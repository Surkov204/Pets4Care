<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
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
    <title>Quản lý danh mục - PET TOY SHOP</title>
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

        .table-container {
            background: var(--card-bg);
            border-radius: var(--border-radius);
            box-shadow: var(--shadow-light);
            overflow: hidden;
        }

        .table {
            width: 100%;
            border-collapse: collapse;
            font-size: 0.95rem;
        }

        .table th {
            background: var(--accent);
            color: var(--text);
            padding: 1rem;
            text-align: left;
            font-weight: 600;
            border-bottom: 2px solid rgba(111, 213, 221, 0.2);
        }

        .table td {
            padding: 1rem;
            border-bottom: 1px solid rgba(111, 213, 221, 0.1);
        }

        .table tbody tr:hover {
            background: rgba(111, 213, 221, 0.05);
        }

        .table tbody tr:last-child td {
            border-bottom: none;
        }

        .action-links {
            display: flex;
            gap: 0.5rem;
        }

        .action-links a {
            color: var(--primary);
            text-decoration: none;
            font-weight: 500;
            transition: var(--transition);
        }

        .action-links a:hover {
            color: var(--accent-pink);
        }

        .action-links a.delete {
            color: #ef4444;
        }

        .action-links a.delete:hover {
            color: #dc2626;
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

        .alert {
            padding: 1rem;
            border-radius: var(--border-radius);
            margin-bottom: 1rem;
            font-weight: 500;
        }

        .alert-success {
            background: #d1fae5;
            color: #065f46;
            border: 1px solid #a7f3d0;
        }

        .alert-error {
            background: #fee2e2;
            color: #991b1b;
            border: 1px solid #fca5a5;
        }
    </style>
</head>
<body>

<!-- Sidebar trái -->
<aside class="admin-sidebar">
    <h2>📋 Danh mục quản lý</h2>
    <ul>
        <li><a href="toys?action=list">🧸 Sản phẩm</a></li>
        <li><a href="categories?action=list" class="active">📂 Danh mục</a></li>
        <li><a href="suppliers?action=list">🏢 Nhà cung cấp</a></li>
        <li><a href="manage-customer">👤 Khách hàng</a></li>
        <li><a href="manage-staff">👔 Nhân viên</a></li>
        <li><a href="statistics?type=day">📈 Thống kê</a></li>
    </ul>

    <a href="dashboard.jsp" class="back-to-site">📋 Về trang quản trị</a>
</aside>

<!-- Nội dung chính -->
<div class="admin-content">
    <!-- Header -->
    <div class="admin-header">
        <h1>📂 Quản lý danh mục sản phẩm</h1>
        <div style="display: flex; gap: 1rem; align-items: center;">
            <a href="../home" class="btn" style="background: #10b981;">🏠 Về trang chủ</a>
            <a href="categories?action=create" class="btn btn-success">+ Thêm danh mục</a>
        </div>
    </div>

    <!-- Thông báo -->
    <c:if test="${not empty success}">
        <div class="alert alert-success">${success}</div>
    </c:if>
    <c:if test="${not empty error}">
        <div class="alert alert-error">${error}</div>
    </c:if>

    <!-- Bảng danh mục -->
    <div class="table-container">
        <table class="table">
            <thead>
                <tr>
                    <th style="width: 100px;">ID</th>
                    <th>Tên danh mục</th>
                    <th style="width: 200px;">Hành động</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach var="category" items="${categories}">
                    <tr>
                        <td>${category.categoryId}</td>
                        <td><strong>${category.name}</strong></td>
                        <td>
                            <div class="action-links">
                                <a href="categories?action=edit&id=${category.categoryId}">✏️ Sửa</a>
                                <a href="categories?action=delete&id=${category.categoryId}" class="delete"
                                   onclick="return confirm('Bạn có chắc muốn xoá danh mục này?\n\nLưu ý: Không thể xóa nếu danh mục đang có sản phẩm.')">🗑️ Xoá</a>
                            </div>
                        </td>
                    </tr>
                </c:forEach>
                <c:if test="${empty categories}">
                    <tr>
                        <td colspan="3" class="empty-state">Chưa có danh mục nào. Hãy thêm danh mục đầu tiên!</td>
                    </tr>
                </c:if>
            </tbody>
        </table>
    </div>
</div>

</body>
</html>

