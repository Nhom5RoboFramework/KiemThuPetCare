*** Settings ***
Resource          ../../resources/dung_chung.resource
Test Setup        Chuẩn Bị Ca Kiểm Thử
Test Teardown     Close Browser
Documentation     Kiểm thử đăng ký tài khoản khách hàng.

*** Test Cases ***
[ACC-REG-01] Đăng ký tài khoản hợp lệ
    Go To    ${DIA_CHI_WEB}/register.html
    Input Text    id:fullname    Robot Framework User
    Input Text    id:email    robot.user@example.com
    Input Text    id:phone    0901234567
    Input Password    id:password    Robot123
    Input Password    id:confirmPassword    Robot123
    Click Button    id:registerButton
    Wait Until Element Contains    id:successMessage    Đăng ký thành công

[ACC-REG-02] Đăng ký từ chối họ tên, email, số điện thoại và mật khẩu sai quy tắc
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

[ACC-REG-03] Đăng ký bằng email đã tồn tại
    Go To    ${DIA_CHI_WEB}/register.html
    Input Text    id:fullname    Khach Trung Lap
    Input Text    id:email    khach@petcare.vn
    Input Text    id:phone    0901234567
    Input Password    id:password    Robot123
    Input Password    id:confirmPassword    Robot123
    Click Button    id:registerButton
    Wait Until Element Contains    id:emailError    Email đã tồn tại

[ACC-REG-04] Đăng ký từ chối khi bỏ trống tất cả trường
    Go To    ${DIA_CHI_WEB}/register.html
    Click Button    id:registerButton
    Wait Until Element Contains    id:fullnameError    Vui lòng nhập họ tên
    Element Should Contain    id:emailError    Vui lòng nhập email
    Element Should Contain    id:phoneError    Vui lòng nhập số điện thoại
    Element Should Contain    id:passwordError    Vui lòng nhập mật khẩu
    Element Should Contain    id:confirmPasswordError    Vui lòng xác nhận mật khẩu

[ACC-REG-05] Họ tên có hai ký tự được chấp nhận
    Go To    ${DIA_CHI_WEB}/register.html
    Input Text    id:fullname    An
    Input Text    id:email    bien.duoi@example.com
    Input Text    id:phone    0901234567
    Input Password    id:password    Robot123
    Input Password    id:confirmPassword    Robot123
    Click Button    id:registerButton
    Wait Until Element Contains    id:successMessage    Đăng ký thành công

[ACC-REG-16] Họ tên có năm mươi ký tự được chấp nhận
    Go To    ${DIA_CHI_WEB}/register.html
    ${tenDai}=    Evaluate    'A' * 50
    Input Text    id:fullname    ${tenDai}
    Input Text    id:email    bien.tren@example.com
    Input Text    id:phone    0901234568
    Input Password    id:password    Robot123
    Input Password    id:confirmPassword    Robot123
    Click Button    id:registerButton
    Wait Until Element Contains    id:successMessage    Đăng ký thành công

[ACC-REG-06] Họ tên dài hơn năm mươi ký tự bị từ chối
    Go To    ${DIA_CHI_WEB}/register.html
    ${tenDai}=    Evaluate    'A' * 51
    Input Text    id:fullname    ${tenDai}
    Input Text    id:email    fullname.dai@example.com
    Input Text    id:phone    0901234567
    Input Password    id:password    Robot123
    Input Password    id:confirmPassword    Robot123
    Click Button    id:registerButton
    Wait Until Element Contains    id:fullnameError    từ 2 đến 50 ký tự

[ACC-REG-07] Email thiếu ký tự @ bị từ chối
    Go To    ${DIA_CHI_WEB}/register.html
    Input Text    id:fullname    Email Test
    Input Text    id:phone    0901234567
    Input Password    id:password    Robot123
    Input Password    id:confirmPassword    Robot123
    Input Text    id:email    thieu-at.example.com
    Click Button    id:registerButton
    Wait Until Element Contains    id:emailError    không đúng định dạng

[ACC-REG-17] Email có hai ký tự @ bị từ chối
    Go To    ${DIA_CHI_WEB}/register.html
    Input Text    id:fullname    Email Test
    Input Text    id:email    a@@example.com
    Input Text    id:phone    0901234567
    Input Password    id:password    Robot123
    Input Password    id:confirmPassword    Robot123
    Click Button    id:registerButton
    Wait Until Element Contains    id:emailError    không đúng định dạng

[ACC-REG-18] Email thiếu phần tên miền cấp cao bị từ chối
    Go To    ${DIA_CHI_WEB}/register.html
    Input Text    id:fullname    Email Test
    Input Text    id:email    a@domain
    Input Text    id:phone    0901234567
    Input Password    id:password    Robot123
    Input Password    id:confirmPassword    Robot123
    Click Button    id:registerButton
    Wait Until Element Contains    id:emailError    không đúng định dạng

[ACC-REG-19] Email chứa khoảng trắng bị từ chối
    Go To    ${DIA_CHI_WEB}/register.html
    Input Text    id:fullname    Email Test
    Input Text    id:email    a b@example.com
    Input Text    id:phone    0901234567
    Input Password    id:password    Robot123
    Input Password    id:confirmPassword    Robot123
    Click Button    id:registerButton
    Wait Until Element Contains    id:emailError    không đúng định dạng

[ACC-REG-08] Email dài hơn một trăm ký tự bị từ chối
    Go To    ${DIA_CHI_WEB}/register.html
    ${emailDai}=    Evaluate    ('a' * 90) + '@example.com'
    Input Text    id:fullname    Email Dai
    Input Text    id:email    ${emailDai}
    Input Text    id:phone    0901234567
    Input Password    id:password    Robot123
    Input Password    id:confirmPassword    Robot123
    Click Button    id:registerButton
    Wait Until Element Contains    id:emailError    không đúng định dạng

[ACC-REG-09] Số điện thoại có chín chữ số bị từ chối
    Go To    ${DIA_CHI_WEB}/register.html
    Input Text    id:fullname    Phone Test
    Input Text    id:email    phone.test@example.com
    Input Password    id:password    Robot123
    Input Password    id:confirmPassword    Robot123
    Input Text    id:phone    123456789
    Click Button    id:registerButton
    Wait Until Element Contains    id:phoneError    10 chữ số

[ACC-REG-20] Số điện thoại có mười một chữ số bị từ chối
    Go To    ${DIA_CHI_WEB}/register.html
    Input Text    id:fullname    Phone Test
    Input Text    id:email    phone.test@example.com
    Input Text    id:phone    01234567890
    Input Password    id:password    Robot123
    Input Password    id:confirmPassword    Robot123
    Click Button    id:registerButton
    Wait Until Element Contains    id:phoneError    10 chữ số

[ACC-REG-21] Số điện thoại sai tiền tố bị từ chối
    Go To    ${DIA_CHI_WEB}/register.html
    Input Text    id:fullname    Phone Test
    Input Text    id:email    phone.test@example.com
    Input Text    id:phone    1901234567
    Input Password    id:password    Robot123
    Input Password    id:confirmPassword    Robot123
    Click Button    id:registerButton
    Wait Until Element Contains    id:phoneError    bắt đầu bằng 0

[ACC-REG-22] Số điện thoại chứa chữ bị từ chối
    Go To    ${DIA_CHI_WEB}/register.html
    Input Text    id:fullname    Phone Test
    Input Text    id:email    phone.test@example.com
    Input Text    id:phone    09abc56789
    Input Password    id:password    Robot123
    Input Password    id:confirmPassword    Robot123
    Click Button    id:registerButton
    Wait Until Element Contains    id:phoneError    10 chữ số

[ACC-REG-10] Mật khẩu ngắn hơn tám ký tự bị từ chối
    Go To    ${DIA_CHI_WEB}/register.html
    Input Text    id:fullname    Password Test
    Input Text    id:email    password.test@example.com
    Input Text    id:phone    0901234567
    Input Password    id:password    Abc1234
    Input Password    id:confirmPassword    Abc1234
    Click Button    id:registerButton
    Wait Until Element Contains    id:passwordError    ít nhất 8 ký tự

[ACC-REG-23] Mật khẩu chỉ có chữ số bị từ chối
    Go To    ${DIA_CHI_WEB}/register.html
    Input Text    id:fullname    Password Test
    Input Text    id:email    password.test@example.com
    Input Text    id:phone    0901234567
    Input Password    id:password    12345678
    Input Password    id:confirmPassword    12345678
    Click Button    id:registerButton
    Wait Until Element Contains    id:passwordError    gồm cả chữ và số

[ACC-REG-24] Mật khẩu chỉ có chữ bị từ chối
    Go To    ${DIA_CHI_WEB}/register.html
    Input Text    id:fullname    Password Test
    Input Text    id:email    password.test@example.com
    Input Text    id:phone    0901234567
    Input Password    id:password    Abcdefgh
    Input Password    id:confirmPassword    Abcdefgh
    Click Button    id:registerButton
    Wait Until Element Contains    id:passwordError    gồm cả chữ và số

[ACC-REG-11] Xác nhận mật khẩu bắt buộc phải trùng khớp
    Go To    ${DIA_CHI_WEB}/register.html
    Input Text    id:fullname    Confirm Test
    Input Text    id:email    confirm.test@example.com
    Input Text    id:phone    0901234567
    Input Password    id:password    Robot123
    Click Button    id:registerButton
    Wait Until Element Contains    id:confirmPasswordError    Vui lòng xác nhận mật khẩu

[ACC-REG-25] Mật khẩu xác nhận không khớp bị từ chối
    Go To    ${DIA_CHI_WEB}/register.html
    Input Text    id:fullname    Confirm Test
    Input Text    id:email    confirm.test@example.com
    Input Text    id:phone    0901234567
    Input Password    id:password    Robot123
    Input Password    id:confirmPassword    Khac1234
    Click Button    id:registerButton
    Wait Until Element Contains    id:confirmPasswordError    không khớp

[ACC-REG-12] Email trùng không phân biệt chữ hoa chữ thường
    Go To    ${DIA_CHI_WEB}/register.html
    Input Text    id:fullname    Trung Email
    Input Text    id:email    KHACH@PETCARE.VN
    Input Text    id:phone    0901234567
    Input Password    id:password    Robot123
    Input Password    id:confirmPassword    Robot123
    Click Button    id:registerButton
    Wait Until Element Contains    id:emailError    Email đã tồn tại

[ACC-REG-13] Tài khoản chưa xác minh email không thể đăng nhập
    Go To    ${DIA_CHI_WEB}/register.html
    Input Text    id:fullname    Chua Xac Minh
    Input Text    id:email    chua.xac.minh@example.com
    Input Text    id:phone    0901234567
    Input Password    id:password    Robot123
    Input Password    id:confirmPassword    Robot123
    Click Button    id:registerButton
    Wait Until Element Contains    id:successMessage    xác minh email
    Go To    ${DIA_CHI_WEB}/login.html
    Input Text    id:email    chua.xac.minh@example.com
    Input Password    id:password    Robot123
    Click Button    id:loginButton
    Wait Until Element Contains    id:loginError    Email chưa được xác minh
    Wait Until Element Is Visible    id:resendVerificationButton

[ACC-REG-14] Xác minh email qua liên kết cho phép đăng nhập
    Go To    ${DIA_CHI_WEB}/register.html
    Input Text    id:fullname    Da Xac Minh
    Input Text    id:email    da.xac.minh@example.com
    Input Text    id:phone    0901234567
    Input Password    id:password    Robot123
    Input Password    id:confirmPassword    Robot123
    Click Button    id:registerButton
    Wait Until Element Contains    id:successMessage    xác minh email
    Create Session    hopThuTest    ${DIA_CHI_WEB}
    ${response}=    GET On Session    hopThuTest    url=/api/test/verification-link?email=da.xac.minh@example.com
    ${link}=    Evaluate    $response.json()['url']
    Should Not Be Empty    ${link}
    Go To    ${link}
    Wait Until Element Contains    id:verifySuccess    Xác minh email thành công
    Go To    ${DIA_CHI_WEB}/login.html
    Input Text    id:email    da.xac.minh@example.com
    Input Password    id:password    Robot123
    Click Button    id:loginButton
    Wait Until Location Contains    index.html

[ACC-REG-15] Liên kết xác minh chỉ sử dụng được một lần
    Go To    ${DIA_CHI_WEB}/register.html
    Input Text    id:fullname    Dung Lien Ket
    Input Text    id:email    dung.lien.ket@example.com
    Input Text    id:phone    0901234567
    Input Password    id:password    Robot123
    Input Password    id:confirmPassword    Robot123
    Click Button    id:registerButton
    Wait Until Element Contains    id:successMessage    xác minh email
    Create Session    hopThuTest    ${DIA_CHI_WEB}
    ${response}=    GET On Session    hopThuTest    url=/api/test/verification-link?email=dung.lien.ket@example.com
    ${link}=    Evaluate    $response.json()['url']
    Go To    ${link}
    Wait Until Element Contains    id:verifySuccess    Xác minh email thành công
    Go To    ${link}
    Wait Until Element Contains    id:verifyError    không hợp lệ hoặc đã hết hạn
