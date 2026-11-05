// Dùng chung cho khách hàng và admin: định dạng đơn, hoàn tồn kho.
const { db } = require('./db');

const STATUS_TEXT = { pending: 'Chờ xác nhận', confirmed: 'Đã xác nhận', shipping: 'Đang giao', completed: 'Hoàn thành', cancelled: 'Đã hủy' };
// Luồng hợp lệ (mục 4.2 của tài liệu thiết kế)
const TRANSITIONS = { pending: ['confirmed', 'cancelled'], confirmed: ['shipping', 'cancelled'], shipping: ['completed'], completed: [], cancelled: [] };

function formatOrder(o, withItems) {
  const out = { id: o.id, code: o.code, status: o.status, statusText: STATUS_TEXT[o.status], total: o.total, receiver: o.receiver, phone: o.phone, address: o.address, paymentMethod: o.payment_method, createdAt: o.created_at };
  if (o.customer_name !== undefined) { out.customerName = o.customer_name; out.customerEmail = o.customer_email; }
  if (withItems) out.items = db.prepare('SELECT product_id AS productId, product_name AS name, unit_price AS price, quantity FROM order_items WHERE order_id = ? ORDER BY id').all(o.id).map(i => ({ ...i, lineTotal: i.price * i.quantity }));
  return out;
}
// Hủy đơn: đổi trạng thái và hoàn lại tồn kho (gọi trong giao dịch)
function cancelAndRestock(orderId) {
  const items = db.prepare('SELECT product_id, quantity FROM order_items WHERE order_id = ?').all(orderId);
  const up = db.prepare('UPDATE products SET stock = stock + ? WHERE id = ?');
  items.forEach(i => up.run(i.quantity, i.product_id));
  db.prepare("UPDATE orders SET status = 'cancelled' WHERE id = ?").run(orderId);
}
module.exports = { STATUS_TEXT, TRANSITIONS, formatOrder, cancelAndRestock };
