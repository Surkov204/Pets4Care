<%@page import="model.OrderStats"%>
<%@page import="java.util.Map"%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page import="java.util.List" %>
<%@ page import="model.Customer" %>
<%@ page import="model.Admin" %>
<%
    Admin admin = (Admin) session.getAttribute("admin");
    if (admin == null) {
        response.sendRedirect("../login.jsp");
        return;
    }

    List<Customer> customers = (List<Customer>) request.getAttribute("customers");
    Map<Integer, OrderStats> orderStats = (Map<Integer, OrderStats>) request.getAttribute("orderStats");
    String keyword = request.getParameter("keyword") != null ? request.getParameter("keyword") : "";
    String statusFilter = request.getParameter("status") != null ? request.getParameter("status") : "all";
%>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Quản lý khách hàng - PET TOY SHOP</title>
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

            .btn {
                background: var(--primary);
                color: white;
                padding: 0.75rem 1.5rem;
                border: none;
                border-radius: var(--border-radius);
                text-decoration: none;
                font-weight: 600;
                transition: var(--transition);
                display: inline-block;
            }

            .btn:hover {
                background: var(--accent-pink);
                transform: translateY(-2px);
                box-shadow: var(--shadow-button-hover);
            }

            .btn-success {
                background: #10b981;
            }

            .btn-success:hover {
                background: #059669;
            }

            .stats-grid {
                display: grid;
                grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
                gap: 1.5rem;
                margin-bottom: 2rem;
            }

            .stat-card {
                background: var(--card-bg);
                padding: 1.5rem;
                border-radius: var(--border-radius);
                box-shadow: var(--shadow-light);
                text-align: center;
                border: 2px solid rgba(111, 213, 221, 0.2);
            }

            .stat-card h3 {
                color: var(--text-light);
                font-size: 0.9rem;
                margin-bottom: 0.5rem;
                font-weight: 500;
            }

            .stat-card .number {
                font-size: 2rem;
                font-weight: 700;
                font-family: 'Baloo 2', cursive;
            }

            .stat-card.active .number {
                color: #10b981;
            }

            .stat-card.inactive .number {
                color: #ef4444;
            }

            .search-form {
                display: flex;
                gap: 1rem;
                margin-bottom: 2rem;
                align-items: center;
            }

            .search-form input {
                flex: 1;
                max-width: 400px;
                padding: 0.75rem;
                border: 2px solid rgba(111, 213, 221, 0.3);
                border-radius: var(--border-radius);
                background: var(--card-bg);
                color: var(--text);
                font-size: 0.95rem;
            }

            .search-form input:focus {
                outline: none;
                border-color: var(--primary);
            }

            .search-form select {
                padding: 0.75rem;
                border: 2px solid rgba(111, 213, 221, 0.3);
                border-radius: var(--border-radius);
                background: var(--card-bg);
                color: var(--text);
                font-size: 0.95rem;
            }

            .search-form select:focus {
                outline: none;
                border-color: var(--primary);
            }

            .table-container {
                background: var(--card-bg);
                border-radius: var(--border-radius);
                box-shadow: var(--shadow-light);
                overflow-x: auto;
            }

            .table {
                width: 100%;
                border-collapse: collapse;
                font-size: 0.85rem;
            }

            .table th {
                background: var(--accent);
                color: var(--text);
                padding: 1rem 0.75rem;
                text-align: left;
                font-weight: 600;
                border-bottom: 2px solid rgba(111, 213, 221, 0.2);
                white-space: nowrap;
            }

            .table td {
                padding: 1rem 0.75rem;
                border-bottom: 1px solid rgba(111, 213, 221, 0.1);
            }

            .table tbody tr:hover {
                background: rgba(111, 213, 221, 0.05);
            }

            .table tbody tr:last-child td {
                border-bottom: none;
            }

            .status-badge {
                padding: 0.25rem 0.75rem;
                border-radius: 999px;
                font-size: 0.8rem;
                font-weight: 600;
                display: inline-block;
            }

            .status-badge.active {
                background: #d1fae5;
                color: #065f46;
            }

            .status-badge.inactive {
                background: #fee2e2;
                color: #991b1b;
            }

            .btn-action {
                padding: 0.4rem 0.9rem;
                border-radius: var(--border-radius-small);
                font-size: 0.85rem;
                font-weight: 600;
                border: none;
                cursor: pointer;
                transition: var(--transition);
                text-decoration: none;
                display: inline-block;
            }

            .btn-lock {
                background: #ef4444;
                color: white;
            }

            .btn-lock:hover {
                background: #dc2626;
                transform: translateY(-2px);
            }

            .btn-unlock {
                background: #10b981;
                color: white;
            }

            .btn-unlock:hover {
                background: #059669;
                transform: translateY(-2px);
            }

            .empty-state {
                text-align: center;
                padding: 3rem;
                color: var(--text-light);
                font-style: italic;
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

            .text-right {
                text-align: right;
            }

            .text-center {
                text-align: center;
            }

            .text-truncate {
                max-width: 150px;
                white-space: nowrap;
                overflow: hidden;
                text-overflow: ellipsis;
            }
            @keyframes fadeIn {
                from {
                    opacity: 0;
                    transform: translateY(-10px);
                }
                to {
                    opacity: 1;
                    transform: translateY(0);
                }
            }
            .flash-message-fixed {
                position: fixed;
                top: 0;
                left: 50%;
                transform: translateX(-50%);
                z-index: 1000;
                width: auto;
                max-width: 90%;
                margin-top: 15px; /* Khoảng cách từ trên xuống */
                box-shadow: 0 4px 12px rgba(0,0,0,0.15);
                animation: slideDown 0.5s ease-out; /* Hiệu ứng cuộn xuống */
            }

            @keyframes slideDown {
                from {
                    opacity: 0;
                    transform: translate(-50%, -100%);
                }
                to {
                    opacity: 1;
                    transform: translate(-50%, 0);
                }
            }
        </style>
    </head>
    <body>

        <!-- Sidebar trái -->
        <aside class="admin-sidebar">
            <h2>📋 Danh mục quản lý</h2>
            <ul>
                <li><a href="toys?action=list">🧸 Sản phẩm</a></li>
                <li><a href="categories?action=list">📂 Danh mục</a></li>
                <li><a href="suppliers?action=list">🏢 Nhà cung cấp</a></li>
                <li><a href="${pageContext.request.contextPath}/admin/customer">👤 Khách hàng</a></li>
                <li><a href="manage-staff">👔 Nhân viên</a></li>
                <li><a href="statistics?type=day">📈 Thống kê</a></li>
            </ul>

            <a href="dashboard.jsp" class="back-to-site">📋 Về trang quản trị</a>
        </aside>

        <!-- Nội dung chính -->
        <div class="admin-content">
            <!-- Header -->
            <div class="admin-header">
                <h1>👤 Quản lý khách hàng</h1>

                <a href="../home" class="btn" style="background: #10b981;">🏠 Về trang chủ</a>
            </div>

            <!-- Thống kê -->
            <div class="stats-grid">
                <div class="stat-card active">
                    <h3>Khách đang hoạt động</h3>
                    <div class="number">${activeCount}</div>
                </div>
                <div class="stat-card inactive">
                    <h3>Khách bị khóa</h3>
                    <div class="number">${inactiveCount}</div>
                </div>
            </div>

            <!-- Form tìm kiếm và lọc -->
            <form method="get" action="manage-customer" class="search-form">
                <input type="text" name="keyword" placeholder="Tìm theo tên..." value="<%= keyword%>">
                <select name="status">
                    <option value="all" <%= "all".equals(statusFilter) ? "selected" : ""%>>-- Tất cả trạng thái --</option>
                    <option value="active" <%= "active".equals(statusFilter) ? "selected" : ""%>>Đang hoạt động</option>
                    <option value="inactive" <%= "inactive".equals(statusFilter) ? "selected" : ""%>>Đã bị khóa</option>
                </select>
                <button type="submit" class="btn">🔍 Lọc / Tìm</button>
            </form>

            <!-- Bảng khách hàng -->
            <div class="table-container">
                <table class="table">
                    <thead>
                        <tr>
                            <th style="width: 60px;">ID</th>
                            <th>Tên</th>
                            <th>Email</th>
                            <th style="width: 120px;">SĐT</th>
                            <th>Địa chỉ</th>
                            <th style="width: 120px;" class="text-center">Đơn gần nhất</th>
                            <th style="width: 150px;" class="text-center">Cấp quyền</th>
                            <th style="width: 120px;" class="text-center">Xem chi tiết</th>
                            <th style="width: 100px;" class="text-center">Hành động</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% if (customers != null && !customers.isEmpty()) {
                                for (Customer c : customers) {
                                    OrderStats stats = orderStats.get(c.getCustomerId());
                        %>
                        <tr>
                            <td><%= c.getCustomerId()%></td>
                            <td><strong><%= c.getName()%></strong></td>
                            <td><%= c.getEmail()%></td>
                            <td><%= c.getPhone()%></td>
                            <td class="text-truncate" title="<%= c.getAddressCustomer()%>">
                                <%= c.getAddressCustomer()%>
                            </td>
                            <td class="text-center">
                                <% if (stats != null && stats.getLatestStatus() != null) {%>
                                <span style="font-size: 0.85rem; color: var(--text-light);"><%= stats.getLatestStatus()%></span>
                                <% } else { %>
                                <span style="font-size: 0.85rem; color: var(--text-light);">-</span>
                                <% }%>
                            <td class="text-center">
                                <form action="${pageContext.request.contextPath}/admin/updateRole" method="post" style="margin:0;">
                                    <input type="hidden" name="customerId" value="<%= c.getCustomerId()%>" />
                                    <select name="role" style="padding:5px 8px; border-radius:6px; border:1px solid #ccc;"
                                            onchange="this.form.submit()"> <option value="user" <%= "user".equalsIgnoreCase(c.getRole()) ? "selected" : ""%>>User</option>
                                        <option value="staff" <%= "staff".equalsIgnoreCase(c.getRole()) ? "selected" : ""%>>Staff</option>
                                        <option value="doctor" <%= "doctor".equalsIgnoreCase(c.getRole()) ? "selected" : ""%>>Doctor</option>
                                        <option value="admin" <%= "admin".equalsIgnoreCase(c.getRole()) ? "selected" : ""%>>Admin</option>
                                    </select>
                                </form>
                            </td>
                            <td class="text-center">
                                <a href="view-customer?id=<%= c.getCustomerId()%>" class="btn-action" style="background: #3b82f6; color: white; text-decoration: none;">
                                    👁️ Xem
                                </a>
                            </td>
                            <td class="text-center">
                                <form action="manage-customer" method="post" style="margin: 0;" onsubmit="return confirm('Bạn có chắc muốn <%= c.getStatus() != null && c.getStatus().equals("active") ? "khóa" : "mở khóa"%> tài khoản này?')">
                                    <input type="hidden" name="action" value="toggle-status" />
                                    <input type="hidden" name="customerId" value="<%= c.getCustomerId()%>" />
                                    <input type="hidden" name="currentStatus" value="<%= c.getStatus() != null ? c.getStatus() : ""%>" />
                                    <% if (c.getStatus() != null && c.getStatus().equals("active")) { %>
                                    <button type="submit" class="btn-action btn-lock">🔒 Khóa</button>
                                    <% } else { %>
                                    <button type="submit" class="btn-action btn-unlock">🔓 Mở</button>
                                    <% } %>
                                </form>
                            </td>
                        </tr>
                        <% }
                        } else { %>
                        <tr>
                            <td colspan="9" class="empty-state">Không tìm thấy khách hàng nào.</td>
                        </tr>
                        <% }%>
                    </tbody>
                </table>
            </div>
        </div>

    </body>
</html>
