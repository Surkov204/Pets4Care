<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.Customer, model.Order, model.BoardingBooking, dao.OrderDAO, dao.BoardingBookingDAO" %>
<%@ page session="true" %>
<%
    Customer currentUser = (Customer) session.getAttribute("currentUser");
    String orderIdParam = request.getParameter("orderId");
    String bookingIdParam = request.getParameter("bookingId");
    String method = request.getParameter("method");
    String type = request.getParameter("type"); // product | boarding | service
    String serviceIdParam = request.getParameter("serviceId");
    String serviceNameParam = request.getParameter("serviceName");
    String quantityParam = request.getParameter("quantity");
    String amountParam = request.getParameter("amount");
    
    Order order = null;
    BoardingBooking booking = null;
    String orderCode = "";
    String orderDate = "";
    double totalAmount = 0;
    String paymentStatus = "";
    String status = "";
    String itemName = "";
    String invoiceTitle = "";
    String serviceName = serviceNameParam != null ? serviceNameParam : "Dịch vụ";
    int serviceQuantity = 1;
    
    try {
        if ("boarding".equals(type) && bookingIdParam != null) {
            int id = Integer.parseInt(bookingIdParam);
            booking = new BoardingBookingDAO().getBoardingBookingById(id);
            if (booking != null) {
                orderCode = String.valueOf(booking.getBookingId());
                orderDate = booking.getCreatedAt() != null ? booking.getCreatedAt().toString() : "";
                totalAmount = booking.getTotalPrice() != null ? booking.getTotalPrice().doubleValue() : 0;
                paymentStatus = booking.getStatus();
                status = booking.getStatus();
                itemName = booking.getServiceName();
                invoiceTitle = "🏠 Hoá đơn lưu trú thú cưng";
            }
        } else if ("service".equals(type)) {
            // Hoá đơn dịch vụ (spa/service) từ query param
            invoiceTitle = "💆 Hoá đơn dịch vụ";
            paymentStatus = "Đã thanh toán";
            status = "completed";
            try {
                if (quantityParam != null) serviceQuantity = Integer.parseInt(quantityParam);
            } catch (Exception ignore) {}
            try {
                if (amountParam != null) totalAmount = Double.parseDouble(amountParam);
            } catch (Exception ignore) {}
            itemName = serviceName + (serviceIdParam != null ? (" #" + serviceIdParam) : "");
        } else if (orderIdParam != null) {
            int id = Integer.parseInt(orderIdParam);
            order = new OrderDAO().getOrderById(id);
            if (order != null) {
                orderCode = String.valueOf(order.getOrderId());
                orderDate = order.getOrderDate() != null ? order.getOrderDate().toString() : "";
                totalAmount = order.getTotalAmount();
                paymentStatus = order.getPaymentStatus();
                status = order.getStatus();
                itemName = "Đơn hàng #" + order.getOrderId();
                invoiceTitle = "📦 Hoá đơn mua hàng";
            }
        }
    } catch (Exception e) {
        e.printStackTrace();
    }
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= "cancelled".equals(status) ? "❌ Hủy đơn hàng" : "✅ Hoá đơn" %></title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <style>
        @media print {
            .no-print { display: none; }
        }
    </style>
</head>
<body class="bg-gray-50 p-4">

<div class="max-w-3xl mx-auto bg-white shadow-lg rounded-lg overflow-hidden">
    <!-- Header -->
    <div class="bg-gradient-to-r from-blue-600 to-green-600 text-white p-6">
        <div class="flex justify-between items-start">
            <div>
                <h1 class="text-3xl font-bold"><%= invoiceTitle %></h1>
                <p class="text-blue-100 mt-2">
                    <i class="fas fa-calendar-alt"></i> <%= orderDate %>
                </p>
            </div>
            <% if ("cancelled".equals(status)) { %>
                <div class="bg-red-500 text-white px-4 py-2 rounded-lg">
                    <i class="fas fa-times-circle"></i> Đã hủy
                </div>
            <% } else { %>
                <div class="bg-green-500 text-white px-4 py-2 rounded-lg">
                    <i class="fas fa-check-circle"></i> <%= paymentStatus != null ? paymentStatus : "Đã xác nhận" %>
                </div>
            <% } %>
        </div>
    </div>

    <!-- Customer Info -->
    <div class="p-6 border-b border-gray-200">
        <h2 class="text-xl font-semibold text-gray-800 mb-3">
            <i class="fas fa-user text-blue-600"></i> Thông tin khách hàng
        </h2>
        <% if (currentUser != null) { %>
            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div>
                    <p class="text-gray-600">Họ tên:</p>
                    <p class="font-semibold text-gray-800"><%= currentUser.getName() %></p>
                </div>
                <div>
                    <p class="text-gray-600">Email:</p>
                    <p class="font-semibold text-gray-800"><%= currentUser.getEmail() %></p>
                </div>
                <div>
                    <p class="text-gray-600">Số điện thoại:</p>
                    <p class="font-semibold text-gray-800"><%= currentUser.getPhone() %></p>
                </div>
                <div>
                    <p class="text-gray-600">Mã đơn hàng:</p>
                    <p class="font-semibold text-blue-600">#<%= orderCode %></p>
                </div>
            </div>
        <% } %>
    </div>

    <!-- Order Details -->
    <div class="p-6">
        <h2 class="text-xl font-semibold text-gray-800 mb-3">
            <i class="fas fa-list text-green-600"></i> Chi tiết đơn hàng
        </h2>
        
        <% if ("boarding".equals(type) && booking != null) { %>
            <!-- Boarding Invoice -->
            <div class="bg-gray-50 rounded-lg p-4 mb-4">
                <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <div>
                        <p class="text-sm text-gray-600">Loại phòng:</p>
                        <p class="font-semibold text-gray-800"><%= booking.getRoomType() %></p>
                    </div>
                    <div>
                        <p class="text-sm text-gray-600">Giá/ngày:</p>
                        <p class="font-semibold text-gray-800"><%= String.format("%,.0f", booking.getPricePerDay().doubleValue()) %> ₫</p>
                    </div>
                    <div>
                        <p class="text-sm text-gray-600">Số ngày:</p>
                        <p class="font-semibold text-gray-800"><%= booking.getBoardingDays() %> ngày</p>
                    </div>
                    <div>
                        <p class="text-sm text-gray-600">Tổng tiền:</p>
                        <p class="font-semibold text-green-600 text-lg"><%= String.format("%,.0f", totalAmount) %> ₫</p>
                    </div>
                    <div>
                        <p class="text-sm text-gray-600">Ngày nhận:</p>
                        <p class="font-semibold text-gray-800"><%= booking.getCheckInDate() != null ? booking.getCheckInDate().toString().substring(0, 10) : "" %></p>
                    </div>
                    <div>
                        <p class="text-sm text-gray-600">Ngày trả:</p>
                        <p class="font-semibold text-gray-800"><%= booking.getCheckOutDate() != null ? booking.getCheckOutDate().toString().substring(0, 10) : "" %></p>
                    </div>
                    <% if (booking.getSpecialNotes() != null && !booking.getSpecialNotes().isEmpty()) { %>
                        <div class="col-span-2">
                            <p class="text-sm text-gray-600">Ghi chú:</p>
                            <p class="font-semibold text-gray-800"><%= booking.getSpecialNotes() %></p>
                        </div>
                    <% } %>
                </div>
            </div>
        <% } else if ("service".equals(type)) { %>
            <!-- Service Invoice (success) -->
            <div class="bg-gray-50 rounded-lg p-4 mb-4">
                <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <div>
                        <p class="text-sm text-gray-600">Dịch vụ:</p>
                        <p class="font-semibold text-gray-800"><%= itemName %></p>
                    </div>
                    <div>
                        <p class="text-sm text-gray-600">Số lượng:</p>
                        <p class="font-semibold text-gray-800"><%= serviceQuantity %></p>
                    </div>
                    <div>
                        <p class="text-sm text-gray-600">Trạng thái thanh toán:</p>
                        <p class="font-semibold text-green-600"><%= paymentStatus %></p>
                    </div>
                </div>
            </div>
        <% } else if (order != null) { %>
            <!-- Product Invoice -->
            <div class="bg-gray-50 rounded-lg p-4 mb-4">
                <p class="font-semibold text-gray-800"><%= itemName %></p>
                <p class="text-gray-600 text-sm mt-1">
                    <%= paymentStatus != null ? paymentStatus : "Đã xác nhận" %>
                </p>
            </div>
        <% } %>

        <!-- Payment Method -->
        <div class="border-t border-gray-200 pt-4 mt-4">
            <div class="flex justify-between items-center">
                <span class="text-gray-600">Phương thức thanh toán:</span>
                <span class="font-semibold text-gray-800">
                    <%= method != null ? method : "Chưa xác định" %>
                </span>
            </div>
            <div class="flex justify-between items-center mt-2">
                <span class="text-gray-600">Tổng tiền:</span>
                <span class="font-bold text-xl text-green-600"><%= String.format("%,.0f", totalAmount) %> ₫</span>
            </div>
        </div>
    </div>

    <!-- Footer -->
    <div class="bg-gray-100 p-6 border-t border-gray-200">
        <p class="text-sm text-gray-600 text-center">
            <i class="fas fa-info-circle"></i> 
            Cảm ơn bạn đã sử dụng dịch vụ của chúng tôi!
        </p>
        <p class="text-xs text-gray-500 text-center mt-2">
            Hotline: 1900-xxxx | Email: support@pets4care.com
        </p>
    </div>
</div>

<!-- Action Buttons -->
<div class="max-w-3xl mx-auto mt-6 flex justify-center gap-4 no-print">
    <a href="<%= request.getContextPath() %>/home" 
       class="bg-gray-500 hover:bg-gray-600 text-white px-6 py-3 rounded-lg transition shadow-md">
        <i class="fas fa-home"></i> Về trang chủ
    </a>
    
    <% if ("boarding".equals(type) || "service".equals(type)) { %>
        <a href="<%= request.getContextPath() %>/spa-booking?action=history" 
           class="bg-blue-500 hover:bg-blue-600 text-white px-6 py-3 rounded-lg transition shadow-md">
            <i class="fas fa-history"></i> Lịch sử đặt phòng
        </a>
    <% } else { %>
        <a href="<%= request.getContextPath() %>/order/order-history.jsp" 
           class="bg-blue-500 hover:bg-blue-600 text-white px-6 py-3 rounded-lg transition shadow-md">
            <i class="fas fa-history"></i> Lịch sử đơn hàng
        </a>
    <% } %>
    
    <button onclick="window.print()" 
            class="bg-green-500 hover:bg-green-600 text-white px-6 py-3 rounded-lg transition shadow-md">
        <i class="fas fa-print"></i> In hoá đơn
    </button>
</div>

</body>
</html>

