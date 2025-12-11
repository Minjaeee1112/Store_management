<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*" %>
<%/*
    // 세션에서 사용자 역할과 사용자 이름을 확인
    String userRole = (String) session.getAttribute("userRole");
    String username = (String) session.getAttribute("username");

    // 세션에 저장된 정보가 없거나 권한이 admin이 아닌 경우
    if (userRole == null || username == null || !"admin".equals(userRole)) {
        // 로그인 페이지로 리다이렉트
        response.sendRedirect("index.jsp");
        return;
    }*/
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>결제 취소</title>
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
</head>
<body>
    <div class="container mt-5">
        <h2 class="text-center mb-4">결제 취소</h2>
        <form method="post">
            <div class="form-group">
                <label for="payment-list">결제 내역</label>
                <div id="payment-list">
                    <% 
                        // 데이터베이스 연결 정보
                        String DB_URL = "jdbc:mysql://localhost:3306/storemanagement";
                        String DB_USER = "root";
                        String DB_PASSWORD = "root";

                        // 결제 내역 가져오기
                        try (Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD)) {
                            String query = "SELECT PaymentID, PaymentAmount, PaymentStatus, PaymentDate FROM Payment WHERE PaymentStatus = 'Paid' ORDER BY PaymentDate DESC";
                            try (PreparedStatement stmt = conn.prepareStatement(query);
                                 ResultSet rs = stmt.executeQuery()) {
                                while (rs.next()) {
                                    int paymentId = rs.getInt("PaymentID");
                                    double paymentAmount = rs.getDouble("PaymentAmount");
                                    String paymentStatus = rs.getString("PaymentStatus");
                                    String paymentDate = rs.getTimestamp("PaymentDate").toString();

                                    // 결제 내역을 라디오 버튼으로 표시
                                    out.println("<div class='form-check'>");
                                    out.println("<input class='form-check-input' type='radio' name='paymentId' value='" + paymentId + "' id='payment-" + paymentId + "'>");
                                    out.println("<label class='form-check-label' for='payment-" + paymentId + "'>");
                                    out.println("결제 ID: " + paymentId + ", 금액: " + paymentAmount + "원, 상태: " + paymentStatus + ", 날짜: " + paymentDate);
                                    out.println("</label>");
                                    out.println("</div>");
                                }
                            }
                        } catch (SQLException e) {
                            e.printStackTrace();
                            out.println("<p class='text-danger'>결제 내역을 가져오는 중 오류가 발생했습니다.</p>");
                        }
                    %>
                </div>
            </div>
            <button type="submit" class="btn btn-danger">결제 취소</button>
        </form>
        <% 
            // 결제 취소 처리
            String selectedPaymentId = request.getParameter("paymentId");
            if (selectedPaymentId != null) {
                try (Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD)) {
                    conn.setAutoCommit(false); // 트랜잭션 시작
                    
                    // Payment 테이블 상태 변경
                    String updatePaymentStatusQuery = "UPDATE Payment SET PaymentStatus = 'Cancel' WHERE PaymentID = ?";
                    try (PreparedStatement stmt = conn.prepareStatement(updatePaymentStatusQuery)) {
                        stmt.setInt(1, Integer.parseInt(selectedPaymentId));
                        stmt.executeUpdate();
                    }

                    // Order 테이블 상태 변경
                    String fetchOrderIdQuery = "SELECT OrderID FROM Payment WHERE PaymentID = ?";
                    int orderId = 0;
                    try (PreparedStatement stmt = conn.prepareStatement(fetchOrderIdQuery)) {
                        stmt.setInt(1, Integer.parseInt(selectedPaymentId));
                        try (ResultSet rs = stmt.executeQuery()) {
                            if (rs.next()) {
                                orderId = rs.getInt("OrderID");
                            }
                        }
                    }

                    if (orderId > 0) {
                        String updateOrderStatusQuery = "UPDATE `Order` SET OrderStatus = 'Cancel' WHERE OrderID = ?";
                        try (PreparedStatement stmt = conn.prepareStatement(updateOrderStatusQuery)) {
                            stmt.setInt(1, orderId);
                            stmt.executeUpdate();
                        }

                        // OrderItem 테이블 상태 변경
                        String updateOrderItemStatusQuery = "UPDATE OrderItem SET Status = 'Cancel' WHERE OrderID = ?";
                        try (PreparedStatement stmt = conn.prepareStatement(updateOrderItemStatusQuery)) {
                            stmt.setInt(1, orderId);
                            stmt.executeUpdate();
                        }
                    }

                    conn.commit(); // 트랜잭션 커밋
                    out.println("<p class='text-success'>결제가 성공적으로 취소되었습니다.</p>");
                } catch (SQLException e) {
                    e.printStackTrace();
                    out.println("<p class='text-danger'>결제를 취소하는 중 오류가 발생했습니다.</p>");
                }
            }
        %>
    </div>
</body>
</html>
