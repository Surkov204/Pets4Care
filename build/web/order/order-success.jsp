<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.Customer, model.Order, dao.OrderDAO" %>
<%@ page session="true" %>
<%
    Customer currentUser = (Customer) session.getAttribute("currentUser");
    String orderId = request.getParameter("orderId");
    String method = request.getParameter("method");

    Order order = null;
    double totalAmount = 0;
    try {
        int id = Integer.parseInt(orderId);
        order = new OrderDAO().getOrderById(id);
        if (order != null) {
            totalAmount = order.getTotalAmount();
        }
    } catch (Exception e) {
        order = null;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>Đặt hàng thành công</title>
    <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="flex flex-col items-center justify-center min-h-screen bg-green-50 text-center font-sans px-4">

    <div class="bg-white p-6 rounded-xl shadow-md w-full max-w-xl">
        <h1 class="text-3xl font-bold text-green-600 mb-4">🎉 Đặt hàng thành công!</h1>

        <% if (currentUser != null && order != null) { %>
            <p class="text-lg mb-2">Cảm ơn <strong><%= currentUser.getName() %></strong> đã mua hàng tại Petcity.</p>
            <p class="mb-2">Mã đơn hàng của bạn: <strong>#<%= order.getOrderId() %></strong></p>
            <p class="mb-4">Bạn có thể xem <a href="<%= request.getContextPath() %>/order/order-history.jsp" class="text-blue-500 underline">lịch sử đơn hàng</a>.</p>
        <% } else { %>
            <p class="text-lg text-red-500">Không thể hiển thị đơn hàng. Vui lòng thử lại sau.</p>
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
        <% } else if ("Tiền mặt".equalsIgnoreCase(method)) { %>
            <p class="mt-6 text-green-600 font-semibold">🛍 Bạn đã chọn thanh toán tiền mặt khi nhận hàng.</p>
        <% } %>

        <a href="<%= request.getContextPath() %>/home" class="mt-6 inline-block bg-gray-300 text-gray-800 px-4 py-2 rounded hover:bg-gray-400">
            ⬅ Về trang chủ
        </a>
    </div>

</body>
</html>
