*** Settings ***
Resource          ../../resources/dung_chung.resource
Test Setup        Chuẩn Bị Ca Kiểm Thử
Test Teardown     Close Browser
Documentation     Kiểm thử quản trị sản phẩm.

*** Test Cases ***
[ADMIN-PRODUCT-01] Quản trị viên thêm sản phẩm mới
    Đăng Nhập Quản Trị Viên
    Wait Until Element Is Visible    id:adminProductList
    Input Text    id:pName    Robot Test Treat
    Select From List By Label    id:pCategory    Thức ăn
    Input Text    id:pPrice    50000
    Input Text    id:pStock    7
    Input Text    id:pDescription    Sản phẩm kiểm thử Robot Framework
    Click Button    id:saveProductButton
    Wait Until Element Contains    id:productMessage    Đã thêm sản phẩm
    ${dong}=    Set Variable    xpath://tr[.//b[contains(@class,'p-name') and contains(.,'Robot Test Treat')]]
    Wait Until Element Is Visible    ${dong}

[ADMIN-PRODUCT-12] Quản trị viên cập nhật sản phẩm
    Đăng Nhập Quản Trị Viên
    ${dong}=    Set Variable    xpath://tr[.//b[contains(@class,'p-name') and contains(.,'Pate cho mèo')]]
    Wait Until Element Is Visible    ${dong}
    Click Button    ${dong}//button[contains(@class,'edit-product')]
    Input Text    id:pName    Pate cập nhật
    Input Text    id:pPrice    36000
    Click Button    id:saveProductButton
    Wait Until Element Contains    id:productMessage    Đã cập nhật sản phẩm
    ${dongCapNhat}=    Set Variable    xpath://tr[.//b[contains(@class,'p-name') and contains(.,'Pate cập nhật')]]
    Page Should Contain Element    ${dongCapNhat}
    Element Should Contain    ${dongCapNhat}    36.000đ

[ADMIN-PRODUCT-13] Quản trị viên xóa sản phẩm chưa có trong đơn
    Đăng Nhập Quản Trị Viên
    ${dong}=    Set Variable    xpath://tr[.//b[contains(@class,'p-name') and contains(.,'Xương gặm sạch răng')]]
    Wait Until Element Is Visible    ${dong}
    Click Button    ${dong}//button[contains(@class,'delete-product')]
    Click Button    ${dong}//button[contains(@class,'delete-product')]
    Wait Until Element Contains    id:productMessage    Đã xóa sản phẩm
    Wait Until Page Does Not Contain Element    ${dong}

[ADMIN-PRODUCT-02] Quản trị viên ẩn sản phẩm đã có trong đơn
    Đăng Nhập Khách Hàng
    Thêm Sản Phẩm Vào Giỏ    2    1
    Go To    ${DIA_CHI_WEB}/checkout.html
    Click Button    id:placeOrderButton
    Wait Until Element Is Visible    id:orderSuccess
    Click Button    id:logoutButton
    Đăng Nhập Quản Trị Viên
    ${dongSanPham}=    Set Variable    xpath://tr[.//b[contains(@class,'p-name') and contains(.,'Pate cho mèo')]]
    Wait Until Element Is Visible    ${dongSanPham}
    Click Button    ${dongSanPham}//button[contains(@class,'delete-product')]
    Click Button    ${dongSanPham}//button[contains(@class,'delete-product')]
    Wait Until Element Contains    id:productMessage    Sản phẩm đã có trong đơn hàng nên được ẩn
    Element Should Contain    ${dongSanPham}    Đã ẩn

[ADMIN-PRODUCT-03] Quản trị viên từ chối sản phẩm thiếu dữ liệu bắt buộc
    Đăng Nhập Quản Trị Viên
    Click Button    id:saveProductButton
    Wait Until Element Contains    id:pNameError    tên sản phẩm
    Element Should Contain    id:pPriceError    Giá phải là số nguyên
    Element Should Contain    id:pStockError    Tồn kho phải là số nguyên
    Element Should Contain    id:pCategoryError    Vui lòng chọn danh mục

[ADMIN-PRODUCT-04] Quản trị viên từ chối tên sản phẩm ngắn hơn hai ký tự
    Đăng Nhập Quản Trị Viên
    Select From List By Label    id:pCategory    Thức ăn
    Input Text    id:pPrice    1000
    Input Text    id:pStock    1
    Input Text    id:pName    A
    Click Button    id:saveProductButton
    Wait Until Element Contains    id:pNameError    từ 2 đến 100 ký tự
[ADMIN-PRODUCT-05] Quản trị viên từ chối tên sản phẩm dài hơn một trăm ký tự
    Đăng Nhập Quản Trị Viên
    Select From List By Label    id:pCategory    Thức ăn
    Input Text    id:pPrice    1000
    Input Text    id:pStock    1
    ${tenDai}=    Evaluate    'A' * 101
    Input Text    id:pName    ${tenDai}
    Click Button    id:saveProductButton
    Wait Until Element Contains    id:pNameError    từ 2 đến 100 ký tự

[ADMIN-PRODUCT-06] Quản trị viên từ chối giá bằng không
    Đăng Nhập Quản Trị Viên
    Input Text    id:pName    Product Price Test
    Select From List By Label    id:pCategory    Thức ăn
    Input Text    id:pStock    1
    Input Text    id:pPrice    0
    Click Button    id:saveProductButton
    Wait Until Element Contains    id:pPriceError    Giá phải là số nguyên lớn hơn 0

[ADMIN-PRODUCT-07] Quản trị viên từ chối giá âm
    Đăng Nhập Quản Trị Viên
    Input Text    id:pName    Product Price Test
    Select From List By Label    id:pCategory    Thức ăn
    Input Text    id:pStock    1
    Input Text    id:pPrice    -1
    Click Button    id:saveProductButton
    Wait Until Element Contains    id:pPriceError    Giá phải là số nguyên lớn hơn 0

[ADMIN-PRODUCT-08] Quản trị viên từ chối giá thập phân
    Đăng Nhập Quản Trị Viên
    Input Text    id:pName    Product Price Test
    Select From List By Label    id:pCategory    Thức ăn
    Input Text    id:pStock    1
    Input Text    id:pPrice    1.5
    Click Button    id:saveProductButton
    Wait Until Element Contains    id:pPriceError    Giá phải là số nguyên lớn hơn 0

[ADMIN-PRODUCT-09] Quản trị viên từ chối tồn kho âm
    Đăng Nhập Quản Trị Viên
    Input Text    id:pName    Product Stock Test
    Select From List By Label    id:pCategory    Thức ăn
    Input Text    id:pPrice    1000
    Input Text    id:pStock    -1
    Click Button    id:saveProductButton
    Wait Until Element Contains    id:pStockError    Tồn kho phải là số nguyên không âm

[ADMIN-PRODUCT-10] Quản trị viên từ chối tồn kho thập phân
    Đăng Nhập Quản Trị Viên
    Input Text    id:pName    Product Stock Test
    Select From List By Label    id:pCategory    Thức ăn
    Input Text    id:pPrice    1000
    Input Text    id:pStock    1.5
    Click Button    id:saveProductButton
    Wait Until Element Contains    id:pStockError    Tồn kho phải là số nguyên không âm

[ADMIN-PRODUCT-11] Quản trị viên chấp nhận giá nhỏ nhất và tồn kho bằng không
    Đăng Nhập Quản Trị Viên
    Input Text    id:pName    P0
    Select From List By Label    id:pCategory    Thức ăn
    Input Text    id:pPrice    1
    Input Text    id:pStock    0
    Click Button    id:saveProductButton
    Wait Until Element Contains    id:productMessage    Đã thêm sản phẩm
    Page Should Contain Element    xpath://tr[.//b[contains(@class,'p-name') and contains(.,'P0')]][.//td[contains(@class,'p-stock') and normalize-space()='0']]
