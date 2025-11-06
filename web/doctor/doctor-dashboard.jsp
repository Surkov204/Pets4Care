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
            background: #e3f2fd;
            padding: 10px;
            border-radius: 5px;
            margin-top: 10px;
            border-left: 4px solid #2196F3;
        }

        /* Attendance & Payroll Styles */
        .attendance-section {
            display: flex;
            flex-wrap: wrap;
            gap: 24px;
            margin-top: 25px;
            margin-bottom: 25px;
        }

        .attendance-card, .salary-card {
            flex: 1;
            background: #fff;
            border-radius: 16px;
            box-shadow: 0 4px 16px rgba(0, 0, 0, 0.05);
            padding: 30px 25px;
            transition: all 0.3s ease;
        }

        .attendance-card:hover, .salary-card:hover {
            transform: translateY(-3px);
            box-shadow: 0 6px 18px rgba(0, 0, 0, 0.08);
        }

        .attendance-card {
            text-align: center;
        }

        .attendance-card h3, .salary-card h3 {
            color: #334155;
            font-weight: 600;
            margin-bottom: 10px;
        }

        .attendance-subtext {
            color: #64748b;
            font-size: 14px;
            margin-bottom: 20px;
        }

        .btn-checkin, .btn-checkout {
            border: none;
            border-radius: 40px;
            font-weight: 600;
            cursor: pointer;
            padding: 14px 40px;
            font-size: 18px;
            transition: all 0.3s ease;
        }

        .btn-checkin {
            background: linear-gradient(135deg, #22c55e, #16a34a);
            color: #fff;
            box-shadow: 0 5px 12px rgba(34,197,94,0.4);
        }

        .btn-checkin:hover {
            background: linear-gradient(135deg, #16a34a, #15803d);
            transform: scale(1.03);
        }

        .btn-checkout {
            background: linear-gradient(135deg, #facc15, #eab308);
            color: #333;
            box-shadow: 0 5px 12px rgba(250,204,21,0.4);
        }

        .btn-checkout:hover {
            background: linear-gradient(135deg, #eab308, #ca8a04);
            transform: scale(1.03);
        }

        .salary-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 15px;
        }

        .btn-calc-salary {
            background: #3b82f6;
            color: #fff;
            font-size: 13px;
            border: none;
            border-radius: 8px;
            font-weight: 600;
            cursor: pointer;
            padding: 10px 20px;
            transition: all 0.3s ease;
        }

        .btn-calc-salary:hover {
            background: #2563eb;
        }

        .salary-table {
            width: 100%;
            border-collapse: collapse;
            text-align: center;
        }

        .salary-table th {
            background: #f1f5f9;
            color: #475569;
            padding: 10px;
            font-weight: 600;
        }

        .salary-table td {
            padding: 10px;
            border-top: 1px solid #e2e8f0;
            color: #334155;
            font-size: 14px;
        }

        .salary-table .empty-msg {
            color: #94a3b8;
            font-style: italic;
            text-align: center;
        }
        
        .status {
            padding: 4px 8px;
            border-radius: 4px;
            font-size: 12px;
            font-weight: bold;
        }
        
        .status-confirmed { background: #e8f5e8; color: #2e7d32; }
        .status-pending { background: #fff3e0; color: #f57c00; }
        .status-cancelled { background: #ffebee; color: #c62828; }
        .status-completed { background: #e3f2fd; color: #1565c0; }
        
        .btn-small {
            background: #4CAF50;
            color: white;
            padding: 4px 8px;
            border-radius: 3px;
            text-decoration: none;
            font-size: 12px;
        }
        
        .btn-small:hover {
            background: #45a049;
        }
        
        .no-data {
            text-align: center;
            padding: 40px;
            color: #666;
        }
        
        .no-data i {
            font-size: 48px;
            margin-bottom: 16px;
            opacity: 0.5;
        }
        
        .avatar small {
            display: block;
            font-size: 12px;
            color: #666;
            margin-top: 2px;
        }
        
        /* Dropdown Menu Styles */
        .avatar-dropdown {
            position: relative;
            display: inline-block;
            transform: translateX(50px);
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
            width: 16px;
            text-align: center;
        }
    </style>
</head>
<body>

<header class="staff-header">
    <div class="user-section">
        <div class="avatar-dropdown">
            <div class="avatar" onclick="toggleDropdown()">
                <img src="${pageContext.request.contextPath}/images/doctor-avatar.png" alt="Doctor">
                <span>${fullDoctorInfo.name}</span>
                <i class="fas fa-chevron-down"></i>
            </div>
            <div class="dropdown-menu" id="dropdownMenu">
                <a href="${pageContext.request.contextPath}/home.jsp">
                    <i class="fas fa-home"></i> Trang chủ
                </a>
                <a href="doctor-profile.jsp">
                    <i class="fas fa-user-edit"></i> Chỉnh sửa thông tin
                </a>
                <a href="${pageContext.request.contextPath}/logout">
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
            <li><a href="doctor-dashboard.jsp" class="active"><i class="fas fa-home"></i> Dashboard</a></li>
            <li><a href="medical-record.jsp"><i class="fas fa-notes-medical"></i> Medical Records</a></li>
            <li><a href="work-schedule.jsp"><i class="fas fa-calendar-alt"></i> Work Schedule</a></li>
            <li><a href="appointments.jsp"><i class="fas fa-stethoscope"></i> Appointments</a></li>
            <li><a href="doctor-profile.jsp"><i class="fas fa-user-md"></i> Doctor Profile</a></li>
        </ul>
    </aside>

    <!-- Main Content -->
    <main class="staff-content">
        <section class="welcome-card">
            <h2>Chào mừng trở lại, Bác sĩ ${fullDoctorInfo.name} 👨‍⚕️</h2>
            <p>Chuyên khoa: <strong>${fullDoctorInfo.specialization}</strong></p>
            <p>Chúc bạn một ngày làm việc hiệu quả cùng các thú cưng đáng yêu!</p>
            <c:if test="${not empty fullDoctorInfo.scheduleNote}">
                <div class="schedule-info">
                    <i class="fas fa-calendar"></i> ${fullDoctorInfo.scheduleNote}
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
                <a href="appointments.jsp" class="btn-dashboard" style="background: rgba(255,255,255,0.2); color: white;">Xem chi tiết</a>
            </div>

            <div class="dashboard-card" style="background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%); color: white;">
                <i class="fas fa-clock" style="color: white;"></i>
                <h3 style="color: white;">Sắp tới</h3>
                <p style="color: white;"><strong style="font-size: 2rem;">${upcomingCount}</strong> lịch hẹn</p>
                <a href="appointments.jsp" class="btn-dashboard" style="background: rgba(255,255,255,0.2); color: white;">Xem chi tiết</a>
            </div>

            <div class="dashboard-card" style="background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%); color: white;">
                <i class="fas fa-calendar-alt" style="color: white;"></i>
                <h3 style="color: white;">Tháng này</h3>
                <p style="color: white;"><strong style="font-size: 2rem;">${monthlyCount}</strong> ca khám</p>
                <a href="medical-record.jsp" class="btn-dashboard" style="background: rgba(255,255,255,0.2); color: white;">Hồ sơ</a>
            </div>

            <div class="dashboard-card" style="background: linear-gradient(135deg, #43e97b 0%, #38f9d7 100%); color: white;">
                <i class="fas fa-check-circle" style="color: white;"></i>
                <h3 style="color: white;">Hoàn thành</h3>
                <p style="color: white;"><strong style="font-size: 2rem;">${completedCount}</strong> ca khám</p>
                <a href="medical-record.jsp" class="btn-dashboard" style="background: rgba(255,255,255,0.2); color: white;">Xem báo cáo</a>
            </div>
        </section>

        <!-- Quick Stats -->
        <section class="recent-section" style="background: white; padding: 20px; border-radius: 10px; margin-bottom: 20px;">
            <h3 style="margin-bottom: 15px;"><i class="fas fa-chart-pie"></i> Thống kê nhanh</h3>
            <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 15px;">
                <div style="background: #fff3cd; padding: 15px; border-radius: 8px; border-left: 4px solid #ffc107;">
                    <div style="font-size: 0.9rem; color: #856404;">Đang chờ</div>
                    <div style="font-size: 1.5rem; font-weight: bold; color: #856404;">${pendingCount}</div>
                </div>
                <div style="background: #d1ecf1; padding: 15px; border-radius: 8px; border-left: 4px solid #17a2b8;">
                    <div style="font-size: 0.9rem; color: #0c5460;">Đang khám</div>
                    <div style="font-size: 1.5rem; font-weight: bold; color: #0c5460;">${inProgressCount}</div>
                </div>
                <div style="background: #d4edda; padding: 15px; border-radius: 8px; border-left: 4px solid #28a745;">
                    <div style="font-size: 0.9rem; color: #155724;">Hoàn thành tháng này</div>
                    <div style="font-size: 1.5rem; font-weight: bold; color: #155724;">${completedCount}</div>
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
                                        <a href="appointment-detail.jsp?id=${appointment.bookingId}" class="btn-small">Chi tiết</a>
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
                                        <a href="appointment-detail.jsp?id=${appointment.bookingId}" class="btn-small">Chi tiết</a>
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
