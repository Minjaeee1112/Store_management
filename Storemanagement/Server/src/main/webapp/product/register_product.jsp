<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
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
    <title>상품 등록</title>
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
        // 파일 크기 검증
        function validateFileSize(input) {
            const file = input.files[0];
            const maxSize = 5 * 1024 * 1024; // 최대 크기: 5MB
            if (file.size > maxSize) {
                alert("이미지 크기는 5MB를 초과할 수 없습니다.");
                input.value = ""; // 입력 필드 초기화
            }
        }
    </script>
</head>
<body>
    <jsp:include page="${pageContext.request.contextPath}/dashboard.jsp" />

    <div class="main-title text-center">
        <br><br><h1>상품 등록</h1>
    </div>

    <div class="box-container">
        <form action="${pageContext.request.contextPath}/RegisterProductServlet" method="post" enctype="multipart/form-data" accept-charset="UTF-8">
            <div class="form-group">
                <label for="productName">상품명:</label>
                <input type="text" id="productName" name="productName" class="form-control" placeholder="상품명 입력" required>
            </div>
            <div class="form-group">
                <label for="productPrice">가격:</label>
                <input type="number" id="productPrice" name="productPrice" class="form-control" placeholder="가격 입력" min="0" step="0.01" required>
            </div>
            <div class="form-group">
                <label for="productDescription">상품 설명:</label>
                <textarea id="productDescription" name="productDescription" class="form-control" placeholder="상품 설명 입력" rows="3"></textarea>
            </div>
            <div class="form-group">
                <label for="productStock">수량:</label>
                <input type="number" id="productStock" name="productStock" class="form-control" placeholder="수량 입력" min="0" required>
            </div>
            <div class="form-group">
                <label for="productStatus">상태:</label>
                <select id="productStatus" name="productStatus" class="form-control" required>
                    <option value="">상태 선택</option>
                    <option value="Available">Available</option>
                    <option value="Sold Out">Sold Out</option>
                </select>
            </div>
            <div class="form-group">
                <label for="productCategory">카테고리:</label>
                <select id="productCategory" name="productCategory" class="form-control" required>
                    <option value="">카테고리 선택</option>
                    <option value="음식">음식</option>
                    <option value="음료수">음료수</option>
                    <option value="기타">기타</option>
                </select>
            </div>
            <div class="form-group">
                <label for="productImage">상품 이미지:</label>
                <input type="file" id="productImage" name="productImage" class="form-control" accept="image/*" onchange="validateFileSize(this)" required>
            </div>
            <div class="form-buttons">
                <button type="submit" class="btn btn-primary">등록하기</button>
            </div>
        </form>
    </div>

    <div class="box-container mt-5">
        <jsp:include page="product_list.jsp"></jsp:include>
    </div>
</body>
</html>
