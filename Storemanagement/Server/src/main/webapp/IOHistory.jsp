<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*" %>
<%
/*
    // 세션에서 사용자 역할과 사용자 이름을 확인
    String userRole = (String) session.getAttribute("userRole");
    String username = (String) session.getAttribute("username");

    // 세션에 저장된 정보가 없거나 권한이 admin이 아닌 경우
    if (userRole == null || username == null || !"admin".equals(userRole)) {
        // 로그인 페이지로 리다이렉트
        response.sendRedirect("index.jsp");
        return;
    }
*/
%>
<!DOCTYPE html>
<html>
<head>
    <title>결제 관리</title>
    <!-- 부트스트랩 CSS 링크 -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        /* 테이블 헤더 색상을 회색으로 설정 */
        .table-gray thead {
            background-color: #6c757d;
            color: white;
        }
    </style>
</head>
<body>
<jsp:include page="${pageContext.request.contextPath}/dashboard.jsp" />

<div class="container mt-5">
    <!-- 메인 타이틀 -->
    <div class="text-center mb-4">
        
    </div>
<br><br>
<%
    Connection con = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        con = DriverManager.getConnection("jdbc:mysql://localhost:3306/StoreManagement", "root", "root");

        // Payment 테이블에서 결제 기록을 가져오기
        String paymentSql = "SELECT PaymentID, OrderID, PaymentAmount, PaymentDate, PaymentMethod FROM Payment";
        pstmt = con.prepareStatement(paymentSql);
        rs = pstmt.executeQuery();

        out.println("<h2 class='text-center'>결제 내역</h2>");
        out.println("<table class='table table-gray table-striped table-hover mt-3'>");
        out.println("<thead>");
        out.println("<tr><th>결제 ID</th><th>주문 ID</th><th>결제 금액</th><th>결제 날짜</th><th>결제 방법</th></tr>");
        out.println("</thead>");
        out.println("<tbody>");
        while (rs.next()) {
            int paymentId = rs.getInt("PaymentID");
            int orderId = rs.getInt("OrderID");
            int paymentAmount = rs.getInt("PaymentAmount");
            Timestamp paymentDate = rs.getTimestamp("PaymentDate");
            String paymentMethod = rs.getString("PaymentMethod");

            out.println("<tr>");
            out.println("<td>" + paymentId + "</td>");
            out.println("<td>" + orderId + "</td>");
            out.println("<td>" + paymentAmount + "원</td>");
            out.println("<td>" + paymentDate + "</td>");
            out.println("<td>" + paymentMethod + "</td>");
            out.println("</tr>");
        }
        out.println("</tbody>");
        out.println("</table>");

    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        try {
            if (rs != null) rs.close();
            if (pstmt != null) pstmt.close();
            if (con != null) con.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
%>
</div>

<!-- 부트스트랩 JS 및 의존성 -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
