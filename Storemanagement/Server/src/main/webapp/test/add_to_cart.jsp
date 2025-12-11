<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, java.sql.*" %>

<%
    int orderTableId = Integer.parseInt(request.getParameter("orderTableId"));
    int productId = Integer.parseInt(request.getParameter("productId"));
    int quantity = Integer.parseInt(request.getParameter("quantity"));

    String sessionKey = "cart_" + orderTableId;
    List<Map<String, Object>> cart = (List<Map<String, Object>>) session.getAttribute(sessionKey);

    if (cart == null) {
        cart = new ArrayList<>();
        session.setAttribute(sessionKey, cart);
    }

    // 상품 정보 DB에서 가져오기
    Connection con = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        con = DriverManager.getConnection("jdbc:mysql://localhost:3306/storemanagement", "root", "root");

        String sql = "SELECT * FROM Product WHERE ProductID = ?";
        pstmt = con.prepareStatement(sql);
        pstmt.setInt(1, productId);
        rs = pstmt.executeQuery();

        if (rs.next()) {
            String productName = rs.getString("ProductName");
            double productPrice = rs.getDouble("ProductPrice");
			
            System.out.println("productName : " + productName);
            System.out.println("productName : " + productPrice);
            
            Map<String, Object> cartItem = new HashMap<>();
            cartItem.put("productId", productId);
            cartItem.put("productName", productName);
            cartItem.put("productPrice", productPrice);
            cartItem.put("quantity", quantity);

            boolean found = false;
            for (Map<String, Object> item : cart) {
                if ((int) item.get("productId") == productId) {
                    int currentQuantity = (int) item.get("quantity");
                    item.put("quantity", currentQuantity + quantity);
                    found = true;
                    break;
                }
            }
            if (!found) {
                cart.add(cartItem);
            }
            out.print("<div class='alert alert-success'>장바구니에 '" + productName + "'가 추가되었습니다.</div>");
        } else {
            out.print("<div class='alert alert-danger'>상품을 찾을 수 없습니다.</div>");
        }
    } catch (Exception e) {
        e.printStackTrace();
        out.print("<div class='alert alert-danger'>오류가 발생했습니다: " + e.getMessage() + "</div>");
    } finally {
        if (rs != null) rs.close();
        if (pstmt != null) pstmt.close();
        if (con != null) con.close();
    }
%>
