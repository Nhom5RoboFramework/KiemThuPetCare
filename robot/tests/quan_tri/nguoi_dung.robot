*** Settings ***
Resource          ../../resources/dung_chung.resource
Test Setup        Chuẩn Bị Ca Kiểm Thử
Test Teardown     Close Browser
Documentation     Kiểm thử khóa, mở khóa người dùng và bảo vệ tài khoản quản trị.

*** Test Cases ***
[ADMIN-USER-01] Quản trị viên khóa và mở lại tài khoản khách
    Đăng Nhập Quản Trị Viên
    Click Button    id:tabUsers
    ${nguoiDungBiKhoa}=    Set Variable    xpath://tr[.//td[contains(.,'khoa@petcare.vn')]]
    Wait Until Element Is Visible    ${nguoiDungBiKhoa}
    Click Button    ${nguoiDungBiKhoa}//button[contains(@class,'toggle-lock')]
    Wait Until Element Contains    id:userMessage    Đã mở khóa tài khoản
    Click Button    ${nguoiDungBiKhoa}//button[contains(@class,'toggle-lock')]
    Wait Until Element Contains    id:userMessage    Đã khóa tài khoản
    Click Button    id:logoutButton
    Go To    ${DIA_CHI_WEB}/login.html
    Input Text    id:email    khoa@petcare.vn
    Input Password    id:password    Khoa1234
    Click Button    id:loginButton
    Wait Until Element Contains    id:loginError    Tài khoản đã bị khóa

[ADMIN-USER-02] Quản trị viên không thể tự khóa tài khoản
    Đăng Nhập Quản Trị Viên
    Click Button    id:tabUsers
    ${dongQuanTri}=    Set Variable    xpath://tr[.//td[contains(.,'admin@petcare.vn')]]
    Wait Until Element Is Visible    ${dongQuanTri}
    Page Should Not Contain Element    ${dongQuanTri}//button[contains(@class,'toggle-lock')]

[ADMIN-USER-03] Khóa tài khoản khách đang hoạt động sẽ chặn lần đăng nhập tiếp theo
    Đăng Nhập Quản Trị Viên
    Click Button    id:tabUsers
    ${dongKhach}=    Set Variable    xpath://tr[.//td[contains(.,'khach@petcare.vn')]]
    Wait Until Element Is Visible    ${dongKhach}
    Click Button    ${dongKhach}//button[contains(@class,'toggle-lock')]
    Wait Until Element Contains    id:userMessage    Đã khóa tài khoản
    Click Button    id:logoutButton
    Go To    ${DIA_CHI_WEB}/login.html
    Input Text    id:email    khach@petcare.vn
    Input Password    id:password    Khach123
    Click Button    id:loginButton
    Wait Until Element Contains    id:loginError    Tài khoản đã bị khóa
