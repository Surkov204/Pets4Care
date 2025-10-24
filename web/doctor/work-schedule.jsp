<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
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
            gap: 1px;
            background: #ddd;
            border-radius: 8px;
            overflow: hidden;
            margin-bottom: 30px;
        }
        
        .calendar-header {
            background: #f8f9fa;
            padding: 15px;
            text-align: center;
            font-weight: 600;
            color: #333;
        }
        
        .calendar-day {
            background: white;
            padding: 15px;
            min-height: 100px;
            border: 1px solid #f0f0f0;
        }
        
        .calendar-day.today {
            background: #e3f2fd;
            border-color: #2196F3;
        }
        
        .calendar-day.has-appointments {
            background: #e8f5e8;
            border-color: #4CAF50;
        }
        
        .day-number {
            font-weight: bold;
            margin-bottom: 5px;
        }
        
        .appointment-count {
            background: #4CAF50;
            color: white;
            padding: 2px 6px;
            border-radius: 10px;
            font-size: 12px;
            display: inline-block;
        }
        
        .time-slots {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin-top: 30px;
        }
        
        .time-slot {
            background: #f8f9fa;
            padding: 20px;
            border-radius: 8px;
            border-left: 4px solid #4CAF50;
        }
        
        .time-slot h4 {
            margin: 0 0 10px 0;
            color: #333;
        }
        
        .time-slot p {
            margin: 0;
            color: #666;
        }
        
        .edit-schedule-btn {
            background: #4CAF50;
            color: white;
            padding: 10px 20px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            font-size: 16px;
            margin-top: 20px;
        }
        
        .edit-schedule-btn:hover {
            background: #45a049;
        }
        
        .no-schedule {
            text-align: center;
            padding: 40px;
            color: #666;
        }
        
        .no-schedule i {
            font-size: 48px;
            margin-bottom: 16px;
            opacity: 0.5;
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
            <li><a href="work-schedule.jsp" class="active"><i class="fas fa-calendar-alt"></i> Work Schedule</a></li>
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

        <div class="schedule-container">
            <div class="schedule-header">
                <h3><i class="fas fa-calendar"></i> Lịch làm việc hiện tại</h3>
                <button class="edit-schedule-btn" onclick="editSchedule()">
                    <i class="fas fa-edit"></i> Chỉnh sửa lịch
                </button>
            </div>

            <c:choose>
                <c:when test="${not empty fullDoctorInfo.scheduleNote}">
                    <div class="schedule-info">
                        <h3><i class="fas fa-info-circle"></i> Thông tin lịch làm việc</h3>
                        <p>${fullDoctorInfo.scheduleNote}</p>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="no-schedule">
                        <i class="fas fa-calendar-times"></i>
                        <h3>Chưa có lịch làm việc</h3>
                        <p>Bạn chưa thiết lập lịch làm việc. Vui lòng liên hệ quản trị viên để được hỗ trợ.</p>
                    </div>
                </c:otherwise>
            </c:choose>

            <!-- Calendar View -->
            <div class="schedule-info">
                <h3><i class="fas fa-calendar-week"></i> Lịch làm việc tuần này</h3>
                <div class="calendar-grid">
                    <div class="calendar-header">Thứ 2</div>
                    <div class="calendar-header">Thứ 3</div>
                    <div class="calendar-header">Thứ 4</div>
                    <div class="calendar-header">Thứ 5</div>
                    <div class="calendar-header">Thứ 6</div>
                    <div class="calendar-header">Thứ 7</div>
                    <div class="calendar-header">Chủ nhật</div>
                    
                    <div class="calendar-day">
                        <div class="day-number">13</div>
                        <span class="appointment-count">3 ca</span>
                    </div>
                    <div class="calendar-day today">
                        <div class="day-number">14</div>
                        <span class="appointment-count">5 ca</span>
                    </div>
                    <div class="calendar-day">
                        <div class="day-number">15</div>
                        <span class="appointment-count">2 ca</span>
                    </div>
                    <div class="calendar-day">
                        <div class="day-number">16</div>
                        <span class="appointment-count">4 ca</span>
                    </div>
                    <div class="calendar-day">
                        <div class="day-number">17</div>
                        <span class="appointment-count">3 ca</span>
                    </div>
                    <div class="calendar-day">
                        <div class="day-number">18</div>
                        <span class="appointment-count">1 ca</span>
                    </div>
                    <div class="calendar-day">
                        <div class="day-number">19</div>
                        <span class="appointment-count">0 ca</span>
                    </div>
                </div>
            </div>

            <!-- Time Slots -->
            <div class="time-slots">
                <div class="time-slot">
                    <h4><i class="fas fa-sun"></i> Ca sáng</h4>
                    <p><strong>Thời gian:</strong> 08:00 - 12:00</p>
                    <p><strong>Ngày làm việc:</strong> Thứ 2, 4, 6</p>
                    <p><strong>Trạng thái:</strong> <span style="color: #4CAF50;">Đang hoạt động</span></p>
                </div>
                
                <div class="time-slot">
                    <h4><i class="fas fa-cloud-sun"></i> Ca chiều</h4>
                    <p><strong>Thời gian:</strong> 13:00 - 17:00</p>
                    <p><strong>Ngày làm việc:</strong> Thứ 3, 5, 7</p>
                    <p><strong>Trạng thái:</strong> <span style="color: #4CAF50;">Đang hoạt động</span></p>
                </div>
                
                <div class="time-slot">
                    <h4><i class="fas fa-moon"></i> Ca tối</h4>
                    <p><strong>Thời gian:</strong> 18:00 - 21:00</p>
                    <p><strong>Ngày làm việc:</strong> Thứ 2, 4, 6</p>
                    <p><strong>Trạng thái:</strong> <span style="color: #f57c00;">Tùy chọn</span></p>
                </div>
                
                <div class="time-slot">
                    <h4><i class="fas fa-calendar-weekend"></i> Cuối tuần</h4>
                    <p><strong>Thời gian:</strong> 09:00 - 15:00</p>
                    <p><strong>Ngày làm việc:</strong> Thứ 7</p>
                    <p><strong>Trạng thái:</strong> <span style="color: #4CAF50;">Đang hoạt động</span></p>
                </div>
            </div>

            <!-- Quick Actions -->
            <div class="schedule-info">
                <h3><i class="fas fa-tools"></i> Thao tác nhanh</h3>
                <div style="display: flex; gap: 15px; margin-top: 15px;">
                    <button class="edit-schedule-btn" onclick="requestTimeOff()">
                        <i class="fas fa-calendar-times"></i> Xin nghỉ phép
                    </button>
                    <button class="edit-schedule-btn" onclick="viewAppointments()">
                        <i class="fas fa-eye"></i> Xem lịch hẹn
                    </button>
                    <button class="edit-schedule-btn" onclick="exportSchedule()">
                        <i class="fas fa-download"></i> Xuất lịch
                    </button>
                </div>
            </div>
        </div>
    </main>
</div>

<footer class="staff-footer">
    <p>© 2025 Pet4Care — Dedicated to Pet Health & Happiness 🐶🐱</p>
    </footer>

<script>
function editSchedule() {
    alert('Chức năng chỉnh sửa lịch làm việc sẽ được phát triển trong phiên bản tiếp theo!');
}

function requestTimeOff() {
    alert('Chức năng xin nghỉ phép sẽ được phát triển trong phiên bản tiếp theo!');
}

function viewAppointments() {
    window.location.href = 'appointments.jsp';
}

function exportSchedule() {
    alert('Chức năng xuất lịch sẽ được phát triển trong phiên bản tiếp theo!');
}

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