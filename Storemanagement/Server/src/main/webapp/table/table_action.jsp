<%-- <%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@page import="com.google.zxing.BarcodeFormat"%>
<%@page import="com.google.zxing.qrcode.QRCodeWriter"%>
<%@page import="com.google.zxing.common.BitMatrix"%>
<%@page import="com.google.zxing.client.j2se.MatrixToImageWriter"%>
<%@page import="java.io.OutputStream"%>

<%
    String action = request.getParameter("action");
    Connection con = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        con = DriverManager.getConnection("jdbc:mysql://localhost:3306/StoreManagement", "root", "root");

        if ("load".equals(action)) {
            String loadSql = "SELECT * FROM OrderTable";
            pstmt = con.prepareStatement(loadSql);
            rs = pstmt.executeQuery();

            while (rs.next()) {
                int orderTableId = rs.getInt("OrderTableID");
                String tableNumber = rs.getString("TableNumber");
                int capacity = rs.getInt("Capacity");
                String status = rs.getString("Status");

                out.println("<tr>");
                out.println("<td>" + tableNumber + "</td>");
                out.println("<td>" + capacity + "</td>");
                
                out.println("<td>" + (status.equals("Available") ? "사용 가능" : "사용 중지") + "</td>");
                out.println("<td>");
                if ("Available".equalsIgnoreCase(status)) {
                    out.println("<button onclick=\"window.open('table_action.jsp?action=generateQR&orderTableId=" + orderTableId + "')\" class='btn btn-secondary btn-sm ms-2'>QR 코드 생성</button>");
                }
                if ("Available".equalsIgnoreCase(status)) {
                    out.println("<button onclick=\"updateTableStatus(" + orderTableId + ", 'disable')\" class='btn btn-warning btn-sm'>사용 중지</button>");
                } else {
                    out.println("<button onclick=\"updateTableStatus(" + orderTableId + ", 'enable')\" class='btn btn-success btn-sm'>다시 사용</button>");
                }
                out.println("<button onclick=\"deleteTable(" + orderTableId + ")\" class='btn btn-danger btn-sm ms-2'>삭제</button>");
                out.println("</td>");
                out.println("</tr>");
            }
        } else if ("add".equals(action)) {
            String tableNumber = request.getParameter("tableNumber");
            int capacity = Integer.parseInt(request.getParameter("capacity"));

            String insertSql = "INSERT INTO OrderTable (TableNumber, Capacity, Status) VALUES (?, ?, 'Available')";
            pstmt = con.prepareStatement(insertSql);
            pstmt.setString(1, tableNumber);
            pstmt.setInt(2, capacity);
            pstmt.executeUpdate();

            out.println("<div class='alert alert-success mt-3'>테이블이 성공적으로 추가되었습니다.</div>");
        } else if ("delete".equals(action)) {
            int orderTableId = Integer.parseInt(request.getParameter("orderTableId"));

            String deleteSql = "DELETE FROM OrderTable WHERE OrderTableID = ?";
            pstmt = con.prepareStatement(deleteSql);
            pstmt.setInt(1, orderTableId);
            pstmt.executeUpdate();

            out.println("<div class='alert alert-danger mt-3'>테이블이 삭제되었습니다.</div>");
        } else if ("generateQR".equals(action)) {
            int orderTableId = Integer.parseInt(request.getParameter("orderTableId"));
            String baseUrl = "https://hans2025.zapto.org/NEWmenu.jsp?orderTableId=" + orderTableId;

            response.setContentType("image/png");
            QRCodeWriter qrCodeWriter = new QRCodeWriter();
            BitMatrix bitMatrix = qrCodeWriter.encode(baseUrl, BarcodeFormat.QR_CODE, 200, 200);
            try (OutputStream qrOut = response.getOutputStream()) {
                MatrixToImageWriter.writeToStream(bitMatrix, "PNG", qrOut);
                qrOut.flush();
            }
        }
    } catch (Exception e) {
        e.printStackTrace();
        out.println("<div class='alert alert-danger mt-3'>오류가 발생했습니다: " + e.getMessage() + "</div>");
    } finally {
        if (rs != null) rs.close();
        if (pstmt != null) pstmt.close();
        if (con != null) con.close();
    }
%>
 --%><%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@page import="com.google.zxing.BarcodeFormat"%>
<%@page import="com.google.zxing.qrcode.QRCodeWriter"%>
<%@page import="com.google.zxing.common.BitMatrix"%>
<%@page import="com.google.zxing.client.j2se.MatrixToImageWriter"%>
<%@page import="java.io.OutputStream"%>

<%
    String action = request.getParameter("action");
    Connection con = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        con = DriverManager.getConnection("jdbc:mysql://localhost:3306/StoreManagement", "root", "root");

        if ("load".equals(action)) {
            // 테이블 목록 로드
            String loadSql = "SELECT * FROM OrderTable";
            pstmt = con.prepareStatement(loadSql);
            rs = pstmt.executeQuery();

            while (rs.next()) {
                int orderTableId = rs.getInt("OrderTableID");
                String tableNumber = rs.getString("TableNumber");
                int capacity = rs.getInt("Capacity");
                String status = rs.getString("Status");

                out.println("<tr>");
                out.println("<td>" + tableNumber + "</td>");
                out.println("<td>" + capacity + "</td>");
                out.println("<td>" + (status.equals("Available") ? "사용 가능" : "사용 중지") + "</td>");
                out.println("<td>");
                if ("Available".equalsIgnoreCase(status)) {
                    out.println("<button onclick=\"window.open('table_action.jsp?action=generateQR&orderTableId=" + orderTableId + "')\" class='btn btn-secondary btn-sm ms-2'>QR 코드 생성</button>");
                    out.println("<button onclick=\"updateTableStatus(" + orderTableId + ", 'disable')\" class='btn btn-warning btn-sm'>사용 중지</button>");
                } else {
                    out.println("<button onclick=\"updateTableStatus(" + orderTableId + ", 'enable')\" class='btn btn-success btn-sm'>다시 사용</button>");
                }
                out.println("<button onclick=\"deleteTable(" + orderTableId + ")\" class='btn btn-danger btn-sm ms-2'>삭제</button>");
                out.println("</td>");
                out.println("</tr>");
            }

        } else if ("add".equals(action)) {
            // 테이블 추가
            String tableNumber = request.getParameter("tableNumber");
            int capacity = Integer.parseInt(request.getParameter("capacity"));

            String insertSql = "INSERT INTO OrderTable (TableNumber, Capacity, Status) VALUES (?, ?, 'Available')";
            pstmt = con.prepareStatement(insertSql);
            pstmt.setString(1, tableNumber);
            pstmt.setInt(2, capacity);
            pstmt.executeUpdate();

            out.println("<div class='alert alert-success mt-3'>테이블이 성공적으로 추가되었습니다.</div>");

        } else if ("delete".equals(action)) {
            // 테이블 삭제
            int orderTableId = Integer.parseInt(request.getParameter("orderTableId"));

            String deleteSql = "DELETE FROM OrderTable WHERE OrderTableID = ?";
            pstmt = con.prepareStatement(deleteSql);
            pstmt.setInt(1, orderTableId);
            pstmt.executeUpdate();

            out.println("<div class='alert alert-danger mt-3'>테이블이 삭제되었습니다.</div>");

        } else if ("disable".equals(action) || "enable".equals(action)) {
            // 테이블 상태 업데이트
            int orderTableId = Integer.parseInt(request.getParameter("orderTableId"));
            String newStatus = "disable".equals(action) ? "No_Use" : "Available";

            String updateSql = "UPDATE OrderTable SET Status = ? WHERE OrderTableID = ?";
            pstmt = con.prepareStatement(updateSql);
            pstmt.setString(1, newStatus);
            pstmt.setInt(2, orderTableId);
            int rowsUpdated = pstmt.executeUpdate();

            if (rowsUpdated > 0) {
                out.println("<div class='alert alert-success mt-3'>테이블 상태가 업데이트되었습니다: " + newStatus + "</div>");
            } else {
                out.println("<div class='alert alert-danger mt-3'>테이블 상태 업데이트에 실패했습니다.</div>");
            }

        } else if ("generateQR".equals(action)) {
            // QR 코드 생성
            int orderTableId = Integer.parseInt(request.getParameter("orderTableId"));
            String baseUrl = "https://hans2025.zapto.org/NEWmenu.jsp?orderTableId=" + orderTableId;

            response.setContentType("image/png");
            QRCodeWriter qrCodeWriter = new QRCodeWriter();
            BitMatrix bitMatrix = qrCodeWriter.encode(baseUrl, BarcodeFormat.QR_CODE, 200, 200);
            try (OutputStream qrOut = response.getOutputStream()) {
                MatrixToImageWriter.writeToStream(bitMatrix, "PNG", qrOut);
                qrOut.flush();
            }
        }

    } catch (Exception e) {
        e.printStackTrace();
        out.println("<div class='alert alert-danger mt-3'>오류가 발생했습니다: " + e.getMessage() + "</div>");
    } finally {
        if (rs != null) rs.close();
        if (pstmt != null) pstmt.close();
        if (con != null) con.close();
    }
%>
 