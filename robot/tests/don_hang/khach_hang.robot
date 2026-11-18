*** Settings ***
Resource          ../../resources/dung_chung.resource
Test Setup        Chuẩn Bị Ca Kiểm Thử
Test Teardown     Close Browser
Documentation     Kiểm thử lịch sử, chi tiết và hủy đơn của khách hàng.

*** Test Cases ***
[ORDER-CUSTOMER-01] Khách chưa có đơn nhìn thấy trạng thái trống
    Đăng Nhập Khách Hàng
    Go To    ${DIA_CHI_WEB}/orders.html
    Wait Until Element Is Visible    id:emptyOrders

[ORDER-CUSTOMER-02] Khách xem chi tiết và hủy đơn chờ xác nhận
    Đăng Nhập Khách Hàng
    Thêm Sản Phẩm Vào Giỏ    2    2
    Go To    ${DIA_CHI_WEB}/checkout.html
    Click Button    id:placeOrderButton
    Wait Until Element Is Visible    id:orderSuccess
    Click Element    id:viewOrdersLink
    Wait Until Element Is Visible    css:.view-order
    Click Button    css:.view-order
    Wait Until Element Is Visible    id:cancelOrderButton
    Element Should Contain    id:detailTotal    70.000đ
    Click Button    id:cancelOrderButton
    Wait Until Element Contains    id:successMessage    Đã hủy đơn hàng
    Element Should Contain    id:detailStatus    Đã hủy
