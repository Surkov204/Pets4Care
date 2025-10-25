<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.Admin" %>
<%@ page import="model.Staff" %>
<%
    Admin admin = (Admin) session.getAttribute("admin");
    if (admin == null) {
        response.sendRedirect("../login.jsp");
        return;
    }
    
    // Nếu truy cập trực tiếp JSP (không qua servlet), redirect về servlet
    Staff staff = (Staff) request.getAttribute("staff");
    String successMessage = request.getParameter("success");
    
    if (staff == null) {
        // Kiểm tra nếu có ID parameter thì redirect về servlet với ID
        String idParam = request.getParameter("id");
        if (idParam != null) {
            response.sendRedirect("view-staff?id=" + idParam);
        } else {
            response.sendRedirect("manage-staff");
        }
        return;
    }
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Hồ sơ nhân viên - <%= staff.getName() %></title>
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
            overflow-y: auto;
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
            margin-bottom: 2rem;
            padding-bottom: 2rem;
            border-bottom: 2px solid rgba(111, 213, 221, 0.2);
        }

        .profile-avatar {
            width: 100px;
            height: 100px;
            border-radius: 50%;
            background: linear-gradient(135deg, var(--primary), var(--accent-pink));
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 2.5rem;
            color: white;
            font-weight: 700;
            flex-shrink: 0;
        }

        .profile-info h2 {
            font-size: 1.8rem;
            color: var(--text);
            margin-bottom: 0.5rem;
        }

        .role-badge {
            padding: 0.4rem 1rem;
            border-radius: var(--border-radius-small);
            font-size: 0.9rem;
            font-weight: 600;
            display: inline-block;
            margin-right: 0.5rem;
        }

        .role-admin {
            background: #fee2e2;
            color: #991b1b;
        }

        .role-manager {
            background: #dbeafe;
            color: #1e40af;
        }

        .role-staff {
            background: #d1fae5;
            color: #065f46;
        }

        .info-grid {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 1.5rem;
        }

        .info-item {
            padding: 1rem;
            background: rgba(111, 213, 221, 0.05);
            border-radius: var(--border-radius-small);
            border-left: 4px solid var(--primary);
        }

        .info-item .label {
            font-size: 0.85rem;
            color: var(--text-light);
            margin-bottom: 0.5rem;
        }

        .info-item .value {
            font-size: 1.1rem;
            font-weight: 600;
            color: var(--text);
        }

        .btn {
            padding: 0.75rem 1.5rem;
            border-radius: var(--border-radius);
            border: none;
            cursor: pointer;
            font-size: 1rem;
            color: white;
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

        .schedule-note {
            margin-top: 2rem;
            padding-top: 2rem;
            border-top: 2px solid rgba(111, 213, 221, 0.2);
        }

        .schedule-note h3 {
            font-size: 1.3rem;
            color: var(--text);
            font-family: 'Baloo 2', cursive;
            margin-bottom: 1rem;
        }

        .schedule-note .content {
            padding: 1rem;
            background: rgba(111, 213, 221, 0.05);
            border-radius: var(--border-radius-small);
            color: var(--text-light);
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
        <li><a href="manage-customer">👤 Khách hàng</a></li>
        <li><a href="manage-staff" class="active">👔 Nhân viên</a></li>
        <li><a href="statistics?type=day">📈 Thống kê</a></li>
    </ul>
    <a href="dashboard.jsp" class="back-to-site">📋 Về trang quản trị</a>
</aside>

<!-- Nội dung chính -->
<div class="admin-content">
    <!-- Header -->
    <div class="admin-header">
        <h1>👤 Hồ sơ nhân viên</h1>
        <div style="display: flex; gap: 1rem;">
            <a href="manage-staff" class="btn btn-back">◀ Quay lại</a>
            <a href="../home" class="btn" style="background: #10b981;">🏠 Về trang chủ</a>
        </div>
    </div>

    <!-- Success Message -->
    <% if (successMessage != null && successMessage.equals("true")) { %>
    <div class="alert-success">
        ✅ Cập nhật thông tin nhân viên thành công!
    </div>
    <% } %>

    <!-- Card hồ sơ -->
    <div class="profile-card">
        <div class="profile-header">
            <div class="profile-avatar">
                <%= staff.getName().substring(0, 1).toUpperCase() %>
            </div>
            <div class="profile-info">
                <h2><%= staff.getName() %></h2>
                <%
                String position = staff.getPosition();
                String roleClass = "role-staff";
                if ("admin".equalsIgnoreCase(position)) {
                    roleClass = "role-admin";
                } else if ("quản lý".equalsIgnoreCase(position)) {
                    roleClass = "role-manager";
                }
                %>
                <span class="role-badge <%= roleClass %>">👔 <%= position %></span>
                <p style="color: var(--text-light); margin-top: 0.5rem; font-size: 0.9rem;">
                    ID: #<%= staff.getStaffId() %>
                </p>
            </div>
        </div>

        <div class="info-grid">
            <div class="info-item">
                <div class="label">
                    📧 Email
                </div>
                <div class="value"><%= staff.getEmail() %></div>
            </div>

            <div class="info-item">
                <div class="label">
                    📞 Số điện thoại
                </div>
                <div class="value"><%= staff.getPhone() != null ? staff.getPhone() : "Chưa cập nhật" %></div>
            </div>

            <div class="info-item">
                <div class="label">
                    💼 Vị trí
                </div>
                <div class="value"><%= staff.getPosition() %></div>
            </div>

            <div class="info-item">
                <div class="label">
                    🆔 Mã nhân viên
                </div>
                <div class="value">#<%= staff.getStaffId() %></div>
            </div>
        </div>

        <% if (staff.getScheduleNote() != null && !staff.getScheduleNote().trim().isEmpty()) { %>
        <div class="schedule-note">
            <h3>📅 Ghi chú lịch làm việc</h3>
            <div class="content">
                <%= staff.getScheduleNote() %>
            </div>
        </div>
        <% } %>

        <div style="margin-top: 2rem; text-align: center;">
            <a href="edit-staff?id=<%= staff.getStaffId() %>" class="btn" style="background: #3b82f6;">
                ✏️ Chỉnh sửa thông tin
            </a>
            <a href="manage-staff" class="btn btn-back">
                ◀ Quay lại danh sách
            </a>
        </div>
    </div>
</div>

</body>
</html>

