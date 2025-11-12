<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ page import="model.Doctor" %>
<%
    // Kiểm tra đăng nhập
    Doctor doctor = (Doctor) session.getAttribute("doctor");
    if (doctor == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    
    // Dữ liệu được load từ DoctorMedicalRecordController
    if (request.getAttribute("medicalRecords") == null) {
        response.sendRedirect(request.getContextPath() + "/doctor/medical-records");
        return;
    }
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
            <li><a href="${pageContext.request.contextPath}/doctor/medical-records" class="active"><i class="fas fa-notes-medical"></i> Medical Records</a></li>
            <li><a href="${pageContext.request.contextPath}/doctor/appointments"><i class="fas fa-stethoscope"></i> Appointments</a></li>
            <li><a href="${pageContext.request.contextPath}/doctor/work-schedule"><i class="fas fa-calendar-alt"></i> Work Schedule</a></li>
            <li><a href="${pageContext.request.contextPath}/doctor/profile"><i class="fas fa-user-md"></i> Doctor Profile</a></li>
        </ul>
    </aside>

    <!-- Main Content -->
    <main class="staff-content">
        <section class="welcome-card">
            <h2><i class="fas fa-notes-medical"></i> Hồ sơ y tế & Lịch hẹn</h2>
            <p>Quản lý hồ sơ y tế và theo dõi tất cả lịch hẹn khám bệnh của các thú cưng</p>
    </section>

        <!-- Pending Appointments - Waiting for Doctor Confirmation -->
        <c:if test="${not empty pendingAppointments}">
            <div class="search-filter" style="background: #fff3e0; border-left: 4px solid #ff9800;">
                <h3 style="color: #e65100; margin-bottom: 15px;">
                    <i class="fas fa-clock"></i> Lịch hẹn đang chờ xác nhận
                </h3>
                <p style="margin-bottom: 15px; color: #666;">
                    Có <strong>${pendingAppointments.size()}</strong> lịch hẹn đang chờ bác sĩ xác nhận.
                    Vui lòng xem chi tiết và cập nhật trạng thái:
                </p>
                <div style="max-height: 300px; overflow-y: auto;">
                    <c:forEach var="appt" items="${pendingAppointments}" varStatus="status">
                        <div style="background: white; padding: 15px; border-radius: 8px; margin-bottom: 12px; border: 1px solid #ffe0b2; display: flex; justify-content: space-between; align-items: center;">
                            <div style="flex: 1;">
                                <div style="display: flex; align-items: center; margin-bottom: 8px;">
                                    <span style="background: #ff9800; color: white; padding: 2px 8px; border-radius: 12px; font-size: 12px; margin-right: 10px;">
                                        ${status.index + 1}
                                    </span>
                                    <strong style="color: #e65100; font-size: 16px;">${appt.petName}</strong>
                                    <span style="color: #666; margin-left: 8px;">(${appt.petType})</span>
                                </div>
                                <div style="color: #666; font-size: 14px;">
                                    <i class="fas fa-user"></i> Chủ: <strong>${appt.customerName}</strong> |
                                    <i class="fas fa-calendar"></i> <fmt:formatDate value="${appt.appointmentStart}" pattern="dd/MM/yyyy HH:mm"/> |
                                    <i class="fas fa-stethoscope"></i> ${appt.serviceNames}
                                </div>
                                <c:if test="${not empty appt.note}">
                                    <div style="color: #666; font-size: 13px; margin-top: 5px; font-style: italic;">
                                        <i class="fas fa-sticky-note"></i> "${appt.note}"
                                    </div>
                                </c:if>
                            </div>
                            <div style="margin-left: 15px;">
                                <a href="${pageContext.request.contextPath}/doctor/appointment-detail?id=${appt.bookingId}"
                                   class="btn-primary" style="padding: 10px 20px; font-size: 14px; text-decoration: none;">
                                    <i class="fas fa-eye"></i> Xem chi tiết
                                </a>
                            </div>
                        </div>
                    </c:forEach>
                </div>
            </div>
        </c:if>

        <!-- Upcoming Confirmed Appointments -->
        <c:if test="${not empty upcomingAppointments}">
            <div class="search-filter" style="background: #e8f5e8; border-left: 4px solid #4CAF50;">
                <h3 style="color: #2e7d32; margin-bottom: 15px;">
                    <i class="fas fa-calendar-check"></i> Lịch hẹn đã xác nhận sắp tới
                </h3>
                <p style="margin-bottom: 15px; color: #666;">
                    Có <strong>${upcomingAppointments.size()}</strong> lịch hẹn đã được xác nhận.
                    Chuẩn bị cho các buổi khám sắp tới:
                </p>
                <div style="max-height: 300px; overflow-y: auto;">
                    <c:forEach var="appt" items="${upcomingAppointments}" varStatus="status">
                        <div style="background: white; padding: 15px; border-radius: 8px; margin-bottom: 12px; border: 1px solid #c8e6c9; display: flex; justify-content: space-between; align-items: center;">
                            <div style="flex: 1;">
                                <div style="display: flex; align-items: center; margin-bottom: 8px;">
                                    <span style="background: #4CAF50; color: white; padding: 2px 8px; border-radius: 12px; font-size: 12px; margin-right: 10px;">
                                        ${status.index + 1}
                                    </span>
                                    <strong style="color: #2e7d32; font-size: 16px;">${appt.petName}</strong>
                                    <span style="color: #666; margin-left: 8px;">(${appt.petType})</span>
                                </div>
                                <div style="color: #666; font-size: 14px;">
                                    <i class="fas fa-user"></i> Chủ: <strong>${appt.customerName}</strong> |
                                    <i class="fas fa-calendar"></i> <fmt:formatDate value="${appt.appointmentStart}" pattern="dd/MM/yyyy HH:mm"/> |
                                    <i class="fas fa-stethoscope"></i> ${appt.serviceNames}
                                </div>
                                <c:if test="${not empty appt.note}">
                                    <div style="color: #666; font-size: 13px; margin-top: 5px; font-style: italic;">
                                        <i class="fas fa-sticky-note"></i> "${appt.note}"
                                    </div>
                                </c:if>
                            </div>
                            <div style="margin-left: 15px;">
                                <a href="${pageContext.request.contextPath}/doctor/appointment-detail?id=${appt.bookingId}"
                                   class="btn-primary" style="padding: 10px 20px; font-size: 14px; text-decoration: none; background: #4CAF50;">
                                    <i class="fas fa-eye"></i> Xem chi tiết
                                </a>
                            </div>
                        </div>
                    </c:forEach>
                </div>
            </div>
        </c:if>

        <!-- Completed Appointments - Create Medical Records -->
        <c:if test="${not empty completedAppointments}">
            <div class="search-filter" style="background: #fff3e0; border-left: 4px solid #ff9800;">
                <h3 style="color: #e65100; margin-bottom: 15px;">
                    <i class="fas fa-clipboard-check"></i> Lịch hẹn hoàn thành - Tạo hồ sơ y tế
                </h3>
                <p style="margin-bottom: 15px; color: #666;">
                    Có <strong>${completedAppointments.size()}</strong> lịch hẹn đã hoàn thành nhưng chưa có hồ sơ y tế.
                    Vui lòng tạo hồ sơ y tế để hoàn tất quá trình khám bệnh:
                </p>
                <div style="max-height: 300px; overflow-y: auto;">
                    <c:forEach var="appt" items="${completedAppointments}" varStatus="status">
                        <div style="background: white; padding: 15px; border-radius: 8px; margin-bottom: 12px; border: 1px solid #ffe0b2; display: flex; justify-content: space-between; align-items: center;">
                            <div style="flex: 1;">
                                <div style="display: flex; align-items: center; margin-bottom: 8px;">
                                    <span style="background: #ff9800; color: white; padding: 2px 8px; border-radius: 12px; font-size: 12px; margin-right: 10px;">
                                        ${status.index + 1}
                                    </span>
                                    <strong style="color: #e65100; font-size: 16px;">${appt.petName}</strong>
                                    <span style="color: #666; margin-left: 8px;">(${appt.petType})</span>
                                </div>
                                <div style="color: #666; font-size: 14px;">
                                    <i class="fas fa-user"></i> Chủ: <strong>${appt.customerName}</strong> |
                                    <i class="fas fa-calendar"></i> <fmt:formatDate value="${appt.appointmentStart}" pattern="dd/MM/yyyy HH:mm"/> |
                                    <i class="fas fa-stethoscope"></i> ${appt.serviceNames}
                                </div>
                                <c:if test="${not empty appt.note}">
                                    <div style="color: #666; font-size: 13px; margin-top: 5px; font-style: italic;">
                                        <i class="fas fa-sticky-note"></i> "${appt.note}"
                                    </div>
                                </c:if>
                            </div>
                            <div style="margin-left: 15px;">
                                <form action="${pageContext.request.contextPath}/doctor/medical-records" method="post" style="margin: 0;" onsubmit="return confirmCreateRecord('${appt.petName}')">
                                    <input type="hidden" name="action" value="create">
                                    <input type="hidden" name="bookingId" value="${appt.bookingId}">
                                    <button type="submit" class="btn-primary" style="padding: 10px 20px; font-size: 14px;">
                                        <i class="fas fa-plus"></i> Tạo hồ sơ y tế
                                    </button>
                                </form>
                            </div>
                        </div>
                    </c:forEach>
                </div>
                <div style="margin-top: 15px; padding: 10px; background: #fff8e1; border-radius: 5px; border: 1px solid #ffe082;">
                    <i class="fas fa-info-circle" style="color: #f57c00;"></i>
                    <strong style="color: #e65100;">Lưu ý:</strong> Việc tạo hồ sơ y tế sẽ giúp theo dõi sức khỏe thú cưng và hỗ trợ các lần khám sau này.
                </div>
            </div>
        </c:if>

        <!-- Search and Filter -->
        <div class="search-filter">
            <form method="get">
                <input type="text" name="search" placeholder="Tìm kiếm theo tên thú cưng hoặc chủ sở hữu..." 
                       class="search-input" value="${param.search}">
                <button type="submit" class="btn-primary">
                    <i class="fas fa-search"></i> Tìm kiếm
                </button>
                <a href="${pageContext.request.contextPath}/doctor/medical-records" class="btn-primary" style="text-decoration: none; display: inline-block;">
                    <i class="fas fa-refresh"></i> Làm mới
                </a>
            </form>
        </div>

        <!-- Appointments and Medical Records Summary -->
        <div class="search-filter" style="background: #f8f9fa; border-left: 4px solid #6c757d;">
            <h3 style="color: #495057; margin-bottom: 15px;">
                <i class="fas fa-chart-line"></i> Tổng quan lịch hẹn và hồ sơ y tế
            </h3>
            <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(150px, 1fr)); gap: 15px;">
                <div style="background: #fff3e0; padding: 15px; border-radius: 8px; text-align: center;">
                    <i class="fas fa-clock" style="font-size: 24px; color: #ff9800;"></i>
                    <div style="font-size: 20px; font-weight: bold; color: #e65100;">${pendingAppointments.size()}</div>
                    <div style="font-size: 12px; color: #666;">Chờ xác nhận</div>
                </div>
                <div style="background: #e8f5e8; padding: 15px; border-radius: 8px; text-align: center;">
                    <i class="fas fa-calendar-check" style="font-size: 24px; color: #4CAF50;"></i>
                    <div style="font-size: 20px; font-weight: bold; color: #2e7d32;">${upcomingAppointments.size()}</div>
                    <div style="font-size: 12px; color: #666;">Đã xác nhận</div>
                </div>
                <div style="background: #e3f2fd; padding: 15px; border-radius: 8px; text-align: center;">
                    <i class="fas fa-check-circle" style="font-size: 24px; color: #2196F3;"></i>
                    <div style="font-size: 20px; font-weight: bold; color: #1565c0;">${completedAppointments.size()}</div>
                    <div style="font-size: 12px; color: #666;">Hoàn thành</div>
                </div>
                <div style="background: #f3e5f5; padding: 15px; border-radius: 8px; text-align: center;">
                    <i class="fas fa-notes-medical" style="font-size: 24px; color: #9C27B0;"></i>
                    <div style="font-size: 20px; font-weight: bold; color: #7b1fa2;">${medicalRecords.size()}</div>
                    <div style="font-size: 12px; color: #666;">Hồ sơ y tế</div>
                </div>
            </div>
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
                                 <th>Chẩn đoán</th>
                                 <th>Điều trị</th>
                                 <th>Tái khám</th>
                                 <th>Hành động</th>
                 </tr>
             </thead>
             <tbody>
                 <c:forEach var="record" items="${medicalRecords}">
                                 <tr>
                                     <td>
                                         <fmt:formatDate value="${record.examinationDate}" pattern="dd/MM/yyyy HH:mm" />
                                     </td>
                                     <td>
                                         <strong>${record.petName}</strong>
                                     </td>
                                     <td>
                                         ${record.customerName}
                                     </td>
                                     <td>${record.petSpecies}</td>
                                     <td>
                                         <c:choose>
                                             <c:when test="${not empty record.diagnosis}">
                                                 ${record.diagnosis.length() > 50 ? record.diagnosis.substring(0, 50).concat('...') : record.diagnosis}
                                             </c:when>
                                             <c:otherwise><em>Chưa có</em></c:otherwise>
                                         </c:choose>
                                     </td>
                                     <td>
                                         <c:choose>
                                             <c:when test="${not empty record.treatment}">
                                                 ${record.treatment.length() > 50 ? record.treatment.substring(0, 50).concat('...') : record.treatment}
                                             </c:when>
                                             <c:otherwise><em>Chưa có</em></c:otherwise>
                                         </c:choose>
                                     </td>
                                     <td>
                                         <c:choose>
                                             <c:when test="${not empty record.followUpDate}">
                                                 <fmt:formatDate value="${record.followUpDate}" pattern="dd/MM/yyyy" />
                                             </c:when>
                                             <c:otherwise>-</c:otherwise>
                                         </c:choose>
                                     </td>
                                     <td>
                                         <a href="${pageContext.request.contextPath}/doctor/medical-records?action=view&id=${record.recordId}"
                                            class="btn-small" style="background: #4CAF50; color: white; text-decoration: none; padding: 8px 12px; border-radius: 5px; display: inline-block; margin-right: 5px;">
                                             <i class="fas fa-eye"></i> Xem
                                         </a>
                                         <a href="${pageContext.request.contextPath}/doctor/medical-records?action=view&id=${record.recordId}"
                                            class="btn-small" style="background: #2196F3; color: white; text-decoration: none; padding: 8px 12px; border-radius: 5px; display: inline-block;">
                                             <i class="fas fa-edit"></i> Sửa
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
                    <strong>Có tái khám:</strong>
                    <c:set var="followUpCount" value="0" />
                    <c:forEach var="record" items="${medicalRecords}">
                        <c:if test="${not empty record.followUpDate}">
                            <c:set var="followUpCount" value="${followUpCount + 1}" />
                        </c:if>
                    </c:forEach>
                    ${followUpCount}
                </div>
                <div style="background: #fff3e0; padding: 15px; border-radius: 5px; flex: 1;">
                    <strong>Có đơn thuốc:</strong>
                    <c:set var="prescriptionCount" value="0" />
                    <c:forEach var="record" items="${medicalRecords}">
                        <c:if test="${not empty record.prescription}">
                            <c:set var="prescriptionCount" value="${prescriptionCount + 1}" />
                        </c:if>
                    </c:forEach>
                    ${prescriptionCount}
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

// Confirm medical record creation
function confirmCreateRecord(petName) {
    return confirm('Bạn có chắc chắn muốn tạo hồ sơ y tế cho thú cưng "' + petName + '"?\n\nHồ sơ y tế sẽ được tạo với thông tin từ lịch hẹn và bạn có thể chỉnh sửa chi tiết sau.');
}

// Show success/error messages
window.onload = function() {
    const urlParams = new URLSearchParams(window.location.search);
    if (urlParams.get('success') === 'created') {
        alert('✅ Tạo hồ sơ y tế thành công!\n\nBạn có thể chỉnh sửa chi tiết hồ sơ bằng cách nhấn nút "Sửa" trong bảng bên dưới.');
        window.history.replaceState({}, document.title, window.location.pathname);
    } else if (urlParams.get('success') === 'updated') {
        alert('✅ Cập nhật hồ sơ y tế thành công!');
        window.history.replaceState({}, document.title, window.location.pathname);
    } else if (urlParams.get('error')) {
        const error = decodeURIComponent(urlParams.get('error'));
        alert('❌ Có lỗi xảy ra: ' + error);
        window.history.replaceState({}, document.title, window.location.pathname);
    }
}
</script>

</body>
</html>
