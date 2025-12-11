package com.ProductM.model;

import java.awt.Graphics2D;
import java.awt.image.BufferedImage;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;

import javax.imageio.ImageIO;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.Part;

@WebServlet("/RegisterProductServlet")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024,  // 메모리에 저장되는 임시 파일 크기 (1MB)
    maxFileSize = 5 * 1024 * 1024,   // 업로드되는 파일 최대 크기 (5MB)
    maxRequestSize = 10 * 1024 * 1024 // 전체 요청 최대 크기 (10MB)
)
public class RegisterProductServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html; charset=UTF-8");

        // 상품 정보 가져오기
        String productName = request.getParameter("productName");
        String productPriceStr = request.getParameter("productPrice");
        String productDescription = request.getParameter("productDescription");
        String productStockStr = request.getParameter("productStock");
        String productStatus = request.getParameter("productStatus");
        String productCategory = request.getParameter("productCategory");

        try {
            // 파일 처리
        	int ProductStock = Integer.parseInt(productStockStr);
        	double productPrice = Double.parseDouble(productPriceStr); // 가격
        	
        	// 가격 검증
            if (productPrice <= 0) {
                throw new IllegalArgumentException("상품 가격은 0 이상이어야 합니다.");
            }
        	
        	
            
        	Part filePart = request.getPart("productImage");
            if (filePart != null && filePart.getSize() > 0) {
                String fileName = filePart.getSubmittedFileName();
                String mimeType = filePart.getContentType();

                // 파일 형식 확인
                if (!mimeType.startsWith("image/")) {
                    throw new ServletException("이미지 파일만 업로드 가능합니다.");
                }

                // 파일 크기 확인
                if (filePart.getSize() > 5 * 1024 * 1024) { // 5MB 초과 확인
                    throw new ServletException("이미지 크기는 5MB를 초과할 수 없습니다.");
                }

                // 이미지 데이터 읽기
                InputStream inputStream = filePart.getInputStream();

                // 이미지 크기 조정 (선택적 구현)
                byte[] imageData = resizeImage(inputStream, 300, 300); // 예: 300x300 크기로 조정

                // DB 저장
                Class.forName("com.mysql.cj.jdbc.Driver");
                Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/StoreManagement", "root", "root");
                String query = "INSERT INTO Product(ProductName, ProductPrice, ProductDescription, ProductStock, ProductStatus, ProductCategory, ProductPicture) VALUES (?, ?, ?, ?, ?, ?, ?)";
                PreparedStatement pst = con.prepareStatement(query);
                pst.setString(1, productName);
                pst.setDouble(2, Double.parseDouble(productPriceStr));
                pst.setString(3, productDescription);
                pst.setInt(4, Integer.parseInt(productStockStr));
                pst.setString(5, productStatus);
                pst.setString(6, productCategory);
                pst.setBytes(7, imageData);
                pst.executeUpdate();

                pst.close();
                con.close();
            }
            response.sendRedirect("/product/register_product.jsp");
        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().println("<script>alert('오류 발생: " + e.getMessage() + "'); location.href='register_product.jsp';</script>");
        }
    }

    // 이미지 크기 조정 메서드 (선택적)
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