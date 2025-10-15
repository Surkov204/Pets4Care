<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>🐾 Doctor Dashboard | Pet4Care</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/staff.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
</head>
<body>

<header class="staff-header">
    <div class="logo-section">
        <img src="${pageContext.request.contextPath}/images/logo.png" alt="Pet4Care">
        <div>
            <h1>Pet4Care</h1>
            <p>Doctor Dashboard</p>
        </div>
    </div>
    <div class="user-section">
        <div class="notif"><i class="fas fa-bell"></i></div>
        <div class="chat"><i class="fas fa-comments"></i></div>
        <div class="avatar">
            <img src="${pageContext.request.contextPath}/images/doctor-avatar.png" alt="Doctor Avatar">
            <span>${sessionScope.doctor.name}</span>
        </div>
        <form action="${pageContext.request.contextPath}/logout" method="post">
            <button class="logout-btn"><i class="fas fa-sign-out-alt"></i></button>
        </form>
    </div>
</header>

<div class="staff-wrapper">
    <!-- Sidebar -->
    <aside class="staff-sidebar">
        <ul>
            <li><a href="doctor-dashboard.jsp" class="active"><i class="fas fa-home"></i> Dashboard</a></li>
            <li><a href="medical-record.jsp"><i class="fas fa-notes-medical"></i> Medical Records</a></li>
            <li><a href="work-schedule.jsp"><i class="fas fa-calendar-alt"></i> Work Schedule</a></li>
            <li><a href="chatCustomer.jsp"><i class="fas fa-comments"></i> Chat with Customers</a></li>
            <li><a href="doctor-profile.jsp"><i class="fas fa-user-md"></i> Doctor Profile</a></li>
        </ul>
    </aside>

    <!-- Main Content -->
    <main class="staff-content">
        <section class="welcome-card">
            <h2>Chào mừng trở lại, Bác sĩ ${sessionScope.doctor.name} 👨‍⚕️</h2>
            <p>Chúc bạn một ngày làm việc hiệu quả cùng các thú cưng đáng yêu!</p>
        </section>

        <section class="dashboard-grid">
            <div class="dashboard-card">
                <i class="fas fa-calendar-check"></i>
                <h3>Work Schedule</h3>
                <p>Lịch làm việc hôm nay</p>
                <a href="work-schedule.jsp" class="btn-dashboard">Xem chi tiết</a>
            </div>

            <div class="dashboard-card">
                <i class="fas fa-notes-medical"></i>
                <h3>Medical Records</h3>
                <p>Hồ sơ bệnh án gần đây</p>
                <a href="medical-record.jsp" class="btn-dashboard">Quản lý hồ sơ</a>
            </div>

            <div class="dashboard-card">
                <i class="fas fa-user-paw"></i>
                <h3>Customers</h3>
                <p>Thú cưng và chủ nuôi đang theo dõi</p>
                <a href="customer-list.jsp" class="btn-dashboard">Xem danh sách</a>
            </div>

            <div class="dashboard-card">
                <i class="fas fa-stethoscope"></i>
                <h3>Upcoming Appointments</h3>
                <p>Ca khám sắp tới</p>
                <a href="appointments.jsp" class="btn-dashboard">Xem chi tiết</a>
            </div>
        </section>

        <section class="recent-section">
            <h2><i class="fas fa-clock"></i> Recent Activities</h2>
            <table class="recent-table">
                <thead>
                    <tr>
                        <th>Thời gian</th>
                        <th>Hoạt động</th>
                        <th>Chi tiết</th>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <td>08:30</td>
                        <td>Khám cho Mèo Mimi</td>
                        <td>Viêm tai ngoài, đang điều trị</td>
                    </tr>
                    <tr>
                        <td>10:15</td>
                        <td>Gọi điện tư vấn</td>
                        <td>Khách hàng: Trần Hồng – Cún Bông</td>
                    </tr>
                    <tr>
                        <td>14:00</td>
                        <td>Khám định kỳ</td>
                        <td>Cún Lucky – kiểm tra sức khỏe</td>
                    </tr>
                </tbody>
            </table>
        </section>
    </main>
</div>

<footer class="staff-footer">
    <p>© 2025 Pet4Care — Dedicated to Pet Health & Happiness 🐶🐱</p>
</footer>

</body>
</html>
