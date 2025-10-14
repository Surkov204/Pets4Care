<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.Order" %>
<%@ page import="model.OrderItem" %>
<%@ page import="java.util.List" %>

<%
    Order order = (Order) request.getAttribute("order");
    List<OrderItem> items = (List<OrderItem>) request.getAttribute("items");
%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Chi tiết đơn hàng</title>
    <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-gray-100 min-h-screen p-8">

    <div class="bg-white rounded shadow p-6 max-w-4xl mx-auto">
        <h1 class="text-2xl font-bold text-blue-700 mb-4">
            Chi tiết đơn hàng #<%= order.getOrderId() %>
        </h1>

        <div class="grid grid-cols-2 gap-4 text-sm text-gray-700 mb-6">
            <div>
                <p><strong>Ngày đặt:</strong> <%= order.getOrderDate() %></p>
                <p><strong>Phương thức thanh toán:</strong> <%= order.getPaymentMethod() %> - <%= order.getPaymentStatus() %></p>
            </div>
            <div>
                <p><strong>Trạng thái:</strong> <%= order.getStatus() %></p>
                <p><strong>Tổng tiền:</strong> <span class="text-green-600 font-semibold"><%= String.format("%,.0f", order.getTotalAmount()) %> đ</span></p>
            </div>
        </div>

        <h2 class="text-md font-semibold text-gray-800 mb-2">Sản phẩm trong đơn:</h2>
        <table class="w-full table-auto border bg-white text-sm">
            <thead class="bg-gray-100 font-semibold">
                <tr>
                    <th class="border px-4 py-2 text-left">Tên sản phẩm</th>
                    <th class="border px-4 py-2 text-center">Số lượng</th>
                    <th class="border px-4 py-2 text-right">Đơn giá</th>
                    <th class="border px-4 py-2 text-right">Thành tiền</th>
                </tr>
            </thead>
            <tbody>
                <% if (items != null && !items.isEmpty()) {
                    for (OrderItem item : items) { %>
                        <tr class="hover:bg-gray-50">
                            <td class="border px-4 py-2"><%= item.getToyName() %></td>
                            <td class="border px-4 py-2 text-center"><%= item.getQuantity() %></td>
                            <td class="border px-4 py-2 text-right"><%= String.format("%,.0f", item.getUnitPrice()) %> đ</td>
                            <td class="border px-4 py-2 text-right"><%= String.format("%,.0f", item.getTotalPrice()) %> đ</td>
                        </tr>
                <%  }
                } else { %>
                    <tr>
                        <td colspan="4" class="text-center text-gray-500 py-4">Không có sản phẩm nào trong đơn.</td>
                    </tr>
                <% } %>
            </tbody>
        </table>

        <a href="manage-order" class="mt-6 inline-block bg-gray-600 hover:bg-gray-700 text-white px-4 py-2 rounded">
            ← Quay lại danh sách đơn hàng
        </a>
    </div>

</body>
</html>
