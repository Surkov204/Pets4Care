<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ page import="dao.DoctorDAO" %>
<%@ page import="dao.BookingDAO" %>
<%@ page import="dao.PetDAO" %>
<%@ page import="model.Doctor" %>
<%@ page import="model.Booking" %>
<%@ page import="model.Pet" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%
    // Kiểm tra đăng nhập
    Doctor doctor = (Doctor) session.getAttribute("doctor");
    if (doctor == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    
    // Lấy booking ID từ parameter
    String bookingIdStr = request.getParameter("id");
    if (bookingIdStr == null || bookingIdStr.trim().isEmpty()) {
        response.sendRedirect(request.getContextPath() + "/doctor/appointments.jsp?error=missing_id");
        return;
    }
    
    try {
        int bookingId = Integer.parseInt(bookingIdStr);
        BookingDAO bookingDAO = new BookingDAO();
        Booking booking = bookingDAO.getBookingById(bookingId);
        
        // Kiểm tra booking có tồn tại và thuộc về doctor này không
        if (booking == null) {
            response.sendRedirect(request.getContextPath() + "/doctor/appointments.jsp?error=booking_not_found");
            return;
        }
        
        if (booking.getDoctorId() != doctor.getDoctorId()) {
            response.sendRedirect(request.getContextPath() + "/doctor/appointments.jsp?error=unauthorized");
            return;
        }
        
        // Lấy thông tin thú cưng chi tiết
        Pet pet = null;
        if (booking.getPetId() > 0) {
            PetDAO petDAO = new PetDAO();
            pet = petDAO.getPetById(booking.getPetId());
        }
        
        request.setAttribute("booking", booking);
        request.setAttribute("pet", pet);
        
        // Lấy thông báo success/error
        String successMessage = request.getParameter("success");
        String errorMessage = request.getParameter("error");
        request.setAttribute("successMessage", successMessage);
        request.setAttribute("errorMessage", errorMessage);
        
    } catch (NumberFormatException e) {
        response.sendRedirect(request.getContextPath() + "/doctor/appointments.jsp?error=invalid_id");
        return;
    }
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Chi tiết lịch hẹn | Pet4Care</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/staff.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <style>
        .detail-card {
            background: white;
            border-radius: 10px;
            padding: 25px;
            margin-bottom: 20px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        
        .detail-card h3 {
            color: #333;
            margin-bottom: 20px;
            padding-bottom: 10px;
            border-bottom: 2px solid #4CAF50;
        }
        
        .info-row {
            display: flex;
            justify-content: space-between;
            padding: 10px 0;
            border-bottom: 1px solid #eee;
        }
        
        .info-label {
            font-weight: 600;
            color: #666;
        }
        
        .info-value {
            color: #333;
            font-weight: 500;
        }
        
        .pet-info-box {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border-radius: 15px;
            padding: 20px;
            margin-bottom: 20px;
        }
        
        .pet-info-box h4 {
            margin-bottom: 15px;
            color: white;
        }
        
        .status-badge {
            padding: 6px 12px;
            border-radius: 20px;
            font-size: 14px;
            font-weight: bold;
        }
        
        .status-pending { background: #fff3e0; color: #f57c00; }
        .status-confirmed { background: #e8f5e8; color: #2e7d32; }
        .status-completed { background: #e3f2fd; color: #1565c0; }
        .status-cancelled { background: #ffebee; color: #c62828; }
        
        .medical-form {
            background: #f8f9fa;
            padding: 20px;
            border-radius: 10px;
            margin-top: 20px;
        }
        
        .form-group {
            margin-bottom: 20px;
        }
        
        .form-group label {
            display: block;
            font-weight: 600;
            margin-bottom: 8px;
            color: #333;
        }
        
        .form-group textarea {
            width: 100%;
            padding: 12px;
            border: 2px solid #ddd;
            border-radius: 5px;
            font-size: 14px;
            font-family: inherit;
            resize: vertical;
        }
        
        .form-group textarea:focus {
            outline: none;
            border-color: #4CAF50;
        }
        
        .btn-action {
            background: #4CAF50;
            color: white;
            padding: 10px 20px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            font-size: 14px;
            font-weight: 600;
            text-decoration: none;
            display: inline-block;
            transition: background 0.3s;
        }
        
        .btn-action:hover {
            background: #45a049;
        }
        
        .btn-secondary {
            background: #6c757d;
        }
        
        .btn-secondary:hover {
            background: #5a6268;
        }
        
        .alert {
            padding: 15px;
            border-radius: 5px;
            margin-bottom: 20px;
        }
        
        .alert-success {
            background: #d4edda;
            color: #155724;
            border: 1px solid #c3e6cb;
        }
        
        .alert-error {
            background: #f8d7da;
            color: #721c24;
            border: 1px solid #f5c6cb;
        }
        
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
            <li><a href="medical-record.jsp"><i class="fas fa-notes-medical"></i> Medical Records</a></li>
            <li><a href="work-schedule.jsp"><i class="fas fa-calendar-alt"></i> Work Schedule</a></li>
            <li><a href="appointments.jsp"><i class="fas fa-stethoscope"></i> Appointments</a></li>
            <li><a href="doctor-profile.jsp"><i class="fas fa-user-md"></i> Doctor Profile</a></li>
        </ul>
    </aside>

    <!-- Main Content -->
    <main class="staff-content">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h1><i class="fas fa-calendar-check"></i> Chi tiết lịch hẹn #${booking.bookingId}</h1>
            <a href="appointments.jsp" class="btn-action">
                <i class="fas fa-arrow-left"></i> Quay lại
            </a>
        </div>

        <c:if test="${not empty successMessage}">
            <div class="alert alert-success">
                <i class="fas fa-check-circle"></i> 
                <c:choose>
                    <c:when test="${successMessage == 'updated'}">Cập nhật thông tin y tế thành công!</c:when>
                    <c:otherwise>Thao tác thành công!</c:otherwise>
                </c:choose>
            </div>
        </c:if>

        <c:if test="${not empty errorMessage}">
            <div class="alert alert-error">
                <i class="fas fa-exclamation-circle"></i> 
                <c:choose>
                    <c:when test="${errorMessage == 'update_failed'}">Cập nhật thất bại. Vui lòng thử lại.</c:when>
                    <c:otherwise>Có lỗi xảy ra.</c:otherwise>
                </c:choose>
            </div>
        </c:if>

        <c:if test="${not empty booking}">
            <!-- Thông tin lịch hẹn -->
            <div class="detail-card">
                <h3><i class="fas fa-calendar"></i> Thông tin lịch hẹn</h3>
                <div class="info-row">
                    <span class="info-label">Trạng thái:</span>
                    <span class="status-badge status-${booking.status}">${booking.status}</span>
                </div>
                <div class="info-row">
                    <span class="info-label">Ngày giờ bắt đầu:</span>
                    <span class="info-value">
                        <c:choose>
                            <c:when test="${not empty booking.appointmentStart}">
                                ${booking.appointmentStart}
                            </c:when>
                            <c:otherwise>Chưa xác định</c:otherwise>
                        </c:choose>
                    </span>
                </div>
                <div class="info-row">
                    <span class="info-label">Ngày giờ kết thúc:</span>
                    <span class="info-value">
                        <c:choose>
                            <c:when test="${not empty booking.appointmentEnd}">
                                ${booking.appointmentEnd}
                            </c:when>
                            <c:otherwise>Chưa xác định</c:otherwise>
                        </c:choose>
                    </span>
                </div>
                <div class="info-row">
                    <span class="info-label">Dịch vụ:</span>
                    <span class="info-value">
                        <c:choose>
                            <c:when test="${not empty booking.serviceNames}">${booking.serviceNames}</c:when>
                            <c:otherwise>—</c:otherwise>
                        </c:choose>
                    </span>
                </div>
            </div>

            <!-- Thông tin khách hàng -->
            <div class="detail-card">
                <h3><i class="fas fa-user"></i> Thông tin khách hàng</h3>
                <div class="info-row">
                    <span class="info-label">Tên khách hàng:</span>
                    <span class="info-value">${booking.customerName}</span>
                </div>
                <div class="info-row">
                    <span class="info-label">Số điện thoại:</span>
                    <span class="info-value">${booking.customerPhone}</span>
                </div>
                <c:if test="${not empty booking.customerEmail}">
                <div class="info-row">
                    <span class="info-label">Email:</span>
                    <span class="info-value">${booking.customerEmail}</span>
                </div>
                </c:if>
            </div>

            <!-- Thông tin thú cưng -->
            <div class="detail-card">
                <c:if test="${not empty pet}">
                    <div class="pet-info-box">
                        <h4><i class="fas fa-paw"></i> Thông tin thú cưng</h4>
                        <div class="info-row" style="border-bottom: 1px solid rgba(255,255,255,0.3);">
                            <span class="info-label" style="color: rgba(255,255,255,0.9);">Tên thú cưng:</span>
                            <span class="info-value" style="color: white; font-weight: 600;">${pet.petName}</span>
                        </div>
                        <div class="info-row" style="border-bottom: 1px solid rgba(255,255,255,0.3);">
                            <span class="info-label" style="color: rgba(255,255,255,0.9);">Loài:</span>
                            <span class="info-value" style="color: white;">${pet.species}</span>
                        </div>
                        <c:if test="${not empty pet.breed}">
                        <div class="info-row" style="border-bottom: 1px solid rgba(255,255,255,0.3);">
                            <span class="info-label" style="color: rgba(255,255,255,0.9);">Giống:</span>
                            <span class="info-value" style="color: white;">${pet.breed}</span>
                        </div>
                        </c:if>
                        <div class="info-row" style="border-bottom: 1px solid rgba(255,255,255,0.3);">
                            <span class="info-label" style="color: rgba(255,255,255,0.9);">Tuổi:</span>
                            <span class="info-value" style="color: white;">${pet.age} tuổi</span>
                        </div>
                        <div class="info-row" style="border-bottom: 1px solid rgba(255,255,255,0.3);">
                            <span class="info-label" style="color: rgba(255,255,255,0.9);">Giới tính:</span>
                            <span class="info-value" style="color: white;">${pet.genderDisplayName}</span>
                        </div>
                        <c:if test="${not empty pet.healthStatus}">
                        <div class="info-row" style="border-bottom: 1px solid rgba(255,255,255,0.3);">
                            <span class="info-label" style="color: rgba(255,255,255,0.9);">Tình trạng sức khỏe:</span>
                            <span class="info-value" style="color: white; font-weight: 600;">${pet.healthStatus}</span>
                        </div>
                        </c:if>
                        <c:if test="${not empty pet.description}">
                        <div class="info-row">
                            <span class="info-label" style="color: rgba(255,255,255,0.9);">Mô tả:</span>
                            <span class="info-value" style="color: white;">${pet.description}</span>
                        </div>
                        </c:if>
                    </div>
                </c:if>
                <c:if test="${empty pet}">
                    <div class="alert alert-error">
                        <i class="fas fa-exclamation-triangle"></i> Không tìm thấy thông tin thú cưng
                    </div>
                </c:if>
            </div>

            <!-- Cập nhật thông tin y tế -->
            <div class="detail-card">
                <h3><i class="fas fa-notes-medical"></i> Cập nhật tiến độ bệnh trạng</h3>
                
                <c:if test="${not empty booking.note}">
                    <div class="alert" style="background: #e3f2fd; color: #1565c0; margin-bottom: 20px;">
                        <strong>Ghi chú hiện tại:</strong><br>
                        ${booking.note}
                    </div>
                </c:if>

                <form method="POST" action="${pageContext.request.contextPath}/update-medical-info" class="medical-form">
                    <input type="hidden" name="bookingId" value="${booking.bookingId}">
                    
                    <div class="form-group">
                        <label for="medicalNote">
                            <i class="fas fa-stethoscope"></i> Chẩn đoán / Ghi chú y tế:
                        </label>
                        <textarea id="medicalNote" name="medicalNote" rows="6" 
                                  placeholder="Nhập chẩn đoán, kế hoạch điều trị, tiến độ bệnh trạng hoặc các ghi chú y tế khác...">${booking.note}</textarea>
                    </div>
                    
                    <div style="display: flex; gap: 10px;">
                        <button type="submit" class="btn-action">
                            <i class="fas fa-save"></i> Lưu thông tin y tế
                        </button>
                        <c:if test="${booking.status == 'pending'}">
                            <a href="${pageContext.request.contextPath}/update-appointment-status?bookingId=${booking.bookingId}&status=confirmed" 
                               class="btn-action">
                                <i class="fas fa-check"></i> Xác nhận lịch hẹn
                            </a>
                        </c:if>
                        <c:if test="${booking.status == 'confirmed'}">
                            <a href="${pageContext.request.contextPath}/update-appointment-status?bookingId=${booking.bookingId}&status=completed" 
                               class="btn-action">
                                <i class="fas fa-check-circle"></i> Đánh dấu hoàn thành
                            </a>
                        </c:if>
                    </div>
                </form>
            </div>
        </c:if>
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
