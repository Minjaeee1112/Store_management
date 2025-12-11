<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>로그인</title>
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">

    <style>
        body {
            font-family: Arial, sans-serif;
            height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            margin: 0;
            background-color: #f4f4f4;
        }
        .form-section {
            background-color: white;
            border: 1px solid #ddd;
            padding: 30px;
            box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
            width: 100%;
            max-width: 400px;
            text-align: center;
            border-radius: 8px;
        }
        .btn-group-vertical .btn {
            margin-top: 10px;
        }
    </style>
</head>
<body>
    <div class="form-section">
        <h2 class="mb-4">로그인</h2>
        <form method="POST">
            <div class="form-group">
                <label for="username">아이디:</label>
                <input type="text" id="username" name="username" class="form-control" required>
            </div>
            <div class="form-group">
                <label for="password">비밀번호:</label>
                <input type="password" id="password" name="password" class="form-control" required>
            </div>
            <button type="submit" class="btn btn-primary btn-block">로그인</button>
            <div class="btn-group-vertical w-100 mt-3">
                <button type="button" class="btn btn-secondary" onclick="location.href='find_id.jsp'">아이디 찾기</button>
                <button type="button" class="btn btn-secondary" onclick="location.href='find_password.jsp'">비밀번호 찾기</button>
            </div>
        </form>
    </div>

<%
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String username = request.getParameter("username");
        String password = request.getParameter("password");

        Connection con = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            con = DriverManager.getConnection("jdbc:mysql://localhost:3306/StoreManagement", "root", "root");

            String sql = "SELECT * FROM User WHERE UserName = ? AND UserPassword = ?";
            pstmt = con.prepareStatement(sql);
            pstmt.setString(1, username);
            pstmt.setString(2, password);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                session.setAttribute("userId", rs.getInt("UserID"));
                session.setAttribute("username", rs.getString("UserName"));
                session.setAttribute("userRole", rs.getString("UserRole"));

                System.out.println("로그인 성공 - 리디렉션 시작");
                response.sendRedirect(request.getContextPath() + "/product/register_product.jsp");
                return;
            } else {
                System.out.println("로그인 실패 - 아이디 또는 비밀번호 잘못됨");
                out.println("<script>alert('로그인 실패, 아이디 혹은 비밀번호가 잘못됐습니다.');</script>");
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if (rs != null) try { rs.close(); } catch (SQLException e) { e.printStackTrace(); }
            if (pstmt != null) try { pstmt.close(); } catch (SQLException e) { e.printStackTrace(); }
            if (con != null) try { con.close(); } catch (SQLException e) { e.printStackTrace(); }
        }
    }
%>
</body>
</html>

