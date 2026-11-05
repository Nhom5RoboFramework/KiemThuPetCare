// PetCare – máy chủ web: phục vụ giao diện (thư mục public) và API REST (/api/...).
// Chạy: node server.js   (cần Node.js 22.13 trở lên, không cần cài thêm gói nào)
const http = require('http');
const fs = require('fs');
const path = require('path');
const { find, HttpError } = require('./src/router');
require('./src/db');
require('./src/routes/account');
require('./src/routes/products');
require('./src/routes/cart');
require('./src/routes/orders');
require('./src/routes/admin');
require('./src/routes/test');

const PORT = Number(process.env.PORT || 3000);
const PUBLIC = path.join(__dirname, 'public');
const MIME = { '.html': 'text/html; charset=utf-8', '.css': 'text/css; charset=utf-8', '.js': 'text/javascript; charset=utf-8', '.json': 'application/json', '.png': 'image/png', '.ico': 'image/x-icon', '.svg': 'image/svg+xml' };

function sendJson(res, status, obj) {
  const body = JSON.stringify(obj);
  res.writeHead(status, { 'Content-Type': 'application/json; charset=utf-8', 'Cache-Control': 'no-store' });
  res.end(body);
}
function readBody(req) {
  return new Promise((resolve, reject) => {
    let data = '';
    req.on('data', c => { data += c; if (data.length > 100000) { reject(new HttpError(413, 'Dữ liệu quá lớn.')); req.destroy(); } });
    req.on('end', () => {
      if (!data) return resolve({});
      try { const o = JSON.parse(data); resolve(o && typeof o === 'object' ? o : {}); }
      catch { reject(new HttpError(400, 'Dữ liệu gửi lên không phải JSON hợp lệ.')); }
    });
    req.on('error', reject);
  });
}

async function handleApi(req, res, url) {
  try {
    const { route, params, pathMatched } = find(req.method, url.pathname);
    if (!route) throw new HttpError(pathMatched ? 405 : 404, pathMatched ? 'Phương thức không được hỗ trợ.' : 'Không tìm thấy API.');
    const ctx = { req, res, params, query: Object.fromEntries(url.searchParams), body: {}, user: null };
    if (['POST', 'PUT', 'PATCH'].includes(req.method)) ctx.body = await readBody(req);
    let result;
    for (const h of route.handlers) { const r = await h(ctx); if (r !== undefined) result = r; }
    if (Array.isArray(result) && typeof result[0] === 'number') sendJson(res, result[0], result[1]);
    else sendJson(res, 200, result ?? {});
  } catch (e) {
    if (e instanceof HttpError) sendJson(res, e.status, { error: e.message, ...(e.errors ? { errors: e.errors } : {}) });
    else { console.error(e); sendJson(res, 500, { error: 'Lỗi máy chủ.' }); }
  }
}

function serveStatic(req, res, url) {
  let rel = decodeURIComponent(url.pathname);
  if (rel === '/') rel = '/index.html';
  const file = path.normalize(path.join(PUBLIC, rel));
  if (!file.startsWith(PUBLIC)) { res.writeHead(403); return res.end('Forbidden'); }
  fs.readFile(file, (err, data) => {
    if (err) { res.writeHead(404, { 'Content-Type': 'text/plain; charset=utf-8' }); return res.end('Không tìm thấy trang.'); }
    res.writeHead(200, { 'Content-Type': MIME[path.extname(file)] || 'application/octet-stream', 'Cache-Control': 'no-cache' });
    res.end(data);
  });
}

const server = http.createServer((req, res) => {
  const url = new URL(req.url, `http://${req.headers.host || 'localhost'}`);
  if (url.pathname.startsWith('/api/')) handleApi(req, res, url);
  else serveStatic(req, res, url);
});
server.listen(PORT, () => console.log(`PetCare đang chạy tại http://localhost:${PORT}`));
