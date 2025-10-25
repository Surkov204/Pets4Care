<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.Admin" %>
<%@ page import="model.Staff" %>
<%
    Admin admin = (Admin) session.getAttribute("admin");
    if (admin == null) {
        response.sendRedirect("../login.jsp");
        return;
    }
    
    // Lấy staff từ request attribute hoặc tạo mẫu để test
    Staff staff = (Staff) request.getAttribute("staff");
    if (staff == null) {
        staff = new Staff(1, "Đỗ Quốc Anh", "doquocanh@pets4care.com", "0901234567", "staff123", "Nhân viên");
    }
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Hồ sơ nhân viên - PET TOY SHOP</title>
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

        .admin-sidebar a:hover {
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
            background: linear-gradient(135deg, #f59e0b, #ef4444);
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
            background: #f59e0b;
            color: white;
            border-radius: 999px;
            font-size: 0.85rem;
            font-weight: 600;
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
            border-top: 3px solid #f59e0b;
        }

        .stat-card h3 {
            color: var(--text-light);
            font-size: 0.85rem;
            margin-bottom: 0.5rem;
        }

        .stat-card .number {
            font-size: 2rem;
            font-weight: 700;
            color: #f59e0b;
            font-family: 'Baloo 2', cursive;
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
        <h1>👨‍💼 Hồ sơ nhân viên</h1>
        <div style="display: flex; gap: 1rem;">
            <a href="manage-staff.jsp" class="btn btn-back">◀ Quay lại</a>
            <a href="../home" class="btn" style="background: #10b981;">🏠 Về trang chủ</a>
        </div>
    </div>

    <!-- Thống kê nhanh -->
    <div class="stats-grid">
        <div class="stat-card">
            <h3>Mã nhân viên</h3>
            <div class="number">#<%= staff.getStaffId() %></div>
        </div>
        <div class="stat-card">
            <h3>Vai trò</h3>
            <div class="number" style="font-size: 1.2rem;">Staff</div>
        </div>
        <div class="stat-card">
            <h3>Trạng thái</h3>
            <div class="number" style="color: #10b981; font-size: 1.2rem;">Hoạt động</div>
        </div>
    </div>

    <!-- Card hồ sơ -->
    <div class="profile-card">
        <div class="profile-header">
            <div class="profile-avatar">
                <%= staff.getName().substring(0, 1).toUpperCase() %>
            </div>
            <div class="profile-info">
                <h2><%= staff.getName() %></h2>
                <span class="role-badge">👔 <%= staff.getPosition() %></span>
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
                    🔑 Mật khẩu
                </div>
                <div class="value">••••••••</div>
            </div>

            <div class="info-item">
                <div class="label">
                    🎯 Chức vụ
                </div>
                <div class="value"><%= staff.getPosition() %></div>
            </div>

            <div class="info-item">
                <div class="label">
                    🆔 Mã nhân viên
                </div>
                <div class="value">#<%= staff.getStaffId() %></div>
            </div>

            <div class="info-item">
                <div class="label">
                    ✅ Trạng thái
                </div>
                <div class="value" style="color: #10b981; font-weight: 700;">
                    Đang làm việc
                </div>
            </div>
        </div>

        <div style="margin-top: 2rem; text-align: center;">
            <a href="edit-staff.jsp?id=<%= staff.getStaffId() %>" class="btn">
                ✏️ Chỉnh sửa thông tin
            </a>
            <a href="manage-staff.jsp" class="btn btn-back">
                ◀ Quay lại danh sách
            </a>
            <a href="#" class="btn btn-danger" onclick="return confirm('Bạn có chắc muốn xóa nhân viên này?')">
                🗑️ Xóa nhân viên
            </a>
        </div>
    </div>
</div>

</body>
</html>

