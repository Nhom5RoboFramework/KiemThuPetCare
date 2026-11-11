*** Settings ***
Resource          ../../resources/dung_chung.resource
Test Setup        Chuẩn Bị Ca Kiểm Thử
Test Teardown     Close Browser
Documentation     Kiểm thử quy tắc đổi mật khẩu khách hàng.

*** Test Cases ***
Đổi mật khẩu thành công và đăng nhập lại bằng mật khẩu mới
    Đăng Nhập Khách Hàng
    Go To    ${DIA_CHI_WEB}/profile.html
    Wait Until Element Is Visible    id:changePasswordButton
    Input Password    id:currentPassword    Khach123
    Input Password    id:newPassword    Moi12345
    Click Button    id:changePasswordButton
    Wait Until Element Contains    id:passwordMessage    Đổi mật khẩu thành công
    Click Button    id:logoutButton
    Wait Until Location Contains    login.html
    Input Text    id:email    khach@petcare.vn
    Input Password    id:password    Moi12345
    Click Button    id:loginButton
    Wait Until Location Contains    index.html
    Wait Until Element Is Visible    id:userName

Đổi mật khẩu từ chối mật khẩu hiện tại sai
    Đăng Nhập Khách Hàng
    Go To    ${DIA_CHI_WEB}/profile.html
    Wait Until Element Is Visible    id:changePasswordButton
    Input Password    id:currentPassword    Wrong123
    Input Password    id:newPassword    Moi12345
    Click Button    id:changePasswordButton
    Wait Until Element Contains    id:currentPasswordError    không đúng

Mật khẩu mới phải đủ tám ký tự và có cả chữ lẫn số
    Đăng Nhập Khách Hàng
    Go To    ${DIA_CHI_WEB}/profile.html
    Wait Until Element Is Visible    id:changePasswordButton
    Input Password    id:currentPassword    Khach123
    Input Password    id:newPassword    abc123
    Click Button    id:changePasswordButton
    Wait Until Element Contains    id:newPasswordError    ít nhất 8 ký tự
    Input Password    id:newPassword    12345678
    Click Button    id:changePasswordButton
    Wait Until Element Contains    id:newPasswordError    ít nhất 8 ký tự

Mật khẩu mới phải khác mật khẩu hiện tại
    Đăng Nhập Khách Hàng
    Go To    ${DIA_CHI_WEB}/profile.html
    Wait Until Element Is Visible    id:changePasswordButton
    Input Password    id:currentPassword    Khach123
    Input Password    id:newPassword    Khach123
    Click Button    id:changePasswordButton
    Wait Until Element Contains    id:newPasswordError    phải khác mật khẩu cũ

Mật khẩu hiện tại và mật khẩu mới là bắt buộc
    Đăng Nhập Khách Hàng
    Go To    ${DIA_CHI_WEB}/profile.html
    Wait Until Element Is Visible    id:changePasswordButton
    Click Button    id:changePasswordButton
    Wait Until Element Contains    id:currentPasswordError    Vui lòng nhập mật khẩu hiện tại
    Element Should Contain    id:newPasswordError    Vui lòng nhập mật khẩu
    Input Password    id:currentPassword    Khach123
    Click Button    id:changePasswordButton
    Wait Until Element Contains    id:newPasswordError    Vui lòng nhập mật khẩu
    Clear Element Text    id:currentPassword
    Input Password    id:newPassword    Moi12345
    Click Button    id:changePasswordButton
    Wait Until Element Contains    id:currentPasswordError    Vui lòng nhập mật khẩu hiện tại
