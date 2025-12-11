/*
 * package com.NEWpayment; import javax.servlet.*; import javax.servlet.http.*;
 * import javax.servlet.annotation.*; import java.io.*; import java.sql.*;
 * import java.util.*; import com.google.gson.Gson;
 * 
 * @WebServlet("/ManagementServlet") public class ManagementServlet extends
 * HttpServlet {
 * 
 * private static final String DB_URL =
 * "jdbc:mysql://localhost:3306/storemanagement"; private static final String
 * DB_USER = "root"; private static final String DB_PASSWORD = "root";
 * 
 * // MySQL 데이터베이스 연결 메서드 private Connection getConnection() throws SQLException
 * { try { Class.forName("com.mysql.cj.jdbc.Driver"); // MySQL 드라이버 로드 } catch
 * (ClassNotFoundException e) { throw new
 * SQLException("MySQL JDBC Driver not found.", e); } return
 * DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD); }
 * 
 * @Override protected void doPost(HttpServletRequest request,
 * HttpServletResponse response) throws IOException {
 * response.setCharacterEncoding("UTF-8");
 * response.setContentType("application/json; charset=UTF-8");
 * 
 * String action = request.getParameter("action"); // 클라이언트에서 보낸 action 파라미터
 * PrintWriter out = response.getWriter();
 * 
 * try (Connection conn = getConnection()) { if (action == null ||
 * action.isEmpty()) { response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
 * out.write("{\"error\": \"Action parameter is missing.\"}"); return; }
 * 
 * switch (action) { case "fetchTables": fetchTables(conn, out); // 테이블 상태 가져오기
 * break; case "fetchOrders": int tableId =
 * Integer.parseInt(request.getParameter("tableId")); if (tableId <= 0) {
 * response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
 * out.write("{\"error\": \"Invalid table ID.\"}"); return; } fetchOrders(conn,
 * tableId, out); // 특정 테이블의 주문 내역 가져오기 break; case "fetchOrderItems": int
 * orderId = Integer.parseInt(request.getParameter("orderId")); if (orderId <=
 * 0) { response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
 * out.write("{\"error\": \"Invalid order ID.\"}"); return; }
 * fetchOrderItems(conn, orderId, out); // 특정 주문의 아이템 가져오기 break; case
 * "processPayment": tableId =
 * Integer.parseInt(request.getParameter("tableId")); if (tableId <= 0) {
 * response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
 * out.write("{\"error\": \"Invalid table ID.\"}"); return; }
 * processPayment(conn, tableId, out); // 결제 처리 break; default:
 * response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
 * out.write("{\"error\": \"Invalid action.\"}"); break; } } catch (SQLException
 * e) { e.printStackTrace();
 * response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
 * out.write("{\"error\": \"Database error: " + e.getMessage() + "\"}"); } catch
 * (NumberFormatException e) {
 * response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
 * out.write("{\"error\": \"Invalid number format: " + e.getMessage() + "\"}");
 * } }
 * 
 * // 1. 테이블 상태 가져오기 private void fetchTables(Connection conn, PrintWriter out)
 * throws SQLException { String query = "SELECT * FROM OrderTable"; //
 * OrderTable의 모든 데이터 가져오기 List<Map<String, Object>> tables = new ArrayList<>();
 * 
 * try (PreparedStatement stmt = conn.prepareStatement(query); ResultSet rs =
 * stmt.executeQuery()) { while (rs.next()) { Map<String, Object> table = new
 * HashMap<>(); table.put("orderTableId", rs.getInt("OrderTableID"));
 * table.put("tableNumber", rs.getString("TableNumber")); table.put("status",
 * rs.getString("Status")); tables.add(table); } }
 * 
 * Gson gson = new Gson(); out.write(gson.toJson(tables)); // JSON 형식으로 반환 }
 * 
 * // 2. 특정 테이블의 주문 내역 가져오기 (OrderDate 필드 제거) private void
 * fetchOrders(Connection conn, int tableId, PrintWriter out) throws
 * SQLException { String orderQuery =
 * "SELECT * FROM Order WHERE OrderTableID = ?";
 * 
 * List<Map<String, Object>> orders = new ArrayList<>();
 * 
 * try (PreparedStatement orderStmt = conn.prepareStatement(orderQuery)) {
 * orderStmt.setInt(1, tableId); try (ResultSet orderRs =
 * orderStmt.executeQuery()) { while (orderRs.next()) { Map<String, Object>
 * order = new HashMap<>(); int orderId = orderRs.getInt("OrderID");
 * 
 * order.put("orderId", orderId); order.put("totalAmount",
 * orderRs.getDouble("TotalAmount")); order.put("orderStatus",
 * orderRs.getString("OrderStatus"));
 * 
 * // 결과 리스트에 추가 orders.add(order); } } }
 * 
 * Gson gson = new Gson(); out.write(gson.toJson(orders)); // JSON 형식으로 반환 }
 * 
 * // // 3. 특정 테이블의 주문 아이템 가져오기 (테이블 ID 기반으로, 동일 상품 합치기) private void
 * fetchOrderItems(Connection conn, int tableId, PrintWriter out) throws
 * SQLException { String query =
 * "SELECT p.ProductName, SUM(oi.Quantity) AS TotalQuantity, SUM(oi.FinalPrice * oi.Quantity) AS TotalPrice "
 * + "FROM OrderItem oi " + "JOIN Product p ON oi.ProductID = p.ProductID " +
 * "JOIN Order o ON oi.OrderID = o.OrderID " + "WHERE o.OrderTableID = ? " +
 * "GROUP BY p.ProductName";
 * 
 * List<Map<String, Object>> items = new ArrayList<>(); try (PreparedStatement
 * stmt = conn.prepareStatement(query)) { stmt.setInt(1, tableId); try
 * (ResultSet rs = stmt.executeQuery()) { while (rs.next()) { Map<String,
 * Object> item = new HashMap<>(); item.put("productName",
 * rs.getString("ProductName")); item.put("quantity",
 * rs.getInt("TotalQuantity")); item.put("totalPrice",
 * rs.getDouble("TotalPrice")); items.add(item); } } }
 * 
 * Gson gson = new Gson(); out.write(gson.toJson(items)); // JSON 형식으로 반환 }
 * 
 * private void processPayment(Connection conn, int tableId, PrintWriter out)
 * throws SQLException { // SQL 쿼리 정의 String updateOrderStatusQuery =
 * "UPDATE Order SET OrderStatus = 'paid' WHERE OrderTableID = ?"; String
 * deleteOrderItemsQuery =
 * "DELETE FROM OrderItem WHERE OrderID IN (SELECT OrderID FROM Order WHERE OrderTableID = ?)"
 * ; String updateTableStatusQuery =
 * "UPDATE OrderTable SET Status = 'Available' WHERE OrderTableID = ?";
 * 
 * try { conn.setAutoCommit(false); // 트랜잭션 시작
 * 
 * // 1. 주문 상태 업데이트 (paid) try (PreparedStatement stmt =
 * conn.prepareStatement(updateOrderStatusQuery)) { stmt.setInt(1, tableId);
 * stmt.executeUpdate(); }
 * 
 * // 2. 주문 아이템 삭제 try (PreparedStatement stmt =
 * conn.prepareStatement(deleteOrderItemsQuery)) { stmt.setInt(1, tableId);
 * stmt.executeUpdate(); }
 * 
 * // 3. 테이블 상태 업데이트 try (PreparedStatement stmt =
 * conn.prepareStatement(updateTableStatusQuery)) { stmt.setInt(1, tableId);
 * stmt.executeUpdate(); }
 * 
 * conn.commit(); // 트랜잭션 커밋 out.write("{\"message\": \"결제가 완료되었습니다.\"}"); }
 * catch (SQLException e) { conn.rollback(); // 트랜잭션 롤백 e.printStackTrace();
 * throw new SQLException("결제 처리 중 오류 발생: " + e.getMessage(), e); } finally {
 * conn.setAutoCommit(true); // 자동 커밋 복원 } }
 * 
 * private void fetchPaidOrders(Connection conn, int tableId, PrintWriter out)
 * throws SQLException { String query =
 * "SELECT * FROM Order WHERE OrderTableID = ? AND OrderStatus = 'paid'";
 * 
 * List<Map<String, Object>> orders = new ArrayList<>(); try (PreparedStatement
 * stmt = conn.prepareStatement(query)) { stmt.setInt(1, tableId); try
 * (ResultSet rs = stmt.executeQuery()) { while (rs.next()) { Map<String,
 * Object> order = new HashMap<>(); order.put("orderId", rs.getInt("OrderID"));
 * order.put("totalAmount", rs.getDouble("TotalAmount")); orders.add(order); } }
 * }
 * 
 * Gson gson = new Gson(); out.write(gson.toJson(orders)); // JSON 형식으로 반환 }
 * private void cancelPayment(Connection conn, int orderId, PrintWriter out)
 * throws SQLException { String updateOrderStatusQuery =
 * "UPDATE Order SET OrderStatus = 'Pending' WHERE OrderID = ?";
 * 
 * try { try (PreparedStatement stmt =
 * conn.prepareStatement(updateOrderStatusQuery)) { stmt.setInt(1, orderId); int
 * rowsUpdated = stmt.executeUpdate(); if (rowsUpdated > 0) {
 * out.write("{\"message\": \"결제가 취소되었습니다.\"}"); } else {
 * out.write("{\"error\": \"결제 취소에 실패했습니다. 주문이 존재하지 않습니다.\"}"); } } } catch
 * (SQLException e) { e.printStackTrace(); // 오류 로그만 남기기 }
 * 
 * }}
 */

package com.NEWpayment;
import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.*;
import java.io.*;
import java.sql.*;
import java.util.*;
import com.google.gson.Gson;

@WebServlet("/ManagementServlet")
public class ManagementServlet extends HttpServlet {

    private static final String DB_URL = "jdbc:mysql://localhost:3306/storemanagement";
    private static final String DB_USER = "root";
    private static final String DB_PASSWORD = "root";

    // MySQL 데이터베이스 연결 메서드
    private Connection getConnection() throws SQLException {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver"); // MySQL 드라이버 로드
        } catch (ClassNotFoundException e) {
            throw new SQLException("MySQL JDBC Driver not found.", e);
        }
        return DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setCharacterEncoding("UTF-8");
        response.setContentType("application/json; charset=UTF-8");
        
        String action = request.getParameter("action"); // 클라이언트에서 보낸 action 파라미터
        PrintWriter out = response.getWriter();

        try (Connection conn = getConnection()) {
            if (action == null || action.isEmpty()) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.write("{\"error\": \"Action parameter is missing.\"}");
                return;
            }

            switch (action) {
                case "fetchTables":
                    fetchTables(conn, out); // 테이블 상태 가져오기
                    break;
                case "fetchOrders":
                    int tableId = Integer.parseInt(request.getParameter("tableId"));
                    if (tableId <= 0) {
                        response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                        out.write("{\"error\": \"Invalid table ID.\"}");
                        return;
                    }
                    fetchOrders(conn, tableId, out); // 특정 테이블의 주문 내역 가져오기
                    break;
                case "fetchOrderItems":
                    int orderId = Integer.parseInt(request.getParameter("orderId"));
                    if (orderId <= 0) {
                        response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                        out.write("{\"error\": \"Invalid order ID.\"}");
                        return;
                    }
                    fetchOrderItems(conn, orderId, out); // 특정 주문의 아이템 가져오기
                    break;
                case "processPayment":
                    tableId = Integer.parseInt(request.getParameter("tableId"));
                    if (tableId <= 0) {
                        response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                        out.write("{\"error\": \"Invalid table ID.\"}");
                        return;
                    }
                    processPayment(conn, tableId, out); // 결제 처리
                    break;
                default:
                    response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                    out.write("{\"error\": \"Invalid action.\"}");
                    break;
            }
        } catch (SQLException e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.write("{\"error\": \"Database error: " + e.getMessage() + "\"}");
        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.write("{\"error\": \"Invalid number format: " + e.getMessage() + "\"}");
        }
    }

    // 1. 테이블 상태 가져오기
    private void fetchTables(Connection conn, PrintWriter out) throws SQLException {
        String query = "SELECT * FROM OrderTable"; // OrderTable의 모든 데이터 가져오기
        List<Map<String, Object>> tables = new ArrayList<>();

        try (PreparedStatement stmt = conn.prepareStatement(query);
             ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> table = new HashMap<>();
                table.put("orderTableId", rs.getInt("OrderTableID"));
                table.put("tableNumber", rs.getString("TableNumber"));
                table.put("status", rs.getString("Status"));
                tables.add(table);
            }
        }

        Gson gson = new Gson();
        out.write(gson.toJson(tables)); // JSON 형식으로 반환
    }

    // 2. 특정 테이블의 주문 내역 가져오기 (OrderDate 필드 제거)
    private void fetchOrders(Connection conn, int tableId, PrintWriter out) throws SQLException {
        String orderQuery = "SELECT * FROM `Order` WHERE OrderTableID = ?";

        List<Map<String, Object>> orders = new ArrayList<>();

        try (PreparedStatement orderStmt = conn.prepareStatement(orderQuery)) {
            orderStmt.setInt(1, tableId);
            try (ResultSet orderRs = orderStmt.executeQuery()) {
                while (orderRs.next()) {
                    Map<String, Object> order = new HashMap<>();
                    int orderId = orderRs.getInt("OrderID");

                    order.put("orderId", orderId);
                    order.put("totalAmount", orderRs.getDouble("TotalAmount"));
                    order.put("orderStatus", orderRs.getString("OrderStatus"));

                    // 결과 리스트에 추가
                    orders.add(order);
                }
            }
        }

        Gson gson = new Gson();
        out.write(gson.toJson(orders)); // JSON 형식으로 반환
    }

 // // 3. 특정 테이블의 주문 아이템 가져오기 (테이블 ID 기반으로, 동일 상품 합치기)
    private void fetchOrderItems(Connection conn, int tableId, PrintWriter out) throws SQLException {
        String query = "SELECT p.ProductName, SUM(oi.Quantity) AS TotalQuantity, SUM(oi.FinalPrice * oi.Quantity) AS TotalPrice " +
                       "FROM orderItem oi " +
                       "JOIN Product p ON oi.ProductID = p.ProductID " +
                       "JOIN `order` o ON oi.OrderID = o.OrderID " +
                       "WHERE o.OrderTableID = ? AND oi.Status = 'Pending' " + // Status 조건 추가
                       "GROUP BY p.ProductName";

        List<Map<String, Object>> items = new ArrayList<>();
        try (PreparedStatement stmt = conn.prepareStatement(query)) {
            stmt.setInt(1, tableId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> item = new HashMap<>();
                    item.put("productName", rs.getString("ProductName"));
                    item.put("quantity", rs.getInt("TotalQuantity"));
                    item.put("totalPrice", rs.getDouble("TotalPrice"));
                    items.add(item);
                }
            }
        }

        Gson gson = new Gson();
        out.write(gson.toJson(items)); // JSON 형식으로 반환
    }

    
    // 4. 결제 처리
    private void processPayment(Connection conn, int tableId, PrintWriter out) throws SQLException {
        // SQL 쿼리 정의
        String fetchOrderQuery = "SELECT OrderID FROM `Order` WHERE OrderTableID = ?";
        String deleteOrderItemsQuery = "DELETE FROM OrderItem WHERE OrderID = ?";
        String deleteOrderQuery = "DELETE FROM `Order` WHERE OrderTableID = ?";
        String updateTableStatusQuery = "UPDATE OrderTable SET Status = 'Available' WHERE OrderTableID = ?";

        try {
            conn.setAutoCommit(false); // 트랜잭션 시작

            // 1. 주문 ID 가져오기
            List<Integer> orderIds = new ArrayList<>();
            try (PreparedStatement stmt = conn.prepareStatement(fetchOrderQuery)) {
                stmt.setInt(1, tableId);
                try (ResultSet rs = stmt.executeQuery()) {
                    while (rs.next()) {
                        orderIds.add(rs.getInt("OrderID"));
                    }
                }
            }

            // 2. 각 주문의 주문 아이템 삭제
            for (int orderId : orderIds) {
                try (PreparedStatement stmt = conn.prepareStatement(deleteOrderItemsQuery)) {
                    stmt.setInt(1, orderId);
                    stmt.executeUpdate();
                }
            }

            // 3. 주문 삭제
            try (PreparedStatement stmt = conn.prepareStatement(deleteOrderQuery)) {
                stmt.setInt(1, tableId);
                stmt.executeUpdate();
            }

            // 4. 테이블 상태 업데이트
            try (PreparedStatement stmt = conn.prepareStatement(updateTableStatusQuery)) {
                stmt.setInt(1, tableId);
                stmt.executeUpdate();
            }

            conn.commit(); // 트랜잭션 커밋
            out.write("{\"message\": \"결제가 완료되었습니다.\"}");
        } catch (SQLException e) {
            conn.rollback(); // 트랜잭션 롤백
            e.printStackTrace();
            throw new SQLException("결제 처리 중 오류 발생: " + e.getMessage(), e);
        } finally {
            conn.setAutoCommit(true); // 자동 커밋 복원
        }
    }
}