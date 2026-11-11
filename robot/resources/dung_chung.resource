*** Settings ***
Library    SeleniumLibrary
Library    RequestsLibrary

*** Variables ***
${DIA_CHI_WEB}    http://localhost:3101
${TRINH_DUYET}    chrome

*** Keywords ***
Đặt Lại Dữ Liệu Kiểm Thử
    Create Session    petcare    ${DIA_CHI_WEB}
    ${response}=    POST On Session    petcare    /api/test/reset
    Should Be Equal As Integers    ${response.status_code}    200
    Delete All Sessions

Mở Trang PetCare
    [Arguments]    ${trang}=index.html
    Open Browser    ${DIA_CHI_WEB}/${trang}    ${TRINH_DUYET}
    Set Window Size    1440    1000

Chuẩn Bị Ca Kiểm Thử
    Đặt Lại Dữ Liệu Kiểm Thử
    Mở Trang PetCare

Đăng Nhập Khách Hàng
    Go To    ${DIA_CHI_WEB}/login.html
    Wait Until Element Is Visible    id:email
    Input Text    id:email    khach@petcare.vn
    Input Password    id:password    Khach123
    Click Button    id:loginButton
    Wait Until Location Contains    index.html

Đăng Nhập Quản Trị Viên
    Go To    ${DIA_CHI_WEB}/login.html
    Wait Until Element Is Visible    id:email
    Input Text    id:email    admin@petcare.vn
    Input Password    id:password    Admin123
    Click Button    id:loginButton
    Wait Until Location Contains    admin.html
    Wait Until Element Is Visible    id:tabProducts

Thêm Sản Phẩm Vào Giỏ
    [Arguments]    ${maSanPham}    ${soLuong}=1
    Go To    ${DIA_CHI_WEB}/product.html?id=${maSanPham}
    Wait Until Element Is Visible    id:productName
    Input Text    id:quantity    ${soLuong}
    Click Button    id:addToCartButton
    Wait Until Element Contains    id:successMessage    Đã thêm vào giỏ hàng

Tạo Đơn Mẫu
    Đăng Nhập Khách Hàng
    Thêm Sản Phẩm Vào Giỏ    2    2
    Go To    ${DIA_CHI_WEB}/checkout.html
    Wait Until Element Is Visible    id:placeOrderButton
    Click Button    id:placeOrderButton
    Wait Until Element Is Visible    id:orderSuccess
    ${maDon}=    Get Text    id:orderCode
    RETURN    ${maDon}
