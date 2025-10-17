<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>🐾 Staff Profile | Pet4Care</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/staff.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <style>
        /* Dropdown Menu Styles */
        .avatar-dropdown {
            position: relative;
            display: inline-block;
        }
        
        .avatar {
            cursor: pointer;
            display: flex;
            align-items: center;
            gap: 8px;
            padding: 8px 12px;
            border-radius: 8px;
            transition: background-color 0.3s;
        }
        
        .avatar:hover {
            background-color: rgba(255, 255, 255, 0.1);
        }
        
        .avatar i {
            font-size: 12px;
            transition: transform 0.3s;
        }
        
        .dropdown-menu {
            position: absolute;
            top: 100%;
            right: 0;
            background: white;
            border-radius: 8px;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
            min-width: 200px;
            z-index: 1000;
            display: none;
            overflow: hidden;
        }
        
        .dropdown-menu.show {
            display: block;
        }
        
        .dropdown-menu a {
            display: flex;
            align-items: center;
            gap: 10px;
            padding: 12px 16px;
            color: #333;
            text-decoration: none;
            transition: background-color 0.3s;
        }
        
        .dropdown-menu a:hover {
            background-color: #f8f9fa;
        }
        
        .dropdown-menu a i {
            color: #6c757d;
            width: 16px;
        }
    </style>
</head>
<body>
<header class="staff-header">
    <div class="user-section">
        <div class="avatar-dropdown">
            <div class="avatar" onclick="toggleDropdown()">
                <img src="${pageContext.request.contextPath}/images/staff-avatar.png" alt="Staff">
                <span>${sessionScope.staff.name}</span>
                <i class="fas fa-chevron-down"></i>
            </div>
            <div class="dropdown-menu" id="dropdownMenu">
                <a href="${pageContext.request.contextPath}/staff/edit-profile">
                    <i class="fas fa-user-edit"></i> Chỉnh sửa thông tin
                </a>
                <a href="${pageContext.request.contextPath}/staff/logout">
                    <i class="fas fa-sign-out-alt"></i> Đăng xuất
                </a>
            </div>
        </div>
    </div>
</header>

<div class="staff-wrapper">
    <!-- Sidebar -->
    <aside class="staff-sidebar">
        <ul>
            <li><a href="${pageContext.request.contextPath}/staff/viewOrder"><i class="fas fa-receipt"></i> View Orders</a></li>
            <li><a href="${pageContext.request.contextPath}/staff/work-schedule"><i class="fas fa-calendar-alt"></i> Work Schedule</a></li>
            <li><a href="${pageContext.request.contextPath}/staff/staff-profile" class="active"><i class="fas fa-user-circle"></i> Staff Profile</a></li>
            <li><a href="${pageContext.request.contextPath}/staff/customer-list"><i class="fas fa-users"></i> Customer Profile</a></li>
            <li><a href="${pageContext.request.contextPath}/staff/services-booking"><i class="fas fa-list"></i> Services Booking</a></li>
            <li><a href="${pageContext.request.contextPath}/staff/chatCustomer"><i class="fas fa-comments"></i> Chat with Customer</a></li>
            <li><a href="${pageContext.request.contextPath}/staff/products"><i class="fas fa-box"></i> View Product</a></li>
    </aside>

    <!-- Main content -->
    <main class="staff-content">
        <section class="welcome-card">
            <h2><i class="fas fa-id-card"></i> Thông tin nhân viên</h2>
            <p>Cập nhật hồ sơ cá nhân của bạn để hệ thống luôn chính xác 🐾</p>
        </section>
        
<section class="staff-profile-wrapper">
    <div class="staff-profile-card">
        <div class="profile-header-banner"></div>

        <div class="profile-main">
            <img src="${pageContext.request.contextPath}/images/staff-avatar.png" alt="Staff Avatar" class="profile-avatar">

            <h2>${sessionScope.staff.name}</h2>
            <p class="staff-role">Nhân viên chăm sóc thú cưng 🐾</p>

            <div class="profile-info">
                <p><i class="fas fa-envelope"></i> ${sessionScope.staff.email}</p>
                <p><i class="fas fa-phone"></i> ${sessionScope.staff.phone}</p>
            </div>

            <div class="profile-actions">
                <a href="staff-edit-profile.jsp" class="btn-gradient">
                    <i class="fas fa-user-edit"></i> Chỉnh sửa hồ sơ
                </a>
                <form action="logout" method="post" class="logout-form">
                    <button type="submit" class="btn-outline">
                        <i class="fas fa-sign-out-alt"></i> Đăng xuất
                    </button>
                </form>
            </div>
        </div>
    </div>
</section>
    </main>
</div>

<footer class="staff-footer">
    <p>© 2025 Pet4Care — Where Pets Feel Loved 🐶🐱</p>
</footer>

<script>
function toggleDropdown() {
    const dropdown = document.getElementById('dropdownMenu');
    dropdown.classList.toggle('show');
}

// Close dropdown when clicking outside
document.addEventListener('click', function(event) {
    const dropdown = document.getElementById('dropdownMenu');
    const avatar = document.querySelector('.avatar');
    
    if (!avatar.contains(event.target)) {
        dropdown.classList.remove('show');
    }
});
</script>

</body>
</html>
