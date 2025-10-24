<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.Admin" %>
<%@ page import="model.Customer" %>
<%
    Admin admin = (Admin) session.getAttribute("admin");
    if (admin == null) {
        response.sendRedirect("../login.jsp");
        return;
    }
    
    Customer customer = (Customer) request.getAttribute("customer");
    if (customer == null) {
        response.sendRedirect("manage-customer");
        return;
    }
    
    String errorMessage = (String) request.getAttribute("error");
    String successMessage = (String) request.getAttribute("success");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Chỉnh sửa khách hàng - PET TOY SHOP</title>
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

        .form-card {
            background: var(--card-bg);
            border-radius: var(--border-radius);
            padding: 2rem;
            max-width: 800px;
            margin: 0 auto;
            box-shadow: var(--shadow-light);
        }

        .form-group {
            margin-bottom: 1.5rem;
        }

        .form-group label {
            display: block;
            margin-bottom: 0.5rem;
            color: var(--text);
            font-weight: 600;
            font-size: 0.95rem;
        }

        .form-group label .required {
            color: #ef4444;
            margin-left: 0.2rem;
        }

        .form-group input,
        .form-group select,
        .form-group textarea {
            width: 100%;
            padding: 0.75rem;
            border: 2px solid rgba(111, 213, 221, 0.3);
            border-radius: var(--border-radius-small);
            font-size: 1rem;
            transition: var(--transition);
            background: var(--main-bg);
            color: var(--text);
        }

        .form-group input:focus,
        .form-group select:focus,
        .form-group textarea:focus {
            outline: none;
            border-color: var(--primary);
            box-shadow: 0 0 0 3px rgba(111, 213, 221, 0.1);
        }

        .form-group textarea {
            resize: vertical;
            min-height: 100px;
        }

        .form-actions {
            display: flex;
            gap: 1rem;
            justify-content: center;
            margin-top: 2rem;
        }

        .btn {
            padding: 0.75rem 2rem;
            border-radius: var(--border-radius);
            border: none;
            cursor: pointer;
            font-size: 1rem;
            font-weight: 600;
            transition: var(--transition);
            text-decoration: none;
            display: inline-block;
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

        .btn-secondary {
            background: #6b7280;
            color: white;
        }

        .btn-secondary:hover {
            background: #4b5563;
        }

        .alert {
            padding: 1rem;
            border-radius: var(--border-radius-small);
            margin-bottom: 1.5rem;
        }

        .alert-error {
            background: #fee2e2;
            color: #dc2626;
            border-left: 4px solid #dc2626;
        }

        .alert-success {
            background: #d1fae5;
            color: #059669;
            border-left: 4px solid #059669;
        }

        .form-row {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 1.5rem;
        }

        .info-note {
            background: rgba(111, 213, 221, 0.1);
            padding: 1rem;
            border-radius: var(--border-radius-small);
            border-left: 4px solid var(--primary);
            margin-bottom: 1.5rem;
        }

        .info-note p {
            margin: 0;
            color: var(--text-light);
            font-size: 0.9rem;
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
        <h1>✏️ Chỉnh sửa khách hàng</h1>
        <a href="view-customer?id=<%= customer.getCustomerId() %>" class="btn btn-secondary">◀ Quay lại</a>
    </div>

    <!-- Form -->
    <div class="form-card">
        <% if (errorMessage != null) { %>
        <div class="alert alert-error">
            ⚠️ <%= errorMessage %>
        </div>
        <% } %>
        
        <% if (successMessage != null) { %>
        <div class="alert alert-success">
            ✅ <%= successMessage %>
        </div>
        <% } %>

        <div class="info-note">
            <p>💡 <strong>Lưu ý:</strong> Các trường có dấu <span style="color: #ef4444;">*</span> là bắt buộc. Email và Google ID không thể thay đổi.</p>
        </div>

        <form action="edit-customer" method="post" onsubmit="return validateForm()">
            <input type="hidden" name="customerId" value="<%= customer.getCustomerId() %>">

            <div class="form-row">
                <div class="form-group">
                    <label>👤 Tên khách hàng <span class="required">*</span></label>
                    <input type="text" name="name" value="<%= customer.getName() %>" required>
                </div>

                <div class="form-group">
                    <label>📧 Email</label>
                    <input type="email" value="<%= customer.getEmail() %>" disabled style="background: #f3f4f6; cursor: not-allowed;">
                    <small style="color: var(--text-light); font-size: 0.85rem;">Email không thể thay đổi</small>
                </div>
            </div>

            <div class="form-row">
                <div class="form-group">
                    <label>📞 Số điện thoại <span class="required">*</span></label>
                    <input type="tel" name="phone" value="<%= customer.getPhone() != null ? customer.getPhone() : "" %>" required pattern="[0-9]{10,11}">
                    <small style="color: var(--text-light); font-size: 0.85rem;">Nhập 10-11 số</small>
                </div>

                <div class="form-group">
                    <label>📊 Trạng thái <span class="required">*</span></label>
                    <select name="status" required>
                        <option value="active" <%= customer.getStatus() != null && customer.getStatus().equals("active") ? "selected" : "" %>>✅ Hoạt động</option>
                        <option value="inactive" <%= customer.getStatus() == null || customer.getStatus().equals("inactive") ? "selected" : "" %>>🔒 Đã khóa</option>
                    </select>
                </div>
            </div>

            <div class="form-group">
                <label>🏠 Địa chỉ <span class="required">*</span></label>
                <textarea name="address" required><%= customer.getAddressCustomer() != null ? customer.getAddressCustomer() : "" %></textarea>
            </div>

            <div class="form-group">
                <label>🔐 Google ID</label>
                <input type="text" value="<%= customer.getGoogleId() != null ? customer.getGoogleId() : "Không có" %>" disabled style="background: #f3f4f6; cursor: not-allowed;">
                <small style="color: var(--text-light); font-size: 0.85rem;">Google ID không thể thay đổi</small>
            </div>

            <div class="form-actions">
                <button type="submit" class="btn btn-primary">💾 Lưu thay đổi</button>
                <a href="view-customer?id=<%= customer.getCustomerId() %>" class="btn btn-secondary">❌ Hủy bỏ</a>
            </div>
        </form>
    </div>
</div>

<script>
    function validateForm() {
        const name = document.querySelector('input[name="name"]').value.trim();
        const phone = document.querySelector('input[name="phone"]').value.trim();
        const address = document.querySelector('textarea[name="address"]').value.trim();

        if (name === '') {
            alert('Vui lòng nhập tên khách hàng!');
            return false;
        }

        if (phone === '' || phone.length < 10 || phone.length > 11) {
            alert('Vui lòng nhập số điện thoại hợp lệ (10-11 số)!');
            return false;
        }

        if (address === '') {
            alert('Vui lòng nhập địa chỉ!');
            return false;
        }

        return confirm('Bạn có chắc muốn lưu thay đổi thông tin khách hàng này?');
    }
</script>

</body>
</html>

