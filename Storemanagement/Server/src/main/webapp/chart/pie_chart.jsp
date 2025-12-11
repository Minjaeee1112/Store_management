<%@page import="java.sql.DriverManager"%>
<%@page import="java.util.ArrayList"%>
<%@page import="java.util.List"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.sql.Connection"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    Connection con = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    double totalIncome = 0.0;
    double totalExpense = 0.0;
    double totalProfit = 0.0;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        con = DriverManager.getConnection("jdbc:mysql://localhost:3306/storemanagement", "root", "root");

        String sql = "SELECT SUM(PaymentAmount) AS total_income, " +
                     "SUM(CASE WHEN PaymentStatus = 'Paid' THEN PaymentAmount * 0.2 ELSE 0 END) AS total_expense, " +
                     "SUM(PaymentAmount - (PaymentAmount * 0.2)) AS total_profit " +
                     "FROM Payment WHERE PaymentStatus = 'Paid'";

        pstmt = con.prepareStatement(sql);
        rs = pstmt.executeQuery();

        if (rs.next()) {
            totalIncome = rs.getDouble("total_income");
            totalExpense = rs.getDouble("total_expense");
            totalProfit = rs.getDouble("total_profit");
        }
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        try { if (rs != null) rs.close(); if (pstmt != null) pstmt.close(); if (con != null) con.close(); } catch (Exception e) { }
    }
%>

<div style="max-width: 300px; margin: 0 auto;">
    <canvas id="pieChart" width="300" height="300"></canvas>
</div>

<script>
    var ctx = document.getElementById('pieChart').getContext('2d');
    var pieChart = new Chart(ctx, {
        type: 'pie',
        data: {
            labels: ['수익 (Income)', '비용 (Expense)', '이익 (Profit)'],
            datasets: [{
                data: [
                    <%= totalIncome %>, // 총 수익
                    <%= totalExpense %>, // 총 비용
                    <%= totalProfit %>  // 총 이익
                ],
                backgroundColor: [
                    'rgba(54, 162, 235, 0.5)',  // 수익 색상
                    'rgba(255, 99, 132, 0.5)',  // 비용 색상
                    'rgba(75, 192, 192, 0.5)'   // 이익 색상
                ]
            }]
        },
        options: {
            responsive: true,
            plugins: {
                legend: {
                    position: 'top',
                    labels: {
                        font: {
                            size: 14 // 레이블 폰트 크기 조정
                        }
                    }
                }
            },
            layout: {
                padding: {
                    top: 10,  // 상단 여백
                    bottom: 10 // 하단 여백
                }
            }
        }
    });
</script>

