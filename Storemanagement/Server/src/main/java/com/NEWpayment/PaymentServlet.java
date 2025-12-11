package com.NEWpayment;

import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.*;
import java.io.*;
import java.sql.*;

@WebServlet("/PaymentServlet")
public class PaymentServlet extends HttpServlet {

    private static final String DB_URL = "jdbc:mysql://localhost:3306/storemanagement";
    private static final String DB_USER = "root";
    private static final String DB_PASSWORD = "root";

    private Connection getConnection() throws SQLException {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new SQLException("MySQL JDBC Driver not found.", e);
        }
        return DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setCharacterEncoding("UTF-8");
        response.setContentType("application/json; charset=UTF-8");

        String action = request.getParameter("action");
        PrintWriter out = response.getWriter();

        try (Connection conn = getConnection()) {
            if (action == null || action.isEmpty()) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.write("{\"error\": \"Action parameter is missing.\"}");
                return;
            }

            switch (action) {
                case "processPayment":
                    int tableId = Integer.parseInt(request.getParameter("tableId"));
                    double paymentAmount = Double.parseDouble(request.getParameter("paymentAmount"));
                    String paymentMethod = request.getParameter("paymentMethod");
                    processPayment(conn, tableId, paymentAmount, paymentMethod, out);
                    break;
                case "cancelPayment":
                    int paymentId = Integer.parseInt(request.getParameter("paymentId"));
                    cancelPayment(conn, paymentId, out);
                    break;
                case "fetchPaymentId":
                    tableId = Integer.parseInt(request.getParameter("tableId"));
                    fetchPaymentId(conn, tableId, out);
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

    private void processPayment(Connection conn, int tableId, double paymentAmount, String paymentMethod, PrintWriter out) throws SQLException {
        System.out.println("Processing payment for Table ID: " + tableId + ", Amount: " + paymentAmount + ", Method: " + paymentMethod);
        if (paymentMethod == null || paymentMethod.isEmpty()) {
            out.write("{\"error\": \"Payment method is missing.\"}");
            return;
        }

        String insertPaymentQuery = "INSERT INTO Payment (PaymentDate, PaymentAmount, OrderID, PaymentMethod, PaymentStatus) VALUES (NOW(), ?, ?, ?, 'Paid')";
        String fetchOrderQuery = "SELECT OrderID FROM `Order` WHERE OrderTableID = ? AND OrderStatus = 'Pending'";
        String updateOrderStatusQuery = "UPDATE `Order` SET OrderStatus = 'Paid' WHERE OrderID = ?";
        String updateOrderItemsQuery = "UPDATE orderitem SET Status = 'Paid' WHERE OrderID = ?";

        try {
            conn.setAutoCommit(false);

            try (PreparedStatement fetchStmt = conn.prepareStatement(fetchOrderQuery)) {
                fetchStmt.setInt(1, tableId);
                try (ResultSet rs = fetchStmt.executeQuery()) {
                    while (rs.next()) {
                        int orderId = rs.getInt("OrderID");

                        try (PreparedStatement updateOrderStmt = conn.prepareStatement(updateOrderStatusQuery)) {
                            updateOrderStmt.setInt(1, orderId);
                            updateOrderStmt.executeUpdate();
                        }

                        try (PreparedStatement updateOrderItemsStmt = conn.prepareStatement(updateOrderItemsQuery)) {
                            updateOrderItemsStmt.setInt(1, orderId);
                            updateOrderItemsStmt.executeUpdate();
                        }

                        try (PreparedStatement insertStmt = conn.prepareStatement(insertPaymentQuery)) {
                            insertStmt.setDouble(1, paymentAmount);
                            insertStmt.setInt(2, orderId);
                            insertStmt.setString(3, paymentMethod);
                            insertStmt.executeUpdate();
                        }
                    }
                }
            }

            conn.commit();
            out.write("{\"message\": \"결제가 성공적으로 처리되었습니다.\"}");
        } catch (SQLException e) {
            conn.rollback();
            throw new SQLException("결제 처리 중 오류 발생: " + e.getMessage(), e);
        } finally {
            conn.setAutoCommit(true);
        }
    }

	/*
	 * private void cancelPayment(Connection conn, int paymentId, PrintWriter out)
	 * throws SQLException { String fetchPaymentQuery =
	 * "SELECT OrderID FROM Payment WHERE PaymentID = ?"; String
	 * restoreOrderStatusQuery =
	 * "UPDATE `Order` SET OrderStatus = 'Pending' WHERE OrderID = ?"; String
	 * restoreOrderItemsStatusQuery =
	 * "UPDATE orderitem SET Status = 'Pending' WHERE OrderID = ?"; String
	 * deletePaymentQuery = "DELETE FROM Payment WHERE PaymentID = ?";
	 * 
	 * try { conn.setAutoCommit(false);
	 * 
	 * int orderId = 0; try (PreparedStatement fetchStmt =
	 * conn.prepareStatement(fetchPaymentQuery)) { fetchStmt.setInt(1, paymentId);
	 * try (ResultSet rs = fetchStmt.executeQuery()) { if (rs.next()) { orderId =
	 * rs.getInt("OrderID"); } else { throw new
	 * SQLException("No payment record found for PaymentID: " + paymentId); } } }
	 * 
	 * // Restore Order Status to 'Pending' try (PreparedStatement
	 * restoreOrderStatusStmt = conn.prepareStatement(restoreOrderStatusQuery)) {
	 * restoreOrderStatusStmt.setInt(1, orderId);
	 * restoreOrderStatusStmt.executeUpdate(); }
	 * 
	 * // Restore OrderItem Status to 'Pending' try (PreparedStatement
	 * restoreOrderItemsStmt = conn.prepareStatement(restoreOrderItemsStatusQuery))
	 * { restoreOrderItemsStmt.setInt(1, orderId);
	 * restoreOrderItemsStmt.executeUpdate(); }
	 * 
	 * // Delete Payment Record try (PreparedStatement deletePaymentStmt =
	 * conn.prepareStatement(deletePaymentQuery)) { deletePaymentStmt.setInt(1,
	 * paymentId); deletePaymentStmt.executeUpdate(); }
	 * 
	 * conn.commit(); out.
	 * write("{\"message\": \"Payment canceled and data restored successfully.\"}");
	 * } catch (SQLException e) { conn.rollback(); throw new
	 * SQLException("Error canceling payment: " + e.getMessage(), e); } finally {
	 * conn.setAutoCommit(true); } }
	 */
    private void cancelPayment(Connection conn, int paymentId, PrintWriter out) throws SQLException {
        String fetchPaymentQuery = "SELECT OrderID FROM Payment WHERE PaymentID = ?";
        String updatePaymentStatusQuery = "UPDATE Payment SET PaymentStatus = 'Cancel' WHERE PaymentID = ?";
        String restoreOrderStatusQuery = "UPDATE `Order` SET OrderStatus = 'Pending' WHERE OrderID = ?";

        try {
            conn.setAutoCommit(false);

            int orderId = 0;
            try (PreparedStatement fetchStmt = conn.prepareStatement(fetchPaymentQuery)) {
                fetchStmt.setInt(1, paymentId);
                try (ResultSet rs = fetchStmt.executeQuery()) {
                    if (rs.next()) {
                        orderId = rs.getInt("OrderID");
                    } else {
                        throw new SQLException("No payment record found for PaymentID: " + paymentId);
                    }
                }
            }

            // Update Payment Status to 'Cancel'
            try (PreparedStatement updatePaymentStmt = conn.prepareStatement(updatePaymentStatusQuery)) {
                updatePaymentStmt.setInt(1, paymentId);
                updatePaymentStmt.executeUpdate();
            }

            // Restore Order Status to 'Pending'
            try (PreparedStatement restoreOrderStatusStmt = conn.prepareStatement(restoreOrderStatusQuery)) {
                restoreOrderStatusStmt.setInt(1, orderId);
                restoreOrderStatusStmt.executeUpdate();
            }

            conn.commit();
            out.write("{\"message\": \"Payment canceled and status updated to 'Cancel'.\"}");
        } catch (SQLException e) {
            conn.rollback();
            throw new SQLException("Error canceling payment: " + e.getMessage(), e);
        } finally {
            conn.setAutoCommit(true);
        }
    }


    private void fetchPaymentId(Connection conn, int tableId, PrintWriter out) throws SQLException {
        String query = "SELECT PaymentID FROM Payment WHERE OrderID IN (SELECT OrderID FROM `Order` WHERE OrderTableID = ?) ORDER BY PaymentDate DESC LIMIT 1";

        try (PreparedStatement stmt = conn.prepareStatement(query)) {
            stmt.setInt(1, tableId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    int paymentId = rs.getInt("PaymentID");
                    out.write("{\"paymentId\": " + paymentId + "}");
                } else {
                    out.write("{\"paymentId\": null}");
                }
            }
        }
    }
}





