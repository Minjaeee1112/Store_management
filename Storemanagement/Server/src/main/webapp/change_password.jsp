<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="javax.servlet.http.*, javax.servlet.*" %>

<%
    HttpSession session2 = request.getSession(false);
    Integer userId = (Integer) session2.getAttribute("userId"); // 세션에서 userId 가져오기
    String message = "";

    if (userId == null) {
        response.sendRedirect("../index.jsp"); // 세션이 없으면 로그인 페이지로 리다이렉트
        return;
    }

    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String currentPassword = request.getParameter("currentPassword");
        String newPassword = request.getParameter("newPassword");
        String confirmPassword = request.getParameter("confirmPassword");

        if (newPassword.equals(confirmPassword)) {
            Connection conn = null;
            PreparedStatement pstmt = null;
            ResultSet rs = null;
            String url = "jdbc:mysql://127.0.0.1:3306/StoreManagement";

            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                conn = DriverManager.getConnection(url, "root", "root");

                // 현재 비밀번호가 맞는지 확인
                String checkPasswordQuery = "SELECT * FROM User WHERE UserID = ? AND UserPassword = ?";
                pstmt = conn.prepareStatement(checkPasswordQuery);
                pstmt.setInt(1, userId);
                pstmt.setString(2, currentPassword);
                rs = pstmt.executeQuery();

                if (rs.next()) {
                    // 비밀번호 업데이트
                    String updatePasswordQuery = "UPDATE User SET UserPassword = ? WHERE UserID = ?";
                    pstmt = conn.prepareStatement(updatePasswordQuery);
                    pstmt.setString(1, newPassword);
                    pstmt.setInt(2, userId);
                    int rowsUpdated = pstmt.executeUpdate();

                    if (rowsUpdated > 0) {
                        message = "비밀번호가 성공적으로 변경되었습니다.";
                    } else {
                        message = "비밀번호 변경 중 오류가 발생했습니다. 다시 시도해주세요.";
                    }
                } else {
                    message = "현재 비밀번호가 일치하지 않습니다.";
                }
            } catch (Exception e) {
                e.printStackTrace();
                message = "오류가 발생했습니다. 다시 시도해주세요.";
            } finally {
                if (rs != null) rs.close();
                if (pstmt != null) pstmt.close();
                if (conn != null) conn.close();
            }
        } else {
            message = "새 비밀번호와 확인 비밀번호가 일치하지 않습니다.";
        }
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>비밀번호 변경</title>
    <link rel="stylesheet" type="text/css" href="change_password.css">
</head>
<body class="bg-light">
<jsp:include page="${pageContext.request.contextPath}/dashboard.jsp" />
<div class="container mt-5 d-flex justify-content-center">
    <div class="card col-md-8 col-lg-6">
        <div class="card-header text-center">
            <h2>비밀번호 변경</h2>
        </div>
        <div class="card-body">
            <form method="POST">
                <div class="form-group">
                    <label for="currentPassword">현재 비밀번호</label>
                    <input type="password" class="form-control" id="currentPassword" name="currentPassword" required>
                </div>
                <div class="form-group">
                    <label for="newPassword">새 비밀번호</label>
                    <input type="password" class="form-control" id="newPassword" name="newPassword" required>
                </div>
                <div class="form-group">
                    <label for="confirmPassword">새 비밀번호 확인</label>
                    <input type="password" class="form-control" id="confirmPassword" name="confirmPassword" required>
                </div>
                <button type="submit" class="btn btn-primary btn-block">비밀번호 변경</button>
            </form>
            <p class="text-center text-danger mt-3"><%= message %></p>
        </div>
    </div>
</div>
</body>
</html>

