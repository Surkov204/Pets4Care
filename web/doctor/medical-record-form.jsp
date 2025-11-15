<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ page import="model.Doctor" %>
<%
    Doctor doctor = (Doctor) session.getAttribute("doctor");
    if (doctor == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    if (request.getAttribute("booking") == null) {
        response.sendRedirect(request.getContextPath() + "/doctor/medical-records");
        return;
    }
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>🐾 ${mode == 'create' ? 'Tạo' : 'Cập nhật'} Hồ sơ Y tế | Pet4Care</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/staff.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <style>
        .form-container {
            background: white;
            border-radius: 10px;
            padding: 30px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            max-width: 800px;
            margin: 20px auto;
        }

        .form-group {
            margin-bottom: 20px;
        }

        .form-group label {
            display: block;
            margin-bottom: 5px;
            font-weight: 600;
            color: #333;
        }

        .form-group input, .form-group textarea, .form-group select {
            width: 100%;
            padding: 10px;
            border: 2px solid #ddd;
            border-radius: 5px;
            font-size: 14px;
            transition: border-color 0.3s;
        }

        .form-group input:focus, .form-group textarea:focus, .form-group select:focus {
            outline: none;
            border-color: #4CAF50;
        }

        .form-group textarea {
            resize: vertical;
            min-height: 80px;
        }

        .form-row {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 20px;
        }

        .form-row .form-group {
            margin-bottom: 0;
        }

        .btn-submit {
            background: #4CAF50;
            color: white;
            padding: 12px 30px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            font-size: 16px;
            font-weight: 600;
            transition: background-color 0.3s;
        }

        .btn-submit:hover {
            background: #45a049;
        }

        .btn-cancel {
            background: #f44336;
            color: white;
            padding: 12px 30px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            font-size: 16px;
            font-weight: 600;
            margin-left: 10px;
            text-decoration: none;
            display: inline-block;
            transition: background-color 0.3s;
        }

        .btn-cancel:hover {
            background: #d32f2f;
        }

        .booking-info {
            background: #f8f9fa;
            padding: 20px;
            border-radius: 8px;
            margin-bottom: 30px;
            border-left: 4px solid #4CAF50;
        }

        .booking-info h3 {
            margin-top: 0;
            color: #2e7d32;
        }

        .error-message {
            background: #ffebee;
            color: #c62828;
            padding: 10px;
            border-radius: 5px;
            margin-bottom: 20px;
            border-left: 4px solid #f44336;
        }

        .success-message {
            background: #e8f5e8;
            color: #2e7d32;
            padding: 10px;
            border-radius: 5px;
            margin-bottom: 20px;
            border-left: 4px solid #4CAF50;
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
            <li><a href="${pageContext.request.contextPath}/doctor/work-schedule"><i class="fas fa-calendar-alt"></i> Work Schedule</a></li>
            <li><a href="${pageContext.request.contextPath}/doctor/appointments"><i class="fas fa-stethoscope"></i> Appointments</a></li>
            <li><a href="${pageContext.request.contextPath}/doctor/profile"><i class="fas fa-user-md"></i> Doctor Profile</a></li>
        </ul>
    </aside>

    <!-- Main Content -->
    <main class="staff-content">
        <section class="welcome-card">
            <h2><i class="fas fa-plus-circle"></i> ${mode == 'create' ? 'Tạo' : 'Cập nhật'} Hồ sơ Y tế</h2>
            <p>${mode == 'create' ? 'Điền thông tin chi tiết cho hồ sơ y tế mới' : 'Cập nhật thông tin hồ sơ y tế'}</p>
        </section>

        <!-- Error/Success Messages -->
        <c:if test="${not empty param.error}">
            <div class="error-message">
                <i class="fas fa-exclamation-triangle"></i>
                <c:choose>
                    <c:when test="${param.error == 'unauthorized'}">Bạn không có quyền truy cập lịch hẹn này.</c:when>
                    <c:when test="${param.error == 'exists'}">Hồ sơ y tế đã tồn tại cho lịch hẹn này.</c:when>
                    <c:when test="${param.error == 'missing_booking'}">Thiếu thông tin lịch hẹn.</c:when>
                    <c:otherwise>Có lỗi xảy ra. Vui lòng thử lại.</c:otherwise>
                </c:choose>
            </div>
        </c:if>

        <c:if test="${not empty param.success}">
            <div class="success-message">
                <i class="fas fa-check-circle"></i>
                Hồ sơ y tế đã được ${mode == 'create' ? 'tạo' : 'cập nhật'} thành công!
            </div>
        </c:if>

        <!-- Booking Information -->
        <div class="booking-info">
            <h3><i class="fas fa-calendar-check"></i> Thông tin lịch hẹn</h3>
            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 15px; margin-top: 15px;">
                <div>
                    <strong>Thú cưng:</strong> ${booking.petName} (${booking.petType})
                </div>
                <div>
                    <strong>Chủ sở hữu:</strong> ${booking.customerName}
                </div>
                <div>
                    <strong>Thời gian:</strong> <fmt:formatDate value="${booking.appointmentStart}" pattern="dd/MM/yyyy HH:mm"/>
                </div>
                <div>
                    <strong>Dịch vụ:</strong> ${booking.serviceNames}
                </div>
            </div>
            <c:if test="${not empty booking.note}">
                <div style="margin-top: 10px;">
                    <strong>Ghi chú:</strong> ${booking.note}
                </div>
            </c:if>
        </div>

        <!-- Medical Record Form -->
        <div class="form-container">
            <form action="${pageContext.request.contextPath}/doctor/medical-records" method="post">
                <input type="hidden" name="action" value="${mode}">
                <input type="hidden" name="bookingId" value="${booking.bookingId}">

                <div class="form-row">
                    <div class="form-group">
                        <label for="weight">Cân nặng (kg)</label>
                        <input type="number" step="0.1" id="weight" name="weight" placeholder="Ví dụ: 5.5" value="${mode == 'edit' ? record.weight : ''}">
                    </div>
                    <div class="form-group">
                        <label for="temperature">Nhiệt độ (°C)</label>
                        <input type="number" step="0.1" id="temperature" name="temperature" placeholder="Ví dụ: 38.5" value="${mode == 'edit' ? record.temperature : ''}">
                    </div>
                </div>

                <div class="form-row">
                    <div class="form-group">
                        <label for="heartRate">Nhịp tim (lần/phút)</label>
                        <input type="number" id="heartRate" name="heartRate" placeholder="Ví dụ: 120" value="${mode == 'edit' ? record.heartRate : ''}">
                    </div>
                    <div class="form-group">
                        <label for="bloodPressure">Huyết áp</label>
                        <input type="text" id="bloodPressure" name="bloodPressure" placeholder="Ví dụ: 120/80" value="${mode == 'edit' ? record.bloodPressure : ''}">
                    </div>
                </div>

                <div class="form-group">
                    <label for="symptoms">Triệu chứng</label>
                    <textarea id="symptoms" name="symptoms" placeholder="Mô tả các triệu chứng của thú cưng...">${mode == 'edit' ? record.symptoms : ''}</textarea>
                </div>

                <div class="form-group">
                    <label for="diagnosis">Chẩn đoán</label>
                    <textarea id="diagnosis" name="diagnosis" placeholder="Kết quả chẩn đoán...">${mode == 'edit' ? record.diagnosis : ''}</textarea>
                </div>

                <div class="form-group">
                    <label for="treatment">Phương pháp điều trị</label>
                    <textarea id="treatment" name="treatment" placeholder="Mô tả phương pháp điều trị...">${mode == 'edit' ? record.treatment : ''}</textarea>
                </div>

                <div class="form-group">
                    <label for="prescription">Đơn thuốc</label>
                    <textarea id="prescription" name="prescription" placeholder="Liệt kê các loại thuốc và liều lượng...">${mode == 'edit' ? record.prescription : ''}</textarea>
                </div>

                <div class="form-row">
                    <div class="form-group">
                        <label for="followUpDate">Ngày tái khám</label>
                        <input type="date" id="followUpDate" name="followUpDate" value="${mode == 'edit' && record.followUpDate != null ? record.followUpDate : ''}">
                    </div>
                    <div class="form-group">
                        <label for="followUpNotes">Ghi chú tái khám</label>
                        <input type="text" id="followUpNotes" name="followUpNotes" placeholder="Lưu ý cho lần khám sau..." value="${mode == 'edit' ? record.followUpNotes : ''}">
                    </div>
                </div>

                <div class="form-group">
                    <label for="notes">Ghi chú bổ sung</label>
                    <textarea id="notes" name="notes" placeholder="Các ghi chú khác...">${mode == 'edit' ? record.notes : ''}</textarea>
                </div>

                <div style="text-align: center; margin-top: 30px;">
                    <button type="submit" class="btn-submit">
                        <i class="fas fa-save"></i> ${mode == 'create' ? 'Tạo' : 'Cập nhật'} Hồ sơ Y tế
                    </button>
                    <a href="${pageContext.request.contextPath}/doctor/medical-records" class="btn-cancel">
                        <i class="fas fa-times"></i> Hủy
                    </a>
                </div>
            </form>
        </div>
    </main>
</div>

<script>
function toggleDropdown() {
    const dropdown = document.getElementById('dropdownMenu');
    dropdown.classList.toggle('show');
}

// Close dropdown when clicking outside
window.onclick = function(event) {
    if (!event.target.matches('.avatar') && !event.target.matches('.avatar *')) {
        const dropdowns = document.getElementsByClassName('dropdown-menu');
        for (let i = 0; i < dropdowns.length; i++) {
            const openDropdown = dropdowns[i];
            if (openDropdown.classList.contains('show')) {
                openDropdown.classList.remove('show');
            }
        }
    }
}
</script>

</body>
</html>