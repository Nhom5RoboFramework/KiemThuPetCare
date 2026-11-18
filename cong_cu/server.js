// Máy chủ dành cho Robot Framework, dùng cổng và database test riêng.
const path = require('path');

process.env.NODE_ENV = 'test';
process.env.ENABLE_TEST_API = '1';
process.env.PORT = '3101';
// Rút ngắn thời gian khóa trong môi trường kiểm thử để có thể kiểm tra hết hạn.
process.env.LOCK_MINUTES = '0.02';
process.env.DB_FILE = path.join(__dirname, '..', 'robot', '.test-data', 'petcare.db');
process.env.SMTP_HOST = '127.0.0.1';
process.env.SMTP_PORT = '2525';
process.env.SMTP_FROM = 'PetCare Test <no-reply@petcare.test>';
process.env.SMTP_SECURE = 'false';

require('./smtp_thu_nghiem').batMayChuSMTP();
require('../server');
