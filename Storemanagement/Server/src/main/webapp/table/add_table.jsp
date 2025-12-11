<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    // 세션에서 사용자 역할과 사용자 이름을 확인
    String userRole = (String) session.getAttribute("userRole");
    String username = (String) session.getAttribute("username");

    // 세션에 저장된 정보가 없거나 권한이 admin이 아닌 경우
    if (userRole == null || username == null || !"admin".equals(userRole)) {
        // 로그인 페이지로 리다이렉트
        response.sendRedirect("../index.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>테이블 관리</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css">
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script>
        // AJAX로 테이블 데이터 로드
        function loadTableData() {
            $.ajax({
                type: 'POST',
                url: 'table_action.jsp',
                data: { action: 'load' },
                success: function(response) {
                    $("#table-data").html(response); // 테이블 데이터를 업데이트
                }
            });
        }

        // 테이블 추가 함수
        function addTable() {
            const tableNumber = $("#tableNumber").val();
            const capacity = $("#capacity").val();

            $.ajax({
                type: 'POST',
                url: 'table_action.jsp',
                data: { action: 'add', tableNumber: tableNumber, capacity: capacity },
                success: function(response) {
                    $("#table-message").html(response).fadeIn().delay(2000).fadeOut(); // 메시지 표시
                    loadTableData(); // 테이블 목록 업데이트
                }
            });
        }

        // 테이블 상태 업데이트 함수 (사용 중지, 사용 재개)
        function updateTableStatus(orderTableId, action) {
            $.ajax({
                type: 'POST',
                url: 'table_action.jsp',
                data: { action: action, orderTableId: orderTableId },
                success: function(response) {
                    $("#table-message").html(response).fadeIn().delay(2000).fadeOut(); // 메시지 표시
                    loadTableData(); // 테이블 목록 업데이트
                }
            });
        }

        // 테이블 삭제 함수
        function deleteTable(orderTableId) {
            if (confirm("이 테이블을 정말 삭제하시겠습니까?")) {
                $.ajax({
                    type: 'POST',
                    url: 'table_action.jsp',
                    data: { action: 'delete', orderTableId: orderTableId },
                    success: function(response) {
                        $("#table-message").html(response).fadeIn().delay(2000).fadeOut(); // 메시지 표시
                        loadTableData(); // 테이블 목록 업데이트
                    }
                });
            }
        }

        $(document).ready(function() {
            loadTableData(); // 페이지 로드 시 테이블 데이터 로드
        });
    </script>
</head>
<body>
<jsp:include page="${pageContext.request.contextPath}/dashboard.jsp" />
    <div class="container mt-5">
        <h1 class="text-center">테이블 관리</h1>
        <hr>

        <!-- 테이블 추가 폼 -->
        <form onsubmit="addTable(); return false;" class="mt-4">
            <div class="mb-3">
                <label for="tableNumber" class="form-label">테이블 번호</label>
                <input type="text" id="tableNumber" name="tableNumber" class="form-control" placeholder="예: A1, B2" required>
            </div>
            <div class="mb-3">
                <label for="capacity" class="form-label">테이블 수용 인원</label>
                <input type="number" id="capacity" name="capacity" class="form-control" placeholder="예: 4" min="1" required>
            </div>
            <button type="submit" class="btn btn-primary">테이블 추가</button>
        </form>

        <hr>

        <!-- 테이블 상태 관리 테이블 -->
        <h2>현재 테이블 상태</h2>
        <div id="table-message" class="mt-3"></div>
        <table class="table table-bordered mt-4">
            <thead>
                <tr>
                    <th>테이블 번호</th>
                    <th>수용 인원</th>
                    <th>상태</th>
                    <th>관리</th>
                </tr>
            </thead>
            <tbody id="table-data">
                <!-- AJAX로 테이블 데이터가 로드될 위치 -->
            </tbody>
        </table>
    </div>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
