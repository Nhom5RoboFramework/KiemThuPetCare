// Bộ định tuyến nhỏ cho API (thay Express để dự án không cần cài thêm gói nào).
class HttpError extends Error {
  constructor(status, message, errors) { super(message); this.status = status; this.errors = errors; }
}
const routes = [];
function add(method, pattern, ...handlers) {
  const keys = [];
  const re = new RegExp('^' + pattern.replace(/:([A-Za-z]+)/g, (_, k) => { keys.push(k); return '([^/]+)'; }) + '/?$');
  routes.push({ method, re, keys, handlers });
}
const api = {
  get: (p, ...h) => add('GET', p, ...h),
  post: (p, ...h) => add('POST', p, ...h),
  put: (p, ...h) => add('PUT', p, ...h),
  delete: (p, ...h) => add('DELETE', p, ...h),
};
function find(method, path) {
  let pathMatched = false;
  for (const r of routes) {
    const m = r.re.exec(path);
    if (!m) continue;
    pathMatched = true;
    if (r.method !== method) continue;
    const params = {};
    r.keys.forEach((k, i) => { params[k] = decodeURIComponent(m[i + 1]); });
    return { route: r, params };
  }
  return { pathMatched };
}
module.exports = { api, find, HttpError };
