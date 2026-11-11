*** Settings ***
Resource          ../../resources/dung_chung.resource
Test Setup        Chuẩn Bị Ca Kiểm Thử
Test Teardown     Close Browser
Documentation     Kiểm thử đăng ký tài khoản khách hàng.

*** Test Cases ***
Đăng ký tài khoản hợp lệ
    Go To    ${DIA_CHI_WEB}/register.html
    Input Text    id:fullname    Robot Framework User
    Input Text    id:email    robot.user@example.com
    Input Text    id:phone    0901234567
    Input Password    id:password    Robot123
    Input Password    id:confirmPassword    Robot123
    Click Button    id:registerButton
    Wait Until Element Contains    id:successMessage    Đăng ký thành công

Đăng ký báo lỗi các trường không hợp lệ
    Go To    ${DIA_CHI_WEB}/register.html
    Input Text    id:fullname    A
    Input Text    id:email    email-sai
    Input Text    id:phone    123
    Input Password    id:password    abc
    Input Password    id:confirmPassword    xyz
    Click Button    id:registerButton
    Wait Until Element Contains    id:fullnameError    từ 2 đến 50 ký tự
    Element Should Contain    id:emailError    không đúng định dạng
    Element Should Contain    id:phoneError    10 chữ số
    Element Should Contain    id:passwordError    ít nhất 8 ký tự
    Element Should Contain    id:confirmPasswordError    không khớp

Đăng ký bằng email đã tồn tại
    Go To    ${DIA_CHI_WEB}/register.html
    Input Text    id:fullname    Khach Trung Lap
    Input Text    id:email    khach@petcare.vn
    Input Text    id:phone    0901234567
    Input Password    id:password    Robot123
    Input Password    id:confirmPassword    Robot123
    Click Button    id:registerButton
    Wait Until Element Contains    id:emailError    Email đã tồn tại

Đăng ký từ chối khi bỏ trống tất cả trường
    Go To    ${DIA_CHI_WEB}/register.html
    Click Button    id:registerButton
    Wait Until Element Contains    id:fullnameError    Vui lòng nhập họ tên
    Element Should Contain    id:emailError    Vui lòng nhập email
    Element Should Contain    id:phoneError    Vui lòng nhập số điện thoại
    Element Should Contain    id:passwordError    Vui lòng nhập mật khẩu
    Element Should Contain    id:confirmPasswordError    Vui lòng xác nhận mật khẩu

Họ tên hai và năm mươi ký tự được chấp nhận
    Go To    ${DIA_CHI_WEB}/register.html
    Input Text    id:fullname    An
    Input Text    id:email    bien.duoi@example.com
    Input Text    id:phone    0901234567
    Input Password    id:password    Robot123
    Input Password    id:confirmPassword    Robot123
    Click Button    id:registerButton
    Wait Until Element Contains    id:successMessage    Đăng ký thành công
    Go To    ${DIA_CHI_WEB}/register.html
    ${tenDai}=    Evaluate    'A' * 50
    Input Text    id:fullname    ${tenDai}
    Input Text    id:email    bien.tren@example.com
    Input Text    id:phone    0901234568
    Input Password    id:password    Robot123
    Input Password    id:confirmPassword    Robot123
    Click Button    id:registerButton
    Wait Until Element Contains    id:successMessage    Đăng ký thành công

Họ tên dài hơn năm mươi ký tự bị từ chối
    Go To    ${DIA_CHI_WEB}/register.html
    ${tenDai}=    Evaluate    'A' * 51
    Input Text    id:fullname    ${tenDai}
    Input Text    id:email    fullname.dai@example.com
    Input Text    id:phone    0901234567
    Input Password    id:password    Robot123
    Input Password    id:confirmPassword    Robot123
    Click Button    id:registerButton
    Wait Until Element Contains    id:fullnameError    từ 2 đến 50 ký tự

Email thiếu hoặc sai cấu trúc bị từ chối
    Go To    ${DIA_CHI_WEB}/register.html
    Input Text    id:fullname    Email Test
    Input Text    id:phone    0901234567
    Input Password    id:password    Robot123
    Input Password    id:confirmPassword    Robot123
    FOR    ${emailSai}    IN    thieu-at.example.com    a@@example.com    a@domain    a b@example.com
        Input Text    id:email    ${emailSai}
        Click Button    id:registerButton
        Wait Until Element Contains    id:emailError    không đúng định dạng
    END

Email dài hơn một trăm ký tự bị từ chối
    Go To    ${DIA_CHI_WEB}/register.html
    ${emailDai}=    Evaluate    ('a' * 90) + '@example.com'
    Input Text    id:fullname    Email Dai
    Input Text    id:email    ${emailDai}
    Input Text    id:phone    0901234567
    Input Password    id:password    Robot123
    Input Password    id:confirmPassword    Robot123
    Click Button    id:registerButton
    Wait Until Element Contains    id:emailError    không đúng định dạng

Số điện thoại không đủ mười số hoặc sai tiền tố bị từ chối
    Go To    ${DIA_CHI_WEB}/register.html
    Input Text    id:fullname    Phone Test
    Input Text    id:email    phone.test@example.com
    Input Password    id:password    Robot123
    Input Password    id:confirmPassword    Robot123
    FOR    ${soSai}    IN    123456789    01234567890    1901234567    09abc56789
        Input Text    id:phone    ${soSai}
        Click Button    id:registerButton
        Wait Until Element Contains    id:phoneError    10 chữ số
    END

Mật khẩu ngắn hơn tám ký tự hoặc thiếu chữ hay số bị từ chối
    Go To    ${DIA_CHI_WEB}/register.html
    Input Text    id:fullname    Password Test
    Input Text    id:email    password.test@example.com
    Input Text    id:phone    0901234567
    FOR    ${matKhauSai}    IN    Abc1234    12345678    Abcdefgh
        Input Password    id:password    ${matKhauSai}
        Input Password    id:confirmPassword    ${matKhauSai}
        Click Button    id:registerButton
        Wait Until Element Contains    id:passwordError    ít nhất 8 ký tự
    END

Xác nhận mật khẩu bắt buộc phải trùng khớp
    Go To    ${DIA_CHI_WEB}/register.html
    Input Text    id:fullname    Confirm Test
    Input Text    id:email    confirm.test@example.com
    Input Text    id:phone    0901234567
    Input Password    id:password    Robot123
    Click Button    id:registerButton
    Wait Until Element Contains    id:confirmPasswordError    Vui lòng xác nhận mật khẩu
    Input Password    id:confirmPassword    Khac1234
    Click Button    id:registerButton
    Wait Until Element Contains    id:confirmPasswordError    không khớp

Email trùng không phân biệt chữ hoa chữ thường
    Go To    ${DIA_CHI_WEB}/register.html
    Input Text    id:fullname    Trung Email
    Input Text    id:email    KHACH@PETCARE.VN
    Input Text    id:phone    0901234567
    Input Password    id:password    Robot123
    Input Password    id:confirmPassword    Robot123
    Click Button    id:registerButton
    Wait Until Element Contains    id:emailError    Email đã tồn tại
