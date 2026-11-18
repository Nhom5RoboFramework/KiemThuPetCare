*** Settings ***
Resource          ../../resources/dung_chung.resource
Test Setup        Chuẩn Bị Ca Kiểm Thử
Test Teardown     Close Browser
Documentation     Kiểm thử trang chi tiết và trạng thái bán sản phẩm.

*** Test Cases ***
[PRD-DETAIL-01] Mở chi tiết sản phẩm từ danh sách
    Input Text    id:searchInput    Pate cho mèo
    Click Button    id:applyFilter
    Wait Until Element Contains    id:resultCount    1 sản phẩm
    Click Element    xpath://article[contains(@class,'product-card')][.//h3[normalize-space()='Pate cho mèo']]//a[contains(@class,'detail-link')]
    Wait Until Element Contains    id:productName    Pate cho mèo
    Page Should Contain Element    id:productDescription

[PRD-DETAIL-02] Sản phẩm hết hàng không thể thêm vào giỏ
    Go To    ${DIA_CHI_WEB}/product.html?id=21
    Wait Until Element Contains    id:productStock    Hết hàng
    Element Should Be Disabled    id:addToCartButton
    Element Should Be Disabled    id:quantity

[PRD-DETAIL-03] Khách chưa đăng nhập được chuyển tới đăng nhập khi thêm hàng
    Go To    ${DIA_CHI_WEB}/product.html?id=2
    Wait Until Element Is Visible    id:addToCartButton
    Click Button    id:addToCartButton
    Wait Until Location Contains    login.html
    Wait Until Element Is Visible    id:loginButton

[PRD-DETAIL-04] Số lượng bằng không không được thêm vào giỏ
    Đăng Nhập Khách Hàng
    Go To    ${DIA_CHI_WEB}/product.html?id=2
    Wait Until Element Is Visible    id:quantity
    Input Text    id:quantity    0
    Click Button    id:addToCartButton
    Wait Until Element Contains    id:message    Số lượng phải là số nguyên từ 1 trở lên

[PRD-DETAIL-05] Thêm đúng số lượng tồn kho được chấp nhận
    Đăng Nhập Khách Hàng
    Go To    ${DIA_CHI_WEB}/product.html?id=2
    Wait Until Element Is Visible    id:quantity
    Input Text    id:quantity    100
    Click Button    id:addToCartButton
    Wait Until Element Contains    id:successMessage    Đã thêm vào giỏ hàng

[PRD-DETAIL-06] Không mở được sản phẩm đã ẩn
    Go To    ${DIA_CHI_WEB}/product.html?id=22
    Wait Until Element Contains    id:loadError    Không tìm thấy sản phẩm
