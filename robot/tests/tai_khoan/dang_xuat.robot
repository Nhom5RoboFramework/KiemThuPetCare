*** Settings ***
Resource          ../../resources/dung_chung.resource
Test Setup        Chuẩn Bị Ca Kiểm Thử
Test Teardown     Close Browser
Documentation     Kiểm thử kết thúc phiên đăng nhập.

*** Test Cases ***
Đăng xuất kết thúc phiên đăng nhập
    Đăng Nhập Khách Hàng
    Click Button    id:logoutButton
    Wait Until Location Contains    login.html
    Wait Until Element Is Visible    id:loginButton
