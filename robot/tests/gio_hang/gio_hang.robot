*** Settings ***
Resource          ../../resources/dung_chung.resource
Test Setup        Chuẩn Bị Ca Kiểm Thử
Test Teardown     Close Browser
Documentation     Kiểm thử thêm, cập nhật và xóa sản phẩm trong giỏ hàng.

*** Test Cases ***
[CART-01] Khách chưa đăng nhập vào giỏ được chuyển tới đăng nhập
    Go To    ${DIA_CHI_WEB}/cart.html
    Wait Until Location Contains    login.html
    Wait Until Element Is Visible    id:loginButton

[CART-02] Thêm sản phẩm hai lần thì cộng dồn số lượng
    Đăng Nhập Khách Hàng
    Thêm Sản Phẩm Vào Giỏ    2    1
    Click Button    id:addToCartButton
    Wait Until Element Contains    id:successMessage    Đã thêm vào giỏ hàng
    Go To    ${DIA_CHI_WEB}/cart.html
    Wait Until Element Is Visible    id:cartTotal
    Wait Until Element Contains    id:cartTotal    70.000đ
    Element Should Contain    id:cartCount    2

[CART-03] Không cho thêm số lượng vượt quá tồn kho
    Đăng Nhập Khách Hàng
    Go To    ${DIA_CHI_WEB}/product.html?id=2
    Wait Until Element Is Visible    id:quantity
    Input Text    id:quantity    101
    Click Button    id:addToCartButton
    Wait Until Element Contains    id:message    vượt quá tồn kho

[CART-04] Không cho cộng dồn vượt tồn kho khi sản phẩm đã có trong giỏ
    Đăng Nhập Khách Hàng
    Thêm Sản Phẩm Vào Giỏ    2    60
    Go To    ${DIA_CHI_WEB}/product.html?id=2
    Wait Until Element Is Visible    id:quantity
    Input Text    id:quantity    41
    Click Button    id:addToCartButton
    Wait Until Element Contains    id:message    vượt quá tồn kho

[CART-05] Không chấp nhận số lượng giỏ bằng không
    Đăng Nhập Khách Hàng
    Thêm Sản Phẩm Vào Giỏ    2    2
    Go To    ${DIA_CHI_WEB}/cart.html
    Wait Until Element Is Visible    css:.qty-input
    Click Element    css:.qty-input
    Press Keys    css:.qty-input    CTRL+A    0    TAB
    Wait Until Element Contains    id:cartMessage    Số lượng phải là số nguyên từ 1 trở lên

[CART-06] Không cho cập nhật số lượng giỏ vượt tồn kho
    Đăng Nhập Khách Hàng
    Thêm Sản Phẩm Vào Giỏ    2    2
    Go To    ${DIA_CHI_WEB}/cart.html
    Wait Until Element Is Visible    css:.qty-input
    Click Element    css:.qty-input
    Press Keys    css:.qty-input    CTRL+A    101    TAB
    Wait Until Element Contains    id:cartMessage    vượt quá tồn kho
    Element Should Contain    id:cartTotal    70.000đ

[CART-07] Cập nhật số lượng sản phẩm trong giỏ
    Đăng Nhập Khách Hàng
    Thêm Sản Phẩm Vào Giỏ    2    2
    Go To    ${DIA_CHI_WEB}/cart.html
    Wait Until Element Is Visible    css:.qty-input
    Wait Until Element Contains    id:cartTotal    70.000đ
    Click Element    css:.qty-input
    Press Keys    css:.qty-input    CTRL+A    3    TAB
    Wait Until Element Contains    id:cartTotal    105.000đ

[CART-09] Xóa sản phẩm khỏi giỏ
    Đăng Nhập Khách Hàng
    Thêm Sản Phẩm Vào Giỏ    2    2
    Go To    ${DIA_CHI_WEB}/cart.html
    Wait Until Element Is Visible    css:.remove-btn
    Click Button    css:.remove-btn
    Wait Until Element Is Visible    id:emptyCart

[CART-08] Xóa toàn bộ giỏ hàng
    Đăng Nhập Khách Hàng
    Thêm Sản Phẩm Vào Giỏ    2    2
    Go To    ${DIA_CHI_WEB}/cart.html
    Wait Until Element Is Visible    id:clearCart
    Click Button    id:clearCart
    Wait Until Element Is Visible    id:emptyCart
