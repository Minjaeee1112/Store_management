<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>

<%
    String orderTableIdParam = request.getParameter("orderTableId");
    int orderTableId = (orderTableIdParam != null && !orderTableIdParam.isEmpty()) ? Integer.parseInt(orderTableIdParam) : -1;

    if (orderTableId == -1) {
        out.println("<div class='alert alert-danger'>OrderTableId가 제공되지 않았습니다.</div>");
        return;
    }

    String sessionKey = "cart_" + orderTableId;
    List<Map<String, Object>> cart = (List<Map<String, Object>>) session.getAttribute(sessionKey);

    if (cart == null) {
        cart = new ArrayList<>();
        session.setAttribute(sessionKey, cart);
    }
%>



<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>장바구니</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css">
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script>
    function removeFromCart(productId) {
        const orderTableId = "<%= orderTableId %>";
        $.ajax({
            type: "POST",
            url: "cartManagement.jsp",
            data: { action: "remove", productId: productId, orderTableId: orderTableId },
            success: function(response) {
                $("#cart-message").html(response).fadeIn().delay(2000).fadeOut();
                location.reload(); // 새로고침
            }
        });
    }

    function checkout() {
        const orderTableId = "<%= orderTableId %>";
        $.ajax({
            type: "POST",
            url: "cartManagement.jsp",
            data: { action: "checkout", orderTableId: orderTableId },
            success: function(response) {
                $("#cart-message").html(response).fadeIn().delay(2000).fadeOut();
                location.reload(); // 새로고침
            }
        });
    }

    </script>
</head>
<body>
    <div class="container mt-5">
        <h1 class="mb-4">장바구니</h1>
        <div id="cart-message"></div>

        <% if (cart.isEmpty()) { %>
            <div class="alert alert-warning">장바구니가 비어 있습니다.</div>
        <% } else { %>
            <table class="table table-bordered">
                <thead>
                    <tr>
                        <th>상품명</th>
                        <th>가격</th>
                        <th>수량</th>
                        <th>합계</th>
                        <th>관리</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                        double totalAmount = 0;
                        for (Map<String, Object> item : cart) {
                            int productId = (int) item.get("productId");
                            String productName = (String) item.get("productName");
                            double productPrice = (double) item.get("productPrice");
                            int quantity = (int) item.get("quantity");
                            double subtotal = productPrice * quantity;
                            totalAmount += subtotal;
                    %>
                    <tr>
                        <td><%= productName %></td>
                        <td><%= productPrice %>원</td>
                        <td><%= quantity %></td>
                        <td><%= subtotal %>원</td>
                        <td>
                            <button class="btn btn-danger btn-sm" onclick="removeFromCart(<%= productId %>)">삭제</button>
                        </td>
                    </tr>
                    <% } %>
                    <tr>
                        <td colspan="3" class="text-end"><strong>총 합계</strong></td>
                        <td colspan="2"><strong><%= totalAmount %>원</strong></td>
                    </tr>
                </tbody>
            </table>
        <% } %>
        <a href="../NEWmenu.jsp?orderTableId=<%= orderTableId %>" class="btn btn-primary">메뉴로 돌아가기</a>
        <a href="javascript:void(0);" onclick="checkout();" class="btn btn-success">주문하기</a>
    </div>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>