package com.ProductM.model;


import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.example.model.Product;

@WebServlet("/ProductListServlet")
public class ProductListServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("text/html; charset=UTF-8");
        request.setCharacterEncoding("UTF-8");

        List<Product> productList = new ArrayList<>();

        Connection con = null;
        Statement stmt = null;
        ResultSet rs = null;

        try {
            // MySQL JDBC 드라이버 로드
            Class.forName("com.mysql.cj.jdbc.Driver");

            // 데이터베이스 연결
            con = DriverManager.getConnection("jdbc:mysql://localhost:3306/StoreManagement", "root", "root");

            // SQL 쿼리 실행
            stmt = con.createStatement();
            rs = stmt.executeQuery("SELECT * FROM Product");

            while (rs.next()) {
                int id = rs.getInt("ProductID");
                String name = rs.getString("ProductName");
                double price = rs.getDouble("ProductPrice");
                String description = rs.getString("ProductDescription");
                int stock = rs.getInt("ProductStock");
                String status = rs.getString("ProductStatus");

                Product product = new Product(id, name, price, description, stock, status);
                productList.add(product);
            }

            // 상품 목록을 request 객체에 설정
            request.setAttribute("productList", productList);

            // 데이터를 포함하여 product_list.jsp로 포워딩
            RequestDispatcher dispatcher = request.getRequestDispatcher("/product_list.jsp");
            dispatcher.include(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, e.getMessage());
        } finally {
            try {
                if (rs != null) rs.close();
                if (stmt != null) stmt.close();
                if (con != null) con.close();
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }
}