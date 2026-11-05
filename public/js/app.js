// Tiện ích dùng chung cho mọi trang: gọi API, tiêu đề trang, đăng xuất, định dạng.
(function () {
  const STATUS = { pending: 'Chờ xác nhận', confirmed: 'Đã xác nhận', shipping: 'Đang giao', completed: 'Hoàn thành', cancelled: 'Đã hủy' };
  const $ = id => document.getElementById(id);
  const esc = s => String(s ?? '').replace(/[&<>"']/g, c => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c]));
  const money = n => Number(n).toLocaleString('vi-VN') + 'đ';
  const dateText = iso => new Date(iso).toLocaleString('vi-VN');
  const statusBadge = s => `<span class="status st-${s}">${STATUS[s] || s}</span>`;

  async function call(method, path, body) {
    const token = localStorage.getItem('token');
    let res;
    try {
      res = await fetch(path, { method, headers: { 'Content-Type': 'application/json', ...(token ? { Authorization: 'Bearer ' + token } : {}) }, body: body ? JSON.stringify(body) : undefined });
    } catch (e) { return { status: 0, data: { error: 'Không kết nối được máy chủ.' } }; }
    let data = {}; try { data = await res.json(); } catch (e) {}
    if (res.status === 401 && token) { localStorage.removeItem('token'); } // token hết hạn hoặc không hợp lệ
    return { status: res.status, data };
  }

  // Gắn lỗi theo từng ô: phần tử có id "<tênTrường>Error"
  function setErrors(fields, errors, prefix) {
    fields.forEach(f => { const el = $((prefix || '') + f + 'Error'); if (el) el.textContent = (errors && errors[f]) || ''; });
  }
  function setMsg(id, text) { const el = $(id); if (el) el.textContent = text || ''; }

  let user = null;
  async function loadUser() {
    if (!localStorage.getItem('token')) return null;
    const r = await call('GET', '/api/me');
    return r.status === 200 ? r.data : null;
  }
  async function refreshCartCount() {
    const el = $('cartCount'); if (!el) return;
    if (!user) { el.textContent = '0'; return; }
    const r = await call('GET', '/api/cart');
    el.textContent = r.status === 200 ? r.data.count : '0';
  }
  function logout() { localStorage.removeItem('token'); location.href = 'login.html'; }
  function goLogin() { location.href = 'login.html?next=' + encodeURIComponent(location.pathname.split('/').pop() + location.search); }

  function renderHeader() {
    const h = $('site-header'); if (!h) return;
    const auth = user
      ? `<span class="hello">Xin chào, <b id="userName">${esc(user.fullname)}</b></span>
         <a href="orders.html" id="navOrders">Đơn hàng</a>
         <a href="profile.html" id="navProfile">Hồ sơ</a>
         ${user.role === 'admin' ? '<a href="admin.html" id="navAdmin">Quản trị</a>' : ''}
         <button class="link-btn" id="logoutButton" type="button">Đăng xuất</button>`
      : `<a href="login.html" id="navLogin">Đăng nhập</a><a href="register.html" id="navRegister">Đăng ký</a>`;
    h.innerHTML = `<header class="header"><div class="header-inner">
      <a class="logo" href="index.html" id="logo">🐾 PetCare</a>
      <form class="search" id="headerSearch"><input id="headerSearchInput" placeholder="Tìm sản phẩm..." autocomplete="off"><button type="submit" id="headerSearchButton">Tìm</button></form>
      <nav class="nav"><a href="index.html" id="navProducts">Sản phẩm</a>
        <a href="cart.html" id="navCart">Giỏ hàng <span class="badge" id="cartCount">0</span></a>${auth}</nav></div></header>`;
    $('headerSearch').addEventListener('submit', e => { e.preventDefault(); const q = $('headerSearchInput').value.trim(); location.href = 'index.html' + (q ? '?q=' + encodeURIComponent(q) : ''); });
    const lb = $('logoutButton'); if (lb) lb.addEventListener('click', logout);
  }

  const ready = (async () => {
    user = await loadUser();
    renderHeader();
    await refreshCartCount();
    return user;
  })();

  window.PetCare = {
    $, esc, money, dateText, statusBadge, STATUS, call, setErrors, setMsg, ready, refreshCartCount, logout,
    user: () => user,
    async requireLogin() { const u = await ready; if (!u) { goLogin(); return null; } return u; },
    async requireAdmin() {
      const u = await this.requireLogin(); if (!u) return null;
      if (u.role !== 'admin') { const m = $('forbidden'); if (m) m.style.display = 'block'; const c = $('adminContent'); if (c) c.style.display = 'none'; return null; }
      return u;
    },
  };
})();
