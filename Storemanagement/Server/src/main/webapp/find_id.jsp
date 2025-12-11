<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
    <title>아이디 찾기</title>
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f8f9fa;
            height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            margin: 0;
        }
        .card {
            width: 100%;
            max-width: 400px;
        }
    </style>
</head>
<body>
    <div class="container d-flex justify-content-center align-items-center" style="height: 100vh;">
        <div class="card">
            <div class="card-header text-center">
                <h2>아이디 찾기</h2>
            </div>
            <div class="card-body">
                <form method="POST" action="find_id.jsp">
                    <div class="form-group">
                        <label for="email">이메일 주소</label>
                        <input type="email" class="form-control" id="email" name="email" required>
                    </div>
                    <button type="submit" class="btn btn-primary btn-block">아이디 찾기</button>
                </form>
                <div class="mt-3 text-center">
                    <a href="index.jsp">로그인 페이지로 돌아가기</a>
                </div>
            </div>
            <div class="card-footer text-center">
                <%
                    if (request.getMethod().equalsIgnoreCase("POST")) {
                        String email = request.getParameter("email");
                        Connection con = null;
                        PreparedStatement pstmt = null;
                        ResultSet rs = null;

                        try {
                            Class.forName("com.mysql.cj.jdbc.Driver");
                            con = DriverManager.getConnection("jdbc:mysql://localhost:3306/StoreManagement", "root", "root");

                            String sql = "SELECT UserName FROM User WHERE UserEmail = ?";
                            pstmt = con.prepareStatement(sql);
                            pstmt.setString(1, email);
                            rs = pstmt.executeQuery();

                            if (rs.next()) {
                                out.println("<p>아이디는 <strong>" + rs.getString("UserName") + "</strong>입니다.</p>");
                            } else {
                                out.println("<p class='text-danger'>등록된 이메일이 없습니다.</p>");
                            }
                        } catch (Exception e) {
                            e.printStackTrace();
                            out.println("<p class='text-danger'>오류가 발생했습니다. 다시 시도해주세요.</p>");
                        } finally {
                            try { if (rs != null) rs.close(); if (pstmt != null) pstmt.close(); if (con != null) con.close(); } catch (SQLException e) { e.printStackTrace(); }
                        }
                    }
                %>
            </div>
        </div>
    </div>
</body>
</html>
