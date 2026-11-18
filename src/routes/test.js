// API chỉ dành cho môi trường kiểm thử: nạp lại dữ liệu mẫu để mỗi lượt chạy bắt đầu từ trạng thái đã biết.
const { api, HttpError } = require('../router');
const { reset } = require('../db');
const { layLienKetTest, xoaOutboxTest } = require('../email');
const { layLienKetEmailDaNhan, xoaThuDaNhan } = require('../../cong_cu/smtp_thu_nghiem');

function requireTestEnvironment() {
  const enabled = process.env.NODE_ENV === 'test' || process.env.ENABLE_TEST_API === '1';
  if (process.env.NODE_ENV === 'production' || !enabled) throw new HttpError(404, 'Không tìm thấy.');
}

api.post('/api/test/reset', () => {
  requireTestEnvironment();
  reset();
  xoaOutboxTest();
  xoaThuDaNhan();
  return { message: 'Đã nạp lại dữ liệu mẫu.' };
});

api.get('/api/test/verification-link', ctx => {
  requireTestEnvironment();
  return { url: layLienKetEmailDaNhan(ctx.query.email) || layLienKetTest(ctx.query.email) };
});
