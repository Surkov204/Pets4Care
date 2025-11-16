<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.Customer, model.Order, model.BoardingBooking, model.Booking, dao.OrderDAO, dao.BoardingBookingDAO, dao.BookingDAO" %>
<%@ page session="true" %>
<%
    Customer currentUser = (Customer) session.getAttribute("currentUser");
    String orderIdParam = request.getParameter("orderId");
    String bookingIdParam = request.getParameter("bookingId");
    String method = request.getParameter("method");
    String type = request.getParameter("type"); // product | boarding | service | health_check
    String serviceIdParam = request.getParameter("serviceId");
    String serviceNameParam = request.getParameter("serviceName");
    String quantityParam = request.getParameter("quantity");
    String amountParam = request.getParameter("amount");
    
    Order order = null;
    BoardingBooking boardingBooking = null;
    Booking healthCheckBooking = null;
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
        if ("health_check".equals(type)) {
            // Hoá đơn khám sức khỏe
            invoiceTitle = "🏥 Hoá đơn khám sức khỏe";
            paymentStatus = "Đã thanh toán";
            status = "completed";
            
            if (bookingIdParam != null && !bookingIdParam.trim().isEmpty()) {
                // Có booking_id, lấy thông tin từ database
                try {
                    int id = Integer.parseInt(bookingIdParam);
                    healthCheckBooking = new BookingDAO().getBookingById(id);
                    if (healthCheckBooking != null) {
                        orderCode = String.valueOf(healthCheckBooking.getBookingId());
                        orderDate = healthCheckBooking.getCreatedAt() != null ? healthCheckBooking.getCreatedAt().toString() : "";
                        status = healthCheckBooking.getStatus() != null ? healthCheckBooking.getStatus() : "pending";
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
            
            // Lấy thông tin từ query params nếu không có từ database
            if (orderCode.isEmpty() && serviceIdParam != null) {
                orderCode = "HC-" + serviceIdParam;
            }
            if (orderDate.isEmpty()) {
                java.util.Date now = new java.util.Date();
                java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
                orderDate = sdf.format(now);
            }
            
            // Lấy số tiền từ query param
            try {
                if (amountParam != null && !amountParam.trim().isEmpty()) {
                    totalAmount = Double.parseDouble(amountParam);
                }
            } catch (Exception ignore) {}
            
            itemName = serviceName + (serviceIdParam != null ? (" #" + serviceIdParam) : "");
        } else if ("boarding".equals(type) && bookingIdParam != null) {
            int id = Integer.parseInt(bookingIdParam);
            boardingBooking = new BoardingBookingDAO().getBoardingBookingById(id);
            if (boardingBooking != null) {
                orderCode = String.valueOf(boardingBooking.getBookingId());
                orderDate = boardingBooking.getCreatedAt() != null ? boardingBooking.getCreatedAt().toString() : "";
                totalAmount = boardingBooking.getTotalPrice() != null ? boardingBooking.getTotalPrice().doubleValue() : 0;
                paymentStatus = boardingBooking.getStatus();
                status = boardingBooking.getStatus();
                itemName = boardingBooking.getServiceName();
                invoiceTitle = "🏠 Hoá đơn lưu trú thú cưng";
            }
        } else if ("service".equals(type)) {
            // Hoá đơn dịch vụ (spa/service) từ query param
            invoiceTitle = "💆 Hoá đơn dịch vụ";
            paymentStatus = "Đã thanh toán";
            status = "completed";
            
            // Nếu có bookingId, lấy thông tin từ database
            if (bookingIdParam != null && !bookingIdParam.trim().isEmpty()) {
                try {
                    int id = Integer.parseInt(bookingIdParam);
                    Booking spaBooking = new BookingDAO().getBookingById(id);
                    if (spaBooking != null) {
                        orderCode = String.valueOf(spaBooking.getBookingId());
                        orderDate = spaBooking.getCreatedAt() != null ? spaBooking.getCreatedAt().toString() : "";
                        status = spaBooking.getStatus() != null ? spaBooking.getStatus() : "completed";
                        
                        // Lấy thông tin dịch vụ từ booking
                        if (spaBooking.getServiceNames() != null && !spaBooking.getServiceNames().isEmpty()) {
                            serviceName = spaBooking.getServiceNames();
                        }
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
            
            // Lấy thông tin từ query params nếu không có từ database
            if (orderCode.isEmpty() && bookingIdParam != null) {
                orderCode = bookingIdParam;
            }
            if (orderDate.isEmpty()) {
                java.util.Date now = new java.util.Date();
                java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
                orderDate = sdf.format(now);
            }
            
            try {
                if (quantityParam != null) serviceQuantity = Integer.parseInt(quantityParam);
            } catch (Exception ignore) {}
            try {
                if (amountParam != null && !amountParam.trim().isEmpty()) {
                    totalAmount = Double.parseDouble(amountParam);
                }
            } catch (Exception ignore) {}
            itemName = serviceName + (bookingIdParam != null ? (" #" + bookingIdParam) : "");
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
    <title><%= "cancelled".equals(status) ? "❌ Hủy đơn hàng" : "✅ Hoá đơn" %> - Petcity</title>
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
        
        <% if ("health_check".equals(type)) { %>
            <!-- Health Check Invoice -->
            <div class="bg-gray-50 rounded-lg p-4 mb-4">
                <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <div>
                        <p class="text-sm text-gray-600">Dịch vụ:</p>
                        <p class="font-semibold text-gray-800"><%= itemName %></p>
                    </div>
                    <div>
                        <p class="text-sm text-gray-600">Trạng thái:</p>
                        <p class="font-semibold text-green-600"><%= paymentStatus %></p>
                    </div>
                    <% if (healthCheckBooking != null) { %>
                        <div>
                            <p class="text-sm text-gray-600">Ngày hẹn:</p>
                            <p class="font-semibold text-gray-800">
                                <%= healthCheckBooking.getAppointmentStart() != null ? 
                                    new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm").format(healthCheckBooking.getAppointmentStart()) : "" %>
                            </p>
                        </div>
                        <div>
                            <p class="text-sm text-gray-600">Bác sĩ:</p>
                            <p class="font-semibold text-gray-800">
                                <%= (healthCheckBooking.getDoctorName() != null && !healthCheckBooking.getDoctorName().trim().isEmpty()) 
                                    ? healthCheckBooking.getDoctorName() 
                                    : (healthCheckBooking.getDoctorId() > 0 ? "BS #" + healthCheckBooking.getDoctorId() : "Chưa xác định") %>
                            </p>
                        </div>
                    <% } %>
                    <div class="col-span-2">
                        <p class="text-sm text-gray-600">Tổng tiền:</p>
                        <p class="font-semibold text-green-600 text-lg"><%= String.format("%,.0f", totalAmount) %> ₫</p>
                    </div>
                </div>
            </div>
        <% } else if ("boarding".equals(type) && boardingBooking != null) { %>
            <!-- Boarding Invoice -->
            <div class="bg-gray-50 rounded-lg p-4 mb-4">
                <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <div>
                        <p class="text-sm text-gray-600">Loại phòng:</p>
                        <p class="font-semibold text-gray-800"><%= boardingBooking.getRoomType() %></p>
                    </div>
                    <div>
                        <p class="text-sm text-gray-600">Giá/ngày:</p>
                        <p class="font-semibold text-gray-800"><%= String.format("%,.0f", boardingBooking.getPricePerDay().doubleValue()) %> ₫</p>
                    </div>
                    <div>
                        <p class="text-sm text-gray-600">Số ngày:</p>
                        <p class="font-semibold text-gray-800"><%= boardingBooking.getBoardingDays() %> ngày</p>
                    </div>
                    <div>
                        <p class="text-sm text-gray-600">Tổng tiền:</p>
                        <p class="font-semibold text-green-600 text-lg"><%= String.format("%,.0f", totalAmount) %> ₫</p>
                    </div>
                    <div>
                        <p class="text-sm text-gray-600">Ngày nhận:</p>
                        <p class="font-semibold text-gray-800"><%= boardingBooking.getCheckInDate() != null ? boardingBooking.getCheckInDate().toString().substring(0, 10) : "" %></p>
                    </div>
                    <div>
                        <p class="text-sm text-gray-600">Ngày trả:</p>
                        <p class="font-semibold text-gray-800"><%= boardingBooking.getCheckOutDate() != null ? boardingBooking.getCheckOutDate().toString().substring(0, 10) : "" %></p>
                    </div>
                    <% if (boardingBooking.getSpecialNotes() != null && !boardingBooking.getSpecialNotes().isEmpty()) { %>
                        <div class="col-span-2">
                            <p class="text-sm text-gray-600">Ghi chú:</p>
                            <p class="font-semibold text-gray-800"><%= boardingBooking.getSpecialNotes() %></p>
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
    
    <% if ("health_check".equals(type)) { %>
        <a href="<%= request.getContextPath() %>/health-check-booking?action=history" 
           class="bg-blue-500 hover:bg-blue-600 text-white px-6 py-3 rounded-lg transition shadow-md">
            <i class="fas fa-history"></i> Lịch sử khám sức khỏe
        </a>
    <% } else if ("boarding".equals(type) || "service".equals(type)) { %>
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

