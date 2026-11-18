// Module A – Tài khoản (FR01–FR06): đăng ký, đăng nhập, hồ sơ, đổi mật khẩu.
const { api, HttpError } = require('../router');
const { db } = require('../db');
const { hashPassword, verifyPassword, sign } = require('../security');
const { rules, collect } = require('../validate');
const { requireAuth } = require('../auth');
const {
  RESEND_WAIT_MS,
  taoTokenXacMinh,
  layTokenHopLe,
  xoaToken,
  taoLienKetXacMinh,
  guiEmailXacMinh,
} = require('../email');

const MAX_FAILED = 5;
const LOCK_MINUTES = Number(process.env.LOCK_MINUTES || 5);

// FR01 – Đăng ký
api.post('/api/auth/register', async ctx => {
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
  const result = db.prepare(`INSERT INTO users (fullname, email, phone, password_hash, email_verified, created_at)
    VALUES (?, ?, ?, ?, 0, ?)`).run(
    String(b.fullname).trim(), email, String(b.phone).trim(), hashPassword(b.password), new Date().toISOString(),
  );
  const userId = Number(result.lastInsertRowid);
  const token = taoTokenXacMinh(userId);
  try {
    await guiEmailXacMinh(email, taoLienKetXacMinh(token));
  } catch (error) {
    xoaToken(userId);
    console.error('Không gửi được email xác minh:', error.message);
    throw new HttpError(503, 'Tạo tài khoản xong nhưng chưa gửi được email xác minh. Vui lòng thử gửi lại.');
  }
  return [201, { message: 'Đăng ký thành công. Vui lòng xác minh email trước khi đăng nhập.' }];
});

// Xác minh email bằng token dùng một lần, có thời hạn.
api.post('/api/auth/verify-email', ctx => {
  const record = layTokenHopLe(ctx.body.token);
  if (!record || record.expires_at <= Date.now()) {
    if (record) xoaToken(record.id);
    throw new HttpError(400, 'Liên kết xác minh không hợp lệ hoặc đã hết hạn.');
  }
  db.prepare('UPDATE users SET email_verified = 1 WHERE id = ?').run(record.id);
  xoaToken(record.id);
  return { message: 'Xác minh email thành công. Bạn có thể đăng nhập.' };
});

// Gửi lại email với phản hồi chung để không tiết lộ email có đăng ký hay chưa.
api.post('/api/auth/resend-verification', async ctx => {
  const email = String(ctx.body.email ?? '').trim().toLowerCase();
  const user = db.prepare('SELECT id, email, email_verified FROM users WHERE lower(email) = ?').get(email);
  const reply = 'Nếu email cần xác minh, PetCare sẽ gửi liên kết đến địa chỉ đó. Hãy chờ ít nhất 1 phút trước khi yêu cầu gửi lại.';
  if (!user || user.email_verified) return { message: reply };

  const current = db.prepare('SELECT created_at FROM email_verification_tokens WHERE user_id = ?').get(user.id);
  if (current && Date.now() - current.created_at < RESEND_WAIT_MS)
    return { message: reply };

  const token = taoTokenXacMinh(user.id);
  try {
    await guiEmailXacMinh(user.email, taoLienKetXacMinh(token));
  } catch (error) {
    xoaToken(user.id);
    console.error('Không gửi được email xác minh:', error.message);
    throw new HttpError(503, 'Chưa gửi được email xác minh. Vui lòng thử lại sau.');
  }
  return { message: reply };
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
  if (!user.email_verified) throw new HttpError(403, 'Email chưa được xác minh. Hãy xác minh email trước khi đăng nhập.');
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
