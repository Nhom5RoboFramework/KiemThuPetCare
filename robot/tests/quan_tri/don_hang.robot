*** Settings ***
Resource          ../../resources/dung_chung.resource
Test Setup        Chuẩn Bị Ca Kiểm Thử
Test Teardown     Close Browser
Documentation     Kiểm thử trạng thái, bộ lọc đơn và thống kê quản trị.

*** Test Cases ***
[ADMIN-ORDER-01] Quản trị viên chuyển đơn qua các trạng thái hợp lệ
    ${maDon}=    Tạo Đơn Mẫu
    Click Button    id:logoutButton
    Wait Until Location Contains    login.html
    Đăng Nhập Quản Trị Viên
    Click Button    id:tabOrders
    Wait Until Element Is Visible    css:button.status-btn[data-status="confirmed"]
    Click Button    css:button.status-btn[data-status="confirmed"]
    Wait Until Element Contains    id:adminOrderMessage    Đơn ${maDon}: Đã xác nhận.
    Click Button    css:button.status-btn[data-status="shipping"]
    Wait Until Element Contains    id:adminOrderMessage    Đơn ${maDon}: Đang giao.
    Click Button    css:button.status-btn[data-status="completed"]
    Wait Until Element Contains    id:adminOrderMessage    Đơn ${maDon}: Hoàn thành.

[ADMIN-ORDER-04] Thống kê ghi nhận đơn hoàn thành và doanh thu
    ${maDon}=    Tạo Đơn Mẫu
    Click Button    id:logoutButton
    Wait Until Location Contains    login.html
    Đăng Nhập Quản Trị Viên
    Click Button    id:tabOrders
    Wait Until Element Is Visible    css:button.status-btn[data-status="confirmed"]
    Click Button    css:button.status-btn[data-status="confirmed"]
    Click Button    css:button.status-btn[data-status="shipping"]
    Click Button    css:button.status-btn[data-status="completed"]
    Wait Until Element Contains    id:adminOrderMessage    Đơn ${maDon}: Hoàn thành.
    Click Button    id:tabStats
    Wait Until Element Contains    id:statTotalOrders    1
    Element Should Contain    id:statRevenue    70.000đ
    Element Should Contain    id:stat-completed    1

[ADMIN-ORDER-05] Bộ lọc chỉ hiển thị đơn thuộc trạng thái đã chọn
    ${maDon}=    Tạo Đơn Mẫu
    Click Button    id:logoutButton
    Wait Until Location Contains    login.html
    Đăng Nhập Quản Trị Viên
    Click Button    id:tabOrders
    Select From List By Value    id:orderStatusFilter    pending
    Wait Until Element Contains    id:adminOrderList    ${maDon}
    Select From List By Value    id:orderStatusFilter    cancelled
    Wait Until Element Is Visible    id:adminOrderEmpty

[ADMIN-ORDER-02] Nút thao tác đơn chỉ hiển thị theo trạng thái hiện tại
    ${maDon}=    Tạo Đơn Mẫu
    Click Button    id:logoutButton
    Wait Until Location Contains    login.html
    Đăng Nhập Quản Trị Viên
    Click Button    id:tabOrders
    Wait Until Element Is Visible    css:button.status-btn[data-status="confirmed"]
    Page Should Not Contain Element    css:button.status-btn[data-status="shipping"]
    Page Should Not Contain Element    css:button.status-btn[data-status="completed"]
    Click Button    css:button.status-btn[data-status="confirmed"]
    Wait Until Element Is Visible    css:button.status-btn[data-status="shipping"]
    Page Should Not Contain Element    css:button.status-btn[data-status="completed"]
    Click Button    css:button.status-btn[data-status="shipping"]
    Wait Until Element Is Visible    css:button.status-btn[data-status="completed"]
    Page Should Not Contain Element    css:button.status-btn[data-status="confirmed"]
    Should Not Be Empty    ${maDon}

[ADMIN-ORDER-03] Quản trị viên hủy đơn và hoàn tồn kho
    Đăng Nhập Khách Hàng
    Thêm Sản Phẩm Vào Giỏ    2    2
    Go To    ${DIA_CHI_WEB}/checkout.html
    Click Button    id:placeOrderButton
    Wait Until Element Is Visible    id:orderSuccess
    Click Button    id:logoutButton
    Đăng Nhập Quản Trị Viên
    Click Button    id:tabOrders
    Wait Until Element Is Visible    css:button.status-btn[data-status="cancelled"]
    Click Button    css:button.status-btn[data-status="cancelled"]
    Wait Until Element Contains    id:adminOrderMessage    Đã hủy
    Go To    ${DIA_CHI_WEB}/product.html?id=2
    Wait Until Element Contains    id:productStock    Còn 100 sản phẩm
