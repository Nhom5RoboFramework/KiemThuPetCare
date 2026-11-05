// Module A – Tài khoản (FR01–FR06): đăng ký, đăng nhập, hồ sơ, đổi mật khẩu.
const { api, HttpError } = require('../router');
const { db } = require('../db');
const { hashPassword, verifyPassword, sign } = require('../security');
const { rules, collect } = require('../validate');
const { requireAuth } = require('../auth');

const MAX_FAILED = 5;
const LOCK_MINUTES = Number(process.env.LOCK_MINUTES || 5);

// FR01 – Đăng ký
api.post('/api/auth/register', ctx => {
  const b = ctx.body;
  const errors = collect({
    fullname: rules.fullname(b.fullname),
    email: rules.email(b.email),
    phone: rules.phone(b.phone),
    password: rules.password(b.password),
    confirmPassword: !b.confirmPassword ? 'Vui lòng xác nhận mật khẩu.' : (b.password !== b.confirmPassword ? 'Mật khẩu xác nhận không khớp.' : undefined),
  });
  if (errors) throw new HttpError(400, 'Dữ liệu không hợp lệ.', errors);
  const email = String(b.email).trim().toLowerCase();
  if (db.prepare('SELECT 1 FROM users WHERE lower(email) = ?').get(email))
    throw new HttpError(409, 'Email đã tồn tại.', { email: 'Email đã tồn tại.' });
  db.prepare('INSERT INTO users (fullname, email, phone, password_hash, created_at) VALUES (?,?,?,?,?)')
    .run(String(b.fullname).trim(), email, String(b.phone).trim(), hashPassword(b.password), new Date().toISOString());
  return [201, { message: 'Đăng ký thành công!' }];
});

// FR02 – Đăng nhập, khóa tạm sau 5 lần sai liên tiếp
api.post('/api/auth/login', ctx => {
  const email = String(ctx.body.email ?? '').trim().toLowerCase();
  const password = String(ctx.body.password ?? '');
  const errors = collect({
    email: email ? undefined : 'Vui lòng nhập email.',
    password: password ? undefined : 'Vui lòng nhập mật khẩu.',
  });
  if (errors) throw new HttpError(400, 'Dữ liệu không hợp lệ.', errors);
  const user = db.prepare('SELECT * FROM users WHERE lower(email) = ?').get(email);
  const bad = new HttpError(401, 'Email hoặc mật khẩu không chính xác.');
  if (!user) throw bad;
  const now = Date.now();
  if (user.locked_until > now) {
    const mins = Math.ceil((user.locked_until - now) / 60000);
    throw new HttpError(423, `Tài khoản tạm khóa do đăng nhập sai nhiều lần. Thử lại sau ${mins} phút.`);
  }
  if (!verifyPassword(password, user.password_hash)) {
    const failed = user.failed_attempts + 1;
    if (failed >= MAX_FAILED) {
      db.prepare('UPDATE users SET failed_attempts = 0, locked_until = ? WHERE id = ?').run(now + LOCK_MINUTES * 60000, user.id);
      throw new HttpError(423, `Tài khoản tạm khóa do đăng nhập sai nhiều lần. Thử lại sau ${LOCK_MINUTES} phút.`);
    }
    db.prepare('UPDATE users SET failed_attempts = ? WHERE id = ?').run(failed, user.id);
    throw bad;
  }
  if (user.status === 'locked') throw new HttpError(403, 'Tài khoản đã bị khóa.');
  db.prepare('UPDATE users SET failed_attempts = 0, locked_until = 0 WHERE id = ?').run(user.id);
  return { token: sign({ sub: user.id, role: user.role }), user: { id: user.id, fullname: user.fullname, email: user.email, role: user.role } };
});

// FR04 – Hồ sơ cá nhân
api.get('/api/me', requireAuth, ctx => ctx.user);
api.put('/api/me', requireAuth, ctx => {
  const b = ctx.body;
  const errors = collect({ fullname: rules.fullname(b.fullname), phone: rules.phone(b.phone), address: rules.address(b.address, false) });
  if (errors) throw new HttpError(400, 'Dữ liệu không hợp lệ.', errors);
  db.prepare('UPDATE users SET fullname = ?, phone = ?, address = ? WHERE id = ?')
    .run(String(b.fullname).trim(), String(b.phone).trim(), String(b.address ?? '').trim(), ctx.user.id);
  return { message: 'Cập nhật hồ sơ thành công.' };
});

// FR05 – Đổi mật khẩu
api.put('/api/me/password', requireAuth, ctx => {
  const { currentPassword, newPassword } = ctx.body;
  const row = db.prepare('SELECT password_hash FROM users WHERE id = ?').get(ctx.user.id);
  const errors = collect({
    currentPassword: !currentPassword ? 'Vui lòng nhập mật khẩu hiện tại.' : (!verifyPassword(String(currentPassword), row.password_hash) ? 'Mật khẩu hiện tại không đúng.' : undefined),
    newPassword: rules.password(newPassword) || (newPassword === currentPassword ? 'Mật khẩu mới phải khác mật khẩu cũ.' : undefined),
  });
  if (errors) throw new HttpError(400, 'Dữ liệu không hợp lệ.', errors);
  db.prepare('UPDATE users SET password_hash = ? WHERE id = ?').run(hashPassword(newPassword), ctx.user.id);
  return { message: 'Đổi mật khẩu thành công.' };
});
