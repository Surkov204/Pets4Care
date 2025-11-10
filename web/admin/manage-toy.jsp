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
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Quản lý sản phẩm - PET TOY SHOP</title>
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

            .search-form {
                display: flex;
                gap: 1rem;
                margin-bottom: 2rem;
                align-items: center;
            }

            .search-form input, .search-form select {
                padding: 0.75rem;
                border: 2px solid rgba(111, 213, 221, 0.3);
                border-radius: var(--border-radius);
                background: var(--card-bg);
                color: var(--text);
                font-size: 0.95rem;
            }

            .search-form input:focus, .search-form select:focus {
                outline: none;
                border-color: var(--primary);
            }

            .search-form input {
                flex: 1;
                max-width: 300px;
            }

            .search-form select {
                min-width: 200px;
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
                font-size: 0.9rem;
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
                <li><a href="toys?action=list" class="active">🧸 Sản phẩm</a></li>
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
                <h1>🧸 Quản lý sản phẩm</h1>
                <div style="display: flex; gap: 1rem; align-items: center;">
                    <a href="../home" class="btn" style="background: #10b981;">🏠 Về trang chủ</a>
                    <a href="toys?action=create" class="btn btn-success">+ Thêm sản phẩm</a>
                </div>
            </div>

            <!-- Thông báo -->
            <c:if test="${not empty success}">
                <div class="alert alert-success">${success}</div>
            </c:if>
            <c:if test="${not empty error}">
                <div class="alert alert-error">${error}</div>
            </c:if>

            <!-- Form tìm kiếm và lọc -->
            <form method="get" action="toys" class="search-form">
                <input type="text" name="keyword" placeholder="Tìm theo tên hoặc ID" value="${param.keyword}">
                <select name="category">
                    <option value="">-- Tất cả danh mục --</option>
                    <c:forEach var="cat" items="${categories}">
                        <option value="${cat.categoryId}" ${cat.categoryId == selectedCategory ? 'selected' : ''}>
                            ${cat.name}
                        </option>
                    </c:forEach>
                </select>
                <button type="submit" class="btn">🔍 Tìm kiếm</button>
            </form>

            <!-- Bảng sản phẩm -->
            <div class="table-container">
                <table class="table">
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Tên sản phẩm</th>
                            <th>Giá</th>
                            <th>Danh mục</th>
                            <th>Số lượng</th>
                            <th>Nhà cung cấp</th>
                            <th>Mô tả</th>
                            <th>Hành động</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="product" items="${products}">
                            <tr>
                                <td>${product.productId}</td>
                                <td><strong>${product.name}</strong></td>
                                <td>${product.price} VNĐ</td>
                                <td>
                                    <c:forEach var="cat" items="${categories}">
                                        <c:if test="${cat.categoryId == product.categoryId}">
                                            ${cat.name}
                                        </c:if>
                                    </c:forEach>
                                </td>
                                <td>
                                    <span style="color: ${product.stockQuantity > 50 ? '#10b981' : product.stockQuantity > 0 ? '#f59e0b' : '#ef4444'};">
                                        ${product.stockQuantity}
                                    </span>
                                </td>
                                <td>${supplierMap[product.supplierId]}</td>
                                <td style="max-width: 200px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;">
                                    ${product.description}
                                </td>
                                <td>
                                    <div class="action-links">
                                        <a href="toys?action=edit&id=${product.productId}">✏️ Sửa</a>
                                        <a href="toys?action=delete&id=${product.productId}" class="delete"
                                           onclick="return confirm('Bạn có chắc muốn xoá sản phẩm này?')">🗑️ Xoá</a>
                                    </div>
                                </td>
                            </tr>
                        </c:forEach>
                        <c:if test="${empty products}">
                            <tr>
                                <td colspan="8" class="empty-state">Không tìm thấy sản phẩm nào.</td>
                            </tr>
                        </c:if>
                    </tbody>
                </table>
            </div>
        </div>

    </body>
</html>
