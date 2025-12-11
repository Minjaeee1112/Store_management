<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*" %>

<%
    // URL에서 OrderTableId 가져오기
    String orderTableIdParam = request.getParameter("orderTableId");
    int orderTableId = (orderTableIdParam != null && !orderTableIdParam.isEmpty()) 
        ? Integer.parseInt(orderTableIdParam) 
        : -1;

    if (orderTableId == -1) {
        // OrderTableId가 없는 경우 에러 메시지 출력
        out.println("<div class='alert alert-danger'>OrderTableId가 제공되지 않았습니다.</div>");
        return;
    }

    // DB에서 주문 내역과 해당 주문 아이템 가져오기
    Connection con = null;
    PreparedStatement orderStmt = null;
    PreparedStatement itemStmt = null;
    ResultSet orderRs = null;
    ResultSet itemRs = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        con = DriverManager.getConnection("jdbc:mysql://localhost:3306/StoreManagement", "root", "root");

        // 특정 테이블 ID의 주문 내역 가져오기
        String orderSql = "SELECT * FROM `Order` WHERE OrderTableID = ? AND LOWER(OrderStatus) NOT IN ('paid', 'cancel') ORDER BY OrderDate DESC";

        orderStmt = con.prepareStatement(orderSql);
        orderStmt.setInt(1, orderTableId);
        orderRs = orderStmt.executeQuery();
%>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>주문 내역</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css">
</head>
<body>
    <div class="container mt-5">
        <h1 class="mb-4">주문 내역</h1>

        <% if (!orderRs.isBeforeFirst()) { %>
            <div class="alert alert-warning">주문 내역이 없습니다.</div>
        <% } else { %>
            <div class="accordion" id="orderHistoryAccordion">
                <% while (orderRs.next()) { 
                    int orderId = orderRs.getInt("OrderID");
                    double totalAmount = orderRs.getDouble("TotalAmount");
                    String orderStatus = orderRs.getString("OrderStatus");
                    Timestamp orderDate = orderRs.getTimestamp("OrderDate");
                %>
                <div class="accordion-item">
                    <h2 class="accordion-header" id="heading<%= orderId %>">
                        <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#collapse<%= orderId %>" aria-expanded="false" aria-controls="collapse<%= orderId %>">
                            주문 ID: <%= orderId %> | 총 금액: <%= totalAmount %>원 | 상태: <%= orderStatus %> | 주문 날짜: <%= orderDate %>
                        </button>
                    </h2>
                    <div id="collapse<%= orderId %>" class="accordion-collapse collapse" aria-labelledby="heading<%= orderId %>" data-bs-parent="#orderHistoryAccordion">
                        <div class="accordion-body">
                            <table class="table table-bordered">
                                <thead>
                                    <tr>
                                        <th>상품명</th>
                                        <th>수량</th>
                                        <th>가격</th>
                                        <th>합계</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <%
                                        // OrderItem 테이블에서 해당 주문의 상품 가져오기
                                        String itemSql = "SELECT oi.Quantity, oi.FinalPrice, p.ProductName " +
                                                         "FROM OrderItem oi JOIN Product p ON oi.ProductID = p.ProductID " +
                                                         "WHERE oi.OrderID = ?";
                                        itemStmt = con.prepareStatement(itemSql);
                                        itemStmt.setInt(1, orderId);
                                        itemRs = itemStmt.executeQuery();

                                        while (itemRs.next()) {
                                            String productName = itemRs.getString("ProductName");
                                            int quantity = itemRs.getInt("Quantity");
                                            double price = itemRs.getDouble("FinalPrice");
                                            double subtotal = price * quantity;
                                    %>
                                    <tr>
                                        <td><%= productName %></td>
                                        <td><%= quantity %></td>
                                        <td><%= price %>원</td>
                                        <td><%= subtotal %>원</td>
                                    </tr>
                                    <% } %>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
                <% } %>
            </div>
        <% } %>

        <a href="../NEWmenu.jsp?orderTableId=<%= orderTableId %>" class="btn btn-primary mt-3">메뉴로 돌아가기</a>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>

<%
    } catch (Exception e) {
        e.printStackTrace();
        out.println("<div class='alert alert-danger'>오류가 발생했습니다: " + e.getMessage() + "</div>");
    } finally {
        try {
            if (orderRs != null) orderRs.close();
            if (itemRs != null) itemRs.close();
            if (orderStmt != null) orderStmt.close();
            if (itemStmt != null) itemStmt.close();
            if (con != null) con.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
%>
