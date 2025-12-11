<%@ page import ="com.ProductM.model.*" %>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%/*
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
    <title>Error</title>
</head>
<body>
    <h2>An error occurred. Please try again.</h2>
    <a href="index.jsp">Go Back</a>
</body>
</html>
