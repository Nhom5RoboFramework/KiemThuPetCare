// SMTP sink local cho test tích hợp: nhận thư nhưng không chuyển tiếp ra Internet.
const net = require('node:net');

const thuDaNhan = new Map();

function docLienKetXacMinh(raw) {
  const headers = raw.split('\r\n\r\n', 1)[0].replace(/\r\n[ \t]+/g, ' ');
  const match = headers.match(/^X-PetCare-Verification-URL:\s*(.+)$/im);
  return match ? match[1].replace(/\s/g, '').trim() : null;
}

function batMayChuSMTP() {
  const server = net.createServer(socket => {
    socket.setEncoding('latin1');
    socket.write('220 localhost PetCare SMTP test sink\r\n');
    let buffer = '';
    let dangNhanThu = false;
    let nguoiNhan = '';

    socket.on('data', chunk => {
      buffer += chunk;
      if (dangNhanThu) {
        const end = buffer.indexOf('\r\n.\r\n');
        if (end < 0) return;
        const raw = buffer.slice(0, end).replace(/\r\n\.\./g, '\r\n.');
        const link = docLienKetXacMinh(raw);
        if (link && nguoiNhan) thuDaNhan.set(nguoiNhan.toLowerCase(), { link, raw });
        buffer = buffer.slice(end + 5);
        dangNhanThu = false;
        socket.write('250 2.0.0 Message accepted\r\n');
      }

      let newline;
      while (!dangNhanThu && (newline = buffer.indexOf('\r\n')) >= 0) {
        const line = buffer.slice(0, newline);
        buffer = buffer.slice(newline + 2);
        const command = line.toUpperCase();
        if (command.startsWith('EHLO ') || command.startsWith('HELO ')) {
          socket.write('250-localhost\r\n250-8BITMIME\r\n250 SIZE 10485760\r\n');
        } else if (command.startsWith('MAIL FROM:')) {
          nguoiNhan = '';
          socket.write('250 2.1.0 Sender accepted\r\n');
        } else if (command.startsWith('RCPT TO:')) {
          nguoiNhan = line.match(/<([^>]+)>/)?.[1] || '';
          socket.write('250 2.1.5 Recipient accepted\r\n');
        } else if (command === 'DATA') {
          dangNhanThu = true;
          socket.write('354 End data with <CR><LF>.<CR><LF>\r\n');
          break;
        } else if (command === 'RSET' || command === 'NOOP') {
          socket.write('250 2.0.0 OK\r\n');
        } else if (command === 'QUIT') {
          socket.write('221 2.0.0 Bye\r\n');
          socket.end();
          break;
        } else {
          socket.write('250 2.0.0 OK\r\n');
        }
      }
    });
    socket.on('error', () => {});
  });

  server.on('error', error => console.error('SMTP test sink không khởi động được:', error.message));
  server.listen(2525, '127.0.0.1', () => console.log('SMTP test sink đang nghe tại 127.0.0.1:2525'));
  return server;
}

function layLienKetEmailDaNhan(email) {
  return thuDaNhan.get(String(email || '').trim().toLowerCase())?.link || null;
}

function xoaThuDaNhan() {
  thuDaNhan.clear();
}

module.exports = { batMayChuSMTP, layLienKetEmailDaNhan, xoaThuDaNhan };
