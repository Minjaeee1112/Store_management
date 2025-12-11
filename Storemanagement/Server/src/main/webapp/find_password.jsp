<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, javax.mail.*, javax.mail.internet.*, java.util.*" %>
<!DOCTYPE html>
<html>
<head>
    <title>비밀번호 찾기</title>
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f8f9fa;
            height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
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
                <h2>비밀번호 찾기</h2>
            </div>
            <div class="card-body">
                <form method="POST" action="find_password.jsp">
                    <div class="form-group">
                        <label for="username">아이디</label>
                        <input type="text" class="form-control" id="username" name="username" required>
                    </div>
                    <div class="form-group">
                        <label for="email">이메일 주소</label>
                        <input type="email" class="form-control" id="email" name="email" required>
                    </div>
                    <button type="submit" class="btn btn-primary btn-block">비밀번호 찾기</button>
                </form>
                <div class="mt-3 text-center">
                    <a href="index.jsp">로그인 페이지로 돌아가기</a>
                </div>
            </div>
            <div class="card-footer text-center">
                <%
                    if (request.getMethod().equalsIgnoreCase("POST")) {
                        String username = request.getParameter("username");
                        String email = request.getParameter("email");
                        Connection con = null;
                        PreparedStatement pstmt = null;
                        ResultSet rs = null;
                        String tempPassword = "";

                        try {
                            // 데이터베이스 연결
                            Class.forName("com.mysql.cj.jdbc.Driver");
                            con = DriverManager.getConnection("jdbc:mysql://localhost:3306/StoreManagement", "root", "root");

                            // 사용자 정보 확인
                            String sql = "SELECT * FROM User WHERE UserName = ? AND UserEmail = ?";
                            pstmt = con.prepareStatement(sql);
                            pstmt.setString(1, username);
                            pstmt.setString(2, email);
                            rs = pstmt.executeQuery();

                            if (rs.next()) {
                                // 임시 비밀번호 생성
                                String chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
                                Random rnd = new Random();
                                for (int i = 0; i < 8; i++) {
                                    tempPassword += chars.charAt(rnd.nextInt(chars.length()));
                                }

                                // 임시 비밀번호로 데이터베이스 업데이트
                                String updateSql = "UPDATE User SET UserPassword = ? WHERE UserName = ? AND UserEmail = ?";
                                pstmt = con.prepareStatement(updateSql);
                                pstmt.setString(1, tempPassword);
                                pstmt.setString(2, username);
                                pstmt.setString(3, email);
                                pstmt.executeUpdate();

                                // 이메일 설정
                                String host = "smtp.gmail.com";
                                final String senderEmail = "201944099@itc.ac.kr";  // 발신자 이메일 주소
                                final String senderPassword = "rlndbfxsqcskphvm";  // 발신자 이메일 비밀번호

                                Properties props = new Properties();
                                props.put("mail.smtp.host", host);
                                props.put("mail.smtp.port", "587");
                                props.put("mail.smtp.auth", "true");
                                props.put("mail.smtp.starttls.enable", "true");

                                Session session2 = Session.getInstance(props, new javax.mail.Authenticator() {
                                    protected PasswordAuthentication getPasswordAuthentication() {
                                        return new PasswordAuthentication(senderEmail, senderPassword);
                                    }
                                });

                                // 이메일 메시지 구성 및 전송
                                Message message = new MimeMessage(session2);
                                message.setFrom(new InternetAddress(senderEmail));
                                message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(email));
                                message.setSubject("임시 비밀번호 안내");
                                message.setText("임시 비밀번호: " + tempPassword + "\n로그인 후 비밀번호를 변경해주세요.");

                                Transport.send(message);

                                out.println("<p class='text-success'>임시 비밀번호가 이메일로 전송되었습니다.</p>");
                            } else {
                                out.println("<p class='text-danger'>정보가 일치하지 않습니다.</p>");
                            }
                        } catch (Exception e) {
                            e.printStackTrace();
                            out.println("<p class='text-danger'>오류가 발생했습니다. 다시 시도해주세요.</p>");
                        } finally {
                            if (rs != null) rs.close();
                            if (pstmt != null) pstmt.close();
                            if (con != null) con.close();
                        }
                    }
                %>
            </div>
        </div>
    </div>
</body>
</html>

