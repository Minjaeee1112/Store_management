<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*" %>
<!DOCTYPE html>
<html>
<head>
    <title>차트</title>
    <!-- 부트스트랩 CSS 추가 -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha3/dist/css/bootstrap.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
</head>
<body>
    <div class="container mt-4">
        <div class="text-center">
            <h2>차트</h2>
        </div>
        <div class="d-flex justify-content-center mt-3">
            <!-- 부트스트랩 버튼 그룹 -->
            <div class="btn-group" role="group" aria-label="Chart Type">
                <button type="button" class="btn btn-primary" onclick="updateChart('year')">연도별</button>
                <button type="button" class="btn btn-secondary" onclick="updateChart('month')">월별</button>
                <button type="button" class="btn btn-success" onclick="updateChart('day')">일별</button>
            </div>
        </div>
        <div class="mt-4">
            <!-- 차트 캔버스 -->
            <canvas id="profitChart" width="800" height="400"></canvas>
        </div>
    </div>

    <%
        // 데이터베이스 연결 및 데이터 가져오기
        Connection con = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        // 데이터 저장용 리스트
        List<String> labels = new ArrayList<>();
        List<Double> incomes = new ArrayList<>();
        List<Double> expenses = new ArrayList<>();
        List<Double> profits = new ArrayList<>();

        // 요청된 차트 타입 가져오기
        String chartType = request.getParameter("chartType");
        if (chartType == null || chartType.isEmpty()) {
            chartType = "year"; // 기본값은 연도별
        }

        try {
            // 데이터베이스 연결
            Class.forName("com.mysql.cj.jdbc.Driver");
            con = DriverManager.getConnection("jdbc:mysql://localhost:3306/storemanagement", "root", "root");

            // 차트 타입에 따른 SQL 쿼리
            String sql = "";
            switch (chartType) {
                case "month":
                    sql = "SELECT YEAR(PaymentDate) AS year, MONTH(PaymentDate) AS month, " +
                          "SUM(PaymentAmount) AS total_income, " +
                          "SUM(PaymentAmount * 0.2) AS total_expense, " +
                          "SUM(PaymentAmount) - SUM(PaymentAmount * 0.2) AS total_profit " +
                          "FROM Payment " +
                          "WHERE PaymentStatus = 'Paid' " +
                          "GROUP BY YEAR(PaymentDate), MONTH(PaymentDate)";
                    break;
                case "day":
                    sql = "SELECT YEAR(PaymentDate) AS year, MONTH(PaymentDate) AS month, DAY(PaymentDate) AS day, " +
                          "SUM(PaymentAmount) AS total_income, " +
                          "SUM(PaymentAmount * 0.2) AS total_expense, " +
                          "SUM(PaymentAmount) - SUM(PaymentAmount * 0.2) AS total_profit " +
                          "FROM Payment " +
                          "WHERE PaymentStatus = 'Paid' " +
                          "GROUP BY YEAR(PaymentDate), MONTH(PaymentDate), DAY(PaymentDate)";
                    break;
                default: // year
                    sql = "SELECT YEAR(PaymentDate) AS year, " +
                          "SUM(PaymentAmount) AS total_income, " +
                          "SUM(PaymentAmount * 0.2) AS total_expense, " +
                          "SUM(PaymentAmount) - SUM(PaymentAmount * 0.2) AS total_profit " +
                          "FROM Payment " +
                          "WHERE PaymentStatus = 'Paid' " +
                          "GROUP BY YEAR(PaymentDate)";
                    break;
            }

            // SQL 실행 및 결과 처리
            pstmt = con.prepareStatement(sql);
            rs = pstmt.executeQuery();

            while (rs.next()) {
                if ("month".equals(chartType)) {
                    labels.add(rs.getString("year") + "년 " + rs.getString("month") + "월");
                } else if ("day".equals(chartType)) {
                    labels.add(rs.getString("year") + "년 " + rs.getString("month") + "월 " + rs.getString("day") + "일");
                } else {
                    labels.add(rs.getString("year") + "년");
                }
                incomes.add(rs.getDouble("total_income"));
                expenses.add(rs.getDouble("total_expense"));
                profits.add(rs.getDouble("total_profit"));
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            try { if (rs != null) rs.close(); if (pstmt != null) pstmt.close(); if (con != null) con.close(); } catch (Exception e) { }
        }
    %>

    <script>
        // 차트 데이터를 업데이트하는 함수
        function updateChart(type) {
            window.location.href = '?chartType=' + type;
        }

        // 서버에서 받은 데이터
        var labels = <%= labels.toString().replace("[", "['").replace("]", "']").replace(", ", "','") %>;
        var incomes = <%= incomes.toString().replace("[", "[").replace("]", "]") %>;
        var expenses = <%= expenses.toString().replace("[", "[").replace("]", "]") %>;
        var profits = <%= profits.toString().replace("[", "[").replace("]", "]") %>;

        // 차트 초기화
        var ctx = document.getElementById('profitChart').getContext('2d');
        var profitChart = new Chart(ctx, {
            type: 'bar',
            data: {
                labels: labels,
                datasets: [
                    {
                        label: '수익 (Income)',
                        backgroundColor: 'rgba(54, 162, 235, 0.5)',
                        data: incomes
                    },
                    {
                        label: '비용 (Expense)',
                        backgroundColor: 'rgba(255, 99, 132, 0.5)',
                        data: expenses
                    },
                    {
                        label: '이익 (Profit)',
                        backgroundColor: 'rgba(75, 192, 192, 0.5)',
                        data: profits
                    }
                ]
            },
            options: {
                responsive: true,
                plugins: {
                    legend: { position: 'top' },
                    tooltip: { mode: 'index', intersect: false }
                },
                scales: {
                    x: { stacked: true },
                    y: { beginAtZero: true }
                }
            }
        });
    </script>
    <!-- 부트스트랩 JS 추가 -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha3/dist/js/bootstrap.bundle.min.js"></script>
    
</body>
</html>

