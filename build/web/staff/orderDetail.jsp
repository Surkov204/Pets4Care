<%@ page contentType="text/html;charset=UTF-8" %>
<html>
<head><title>Order Detail</title></head>
<body>
    <h2>Order Detail</h2>
    <p><b>Order ID:</b> ${order.id}</p>
    <p><b>Customer:</b> ${order.customerName}</p>
    <p><b>Service:</b> ${order.serviceName}</p>
    <p><b>Date:</b> ${order.date}</p>
    <p><b>Status:</b> ${order.status}</p>
    <a href="viewOrder">Back</a>
</body>
</html>
