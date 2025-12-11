<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.Connection, java.sql.DriverManager, java.sql.ResultSet, java.sql.Statement, java.sql.PreparedStatement" %>
<%@ page import="java.util.ArrayList, java.util.List" %>
<%@ page import="com.example.model.Product" %>
<%@ page import="com.ProductM.model.*" %>
<%
    //String userRole = (String) session.getAttribute("userRole");
    //String username = (String) session.getAttribute("username");

    //if (userRole == null || username == null || !"admin".equals(userRole)) {
    //    response.sendRedirect("../index.jsp");
    //    return;
    //}

    // 수량 업데이트 로직
    if (request.getParameter("updateStock") != null) {
        int productId = Integer.parseInt(request.getParameter("productId"));
        int newStock = Integer.parseInt(request.getParameter("newStock"));
        String newStatus = (newStock == 0) ? "Sold Out" : "Available";

        try (Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/StoreManagement", "root", "root");
             PreparedStatement pstmt = con.prepareStatement("UPDATE Product SET ProductStock = ?, ProductStatus = ? WHERE ProductID = ?")) {
            pstmt.setInt(1, newStock);
            pstmt.setString(2, newStatus);
            pstmt.setInt(3, productId);
            pstmt.executeUpdate();
            response.sendRedirect("register_product.jsp");
        } catch (Exception e) {
            e.printStackTrace();
            out.println("<p>데이터베이스 업데이트 중 오류가 발생했습니다: " + e.getMessage() + "</p>");
        }
    }

    // 상품 리스트 로드
    List<Product> productList = new ArrayList<>();
    try (Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/StoreManagement", "root", "root");
         Statement stmt = con.createStatement();
         ResultSet rs = stmt.executeQuery("SELECT * FROM Product")) {

        while (rs.next()) {
            int id = rs.getInt("ProductID");
            String name = rs.getString("ProductName");
            double price = rs.getDouble("ProductPrice");
            String description = rs.getString("ProductDescription");
            int stock = rs.getInt("ProductStock");
            String status = rs.getString("ProductStatus");
            String category = rs.getString("ProductCategory");
            byte[] picture = rs.getBytes("ProductPicture");

            Product product = new Product(id, name, price, description, stock, status, category, picture);
            productList.add(product);
        }
    } catch (Exception e) {
        e.printStackTrace();
    }
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>상품 목록</title>
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
    <style>
        .center-title {
            text-align: center; /* 가운데 정렬 */
            font-weight: bold;
            margin-bottom: 20px;
        }
    </style>
    <script>
        // 수량 값 검증
        function validateStock(input) {
            const value = parseInt(input.value, 10);
            if (isNaN(value) || value < 0) {
                alert("수량은 0 이상이어야 합니다.");
                input.value = ""; // 잘못된 입력 초기화
                return false;
            }
            return true;
        }
    </script>
</head>
<body>
    <div class="container">
        <h2 class="center-title">현재 상품 데이터베이스 상태</h2> <!-- 가운데 정렬 -->
        <%
            if (productList.isEmpty()) {
        %>
            <p>상품이 없습니다.</p>
        <%
            } else {
        %>
            <table class="table table-bordered">
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>이름</th>
                        <th>가격</th>
                        <th>설명</th>
                        <th>재고</th>
                        <th>상태</th>
                        <th>카테고리</th>
                        <th>이미지</th>
                        <th>수량 업데이트</th>
                        <th>삭제</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                        for (Product product : productList) {
                    %>
                    <tr>
                        <td><%= product.getId() %></td>
                        <td><%= product.getName() %></td>
                        <td><%= product.getPrice() %></td>
                        <td><%= product.getDescription() %></td>
                        <td><%= product.getStock() %></td>
                        <td><%= product.getStatus() %></td>
                        <td><%= product.getCategory() %></td>
                        <td>
                            <% 
                                if (product.getPicture() != null) {
                                    String base64Image = java.util.Base64.getEncoder().encodeToString(product.getPicture());
                            %>
                                <img src="data:image/jpeg;base64,<%= base64Image %>" alt="Product Image" style="width: 100px; height: auto;">
                            <% 
                                } else {
                            %>
                                없음
                            <% 
                                } 
                            %>
                        </td>
                        <td>
                            <form method="post" action="product_list.jsp" onsubmit="return validateStock(this.newStock);">
                                <input type="hidden" name="productId" value="<%= product.getId() %>">
                                <input type="number" name="newStock" value="<%= product.getStock() %>" min="0" style="width: 70px;" required>
                                <button type="submit" name="updateStock" class="btn btn-primary btn-sm">수정</button>
                            </form>
                        </td>
                        <td>
			                <form method="post" action="${pageContext.request.contextPath}/DeleteProductServlet"> <!-- 삭제 기능 추가 -->
			                    <input type="hidden" name="productId" value="<%= product.getId() %>">
			                    <button type="submit" class="btn btn-danger btn-sm">삭제</button>
			                </form>
		            	</td>
                    </tr>
                    <%
                        }
                    %>
                </tbody>
            </table>
        <%
            }
        %>
    </div>
</body>
</html>
