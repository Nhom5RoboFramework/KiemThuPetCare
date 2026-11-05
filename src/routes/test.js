// API chỉ dành cho môi trường kiểm thử: nạp lại dữ liệu mẫu để mỗi lượt chạy bắt đầu từ trạng thái đã biết.
const { api, HttpError } = require('../router');
const { reset } = require('../db');

api.post('/api/test/reset', () => {
  if (process.env.NODE_ENV === 'production' || process.env.ENABLE_TEST_API === '0') throw new HttpError(404, 'Không tìm thấy.');
  reset();
  return { message: 'Đã nạp lại dữ liệu mẫu.' };
});
