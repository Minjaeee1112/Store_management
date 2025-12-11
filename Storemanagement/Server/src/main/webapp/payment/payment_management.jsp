<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%/*
    // 세션에서 사용자 역할과 사용자 이름을 확인
    String userRole = (String) session.getAttribute("userRole");
    String username = (String) session.getAttribute("username");

    if (userRole == null || username == null || !"admin".equals(userRole)) {
        response.sendRedirect("../index.jsp");
        return;
    }*/
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>결제 및 주문 관리</title>
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <style>
        body {
            background-color: #f8f9fa;
        }
        h2, h4, h5 {
            font-weight: bold;
        }
        #table-status-section {
            background-color: #ffffff;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
        }
        #table-buttons .btn {
            font-size: 18px;
            padding: 10px 20px;
            margin: 5px;
        }
        #table-items-section {
            background-color: #ffffff;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
        }
        #order-items th, #order-items td {
            text-align: center;
        }
        #payment-section, #split-payment-section {
            text-align: right;
            background-color: #ffffff;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
        }
        #split-payment-section {
            display: none;
        }
        .card {
            margin: 20px 0;
        }
        .modal .paid-item {
            cursor: pointer;
            padding: 10px;
            border-bottom: 1px solid #ddd;
        }
        .modal .paid-item:hover {
            background-color: #f8f9fa;
        }
    </style>
</head>
<body>
    <jsp:include page="/dashboard.jsp" />

    <div class="container mt-5">
        <h2 class="text-center mb-4">결제 및 주문 관리</h2>

        <!-- 테이블 상태 -->
        <div id="table-status-section" class="mb-4">
            <h4>테이블 상태</h4>
            <div id="table-buttons" class="d-flex flex-wrap justify-content-start">
                <!-- 버튼 예제 -->
                <button class="btn btn-success">테이블 1</button>
                <button class="btn btn-success">테이블 2</button>
                <button class="btn btn-success">테이블 3</button>
            </div>
        </div>

        <!-- 주문 상세 내역 -->
        <div id="table-items-section" class="mb-4">
            <h4>주문 상세 내역</h4>
            <table id="order-items" class="table table-bordered">
                <thead class="thead-light">
                    <tr>
                        <th>상품명</th>
                        <th>수량</th>
                        <th>가격</th>
                    </tr>
                </thead>
                <tbody></tbody>
            </table>
        </div>

        <!-- 결제 섹션 -->
        <div id="payment-section" class="mb-4">
            <h5>결제 방식 선택</h5>
            <div class="mb-3">
                <label class="mr-3"><input type="radio" name="paymentMethod" value="Cash" checked> 현금</label>
                <label><input type="radio" name="paymentMethod" value="Card"> 카드</label>
            </div>
            <button id="payment-button" class="btn btn-danger">결제하기</button>
            <button id="split-payment-button" class="btn btn-warning">분할 결제</button>
            <button id="cancel-payment-button" class="btn btn-secondary">결제 취소</button>
        </div>

        <!-- 분할 결제 섹션 -->
        <div id="split-payment-section" class="mb-4">
            <h5>분할 결제</h5>
            <div class="mb-3">
                남은 금액: <span id="remaining-amount">0</span>원
            </div>
            <input type="number" id="split-amount" class="form-control mb-3" placeholder="결제 금액 입력">
            <button id="submit-split-payment" class="btn btn-primary">결제 진행</button>
            <button id="cancel-split-payment" class="btn btn-secondary">취소</button>
        </div>
    </div>

    <!-- 결제 취소 항목 선택 모달 -->
    <div id="paid-items-modal" class="modal fade" tabindex="-1" role="dialog">
        <div class="modal-dialog" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">결제 취소 항목 선택</h5>
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                        <span aria-hidden="true">&times;</span>
                    </button>
                </div>
                <div class="modal-body">
                    <!-- Paid 상태의 아이템 목록이 여기에 표시됩니다 -->
                </div>
            </div>
        </div>
    </div>

    <script>
        let selectedTableId = null;
        let paymentId = null;
        let remainingAmount = 0;

        function fetchTableStatus() {
            console.log("테이블 상태 불러오기 시작");
            $.post("/ManagementServlet", { action: "fetchTables" })
                .done(function(data) {
                    console.log("서버 응답: ", data);
                    const tableButtons = $("#table-buttons");
                    tableButtons.empty();

                    if (!data || data.length === 0) {
                        tableButtons.append("<div>테이블 정보가 없습니다.</div>");
                    } else {
                        data.forEach(function(table) {
                            const button = $("<button>")
                                .addClass("btn btn-success m-2")
                                .text("테이블 " + table.tableNumber)
                                .data("table-id", table.orderTableId)
                                .click(function() {
                                    selectedTableId = table.orderTableId;
                                    $("#table-buttons .btn-success").removeClass("active");
                                    $(this).addClass("active");
                                    fetchOrderItems(table.orderTableId);
                                    fetchPaymentId(table.orderTableId);
                                });
                            tableButtons.append(button);
                        });
                    }
                })
                .fail(function(xhr, status, error) {
                    console.error("테이블 상태를 불러오는 중 오류 발생: ", status, error);
                    alert("테이블 상태를 불러오는 중 오류가 발생했습니다.");
                });
        }

        function fetchOrderItems(tableId) {
            console.log("특정 테이블의 주문 상세 내역 불러오기 시작, 테이블 ID: ", tableId);
            $.post("/ManagementServlet", { action: "fetchOrderItems", orderId: tableId })
                .done(function(data) {
                    console.log("서버 응답 (주문 상세 내역): ", data);
                    const orderItemsTable = $("#order-items tbody");
                    orderItemsTable.empty();

                    let totalAmount = 0;

                    if (!data || data.length === 0) {
                        alert("주문 상세 내역이 없습니다.");
                    } else {
                        data.forEach(function(item) {
                            const row = $("<tr>")
                                .append($("<td>").text(item.productName))
                                .append($("<td>").text(item.quantity))
                                .append($("<td>").text(item.totalPrice + "원"));
                            orderItemsTable.append(row);
                            totalAmount += item.totalPrice;
                        });
                    }

                    remainingAmount = totalAmount; // 초기 총액 설정
                    $("#remaining-amount").text(remainingAmount);

                    $("#total-amount").remove();
                    const totalAmountDiv = $("<div>")
                        .attr("id", "total-amount")
                        .addClass("card text-white bg-primary p-3")
                        .css({ "max-width": "250px" })
                        .append(
                            $("<div>").addClass("card-body")
                                .append($("<h5>").addClass("card-title").text("총액"))
                                .append($("<p>").addClass("card-text").text(totalAmount + "원"))
                        );
                    $("#table-items-section").after(totalAmountDiv);
                })
                .fail(function(xhr, status, error) {
                    console.error("주문 상세 내역을 가져오는 중 오류 발생: ", status, error);
                    alert("주문 상세 내역을 가져오는 중 오류가 발생했습니다.");
                });
        }

        $("#cancel-payment-button").click(() => {
            const popup = window.open(
                "cancel_payment.jsp",
                "cancelPaymentPopup",
                "width=600,height=600,scrollbars=yes"
            );

            if (!popup) {
                alert("팝업이 차단되었습니다. 팝업 차단 설정을 해제하세요.");
            }
        });


        $(document).on("click", ".paid-item", function() {
            const orderItemId = $(this).data("id");

            if (confirm("이 항목을 취소하시겠습니까?")) {
                $.post("/PaymentServlet", { action: "cancelSpecificPaidItem", orderItemId: orderItemId })
                    .done(response => {
                        alert(response.message || "결제가 취소되었습니다.");
                        $("#paid-items-modal").modal("hide");
                        fetchTableStatus();
                        $("#order-items tbody").empty();
                    })
                    .fail(function(xhr, status, error) {
                        console.error("결제 취소 중 오류:", status, error);
                        alert("결제 취소 중 오류가 발생했습니다.");
                    });
            }
        });
        $("#submit-split-payment").click(() => {
            const splitAmount = parseFloat($("#split-amount").val());

            if (isNaN(splitAmount) || splitAmount <= 0) {
                alert("유효한 금액을 입력해주세요.");
                return;
            }

            if (splitAmount > remainingAmount) {
                alert("입력한 금액이 남은 금액보다 큽니다.");
                return;
            }

            remainingAmount -= splitAmount;
            $("#remaining-amount").text(remainingAmount);

            if (remainingAmount === 0) {
                alert("모든 금액이 결제되었습니다.");
                $("#split-payment-section").hide();
                $("#payment-button").click(); // 최종 결제 완료 처리
            } else {
                alert("남은 금액: " + remainingAmount + "원");
            }
        });

        
        function fetchPaymentId(tableId) {
            console.log("Fetching payment ID for table ID:", tableId);
            $.post("/PaymentServlet", { action: "fetchPaymentId", tableId: tableId })
                .done(function(data) {
                    console.log("Payment ID response:", data);
                    if (data.paymentId) {
                        paymentId = data.paymentId; // JavaScript 변수에 저장
                        console.log("Payment ID set to:", paymentId);
                    } else {
                        paymentId = null;
                        console.log("No payment ID found for table ID:", tableId);
                    }
                })
                .fail(function(xhr, status, error) {
                    console.error("Error fetching payment ID:", status, error);
                    alert("결제 ID를 가져오는 중 오류가 발생했습니다.");
                });
        }


		
        $("#payment-button").click(() => {
            const paymentMethod = $("input[name='paymentMethod']:checked").val();

            if (!selectedTableId) {
                alert("테이블을 선택하세요.");
                return;
            }

            const totalAmountText = $("#total-amount .card-text").text();
            const totalAmount = parseFloat(totalAmountText.replace("원", "").replace(",", "").trim());

            console.log("Processing payment for Table ID:", selectedTableId, "Amount:", totalAmount, "Method:", paymentMethod);

            if (isNaN(totalAmount) || totalAmount <= 0) {
                alert("총 금액이 올바르지 않습니다.");
                return;
            }

            if (confirm("결제를 진행하시겠습니까?")) {
                $.post("/PaymentServlet", {
                    action: "processPayment",
                    tableId: selectedTableId,
                    paymentAmount: totalAmount,
                    paymentMethod: paymentMethod
                })
                    .done(response => {
                        alert(response.message || "결제가 완료되었습니다.");
                        fetchTableStatus();
                        $("#order-items tbody").empty();
                        $("#total-amount").remove();
                        selectedTableId = null;
                    })
                    .fail((xhr, status, error) => {
                        console.error("Error processing payment:", status, error);
                        alert("결제 처리 중 오류가 발생했습니다.");
                    });
            }
        });

        $("#split-payment-button").click(() => {
            if (!remainingAmount || remainingAmount <= 0) {
                alert("남은 금액이 없습니다.");
                return;
            }
            $("#split-payment-section").show();
        });

        
        $(document).ready(function() {
            fetchTableStatus();
        });
    </script>

</body>
</html>
