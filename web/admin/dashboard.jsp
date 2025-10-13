<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.Admin" %>
<%
    Admin admin = (Admin) session.getAttribute("admin");
    if (admin == null) {
        response.sendRedirect("../login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Dashboard Admin - PET TOY SHOP</title>
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
        }

        .admin-sidebar a:hover {
            color: var(--primary);
            transform: translateX(5px);
        }

        .admin-content {
            margin-left: 250px;
            padding: 2rem;
            background: var(--main-bg);
            min-height: 100vh;
        }

        .admin-header h1 {
            font-size: 2rem;
            color: var(--primary);
            font-family: 'Baloo 2', cursive;
        }

        .admin-header p {
            color: var(--text-light);
            margin-top: 0.5rem;
        }

        .admin-card-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(260px, 1fr));
            gap: 1.5rem;
            margin-top: 2rem;
        }

        .admin-card {
            background: var(--card-bg);
            padding: 2rem;
            border-radius: var(--border-radius);
            box-shadow: var(--shadow-light);
            transition: var(--transition);
            border: 2px solid transparent;
        }

        .admin-card:hover {
            transform: translateY(-5px);
            box-shadow: var(--shadow-hover);
            border-color: var(--primary);
        }

        .admin-card h2 {
            font-size: 1.3rem;
            color: var(--primary);
            margin-bottom: 0.5rem;
            font-family: 'Quicksand', sans-serif;
        }

        .admin-card p {
            color: var(--text);
            font-size: 0.95rem;
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

<!-- Sidebar trái -->
<aside class="admin-sidebar">
    <h2>📋 Danh mục quản lý</h2>
    <ul>
        <li><a href="toys?action=list">🧸 Sản phẩm</a></li>
        <li><a href="SupplierServlet?action=list">🏢 Nhà cung cấp</a></li>
        <li><a href="manage-customer">👤 Khách hàng</a></li>
        <li><a href="manage-order">📦 Đơn hàng</a></li>
        <li><a href="statistics?type=day">📈 Thống kê</a></li>
    </ul>

    <a href="../home" class="back-to-site">🏠 Về trang chủ</a>
</aside>

<!-- Nội dung chính -->
<div class="admin-content">
    <!-- Header -->
    <div class="admin-header">
        <h1>🎯 Trang Quản Trị Hệ Thống</h1>
        <p>Chào mừng, <strong><%= admin.getName() %></strong></p>
    </div>

    <!-- Dashboard items -->
    <div class="admin-card-grid">
        <a href="toys" class="admin-card">
            <h2>🧸 Quản lý sản phẩm</h2>
            <p>Thêm, sửa, xoá các món đồ chơi thú cưng.</p>
        </a>

        <a href="manage-customer" class="admin-card">
            <h2>👤 Quản lý khách hàng</h2>
            <p>Xem thông tin, khoá, xoá tài khoản khách hàng.</p>
        </a>

        <a href="SupplierServlet" class="admin-card">
            <h2>🏢 Quản lý nhà cung cấp</h2>
            <p>Thêm mới, cập nhật hoặc xoá nhà cung cấp.</p>
        </a>

        <a href="manage-order" class="admin-card">
            <h2>📦 Quản lý đơn hàng</h2>
            <p>Xem, lọc trạng thái và tra cứu các đơn đặt hàng.</p>
        </a>

        <a href="statistics?type=day" class="admin-card">
            <h2>📈 Thống kê doanh thu</h2>
            <p>Xem biểu đồ doanh thu theo ngày, tháng, năm.</p>
        </a>
    </div>
</div>

</body>
</html>
