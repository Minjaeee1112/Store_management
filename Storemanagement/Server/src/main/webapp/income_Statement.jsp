<%@page import="java.sql.*"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%
    // 세션 확인
    //String userRole = (String) session.getAttribute("userRole");
    //String username = (String) session.getAttribute("username");
	/*
    if (userRole == null || username == null || !"admin".equals(userRole)) {
        response.sendRedirect("index.jsp");
        return;
    }*/
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>손익 계산서</title>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    
</head>
<body>
    <!-- 대시보드 메뉴 포함 -->
    <header>
        <jsp:include page="${pageContext.request.contextPath}/dashboard.jsp" />
    </header>

    <main>
        <h1 class="text-center">손익 계산서</h1>

        

        <!-- 차트 영역 -->
        <div class="chart-container">
            <div id="barChartContainer">
                <jsp:include page="chart/profit_chart.jsp" />
            </div>
            <div id="pieChartContainer">
                <jsp:include page="chart/pie_chart.jsp" />
            </div>
        </div>
    </main>

    
</body>
</html>
