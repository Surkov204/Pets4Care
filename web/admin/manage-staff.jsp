<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.Admin" %>
<%@ page import="model.Staff" %>
<%@ page import="java.util.List" %>
<%
    Admin admin = (Admin) session.getAttribute("admin");
    if (admin == null) {
        response.sendRedirect("../login.jsp");
        return;
    }
    
    // Nếu truy cập trực tiếp JSP (không qua servlet), redirect về servlet
    List<Staff> staffList = (List<Staff>) request.getAttribute("staffList");
    if (staffList == null) {
        response.sendRedirect("manage-staff");
        return;
    }
    Integer adminCount = (Integer) request.getAttribute("adminCount");
    Integer managerCount = (Integer) request.getAttribute("managerCount");
    Integer staffCount = (Integer) request.getAttribute("staffCount");
    String keyword = (String) request.getAttribute("keyword");
    String positionFilter = (String) request.getAttribute("positionFilter");
    
    // Lấy thông báo từ session
    String successMessage = (String) session.getAttribute("successMessage");
    String errorMessage = (String) session.getAttribute("errorMessage");
    
    // Xóa thông báo khỏi session sau khi lấy
    if (successMessage != null) session.removeAttribute("successMessage");
    if (errorMessage != null) session.removeAttribute("errorMessage");
    
    if (adminCount == null) adminCount = 0;
    if (managerCount == null) managerCount = 0;
    if (staffCount == null) staffCount = 0;
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Quản lý nhân viên - PET TOY SHOP</title>
    <link rel="stylesheet" href="../css/homeStyle.css">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: var(--main-bg);
            color: var(--text);
        }

        .admin-layout {
            display: flex;
            min-height: 100vh;
        }

        .admin-sidebar {
            width: 250px;
            background: var(--card-bg);
            padding: 2rem 1.5rem;
            border-right: 2px solid rgba(111, 213, 221, 0.2);
            box-shadow: var(--shadow-light);
            position: fixed;
            height: 100vh;
            overflow-y: auto;
        }

        .admin-sidebar h2 {
            font-size: 1.4rem;
            font-family: 'Baloo 2', cursive;
            color: var(--primary);
            margin-bottom: 1.5rem;
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }

        .sidebar-menu {
            list-style: none;
        }

        .sidebar-menu li {
            margin-bottom: 0.5rem;
        }

        .sidebar-menu a {
            display: flex;
            align-items: center;
            gap: 0.75rem;
            padding: 0.75rem 1rem;
            color: var(--text);
            text-decoration: none;
            border-radius: var(--border-radius-small);
            transition: var(--transition);
            font-weight: 600;
        }

        .sidebar-menu a:hover,
        .sidebar-menu a.active {
            background: var(--accent);
            color: var(--primary);
            transform: translateX(5px);
        }

        .back-to-site {
            margin-top: 2rem;
            display: block;
            text-align: center;
            padding: 0.75rem;
            background: var(--accent);
            color: var(--primary);
            text-decoration: none;
            border-radius: var(--border-radius-small);
            font-weight: 600;
            transition: var(--transition);
        }

        .back-to-site:hover {
            background: var(--accent-pink);
            color: white;
            transform: translateY(-2px);
        }

        .admin-main {
            flex: 1;
            margin-left: 250px;
            padding: 2rem;
        }

        .page-header {
            margin-bottom: 2rem;
        }

        .page-header h1 {
            font-size: 2rem;
            color: var(--primary);
            font-family: 'Baloo 2', cursive;
            margin-bottom: 0.5rem;
        }

        .page-header p {
            color: var(--text-light);
        }

        .stats-cards {
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
            border-top: 4px solid var(--primary);
        }

        .stat-card h3 {
            font-size: 0.9rem;
            color: var(--text-light);
            margin-bottom: 0.75rem;
        }

        .stat-card .number {
            font-size: 2rem;
            font-weight: 700;
            color: var(--primary);
            font-family: 'Baloo 2', cursive;
        }

        .filters-section {
            background: var(--card-bg);
            padding: 1.5rem;
            border-radius: var(--border-radius);
            box-shadow: var(--shadow-light);
            margin-bottom: 2rem;
        }

        .filters-grid {
            display: grid;
            grid-template-columns: 2fr 1fr auto;
            gap: 1rem;
            align-items: end;
        }

        .form-group {
            display: flex;
            flex-direction: column;
        }

        .form-group label {
            margin-bottom: 0.5rem;
            font-weight: 600;
            color: var(--text);
            font-size: 0.9rem;
        }

        .form-group input,
        .form-group select {
            padding: 0.75rem;
            border: 2px solid rgba(111, 213, 221, 0.3);
            border-radius: var(--border-radius-small);
            font-size: 1rem;
            transition: var(--transition);
        }

        .form-group input:focus,
        .form-group select:focus {
            outline: none;
            border-color: var(--primary);
            box-shadow: 0 0 0 3px rgba(111, 213, 221, 0.1);
        }

        .btn {
            padding: 0.75rem 1.5rem;
            border: none;
            border-radius: var(--border-radius-small);
            font-size: 1rem;
            font-weight: 600;
            cursor: pointer;
            transition: var(--transition);
        }

        .btn-primary {
            background: var(--primary);
            color: white;
        }

        .btn-primary:hover {
            background: var(--accent-pink);
            transform: translateY(-2px);
            box-shadow: var(--shadow-button-hover);
        }

        .table-container {
            background: var(--card-bg);
            border-radius: var(--border-radius);
            box-shadow: var(--shadow-light);
            overflow: hidden;
        }

        table {
            width: 100%;
            border-collapse: collapse;
        }

        thead {
            background: linear-gradient(135deg, rgba(111, 213, 221, 0.2), rgba(247, 149, 193, 0.2));
        }

        th {
            padding: 1rem;
            text-align: left;
            font-weight: 700;
            color: var(--text);
            border-bottom: 2px solid rgba(111, 213, 221, 0.3);
        }

        th.text-center {
            text-align: center;
        }

        td {
            padding: 1rem;
            border-bottom: 1px solid rgba(111, 213, 221, 0.1);
            color: var(--text-light);
        }

        td.text-center {
            text-align: center;
        }

        tbody tr {
            transition: var(--transition);
        }

        tbody tr:hover {
            background: rgba(111, 213, 221, 0.05);
        }

        .position-badge {
            padding: 0.4rem 0.8rem;
            border-radius: var(--border-radius-small);
            font-size: 0.85rem;
            font-weight: 600;
            display: inline-block;
        }

        .position-admin {
            background: #fee2e2;
            color: #991b1b;
        }

        .position-manager {
            background: #dbeafe;
            color: #1e40af;
        }

        .position-staff {
            background: #d1fae5;
            color: #065f46;
        }

        .btn-action {
            padding: 0.5rem 1rem;
            border: none;
            border-radius: var(--border-radius-small);
            font-size: 0.9rem;
            font-weight: 600;
            cursor: pointer;
            transition: var(--transition);
            text-decoration: none;
            display: inline-block;
        }

        .empty-state {
            text-align: center;
            padding: 3rem;
            color: var(--text-light);
        }

        .alert {
            padding: 1rem;
            border-radius: var(--border-radius-small);
            margin-bottom: 1.5rem;
            animation: slideIn 0.3s ease-out;
        }

        .alert-success {
            background: #d1fae5;
            color: #065f46;
            border-left: 4px solid #059669;
        }

        .alert-error {
            background: #fee2e2;
            color: #991b1b;
            border-left: 4px solid #dc2626;
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

        .btn-delete {
            background: #ef4444;
            color: white;
        }

        .btn-delete:hover {
            background: #dc2626;
        }

        .action-buttons {
            display: flex;
            gap: 0.5rem;
            justify-content: center;
        }
    </style>
</head>
<body>

<div class="admin-layout">
    <!-- Sidebar -->
    <aside class="admin-sidebar">
        <h2>📋 Danh mục quản lý</h2>
        <ul class="sidebar-menu">
            <li><a href="toys?action=list">🧸 Sản phẩm</a></li>
            <li><a href="categories?action=list">📂 Danh mục</a></li>
            <li><a href="suppliers?action=list">🏢 Nhà cung cấp</a></li>
        <li><a href="manage-customer">👤 Khách hàng</a></li>
        <li><a href="manage-staff" class="active">👔 Nhân viên</a></li>
        <li><a href="statistics?type=day">📈 Thống kê</a></li>
        </ul>
        <a href="dashboard.jsp" class="back-to-site">📋 Về trang quản trị</a>
    </aside>

    <!-- Main Content -->
    <main class="admin-main">
        <!-- Page Header -->
        <div class="page-header">
            <h1>👥 Quản lý nhân viên</h1>
            <p>Quản lý thông tin nhân viên trong hệ thống</p>
        </div>

        <!-- Success/Error Messages -->
        <% if (successMessage != null) { %>
        <div class="alert alert-success">
            ✅ <%= successMessage %>
        </div>
        <% } %>
        
        <% if (errorMessage != null) { %>
        <div class="alert alert-error">
            ⚠️ <%= errorMessage %>
        </div>
        <% } %>

        <!-- Stats Cards -->
        <div class="stats-cards">
            <div class="stat-card">
                <h3>👑 Admin</h3>
                <div class="number"><%= adminCount %></div>
            </div>
            <div class="stat-card">
                <h3>👔 Quản lý</h3>
                <div class="number"><%= managerCount %></div>
            </div>
            <div class="stat-card">
                <h3>👨‍💼 Nhân viên</h3>
                <div class="number"><%= staffCount %></div>
            </div>
            <div class="stat-card">
                <h3>📊 Tổng cộng</h3>
                <div class="number"><%= staffList != null ? staffList.size() : 0 %></div>
            </div>
        </div>

        <!-- Filters -->
        <div class="filters-section">
            <form action="manage-staff" method="get">
                <div class="filters-grid">
                    <div class="form-group">
                        <label>🔍 Tìm kiếm</label>
                        <input type="text" name="keyword" placeholder="Tìm theo tên, email hoặc SĐT..." value="<%= keyword != null ? keyword : "" %>">
                    </div>
                    <div class="form-group">
                        <label>📋 Vị trí</label>
                        <select name="position">
                            <option value="all" <%= positionFilter == null || "all".equals(positionFilter) ? "selected" : "" %>>Tất cả</option>
                            <option value="admin" <%= "admin".equals(positionFilter) ? "selected" : "" %>>Admin</option>
                            <option value="quản lý" <%= "quản lý".equals(positionFilter) ? "selected" : "" %>>Quản lý</option>
                            <option value="nhân viên" <%= "nhân viên".equals(positionFilter) ? "selected" : "" %>>Nhân viên</option>
                        </select>
                    </div>
                    <button type="submit" class="btn btn-primary">🔎 Lọc / Tìm</button>
                </div>
            </form>
        </div>

        <!-- Table -->
        <div class="table-container">
            <table>
                <thead>
                <tr>
                    <th style="width: 60px;">ID</th>
                    <th>Tên</th>
                    <th>Email</th>
                    <th style="width: 120px;">SĐT</th>
                    <th style="width: 150px;" class="text-center">Vị trí</th>
                    <th>Ghi chú lịch làm việc</th>
                    <th style="width: 200px;" class="text-center">Hành động</th>
                </tr>
                </thead>
                <tbody>
                    <% if (staffList != null && !staffList.isEmpty()) {
                            for (Staff s : staffList) { %>
                    <tr>
                        <td><%= s.getStaffId() %></td>
                        <td><strong><%= s.getName() %></strong></td>
                        <td><%= s.getEmail() %></td>
                        <td><%= s.getPhone() != null ? s.getPhone() : "-" %></td>
                        <td class="text-center">
                            <%
                            String position = s.getPosition();
                            String positionClass = "position-staff";
                            if ("admin".equalsIgnoreCase(position)) {
                                positionClass = "position-admin";
                            } else if ("quản lý".equalsIgnoreCase(position)) {
                                positionClass = "position-manager";
                            }
                            %>
                            <span class="position-badge <%= positionClass %>"><%= position %></span>
                        </td>
                        <td><%= s.getScheduleNote() != null ? s.getScheduleNote() : "-" %></td>
                        <td class="text-center">
                            <div class="action-buttons">
                                <a href="view-staff?id=<%= s.getStaffId() %>" class="btn-action" style="background: #3b82f6; color: white;">
                                    👁️ Xem
                                </a>
                                <form action="manage-staff" method="post" style="margin: 0;" onsubmit="return confirm('Bạn có chắc muốn xóa nhân viên <%= s.getName() %>?')">
                                    <input type="hidden" name="action" value="delete" />
                                    <input type="hidden" name="staffId" value="<%= s.getStaffId() %>" />
                                    <button type="submit" class="btn-action btn-delete">
                                        🗑️ Xóa
                                    </button>
                                </form>
                            </div>
                        </td>
                    </tr>
                    <% }
                } else { %>
                    <tr>
                        <td colspan="7" class="empty-state">Không tìm thấy nhân viên nào.</td>
                    </tr>
                    <% } %>
                </tbody>
            </table>
        </div>
    </main>
</div>

</body>
</html>

