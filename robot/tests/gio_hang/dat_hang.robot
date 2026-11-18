*** Settings ***
Resource          ../../resources/dung_chung.resource
Test Setup        Chuẩn Bị Ca Kiểm Thử
Test Teardown     Close Browser
Documentation     Kiểm thử kiểm tra giỏ và tạo đơn hàng.

*** Test Cases ***
[CHECKOUT-01] Trang đặt hàng báo giỏ trống
    Đăng Nhập Khách Hàng
    Go To    ${DIA_CHI_WEB}/checkout.html
    Wait Until Element Is Visible    id:emptyCart

[CHECKOUT-02] Đặt hàng thành công bằng chuyển khoản
    Đăng Nhập Khách Hàng
    Thêm Sản Phẩm Vào Giỏ    2    2
    Go To    ${DIA_CHI_WEB}/checkout.html
    Wait Until Element Is Visible    id:placeOrderButton
    Select Radio Button    paymentMethod    bank
    Click Button    id:placeOrderButton
    Wait Until Element Is Visible    id:orderSuccess
    Element Should Contain    id:orderCode    PC000001
    Element Should Contain    id:orderTotalDone    70.000đ

[CHECKOUT-03] Đặt hàng thành công bằng tiền mặt khi nhận hàng và cập nhật kho
    Đăng Nhập Khách Hàng
    Thêm Sản Phẩm Vào Giỏ    2    2
    Go To    ${DIA_CHI_WEB}/checkout.html
    Wait Until Element Is Visible    id:placeOrderButton
    Select Radio Button    paymentMethod    cod
    Click Button    id:placeOrderButton
    Wait Until Element Is Visible    id:orderSuccess
    Element Should Contain    id:orderCode    PC000001
    Go To    ${DIA_CHI_WEB}/product.html?id=2
    Wait Until Element Contains    id:productStock    Còn 98 sản phẩm
    Go To    ${DIA_CHI_WEB}/cart.html
    Wait Until Element Is Visible    id:emptyCart

[CHECKOUT-04] Đặt hàng từ chối tên người nhận ngắn hơn hai ký tự
    Đăng Nhập Khách Hàng
    Thêm Sản Phẩm Vào Giỏ    2    1
    Go To    ${DIA_CHI_WEB}/checkout.html
    Wait Until Element Is Visible    id:placeOrderButton
    Input Text    id:receiver    A
    Click Button    id:placeOrderButton
    Wait Until Element Contains    id:receiverError    từ 2 đến 50 ký tự

[CHECKOUT-05] Đặt hàng từ chối số điện thoại sai định dạng
    Đăng Nhập Khách Hàng
    Thêm Sản Phẩm Vào Giỏ    2    1
    Go To    ${DIA_CHI_WEB}/checkout.html
    Wait Until Element Is Visible    id:placeOrderButton
    Input Text    id:phone    123
    Click Button    id:placeOrderButton
    Element Should Contain    id:phoneError    10 chữ số

[CHECKOUT-06] Đặt hàng từ chối địa chỉ ngắn hơn mười ký tự
    Đăng Nhập Khách Hàng
    Thêm Sản Phẩm Vào Giỏ    2    1
    Go To    ${DIA_CHI_WEB}/checkout.html
    Wait Until Element Is Visible    id:placeOrderButton
    Input Text    id:address    Ngan
    Click Button    id:placeOrderButton
    Element Should Contain    id:addressError    từ 10 đến 200 ký tự

[CHECKOUT-07] Đặt hàng từ chối khi thiếu tên người nhận
    Đăng Nhập Khách Hàng
    Thêm Sản Phẩm Vào Giỏ    2    1
    Go To    ${DIA_CHI_WEB}/checkout.html
    Wait Until Element Is Visible    id:placeOrderButton
    Clear Element Text    id:receiver
    Click Button    id:placeOrderButton
    Wait Until Element Contains    id:receiverError    Vui lòng nhập tên người nhận

[CHECKOUT-08] Đặt hàng từ chối khi thiếu số điện thoại
    Đăng Nhập Khách Hàng
    Thêm Sản Phẩm Vào Giỏ    2    1
    Go To    ${DIA_CHI_WEB}/checkout.html
    Wait Until Element Is Visible    id:placeOrderButton
    Clear Element Text    id:phone
    Click Button    id:placeOrderButton
    Element Should Contain    id:phoneError    Vui lòng nhập số điện thoại

[CHECKOUT-09] Đặt hàng từ chối khi thiếu địa chỉ
    Đăng Nhập Khách Hàng
    Thêm Sản Phẩm Vào Giỏ    2    1
    Go To    ${DIA_CHI_WEB}/checkout.html
    Wait Until Element Is Visible    id:placeOrderButton
    Clear Element Text    id:address
    Click Button    id:placeOrderButton
    Element Should Contain    id:addressError    Vui lòng nhập địa chỉ
