<%@ page import ="com.ProductM.model.*" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%/*
    String userRole = (String) session.getAttribute("userRole");
    String username = (String) session.getAttribute("username");

    if (userRole == null || username == null || !"admin".equals(userRole)) {
        response.sendRedirect("../index.jsp");
        return;
    }*/
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>상품 수정</title>
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
    <style>
        .box-container {
            width: 100%; /* 너비를 100%로 설정 */
            max-width: 1200px; /* 최대 너비 설정으로 가독성 유지 */
            margin: auto;
            padding: 20px;
            border: 2px solid #ddd;
            border-radius: 10px;
            background-color: #f9f9f9;
        }

        .main-title {
            margin-top: 20px;
        }
    </style>
    <script>
        function validateForm() {
            const productPrice = document.getElementById("productPrice").value;
            const productStock = document.getElementById("productStock").value;

            if (productPrice && productPrice <= 0) {
                alert("상품 가격은 0보다 커야 합니다.");
                return false;
            }
            if (productStock && productStock < 0) {
                alert("재고는 0 이상이어야 합니다.");
                return false;
            }
            return true;
        }
    </script>
</head>
<body>
<jsp:include page="${pageContext.request.contextPath}/dashboard.jsp" />
<div class="main-title text-center">
    <br><br><h1>상품 수정</h1>
</div>

<div class="box-container">
    <form action="${pageContext.request.contextPath}/UpdateProductServlet" method="post" enctype="multipart/form-data" onsubmit="return validateForm()">
        <div class="form-group">
            <label for="productId">상품 ID (필수):</label>
            <input type="number" id="productId" name="productId" class="form-control" placeholder="상품 ID 입력" required>
        </div>
        <div class="form-group mt-3">
            <label for="productName">새로운 상품 이름:</label>
            <input type="text" id="productName" name="productName" class="form-control" placeholder="새로운 상품 이름">
        </div>
        <div class="form-group mt-3">
            <label for="productPrice">새로운 가격:</label>
            <input type="number" id="productPrice" name="productPrice" class="form-control" placeholder="새로운 가격 (0 이상)">
        </div>
        <div class="form-group mt-3">
            <label for="productDescription">새로운 설명:</label>
            <textarea id="productDescription" name="productDescription" class="form-control" rows="3" placeholder="새로운 상품 설명"></textarea>
        </div>
        <div class="form-group mt-3">
            <label for="productStock">새로운 재고 수량:</label>
            <input type="number" id="productStock" name="productStock" class="form-control" placeholder="0 이상">
        </div>
        <div class="form-group mt-3">
            <label for="productStatus">상품 상태:</label>
            <select id="productStatus" name="productStatus" class="form-control">
                <option value="">-- 상태 선택 --</option>
                <option value="Available">재고 있음</option>
                <option value="Sold Out">품절</option>
            </select>
        </div>
        <div class="form-group mt-3">
            <label for="productImage">새로운 이미지 업로드:</label>
            <input type="file" id="productImage" name="productImage" class="form-control" accept="image/*">
        </div>
        <div class="text-center mt-4">
            <button type="submit" class="btn btn-primary">수정</button>
        </div>
    </form>
</div>

<div class="box-container mt-5">
    <jsp:include page="product_list.jsp"></jsp:include>
</div>
</body>
</html>
