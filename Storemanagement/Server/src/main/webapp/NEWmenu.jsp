<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.ArrayList, java.util.List"%>

<!DOCTYPE html>
<html lang="ko">
<head>
    <!-- 장바구니 아이콘 -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>메뉴</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css">
    <style>
        /* 상단 고정 메뉴 스타일 */
        #cart-message {
            position: fixed; /* 화면에 고정 */
            top: 50%; /* 세로 중앙 */
            left: 50%; /* 가로 중앙 */
            transform: translate(-50%, -50%); /* 중앙 정렬 */
            z-index: 1050; /* 다른 요소 위에 표시 */
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0px 4px 6px rgba(0, 0, 0, 0.1);
            display: none; /* 기본적으로 숨김 */
        }
        .fixed-top-menu {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            background-color: #f8f9fa;
            z-index: 1000;
            padding: 10px 0;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
        }
        .content {
            margin-top: 80px; /* 고정 메뉴 높이만큼 여백 추가 */
        }
        .card {
            display: flex;
            flex-direction: row; /* 카드 내부를 가로 배치 */
            align-items: center;
            padding: 10px;
            border: 1px solid #ddd;
            border-radius: 8px;
        }
        .card img {
            width: 150px; /* 이미지 크기 설정 */
            height: 150px;
            object-fit: cover;
            border-radius: 8px;
            margin-right: 10px; /* 이미지와 텍스트 간격 */
        }
        .card-body {
            flex: 1; /* 오른쪽 영역이 남은 공간을 차지 */
            display: flex;
            flex-direction: column;
            justify-content: space-between;
            padding: 5px;
        }
        .form-inline {
            display: flex;
            align-items: center;
        }
        .form-inline input {
            width: 80px; /* 입력 필드 크기 */
            margin-right: 10px;
        }
        #tablenumber {
            margin-right: 120px !important;
            font-weight: 700;
            letter-spacing: 1px;
            font-size: 1.3rem;
            padding: 0px;
            margin: 0px;
            color: #0037CF !important;
        }

        @media (min-width: 270px) {
        #submitb {
        	font-size: 13px;
        	
        }
        #ct{
        	font-siZe: 17px !important;
        }
        }
    </style>
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script>
        // 수량 감소 함수
        function decrementQuantity(button) {
            const input = button.closest('.input-group').querySelector('input[name="quantity"]');
            const currentValue = parseInt(input.value, 10);
            if (currentValue > 1) {
                input.value = currentValue - 1;
            }
        }

        // 수량 증가 함수
        function incrementQuantity(button) {
            const input = button.closest('.input-group').querySelector('input[name="quantity"]');
            input.value = parseInt(input.value, 10) + 1;
        }

        // AJAX로 장바구니에 상품 추가
        function addToCart(productId, orderTableId, quantity) {
            $.ajax({
                type: "POST",
                url: "test/add_to_cart.jsp",
                data: { productId: productId, orderTableId: orderTableId, quantity: quantity },
                success: function(response) {
                    $("#cart-message").html(response).fadeIn().delay(2000).fadeOut(); // 알림 메시지 표시
                }
            });
        }
    </script>
</head>
<body>

    <!-- 상단 고정 메뉴 -->
    <div class="fixed-top-menu">
        <div class="container d-flex justify-content-end align-items-center">
            <span id="tablenumber" >Table: <%=request.getParameter("orderTableId")%></span>
            <!-- QR 코드에서 orderTableId를 받아 메뉴와 연동 -->
            <a href="test/view_cart.jsp?orderTableId=<%= request.getParameter("orderTableId") %>"><i class="fa-solid fa-cart-shopping fa-lg" 
                style="color: #0037CF; margin-right: 10px; margin-top: 13px; font-size: 2rem;"></i></a>            
            <a href="test/order_history.jsp?orderTableId=<%= request.getParameter("orderTableId") %>" class="btn btn-info"
                style="background-color: #0037CF; color: white; border: none">주문 내역</a>
        </div>
    </div>

    <div class="container content mt-5">
        <!-- 장바구니 알림 메시지 -->
        <div id="cart-message" class="alert alert-success text-center" style="display: none;"></div>

        <!-- 상품 목록 -->
        <div class="row">
            <%
                // 테이블 ID 가져오기
                String orderTableId = request.getParameter("orderTableId");

                // orderTableId가 없으면 접근 차단
                if (orderTableId == null || orderTableId.isEmpty()) {
                    out.println("<h1>잘못된 접근입니다.</h1>");
                    return;
                }

                // DB 연결
                Connection con = null;
                PreparedStatement pstmt = null;
                ResultSet rs = null;
                List<String> menuList = new ArrayList<>();

                try {
                    // 데이터베이스 연결
                    Class.forName("com.mysql.cj.jdbc.Driver");
                    con = DriverManager.getConnection("jdbc:mysql://localhost:3306/StoreManagement", "root", "root");

                    // 테이블 상태 확인
                    String checkStatusSql = "SELECT Status FROM OrderTable WHERE OrderTableID = ?";
                    pstmt = con.prepareStatement(checkStatusSql);
                    pstmt.setInt(1, Integer.parseInt(orderTableId));
                    rs = pstmt.executeQuery();

                    if (rs.next()) {
                        String status = rs.getString("Status");
                        // 테이블 상태가 "Available"이 아닌 경우 접근 차단
                        if (!"Available".equalsIgnoreCase(status)) {
                        	out.println("<br><h1>사용 불가능</h1><br>");
                        	out.println("<h1>이 테이블은 사용 가능한 상태가 아닙니다.</h1>");
                            return;
                        }
                    } else {
                        // 테이블 ID가 유효하지 않은 경우
                        out.println("<h1>잘못된 테이블 ID입니다.</h1>");
                        return;
                    }

                    String sql = "SELECT * FROM Product WHERE ProductStatus != 'Sold out'"; // 품절인 상품 제외
                    pstmt = con.prepareStatement(sql);
                    rs = pstmt.executeQuery();

                    while (rs.next()) {
                        int productId = rs.getInt("ProductID");
                        String name = rs.getString("ProductName");
                        int price = rs.getInt("ProductPrice");
                        String description = rs.getString("ProductDescription");
                        byte[] picture = rs.getBytes("ProductPicture"); // 이미지 경로
                        String category = rs.getString("ProductCategory"); // 예시: 음식, 음료수

                        // 이미지가 있을 경우 base64로 변환
                        String imageTag = "";
                        if (picture != null) {
                            String base64Image = java.util.Base64.getEncoder().encodeToString(picture);
                            imageTag = "<img src='data:image/jpeg;base64," + base64Image + "' alt='" + name + " 이미지' />";
                        } else {
                            imageTag = "<p>이미지 없음</p>";
                        }

                        // 상품 카드 생성
                        menuList.add(
                            "<div class='col-md-6 mb-4'>" +
                                "<div class='card shadow-sm'>" +
                                    imageTag + // 이미지
                                    "<div class='card-body'>" +
                                        "<h5 id='ct' class='card-title'>" + name + " - " + price + "원</h5>" +
                                        "<p class='card-text'>" + category + "</p>" +
                                        "<p class='card-text text-muted'>" + description + "</p>" +
                                        "<form onsubmit='event.preventDefault(); addToCart(" + productId + ", " + request.getParameter("orderTableId") + ", this.quantity.value);'>" +
                                            "<div class='input-group' style='max-width: 140px;'>" +
                                                "<button type='button' class='btn btn-outline-secondary' onclick='decrementQuantity(this)'>-</button>" +
                                                "<input type='number' name='quantity' value='1' min='1' class='form-control text-center' style='width: 50px;' />" +
                                                "<button type='button' class='btn btn-outline-secondary' onclick='incrementQuantity(this)'>+</button>" +
                                            "</div>" +
                                            "<button type='submit' id='submitb'class='btn btn-primary mt-2'>장바구니에 담기</button>" +
                                        "</form>" +
                                    "</div>" +
                                "</div>" +
                            "</div>"
                        );
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                } finally {
                    try {
                        if (rs != null) rs.close();
                        if (pstmt != null) pstmt.close();
                        if (con != null) con.close();
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                }

                // 상품 목록 출력
                for (String menuItem : menuList) {
                    out.println(menuItem);
                }
            %>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
