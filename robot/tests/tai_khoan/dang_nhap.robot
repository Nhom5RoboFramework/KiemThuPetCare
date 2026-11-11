*** Settings ***
Resource          ../../resources/dung_chung.resource
Test Setup        Chuẩn Bị Ca Kiểm Thử
Test Teardown     Close Browser
Documentation     Kiểm thử đăng nhập, khóa tài khoản và phân quyền.

*** Test Cases ***
Đăng nhập khách thành công
    Go To    ${DIA_CHI_WEB}/login.html
    Input Text    id:email    khach@petcare.vn
    Input Password    id:password    Khach123
    Click Button    id:loginButton
    Wait Until Location Contains    index.html
    Wait Until Element Is Visible    id:userName
    Element Should Contain    id:userName    Nguyễn Văn A

Đăng nhập với mật khẩu sai
    Go To    ${DIA_CHI_WEB}/login.html
    Input Text    id:email    khach@petcare.vn
    Input Password    id:password    Sai12345
    Click Button    id:loginButton
    Wait Until Element Contains    id:loginError    Email hoặc mật khẩu không chính xác

Đăng nhập từ chối khi thiếu email hoặc mật khẩu
    Go To    ${DIA_CHI_WEB}/login.html
    Click Button    id:loginButton
    Wait Until Element Contains    id:emailError    Vui lòng nhập email
    Element Should Contain    id:passwordError    Vui lòng nhập mật khẩu
    Input Text    id:email    khach@petcare.vn
    Click Button    id:loginButton
    Wait Until Element Contains    id:passwordError    Vui lòng nhập mật khẩu
    Clear Element Text    id:email
    Input Password    id:password    Khach123
    Click Button    id:loginButton
    Wait Until Element Contains    id:emailError    Vui lòng nhập email

Email chưa đăng ký bị từ chối
    Go To    ${DIA_CHI_WEB}/login.html
    Input Text    id:email    chua.dang.ky@example.com
    Input Password    id:password    Robot123
    Click Button    id:loginButton
    Wait Until Element Contains    id:loginError    Email hoặc mật khẩu không chính xác

Email đăng nhập không phân biệt chữ hoa chữ thường
    Go To    ${DIA_CHI_WEB}/login.html
    Input Text    id:email    KHACH@PETCARE.VN
    Input Password    id:password    Khach123
    Click Button    id:loginButton
    Wait Until Location Contains    index.html
    Wait Until Element Is Visible    id:userName

Đăng nhập đúng sẽ xóa số lần nhập sai trước đó
    Go To    ${DIA_CHI_WEB}/login.html
    Input Text    id:email    khach@petcare.vn
    Input Password    id:password    Sai12345
    Click Button    id:loginButton
    Wait Until Element Contains    id:loginError    Email hoặc mật khẩu không chính xác
    Input Password    id:password    Khach123
    Click Button    id:loginButton
    Wait Until Location Contains    index.html
    Click Button    id:logoutButton
    Wait Until Location Contains    login.html
    Input Text    id:email    khach@petcare.vn
    FOR    ${lanThu}    IN RANGE    4
        Input Password    id:password    Sai12345
        Click Button    id:loginButton
        Wait Until Element Contains    id:loginError    Email hoặc mật khẩu không chính xác
    END
    Input Password    id:password    Khach123
    Click Button    id:loginButton
    Wait Until Location Contains    index.html

Khóa đăng nhập sau năm lần nhập sai liên tiếp
    Go To    ${DIA_CHI_WEB}/login.html
    Input Text    id:email    khach@petcare.vn
    FOR    ${lanThu}    IN RANGE    4
        Input Password    id:password    Sai12345
        Click Button    id:loginButton
        Wait Until Element Contains    id:loginError    Email hoặc mật khẩu không chính xác
    END
    Input Password    id:password    Sai12345
    Click Button    id:loginButton
    Wait Until Element Contains    id:loginError    Tài khoản tạm khóa
    Input Password    id:password    Khach123
    Click Button    id:loginButton
    Wait Until Element Contains    id:loginError    Tài khoản tạm khóa

Tài khoản được mở đăng nhập lại sau khi hết thời gian khóa
    Go To    ${DIA_CHI_WEB}/login.html
    Input Text    id:email    khach@petcare.vn
    FOR    ${lanThu}    IN RANGE    5
        Input Password    id:password    Sai12345
        Click Button    id:loginButton
        IF    ${lanThu} < 4
            Wait Until Element Contains    id:loginError    Email hoặc mật khẩu không chính xác
        ELSE
            Wait Until Element Contains    id:loginError    Tài khoản tạm khóa
        END
    END
    Sleep    2 seconds
    Input Password    id:password    Khach123
    Click Button    id:loginButton
    Wait Until Location Contains    index.html
    Wait Until Element Is Visible    id:userName

Tài khoản bị quản trị viên khóa không đăng nhập được
    Go To    ${DIA_CHI_WEB}/login.html
    Input Text    id:email    khoa@petcare.vn
    Input Password    id:password    Khoa1234
    Click Button    id:loginButton
    Wait Until Element Contains    id:loginError    Tài khoản đã bị khóa

Khách không được truy cập trang quản trị
    Đăng Nhập Khách Hàng
    Go To    ${DIA_CHI_WEB}/admin.html
    Wait Until Element Is Visible    id:forbidden
    Element Should Not Be Visible    id:adminContent
