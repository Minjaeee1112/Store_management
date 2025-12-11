<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*" %>

<%
    String action = request.getParameter("action");
    int orderTableId = Integer.parseInt(request.getParameter("orderTableId"));

    String sessionKey = "cart_" + orderTableId;

    // 세션에서 해당 테이블의 장바구니 가져오기
    List<Map<String, Object>> cart = (List<Map<String, Object>>) session.getAttribute(sessionKey);

    // 장바구니가 null일 경우 새 리스트로 초기화
    if (cart == null) {
        cart = new ArrayList<>();
        session.setAttribute(sessionKey, cart);
    }
    //장바구니 삭제 처리
    if ("remove".equals(action)) {
        int productId = Integer.parseInt(request.getParameter("productId"));
        
        // 장바구니에서 해당 상품을 제거
        cart.removeIf(item -> (int) item.get("productId") == productId);
        
        // 세션에 수정된 장바구니 저장
        session.setAttribute(sessionKey, cart);

        out.print("<div class='alert alert-success'>상품이 장바구니에서 제거되었습니다.</div>");
    }
    // 주문 처리
    if ("checkout".equals(action)) {
        Connection con = null;
        PreparedStatement pstmt = null;
        PreparedStatement productStmt = null;

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            con = DriverManager.getConnection("jdbc:mysql://localhost:3306/StoreManagement", "root", "root");

            // 주문 테이블에 주문 기록 추가
            String insertOrderSql = "INSERT INTO `Order` (OrderTableID, OrderDate, TotalAmount, OrderStatus) VALUES (?, NOW(), ?, 'Pending')";
            pstmt = con.prepareStatement(insertOrderSql, Statement.RETURN_GENERATED_KEYS);

            double totalAmount = 0;
            for (Map<String, Object> item : cart) {
                int productId = (int) item.get("productId");
                int quantity = (int) item.get("quantity");

                // Product 테이블에서 가격 가져오기
                String getProductPriceSql = "SELECT ProductPrice FROM Product WHERE ProductID = ?";
                productStmt = con.prepareStatement(getProductPriceSql);
                productStmt.setInt(1, productId);
                ResultSet rs = productStmt.executeQuery();

                if (rs.next()) {
                    double productPrice = rs.getDouble("ProductPrice");
                    totalAmount += productPrice * quantity;

                    // 장바구니 항목에 가격 추가
                    item.put("productPrice", productPrice); // 장바구니에도 최신 가격 정보 업데이트
                }
                rs.close();
            }

            pstmt.setInt(1, orderTableId);
            pstmt.setDouble(2, totalAmount);
            pstmt.executeUpdate();

            ResultSet generatedKeys = pstmt.getGeneratedKeys();
            int orderId = -1;
            if (generatedKeys.next()) {
                orderId = generatedKeys.getInt(1); // 생성된 OrderID
            }
            generatedKeys.close();
            pstmt.close();

            // 주문 아이템 테이블에 개별 상품 추가
            String insertOrderItemSql = "INSERT INTO orderItem (OrderID, ProductID, Quantity, FinalPrice) VALUES (?, ?, ?, ?)";
            pstmt = con.prepareStatement(insertOrderItemSql);

            for (Map<String, Object> item : cart) {
                int productId = (int) item.get("productId");
                double finalPrice = (double) item.get("productPrice");
                int quantity = (int) item.get("quantity");

                pstmt.setInt(1, orderId);
                pstmt.setInt(2, productId);
                pstmt.setInt(3, quantity);
                pstmt.setDouble(4, finalPrice);
                pstmt.addBatch();
            }

            pstmt.executeBatch();
            out.print("<div class='alert alert-success'>주문이 성공적으로 처리되었습니다.</div>");

            // 주문 후 장바구니 비우기
            cart.clear();
            session.removeAttribute(sessionKey); // 세션에서 해당 테이블의 장바구니 제거
        } catch (Exception e) {
            e.printStackTrace();
            out.print("<div class='alert alert-danger'>오류가 발생했습니다: " + e.getMessage() + "</div>");
        } finally {
            try {
                if (pstmt != null) pstmt.close();
                if (productStmt != null) productStmt.close();
                if (con != null) con.close();
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }
%>
