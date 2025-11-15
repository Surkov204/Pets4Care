<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.Customer, model.Order, dao.OrderDAO, dao.BoardingBookingDAO, model.BoardingBooking" %>
<%@ page session="true" %>
<%
    Customer currentUser = (Customer) session.getAttribute("currentUser");
    String orderId = request.getParameter("orderId");
    String bookingId = request.getParameter("bookingId");
    String method = request.getParameter("method");
    String type = request.getParameter("type"); // boarding | product | service

    Order order = null;
    BoardingBooking booking = null;
    double totalAmount = 0;
    String displayType = "product";
    
    try {
        if ("boarding".equals(type) && bookingId != null) {
            int id = Integer.parseInt(bookingId);
            booking = new BoardingBookingDAO().getBoardingBookingById(id);
            if (booking != null) {
                totalAmount = booking.getTotalPrice() != null ? booking.getTotalPrice().doubleValue() : 0;
                displayType = "boarding";
            }
        } else if (orderId != null) {
            int id = Integer.parseInt(orderId);
            order = new OrderDAO().getOrderById(id);
            if (order != null) {
                totalAmount = order.getTotalAmount();
                displayType = "product";
            }
        }
    } catch (Exception e) {
        order = null;
        booking = null;
    }
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>🎉 Đặt hàng thành công - Petcity</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
</head>
<body class="flex flex-col items-center justify-center min-h-screen bg-green-50 text-center font-sans px-4">

    <div class="bg-white p-6 rounded-xl shadow-md w-full max-w-xl">
        <h1 class="text-3xl font-bold text-green-600 mb-4">🎉 Đặt hàng thành công!</h1>

        <% if (currentUser != null) { %>
            <% if ("boarding".equals(displayType) && booking != null) { %>
                <p class="text-lg mb-2">Cảm ơn <strong><%= currentUser.getName() %></strong> đã đặt phòng lưu trú tại Petcity.</p>
                <p class="mb-2">Mã đặt phòng của bạn: <strong>#<%= booking.getBookingId() %></strong></p>
                <p class="mb-4">Bạn có thể xem <a href="<%= request.getContextPath() %>/spa-booking?action=history" class="text-blue-500 underline">lịch sử đặt phòng</a>.</p>
            <% } else if (order != null) { %>
                <p class="text-lg mb-2">Cảm ơn <strong><%= currentUser.getName() %></strong> đã mua hàng tại Petcity.</p>
                <p class="mb-2">Mã đơn hàng của bạn: <strong>#<%= order.getOrderId() %></strong></p>
                <p class="mb-4">Bạn có thể xem <a href="<%= request.getContextPath() %>/order/order-history.jsp" class="text-blue-500 underline">lịch sử đơn hàng</a>.</p>
            <% } else { %>
                <p class="text-lg text-red-500">Không thể hiển thị đơn hàng. Vui lòng thử lại sau.</p>
            <% } %>
        <% } else { %>
            <p class="text-lg text-red-500">Vui lòng đăng nhập để xem đơn hàng.</p>
        <% } %>

        <% if ("Chuyển khoản".equalsIgnoreCase(method) && order != null) { %>
            <div class="my-6">
                <h2 class="text-xl font-semibold text-gray-700 mb-2">💳 Quét mã QR để thanh toán</h2>
                <p>Ngân hàng: <strong>VietinBank</strong></p>
                <p>Số tài khoản: <strong>0916134642</strong></p>
                <p>Chủ tài khoản: <strong>LÊ VĨNH TIẾN</strong></p>
            </div>

            <img src="https://img.vietqr.io/image/VietinBank-0916134642-compact.png?amount=<%= (int)(totalAmount * 1000) %>&addInfo=DH<%= order.getOrderId() %>"
                class="w-60 mx-auto rounded shadow mb-6" alt="QR Code chuyển khoản">

            <form action="<%= request.getContextPath() %>/confirmpaymentservlet" method="post">
                <input type="hidden" name="orderId" value="<%= order.getOrderId() %>">
                <button type="submit" class="bg-green-600 hover:bg-green-700 text-white font-semibold px-6 py-2 rounded">
                    ✅ Tôi đã thanh toán
                </button>
            </form>

            <p class="text-sm text-gray-500 mt-4">Sau khi xác nhận, đơn hàng sẽ được cập nhật trạng thái "Đã thanh toán".</p>
        <% } else if ("PayOS".equalsIgnoreCase(method) && order != null) { %>
            <div class="my-6">
                <h2 class="text-xl font-semibold text-gray-700 mb-2">💳 Thanh toán online với PayOS</h2>
                <p class="text-gray-600 mb-4">Bạn sẽ được chuyển hướng đến trang thanh toán an toàn của PayOS.</p>
                <p class="text-sm text-gray-500 mb-4">Hỗ trợ thanh toán qua thẻ ATM, thẻ tín dụng, ví điện tử...</p>
            </div>

            <a href="<%= request.getContextPath() %>/payos/create-payment?orderId=<%= order.getOrderId() %>" 
               class="bg-blue-600 hover:bg-blue-700 text-white font-semibold px-6 py-3 rounded inline-block">
                🚀 Thanh toán ngay với PayOS
            </a>

            <p class="text-sm text-gray-500 mt-4">Sau khi thanh toán thành công, đơn hàng sẽ được tự động cập nhật trạng thái.</p>
        <% } else if ("Tiền mặt".equalsIgnoreCase(method)) { %>
            <p class="mt-6 text-green-600 font-semibold">🛍 Bạn đã chọn thanh toán tiền mặt khi nhận hàng.</p>
        <% } %>

        <div class="mt-6 flex flex-col gap-2">
            <a href="<%= request.getContextPath() %>/order/invoice.jsp?<%= "boarding".equals(displayType) ? "bookingId=" + bookingId + "&type=boarding" : "orderId=" + orderId + "&type=product" %>&method=<%= method != null ? method : "Cash on Delivery" %>" 
               class="inline-block bg-blue-600 hover:bg-blue-700 text-white px-6 py-3 rounded-lg transition shadow-md">
                <i class="fas fa-receipt"></i> Xem hoá đơn
            </a>
            
            <% if ("boarding".equals(displayType) || "service".equals(type)) { %>
                <a href="<%= request.getContextPath() %>/spa-booking?action=history" 
                   class="inline-block bg-green-600 hover:bg-green-700 text-white px-6 py-3 rounded-lg transition shadow-md">
                    <i class="fas fa-history"></i> Lịch sử đặt phòng
                </a>
            <% } else { %>
                <a href="<%= request.getContextPath() %>/order/order-history.jsp" 
                   class="inline-block bg-green-600 hover:bg-green-700 text-white px-6 py-3 rounded-lg transition shadow-md">
                    <i class="fas fa-history"></i> Lịch sử đơn hàng
                </a>
            <% } %>
            
            <a href="<%= request.getContextPath() %>/home" 
               class="inline-block bg-gray-300 text-gray-800 px-4 py-2 rounded hover:bg-gray-400">
                <i class="fas fa-home"></i> Về trang chủ
            </a>
        </div>
    </div>

    <script src="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/js/all.min.js"></script>
</body>
</html>
