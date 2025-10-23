<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ page import="dao.DoctorDAO" %>
<%@ page import="dao.BookingDAO" %>
<%@ page import="model.Doctor" %>
<%@ page import="model.Booking" %>
<%@ page import="java.util.List" %>
<%@ page import="java.time.LocalDate" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%
    // Kiểm tra đăng nhập
    Doctor doctor = (Doctor) session.getAttribute("doctor");
    if (doctor == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    
    // Lấy dữ liệu cho dashboard
    DoctorDAO doctorDAO = new DoctorDAO();
    BookingDAO bookingDAO = new BookingDAO();
    
    // Lấy thông tin doctor đầy đủ
    Doctor fullDoctorInfo = doctorDAO.findById(doctor.getDoctorId());
    
    // Lấy lịch hẹn hôm nay
    List<Booking> todayAppointments = bookingDAO.getBookingsByDoctorAndDate(doctor.getDoctorId(), LocalDate.now());
    
    // Lấy lịch hẹn sắp tới (7 ngày tới)
    List<Booking> upcomingAppointments = bookingDAO.getBookingsByDoctorAndDateRange(
        doctor.getDoctorId(), 
        LocalDate.now().plusDays(1), 
        LocalDate.now().plusDays(7)
    );
    
    // Đặt vào request để JSP sử dụng
    request.setAttribute("fullDoctorInfo", fullDoctorInfo);
    request.setAttribute("todayAppointments", todayAppointments);
    request.setAttribute("upcomingAppointments", upcomingAppointments);
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>🐾 Doctor Dashboard | Pet4Care</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/staff.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <style>
        .schedule-info {
            background: #e3f2fd;
            padding: 10px;
            border-radius: 5px;
            margin-top: 10px;
            border-left: 4px solid #2196F3;
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
                <h3>Today's Appointments</h3>
                <p><strong>${todayAppointments.size()}</strong> ca khám hôm nay</p>
                <a href="appointments.jsp" class="btn-dashboard">Xem chi tiết</a>
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
</script>

</body>
</html>
