<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="model.Order" %>
<%
    List<Order> orders = (List<Order>) request.getAttribute("orders");
    int customerId = (int) request.getAttribute("customerId");
%>
<!DOCTYPE html>
<html>
<head>
    <title>Lịch sử đơn hàng</title>
    <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-gray-100 p-6">
    <div class="max-w-5xl mx-auto bg-white p-6 rounded shadow">
        <h1 class="text-2xl font-bold mb-4">Lịch sử đơn hàng - Khách hàng #<%= customerId %></h1>
        <a href="manage-customer" class="text-blue-600 underline mb-4 inline-block">← Quay lại danh sách khách hàng</a>

        <table class="w-full border mt-4">
            <thead class="bg-gray-200">
                <tr>
                    <th class="p-3 border">Mã đơn</th>
                    <th class="p-3 border">Ngày đặt</th>
                    <th class="p-3 border">Tổng tiền</th>
                    <th class="p-3 border">Trạng thái</th>
                    <th class="p-3 border">Thanh toán</th>
                    <th class="p-3 border">Phương thức</th>
                </tr>
            </thead>
            <tbody>
            <% if (orders != null && !orders.isEmpty()) {
                for (Order o : orders) { %>
                <tr class="hover:bg-gray-50">
                    <td class="p-3 border"><%= o.getOrderId() %></td>
                    <td class="p-3 border"><%= o.getOrderDate() %></td>
                    <td class="p-3 border"><%= o.getTotalAmount() %> đ</td>
                    <td class="p-3 border"><%= o.getStatus() %></td>
                    <td class="p-3 border"><%= o.getPaymentStatus() %></td>
                    <td class="p-3 border"><%= o.getPaymentMethod() %></td>
                </tr>
            <% }} else { %>
                <tr><td colspan="6" class="p-4 text-center text-gray-500">Không có đơn hàng nào.</td></tr>
            <% } %>
            </tbody>
        </table>
    </div>
</body>
</html>
