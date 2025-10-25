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
    <title>Chỉnh sửa nhà cung cấp - PET TOY SHOP</title>
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
            cursor: pointer;
        }

        .btn:hover {
            background: var(--accent-pink);
            transform: translateY(-2px);
            box-shadow: var(--shadow-button-hover);
        }

        .btn-secondary {
            background: #6b7280;
        }

        .btn-secondary:hover {
            background: #4b5563;
        }

        .form-container {
            background: var(--card-bg);
            padding: 2rem;
            border-radius: var(--border-radius);
            box-shadow: var(--shadow-light);
            max-width: 700px;
        }

        .form-group {
            margin-bottom: 1.5rem;
        }

        .form-group label {
            display: block;
            margin-bottom: 0.5rem;
            font-weight: 600;
            color: var(--text);
        }

        .form-group input, .form-group textarea {
            width: 100%;
            padding: 0.75rem;
            border: 2px solid rgba(111, 213, 221, 0.3);
            border-radius: var(--border-radius);
            background: var(--main-bg);
            color: var(--text);
            font-size: 0.95rem;
            transition: var(--transition);
        }

        .form-group input:focus, .form-group textarea:focus {
            outline: none;
            border-color: var(--primary);
        }

        .form-group textarea {
            resize: vertical;
            min-height: 80px;
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
        <li><a href="categories?action=list">📂 Danh mục</a></li>
        <li><a href="suppliers?action=list" class="active">🏢 Nhà cung cấp</a></li>
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
        <h1>✏️ Chỉnh sửa nhà cung cấp</h1>
        <a href="suppliers?action=list" class="btn btn-secondary">← Quay lại</a>
    </div>

    <!-- Form chỉnh sửa nhà cung cấp -->
    <c:if test="${not empty supplier}">
        <div class="form-container">
            <form method="post" action="suppliers">
                <input type="hidden" name="action" value="update">
                <input type="hidden" name="supplierId" value="${supplier.supplierId}">
                
                <div class="form-group">
                    <label for="name">Tên công ty *</label>
                    <input type="text" id="name" name="name" 
                           value="${supplier.nameCompany}"
                           required autofocus>
                </div>

                <div class="form-group">
                    <label for="address">Địa chỉ</label>
                    <textarea id="address" name="address">${supplier.address}</textarea>
                </div>

                <div class="form-group">
                    <label for="phone">Số điện thoại</label>
                    <input type="tel" id="phone" name="phone" 
                           value="${supplier.phone}">
                </div>

                <div style="display: flex; gap: 1rem; justify-content: flex-end;">
                    <a href="suppliers?action=list" class="btn btn-secondary">Hủy</a>
                    <button type="submit" class="btn">💾 Cập nhật</button>
                </div>
            </form>
        </div>
    </c:if>

    <c:if test="${empty supplier}">
        <div class="alert alert-error">Không tìm thấy nhà cung cấp để chỉnh sửa.</div>
        <a href="suppliers?action=list" class="btn">← Quay lại danh sách</a>
    </c:if>
</div>

</body>
</html>
