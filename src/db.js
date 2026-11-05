// Cơ sở dữ liệu SQLite (module có sẵn của Node: node:sqlite). Không cần cài thêm gói nào.
const { DatabaseSync } = require('node:sqlite');
const fs = require('fs');
const path = require('path');
const { hashPassword } = require('./security');

const DB_FILE = process.env.DB_FILE || path.join(__dirname, '..', 'data', 'petcare.db');
if (DB_FILE !== ':memory:') fs.mkdirSync(path.dirname(DB_FILE), { recursive: true });
const db = new DatabaseSync(DB_FILE);
db.exec('PRAGMA foreign_keys = ON');

db.exec(`
CREATE TABLE IF NOT EXISTS users (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  fullname TEXT NOT NULL,
  email TEXT NOT NULL UNIQUE,
  phone TEXT NOT NULL DEFAULT '',
  address TEXT NOT NULL DEFAULT '',
  password_hash TEXT NOT NULL,
  role TEXT NOT NULL DEFAULT 'customer' CHECK (role IN ('customer','admin')),
  status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active','locked')),
  failed_attempts INTEGER NOT NULL DEFAULT 0,
  locked_until INTEGER NOT NULL DEFAULT 0,
  created_at TEXT NOT NULL
);
CREATE TABLE IF NOT EXISTS categories (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL UNIQUE
);
CREATE TABLE IF NOT EXISTS products (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  category_id INTEGER NOT NULL REFERENCES categories(id),
  name TEXT NOT NULL,
  description TEXT NOT NULL DEFAULT '',
  image TEXT NOT NULL DEFAULT '',
  price INTEGER NOT NULL CHECK (price > 0),
  stock INTEGER NOT NULL CHECK (stock >= 0),
  is_active INTEGER NOT NULL DEFAULT 1,
  created_at TEXT NOT NULL
);
CREATE TABLE IF NOT EXISTS cart_items (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER NOT NULL REFERENCES users(id),
  product_id INTEGER NOT NULL REFERENCES products(id),
  quantity INTEGER NOT NULL CHECK (quantity >= 1),
  UNIQUE (user_id, product_id)
);
CREATE TABLE IF NOT EXISTS orders (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  code TEXT UNIQUE,
  user_id INTEGER NOT NULL REFERENCES users(id),
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending','confirmed','shipping','completed','cancelled')),
  total INTEGER NOT NULL,
  receiver TEXT NOT NULL,
  phone TEXT NOT NULL,
  address TEXT NOT NULL,
  payment_method TEXT NOT NULL CHECK (payment_method IN ('cod','bank')),
  created_at TEXT NOT NULL
);
CREATE TABLE IF NOT EXISTS order_items (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  order_id INTEGER NOT NULL REFERENCES orders(id),
  product_id INTEGER NOT NULL REFERENCES products(id),
  product_name TEXT NOT NULL,
  unit_price INTEGER NOT NULL,
  quantity INTEGER NOT NULL CHECK (quantity >= 1)
);
`);

// Chạy nhiều lệnh trong một giao dịch: lỗi thì hoàn tác toàn bộ.
function tx(fn) {
  db.exec('BEGIN');
  try { const r = fn(); db.exec('COMMIT'); return r; }
  catch (e) { db.exec('ROLLBACK'); throw e; }
}

const CATEGORIES = ['Thức ăn', 'Đồ chơi', 'Phụ kiện', 'Chăm sóc sức khỏe', 'Quần áo'];
// [danh mục (1-5), tên, mô tả, biểu tượng, giá, tồn kho, đang bán]
const PRODUCTS = [
  [1, 'Thức ăn hạt cho chó', 'Hạt dinh dưỡng đầy đủ cho chó trưởng thành, túi 1 kg.', '🍖', 150000, 50, 1],
  [1, 'Pate cho mèo', 'Pate cá ngừ mềm mịn, lon 85 g.', '🐟', 35000, 100, 1],
  [1, 'Xương gặm sạch răng', 'Xương gặm giúp làm sạch răng cho chó.', '🦴', 45000, 80, 1],
  [1, 'Thức ăn hạt cho mèo', 'Hạt cho mèo mọi lứa tuổi, túi 1 kg.', '🥫', 180000, 40, 1],
  [1, 'Bánh thưởng cho chó', 'Bánh thưởng huấn luyện vị thịt gà.', '🍪', 60000, 60, 1],
  [2, 'Bóng cao su cho chó', 'Bóng cao su bền, nảy tốt.', '🎾', 40000, 70, 1],
  [2, 'Cần câu lông cho mèo', 'Cần câu lông vũ kích thích mèo vận động.', '🪶', 55000, 45, 1],
  [2, 'Chuột bông cho mèo', 'Chuột bông nhồi catnip.', '🐭', 30000, 90, 1],
  [2, 'Dây kéo co', 'Dây kéo co bằng sợi bông cho chó.', '🪢', 50000, 35, 1],
  [2, 'Cào móng mèo', 'Tấm cào móng bằng bìa carton nén.', '🐱', 120000, 25, 1],
  [3, 'Dây dắt thú cưng', 'Dây dắt dài 1,5 m, có đệm tay.', '🦮', 90000, 60, 1],
  [3, 'Vòng cổ có chuông', 'Vòng cổ điều chỉnh được, kèm chuông nhỏ.', '🔔', 45000, 80, 1],
  [3, 'Bát ăn inox', 'Bát inox chống trượt, dung tích 500 ml.', '🥣', 70000, 55, 1],
  [3, 'Túi vận chuyển', 'Túi vận chuyển thoáng khí cho chó mèo nhỏ.', '🧳', 350000, 15, 1],
  [3, 'Ổ nằm êm', 'Ổ nằm lót bông mềm, giặt được.', '🛏️', 260000, 20, 1],
  [4, 'Sữa tắm thú cưng', 'Sữa tắm dịu nhẹ, chai 300 ml.', '🧴', 95000, 50, 1],
  [4, 'Lược chải lông', 'Lược chải lông rụng, cán cầm êm.', '🪮', 65000, 65, 1],
  [4, 'Kéo cắt móng', 'Kéo cắt móng chuyên dụng, có khóa an toàn.', '✂️', 80000, 40, 1],
  [4, 'Viên tẩy giun', 'Viên tẩy giun định kỳ, hộp 4 viên.', '💊', 110000, 30, 1],
  [5, 'Áo hoodie cho chó', 'Áo hoodie giữ ấm mùa đông.', '👕', 130000, 30, 1],
  [5, 'Áo len cho mèo', 'Áo len cổ tròn (tạm hết hàng).', '🧥', 120000, 0, 1],
  [5, 'Áo mưa cho chó', 'Mẫu cũ, đã ngừng bán.', '☔', 100000, 10, 0],
];

function seed() {
  const now = new Date().toISOString();
  const insU = db.prepare('INSERT INTO users (fullname, email, phone, address, password_hash, role, status, created_at) VALUES (?,?,?,?,?,?,?,?)');
  insU.run('Quản trị viên', 'admin@petcare.vn', '0900000000', '1 Đường Láng, Hà Nội', hashPassword('Admin123'), 'admin', 'active', now);
  insU.run('Nguyễn Văn A', 'khach@petcare.vn', '0912345678', '12 Nguyễn Trãi, Hà Nội', hashPassword('Khach123'), 'customer', 'active', now);
  insU.run('Tài Khoản Bị Khóa', 'khoa@petcare.vn', '0987654321', '', hashPassword('Khoa1234'), 'customer', 'locked', now);
  const insC = db.prepare('INSERT INTO categories (name) VALUES (?)');
  CATEGORIES.forEach(c => insC.run(c));
  const insP = db.prepare('INSERT INTO products (category_id, name, description, image, price, stock, is_active, created_at) VALUES (?,?,?,?,?,?,?,?)');
  PRODUCTS.forEach((p, i) => insP.run(p[0], p[1], p[2], p[3], p[4], p[5], p[6], new Date(Date.now() - (PRODUCTS.length - i) * 60000).toISOString()));
}

// Xóa sạch dữ liệu và nạp lại dữ liệu mẫu (dùng cho kiểm thử và lần chạy đầu).
function reset() {
  tx(() => {
    ['order_items', 'orders', 'cart_items', 'products', 'categories', 'users'].forEach(t => db.exec(`DELETE FROM ${t}`));
    db.exec("DELETE FROM sqlite_sequence");
    seed();
  });
}

if (db.prepare('SELECT COUNT(*) AS n FROM users').get().n === 0) reset();

module.exports = { db, tx, reset };
