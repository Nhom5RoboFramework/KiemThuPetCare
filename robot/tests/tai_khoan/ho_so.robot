*** Settings ***
Resource          ../../resources/dung_chung.resource
Test Setup        Chuẩn Bị Ca Kiểm Thử
Test Teardown     Close Browser
Documentation     Kiểm thử thông tin hồ sơ khách hàng và các giới hạn dữ liệu.

*** Test Cases ***
Cập nhật hồ sơ với dữ liệu hợp lệ
    Đăng Nhập Khách Hàng
    Go To    ${DIA_CHI_WEB}/profile.html
    Wait Until Element Is Visible    id:saveProfileButton
    Input Text    id:fullname    Nguyen Van A Cap Nhat
    Input Text    id:phone    0907654321
    Input Text    id:address    88 Nguyen Trai, Ha Noi
    Click Button    id:saveProfileButton
    Wait Until Element Contains    id:profileMessage    Cập nhật hồ sơ thành công
    Element Should Contain    id:userName    Nguyen Van A Cap Nhat

Họ tên chấp nhận độ dài biên hai và năm mươi ký tự
    Đăng Nhập Khách Hàng
    Go To    ${DIA_CHI_WEB}/profile.html
    Wait Until Element Is Visible    id:saveProfileButton
    Input Text    id:fullname    An
    Input Text    id:phone    0901234567
    Clear Element Text    id:address
    Click Button    id:saveProfileButton
    Wait Until Element Contains    id:profileMessage    Cập nhật hồ sơ thành công
    ${tenDai}=    Evaluate    'A' * 50
    Input Text    id:fullname    ${tenDai}
    Click Button    id:saveProfileButton
    Wait Until Element Contains    id:profileMessage    Cập nhật hồ sơ thành công

Họ tên ngắn hơn hai hoặc dài hơn năm mươi ký tự bị từ chối
    Đăng Nhập Khách Hàng
    Go To    ${DIA_CHI_WEB}/profile.html
    Wait Until Element Is Visible    id:saveProfileButton
    ${tenDai}=    Evaluate    'A' * 51
    Clear Element Text    id:fullname
    Click Button    id:saveProfileButton
    Wait Until Element Contains    id:fullnameError    Vui lòng nhập họ tên
    FOR    ${ten}    IN    A    ${tenDai}
        Input Text    id:fullname    ${ten}
        Click Button    id:saveProfileButton
        Wait Until Element Contains    id:fullnameError    từ 2 đến 50 ký tự
    END

Số điện thoại bắt buộc đủ mười số và bắt đầu bằng số không
    Đăng Nhập Khách Hàng
    Go To    ${DIA_CHI_WEB}/profile.html
    Wait Until Element Is Visible    id:saveProfileButton
    ${danhSachSai}=    Create List    123456789    12345678901    1901234567    09abc56789
    FOR    ${soDienThoai}    IN    @{danhSachSai}
        Input Text    id:phone    ${soDienThoai}
        Click Button    id:saveProfileButton
        Wait Until Element Contains    id:phoneError    10 chữ số
    END
    Clear Element Text    id:phone
    Click Button    id:saveProfileButton
    Wait Until Element Contains    id:phoneError    Vui lòng nhập số điện thoại

Địa chỉ có thể để trống
    Đăng Nhập Khách Hàng
    Go To    ${DIA_CHI_WEB}/profile.html
    Wait Until Element Is Visible    id:saveProfileButton
    Clear Element Text    id:address
    Click Button    id:saveProfileButton
    Wait Until Element Contains    id:profileMessage    Cập nhật hồ sơ thành công

Địa chỉ có độ dài ngoài khoảng mười đến hai trăm ký tự bị từ chối
    Đăng Nhập Khách Hàng
    Go To    ${DIA_CHI_WEB}/profile.html
    Wait Until Element Is Visible    id:saveProfileButton
    ${diaChiNgan}=    Evaluate    'A' * 9
    ${diaChiDai}=    Evaluate    'A' * 201
    FOR    ${diaChi}    IN    ${diaChiNgan}    ${diaChiDai}
        Input Text    id:address    ${diaChi}
        Click Button    id:saveProfileButton
        Wait Until Element Contains    id:addressError    từ 10 đến 200 ký tự
    END
