# PetCare – web thương mại điện tử (đối tượng kiểm thử)

Web bán đồ dùng cho thú cưng, có máy chủ và cơ sở dữ liệu thật. Dùng làm đối tượng kiểm thử cho đề tài
"Kiểm thử trên nền web bằng Robot Framework". Thiết kế chi tiết nằm trong tài liệu `PhanTichThietKe_PetCare.docx`.

## Chạy

Cần **Node.js 22.13 trở lên**. Không cần `npm install` (chỉ dùng module có sẵn của Node).

```
node server.js
```

Mở http://localhost:3000. Cơ sở dữ liệu SQLite tự tạo ở `data/petcare.db` và nạp dữ liệu mẫu ở lần chạy đầu.
Node có thể in dòng cảnh báo "SQLite is an experimental feature": đây là bình thường.

Biến môi trường (không bắt buộc): `PORT` (mặc định 3000), `DB_FILE`, `LOCK_MINUTES` (thời gian khóa tạm, mặc định 5),
`ENABLE_TEST_API=0` hoặc `NODE_ENV=production` để tắt API nạp lại dữ liệu mẫu.

## Tài khoản mẫu

| Vai trò | Email | Mật khẩu |
|---|---|---|
| Quản trị viên | admin@petcare.vn | Admin123 |
| Khách hàng | khach@petcare.vn | Khach123 |
| Bị quản trị khóa | khoa@petcare.vn | Khoa1234 |

Dữ liệu mẫu: 5 danh mục, 22 sản phẩm (21 đang bán gồm 1 sản phẩm hết hàng "Áo len cho mèo" và 1 sản phẩm đã ẩn "Áo mưa cho chó").

## Nạp lại dữ liệu mẫu (cho kiểm thử)

`POST /api/test/reset` xóa toàn bộ dữ liệu và nạp lại như ban đầu. Gọi trước mỗi lượt kiểm thử để bắt đầu từ trạng thái đã biết.

## Cấu trúc và phân công module

| Module | Thành viên | Mã nguồn API | Trang giao diện |
|---|---|---|---|
| A. Tài khoản | Lê Ngọc Minh | `src/routes/account.js` | `register.html`, `login.html`, `profile.html` |
| B. Sản phẩm | Trần Anh Đức | `src/routes/products.js` | `index.html`, `product.html` |
| C. Giỏ hàng và đặt hàng | Nguyễn Thành Đạt | `src/routes/cart.js`, `src/routes/orders.js` (đặt hàng) | `cart.html`, `checkout.html` |
| D. Đơn hàng và quản trị | Hồ Duy Minh | `src/routes/orders.js` (đơn của khách), `src/routes/admin.js` | `orders.html`, `admin.html` |

Dùng chung: `server.js`, `src/db.js` (lược đồ 6 bảng và dữ liệu mẫu), `src/auth.js`, `src/validate.js`, `public/js/app.js`, `public/css/style.css`.

## Quy tắc nghiệp vụ chính

- Đăng ký: họ tên 2–50 ký tự; email đúng định dạng, không trùng (không phân biệt hoa thường); SĐT 10 số bắt đầu bằng 0; mật khẩu ≥ 8 ký tự gồm chữ và số.
- Đăng nhập sai 5 lần liên tiếp thì khóa tạm 5 phút (mã 423), kể cả khi sau đó nhập đúng. Tài khoản bị quản trị khóa không đăng nhập được (mã 403).
- Sản phẩm: 8 sản phẩm mỗi trang; tìm theo tên không phân biệt hoa thường; giá thấp nhất ≤ giá cao nhất; sắp xếp `newest`, `price_asc`, `price_desc`, `name_asc`.
- Giỏ hàng: số lượng 1 đến tồn kho; thêm lại sản phẩm đã có thì cộng dồn (không vượt tồn kho); tổng tiền = tổng (đơn giá × số lượng). Không có phí giao hàng hay mã giảm giá.
- Đặt hàng: kiểm tra lại tồn kho ở máy chủ; tạo đơn, trừ tồn kho, xóa giỏ trong một giao dịch; đơn lưu đơn giá lúc mua. Mã đơn dạng `PC000001`.
- Trạng thái đơn: Chờ xác nhận → Đã xác nhận → Đang giao → Hoàn thành; hủy được ở "Chờ xác nhận" (khách hoặc admin) và "Đã xác nhận" (admin); hủy thì hoàn tồn kho.
- Admin: thêm, sửa, xóa sản phẩm (đã có trong đơn thì chỉ ẩn); đổi trạng thái đơn đúng luồng; khóa, mở tài khoản (không tự khóa mình); thống kê (doanh thu = tổng đơn Hoàn thành).

## API

Mọi API trả JSON; lỗi có dạng `{ "error": "...", "errors": { "tênTrường": "..." } }`. Token gửi qua tiêu đề `Authorization: Bearer <token>`.

| Phương thức | Đường dẫn | Quyền |
|---|---|---|
| POST | /api/auth/register, /api/auth/login | Khách |
| GET, PUT | /api/me | Đăng nhập |
| PUT | /api/me/password | Đăng nhập |
| GET | /api/products?q&category&minPrice&maxPrice&sort&page | Mọi người |
| GET | /api/products/:id, /api/categories | Mọi người |
| GET, POST, DELETE | /api/cart | Đăng nhập |
| PUT, DELETE | /api/cart/:productId | Đăng nhập |
| POST | /api/orders | Đăng nhập |
| GET | /api/orders, /api/orders/:id | Đăng nhập (đơn của mình) |
| POST | /api/orders/:id/cancel | Đăng nhập (đơn của mình) |
| GET, POST | /api/admin/products | Admin |
| PUT, DELETE | /api/admin/products/:id | Admin |
| GET | /api/admin/orders?status, /api/admin/orders/:id | Admin |
| PUT | /api/admin/orders/:id/status | Admin |
| GET | /api/admin/users | Admin |
| PUT | /api/admin/users/:id/status | Admin |
| GET | /api/admin/stats | Admin |
| POST | /api/test/reset | Môi trường kiểm thử |

## id phần tử giao diện (dùng trong Robot Framework)

- **login.html:** `email`, `password`, `loginButton`, `emailError`, `passwordError`, `loginError`
- **register.html:** `fullname`, `email`, `phone`, `password`, `confirmPassword`, `registerButton`, `<tênTrường>Error`, `successMessage`
- **Thanh trên cùng (mọi trang):** `headerSearchInput`, `headerSearchButton`, `cartCount`, `navCart`, `navLogin`, `navRegister`, `userName`, `navOrders`, `navProfile`, `navAdmin`, `logoutButton`
- **index.html:** `searchInput`, `categoryFilter`, `minPrice`, `maxPrice`, `sortSelect`, `applyFilter`, `resetFilter`, `resultCount`, `filterError`, `productList` (thẻ `.product-card`, `.product-name`, `.product-price`, `.product-stock`, `.detail-link`), `emptyMessage`, `prevPage`, `nextPage`, `pageInfo`
- **product.html:** `productName`, `productPrice`, `productStock`, `quantity`, `addToCartButton`, `message`, `successMessage`
- **cart.html:** `cartBody` (hàng `tr`, `.qty-input`, `.remove-btn`), `cartTotal`, `cartMessage`, `clearCart`, `checkoutButton`, `emptyCart`
- **checkout.html:** `receiver`, `phone`, `address`, `payCod`, `payBank`, `placeOrderButton`, `<tênTrường>Error`, `orderError`, `orderSuccess`, `orderCode`, `orderTotalDone`
- **orders.html:** `orderList` (`.order-code`, `.order-status`, `.view-order`), `orderDetail`, `detailStatus`, `detailTotal`, `cancelOrderButton`, `orderMessage`, `successMessage`
- **profile.html:** `email`, `fullname`, `phone`, `address`, `saveProfileButton`, `profileMessage`, `currentPassword`, `newPassword`, `changePasswordButton`, `passwordMessage`
- **admin.html:** thẻ `tabProducts`, `tabOrders`, `tabUsers`, `tabStats`; sản phẩm `pName`, `pCategory`, `pPrice`, `pStock`, `pDescription`, `saveProductButton`, `adminProductList` (`.edit-product`, `.delete-product` – bấm hai lần để xóa); đơn hàng `orderStatusFilter`, `adminOrderList` (`.status-btn` với `data-status`), `adminOrderMessage`, `adminOrderError`; người dùng `userList` (`.toggle-lock`); thống kê `statTotalOrders`, `statRevenue`, `stat-<trạngThái>`

# KiemThuPetCare
Sau khi nhận được nhận xét và góp ý từ thầy Trần Tuấn Vinh, nhóm đã tiếp thu và quyết định tái phát triển dự án. Dựa vào những kinh nghệm đã có, hoàn thiện 1 dự án bài bản, có quy củ
