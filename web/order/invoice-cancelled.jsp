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
    String paymentStatus = "Đã hủy";
    String status = "cancelled";
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
                invoiceTitle = "❌ Hoá đơn hủy lưu trú thú cưng";
            }
        } else if ("service".equals(type)) {
            // Huỷ thanh toán dịch vụ: hiển thị thông tin cơ bản từ query param (nếu có)
            invoiceTitle = "❌ Hoá đơn hủy dịch vụ";
            try {
                if (quantityParam != null) serviceQuantity = Integer.parseInt(quantityParam);
            } catch (Exception ignore) {}
            try {
                if (amountParam != null) totalAmount = Double.parseDouble(amountParam);
            } catch (Exception ignore) {}
        } else if (orderIdParam != null) {
            int id = Integer.parseInt(orderIdParam);
            order = new OrderDAO().getOrderById(id);
            if (order != null) {
                orderCode = String.valueOf(order.getOrderId());
                orderDate = order.getOrderDate() != null ? order.getOrderDate().toString() : "";
                totalAmount = order.getTotalAmount();
                invoiceTitle = "❌ Hoá đơn hủy đặt hàng";
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
    <title>❌ Hủy đơn hàng - Petcity</title>
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
    <div class="bg-gradient-to-r from-red-600 to-orange-600 text-white p-6">
        <div class="flex justify-between items-start">
            <div>
                <h1 class="text-3xl font-bold"><%= invoiceTitle %></h1>
                <p class="text-red-100 mt-2">
                    <i class="fas fa-calendar-alt"></i> <%= orderDate %>
                </p>
            </div>
            <div class="bg-red-700 text-white px-4 py-2 rounded-lg">
                <i class="fas fa-times-circle"></i> Đã hủy
            </div>
        </div>
    </div>

    <!-- Warning Message -->
    <div class="bg-red-50 border-l-4 border-red-600 p-4 m-6">
        <div class="flex items-center">
            <i class="fas fa-exclamation-circle text-red-600 text-2xl mr-3"></i>
            <div>
                <p class="font-semibold text-red-800">Đơn hàng đã được hủy</p>
                <p class="text-sm text-red-600">Không có khoản phí nào được tính cho đơn hàng này.</p>
            </div>
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
                    <p class="font-semibold text-red-600">#<%= orderCode %> (Đã hủy)</p>
                </div>
            </div>
        <% } %>
    </div>

    <!-- Order Details -->
    <div class="p-6">
        <h2 class="text-xl font-semibold text-gray-800 mb-3">
            <i class="fas fa-list text-gray-600"></i> Chi tiết đơn hàng đã hủy
        </h2>
        
        <% if ("boarding".equals(type) && booking != null) { %>
            <!-- Boarding Invoice -->
            <div class="bg-gray-50 rounded-lg p-4 mb-4 opacity-75">
                <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <div>
                        <p class="text-sm text-gray-600">Loại phòng:</p>
                        <p class="font-semibold text-gray-700"><%= booking.getRoomType() %></p>
                    </div>
                    <div>
                        <p class="text-sm text-gray-600">Giá/ngày:</p>
                        <p class="font-semibold text-gray-700"><%= String.format("%,.0f", booking.getPricePerDay().doubleValue()) %> ₫</p>
                    </div>
                    <div>
                        <p class="text-sm text-gray-600">Số ngày:</p>
                        <p class="font-semibold text-gray-700"><%= booking.getBoardingDays() %> ngày</p>
                    </div>
                    <div>
                        <p class="text-sm text-gray-600">Tổng tiền:</p>
                        <p class="font-semibold text-gray-500 line-through"><%= String.format("%,.0f", totalAmount) %> ₫</p>
                    </div>
                </div>
            </div>
        <% } else if ("service".equals(type)) { %>
            <!-- Service Invoice (cancelled) -->
            <div class="bg-gray-50 rounded-lg p-4 mb-4 opacity-75">
                <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <div>
                        <p class="text-sm text-gray-600">Dịch vụ:</p>
                        <p class="font-semibold text-gray-700"><%= serviceName %><%= (serviceIdParam != null ? (" #" + serviceIdParam) : "") %></p>
                    </div>
                    <div>
                        <p class="text-sm text-gray-600">Số lượng:</p>
                        <p class="font-semibold text-gray-700"><%= serviceQuantity %></p>
                    </div>
                    <div>
                        <p class="text-sm text-gray-600">Tổng tiền:</p>
                        <p class="font-semibold text-gray-500 line-through"><%= String.format("%,.0f", totalAmount) %> ₫</p>
                    </div>
                </div>
            </div>
        <% } else if (order != null) { %>
            <!-- Product Invoice -->
            <div class="bg-gray-50 rounded-lg p-4 mb-4 opacity-75">
                <p class="font-semibold text-gray-700">Đơn hàng #<%= order.getOrderId() %></p>
                <p class="text-gray-600 text-sm mt-1">Tổng tiền: <span class="line-through"><%= String.format("%,.0f", totalAmount) %> ₫</span></p>
            </div>
        <% } %>

        <!-- Cancelled Status -->
        <div class="border-t border-gray-200 pt-4 mt-4">
            <div class="flex justify-between items-center bg-red-50 p-3 rounded">
                <span class="text-gray-700 font-semibold">Trạng thái:</span>
                <span class="font-bold text-red-600 text-lg">Đã hủy</span>
            </div>
            <p class="text-sm text-gray-500 mt-3 text-center">
                Đơn hàng này đã được hủy và không còn hiệu lực.
            </p>
        </div>
    </div>

    <!-- Footer -->
    <div class="bg-gray-100 p-6 border-t border-gray-200">
        <p class="text-sm text-gray-600 text-center">
            Nếu bạn có bất kỳ thắc mắc nào, vui lòng liên hệ bộ phận hỗ trợ.
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
            <i class="fas fa-history"></i> Lịch sử đặt phòng/DV Spa
        </a>
    <% } else { %>
        <a href="<%= request.getContextPath() %>/order/order-history.jsp" 
           class="bg-blue-500 hover:bg-blue-600 text-white px-6 py-3 rounded-lg transition shadow-md">
            <i class="fas fa-history"></i> Lịch sử đơn hàng
        </a>
    <% } %>
</div>

</body>
</html>

