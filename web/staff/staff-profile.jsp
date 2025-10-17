<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>🐾 Staff Profile | Pet4Care</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/staff.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
</head>
<body>
<header class="staff-header">
    <div class="logo-section">
        <img src="${pageContext.request.contextPath}/images/logo.png" alt="Pet4Care">
        <div>
            <h1>Pet4Care</h1>
            <p>Staff Dashboard</p>
        </div>
    </div>
    <div class="user-section">
        <div class="notif"><i class="fas fa-bell"></i></div>
        <div class="chat"><i class="fas fa-comments"></i></div>
        <div class="avatar">
            <img src="${pageContext.request.contextPath}/images/staff-avatar.png" alt="Staff">
            <span>${sessionScope.staff.name}</span>
        </div>
        <form action="logout" method="post">
            <button class="logout-btn"><i class="fas fa-sign-out-alt"></i></button>
        </form>
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

</body>
</html>
