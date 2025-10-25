<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.Admin" %>
<%@ page import="model.Customer" %>
<%@ page import="model.Order" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.util.Locale" %>
<%
    Admin admin = (Admin) session.getAttribute("admin");
    if (admin == null) {
        response.sendRedirect("../login.jsp");
        return;
    }
    
    Customer customer = (Customer) request.getAttribute("customer");
    List<Order> orders = (List<Order>) request.getAttribute("orders");
    
    if (customer == null) {
        response.sendRedirect("manage-customer");
        return;
    }
    
    SimpleDateFormat dateFormat = new SimpleDateFormat("dd/MM/yyyy HH:mm");
    NumberFormat currencyFormat = NumberFormat.getInstance(new Locale("vi", "VN"));
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Đơn hàng của <%= customer.getName() %> - PET TOY SHOP</title>
    <link rel="stylesheet" href="../css/homeStyle.css">
    <style>
        .admin-sidebar {
            width: 250px;
            height: 100vh;
            background: var(--card-bg);
            padding: 2rem 1.5rem;
            border-right: 2px solid rgba(111, 213, 221, 0.2);
            box-shadow: var(--shadow-light);
            position: fixed;
            top: 0;
            left: 0;
        }

        .admin-sidebar h2 {
            font-size: 1.4rem;
            font-family: 'Baloo 2', cursive;
            color: var(--primary);
            margin-bottom: 1.5rem;
        }

        .admin-sidebar ul {
            list-style: none;
            padding: 0;
        }

        .admin-sidebar li {
            margin-bottom: 1rem;
        }

        .admin-sidebar a {
            text-decoration: none;
            color: var(--text);
            font-weight: 600;
            transition: var(--transition);
            display: block;
            padding: 0.5rem 1rem;
            border-radius: var(--border-radius-small);
        }

        .admin-sidebar a:hover, .admin-sidebar a.active {
            color: var(--primary);
            background: var(--accent);
            transform: translateX(5px);
        }

        .admin-content {
            margin-left: 250px;
            padding: 2rem;
            background: var(--main-bg);
            min-height: 100vh;
        }

        .admin-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 2rem;
            padding-bottom: 1rem;
            border-bottom: 2px solid rgba(111, 213, 221, 0.2);
        }

        .admin-header h1 {
            font-size: 2rem;
            color: var(--primary);
            font-family: 'Baloo 2', cursive;
        }

        .customer-info {
            background: var(--card-bg);
            padding: 1.5rem;
            border-radius: var(--border-radius);
            margin-bottom: 2rem;
            box-shadow: var(--shadow-light);
            display: flex;
            align-items: center;
            gap: 1.5rem;
        }

        .customer-avatar {
            width: 70px;
            height: 70px;
            border-radius: 50%;
            background: linear-gradient(135deg, var(--primary), var(--accent-pink));
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 2rem;
            color: white;
            font-weight: 700;
            flex-shrink: 0;
        }

        .customer-details h3 {
            margin: 0 0 0.5rem 0;
            color: var(--text);
            font-size: 1.3rem;
        }

        .customer-details p {
            margin: 0.25rem 0;
            color: var(--text-light);
            font-size: 0.95rem;
        }

        .orders-container {
            background: var(--card-bg);
            padding: 2rem;
            border-radius: var(--border-radius);
            box-shadow: var(--shadow-light);
        }

        .orders-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 1.5rem;
        }

        .orders-header h2 {
            font-size: 1.5rem;
            color: var(--text);
            font-family: 'Baloo 2', cursive;
            margin: 0;
        }

        .order-count {
            background: var(--primary);
            color: white;
            padding: 0.5rem 1rem;
            border-radius: var(--border-radius-small);
            font-weight: 600;
        }

        .orders-table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 1rem;
        }

        .orders-table thead {
            background: linear-gradient(135deg, rgba(111, 213, 221, 0.2), rgba(247, 149, 193, 0.2));
        }

        .orders-table th {
            padding: 1rem;
            text-align: left;
            font-weight: 700;
            color: var(--text);
            border-bottom: 2px solid rgba(111, 213, 221, 0.3);
        }

        .orders-table th.text-center {
            text-align: center;
        }

        .orders-table td {
            padding: 1rem;
            border-bottom: 1px solid rgba(111, 213, 221, 0.1);
            color: var(--text-light);
        }

        .orders-table td.text-center {
            text-align: center;
        }

        .orders-table tbody tr {
            transition: var(--transition);
        }

        .orders-table tbody tr:hover {
            background: rgba(111, 213, 221, 0.05);
        }

        .status-badge {
            padding: 0.4rem 0.8rem;
            border-radius: var(--border-radius-small);
            font-size: 0.85rem;
            font-weight: 600;
            display: inline-block;
        }

        .status-pending {
            background: #fef3c7;
            color: #92400e;
        }

        .status-processing {
            background: #dbeafe;
            color: #1e40af;
        }

        .status-completed {
            background: #d1fae5;
            color: #065f46;
        }

        .status-cancelled {
            background: #fee2e2;
            color: #991b1b;
        }

        .payment-badge {
            padding: 0.4rem 0.8rem;
            border-radius: var(--border-radius-small);
            font-size: 0.85rem;
            font-weight: 600;
            display: inline-block;
        }

        .payment-paid {
            background: #d1fae5;
            color: #065f46;
        }

        .payment-unpaid {
            background: #fee2e2;
            color: #991b1b;
        }

        .payment-pending {
            background: #fef3c7;
            color: #92400e;
        }

        .btn {
            padding: 0.6rem 1.5rem;
            border-radius: var(--border-radius);
            border: none;
            cursor: pointer;
            font-size: 0.95rem;
            color: white;
            text-decoration: none;
            font-weight: 600;
            transition: var(--transition);
            display: inline-block;
        }

        .btn-primary {
            background: var(--primary);
        }

        .btn-primary:hover {
            background: var(--accent-pink);
            transform: translateY(-2px);
            box-shadow: var(--shadow-button-hover);
        }

        .btn-back {
            background: #6b7280;
        }

        .btn-back:hover {
            background: #4b5563;
        }

        .btn-view {
            background: #3b82f6;
            padding: 0.4rem 1rem;
            font-size: 0.85rem;
        }

        .btn-view:hover {
            background: #2563eb;
        }

        .empty-state {
            text-align: center;
            padding: 3rem;
            color: var(--text-light);
        }

        .empty-state img {
            width: 150px;
            opacity: 0.5;
            margin-bottom: 1rem;
        }

        .empty-state p {
            font-size: 1.1rem;
            margin: 1rem 0;
        }

        .back-to-site {
            margin-top: 3rem;
            display: block;
            text-align: center;
            font-size: 0.95rem;
            color: var(--primary);
            background: var(--accent);
            padding: 0.6rem 1rem;
            border-radius: var(--border-radius-small);
            text-decoration: none;
            font-weight: 600;
            transition: var(--transition);
        }

        .back-to-site:hover {
            background: var(--accent-pink);
            color: white;
            transform: translateY(-2px);
            box-shadow: var(--shadow-button-hover);
        }
    </style>
</head>
<body>

<!-- Sidebar -->
<div class="admin-sidebar">
    <h2>🐾 Admin Panel</h2>
    <ul>
        <li><a href="toys?action=list">🧸 Sản phẩm</a></li>
        <li><a href="suppliers?action=list">📦 Nhà cung cấp</a></li>
        <li><a href="categories?action=list">📂 Danh mục</a></li>
        <li><a href="manage-customer" class="active">👥 Khách hàng</a></li>
        <li><a href="manage-staff">👤 Nhân viên</a></li>
        <li><a href="customer-profile.jsp">🛒 Khách hàng</a></li>
        <li><a href="statistic.jsp">📊 Thống kê</a></li>
        <li><a href="../logout.jsp">🚪 Đăng xuất</a></li>
    </ul>
    <a href="../home" class="back-to-site">◀ Về trang chủ</a>
</div>

<!-- Main Content -->
<div class="admin-content">
    <!-- Header -->
    <div class="admin-header">
        <h1>📦 Đơn hàng của khách hàng</h1>
        <div style="display: flex; gap: 1rem;">
            <a href="view-customer?id=<%= customer.getCustomerId() %>" class="btn btn-back">◀ Quay lại</a>
            <a href="manage-customer" class="btn btn-primary">👥 Danh sách KH</a>
        </div>
    </div>

    <!-- Customer Info -->
    <div class="customer-info">
        <div class="customer-avatar">
            <%= customer.getName().substring(0, 1).toUpperCase() %>
        </div>
        <div class="customer-details">
            <h3>👤 <%= customer.getName() %></h3>
            <p>📧 <%= customer.getEmail() %></p>
            <p>📞 <%= customer.getPhone() != null ? customer.getPhone() : "Chưa cập nhật" %></p>
            <p>🆔 Mã KH: #<%= customer.getCustomerId() %></p>
        </div>
    </div>

    <!-- Orders Container -->
    <div class="orders-container">
        <div class="orders-header">
            <h2>📋 Danh sách đơn hàng</h2>
            <div class="order-count">
                <%= orders != null ? orders.size() : 0 %> đơn hàng
            </div>
        </div>

        <% if (orders != null && !orders.isEmpty()) { %>
        <table class="orders-table">
            <thead>
                <tr>
                    <th style="width: 80px;">Mã đơn</th>
                    <th style="width: 180px;">Ngày đặt</th>
                    <th style="width: 150px;">Tổng tiền</th>
                    <th style="width: 150px;" class="text-center">Phương thức TT</th>
                    <th style="width: 150px;" class="text-center">Trạng thái TT</th>
                    <th style="width: 150px;" class="text-center">Trạng thái đơn</th>
                </tr>
            </thead>
            <tbody>
                <% for (Order order : orders) { %>
                <tr>
                    <td><strong>#<%= order.getOrderId() %></strong></td>
                    <td><%= dateFormat.format(order.getOrderDate()) %></td>
                    <td><strong style="color: var(--primary);"><%= currencyFormat.format(order.getTotalAmount()) %> đ</strong></td>
                    <td class="text-center">
                        <% 
                        String paymentMethod = order.getPaymentMethod();
                        if (paymentMethod == null) paymentMethod = "Không rõ";
                        %>
                        <%= paymentMethod %>
                    </td>
                    <td class="text-center">
                        <%
                        String paymentStatus = order.getPaymentStatus();
                        if (paymentStatus == null) paymentStatus = "pending";
                        String paymentClass = "payment-pending";
                        String paymentText = "Chờ thanh toán";
                        
                        if ("paid".equalsIgnoreCase(paymentStatus) || "Đã thanh toán".equals(paymentStatus)) {
                            paymentClass = "payment-paid";
                            paymentText = "Đã thanh toán";
                        } else if ("unpaid".equalsIgnoreCase(paymentStatus) || "Chưa thanh toán".equals(paymentStatus)) {
                            paymentClass = "payment-unpaid";
                            paymentText = "Chưa thanh toán";
                        }
                        %>
                        <span class="payment-badge <%= paymentClass %>"><%= paymentText %></span>
                    </td>
                    <td class="text-center">
                        <%
                        String status = order.getStatus();
                        if (status == null) status = "pending";
                        String statusClass = "status-pending";
                        String statusText = "Chờ xử lý";
                        
                        if ("completed".equalsIgnoreCase(status) || "Đã hoàn tất".equals(status)) {
                            statusClass = "status-completed";
                            statusText = "Đã hoàn tất";
                        } else if ("processing".equalsIgnoreCase(status) || "Đang xử lý".equals(status)) {
                            statusClass = "status-processing";
                            statusText = "Đang xử lý";
                        } else if ("cancelled".equalsIgnoreCase(status) || "Đã hủy".equals(status)) {
                            statusClass = "status-cancelled";
                            statusText = "Đã hủy";
                        }
                        %>
                        <span class="status-badge <%= statusClass %>"><%= statusText %></span>
                    </td>
                </tr>
                <% } %>
            </tbody>
        </table>
        <% } else { %>
        <div class="empty-state">
            <div style="font-size: 4rem; margin-bottom: 1rem;">📦</div>
            <p><strong>Khách hàng chưa có đơn hàng nào</strong></p>
            <p style="font-size: 0.9rem; color: var(--text-light);">
                Khách hàng <%= customer.getName() %> chưa thực hiện đơn hàng nào.
            </p>
        </div>
        <% } %>
    </div>
</div>

</body>
</html>

