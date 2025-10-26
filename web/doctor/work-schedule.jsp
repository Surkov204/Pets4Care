<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<%@ page import="dao.DoctorDAO" %>
<%@ page import="model.Doctor" %>
<%
    // Kiểm tra đăng nhập
    Doctor doctor = (Doctor) session.getAttribute("doctor");
    if (doctor == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    
    // Lấy thông tin doctor đầy đủ
    DoctorDAO doctorDAO = new DoctorDAO();
    Doctor fullDoctorInfo = doctorDAO.findById(doctor.getDoctorId());
    
    request.setAttribute("fullDoctorInfo", fullDoctorInfo);
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>🐾 Work Schedule | Pet4Care</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/staff.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <style>
        .schedule-container {
            background: white;
            border-radius: 10px;
            padding: 30px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            margin-bottom: 20px;
        }
        
        .schedule-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 30px;
            padding-bottom: 20px;
            border-bottom: 2px solid #f0f0f0;
        }
        
        .week-navigation {
            display: flex;
            gap: 15px;
            align-items: center;
        }
        
        .week-navigation button {
            background: #4CAF50;
            color: white;
            padding: 10px 20px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            font-size: 14px;
        }
        
        .week-navigation button:hover {
            background: #45a049;
        }
        
        .week-range {
            font-weight: 600;
            color: #333;
            font-size: 18px;
        }
        
        .schedule-info {
            background: #e3f2fd;
            padding: 20px;
            border-radius: 8px;
            border-left: 4px solid #2196F3;
            margin-bottom: 30px;
        }
        
        .schedule-info h3 {
            margin: 0 0 10px 0;
            color: #1565c0;
        }
        
        .schedule-info p {
            margin: 0;
            color: #333;
            font-size: 16px;
        }
        
        .calendar-grid {
            display: grid;
            grid-template-columns: repeat(7, 1fr);
            gap: 10px;
            margin-bottom: 30px;
        }
        
        .calendar-day {
            background: white;
            padding: 15px;
            min-height: 120px;
            border: 2px solid #f0f0f0;
            border-radius: 8px;
            transition: all 0.3s;
        }
        
        .calendar-day:hover {
            box-shadow: 0 4px 8px rgba(0,0,0,0.1);
        }
        
        .calendar-day.today {
            background: #e3f2fd;
            border-color: #2196F3;
        }
        
        .calendar-day.has-schedule {
            background: #e8f5e9;
            border-color: #4CAF50;
        }
        
        .day-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 10px;
            padding-bottom: 8px;
            border-bottom: 1px solid #e0e0e0;
        }
        
        .day-name {
            font-weight: 600;
            color: #666;
            font-size: 14px;
        }
        
        .day-number {
            font-weight: bold;
            font-size: 20px;
            color: #333;
        }
        
        .shift-item {
            background: #f8f9fa;
            padding: 8px;
            margin: 5px 0;
            border-radius: 5px;
            font-size: 13px;
            display: flex;
            align-items: center;
            gap: 5px;
        }
        
        .shift-item.morning {
            background: #fff3e0;
            color: #e65100;
            border-left: 3px solid #ff9800;
        }
        
        .shift-item.afternoon {
            background: #e3f2fd;
            color: #0d47a1;
            border-left: 3px solid #2196F3;
        }
        
        .shift-item.evening {
            background: #f3e5f5;
            color: #4a148c;
            border-left: 3px solid #9c27b0;
        }
        
        .shift-time {
            font-size: 11px;
            opacity: 0.8;
        }
        
        .no-schedule {
            text-align: center;
            padding: 10px;
            color: #999;
            font-size: 13px;
        }
        
        .stats-container {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 20px;
            margin-bottom: 30px;
        }
        
        .stat-card {
            background: white;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
            text-align: center;
        }
        
        .stat-card i {
            font-size: 32px;
            margin-bottom: 10px;
        }
        
        .stat-card.morning i {
            color: #ff9800;
        }
        
        .stat-card.afternoon i {
            color: #2196F3;
        }
        
        .stat-card.evening i {
            color: #9c27b0;
        }
        
        .stat-card.total i {
            color: #4CAF50;
        }
        
        .stat-number {
            font-size: 28px;
            font-weight: bold;
            color: #333;
        }
        
        .stat-label {
            color: #666;
            font-size: 14px;
        }
        
        .schedule-list {
            margin-top: 30px;
        }
        
        .schedule-list-item {
            background: white;
            padding: 15px 20px;
            margin-bottom: 10px;
            border-radius: 8px;
            border-left: 4px solid #4CAF50;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        
        .schedule-date {
            font-weight: 600;
            color: #333;
        }
        
        .schedule-shift {
            display: inline-block;
            padding: 5px 15px;
            border-radius: 15px;
            font-size: 13px;
            font-weight: 500;
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
            <li><a href="doctor-dashboard.jsp"><i class="fas fa-home"></i> Dashboard</a></li>
            <li><a href="medical-record.jsp"><i class="fas fa-notes-medical"></i> Medical Records</a></li>
            <li><a href="${pageContext.request.contextPath}/doctor/work-schedule" class="active"><i class="fas fa-calendar-alt"></i> Work Schedule</a></li>
            <li><a href="appointments.jsp"><i class="fas fa-stethoscope"></i> Appointments</a></li>
            <li><a href="doctor-profile.jsp"><i class="fas fa-user-md"></i> Doctor Profile</a></li>
        </ul>
    </aside>

    <!-- Main Content -->
    <main class="staff-content">
        <section class="welcome-card">
            <h2><i class="fas fa-calendar-alt"></i> Lịch làm việc</h2>
            <p>Quản lý lịch làm việc và thời gian khám bệnh của bạn</p>
        </section>

        <!-- Statistics -->
        <div class="stats-container">
            <div class="stat-card morning">
                <i class="fas fa-sun"></i>
                <div class="stat-number">${shiftStats.morning}</div>
                <div class="stat-label">Ca sáng</div>
            </div>
            <div class="stat-card afternoon">
                <i class="fas fa-cloud-sun"></i>
                <div class="stat-number">${shiftStats.afternoon}</div>
                <div class="stat-label">Ca chiều</div>
            </div>
            <div class="stat-card evening">
                <i class="fas fa-moon"></i>
                <div class="stat-number">${shiftStats.evening}</div>
                <div class="stat-label">Ca tối</div>
            </div>
            <div class="stat-card total">
                <i class="fas fa-calendar-check"></i>
                <div class="stat-number">${shiftStats.total}</div>
                <div class="stat-label">Tổng ca</div>
            </div>
        </div>

        <div class="schedule-container">
            <div class="schedule-header">
                <h3><i class="fas fa-calendar-week"></i> Lịch tuần</h3>
                <div class="week-navigation">
                    <button onclick="changeWeek(-1)">
                        <i class="fas fa-chevron-left"></i> Tuần trước
                    </button>
                    <span class="week-range">${startDate} - ${endDate}</span>
                    <button onclick="changeWeek(1)">
                        Tuần sau <i class="fas fa-chevron-right"></i>
                    </button>
                </div>
            </div>

            <c:if test="${not empty fullDoctorInfo.scheduleNote}">
                <div class="schedule-info">
                    <h3><i class="fas fa-info-circle"></i> Ghi chú lịch làm việc</h3>
                    <p>${fullDoctorInfo.scheduleNote}</p>
                </div>
            </c:if>

            <!-- Calendar Grid -->
            <div class="calendar-grid">
                <c:forEach var="day" items="${weekDays}">
                    <div class="calendar-day ${day.isToday ? 'today' : ''} ${day.hasSchedule ? 'has-schedule' : ''}">
                        <div class="day-header">
                            <span class="day-name">${day.dayOfWeek}</span>
                            <span class="day-number">${day.dayNumber}</span>
                        </div>
                        
                        <c:choose>
                            <c:when test="${day.hasSchedule}">
                                <c:forEach var="schedule" items="${day.schedules}">
                                    <c:set var="shiftClass" value=""/>
                                    <c:if test="${schedule.shiftName.toLowerCase().contains('sáng')}">
                                        <c:set var="shiftClass" value="morning"/>
                                    </c:if>
                                    <c:if test="${schedule.shiftName.toLowerCase().contains('chiều')}">
                                        <c:set var="shiftClass" value="afternoon"/>
                                    </c:if>
                                    <c:if test="${schedule.shiftName.toLowerCase().contains('tối')}">
                                        <c:set var="shiftClass" value="evening"/>
                                    </c:if>
                                    
                                    <div class="shift-item ${shiftClass}">
                                        <i class="fas fa-clock"></i>
                                        <div>
                                            <div><strong>${schedule.shiftName}</strong></div>
                                            <div class="shift-time">
                                                <fmt:formatDate value="${schedule.startTime}" pattern="HH:mm"/> - 
                                                <fmt:formatDate value="${schedule.endTime}" pattern="HH:mm"/>
                                            </div>
                                        </div>
                                    </div>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <div class="no-schedule">
                                    <i class="fas fa-calendar-times"></i>
                                    <div>Nghỉ</div>
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </c:forEach>
            </div>

            <!-- Detailed Schedule List -->
            <c:if test="${not empty allSchedules}">
                <div class="schedule-list">
                    <h3><i class="fas fa-list"></i> Chi tiết lịch làm việc tuần này</h3>
                    <c:forEach var="schedule" items="${allSchedules}">
                        <div class="schedule-list-item">
                            <div>
                                <span class="schedule-date">
                                    <i class="fas fa-calendar"></i>
                                    <fmt:formatDate value="${schedule.workDate}" pattern="dd/MM/yyyy (EEEE)" />
                                </span>
                            </div>
                            <div>
                                <c:set var="shiftClass" value=""/>
                                <c:set var="bgColor" value="#4CAF50"/>
                                <c:if test="${schedule.shiftName.toLowerCase().contains('sáng')}">
                                    <c:set var="bgColor" value="#ff9800"/>
                                </c:if>
                                <c:if test="${schedule.shiftName.toLowerCase().contains('chiều')}">
                                    <c:set var="bgColor" value="#2196F3"/>
                                </c:if>
                                <c:if test="${schedule.shiftName.toLowerCase().contains('tối')}">
                                    <c:set var="bgColor" value="#9c27b0"/>
                                </c:if>
                                
                                <span class="schedule-shift" style="background: ${bgColor}; color: white;">
                                    ${schedule.shiftName}: 
                                    <fmt:formatDate value="${schedule.startTime}" pattern="HH:mm"/> - 
                                    <fmt:formatDate value="${schedule.endTime}" pattern="HH:mm"/>
                                </span>
                            </div>
                        </div>
                    </c:forEach>
                </div>
            </c:if>
            
            <c:if test="${empty allSchedules}">
                <div class="schedule-info" style="background: #fff3e0; border-left-color: #ff9800;">
                    <h3><i class="fas fa-exclamation-triangle"></i> Chưa có lịch làm việc</h3>
                    <p>Bạn chưa có lịch làm việc nào trong tuần này. Vui lòng liên hệ quản trị viên để được sắp xếp lịch.</p>
                </div>
            </c:if>
        </div>
    </main>
</div>

<footer class="staff-footer">
    <p>© 2025 Pet4Care — Dedicated to Pet Health & Happiness 🐶🐱</p>
</footer>

<script>
function changeWeek(offset) {
    const currentOffset = ${weekOffset};
    const newOffset = currentOffset + offset;
    window.location.href = '${pageContext.request.contextPath}/doctor/work-schedule?weekOffset=' + newOffset;
}

function toggleDropdown() {
    const dropdown = document.getElementById('dropdownMenu');
    dropdown.classList.toggle('show');
}

// Close dropdown when clicking outside
document.addEventListener('click', function(event) {
    const dropdown = document.getElementById('dropdownMenu');
    const avatar = document.querySelector('.avatar');
    
    if (avatar && !avatar.contains(event.target)) {
        dropdown.classList.remove('show');
    }
});
</script>

</body>
</html>
