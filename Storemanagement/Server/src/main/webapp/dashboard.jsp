<%-- <%@ page import="java.sql.*, java.util.*" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<%
    // 세션에서 사용자 역할과 사용자 이름을 확인
    String userRole = (String) session.getAttribute("userRole");
    String username = (String) session.getAttribute("username");

    // 세션에 저장된 정보가 없거나 권한이 admin이 아닌 경우
    if (userRole == null || username == null || !"admin".equals(userRole)) {
        // 로그인 페이지로 리다이렉트
        response.sendRedirect("index.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>관리 대시보드</title>
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
    <style>
        body, html {
            margin: 0;
            padding: 0;
            height: 100%;
            font-family: Arial, sans-serif;
        }

        .container {
            display: flex;
            min-height: 100vh;
        }
		 a {
            font-size: 30px;
        }
        .sidebar {
            width: 220px;
            background-color: #2c3e50;
            height: 100vh;
            padding: 0;
            box-sizing: border-box;
            position: fixed;
            top: 0;
            left: 0;
            transition: width 0.5s ease;
        }

        .sidebar ul {
            list-style-type: none;
            padding: 0;
            margin: 0;
            font-size: 28px;
        }

        .sidebar ul > li {
            margin-bottom: 10px; /* 상위 메뉴 간의 간격 설정 */
        }

        .sidebar ul ul li {
            padding: 10px 15px; /* 하위 메뉴 간격 설정 */
            margin-bottom: 5px; /* 하위 li 간격 */
        }

        .sidebar ul li a {
            color: white;
            text-decoration: none;
            display: block;
            padding: 10px 15px; /* 메뉴 항목의 안쪽 여백 */
        }

        .sidebar ul li a:hover {
            background-color: #34495e;
        }

        /* 기본적으로 하위 메뉴 숨기기 */
        .sidebar ul ul {
            max-height: 0; /* 처음에는 높이를 0으로 설정 */
            overflow: hidden; /* 넘치는 부분 숨김 */
            transition: max-height 0.5s ease; /* 높이가 변경될 때 애니메이션 적용 */
        }

        /* 활성화된 메뉴 */
        .sidebar ul ul.active {
            max-height: 500px; /* 임시 최대 높이 설정 */
        }

        .content {
            margin-left: 220px;
            padding: 20px;
            background-color: #f8f9fa;
            width: calc(100% - 220px);
            box-sizing: border-box;
            transition: margin-left 0.5s ease;
        }
        /* add_table.jsp에만 적용되는 스타일 */
        <% if ("table".equals(request.getParameter("page"))) { %>
        .content h2 {
            font-size: 24px;
            font-weight: bold;
            color: #333;
        }
        /* add_table.jsp의 테이블 스타일 */
        .content .table {
            width: 100%;
            background-color: #fff;
            border: 1px solid #ddd;
        }
        <% } %>
    </style>

    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script>
        $(document).ready(function() {
            $(".sidebar ul > li > a").on("click", function(event) {
                var submenu = $(this).next("ul");

                // 하위 메뉴가 있으면 슬라이드 동작 실행
                if (submenu.length > 0) {
                    event.preventDefault(); // 하위 메뉴가 있을 때만 기본 동작 방지
                    
                    // 현재 메뉴를 활성화하고, 나머지는 비활성화
                    if (submenu.hasClass("active")) {
                        submenu.removeClass("active").css("max-height", "0"); // 높이 0으로 슬라이드 업
                    } else {
                        $(".sidebar ul ul.active").removeClass("active").css("max-height", "0"); // 다른 활성화된 메뉴 닫기
                        submenu.addClass("active").css("max-height", submenu.prop("scrollHeight") + "px"); // 실제 높이로 슬라이드 다운
                    }
                }
            });
        });
    </script>
</head>
<body>
<div class="container">
    <div class="sidebar">
        <ul>
            <li><a href="#">상품관리</a>
                <ul>
                    <li><a href="dashboard.jsp?page=register_product">상품 등록</a></li>
                    <li><a href="dashboard.jsp?page=update_product">상품 수정</a></li>
                    <li><a href="dashboard.jsp?page=delete_product">상품 삭제</a></li>
                    <li><a href="dashboard.jsp?page=product_list">상품 목록</a></li>
                </ul>
            </li>
            <li><a href="#">결제관리</a>
                <ul>
                	<li><a href="dashboard.jsp?page=table">테이블 관리</a></li>
                    <li><a href="dashboard.jsp?page=payment">결제[legacy] 작동안함</a></li>
                    <li><a href="dashboard.jsp?page=cancel_payment">결제 취소[legacy] 작동안함</a></li>
                </ul>
            </li>
            <li><a href="#">매출관리</a>
                <ul>
                    <li><a href="dashboard.jsp?page=income_Statement">손익계산서</a></li>
                    <li><a href="dashboard.jsp?page=IOHistory">입출금 기록</a></li>
                </ul>
            </li>
            <li><a href="dashboard.jsp?page=change_password">비밀번호 변경</a></li>
            <li><a href="dashboard.jsp?page=logout">로그아웃</a></li>
        </ul>
    </div>
    <div class="content">
        <%
    String currentPage = request.getParameter("page");
    String pagePath = "";
    
    if (currentPage != null) {
        switch (currentPage) {
            case "register_product":
                pagePath = "product/register_product.jsp";
                break;
            case "update_product":
                pagePath = "product/update_product.jsp";
                break;
            case "delete_product":
                pagePath = "product/delete_product.jsp";
                break;
            case "product_list":
                pagePath = "product/product_list.jsp";
                break;
            case "payment":
                pagePath = "payment/payment.jsp";
                break;
            case "cancel_payment":
                pagePath = "payment/cancel_payment.jsp";
                break;
            case "income_Statement":
                pagePath = "income_Statement.jsp";
                break;
            case "IOHistory":
                pagePath = "IOHistory.jsp";
                break;
            case "change_password":
                pagePath = "change_password.jsp";
                break;
            case "logout":
                pagePath = "logout.jsp";
                break;
            case "table":
                pagePath = "table/add_table.jsp";
                break;
            default:
                pagePath = ""; // 기본 페이지 처리
                break;
        }
    }
    
    if (!pagePath.isEmpty()) {
        %><jsp:include page="<%= pagePath %>" /><%
    }
%>

    </div>
</div>
</body>
</html> 
 --%>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>관리 대시보드</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css">
    <style>
        body, html {
            margin: 0;
            padding: 0;
            height: 100%;
            font-family: Arial, sans-serif;
        }
        .dashboard-sidebar {
            width: 220px;
            background-color: #2c3e50;
            height: 100vh;
            padding: 0;
            position: fixed;
            top: 50px; /* 헤더 높이만큼 아래로 */
            left: 0;
            z-index: 1000;
        }
        .dashboard-sidebar ul {
            list-style-type: none;
            padding: 0;
            margin: 0;
        }
        .dashboard-sidebar ul li a {
            color: white;
            text-decoration: none;
            display: block;
            padding: 10px 15px;
            font-size: 18px;
        }
        .dashboard-sidebar ul li a:hover {
            background-color: #34495e;
        }
        /* 하위 메뉴 숨기기 */
        .dashboard-sidebar ul ul {
            max-height: 0;
            overflow: hidden;
            transition: max-height 0.5s ease;
        }
        /* 활성화된 메뉴 */
        .dashboard-sidebar ul ul.active {
            max-height: 500px;
        }
        .dashboard-header {
            height: 50px;
            background-color: #2c3e50;
            color: white;
            position: fixed;
            width: 100%;
            top: 0;
            left: 0;
            display: flex;
            align-items: center;
            padding: 0 15px;
            z-index: 1100;
        }
        .dashboard-header .toggle-btn {
            margin-right: 15px;
            cursor: pointer;
            font-size: 20px;
        }
        .dashboard-content {
            margin-left: 220px;
            margin-top: 50px; /* 헤더 높이 */
            padding: 20px;
        }
        /* 사이드바 숨기기 상태 */
        .dashboard-sidebar.hidden {
            transform: translateX(-220px);
            transition: transform 0.3s ease;
        }
        .dashboard-content.expanded {
            margin-left: 0;
            transition: margin-left 0.3s ease;
        }
        /* 오버레이 추가 스타일 */
        .overlay {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0, 0, 0, 0.3); /* 반투명 검은색 */
            z-index: 900; /* 사이드바와 컨텐츠 사이 */
            display: none; /* 1207 수정 */
        }
    </style>
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script>
 // 사이드바 상태에 따라 오버레이 표시/숨기기
    
        $(document).ready(function () {
        	$(".dashboard-sidebar").addClass("hidden"); // 사이드바를 숨긴 상태로 초기화 1207 수정
            $(".overlay").hide(); // 오버레이를 숨김 상태로 초기화  1207 수정
        	
            $(".toggle-btn").on("click", function () {           	
            	
                $(".dashboard-sidebar").toggleClass("hidden");
                $(".dashboard-content").toggleClass("expanded");
                
             // 사이드바 상태에 따라 오버레이 표시/숨기기
                 if ($(".dashboard-sidebar").hasClass("hidden")) {
                    $(".overlay").fadeOut();
                } else {
                    $(".overlay").fadeIn();
                } 
            });

            $(".dashboard-sidebar ul > li > a").on("click", function (event) {
                var submenu = $(this).next("ul");
                if (submenu.length > 0) {
                    event.preventDefault();
                    if (submenu.hasClass("active")) {
                        submenu.removeClass("active").css("max-height", "0");
                    } else {
                        $(".dashboard-sidebar ul ul.active").removeClass("active").css("max-height", "0");
                        submenu.addClass("active").css("max-height", submenu.prop("scrollHeight") + "px");
                    }
                }
            });
        });
    </script>
</head>
<body>

<div class="overlay" style="display: none"></div>

<div class="dashboard-header">
    <span class="toggle-btn">&#9776;</span> <!-- 햄버거 메뉴 -->
    <span>관리 대시보드</span>
</div>
<div class="dashboard-sidebar">
    <ul>
        <li><a href="#">상품관리</a>
            <ul>
                <li><a href="${pageContext.request.contextPath}/product/register_product.jsp">● 상품 등록</a></li>
                <li><a href="${pageContext.request.contextPath}/product/update_product.jsp">● 상품 수정</a></li>
                <%-- 사용안함<li><a href="${pageContext.request.contextPath}/product/delete_product.jsp">상품 삭제</a></li>
                <li><a href="${pageContext.request.contextPath}/product/product_list.jsp">상품 목록</a></li>
             --%>
            </ul>
        </li>
        <li><a href="#">결제관리</a>
            <ul>
                <li><a href="${pageContext.request.contextPath}/table/add_table.jsp">● 테이블 관리</a></li>
                <li><a href="${pageContext.request.contextPath}/payment/payment_management.jsp">● 결제 관리</a></li>
                <%-- <li><a href="${pageContext.request.contextPath}/payment(legacy)/payment.jsp">legacy결제</a></li>
                <li><a href="${pageContext.request.contextPath}/payment(legacy)/cancel_payment.jsp">legacy결제 취소</a></li>
             	--%>
             </ul>
        </li>
        <li><a href="#">매출관리</a>
            <ul>
                <li><a href="${pageContext.request.contextPath}/income_Statement.jsp">● 손익계산서</a></li>
                <li><a href="${pageContext.request.contextPath}/IOHistory.jsp">● 입출금 기록</a></li>
            </ul>
        </li>
        <li><a href="${pageContext.request.contextPath}/change_password.jsp">비밀번호 변경</a></li>
        <li><a href="${pageContext.request.contextPath}/logout.jsp">로그아웃</a></li>
    </ul>
</div>
</body>
</html>
