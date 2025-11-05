<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.Admin" %>
<%@ page import="model.Customer" %>
<%@ page import="model.OrderStats" %>
<%
    Admin admin = (Admin) session.getAttribute("admin");
    if (admin == null) {
        response.sendRedirect("../login.jsp");
        return;
    }

    // Lấy customer từ request attribute hoặc tạo mẫu để test
    Customer customer = (Customer) request.getAttribute("customer");
    OrderStats stats = (OrderStats) request.getAttribute("orderStats");
    String successMessage = request.getParameter("success");

    if (customer == null) {
        customer = new Customer(1, "Lê Vĩnh Tiến", "0916134642", "a@gmail.com", "123456", null, "Da Nang", "active");
    }
    if (stats == null) {
        stats = new OrderStats(3, 111000, "Đã hoàn tất");
    }
%>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Hồ sơ khách hàng - PET TOY SHOP</title>
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

            .profile-card {
                background: var(--card-bg);
                border-radius: var(--border-radius);
                padding: 2rem;
                max-width: 900px;
                margin: 0 auto;
                box-shadow: var(--shadow-light);
            }

            .profile-header {
                display: flex;
                align-items: center;
                gap: 2rem;
                padding-bottom: 1.5rem;
                margin-bottom: 1.5rem;
                border-bottom: 2px solid rgba(111, 213, 221, 0.2);
            }

            .profile-avatar {
                width: 120px;
                height: 120px;
                border-radius: 50%;
                background: linear-gradient(135deg, var(--primary), #8b5cf6);
                display: flex;
                align-items: center;
                justify-content: center;
                font-size: 3rem;
                color: white;
                font-family: 'Baloo 2', cursive;
                box-shadow: var(--shadow-light);
            }

            .profile-info h2 {
                font-size: 1.8rem;
                color: var(--text);
                font-family: 'Baloo 2', cursive;
                margin-bottom: 0.5rem;
            }

            .profile-info .role-badge {
                display: inline-block;
                padding: 0.4rem 1rem;
                background: #8b5cf6;
                color: white;
                border-radius: 999px;
                font-size: 0.85rem;
                font-weight: 600;
            }

            .status-badge {
                padding: 0.4rem 1rem;
                border-radius: 999px;
                font-size: 0.85rem;
                font-weight: 600;
                display: inline-block;
                margin-left: 0.5rem;
            }

            .status-badge.active {
                background: #d1fae5;
                color: #065f46;
            }

            .status-badge.inactive {
                background: #fee2e2;
                color: #991b1b;
            }

            .info-grid {
                display: grid;
                grid-template-columns: 1fr 1fr;
                gap: 1.5rem;
                margin-top: 1.5rem;
            }

            .info-item {
                padding: 1rem;
                background: rgba(111, 213, 221, 0.05);
                border-radius: var(--border-radius-small);
                border-left: 3px solid var(--primary);
            }

            .info-item .label {
                font-size: 0.85rem;
                color: var(--text-light);
                font-weight: 600;
                margin-bottom: 0.5rem;
                display: flex;
                align-items: center;
                gap: 0.5rem;
            }

            .info-item .value {
                font-size: 1rem;
                color: var(--text);
                font-weight: 500;
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
                margin-right: 1rem;
            }

            .btn:hover {
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

            .btn-danger {
                background: #ef4444;
            }

            .btn-danger:hover {
                background: #dc2626;
            }

            .btn-warning {
                background: #f59e0b;
            }

            .btn-warning:hover {
                background: #d97706;
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

            .stats-grid {
                display: grid;
                grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
                gap: 1rem;
                margin-bottom: 2rem;
            }

            .stat-card {
                background: var(--card-bg);
                padding: 1.5rem;
                border-radius: var(--border-radius);
                box-shadow: var(--shadow-light);
                text-align: center;
                border-top: 3px solid var(--primary);
            }

            .stat-card h3 {
                color: var(--text-light);
                font-size: 0.85rem;
                margin-bottom: 0.5rem;
            }

            .stat-card .number {
                font-size: 2rem;
                font-weight: 700;
                color: var(--primary);
                font-family: 'Baloo 2', cursive;
            }

            .order-history {
                margin-top: 2rem;
                padding-top: 2rem;
                border-top: 2px solid rgba(111, 213, 221, 0.2);
            }

            .order-history h3 {
                font-size: 1.3rem;
                color: var(--text);
                font-family: 'Baloo 2', cursive;
                margin-bottom: 1rem;
            }

            .alert-success {
                background: #d1fae5;
                color: #059669;
                border-left: 4px solid #059669;
                padding: 1rem;
                border-radius: var(--border-radius-small);
                margin-bottom: 1.5rem;
                animation: slideIn 0.3s ease-out;
            }

            @keyframes slideIn {
                from {
                    opacity: 0;
                    transform: translateY(-10px);
                }
                to {
                    opacity: 1;
                    transform: translateY(0);
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
                <li><a href="${pageContext.request.contextPath}/admin/manage-customer" class="active">👤 Khách hàng</a></li>
                <li><a href="manage-staff">👔 Nhân viên</a></li>
                <li><a href="statistics?type=day">📈 Thống kê</a></li>
            </ul>

            <a href="dashboard.jsp" class="back-to-site">📋 Về trang quản trị</a>
        </aside>

        <!-- Nội dung chính -->
        <div class="admin-content">
            <!-- Header -->
            <div class="admin-header">
                <h1>👤 Hồ sơ khách hàng</h1>
                <div style="display: flex; gap: 1rem;">
                    <a href="manage-customer" class="btn btn-back">◀ Quay lại</a>
                    <a href="../home" class="btn" style="background: #10b981;">🏠 Về trang chủ</a>
                </div>
            </div>

            <!-- Success Message -->
            <% if (successMessage != null && successMessage.equals("true")) { %>
            <div class="alert-success">
                ✅ Cập nhật thông tin khách hàng thành công!
            </div>
            <% }%>

            <!-- Thống kê đơn hàng -->
            <div class="stats-grid">
                <div class="stat-card">
                    <h3>Tổng đơn hàng</h3>
                    <div class="number"><%= stats != null ? stats.getTotalOrders() : 0%></div>
                </div>
                <div class="stat-card">
                    <h3>Tổng chi tiêu</h3>
                    <div class="number" style="font-size: 1.3rem;"><%= stats != null ? String.format("%,.0f", stats.getTotalAmount()) : "0"%> đ</div>
                </div>
                <div class="stat-card">
                    <h3>Đơn gần nhất</h3>
                    <div class="number" style="font-size: 1.2rem; color: #10b981;"><%= stats != null && stats.getLatestStatus() != null ? stats.getLatestStatus() : "Chưa có đơn"%></div>
                </div>
            </div>

            <!-- Card hồ sơ -->
            <div class="profile-card">
                <div class="profile-header">
                    <div class="profile-avatar">
                        <%= customer.getName().substring(0, 1).toUpperCase()%>
                    </div>
                    <div class="profile-info">
                        <h2><%= customer.getName()%></h2>
                        <span class="role-badge">🛒 Khách hàng</span>
                        <% if (customer.getStatus() != null && customer.getStatus().equals("active")) { %>
                        <span class="status-badge active">✅ Hoạt động</span>
                        <% } else { %>
                        <span class="status-badge inactive">🔒 Đã khóa</span>
                        <% }%>
                        <p style="color: var(--text-light); margin-top: 0.5rem; font-size: 0.9rem;">
                            ID: #<%= customer.getCustomerId()%>
                        </p>
                    </div>
                </div>

                <div class="info-grid">
                    <div class="info-item">
                        <div class="label">
                            📧 Email
                        </div>
                        <div class="value"><%= customer.getEmail()%></div>
                    </div>

                    <div class="info-item">
                        <div class="label">
                            📞 Số điện thoại
                        </div>
                        <div class="value"><%= customer.getPhone() != null ? customer.getPhone() : "Chưa cập nhật"%></div>
                    </div>

                    <div class="info-item">
                        <div class="label">
                            🏠 Địa chỉ
                        </div>
                        <div class="value"><%= customer.getAddressCustomer() != null ? customer.getAddressCustomer() : "Chưa cập nhật"%></div>
                    </div>

                    <div class="info-item">
                        <div class="label">
                            🔐 Google ID
                        </div>
                        <div class="value"><%= customer.getGoogleId() != null ? customer.getGoogleId() : "Không có"%></div>
                    </div>

                    <div class="info-item">
                        <div class="label">
                            🆔 Mã khách hàng
                        </div>
                        <div class="value">#<%= customer.getCustomerId()%></div>
                    </div>

                    <div class="info-item">
                        <div class="label">
                            📊 Trạng thái tài khoản
                        </div>
                        <% if (customer.getStatus() != null && customer.getStatus().equals("active")) { %>
                        <div class="value" style="color: #10b981; font-weight: 700;">
                            ✅ Đang hoạt động
                        </div>
                        <% } else { %>
                        <div class="value" style="color: #ef4444; font-weight: 700;">
                            🔒 Đã bị khóa
                        </div>
                        <% }%>
                    </div>
                </div>

                <div class="order-history">
                    <h3>📦 Lịch sử mua hàng</h3>
                    <div style="display: flex; gap: 2rem; padding: 1rem; background: rgba(111, 213, 221, 0.05); border-radius: var(--border-radius-small);">
                        <div>
                            <strong>Tổng đơn:</strong> <%= stats != null ? stats.getTotalOrders() : 0%> đơn
                        </div>
                        <div>
                            <strong>Tổng chi tiêu:</strong> <%= stats != null ? String.format("%,.0f", stats.getTotalAmount()) : "0"%> đ
                        </div>
                        <div>
                            <strong>Trạng thái đơn gần nhất:</strong> <span style="color: #10b981;"><%= stats != null && stats.getLatestStatus() != null ? stats.getLatestStatus() : "Chưa có đơn"%></span>
                        </div>
                    </div>
                </div>

                <div style="margin-top: 2rem; text-align: center;">
                    <a href="edit-customer?id=<%= customer.getCustomerId()%>" class="btn" style="background: #3b82f6;">
                        ✏️ Chỉnh sửa thông tin
                    </a>
                    <a href="view-customer-orders?id=<%= customer.getCustomerId()%>" class="btn">
                        📦 Xem đơn hàng
                    </a>
                    <a href="manage-customer" class="btn btn-back">
                        ◀ Quay lại danh sách
                    </a>
                </div>
            </div>
        </div>

    </body>
</html>

