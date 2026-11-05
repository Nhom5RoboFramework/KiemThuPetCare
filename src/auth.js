// Xác thực (JWT) và phân quyền. Kiểm tra ở máy chủ, không chỉ ẩn nút trên giao diện.
const { db } = require('./db');
const { verify } = require('./security');
const { HttpError } = require('./router');

function requireAuth(ctx) {
  const h = ctx.req.headers.authorization || '';
  const token = h.startsWith('Bearer ') ? h.slice(7) : '';
  const payload = verify(token);
  if (!payload) throw new HttpError(401, 'Vui lòng đăng nhập.');
  const user = db.prepare('SELECT id, fullname, email, phone, address, role, status FROM users WHERE id = ?').get(payload.sub);
  if (!user) throw new HttpError(401, 'Vui lòng đăng nhập.');
  if (user.status === 'locked') throw new HttpError(403, 'Tài khoản đã bị khóa.'); // token còn hạn vẫn bị chặn
  ctx.user = user;
}
function requireAdmin(ctx) {
  requireAuth(ctx);
  if (ctx.user.role !== 'admin') throw new HttpError(403, 'Bạn không có quyền thực hiện thao tác này.');
}
module.exports = { requireAuth, requireAdmin };
