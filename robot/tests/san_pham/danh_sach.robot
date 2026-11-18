*** Settings ***
Resource          ../../resources/dung_chung.resource
Test Setup        Chuẩn Bị Ca Kiểm Thử
Test Teardown     Close Browser
Documentation     Kiểm thử tìm kiếm, lọc, sắp xếp và phân trang sản phẩm.

*** Test Cases ***
[PRD-LIST-01] Danh sách có 21 sản phẩm và phân trang tám sản phẩm
    Wait Until Element Contains    id:resultCount    21 sản phẩm
    Page Should Contain Element    css:.product-card
    ${soLuong}=    Get Element Count    css:.product-card
    Should Be Equal As Integers    ${soLuong}    8
    Element Should Contain    id:pageInfo    Trang 1/3
    Click Button    id:nextPage
    Wait Until Element Contains    id:pageInfo    Trang 2/3
    Click Button    id:nextPage
    Wait Until Element Contains    id:pageInfo    Trang 3/3
    ${soLuongTrangCuoi}=    Get Element Count    css:.product-card
    Should Be Equal As Integers    ${soLuongTrangCuoi}    5
    Click Button    id:prevPage
    Wait Until Element Contains    id:pageInfo    Trang 2/3

[PRD-LIST-02] Tìm tên sản phẩm không phân biệt chữ hoa thường
    Input Text    id:searchInput    pAtE CHO MÈO
    Click Button    id:applyFilter
    Wait Until Element Contains    id:resultCount    1 sản phẩm
    Page Should Contain Element    xpath://article[contains(@class,'product-card')]//h3[normalize-space()='Pate cho mèo']

[PRD-LIST-03] Lọc sản phẩm theo danh mục
    Select From List By Label    id:categoryFilter    Thức ăn
    Click Button    id:applyFilter
    Wait Until Element Contains    id:resultCount    5 sản phẩm

[PRD-LIST-04] Lọc theo khoảng giá hợp lệ
    Input Text    id:minPrice    40000
    Input Text    id:maxPrice    60000
    Click Button    id:applyFilter
    Wait Until Element Contains    id:resultCount    6 sản phẩm

[PRD-LIST-05] Khoảng giá bằng nhau lấy đúng các sản phẩm ở biên
    Input Text    id:minPrice    45000
    Input Text    id:maxPrice    45000
    Click Button    id:applyFilter
    Wait Until Element Contains    id:resultCount    2 sản phẩm

[PRD-LIST-06] Lọc theo danh mục không có sản phẩm hiển thị trạng thái rỗng
    Select From List By Label    id:categoryFilter    Quần áo
    Input Text    id:minPrice    200000
    Click Button    id:applyFilter
    Wait Until Element Is Visible    id:emptyMessage
    Element Should Contain    id:resultCount    0 sản phẩm

[PRD-LIST-07] Từ chối khoảng giá có giá thấp nhất lớn hơn giá cao nhất
    Input Text    id:minPrice    200000
    Input Text    id:maxPrice    100000
    Click Button    id:applyFilter
    Wait Until Element Contains    id:filterError    Giá thấp nhất phải nhỏ hơn hoặc bằng giá cao nhất

[PRD-LIST-08] Từ chối giá lọc không phải số nguyên
    Go To    ${DIA_CHI_WEB}/index.html?minPrice=abc
    Wait Until Element Contains    id:filterError    Giá thấp nhất không hợp lệ

[PRD-LIST-09] Từ chối số trang bằng không
    Go To    ${DIA_CHI_WEB}/index.html?page=0
    Wait Until Element Contains    id:filterError    Số trang không hợp lệ

[PRD-LIST-10] Từ chối cách sắp xếp không được hỗ trợ
    Go To    ${DIA_CHI_WEB}/index.html?sort=unknown
    Wait Until Element Contains    id:filterError    Cách sắp xếp không hợp lệ

[PRD-LIST-11] Sắp xếp giá tăng dần
    Select From List By Value    id:sortSelect    price_asc
    Click Button    id:applyFilter
    Wait Until Element Contains    css:.product-card:first-child .product-name    Chuột bông cho mèo

[PRD-LIST-12] Sắp xếp giá giảm dần
    Select From List By Value    id:sortSelect    price_desc
    Click Button    id:applyFilter
    Wait Until Element Contains    css:.product-card:first-child .product-name    Túi vận chuyển

[PRD-LIST-13] Xóa bộ lọc khôi phục danh sách sản phẩm
    Input Text    id:searchInput    khong-co-san-pham
    Click Button    id:applyFilter
    Wait Until Element Is Visible    id:emptyMessage
    Click Button    id:resetFilter
    Wait Until Element Contains    id:resultCount    21 sản phẩm
