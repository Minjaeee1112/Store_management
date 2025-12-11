package com.ProductM.model;

import java.awt.Graphics2D;
import java.awt.image.BufferedImage;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import javax.imageio.ImageIO;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.Part;

@WebServlet("/UpdateProductServlet")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024,
    maxFileSize = 5 * 1024 * 1024,
    maxRequestSize = 10 * 1024 * 1024
)
public class UpdateProductServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html; charset=UTF-8");

        String productIdStr = request.getParameter("productId");

        try {
            if (productIdStr == null || productIdStr.isEmpty()) {
                throw new IllegalArgumentException("상품 ID는 필수 입력값입니다.");
            }

            int productId = Integer.parseInt(productIdStr);

            // 상품 ID 유효성 확인
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/StoreManagement", "root", "root");

            PreparedStatement checkStmt = con.prepareStatement("SELECT COUNT(*) FROM Product WHERE ProductID = ?");
            checkStmt.setInt(1, productId);
            ResultSet rs = checkStmt.executeQuery();
            if (rs.next() && rs.getInt(1) == 0) {
                // 해당 ID가 존재하지 않음
                response.getWriter().println("<script>alert('존재하지 않는 상품 ID입니다.'); location.href='product/update_product.jsp';</script>");
                rs.close();
                checkStmt.close();
                con.close();
                return;
            }
            rs.close();
            checkStmt.close();

            // 상품 업데이트를 위한 준비
            String productName = request.getParameter("productName");
            String productPriceStr = request.getParameter("productPrice");
            String productDescription = request.getParameter("productDescription");
            String productStockStr = request.getParameter("productStock");
            String productStatus = request.getParameter("productStatus");

            int productStock = (productStockStr != null && !productStockStr.isEmpty()) ? Integer.parseInt(productStockStr) : -1;
            double productPrice = (productPriceStr != null && !productPriceStr.isEmpty()) ? Double.parseDouble(productPriceStr) : -1;

            byte[] productImage = null;
            Part filePart = request.getPart("productImage");
            if (filePart != null && filePart.getSize() > 0) {
                InputStream inputStream = filePart.getInputStream();
                productImage = resizeImage(inputStream, 300, 300);
            }

            // 동적 업데이트 쿼리 생성
            StringBuilder query = new StringBuilder("UPDATE Product SET ");
            if (productName != null && !productName.isEmpty()) query.append("ProductName = ?, ");
            if (productPrice > 0) query.append("ProductPrice = ?, ");
            if (productDescription != null && !productDescription.isEmpty()) query.append("ProductDescription = ?, ");
            if (productStock >= 0) query.append("ProductStock = ?, ");
            if (productStatus != null && !productStatus.isEmpty()) query.append("ProductStatus = ?, ");
            if (productImage != null) query.append("ProductPicture = ?, ");
            query.setLength(query.length() - 2); // 마지막 ", " 제거
            query.append(" WHERE ProductID = ?");

            PreparedStatement pstmt = con.prepareStatement(query.toString());

            int paramIndex = 1;
            if (productName != null && !productName.isEmpty()) pstmt.setString(paramIndex++, productName);
            if (productPrice > 0) pstmt.setDouble(paramIndex++, productPrice);
            if (productDescription != null && !productDescription.isEmpty()) pstmt.setString(paramIndex++, productDescription);
            if (productStock >= 0) pstmt.setInt(paramIndex++, productStock);
            if (productStatus != null && !productStatus.isEmpty()) pstmt.setString(paramIndex++, productStatus);
            if (productImage != null) pstmt.setBytes(paramIndex++, productImage);
            pstmt.setInt(paramIndex, productId);

            pstmt.executeUpdate();
            pstmt.close();
            con.close();

            response.sendRedirect("/product/register_product.jsp");
        } catch (NumberFormatException e) {
            response.getWriter().println("<script>alert('상품 ID는 숫자여야 합니다.'); location.href='product/update_product.jsp';</script>");
        } catch (IllegalArgumentException e) {
            response.getWriter().println("<script>alert('" + e.getMessage() + "'); location.href='product/update_product.jsp';</script>");
        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().println("<script>alert('오류 발생: " + e.getMessage() + "'); location.href='product/update_product.jsp';</script>");
        }
    }

    private byte[] resizeImage(InputStream inputStream, int width, int height) throws IOException {
        BufferedImage originalImage = ImageIO.read(inputStream);
        BufferedImage resizedImage = new BufferedImage(width, height, BufferedImage.TYPE_INT_RGB);

        Graphics2D g2d = resizedImage.createGraphics();
        g2d.drawImage(originalImage, 0, 0, width, height, null);
        g2d.dispose();

        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        ImageIO.write(resizedImage, "jpg", baos);
        return baos.toByteArray();
    }
}
