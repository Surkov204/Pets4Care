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
    
    if (request.getAttribute("record") == null) {
        response.sendRedirect(request.getContextPath() + "/doctor/medical-records");
        return;
    }
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>🐾 Chi tiết Hồ sơ Y tế | Pet4Care</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/staff.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <style>
        .detail-container {
            background: white;
            border-radius: 10px;
            padding: 30px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            max-width: 1000px;
            margin: 20px auto;
        }

        .detail-section {
            margin-bottom: 30px;
            padding-bottom: 20px;
            border-bottom: 1px solid #e0e0e0;
        }

        .detail-section:last-child {
            border-bottom: none;
        }

        .detail-section h3 {
            color: #2e7d32;
            margin-bottom: 15px;
            padding-bottom: 10px;
            border-bottom: 2px solid #4CAF50;
        }

        .detail-row {
            display: grid;
            grid-template-columns: 200px 1fr;
            gap: 15px;
            margin-bottom: 12px;
            align-items: start;
        }

        .detail-label {
            font-weight: 600;
            color: #555;
        }

        .detail-value {
            color: #333;
        }

        .detail-value.empty {
            color: #999;
            font-style: italic;
        }

        .btn-group {
            display: flex;
            gap: 10px;
            margin-top: 30px;
            justify-content: center;
        }

        .btn {
            padding: 12px 30px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            font-size: 16px;
            font-weight: 600;
            text-decoration: none;
            display: inline-block;
            transition: background-color 0.3s;
        }

        .btn-primary {
            background: #4CAF50;
            color: white;
        }

        .btn-primary:hover {
            background: #45a049;
        }

        .btn-warning {
            background: #ff9800;
            color: white;
        }

        .btn-warning:hover {
            background: #f57c00;
        }

        .btn-secondary {
            background: #6c757d;
            color: white;
        }

        .btn-secondary:hover {
            background: #5a6268;
        }

        .info-box {
            background: #f8f9fa;
            padding: 15px;
            border-radius: 8px;
            margin-bottom: 20px;
            border-left: 4px solid #4CAF50;
        }

        .info-box h4 {
            margin-top: 0;
            color: #2e7d32;
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
    <aside class="staff-sidebar">
        <ul>
            <li><a href="${pageContext.request.contextPath}/doctor/dashboard"><i class="fas fa-home"></i> Dashboard</a></li>
            <li><a href="${pageContext.request.contextPath}/doctor/medical-records" class="active"><i class="fas fa-notes-medical"></i> Medical Records</a></li>
            <li><a href="${pageContext.request.contextPath}/doctor/work-schedule"><i class="fas fa-calendar-alt"></i> Work Schedule</a></li>
            <li><a href="${pageContext.request.contextPath}/doctor/appointments"><i class="fas fa-stethoscope"></i> Appointments</a></li>
            <li><a href="${pageContext.request.contextPath}/doctor/profile"><i class="fas fa-user-md"></i> Doctor Profile</a></li>
        </ul>
    </aside>

    <main class="staff-content">
        <section class="welcome-card">
            <h2><i class="fas fa-file-medical"></i> Chi tiết Hồ sơ Y tế</h2>
            <p>Thông tin chi tiết về hồ sơ khám bệnh</p>
        </section>

        <div class="detail-container">
            <!-- Thông tin cơ bản -->
            <div class="info-box">
                <h4><i class="fas fa-info-circle"></i> Thông tin cơ bản</h4>
                <div class="detail-row">
                    <span class="detail-label">Thú cưng:</span>
                    <span class="detail-value">${record.petName} <c:if test="${not empty record.petSpecies}">(${record.petSpecies})</c:if></span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Chủ sở hữu:</span>
                    <span class="detail-value">${record.customerName}</span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Bác sĩ:</span>
                    <span class="detail-value">${record.doctorName}</span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Ngày khám:</span>
                    <span class="detail-value"><fmt:formatDate value="${record.examinationDate}" pattern="dd/MM/yyyy HH:mm" /></span>
                </div>
                <c:if test="${not empty record.appointmentStart}">
                    <div class="detail-row">
                        <span class="detail-label">Thời gian hẹn:</span>
                        <span class="detail-value">
                            <fmt:formatDate value="${record.appointmentStart}" pattern="dd/MM/yyyy HH:mm" />
                            <c:if test="${not empty record.appointmentEnd}">
                                - <fmt:formatDate value="${record.appointmentEnd}" pattern="HH:mm" />
                            </c:if>
                        </span>
                    </div>
                </c:if>
            </div>

            <!-- Thông tin sức khỏe -->
            <div class="detail-section">
                <h3><i class="fas fa-heartbeat"></i> Thông tin sức khỏe</h3>
                <div class="detail-row">
                    <span class="detail-label">Cân nặng:</span>
                    <span class="detail-value <c:if test="${empty record.weight}">empty</c:if>">
                        <c:choose>
                            <c:when test="${not empty record.weight}">${record.weight} kg</c:when>
                            <c:otherwise>Chưa có thông tin</c:otherwise>
                        </c:choose>
                    </span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Nhiệt độ:</span>
                    <span class="detail-value <c:if test="${empty record.temperature}">empty</c:if>">
                        <c:choose>
                            <c:when test="${not empty record.temperature}">${record.temperature} °C</c:when>
                            <c:otherwise>Chưa có thông tin</c:otherwise>
                        </c:choose>
                    </span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Nhịp tim:</span>
                    <span class="detail-value <c:if test="${empty record.heartRate}">empty</c:if>">
                        <c:choose>
                            <c:when test="${not empty record.heartRate}">${record.heartRate} lần/phút</c:when>
                            <c:otherwise>Chưa có thông tin</c:otherwise>
                        </c:choose>
                    </span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Huyết áp:</span>
                    <span class="detail-value <c:if test="${empty record.bloodPressure}">empty</c:if>">
                        <c:choose>
                            <c:when test="${not empty record.bloodPressure}">${record.bloodPressure}</c:when>
                            <c:otherwise>Chưa có thông tin</c:otherwise>
                        </c:choose>
                    </span>
                </div>
            </div>

            <!-- Triệu chứng -->
            <div class="detail-section">
                <h3><i class="fas fa-exclamation-triangle"></i> Triệu chứng</h3>
                <div class="detail-value <c:if test="${empty record.symptoms}">empty</c:if>" style="white-space: pre-wrap;">
                    <c:choose>
                        <c:when test="${not empty record.symptoms}">${record.symptoms}</c:when>
                        <c:otherwise>Chưa có thông tin</c:otherwise>
                    </c:choose>
                </div>
            </div>

            <!-- Chẩn đoán -->
            <div class="detail-section">
                <h3><i class="fas fa-stethoscope"></i> Chẩn đoán</h3>
                <div class="detail-value <c:if test="${empty record.diagnosis}">empty</c:if>" style="white-space: pre-wrap;">
                    <c:choose>
                        <c:when test="${not empty record.diagnosis}">${record.diagnosis}</c:when>
                        <c:otherwise>Chưa có thông tin</c:otherwise>
                    </c:choose>
                </div>
            </div>

            <!-- Phương pháp điều trị -->
            <div class="detail-section">
                <h3><i class="fas fa-pills"></i> Phương pháp điều trị</h3>
                <div class="detail-value <c:if test="${empty record.treatment}">empty</c:if>" style="white-space: pre-wrap;">
                    <c:choose>
                        <c:when test="${not empty record.treatment}">${record.treatment}</c:when>
                        <c:otherwise>Chưa có thông tin</c:otherwise>
                    </c:choose>
                </div>
            </div>

            <!-- Đơn thuốc -->
            <div class="detail-section">
                <h3><i class="fas fa-prescription-bottle"></i> Đơn thuốc</h3>
                <div class="detail-value <c:if test="${empty record.prescription}">empty</c:if>" style="white-space: pre-wrap;">
                    <c:choose>
                        <c:when test="${not empty record.prescription}">${record.prescription}</c:when>
                        <c:otherwise>Chưa có thông tin</c:otherwise>
                    </c:choose>
                </div>
            </div>

            <!-- Tái khám -->
            <c:if test="${not empty record.followUpDate || not empty record.followUpNotes}">
                <div class="detail-section">
                    <h3><i class="fas fa-calendar-check"></i> Thông tin tái khám</h3>
                    <c:if test="${not empty record.followUpDate}">
                        <div class="detail-row">
                            <span class="detail-label">Ngày tái khám:</span>
                            <span class="detail-value"><fmt:formatDate value="${record.followUpDate}" pattern="dd/MM/yyyy" /></span>
                        </div>
                    </c:if>
                    <c:if test="${not empty record.followUpNotes}">
                        <div class="detail-row">
                            <span class="detail-label">Ghi chú:</span>
                            <span class="detail-value" style="white-space: pre-wrap;">${record.followUpNotes}</span>
                        </div>
                    </c:if>
                </div>
            </c:if>

            <!-- Ghi chú bổ sung -->
            <c:if test="${not empty record.notes}">
                <div class="detail-section">
                    <h3><i class="fas fa-sticky-note"></i> Ghi chú bổ sung</h3>
                    <div class="detail-value" style="white-space: pre-wrap;">${record.notes}</div>
                </div>
            </c:if>

            <!-- Metadata -->
            <div class="detail-section">
                <h3><i class="fas fa-info"></i> Thông tin hệ thống</h3>
                <c:if test="${not empty record.createdAt}">
                    <div class="detail-row">
                        <span class="detail-label">Ngày tạo:</span>
                        <span class="detail-value"><fmt:formatDate value="${record.createdAt}" pattern="dd/MM/yyyy HH:mm" /></span>
                    </div>
                </c:if>
                <c:if test="${not empty record.updatedAt}">
                    <div class="detail-row">
                        <span class="detail-label">Ngày cập nhật:</span>
                        <span class="detail-value"><fmt:formatDate value="${record.updatedAt}" pattern="dd/MM/yyyy HH:mm" /></span>
                    </div>
                </c:if>
            </div>

            <!-- Buttons -->
            <div class="btn-group">
                <a href="${pageContext.request.contextPath}/doctor/medical-records?action=edit&id=${record.recordId}" class="btn btn-warning">
                    <i class="fas fa-edit"></i> Chỉnh sửa
                </a>
                <a href="${pageContext.request.contextPath}/doctor/medical-records" class="btn btn-secondary">
                    <i class="fas fa-arrow-left"></i> Quay lại
                </a>
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

