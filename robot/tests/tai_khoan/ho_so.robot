*** Settings ***
Resource          ../../resources/dung_chung.resource
Test Setup        Chuẩn Bị Ca Kiểm Thử
Test Teardown     Close Browser
Documentation     Kiểm thử thông tin hồ sơ khách hàng và các giới hạn dữ liệu.

*** Test Cases ***
[ACC-PROFILE-01] Cập nhật hồ sơ với dữ liệu hợp lệ
    Đăng Nhập Khách Hàng
    Go To    ${DIA_CHI_WEB}/profile.html
    Wait Until Element Is Visible    id:saveProfileButton
    Input Text    id:fullname    Nguyen Van A Cap Nhat
    Input Text    id:phone    0907654321
    Input Text    id:address    88 Nguyen Trai, Ha Noi
    Click Button    id:saveProfileButton
    Wait Until Element Contains    id:profileMessage    Cập nhật hồ sơ thành công
    Element Should Contain    id:userName    Nguyen Van A Cap Nhat

[ACC-PROFILE-02] Họ tên có hai ký tự được chấp nhận
    Đăng Nhập Khách Hàng
    Go To    ${DIA_CHI_WEB}/profile.html
    Wait Until Element Is Visible    id:saveProfileButton
    Input Text    id:fullname    An
    Input Text    id:phone    0901234567
    Clear Element Text    id:address
    Click Button    id:saveProfileButton
    Wait Until Element Contains    id:profileMessage    Cập nhật hồ sơ thành công

[ACC-PROFILE-07] Họ tên có năm mươi ký tự được chấp nhận
    Đăng Nhập Khách Hàng
    Go To    ${DIA_CHI_WEB}/profile.html
    Wait Until Element Is Visible    id:saveProfileButton
    ${tenDai}=    Evaluate    'A' * 50
    Input Text    id:fullname    ${tenDai}
    Click Button    id:saveProfileButton
    Wait Until Element Contains    id:profileMessage    Cập nhật hồ sơ thành công

[ACC-PROFILE-03] Họ tên một ký tự bị từ chối
    Đăng Nhập Khách Hàng
    Go To    ${DIA_CHI_WEB}/profile.html
    Wait Until Element Is Visible    id:saveProfileButton
    Input Text    id:fullname    A
    Click Button    id:saveProfileButton
    Wait Until Element Contains    id:fullnameError    từ 2 đến 50 ký tự

[ACC-PROFILE-14] Họ tên dài năm mươi mốt ký tự bị từ chối
    Đăng Nhập Khách Hàng
    Go To    ${DIA_CHI_WEB}/profile.html
    Wait Until Element Is Visible    id:saveProfileButton
    ${tenDai}=    Evaluate    'A' * 51
    Input Text    id:fullname    ${tenDai}
    Click Button    id:saveProfileButton
    Wait Until Element Contains    id:fullnameError    từ 2 đến 50 ký tự

[ACC-PROFILE-15] Bỏ trống họ tên bị từ chối
    Đăng Nhập Khách Hàng
    Go To    ${DIA_CHI_WEB}/profile.html
    Wait Until Element Is Visible    id:saveProfileButton
    Clear Element Text    id:fullname
    Click Button    id:saveProfileButton
    Wait Until Element Contains    id:fullnameError    Vui lòng nhập họ tên

[ACC-PROFILE-04] Số điện thoại có chín chữ số bị từ chối
    Đăng Nhập Khách Hàng
    Go To    ${DIA_CHI_WEB}/profile.html
    Wait Until Element Is Visible    id:saveProfileButton
    Input Text    id:phone    123456789
    Click Button    id:saveProfileButton
    Wait Until Element Contains    id:phoneError    10 chữ số

[ACC-PROFILE-16] Số điện thoại có mười một chữ số bị từ chối
    Đăng Nhập Khách Hàng
    Go To    ${DIA_CHI_WEB}/profile.html
    Wait Until Element Is Visible    id:saveProfileButton
    Input Text    id:phone    12345678901
    Click Button    id:saveProfileButton
    Wait Until Element Contains    id:phoneError    10 chữ số

[ACC-PROFILE-17] Số điện thoại sai tiền tố bị từ chối
    Đăng Nhập Khách Hàng
    Go To    ${DIA_CHI_WEB}/profile.html
    Wait Until Element Is Visible    id:saveProfileButton
    Input Text    id:phone    1901234567
    Click Button    id:saveProfileButton
    Wait Until Element Contains    id:phoneError    bắt đầu bằng 0

[ACC-PROFILE-18] Số điện thoại chứa chữ bị từ chối
    Đăng Nhập Khách Hàng
    Go To    ${DIA_CHI_WEB}/profile.html
    Wait Until Element Is Visible    id:saveProfileButton
    Input Text    id:phone    09abc56789
    Click Button    id:saveProfileButton
    Wait Until Element Contains    id:phoneError    10 chữ số

[ACC-PROFILE-19] Bỏ trống số điện thoại bị từ chối
    Đăng Nhập Khách Hàng
    Go To    ${DIA_CHI_WEB}/profile.html
    Wait Until Element Is Visible    id:saveProfileButton
    Clear Element Text    id:phone
    Click Button    id:saveProfileButton
    Wait Until Element Contains    id:phoneError    Vui lòng nhập số điện thoại

[ACC-PROFILE-05] Địa chỉ có thể để trống
    Đăng Nhập Khách Hàng
    Go To    ${DIA_CHI_WEB}/profile.html
    Wait Until Element Is Visible    id:saveProfileButton
    Clear Element Text    id:address
    Click Button    id:saveProfileButton
    Wait Until Element Contains    id:profileMessage    Cập nhật hồ sơ thành công

[ACC-PROFILE-06] Địa chỉ ngắn hơn mười ký tự bị từ chối
    Đăng Nhập Khách Hàng
    Go To    ${DIA_CHI_WEB}/profile.html
    Wait Until Element Is Visible    id:saveProfileButton
    ${diaChiNgan}=    Evaluate    'A' * 9
    Input Text    id:address    ${diaChiNgan}
    Click Button    id:saveProfileButton
    Wait Until Element Contains    id:addressError    từ 10 đến 200 ký tự

[ACC-PROFILE-20] Địa chỉ dài hơn hai trăm ký tự bị từ chối
    Đăng Nhập Khách Hàng
    Go To    ${DIA_CHI_WEB}/profile.html
    Wait Until Element Is Visible    id:saveProfileButton
    ${diaChiDai}=    Evaluate    'A' * 201
    Input Text    id:address    ${diaChiDai}
    Click Button    id:saveProfileButton
    Wait Until Element Contains    id:addressError    từ 10 đến 200 ký tự
