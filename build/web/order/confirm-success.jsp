<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.Customer" %>
<%@ page session="true" %>
<%
    Customer currentUser = (Customer) session.getAttribute("currentUser");
%>
<!DOCTYPE html>
<html>
<head>
    <title>Đã thanh toán thành công</title>
    <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="flex items-center justify-center min-h-screen bg-green-50 font-sans">

    <div class="bg-white p-8 rounded-xl shadow-lg text-center max-w-md">
        <h1 class="text-3xl font-bold text-green-600 mb-4">✅ Thanh toán thành công!</h1>

        <% if (currentUser != null) { %>
            <p class="text-lg mb-2">Cảm ơn <strong><%= currentUser.getName() %></strong> đã xác nhận thanh toán.</p>
        <% } else { %>
            <p class="text-lg mb-2">Bạn đã xác nhận thanh toán đơn hàng.</p>
        <% } %>

        <p class="text-gray-600 mb-6">Đơn hàng của bạn đang được xử lý. Hệ thống sẽ cập nhật trạng thái và giao hàng sớm nhất.</p>

        <a href="<%= request.getContextPath() %>/order/order-history.jsp"
           class="inline-block bg-green-600 hover:bg-green-700 text-white px-5 py-2 rounded shadow">
            📦 Xem lịch sử đơn hàng
        </a>

        <a href="<%= request.getContextPath() %>/home"
           class="ml-4 inline-block text-gray-600 hover:underline">
            ⬅ Về trang chủ
        </a>
    </div>

</body>
</html>
