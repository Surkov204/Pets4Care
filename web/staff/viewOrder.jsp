<%@ page contentType="text/html;charset=UTF-8" %>
<html>
<head>
    <title>View Orders</title>
</head>
<body>
    <h2>Orders List</h2>
    <table border="1">
        <tr>
            <th>Order ID</th>
            <th>Customer</th>
            <th>Service</th>
            <th>Status</th>
            <th>Actions</th>
        </tr>
        <c:forEach var="order" items="${orderList}">
            <tr>
                <td>${order.id}</td>
                <td>${order.customerName}</td>
                <td>${order.serviceName}</td>
                <td>${order.status}</td>
                <td>
                    <a href="orderDetail?id=${order.id}">View Detail</a>
                    <a href="updateBooking?id=${order.id}">Update Status</a>
                </td>
            </tr>
        </c:forEach>
    </table>
</body>
</html>
