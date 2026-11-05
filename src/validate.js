// Quy tắc kiểm tra dữ liệu dùng chung (theo mục 3 của tài liệu thiết kế).
const isInt = v => typeof v === 'number' ? Number.isInteger(v) : /^-?\d+$/.test(String(v).trim());

const rules = {
  fullname(v) {
    v = String(v ?? '').trim();
    if (!v) return 'Vui lòng nhập họ tên.';
    if (v.length < 2 || v.length > 50) return 'Họ tên phải từ 2 đến 50 ký tự.';
  },
  email(v) {
    v = String(v ?? '').trim();
    if (!v) return 'Vui lòng nhập email.';
    if (v.length > 100 || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(v)) return 'Email không đúng định dạng.';
  },
  phone(v) {
    v = String(v ?? '').trim();
    if (!v) return 'Vui lòng nhập số điện thoại.';
    if (!/^0\d{9}$/.test(v)) return 'Số điện thoại phải gồm 10 chữ số, bắt đầu bằng 0.';
  },
  password(v) {
    v = String(v ?? '');
    if (!v) return 'Vui lòng nhập mật khẩu.';
    if (v.length < 8 || !/[A-Za-z]/.test(v) || !/\d/.test(v)) return 'Mật khẩu phải có ít nhất 8 ký tự, gồm cả chữ và số.';
  },
  address(v, required) {
    v = String(v ?? '').trim();
    if (!v) return required ? 'Vui lòng nhập địa chỉ.' : undefined;
    if (v.length < 10 || v.length > 200) return 'Địa chỉ phải từ 10 đến 200 ký tự.';
  },
  receiver(v) {
    v = String(v ?? '').trim();
    if (!v) return 'Vui lòng nhập tên người nhận.';
    if (v.length < 2 || v.length > 50) return 'Tên người nhận phải từ 2 đến 50 ký tự.';
  },
};
function collect(obj) { // bỏ các khóa không có lỗi
  const errors = {};
  for (const [k, v] of Object.entries(obj)) if (v) errors[k] = v;
  return Object.keys(errors).length ? errors : null;
}
module.exports = { rules, collect, isInt };
