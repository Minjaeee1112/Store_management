package com.ProductM.model;

import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/DeleteProductServlet")
public class DeleteProductServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        //응답 문자 UTF-8로 변경
    	request.setCharacterEncoding("UTF-8"); 
        response.setContentType("text/html; charset=UTF-8");
        response.setCharacterEncoding("UTF-8");

        String productId = request.getParameter("productId");

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/StoreManagement", "root", "root");

            String query = "DELETE FROM Product WHERE ProductID=?";
            PreparedStatement pst = con.prepareStatement(query);
            pst.setString(1, productId);

            pst.executeUpdate();
            con.close();

            // 삭제 후 상품 목록 페이지로 리다이렉트 (새로고침)
            response.sendRedirect("product/register_product.jsp");

        } catch (Exception e) {
            e.printStackTrace();
            request.getRequestDispatcher("/error.jsp").forward(request, response);
        }
    }

}

