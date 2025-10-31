<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.Customer, dao.UserDAO, model.Order, java.util.*" %>
<%@ page session="true" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Lịch sử đơn hàng</title>
    <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="p-8 font-sans bg-gray-50">

<%
    Customer customer = (Customer) session.getAttribute("currentUser");
    if (customer == null) {
        response.sendRedirect("../login.jsp");
        return;
    }

    List<Order> orders = new UserDAO().getOrdersByCustomerId(customer.getCustomerId());
%>

<h2 class="text-2xl font-bold mb-6">📦 Lịch sử đơn hàng của <%= customer.getName() %></h2>

<% if (orders == null || orders.isEmpty()) { %>
    <p class="text-gray-600">Bạn chưa có đơn hàng nào.</p>
<% } else { %>
    <div class="overflow-x-auto">
        <table class="min-w-full border text-sm text-left bg-white shadow-md">
            <thead class="bg-green-100 text-gray-700">
                <tr>
                    <th class="px-4 py-2">Mã đơn</th>
                    <th class="px-4 py-2">Ngày đặt</th>
                    <th class="px-4 py-2">Thanh toán</th>
                    <th class="px-4 py-2">Phương thức</th>
                    <th class="px-4 py-2">Trạng thái</th>
                    <th class="px-4 py-2">Tổng tiền</th>
                    <th class="px-4 py-2">Thao tác</th>
                </tr>
            </thead>
            <tbody>
            <% for (Order o : orders) { %>
                <tr class="border-t hover:bg-gray-50">
                    <td class="px-4 py-2"><%= o.getOrderId() %></td>
                    <td class="px-4 py-2"><%= o.getOrderDate() %></td>
                    <td class="px-4 py-2"><%= o.getPaymentStatus() %></td>
                    <td class="px-4 py-2"><%= o.getPaymentMethod() %></td>
                    <td class="px-4 py-2">
                        <% if ("Đã hủy".equals(o.getStatus())) { %>
                            <span class="text-red-500"><%= o.getStatus() %></span>
                        <% } else if ("Hoàn tất".equals(o.getStatus())) { %>
                            <span class="text-green-600"><%= o.getStatus() %></span>
                        <% } else { %>
                            <span class="text-yellow-600"><%= o.getStatus() %></span>
                        <% } %>
                    </td>
                    <td class="px-4 py-2"><%= String.format("%.2f", o.getTotalAmount()) %> đ</td>
                    <td class="px-4 py-2">
                        <a class="text-blue-600 hover:underline" href="order-detail.jsp?id=<%= o.getOrderId() %>">Chi tiết</a>
                        <% if (!"Đã hủy".equals(o.getStatus()) && !"Hoàn tất".equals(o.getStatus())) { %>
                            | <a class="text-red-500 hover:underline"
                                 href="<%= request.getContextPath() %>/cancelorder?id=<%= o.getOrderId() %>"
                                 onclick="return confirm('Bạn có chắc muốn hủy đơn hàng này?');">Hủy</a>
                        <% } %>
                    </td>
                </tr>
            <% } %>
            </tbody>
        </table>
    </div>
<% } %>

<br>
<a href="<%= request.getContextPath() %>/home" class="text-blue-500 hover:underline">⬅ Quay về trang chủ</a>

</body>
</html>
