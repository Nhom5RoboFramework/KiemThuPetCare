// Module B – Sản phẩm (FR07–FR11): danh sách, tìm kiếm, lọc, sắp xếp, phân trang, chi tiết.
const { api, HttpError } = require('../router');
const { db } = require('../db');

const PAGE_SIZE = 8;
const SORTS = {
  newest: (a, b) => b.id - a.id,
  price_asc: (a, b) => a.price - b.price || a.id - b.id,
  price_desc: (a, b) => b.price - a.price || a.id - b.id,
  name_asc: (a, b) => a.name.localeCompare(b.name, 'vi'),
};
const toItem = p => ({ id: p.id, name: p.name, price: p.price, stock: p.stock, image: p.image, categoryId: p.category_id, category: p.category });

api.get('/api/categories', () => db.prepare('SELECT id, name FROM categories ORDER BY id').all());

api.get('/api/products', ctx => {
  const q = ctx.query;
  const toNum = (v, label) => {
    if (v === undefined || v === '') return null;
    if (!/^\d+$/.test(v)) throw new HttpError(400, `${label} không hợp lệ.`);
    return Number(v);
  };
  const minPrice = toNum(q.minPrice, 'Giá thấp nhất');
  const maxPrice = toNum(q.maxPrice, 'Giá cao nhất');
  if (minPrice !== null && maxPrice !== null && minPrice > maxPrice)
    throw new HttpError(400, 'Giá thấp nhất phải nhỏ hơn hoặc bằng giá cao nhất.');
  const sort = q.sort || 'newest';
  if (!SORTS[sort]) throw new HttpError(400, 'Cách sắp xếp không hợp lệ.');
  const page = q.page === undefined ? 1 : Number(q.page);
  if (!Number.isInteger(page) || page < 1) throw new HttpError(400, 'Số trang không hợp lệ.');
  const category = toNum(q.category, 'Danh mục');

  const kw = String(q.q || '').trim().toLowerCase();
  let items = db.prepare('SELECT p.*, c.name AS category FROM products p JOIN categories c ON c.id = p.category_id WHERE p.is_active = 1').all();
  if (kw) items = items.filter(p => p.name.toLowerCase().includes(kw)); // không phân biệt hoa thường, kể cả có dấu
  if (category !== null) items = items.filter(p => p.category_id === category);
  if (minPrice !== null) items = items.filter(p => p.price >= minPrice);
  if (maxPrice !== null) items = items.filter(p => p.price <= maxPrice);
  items.sort(SORTS[sort]);
  const total = items.length;
  const totalPages = Math.max(1, Math.ceil(total / PAGE_SIZE));
  return { items: items.slice((page - 1) * PAGE_SIZE, page * PAGE_SIZE).map(toItem), page, pageSize: PAGE_SIZE, total, totalPages };
});

api.get('/api/products/:id', ctx => {
  const p = db.prepare('SELECT p.*, c.name AS category FROM products p JOIN categories c ON c.id = p.category_id WHERE p.id = ? AND p.is_active = 1').get(ctx.params.id);
  if (!p) throw new HttpError(404, 'Không tìm thấy sản phẩm.');
  return { ...toItem(p), description: p.description };
});
