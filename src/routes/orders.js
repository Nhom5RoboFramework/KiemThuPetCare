// Module C/D – Đặt hàng (FR16) và đơn hàng của khách (FR17, FR18).
const { api, HttpError } = require('../router');
const { db, tx } = require('../db');
const { requireAuth } = require('../auth');
const { rules, collect } = require('../validate');
const { formatOrder, cancelAndRestock } = require('../orders');

// FR16 – Đặt hàng: tạo đơn, trừ tồn kho, xóa giỏ trong cùng một giao dịch
api.post('/api/orders', requireAuth, ctx => {
  const b = ctx.body;
  const errors = collect({
    receiver: rules.receiver(b.receiver),
    phone: rules.phone(b.phone),
    address: rules.address(b.address, true),
    paymentMethod: ['cod', 'bank'].includes(b.paymentMethod) ? undefined : 'Vui lòng chọn phương thức thanh toán.',
  });
  if (errors) throw new HttpError(400, 'Dữ liệu không hợp lệ.', errors);

  const order = tx(() => {
    // Đọc lại giỏ và tồn kho từ CSDL, không tin dữ liệu từ trình duyệt
    const rows = db.prepare(`SELECT c.product_id, c.quantity, p.name, p.price, p.stock, p.is_active
      FROM cart_items c JOIN products p ON p.id = c.product_id WHERE c.user_id = ? ORDER BY c.id`).all(ctx.user.id);
    if (!rows.length) throw new HttpError(400, 'Giỏ hàng trống.');
    for (const r of rows) {
      if (!r.is_active) throw new HttpError(400, `Sản phẩm "${r.name}" đã ngừng bán.`);
      if (r.quantity > r.stock) throw new HttpError(400, `Sản phẩm "${r.name}" chỉ còn ${r.stock} trong kho.`);
    }
    const total = rows.reduce((s, r) => s + r.price * r.quantity, 0);
    const res = db.prepare('INSERT INTO orders (user_id, status, total, receiver, phone, address, payment_method, created_at) VALUES (?,?,?,?,?,?,?,?)')
      .run(ctx.user.id, 'pending', total, String(b.receiver).trim(), String(b.phone).trim(), String(b.address).trim(), b.paymentMethod, new Date().toISOString());
    const id = Number(res.lastInsertRowid);
    db.prepare('UPDATE orders SET code = ? WHERE id = ?').run('PC' + String(id).padStart(6, '0'), id);
    const insI = db.prepare('INSERT INTO order_items (order_id, product_id, product_name, unit_price, quantity) VALUES (?,?,?,?,?)');
    const dec = db.prepare('UPDATE products SET stock = stock - ? WHERE id = ?');
    rows.forEach(r => { insI.run(id, r.product_id, r.name, r.price, r.quantity); dec.run(r.quantity, r.product_id); });
    db.prepare('DELETE FROM cart_items WHERE user_id = ?').run(ctx.user.id);
    return db.prepare('SELECT * FROM orders WHERE id = ?').get(id);
  });
  return [201, formatOrder(order, true)];
});

// FR17 – Lịch sử đơn của chính mình, mới nhất trước
api.get('/api/orders', requireAuth, ctx =>
  db.prepare('SELECT * FROM orders WHERE user_id = ? ORDER BY id DESC').all(ctx.user.id).map(o => formatOrder(o, false)));

function ownOrder(ctx) {
  const o = db.prepare('SELECT * FROM orders WHERE id = ?').get(Number(ctx.params.id));
  if (!o) throw new HttpError(404, 'Không tìm thấy đơn hàng.');
  if (o.user_id !== ctx.user.id) throw new HttpError(403, 'Bạn không có quyền xem đơn hàng này.');
  return o;
}
api.get('/api/orders/:id', requireAuth, ctx => formatOrder(ownOrder(ctx), true));

// FR18 – Khách hủy đơn khi còn "Chờ xác nhận"
api.post('/api/orders/:id/cancel', requireAuth, ctx => {
  const o = ownOrder(ctx);
  if (o.status !== 'pending') throw new HttpError(400, 'Chỉ hủy được đơn ở trạng thái "Chờ xác nhận".');
  tx(() => cancelAndRestock(o.id));
  return formatOrder(db.prepare('SELECT * FROM orders WHERE id = ?').get(o.id), true);
});
