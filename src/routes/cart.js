// Module C – Giỏ hàng (FR12–FR15).
const { api, HttpError } = require('../router');
const { db } = require('../db');
const { requireAuth } = require('../auth');
const { isInt } = require('../validate');

function readCart(userId) {
  const rows = db.prepare(`SELECT c.product_id, c.quantity, p.name, p.price, p.stock, p.image
    FROM cart_items c JOIN products p ON p.id = c.product_id WHERE c.user_id = ? ORDER BY c.id`).all(userId);
  const items = rows.map(r => ({ productId: r.product_id, name: r.name, image: r.image, price: r.price, stock: r.stock, quantity: r.quantity, lineTotal: r.price * r.quantity }));
  return { items, count: items.reduce((s, i) => s + i.quantity, 0), total: items.reduce((s, i) => s + i.lineTotal, 0) }; // FR15
}
function checkQuantity(q) {
  if (q === undefined || q === null || q === '' || !isInt(q) || Number(q) < 1) throw new HttpError(400, 'Số lượng phải là số nguyên từ 1 trở lên.');
  return Number(q);
}

api.get('/api/cart', requireAuth, ctx => readCart(ctx.user.id));

// FR12 – Thêm vào giỏ (cộng dồn nếu đã có, không vượt tồn kho)
api.post('/api/cart', requireAuth, ctx => {
  const qty = checkQuantity(ctx.body.quantity ?? 1);
  const p = db.prepare('SELECT * FROM products WHERE id = ? AND is_active = 1').get(Number(ctx.body.productId));
  if (!p) throw new HttpError(404, 'Không tìm thấy sản phẩm.');
  if (p.stock <= 0) throw new HttpError(400, 'Sản phẩm đã hết hàng.');
  const cur = db.prepare('SELECT quantity FROM cart_items WHERE user_id = ? AND product_id = ?').get(ctx.user.id, p.id);
  const next = (cur ? cur.quantity : 0) + qty;
  if (next > p.stock) throw new HttpError(400, `Số lượng vượt quá tồn kho (còn ${p.stock}).`);
  if (cur) db.prepare('UPDATE cart_items SET quantity = ? WHERE user_id = ? AND product_id = ?').run(next, ctx.user.id, p.id);
  else db.prepare('INSERT INTO cart_items (user_id, product_id, quantity) VALUES (?,?,?)').run(ctx.user.id, p.id, qty);
  return [201, readCart(ctx.user.id)];
});

// FR14 – Xóa toàn bộ giỏ
api.delete('/api/cart', requireAuth, ctx => {
  db.prepare('DELETE FROM cart_items WHERE user_id = ?').run(ctx.user.id);
  return readCart(ctx.user.id);
});

// FR13 – Sửa số lượng (1 đến tồn kho)
api.put('/api/cart/:productId', requireAuth, ctx => {
  const pid = Number(ctx.params.productId);
  const item = db.prepare('SELECT c.id, p.stock FROM cart_items c JOIN products p ON p.id = c.product_id WHERE c.user_id = ? AND c.product_id = ?').get(ctx.user.id, pid);
  if (!item) throw new HttpError(404, 'Sản phẩm không có trong giỏ hàng.');
  const qty = checkQuantity(ctx.body.quantity);
  if (qty > item.stock) throw new HttpError(400, `Số lượng vượt quá tồn kho (còn ${item.stock}).`);
  db.prepare('UPDATE cart_items SET quantity = ? WHERE id = ?').run(qty, item.id);
  return readCart(ctx.user.id);
});

// FR14 – Xóa một sản phẩm
api.delete('/api/cart/:productId', requireAuth, ctx => {
  const r = db.prepare('DELETE FROM cart_items WHERE user_id = ? AND product_id = ?').run(ctx.user.id, Number(ctx.params.productId));
  if (!r.changes) throw new HttpError(404, 'Sản phẩm không có trong giỏ hàng.');
  return readCart(ctx.user.id);
});

module.exports = { readCart };
