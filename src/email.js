// Tạo và gửi liên kết xác minh email. Test mode giữ email trong outbox giả lập.
const crypto = require('node:crypto');
const { db } = require('./db');

const TOKEN_TTL_MS = 24 * 60 * 60 * 1000;
const RESEND_WAIT_MS = 60 * 1000;
const testOutbox = new Map();
let transporter;

function taoTokenXacMinh(userId) {
  const token = crypto.randomBytes(32).toString('base64url');
  const now = Date.now();
  const tokenHash = crypto.createHash('sha256').update(token).digest('hex');
  db.prepare(`INSERT INTO email_verification_tokens (user_id, token_hash, expires_at, created_at)
    VALUES (?, ?, ?, ?)
    ON CONFLICT(user_id) DO UPDATE SET token_hash=excluded.token_hash, expires_at=excluded.expires_at, created_at=excluded.created_at`)
    .run(userId, tokenHash, now + TOKEN_TTL_MS, now);
  return token;
}

function layTokenHopLe(token) {
  const tokenHash = crypto.createHash('sha256').update(String(token || '')).digest('hex');
  return db.prepare(`SELECT u.id, u.email, t.expires_at
    FROM email_verification_tokens t JOIN users u ON u.id = t.user_id
    WHERE t.token_hash = ?`).get(tokenHash);
}

function xoaToken(userId) {
  db.prepare('DELETE FROM email_verification_tokens WHERE user_id = ?').run(userId);
}

function taoLienKetXacMinh(token) {
  const base = (process.env.APP_BASE_URL || `http://localhost:${process.env.PORT || 3000}`).replace(/\/$/, '');
  return `${base}/xac-minh-email.html?token=${encodeURIComponent(token)}`;
}

async function guiEmailXacMinh(email, url) {
  if (process.env.NODE_ENV === 'test' && !process.env.SMTP_HOST) {
    testOutbox.set(String(email).toLowerCase(), url);
    return;
  }

  const host = process.env.SMTP_HOST;
  if (!host) {
    if (process.env.NODE_ENV === 'production') throw new Error('Chưa cấu hình máy chủ SMTP.');
    console.log(`Liên kết xác minh email cho ${email}: ${url}`);
    return;
  }

  if (!transporter) {
    const nodemailer = require('nodemailer');
    const port = Number(process.env.SMTP_PORT || 587);
    transporter = nodemailer.createTransport({
      host,
      port,
      secure: process.env.SMTP_SECURE === 'true',
      ...(process.env.SMTP_USER ? { auth: { user: process.env.SMTP_USER, pass: process.env.SMTP_PASS || '' } } : {}),
    });
  }

  const from = process.env.SMTP_FROM || process.env.SMTP_USER;
  if (!from) throw new Error('Chưa cấu hình địa chỉ gửi email (SMTP_FROM).');
  await transporter.sendMail({
    from,
    to: email,
    subject: 'Xác minh địa chỉ email PetCare',
    text: `Mở liên kết sau để xác minh email PetCare (có hiệu lực trong 24 giờ):\n${url}`,
    html: `<p>Nhấn liên kết dưới đây để xác minh email PetCare. Liên kết có hiệu lực trong 24 giờ.</p><p><a href="${url}">Xác minh email</a></p>`,
    ...(process.env.NODE_ENV === 'test' ? { headers: { 'X-PetCare-Verification-URL': url } } : {}),
  });
}

function layLienKetTest(email) {
  return testOutbox.get(String(email || '').trim().toLowerCase()) || null;
}

function xoaOutboxTest() {
  testOutbox.clear();
}

module.exports = {
  TOKEN_TTL_MS,
  RESEND_WAIT_MS,
  taoTokenXacMinh,
  layTokenHopLe,
  xoaToken,
  taoLienKetXacMinh,
  guiEmailXacMinh,
  layLienKetTest,
  xoaOutboxTest,
};
