<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.util.*, model.CartItem, model.Toy, model.Order, model.Customer, dao.UserDao" %>
<%@ page session="true" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Chi tiết đơn hàng</title>
    <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="p-8 font-sans bg-gray-50">

<%
    String orderIdRaw = request.getParameter("id");
    if (orderIdRaw == null) {
        response.sendRedirect("order-history.jsp");
        return;
    }

    int orderId = Integer.parseInt(orderIdRaw);
    UserDao userDao = new UserDao();
    List<CartItem> items = userDao.getOrderDetails(orderId);
    Order order = userDao.getOrderById(orderId); // cần hàm getOrderById
    Customer currentUser = (Customer) session.getAttribute("currentUser");
%>

<h2 class="text-2xl font-bold text-gray-800 mb-6">📦 Chi tiết đơn hàng <span class="text-blue-600">#<%= orderId %></span></h2>

<% if (order == null || items == null || items.isEmpty()) { %>
    <p class="text-red-500">Không tìm thấy chi tiết đơn hàng.</p>
<% } else { %>

<div class="bg-white rounded-lg shadow p-6 mb-6">
    <p><strong>👤 Người mua:</strong> <%= currentUser != null ? currentUser.getName() : "Không rõ" %></p>
    <p><strong>🕒 Ngày đặt:</strong> <%= order.getOrderDate() %></p>
    <p><strong>💳 Thanh toán:</strong> <%= order.getPaymentMethod() %> - <%= order.getPaymentStatus() %></p>
    <p><strong>📌 Trạng thái đơn:</strong> <%= order.getStatus() %></p>
</div>

<div class="overflow-x-auto">
    <table class="min-w-full bg-white shadow border text-sm text-left">
        <thead class="bg-blue-100 text-gray-700">
            <tr>
                <th class="px-4 py-2">Tên sản phẩm</th>
                <th class="px-4 py-2">Mô tả</th>
                <th class="px-4 py-2">Giá</th>
                <th class="px-4 py-2">Số lượng</th>
                <th class="px-4 py-2">Thành tiền</th>
            </tr>
        </thead>
        <tbody>
        <%
            double total = 0;
            for (CartItem item : items) {
                double sub = item.getQuantity() * item.getToy().getPrice();
                total += sub;
        %>
            <tr class="border-t hover:bg-gray-50">
                <td class="px-4 py-2"><%= item.getToy().getName() %></td>
                <td class="px-4 py-2 text-gray-600"><%= item.getToy().getDescription() %></td>
                <td class="px-4 py-2"><%= String.format("%.0f", item.getToy().getPrice()) %> đ</td>
                <td class="px-4 py-2"><%= item.getQuantity() %></td>
                <td class="px-4 py-2 font-semibold"><%= String.format("%.0f", sub) %> đ</td>
            </tr>
        <% } %>
        </tbody>
    </table>
</div>

<div class="mt-6 text-lg font-bold text-right text-green-700">
    🧾 Tổng cộng: <span class="text-orange-600"><%= String.format("%.0f", total) %> đ</span>
</div>

<% } %>

<br>
<a href="order-history.jsp" class="text-blue-500 hover:underline">⬅ Quay lại lịch sử đơn hàng</a>

</body>
</html>
