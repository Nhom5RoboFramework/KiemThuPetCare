*** Settings ***
Resource          ../../resources/dung_chung.resource
Test Setup        Chuẩn Bị Ca Kiểm Thử
Test Teardown     Close Browser
Documentation     Kiểm thử kết thúc phiên đăng nhập.

*** Test Cases ***
[ACC-LOGOUT-01] Khách hàng đăng xuất và thanh điều hướng chuyển về trạng thái khách
    Đăng Nhập Khách Hàng
    Click Button    id:logoutButton
    Wait Until Location Contains    login.html
    Wait Until Element Is Visible    id:loginButton
    Page Should Contain Element    id:navLogin
    Page Should Contain Element    id:navRegister
    Page Should Not Contain Element    id:userName
    Page Should Not Contain Element    id:navOrders
    Page Should Not Contain Element    id:navProfile

[ACC-LOGOUT-02] Quản trị viên đăng xuất và không còn liên kết quản trị
    Đăng Nhập Quản Trị Viên
    Click Button    id:logoutButton
    Wait Until Location Contains    login.html
    Wait Until Element Is Visible    id:loginButton
    Page Should Contain Element    id:navLogin
    Page Should Not Contain Element    id:userName
    Page Should Not Contain Element    id:navAdmin

[ACC-LOGOUT-03] Sau khi đăng xuất không thể mở trang hồ sơ
    Đăng Nhập Khách Hàng
    Click Button    id:logoutButton
    Wait Until Location Contains    login.html
    Go To    ${DIA_CHI_WEB}/profile.html
    Wait Until Location Contains    login.html
    Wait Until Element Is Visible    id:loginButton

[ACC-LOGOUT-04] Khách chưa đăng nhập không thấy nút đăng xuất
    Page Should Not Contain Element    id:logoutButton
    Page Should Contain Element    id:navLogin
