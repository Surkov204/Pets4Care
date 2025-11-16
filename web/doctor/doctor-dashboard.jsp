<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ page import="model.Doctor" %>
<%
    // Kiểm tra đăng nhập - dữ liệu được load từ DoctorDashboardController
    Doctor doctor = (Doctor) session.getAttribute("doctor");
    if (doctor == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    // Nếu chưa có dữ liệu từ controller, redirect về controller
    if (request.getAttribute("fullDoctorInfo") == null) {
        response.sendRedirect(request.getContextPath() + "/doctor/dashboard");
        return;
    }
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>🐾 Doctor Dashboard | Pet4Care</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/staff.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <style>
        .schedule-info {
            background: linear-gradient(135deg, #e3f2fd 0%, #f0f9ff 100%);
            padding: 14px 16px;
            border-radius: 8px;
            margin-top: 12px;
            border-left: 4px solid #2196F3;
            font-size: 14px;
            line-height: 1.6;
        }

        /* Attendance & Payroll Styles */
        .attendance-section {
            display: flex;
            flex-wrap: wrap;
            gap: 20px;
            margin-top: 20px;
            margin-bottom: 20px;
        }

        .attendance-card, .salary-card {
            flex: 1;
            background: #fff;
            border-radius: 12px;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
            padding: 24px;
            transition: all 0.3s ease;
            min-width: 280px;
        }

        .attendance-card:hover, .salary-card:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.12);
        }

        .attendance-card {
            text-align: center;
        }

        .attendance-card h3, .salary-card h3 {
            color: #2c3e50;
            font-weight: 600;
            margin: 0 0 8px 0;
            font-size: 15px;
        }

        .attendance-subtext {
            color: #7f8c8d;
            font-size: 13px;
            margin: 12px 0 16px 0;
        }

        .btn-checkin, .btn-checkout {
            border: none;
            border-radius: 8px;
            font-weight: 600;
            cursor: pointer;
            padding: 12px 36px;
            font-size: 16px;
            transition: all 0.3s ease;
        }

        .btn-checkin {
            background: linear-gradient(135deg, #22c55e, #16a34a);
            color: #fff;
            box-shadow: 0 4px 10px rgba(34,197,94,0.3);
        }

        .btn-checkin:hover {
            background: linear-gradient(135deg, #16a34a, #15803d);
            transform: translateY(-2px);
        }

        .btn-checkout {
            background: linear-gradient(135deg, #facc15, #eab308);
            color: #333;
            box-shadow: 0 4px 10px rgba(250,204,21,0.3);
        }

        .btn-checkout:hover {
            background: linear-gradient(135deg, #eab308, #ca8a04);
            transform: translateY(-2px);
        }

        .salary-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 12px;
            gap: 12px;
        }

        .btn-calc-salary {
            background: #3b82f6;
            color: #fff;
            font-size: 13px;
            border: none;
            border-radius: 6px;
            font-weight: 600;
            cursor: pointer;
            padding: 8px 16px;
            transition: all 0.3s ease;
            white-space: nowrap;
        }

        .btn-calc-salary:hover {
            background: #2563eb;
            transform: translateY(-2px);
        }

        .salary-table {
            width: 100%;
            border-collapse: collapse;
            text-align: center;
            font-size: 13px;
        }

        .salary-table th {
            background: #f8fafc;
            color: #475569;
            padding: 10px;
            font-weight: 600;
            border-bottom: 2px solid #e2e8f0;
        }

        .salary-table td {
            padding: 10px;
            border-bottom: 1px solid #e2e8f0;
            color: #334155;
        }

        .salary-table .empty-msg {
            color: #94a3b8;
            font-style: italic;
            padding: 16px;
        }
        
        .status {
            padding: 4px 10px;
            border-radius: 6px;
            font-size: 11px;
            font-weight: 600;
            display: inline-block;
        }
        
        .status-confirmed { background: #d4edda; color: #155724; }
        .status-pending { background: #fff3cd; color: #856404; }
        .status-cancelled { background: #f8d7da; color: #721c24; }
        .status-completed { background: #d1ecf1; color: #0c5460; }
        
        .btn-small {
            background: #6FD5DD;
            color: white;
            padding: 6px 12px;
            border-radius: 6px;
            text-decoration: none;
            font-size: 12px;
            font-weight: 600;
            transition: all 0.2s;
            display: inline-block;
        }
        
        .btn-small:hover {
            background: #5ac5cd;
            transform: translateY(-1px);
        }
        
        .no-data {
            text-align: center;
            padding: 40px 20px;
            color: #95a5a6;
        }
        
        .no-data i {
            font-size: 48px;
            margin-bottom: 12px;
            opacity: 0.4;
        }
        
        .no-data p {
            margin: 0;
            font-size: 14px;
        }
        
        .dashboard-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 16px;
            margin-bottom: 20px;
        }
        
        .dashboard-card {
            border-radius: 12px;
            padding: 20px;
            text-align: center;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
            transition: all 0.3s;
            position: relative;
            overflow: hidden;
        }
        
        .dashboard-card:hover {
            transform: translateY(-3px);
            box-shadow: 0 6px 16px rgba(0, 0, 0, 0.12);
        }
        
        .dashboard-card i {
            font-size: 28px;
            margin-bottom: 8px;
            opacity: 0.9;
        }
        
        .dashboard-card h3 {
            margin: 8px 0;
            font-size: 14px;
            font-weight: 600;
            opacity: 0.9;
        }
        
        .dashboard-card p {
            margin: 4px 0;
            font-size: 13px;
        }
        
        .dashboard-card strong {
            font-size: 24px;
            display: block;
            margin: 8px 0;
        }
        
        .btn-dashboard {
            display: inline-block;
            padding: 6px 14px;
            border-radius: 6px;
            text-decoration: none;
            font-size: 12px;
            font-weight: 600;
            transition: all 0.2s;
            margin-top: 8px;
        }
        
        .btn-dashboard:hover {
            transform: translateY(-2px);
            opacity: 0.9;
        }
        
        .welcome-card {
            background: linear-gradient(135deg, rgba(111, 213, 221, 0.08), rgba(255, 214, 192, 0.08));
            border-radius: 12px;
            padding: 20px 24px;
            margin-bottom: 20px;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.06);
            border-left: 4px solid #6FD5DD;
        }
        
        .welcome-card h2 {
            margin: 0 0 8px 0;
            font-size: 18px;
            color: #2c3e50;
            font-weight: 700;
        }
        
        .welcome-card p {
            margin: 4px 0;
            color: #555;
            font-size: 13px;
            line-height: 1.5;
        }
        
        .recent-section {
            background: white;
            border-radius: 12px;
            padding: 20px;
            margin-bottom: 16px;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.06);
        }
        
        .recent-section h2 {
            margin: 0 0 16px 0;
            font-size: 16px;
            color: #2c3e50;
            font-weight: 700;
        }
        
        .recent-section h3 {
            margin: 0 0 12px 0;
            font-size: 14px;
            color: #2c3e50;
            font-weight: 700;
        }
        
        .recent-table {
            width: 100%;
            border-collapse: collapse;
            font-size: 13px;
        }
        
        .recent-table thead {
            background: #f8fafc;
            border-bottom: 2px solid #e2e8f0;
        }
        
        .recent-table th {
            padding: 10px 12px;
            text-align: left;
            color: #475569;
            font-weight: 600;
            font-size: 12px;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }
        
        .recent-table tbody tr {
            border-bottom: 1px solid #e2e8f0;
            transition: background-color 0.2s;
        }
        
        .recent-table tbody tr:hover {
            background-color: #f8fafc;
        }
        
        .recent-table td {
            padding: 10px 12px;
            color: #334155;
        }
        
        .quick-stats {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
            gap: 12px;
        }
        
        .stat-box {
            padding: 12px 14px;
            border-radius: 8px;
            border-left: 4px solid;
        }
        
        .stat-box div:first-child {
            font-size: 12px;
            font-weight: 600;
            margin-bottom: 4px;
            opacity: 0.85;
        }
        
        .stat-box div:last-child {
            font-size: 20px;
            font-weight: 700;
        }
        
        /* Dropdown Menu Styles */
        .avatar-dropdown {
            position: relative;
            display: inline-block;
        }
        
        .avatar {
            cursor: pointer;
            display: flex;
            align-items: center;
            gap: 10px;
            padding: 8px 16px;
            border-radius: 20px;
            transition: all 0.3s;
            font-weight: 500;
        }
        
        .avatar img {
            width: 32px;
            height: 32px;
            border-radius: 50%;
            border: 2px solid rgba(255, 255, 255, 0.5);
        }
        
        .avatar:hover {
            background-color: rgba(255, 255, 255, 0.15);
        }
        
        .avatar i {
            font-size: 13px;
            transition: transform 0.3s;
        }
        
        .avatar:hover i {
            transform: rotate(180deg);
        }
        
        .dropdown-menu {
            position: absolute;
            top: calc(100% + 8px);
            right: 0;
            background: white;
            border-radius: 12px;
            box-shadow: 0 8px 24px rgba(0, 0, 0, 0.12);
            min-width: 220px;
            z-index: 1000;
            display: none;
            overflow: hidden;
            border: 1px solid #f0f0f0;
            animation: slideDown 0.2s ease-out;
        }
        
        @keyframes slideDown {
            from {
                opacity: 0;
                transform: translateY(-8px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }
        
        .dropdown-menu.show {
            display: block;
        }
        
        .dropdown-menu a {
            display: flex;
            align-items: center;
            gap: 12px;
            padding: 12px 16px;
            color: #333;
            text-decoration: none;
            transition: all 0.2s;
            border-bottom: 1px solid #f5f5f5;
        }
        
        .dropdown-menu a:last-child {
            border-bottom: none;
        }
        
        .dropdown-menu a:hover {
            background-color: #f8f9fa;
            padding-left: 20px;
        }
        
        .dropdown-menu a i {
            width: 16px;
            text-align: center;
            color: #6FD5DD;
        }
    </style>
</head>
<body>

<header class="staff-header">
    <div class="user-section">
        <a href="${pageContext.request.contextPath}/logout.jsp" class="logout-btn">
            <i class="fas fa-sign-out-alt"></i> Đăng xuất
        </a>
    </div>
</header>

<div class="staff-wrapper">
    <!-- Sidebar -->
    <aside class="staff-sidebar">
        <ul>
            <li><a href="${pageContext.request.contextPath}/doctor/dashboard" class="active"><i class="fas fa-home"></i> Dashboard</a></li>
            <li><a href="${pageContext.request.contextPath}/doctor/medical-records"><i class="fas fa-notes-medical"></i> Medical Records</a></li>
            <li><a href="${pageContext.request.contextPath}/doctor/work-schedule"><i class="fas fa-calendar-alt"></i> Work Schedule</a></li>
            <li><a href="${pageContext.request.contextPath}/doctor/appointments"><i class="fas fa-stethoscope"></i> Appointments</a></li>
            <li><a href="${pageContext.request.contextPath}/doctor/profile"><i class="fas fa-user-md"></i> Doctor Profile</a></li>
        </ul>
    </aside>

    <!-- Main Content -->
    <main class="staff-content">
        <section class="welcome-card">
            <h2>Chào mừng trở lại, Bác sĩ ${fullDoctorInfo.name} 👨‍⚕️</h2>
            <p>Chuyên khoa: <strong>${fullDoctorInfo.specialization}</strong></p>
            <p>Chúc bạn một ngày làm việc hiệu quả cùng các thú cưng đáng yêu!</p>
            <c:if test="${not empty todaySchedule}">
                <div class="schedule-info">
                    <i class="fas fa-calendar"></i> Ca làm hôm nay: <strong>${todaySchedule.shiftName}</strong> (${todaySchedule.startTime} - ${todaySchedule.endTime})
                    <br><i class="fas fa-map-marker-alt"></i> ${todaySchedule.location}
                </div>
            </c:if>
            <c:if test="${empty todaySchedule}">
                <div class="schedule-info" style="background: #fef3c7; border-left-color: #f59e0b;">
                    <i class="fas fa-info-circle"></i> Bạn chưa có ca làm việc hôm nay. 
                    <a href="${pageContext.request.contextPath}/doctor/work-schedule" style="color: #92400e; text-decoration: underline;">Xem lịch làm việc</a>
                </div>
            </c:if>
        </section>

        <!-- Attendance & Payroll Section -->
        <section class="attendance-section">
            <!-- Card bên trái: Check-in / Check-out -->
            <div class="attendance-card">
                <h3><i class="fas fa-clock"></i> Chấm công</h3>

                <form id="attendanceForm">
                    <c:choose>
                        <c:when test="${isCheckedIn}">
                            <button type="button" id="attendanceButton" class="btn-checkout">Check-out</button>
                            <p id="attendanceStatus" class="attendance-subtext">Bạn đang trong ca làm.</p>
                        </c:when>
                        <c:otherwise>
                            <button type="button" id="attendanceButton" class="btn-checkin">Check-in</button>
                            <p id="attendanceStatus" class="attendance-subtext">Bạn chưa bắt đầu ca làm.</p>
                        </c:otherwise>
                    </c:choose>
                </form>
            </div>

            <!-- Card bên phải: Bảng lương -->
            <div class="salary-card">
                <div class="salary-header">
                    <h3><i class="fas fa-coins"></i> Lương hiện tại</h3>
                    <button type="button" id="generatePayrollBtn" class="btn-calc-salary">
                        <i class="fas fa-calculator"></i> Tính lương tháng này
                    </button>
                </div>

                <table class="salary-table">
                    <thead>
                        <tr>
                            <th>Tháng</th>
                            <th>Tổng giờ</th>
                            <th>Lương/Giờ (₫)</th>
                            <th>Tổng Lương (₫)</th>
                            <th>Ngày Tạo</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:if test="${not empty sessionScope.latestPayroll}">
                            <tr>
                                <td>${sessionScope.latestPayroll.periodStart} → ${sessionScope.latestPayroll.periodEnd}</td>
                                <td>${sessionScope.latestPayroll.totalHours}</td>
                                <td><fmt:formatNumber value="${sessionScope.latestPayroll.hourlyRate}" type="number" groupingUsed="true"/></td>
                                <td><b><fmt:formatNumber value="${sessionScope.latestPayroll.totalSalary}" type="number" groupingUsed="true"/></b></td>
                                <td><fmt:formatDate value="${sessionScope.latestPayroll.createdAt}" pattern="dd/MM/yyyy HH:mm"/></td>
                            </tr>
                        </c:if>
                        <c:if test="${empty sessionScope.latestPayroll}">
                            <tr><td colspan="5" class="empty-msg">Chưa có dữ liệu lương.</td></tr>
                        </c:if>
                    </tbody>
                </table>
            </div>
        </section>

        <!-- Statistics Cards -->
        <section class="dashboard-grid">
            <div class="dashboard-card" style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white;">
                <i class="fas fa-calendar-day" style="color: white;"></i>
                <h3 style="color: white;">Hôm nay</h3>
                <p style="color: white;"><strong style="font-size: 2rem;">${todayCount}</strong> ca khám</p>
                <a href="${pageContext.request.contextPath}/doctor/appointments" class="btn-dashboard" style="background: rgba(255,255,255,0.2); color: white;">Xem chi tiết</a>
            </div>

            <div class="dashboard-card" style="background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%); color: white;">
                <i class="fas fa-clock" style="color: white;"></i>
                <h3 style="color: white;">Sắp tới</h3>
                <p style="color: white;"><strong style="font-size: 2rem;">${upcomingCount}</strong> lịch hẹn</p>
                <a href="${pageContext.request.contextPath}/doctor/appointments" class="btn-dashboard" style="background: rgba(255,255,255,0.2); color: white;">Xem chi tiết</a>
            </div>

            <div class="dashboard-card" style="background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%); color: white;">
                <i class="fas fa-calendar-alt" style="color: white;"></i>
                <h3 style="color: white;">Tháng này</h3>
                <p style="color: white;"><strong style="font-size: 2rem;">${monthlyCount}</strong> ca khám</p>
                <a href="${pageContext.request.contextPath}/doctor/medical-records" class="btn-dashboard" style="background: rgba(255,255,255,0.2); color: white;">Hồ sơ</a>
            </div>

            <div class="dashboard-card" style="background: linear-gradient(135deg, #43e97b 0%, #38f9d7 100%); color: white;">
                <i class="fas fa-check-circle" style="color: white;"></i>
                <h3 style="color: white;">Hoàn thành</h3>
                <p style="color: white;"><strong style="font-size: 2rem;">${completedCount}</strong> ca khám</p>
                <a href="${pageContext.request.contextPath}/doctor/medical-records" class="btn-dashboard" style="background: rgba(255,255,255,0.2); color: white;">Xem báo cáo</a>
            </div>
        </section>

        <!-- Quick Stats -->
        <section class="recent-section">
            <h2><i class="fas fa-chart-pie"></i> Thống kê nhanh</h2>
            <div class="quick-stats">
                <div class="stat-box" style="background: #fff3cd; border-left-color: #ffc107; color: #856404;">
                    <div>Đang chờ</div>
                    <div>${pendingCount}</div>
                </div>
                <div class="stat-box" style="background: #d1ecf1; border-left-color: #17a2b8; color: #0c5460;">
                    <div>Đang khám</div>
                    <div>${inProgressCount}</div>
                </div>
                <div class="stat-box" style="background: #d4edda; border-left-color: #28a745; color: #155724;">
                    <div>Hoàn thành tháng này</div>
                    <div>${completedCount}</div>
                </div>
            </div>
        </section>

        <!-- Today's Appointments -->
        <section class="recent-section">
            <h2><i class="fas fa-calendar-day"></i> Lịch hẹn hôm nay</h2>
            <c:choose>
                <c:when test="${not empty todayAppointments}">
                    <table class="recent-table">
                        <thead>
                            <tr>
                                <th>Thời gian</th>
                                <th>Khách hàng</th>
                                <th>Thú cưng</th>
                                <th>Dịch vụ</th>
                                <th>Trạng thái</th>
                                <th>Hành động</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="appointment" items="${todayAppointments}">
                                <tr>
                                    <td>
                                        <c:if test="${not empty appointment.appointmentStart}">
                                            ${appointment.appointmentStart}
                                        </c:if>
                                    </td>
                                    <td>${appointment.customerName}</td>
                                    <td>${appointment.petName}</td>
                                    <td>${appointment.serviceNames}</td>
                                    <td>
                                        <span class="status status-${appointment.status}">${appointment.status}</span>
                                    </td>
                                    <td>
                                        <a href="${pageContext.request.contextPath}/doctor/appointment-detail?id=${appointment.bookingId}" class="btn-small">Chi tiết</a>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </c:when>
                <c:otherwise>
                    <div class="no-data">
                        <i class="fas fa-calendar-times"></i>
                        <p>Không có lịch hẹn nào hôm nay</p>
                    </div>
                </c:otherwise>
            </c:choose>
        </section>

        <!-- Upcoming Appointments -->
        <section class="recent-section">
            <h2><i class="fas fa-calendar-week"></i> Lịch hẹn sắp tới (7 ngày)</h2>
            <c:choose>
                <c:when test="${not empty upcomingAppointments}">
                    <table class="recent-table">
                        <thead>
                            <tr>
                                <th>Ngày</th>
                                <th>Thời gian</th>
                                <th>Khách hàng</th>
                                <th>Thú cưng</th>
                                <th>Dịch vụ</th>
                                <th>Hành động</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="appointment" items="${upcomingAppointments}">
                                <tr>
                                    <td>
                                        <c:if test="${not empty appointment.appointmentStart}">
                                            ${appointment.appointmentStart}
                                        </c:if>
                                    </td>
                                    <td>
                                        <c:if test="${not empty appointment.appointmentStart}">
                                            ${appointment.appointmentStart}
                                        </c:if>
                                    </td>
                                    <td>${appointment.customerName}</td>
                                    <td>${appointment.petName}</td>
                                    <td>${appointment.serviceNames}</td>
                                    <td>
                                        <a href="${pageContext.request.contextPath}/doctor/appointment-detail?id=${appointment.bookingId}" class="btn-small">Chi tiết</a>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </c:when>
                <c:otherwise>
                    <div class="no-data">
                        <i class="fas fa-calendar-check"></i>
                        <p>Không có lịch hẹn nào trong 7 ngày tới</p>
                    </div>
                </c:otherwise>
            </c:choose>
        </section>
    </main>
</div>

<footer class="staff-footer">
    <p>© 2025 Pet4Care — Dedicated to Pet Health & Happiness 🐶🐱</p>
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

// Attendance & Payroll JavaScript
document.addEventListener("DOMContentLoaded", () => {
    const btn = document.getElementById("attendanceButton");
    const generateBtn = document.getElementById("generatePayrollBtn");

    // Check-in / Check-out toggle
    if (btn) {
        btn.addEventListener("click", async () => {
            try {
                const formData = new URLSearchParams();
                formData.append("action", "toggle");

                const res = await fetch("${pageContext.request.contextPath}/doctor/attendance", {
                    method: "POST",
                    headers: {"Content-Type": "application/x-www-form-urlencoded"},
                    body: formData.toString()
                });

                const data = await res.json();

                if (data.status === "error") {
                    Swal.fire({
                        icon: "warning",
                        title: "Thông báo",
                        text: data.message,
                        confirmButtonText: "OK"
                    });
                } else {
                    Swal.fire({
                        icon: "success",
                        title: "Thành công!",
                        text: data.message,
                        confirmButtonText: "OK"
                    }).then(() => {
                        const btn = document.getElementById("attendanceButton");
                        const status = document.getElementById("attendanceStatus");

                        if (btn.classList.contains("btn-checkin")) {
                            // Đổi từ check-in sang check-out (xanh → vàng)
                            btn.classList.remove("btn-checkin");
                            btn.classList.add("btn-checkout");
                            btn.textContent = "Check-out";
                            status.textContent = "Bạn đang trong ca làm.";
                        } else {
                            // Đổi từ check-out sang check-in (vàng → xanh)
                            btn.classList.remove("btn-checkout");
                            btn.classList.add("btn-checkin");
                            btn.textContent = "Check-in";
                            status.textContent = "Bạn chưa bắt đầu ca làm.";
                        }
                    });
                }
            } catch (err) {
                Swal.fire({
                    icon: "error",
                    title: "Lỗi hệ thống",
                    text: "Không thể kết nối máy chủ. Hãy thử lại sau.",
                    confirmButtonText: "OK"
                });
            }
        });
    }

    // Generate payroll
    if (generateBtn) {
        generateBtn.addEventListener("click", async () => {
            try {
                const formData = new URLSearchParams();
                formData.append("action", "generate");

                const res = await fetch("${pageContext.request.contextPath}/doctor/attendance", {
                    method: "POST",
                    headers: {"Content-Type": "application/x-www-form-urlencoded"},
                    body: formData.toString()
                });

                const data = await res.json();
                if (data.status === "success") {
                    Swal.fire({
                        icon: "success",
                        title: "Thành công!",
                        text: data.message,
                        confirmButtonText: "OK"
                    }).then(() => window.location.reload());
                } else {
                    Swal.fire({
                        icon: "warning",
                        title: "Không thành công",
                        text: data.message,
                        confirmButtonText: "OK"
                    });
                }
            } catch (err) {
                Swal.fire({
                    icon: "error",
                    title: "Lỗi hệ thống",
                    text: "Không thể kết nối máy chủ.",
                    confirmButtonText: "OK"
                });
            }
        });
    }
});
</script>

</body>
</html>
