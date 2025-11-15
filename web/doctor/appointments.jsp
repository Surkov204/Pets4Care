<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ page import="model.Doctor" %>
<%
    Doctor doctor = (Doctor) session.getAttribute("doctor");
    if (doctor == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    
    if (request.getAttribute("appointments") == null) {
        response.sendRedirect(request.getContextPath() + "/doctor/appointments");
        return;
    }
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>🐾 Appointments | Pet4Care</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/staff.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <style>
        .date-selector {
            background: white;
            padding: 20px;
            border-radius: 10px;
            margin-bottom: 20px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        
        .date-input {
            padding: 10px;
            border: 2px solid #ddd;
            border-radius: 5px;
            font-size: 16px;
            margin-right: 10px;
        }
        
        .btn-primary {
            background: #4CAF50;
            color: white;
            padding: 10px 20px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            font-size: 16px;
        }
        
        .btn-primary:hover {
            background: #45a049;
        }
        
        .appointments-table {
            background: white;
            border-radius: 10px;
            overflow: hidden;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        
        .appointments-table table {
            width: 100%;
            border-collapse: collapse;
        }
        
        .appointments-table th {
            background: #f8f9fa;
            padding: 15px;
            text-align: left;
            font-weight: 600;
            border-bottom: 2px solid #dee2e6;
        }
        
        .appointments-table td {
            padding: 15px;
            border-bottom: 1px solid #dee2e6;
        }
        
        .appointments-table tr:hover {
            background: #f8f9fa;
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
            margin-right: 5px;
        }
        
        .btn-small:hover {
            background: #45a049;
        }
        
        .btn-danger {
            background: #f44336;
        }
        
        .btn-danger:hover {
            background: #d32f2f;
        }
        
        .no-appointments {
            text-align: center;
            padding: 40px;
            color: #666;
        }
        
        .no-appointments i {
            font-size: 48px;
            margin-bottom: 16px;
            opacity: 0.5;
        }
        
        .appointment-actions {
            display: flex;
            gap: 5px;
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
                <span>${sessionScope.doctor.name}</span>
                <i class="fas fa-chevron-down"></i>
            </div>
            <div class="dropdown-menu" id="dropdownMenu">
                <a href="${pageContext.request.contextPath}/home.jsp">
                    <i class="fas fa-home"></i> Trang chủ
                </a>
                <a href="${pageContext.request.contextPath}/doctor/profile">
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
            <li><a href="${pageContext.request.contextPath}/doctor/dashboard"><i class="fas fa-home"></i> Dashboard</a></li>
            <li><a href="${pageContext.request.contextPath}/doctor/medical-records"><i class="fas fa-notes-medical"></i> Medical Records</a></li>
            <li><a href="${pageContext.request.contextPath}/doctor/work-schedule"><i class="fas fa-calendar-alt"></i> Work Schedule</a></li>
            <li><a href="${pageContext.request.contextPath}/doctor/appointments" class="active"><i class="fas fa-stethoscope"></i> Appointments</a></li>
            <li><a href="${pageContext.request.contextPath}/doctor/profile"><i class="fas fa-user-md"></i> Doctor Profile</a></li>
        </ul>
    </aside>

    <!-- Main Content -->
    <main class="staff-content">
        <section class="welcome-card">
            <h2><i class="fas fa-calendar-check"></i> Quản lý lịch hẹn</h2>
            <p>Xem và quản lý các cuộc hẹn khám của bạn</p>
        </section>

        <!-- Date Selector -->
        <div class="date-selector">
            <form method="get">
                <label for="date"><i class="fas fa-calendar"></i> Chọn ngày:</label>
                <input type="date" name="date" id="date" class="date-input" 
                       value="${selectedDateIso}">
                <button type="submit" class="btn-primary">
                    <i class="fas fa-search"></i> Xem lịch hẹn
                </button>
                <a href="${pageContext.request.contextPath}/doctor/appointments" class="btn-primary" style="text-decoration: none; display: inline-block;">
                    <i class="fas fa-calendar-day"></i> Hôm nay
                </a>
            </form>
        </div>

        <!-- Appointments Table -->
        <div class="appointments-table">
            <c:choose>
                <c:when test="${not empty appointments}">
                    <table>
                        <thead>
                            <tr>
                                <th>Thời gian</th>
                                <th>Khách hàng</th>
                                <th>Thú cưng</th>
                                <th>Loại thú cưng</th>
                                <th>Dịch vụ</th>
                                <th>Trạng thái</th>
                                <th>Ghi chú</th>
                                <th>Hành động</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="appointment" items="${appointments}">
                                <tr>
                                    <td>
                                        <c:if test="${not empty appointment.appointmentStart}">
                                            ${appointment.appointmentStart}
                                        </c:if>
                                    </td>
                                    <td>
                                        <strong>${appointment.customerName}</strong><br>
                                        <small>${appointment.customerPhone}</small>
                                    </td>
                                    <td>${appointment.petName}</td>
                                    <td>${appointment.petType}</td>
                                    <td>${appointment.serviceNames}</td>
                                    <td>
                                        <span class="status <c:choose>
                                            <c:when test="${appointment.status == 'Hoàn thành' || appointment.status == 'completed'}">status-completed</c:when>
                                            <c:when test="${appointment.status == 'Đã xác nhận' || appointment.status == 'confirmed'}">status-confirmed</c:when>
                                            <c:when test="${appointment.status == 'pending' || appointment.status == 'Chưa thanh toán'}">status-pending</c:when>
                                            <c:otherwise>status-cancelled</c:otherwise>
                                        </c:choose>">${appointment.status}</span>
                                    </td>
                                    <td>
                                        <c:if test="${not empty appointment.note}">
                                            ${appointment.note}
                                        </c:if>
                                        <c:if test="${empty appointment.note}">
                                            <em>Không có ghi chú</em>
                                        </c:if>
                                    </td>
                                    <td>
                                        <div class="appointment-actions">
                                            <a href="${pageContext.request.contextPath}/doctor/appointment-detail?id=${appointment.bookingId}" class="btn-small">
                                                <i class="fas fa-eye"></i> Chi tiết
                                            </a>
                                            <c:if test="${appointment.status == 'completed' || appointment.status == 'Hoàn thành'}">
                                                <c:if test="${not empty medicalRecordsMap[appointment.bookingId]}">
                                                    <a href="${pageContext.request.contextPath}/doctor/medical-record-detail?id=${medicalRecordsMap[appointment.bookingId].recordId}" class="btn-small" style="background: #2196F3;">
                                                        <i class="fas fa-file-medical"></i> Xem hồ sơ
                                                    </a>
                                                </c:if>
                                            </c:if>
                                        </div>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </c:when>
                <c:otherwise>
                    <div class="no-appointments">
                        <i class="fas fa-calendar-times"></i>
                        <h3>Không có lịch hẹn nào</h3>
                        <p>Không có cuộc hẹn nào vào ngày ${selectedDateDisplay}</p>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>



        <!-- Statistics -->
        <div class="date-selector">
            <h3><i class="fas fa-chart-bar"></i> Thống kê ngày ${selectedDateDisplay}</h3>
            <div style="display: flex; gap: 20px; margin-top: 15px;">
                <div style="background: #e8f5e8; padding: 15px; border-radius: 5px; flex: 1;">
                    <strong>Tổng số cuộc hẹn:</strong> ${fn:length(allAppointments)}
                </div>
                <div style="background: #fff3e0; padding: 15px; border-radius: 5px; flex: 1;">
                    <strong>Chờ xác nhận:</strong>
                    <c:set var="pendingCount" value="0" />
                    <c:forEach var="appointment" items="${allAppointments}">
                        <c:if test="${appointment.status == 'pending' || appointment.status == 'Chờ xác nhận'}">
                            <c:set var="pendingCount" value="${pendingCount + 1}" />
                        </c:if>
                    </c:forEach>
                    ${pendingCount}
                </div>
                <div style="background: #e3f2fd; padding: 15px; border-radius: 5px; flex: 1;">
                    <strong>Đã xác nhận:</strong>
                    <c:set var="confirmedCount" value="0" />
                    <c:forEach var="appointment" items="${allAppointments}">
                        <c:if test="${appointment.status == 'confirmed' || appointment.status == 'Đã xác nhận'}">
                            <c:set var="confirmedCount" value="${confirmedCount + 1}" />
                        </c:if>
                    </c:forEach>
                    ${confirmedCount}
                </div>
            </div>
        </div>

        <!-- Upcoming Appointments Section -->
        <div class="date-selector" style="margin-top: 30px;">
            <h3><i class="fas fa-calendar-week"></i> Lịch hẹn sắp tới (14 ngày tới)</h3>
            <div class="appointments-table" style="margin-top: 15px;">
                <c:choose>
                    <c:when test="${not empty upcomingAppointments}">
                        <table>
                            <thead>
                                <tr>
                                    <th>Ngày & Giờ</th>
                                    <th>Khách hàng</th>
                                    <th>Thú cưng</th>
                                    <th>Loại</th>
                                    <th>Dịch vụ</th>
                                    <th>Trạng thái</th>
                                    <th>Hành động</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="upcoming" items="${upcomingAppointments}">
                                    <tr>
                                        <td>
                                            <strong style="color: #667eea;">
                                                ${upcoming.appointmentStart}
                                            </strong>
                                        </td>
                                        <td>
                                            <strong>${upcoming.customerName}</strong><br>
                                            <small>${upcoming.customerPhone}</small>
                                        </td>
                                        <td>${upcoming.petName}</td>
                                        <td>${upcoming.petType}</td>
                                        <td><small>${upcoming.serviceNames}</small></td>
                                        <td>
                                            <span class="status status-${upcoming.status}">${upcoming.status}</span>
                                        </td>
                                        <td>
                                            <div class="appointment-actions">
                                                <a href="${pageContext.request.contextPath}/doctor/appointment-detail?id=${upcoming.bookingId}" class="btn-small">
                                                    <i class="fas fa-eye"></i> Xem
                                                </a>
                                            </div>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </c:when>
                    <c:otherwise>
                        <div class="no-appointments">
                            <i class="fas fa-calendar-check"></i>
                            <h3>Không có lịch hẹn sắp tới</h3>
                            <p>Bạn không có lịch hẹn nào trong 14 ngày tới</p>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
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

// Confirm medical record creation
function confirmCreateRecord(petName) {
    return confirm('Bạn có chắc chắn muốn tạo hồ sơ y tế cho thú cưng "' + petName + '"?\n\nHồ sơ y tế sẽ được tạo với thông tin từ lịch hẹn và bạn có thể chỉnh sửa chi tiết sau.');
}
</script>

</body>
</html>
