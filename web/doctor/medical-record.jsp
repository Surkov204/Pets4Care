<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ page import="dao.DoctorDAO" %>
<%@ page import="dao.BookingDAO" %>
<%@ page import="model.Doctor" %>
<%@ page import="model.Booking" %>
<%@ page import="java.util.List" %>
<%
    // Kiểm tra đăng nhập
    Doctor doctor = (Doctor) session.getAttribute("doctor");
    if (doctor == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    
    // Lấy dữ liệu hồ sơ y tế (sử dụng booking data)
    BookingDAO bookingDAO = new BookingDAO();
    List<Booking> medicalRecords = bookingDAO.getBookingsByDoctorAndDateRange(
        doctor.getDoctorId(), 
        java.time.LocalDate.now().minusMonths(3), 
        java.time.LocalDate.now()
    );
    
    request.setAttribute("medicalRecords", medicalRecords);
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>🐾 Medical Records | Pet4Care</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/staff.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <style>
        .medical-records-table {
            background: white;
            border-radius: 10px;
            overflow: hidden;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        
        .medical-records-table table {
            width: 100%;
            border-collapse: collapse;
        }
        
        .medical-records-table th {
            background: #f8f9fa;
            padding: 15px;
            text-align: left;
            font-weight: 600;
            border-bottom: 2px solid #dee2e6;
        }
        
        .medical-records-table td {
            padding: 15px;
            border-bottom: 1px solid #dee2e6;
        }
        
        .medical-records-table tr:hover {
            background: #f8f9fa;
        }
        
        .status {
            padding: 4px 8px;
            border-radius: 4px;
            font-size: 12px;
            font-weight: bold;
        }
        
        .status-completed { background: #e3f2fd; color: #1565c0; }
        .status-confirmed { background: #e8f5e8; color: #2e7d32; }
        
        .no-records {
            text-align: center;
            padding: 40px;
            color: #666;
        }
        
        .no-records i {
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
        
        .search-filter {
            background: white;
            padding: 20px;
            border-radius: 10px;
            margin-bottom: 20px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        
        .search-input {
            padding: 10px;
            border: 2px solid #ddd;
            border-radius: 5px;
            font-size: 16px;
            width: 300px;
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
            <li><a href="medical-record.jsp" class="active"><i class="fas fa-notes-medical"></i> Medical Records</a></li>
            <li><a href="work-schedule.jsp"><i class="fas fa-calendar-alt"></i> Work Schedule</a></li>
            <li><a href="appointments.jsp"><i class="fas fa-stethoscope"></i> Appointments</a></li>
            <li><a href="doctor-profile.jsp"><i class="fas fa-user-md"></i> Doctor Profile</a></li>
        </ul>
    </aside>

    <!-- Main Content -->
    <main class="staff-content">
        <section class="welcome-card">
            <h2><i class="fas fa-notes-medical"></i> Hồ sơ y tế thú cưng</h2>
            <p>Quản lý và theo dõi lịch sử khám bệnh của các thú cưng</p>
    </section>

        <!-- Search and Filter -->
        <div class="search-filter">
            <form method="get">
                <input type="text" name="search" placeholder="Tìm kiếm theo tên thú cưng hoặc chủ sở hữu..." 
                       class="search-input" value="${param.search}">
                <button type="submit" class="btn-primary">
                    <i class="fas fa-search"></i> Tìm kiếm
                </button>
                <a href="medical-record.jsp" class="btn-primary" style="text-decoration: none; display: inline-block;">
                    <i class="fas fa-refresh"></i> Làm mới
                </a>
            </form>
        </div>

        <!-- Medical Records Table -->
        <div class="medical-records-table">
            <c:choose>
                <c:when test="${not empty medicalRecords}">
                    <table>
            <thead>
                            <tr>
                                <th>Ngày khám</th>
                                <th>Tên thú cưng</th>
                                <th>Chủ sở hữu</th>
                                <th>Loại thú cưng</th>
                                <th>Dịch vụ</th>
                                <th>Trạng thái</th>
                                <th>Ghi chú</th>
                                <th>Hành động</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach var="record" items="${medicalRecords}">
                                <tr>
                                    <td>
                                        <c:if test="${not empty record.appointmentStart}">
                                            ${record.appointmentStart}
                                        </c:if>
                                    </td>
                                    <td>
                                        <strong>${record.petName}</strong>
                                    </td>
                                    <td>
                                        ${record.customerName}<br>
                                        <small>${record.customerPhone}</small>
                                    </td>
                                    <td>${record.petType}</td>
                                    <td>${record.serviceNames}</td>
                                    <td>
                                        <span class="status status-${record.status}">${record.status}</span>
                                    </td>
                                    <td>
                                        <c:if test="${not empty record.note}">
                                            ${record.note}
                                        </c:if>
                                        <c:if test="${empty record.note}">
                                            <em>Không có ghi chú</em>
                                        </c:if>
                                    </td>
                                    <td>
                                        <a href="appointment-detail.jsp?id=${record.bookingId}" class="btn-small">
                                            <i class="fas fa-eye"></i> Chi tiết
                                        </a>
                                    </td>
                    </tr>
                </c:forEach>
            </tbody>
        </table>
                </c:when>
                <c:otherwise>
                    <div class="no-records">
                        <i class="fas fa-notes-medical"></i>
                        <h3>Chưa có hồ sơ y tế</h3>
                        <p>Chưa có hồ sơ khám bệnh nào trong 3 tháng gần đây</p>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>

        <!-- Statistics -->
        <div class="search-filter">
            <h3><i class="fas fa-chart-bar"></i> Thống kê hồ sơ y tế</h3>
            <div style="display: flex; gap: 20px; margin-top: 15px;">
                <div style="background: #e8f5e8; padding: 15px; border-radius: 5px; flex: 1;">
                    <strong>Tổng số hồ sơ:</strong> ${medicalRecords.size()}
                </div>
                <div style="background: #e3f2fd; padding: 15px; border-radius: 5px; flex: 1;">
                    <strong>Đã hoàn thành:</strong>
                    <c:set var="completedCount" value="0" />
                    <c:forEach var="record" items="${medicalRecords}">
                        <c:if test="${record.status == 'completed'}">
                            <c:set var="completedCount" value="${completedCount + 1}" />
                        </c:if>
                    </c:forEach>
                    ${completedCount}
                </div>
                <div style="background: #fff3e0; padding: 15px; border-radius: 5px; flex: 1;">
                    <strong>Đang điều trị:</strong>
                    <c:set var="confirmedCount" value="0" />
                    <c:forEach var="record" items="${medicalRecords}">
                        <c:if test="${record.status == 'confirmed'}">
                            <c:set var="confirmedCount" value="${confirmedCount + 1}" />
                        </c:if>
                    </c:forEach>
                    ${confirmedCount}
                </div>
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
</script>

</body>
</html>
