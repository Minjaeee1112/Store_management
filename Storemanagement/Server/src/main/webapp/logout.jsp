<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%
    // 세션 무효화 (로그아웃)
    session.invalidate();
	
response.sendRedirect("index.jsp");

%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
</head>
<body>
<script>
    alert("로그아웃 되었습니다.");
    window.location.href = "index.jsp"; // 로그아웃 후 로그인 페이지로 이동
</script>
</body>
</html>