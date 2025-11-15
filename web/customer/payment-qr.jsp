<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.Customer" %>
<%@ page import="model.Booking" %>
<%@ page import="service.BookingService" %>
<%@ page import="java.util.List" %>
<%
    Customer customer = (Customer) session.getAttribute("currentUser");
    if (customer == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    Integer orderId = (Integer) request.getAttribute("orderId");
    Booking booking = (Booking) request.getAttribute("booking");

    if (orderId == null || booking == null) {
        response.sendRedirect(request.getContextPath() + "/customer/booking?action=history");
        return;
    }

    // Tính tổng tiền từ session data
    BookingService bookingService = new BookingService();
    List<Integer> serviceIds = (List<Integer>) session.getAttribute("pendingServiceIds");
    List<Integer> quantities = (List<Integer>) session.getAttribute("pendingQuantities");
    double totalAmount = 0;

    if (serviceIds != null && quantities != null) {
        for (int i = 0; i < serviceIds.size(); i++) {
            model.PetServiceModel service = bookingService.getServiceById(serviceIds.get(i));
            if (service != null) {
                totalAmount += service.getPrice().doubleValue() * quantities.get(i);
            }
        }
    }
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Thanh toán | Pet4Care</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/staff.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <style>
        .payment-container {
            max-width: 600px;
            margin: 50px auto;
            background: white;
            border-radius: 15px;
            padding: 30px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.1);
            text-align: center;
        }

        .payment-header {
            margin-bottom: 30px;
        }

        .payment-header h2 {
            color: #333;
            margin-bottom: 10px;
        }

        .payment-header p {
            color: #666;
            font-size: 16px;
        }

        .qr-container {
            margin: 30px 0;
            padding: 20px;
            background: #f8f9fa;
            border-radius: 10px;
            border: 2px dashed #dee2e6;
        }

        .qr-code {
            width: 256px;
            height: 256px;
            margin: 0 auto 20px;
            display: block;
            border: 1px solid #ddd;
            border-radius: 10px;
        }

        .payment-info {
            background: #e8f5e8;
            padding: 20px;
            border-radius: 10px;
            margin: 20px 0;
            border-left: 4px solid #4CAF50;
        }

        .payment-info h3 {
            color: #2e7d32;
            margin-bottom: 15px;
        }

        .amount {
            font-size: 24px;
            font-weight: bold;
            color: #4CAF50;
            margin: 10px 0;
        }

        .status-checking {
            color: #ff9800;
            font-weight: bold;
            margin-top: 20px;
        }

        .status-success {
            color: #4CAF50;
            font-weight: bold;
            margin-top: 20px;
        }

        .status-error {
            color: #f44336;
            font-weight: bold;
            margin-top: 20px;
        }

        .btn-cancel {
            background: #f44336;
            color: white;
            padding: 12px 30px;
            border: none;
            border-radius: 25px;
            cursor: pointer;
            font-size: 16px;
            margin-top: 20px;
        }

        .btn-cancel:hover {
            background: #d32f2f;
        }

        .loading-spinner {
            display: inline-block;
            width: 20px;
            height: 20px;
            border: 3px solid #f3f3f3;
            border-top: 3px solid #3498db;
            border-radius: 50%;
            animation: spin 1s linear infinite;
            margin-right: 10px;
        }

        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }
    </style>
</head>
<body>

<div class="payment-container">
    <div class="payment-header">
        <h2><i class="fas fa-qrcode"></i> Thanh toán dịch vụ</h2>
        <p>Quét mã QR để thanh toán cho lịch hẹn của bạn</p>
    </div>

    <div class="payment-info">
        <h3><i class="fas fa-calendar-check"></i> Thông tin lịch hẹn</h3>
        <p><strong>Thú cưng:</strong> ${booking.petName}</p>
        <p><strong>Thời gian:</strong>
            <script>
                var date = new Date('${booking.appointmentStart}');
                document.write(date.toLocaleString('vi-VN'));
            </script>
        </p>
        <p><strong>Dịch vụ:</strong>
            <%
                for (int i = 0; i < bookingServices.size(); i++) {
                    model.BookingServiceItem item = bookingServices.get(i);
                    out.print(item.getServiceName());
                    if (i < bookingServices.size() - 1) out.print(", ");
                }
            %>
        </p>
        <div class="amount">
            <%= String.format("%,.0f", totalAmount) %> VND
        </div>
    </div>

    <div class="qr-container">
        <div id="qr-section">
            <img id="qr-code" class="qr-code" src="" alt="QR Code" style="display: none;">
            <div id="qr-loading" style="padding: 50px;">
                <div class="loading-spinner"></div>
                Đang tạo mã QR thanh toán...
            </div>
        </div>
        <p style="color: #666; margin-top: 15px;">
            <i class="fas fa-info-circle"></i>
            Mở ứng dụng ngân hàng hoặc ví điện tử để quét mã QR
        </p>
    </div>

    <div id="status-message"></div>

    <button class="btn-cancel" onclick="cancelPayment()">
        <i class="fas fa-times"></i> Hủy thanh toán
    </button>
</div>

<script>
let paymentUrl = '';
let checkInterval;

$(document).ready(function() {
    createPayment();
});

function createPayment() {
    $.ajax({
        url: '${pageContext.request.contextPath}/payos/create-payment',
        type: 'GET',
        headers: {
            'X-Requested-With': 'XMLHttpRequest'
        },
        data: {
            orderId: <%= orderId %>,
            type: 'service'
        },
        success: function(response) {
            if (response.success && response.url) {
                paymentUrl = response.url;
                // Generate QR code from URL
                generateQRCode(response.url);
                // Start checking payment status
                startStatusCheck();
            } else {
                showError('Không thể tạo thanh toán. Vui lòng thử lại.');
            }
        },
        error: function() {
            showError('Lỗi kết nối. Vui lòng thử lại.');
        }
    });
}

function generateQRCode(url) {
    // Use QR Server API to generate QR code
    const qrUrl = 'https://api.qrserver.com/v1/create-qr-code/?size=256x256&data=' + encodeURIComponent(url);
    $('#qr-code').attr('src', qrUrl).show();
    $('#qr-loading').hide();
}

function startStatusCheck() {
    $('#status-message').html('<div class="status-checking"><div class="loading-spinner"></div>Đang kiểm tra trạng thái thanh toán...</div>');

    checkInterval = setInterval(function() {
        checkPaymentStatus();
    }, 3000); // Check every 3 seconds
}

function checkPaymentStatus() {
    $.ajax({
        url: '${pageContext.request.contextPath}/api/payment-status',
        type: 'GET',
        data: {
            orderId: <%= orderId %>,
            type: 'service'
        },
        success: function(response) {
            if (response.status === 'completed') {
                clearInterval(checkInterval);
                showSuccess();
            } else if (response.status === 'failed') {
                clearInterval(checkInterval);
                showError('Thanh toán thất bại. Vui lòng thử lại.');
            }
            // Continue checking if still pending
        },
        error: function() {
            // Continue checking on error
        }
    });
}

function showSuccess() {
    $('#status-message').html('<div class="status-success"><i class="fas fa-check-circle"></i> Thanh toán thành công! Đang chuyển hướng...</div>');
    setTimeout(function() {
        window.location.href = '${pageContext.request.contextPath}/customer/booking?action=history&success=payment_completed';
    }, 2000);
}

function showError(message) {
    clearInterval(checkInterval);
    $('#status-message').html('<div class="status-error"><i class="fas fa-exclamation-circle"></i> ' + message + '</div>');
    $('#qr-section').hide();
}

function cancelPayment() {
    if (confirm('Bạn có chắc chắn muốn hủy thanh toán?')) {
        // Clear session data for pending booking
        $.ajax({
            url: '${pageContext.request.contextPath}/customer/booking',
            type: 'POST',
            data: {
                action: 'cancel-pending'
            },
            success: function() {
                window.location.href = '${pageContext.request.contextPath}/customer/booking?action=form&error=payment_cancelled';
            },
            error: function() {
                alert('Có lỗi xảy ra khi hủy thanh toán.');
            }
        });
    }
}
</script>

</body>
</html>