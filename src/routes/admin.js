// Module D – Quản trị (FR19–FR24).
const { api, HttpError } = require('../router');
const { db, tx } = require('../db');
const { requireAdmin } = require('../auth');
const { collect, isInt } = require('../validate');
const { STATUS_TEXT, TRANSITIONS, formatOrder, cancelAndRestock } = require('../orders');

function productErrors(b) {
  const name = String(b.name ?? '').trim();
  return collect({
    name: !name ? 'Vui lòng nhập tên sản phẩm.' : (name.length < 2 || name.length > 100 ? 'Tên sản phẩm phải từ 2 đến 100 ký tự.' : undefined),
    price: b.price === undefined || b.price === '' || !isInt(b.price) || Number(b.price) <= 0 ? 'Giá phải là số nguyên lớn hơn 0.' : undefined,
    stock: b.stock === undefined || b.stock === '' || !isInt(b.stock) || Number(b.stock) < 0 ? 'Tồn kho phải là số nguyên không âm.' : undefined,
    categoryId: db.prepare('SELECT 1 FROM categories WHERE id = ?').get(Number(b.categoryId)) ? undefined : 'Vui lòng chọn danh mục.',
  });
}
const adminProduct = p => ({ id: p.id, name: p.name, description: p.description, image: p.image, price: p.price, stock: p.stock, categoryId: p.category_id, category: p.category, isActive: !!p.is_active });
const listProducts = () => db.prepare('SELECT p.*, c.name AS category FROM products p JOIN categories c ON c.id = p.category_id ORDER BY p.id DESC').all().map(adminProduct);

api.get('/api/admin/products', requireAdmin, () => listProducts());

// FR19 – Thêm sản phẩm
api.post('/api/admin/products', requireAdmin, ctx => {
  const b = ctx.body, errors = productErrors(b);
  if (errors) throw new HttpError(400, 'Dữ liệu không hợp lệ.', errors);
  const r = db.prepare('INSERT INTO products (category_id, name, description, image, price, stock, is_active, created_at) VALUES (?,?,?,?,?,?,1,?)')
    .run(Number(b.categoryId), String(b.name).trim(), String(b.description ?? '').trim(), String(b.image ?? '🐾'), Number(b.price), Number(b.stock), new Date().toISOString());
  return [201, adminProduct(db.prepare('SELECT p.*, c.name AS category FROM products p JOIN categories c ON c.id = p.category_id WHERE p.id = ?').get(Number(r.lastInsertRowid)))];
});

// FR20 – Sửa sản phẩm
api.put('/api/admin/products/:id', requireAdmin, ctx => {
  const id = Number(ctx.params.id), b = ctx.body;
  const cur = db.prepare('SELECT * FROM products WHERE id = ?').get(id);
  if (!cur) throw new HttpError(404, 'Không tìm thấy sản phẩm.');
  const errors = productErrors(b);
  if (errors) throw new HttpError(400, 'Dữ liệu không hợp lệ.', errors);
  const active = b.isActive === undefined ? cur.is_active : (b.isActive ? 1 : 0);
  db.prepare('UPDATE products SET category_id=?, name=?, description=?, image=?, price=?, stock=?, is_active=? WHERE id=?')
    .run(Number(b.categoryId), String(b.name).trim(), String(b.description ?? cur.description).trim(), String(b.image ?? cur.image), Number(b.price), Number(b.stock), active, id);
  return adminProduct(db.prepare('SELECT p.*, c.name AS category FROM products p JOIN categories c ON c.id = p.category_id WHERE p.id = ?').get(id));
});

// FR20 – Xóa sản phẩm: đã có trong đơn thì chỉ ẩn
api.delete('/api/admin/products/:id', requireAdmin, ctx => {
  const id = Number(ctx.params.id);
  if (!db.prepare('SELECT 1 FROM products WHERE id = ?').get(id)) throw new HttpError(404, 'Không tìm thấy sản phẩm.');
  if (db.prepare('SELECT 1 FROM order_items WHERE product_id = ?').get(id)) {
    db.prepare('UPDATE products SET is_active = 0 WHERE id = ?').run(id);
    return { hidden: true, message: 'Sản phẩm đã có trong đơn hàng nên được ẩn thay vì xóa.' };
  }
  tx(() => { db.prepare('DELETE FROM cart_items WHERE product_id = ?').run(id); db.prepare('DELETE FROM products WHERE id = ?').run(id); });
  return { hidden: false, message: 'Đã xóa sản phẩm.' };
});

// FR21 – Xem, lọc đơn
api.get('/api/admin/orders', requireAdmin, ctx => {
  const st = ctx.query.status;
  if (st && !STATUS_TEXT[st]) throw new HttpError(400, 'Trạng thái không hợp lệ.');
  const sql = `SELECT o.*, u.fullname AS customer_name, u.email AS customer_email FROM orders o JOIN users u ON u.id = o.user_id ${st ? 'WHERE o.status = ?' : ''} ORDER BY o.id DESC`;
  return (st ? db.prepare(sql).all(st) : db.prepare(sql).all()).map(o => formatOrder(o, false));
});
api.get('/api/admin/orders/:id', requireAdmin, ctx => {
  const o = db.prepare('SELECT o.*, u.fullname AS customer_name, u.email AS customer_email FROM orders o JOIN users u ON u.id = o.user_id WHERE o.id = ?').get(Number(ctx.params.id));
  if (!o) throw new HttpError(404, 'Không tìm thấy đơn hàng.');
  return formatOrder(o, true);
});

// FR22 – Đổi trạng thái đơn theo đúng luồng
api.put('/api/admin/orders/:id/status', requireAdmin, ctx => {
  const o = db.prepare('SELECT * FROM orders WHERE id = ?').get(Number(ctx.params.id));
  if (!o) throw new HttpError(404, 'Không tìm thấy đơn hàng.');
  const next = ctx.body.status;
  if (!STATUS_TEXT[next]) throw new HttpError(400, 'Trạng thái không hợp lệ.');
  if (!TRANSITIONS[o.status].includes(next))
    throw new HttpError(400, `Không thể chuyển từ "${STATUS_TEXT[o.status]}" sang "${STATUS_TEXT[next]}".`);
  tx(() => { if (next === 'cancelled') cancelAndRestock(o.id); else db.prepare('UPDATE orders SET status = ? WHERE id = ?').run(next, o.id); });
  return formatOrder(db.prepare('SELECT * FROM orders WHERE id = ?').get(o.id), true);
});

// FR23 – Khóa, mở tài khoản
const userRow = u => ({ id: u.id, fullname: u.fullname, email: u.email, phone: u.phone, role: u.role, status: u.status, createdAt: u.created_at });
api.get('/api/admin/users', requireAdmin, () => db.prepare('SELECT * FROM users ORDER BY id').all().map(userRow));
api.put('/api/admin/users/:id/status', requireAdmin, ctx => {
  const id = Number(ctx.params.id), st = ctx.body.status;
  const u = db.prepare('SELECT * FROM users WHERE id = ?').get(id);
  if (!u) throw new HttpError(404, 'Không tìm thấy tài khoản.');
  if (!['active', 'locked'].includes(st)) throw new HttpError(400, 'Trạng thái không hợp lệ.');
  if (id === ctx.user.id) throw new HttpError(400, 'Không thể tự khóa tài khoản của chính mình.');
  db.prepare('UPDATE users SET status = ?, failed_attempts = 0, locked_until = 0 WHERE id = ?').run(st, id);
  return userRow(db.prepare('SELECT * FROM users WHERE id = ?').get(id));
});

// FR24 – Thống kê
api.get('/api/admin/stats', requireAdmin, () => {
  const byStatus = {};
  Object.keys(STATUS_TEXT).forEach(s => { byStatus[s] = 0; });
  db.prepare('SELECT status, COUNT(*) AS n FROM orders GROUP BY status').all().forEach(r => { byStatus[r.status] = r.n; });
  const revenue = db.prepare("SELECT COALESCE(SUM(total), 0) AS s FROM orders WHERE status = 'completed'").get().s;
  return { ordersByStatus: byStatus, totalOrders: Object.values(byStatus).reduce((a, b) => a + b, 0), revenue };
});
