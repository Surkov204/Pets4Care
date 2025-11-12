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
    <title>Chi tiết hồ sơ y tế | Pet4Care</title>
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
            display: flex;
            align-items: center;
            gap: 10px;
        }
        
        .info-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 15px;
            margin-bottom: 15px;
        }
        
        .info-item {
            padding: 12px;
            background: #f8f9fa;
            border-radius: 8px;
        }
        
        .info-label {
            font-weight: 600;
            color: #666;
            font-size: 13px;
            margin-bottom: 5px;
        }
        
        .info-value {
            color: #333;
            font-weight: 500;
            font-size: 15px;
        }
        
        .info-section {
            margin-bottom: 25px;
        }
        
        .pet-header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border-radius: 15px;
            padding: 25px;
            margin-bottom: 25px;
        }
        
        .pet-header h2 {
            margin: 0 0 10px 0;
            color: white;
        }
        
        .pet-header p {
            margin: 5px 0;
            opacity: 0.95;
        }
        
        .action-buttons {
            display: flex;
            gap: 10px;
            margin-top: 20px;
        }
        
        .btn-action {
            padding: 12px 24px;
            border: none;
            border-radius: 8px;
            cursor: pointer;
            font-size: 15px;
            font-weight: 600;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            transition: all 0.3s;
        }
        
        .btn-primary {
            background: #4CAF50;
            color: white;
        }
        
        .btn-primary:hover {
            background: #45a049;
            transform: translateY(-2px);
        }
        
        .btn-secondary {
            background: #6c757d;
            color: white;
        }
        
        .btn-secondary:hover {
            background: #5a6268;
        }
        
        .btn-edit {
            background: #2196F3;
            color: white;
        }
        
        .btn-edit:hover {
            background: #0b7dda;
        }
        
        .vital-signs {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 15px;
            margin-top: 15px;
        }
        
        .vital-card {
            background: white;
            border: 2px solid #e9ecef;
            border-radius: 10px;
            padding: 15px;
            text-align: center;
        }
        
        .vital-card i {
            font-size: 24px;
            color: #667eea;
            margin-bottom: 8px;
        }
        
        .vital-label {
            font-size: 12px;
            color: #666;
            margin-bottom: 5px;
        }
        
        .vital-value {
            font-size: 20px;
            font-weight: bold;
            color: #333;
        }
        
        .text-content {
            background: #f8f9fa;
            padding: 15px;
            border-radius: 8px;
            border-left: 4px solid #667eea;
            line-height: 1.6;
            white-space: pre-wrap;
        }
        
        .empty-text {
            color: #999;
            font-style: italic;
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
         .a   background-color: rgba(255, 255, 255, 0v1);
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
            oterflow: hidden;
        }

        .dropdown-menu.show {
            display: block;
        }

        .dropdown-menu a {
            display: flex;
            align-irems: center;
            g:p: 10px;
            padding: 12px 16px;
            colo #333;
            text-decoration: none;
            transition: background-color 0.3s;
        }

        .dropdown-menu a:hover {
            background-color: #f8f9fa;
        }

        .view-mode, .edit-form {
            display: block;
        }

        .edit-form {
            display: none;
        }

        .edit-form.active {
            display: block;
        }

        .view-mode.hidden {
            display: none;
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

        .form-group input, .form-group textarea, .form-group select {
            width: 100%;
            padding: 12px;
            border: 1px solid #ddd;
            border-radius: 8px;
            font-size: 14px;
            transition: border-color 0.3s;
        }

        .form-group input:focus, .form-group textarea:focus, .form-group select:focus {
            outline: none;
            border-color: #667eea;
            box-shadow: 0 0 0 2px rgba(102, 126, 234, 0.1);
        }

        .form-group textarea {
            resize: vertical;
            min-height: 80px;
        }

        .alert {
            padding: 15px;
            border-radius: 8px;
            margin-bottom: 20px;
            font-weight: 500;
        }

        .alert-success {
            background: #d4edda;
            color: #155724;
            border: 1px solid #c3e6cb;
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

        .view-mode, .edit-form {
            display: block;
        }

        .edit-form {
            display: none;
        }

        .edit-form.active {
            display: block;
        }

        .view-mode.hidden {
            display: none;
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

        .form-group input, .form-group textarea, .form-group select {
            width: 100%;
            padding: 12px;
            border: 1px solid #ddd;
            border-radius: 8px;
            font-size: 14px;
            transition: border-color 0.3s;
        }

        .form-group input:focus, .form-group textarea:focus, .form-group select:focus {
            outline: none;
            border-color: #667eea;
            box-shadow: 0 0 0 2px rgba(102, 126, 234, 0.1);
        }

        .form-group textarea {
            resize: vertical;
            min-height: 80px;
        }

        .alert {
            padding: 15px;
            border-radius: 8px;
            margin-bottom: 20px;
            font-weight: 500;
        }

        .alert-success {
            background: #d4edda;
            color: #155724;
            border: 1px solid #c3e6cb;
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
        }
        
        .dropdown-menu a:hover {
            background-color: #f8f9fa;
        }
        
        .alert {
            padding: 15px 20px;
            border-radius: 8px;
            margin-bottom: 20px;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        
        .alert-success {
            background: #d4edda;
            color: #155724;
            border: 1px solid #c3e6cb;
        }
        
        .edit-form {
            display: none;
        }
        
        .edit-form.active {
            display: block;
        }
        
        .view-mode.hidden {
            display: none;
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
        
        .form-group textarea,
        .form-group input {
            width: 100%;
            padding: 12px;
            border: 2px solid #ddd;
            border-radius: 5px;
            font-size: 14px;
            font-family: inherit;
        }
        
        .form-group textarea {
            resize: vertical;
        }
        
        .form-group input:focus,
        .form-group textarea:focus {
            outline: none;
            border-color: #4CAF50;
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
        <c:if test="${param.success == 'updated'}">
            <div class="alert alert-success">
                <i class="fas fa-check-circle"></i>
                <span>Cập nhật hồ sơ y tế thành công!</span>
            </div>
        </c:if>

        <div class="pet-header">
            <h2><i class="fas fa-paw"></i> ${record.petName}</h2>
            <p><i class="fas fa-dog"></i> <strong>Loài:</strong> ${record.petSpecies}</p>
            <p><i class="fas fa-user"></i> <strong>Chủ sở hữu:</strong> ${record.customerName}</p>
            <p><i class="fas fa-calendar"></i> <strong>Ngày khám:</strong> 
                <fmt:formatDate value="${record.examinationDate}" pattern="dd/MM/yyyy HH:mm" />
            </p>
        </div>

        <div class="action-buttons">
            <a href="${pageContext.request.contextPath}/doctor/medical-records" class="btn-action btn-secondary">
                <i class="fas fa-arrow-left"></i> Quay lại
            </a>
            <button onclick="toggleEditMode()" class="btn-action btn-edit" id="editBtn">
                <i class="fas fa-edit"></i> Chỉnh sửa
            </button>
        </div>

        <div id="viewMode" class="view-mode">
            <div class="detail-card">
                <h3><i class="fas fa-heartbeat"></i> Chỉ số sức khỏe</h3>
                <div class="vital-signs">
                    <div class="vital-card">
                        <i class="fas fa-weight"></i>
                        <div class="vital-label">Cân nặng</div>
                        <div class="vital-value">
                            <c:choose>
                                <c:when test="${not empty record.weight}">${record.weight} kg</c:when>
                                <c:otherwise>-</c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                    <div class="vital-card">
                        <i class="fas fa-thermometer-half"></i>
                        <div class="vital-label">Nhiệt độ</div>
                        <div class="vital-value">
                            <c:choose>
                                <c:when test="${not empty record.temperature}">${record.temperature}°C</c:when>
                                <c:otherwise>-</c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                    <div class="vital-card">
                        <i class="fas fa-heartbeat"></i>
                        <div class="vital-label">Nhịp tim</div>
                        <div class="vital-value">
                            <c:choose>
                                <c:when test="${not empty record.heartRate}">${record.heartRate} bpm</c:when>
                                <c:otherwise>-</c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                    <div class="vital-card">
                        <i class="fas fa-tint"></i>
                        <div class="vital-label">Huyết áp</div>
                        <div class="vital-value">
                            <c:choose>
                                <c:when test="${not empty record.bloodPressure}">${record.bloodPressure}</c:when>
                                <c:otherwise>-</c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </div>
            </div>

            <div class="detail-card">
                <h3><i class="fas fa-stethoscope"></i> Triệu chứng</h3>
                <div class="text-content">
                    <c:choose>
                        <c:when test="${not empty record.symptoms}">${record.symptoms}</c:when>
                        <c:otherwise><span class="empty-text">Chưa có thông tin</span></c:otherwise>
                    </c:choose>
                </div>
            </div>

            <div class="detail-card">
                <h3><i class="fas fa-diagnoses"></i> Chẩn đoán</h3>
                <div class="text-content">
                    <c:choose>
                        <c:when test="${not empty record.diagnosis}">${record.diagnosis}</c:when>
                        <c:otherwise><span class="empty-text">Chưa có thông tin</span></c:otherwise>
                    </c:choose>
                </div>
            </div>

            <div class="detail-card">
                <h3><i class="fas fa-procedures"></i> Phương pháp điều trị</h3>
                <div class="text-content">
                    <c:choose>
                        <c:when test="${not empty record.treatment}">${record.treatment}</c:when>
                        <c:otherwise><span class="empty-text">Chưa có thông tin</span></c:otherwise>
                    </c:choose>
                </div>
            </div>

            <div class="detail-card">
                <h3><i class="fas fa-prescription"></i> Đơn thuốc</h3>
                <div class="text-content">
                    <c:choose>
                        <c:when test="${not empty record.prescription}">${record.prescription}</c:when>
                        <c:otherwise><span class="empty-text">Chưa có đơn thuốc</span></c:otherwise>
                    </c:choose>
                </div>
            </div>

            <div class="detail-card">
                <h3><i class="fas fa-notes-medical"></i> Ghi chú</h3>
                <div class="text-content">
                    <c:choose>
                        <c:when test="${not empty record.notes}">${record.notes}</c:when>
                        <c:otherwise><span class="empty-text">Không có ghi chú</span></c:otherwise>
                    </c:choose>
                </div>
            </div>

            <c:if test="${not empty record.followUpDate}">
                <div class="detail-card">
                    <h3><i class="fas fa-calendar-check"></i> Lịch tái khám</h3>
                    <div class="info-grid">
                        <div class="info-item">
                            <div class="info-label">Ngày tái khám</div>
                            <div class="info-value">
                                <fmt:formatDate value="${record.followUpDate}" pattern="dd/MM/yyyy" />
                            </div>
                        </div>
                        <div class="info-item">
                            <div class="info-label">Ghi chú tái khám</div>
                            <div class="info-value">
                                <c:choose>
                                    <c:when test="${not empty record.followUpNotes}">${record.followUpNotes}</c:when>
                                    <c:otherwise>-</c:otherwise>
                                </c:choose>
                            </div>
                        </div>
                    </div>
                </div>
            </c:if>
        </div>

        <div id="editMode" class="edit-form">
            <form action="${pageContext.request.contextPath}/doctor/medical-records" method="post">
                <input type="hidden" name="action" value="update">
                <input type="hidden" name="recordId" value="${record.recordId}">

                <div class="detail-card">
                    <h3><i class="fas fa-heartbeat"></i> Chỉ số sức khỏe</h3>
                    <div class="info-grid">
                        <div class="form-group">
                            <label>Cân nặng (kg):</label>
                            <input type="number" name="weight" step="0.01" value="${record.weight}" placeholder="VD: 5.5">
                        </div>
                        <div class="form-group">
                            <label>Nhiệt độ (°C):</label>
                            <input type="number" name="temperature" step="0.1" value="${record.temperature}" placeholder="VD: 38.5">
                        </div>
                        <div class="form-group">
                            <label>Nhịp tim (bpm):</label>
                            <input type="number" name="heartRate" value="${record.heartRate}" placeholder="VD: 120">
                        </div>
                        <div class="form-group">
                            <label>Huyết áp:</label>
                            <input type="text" name="bloodPressure" value="${record.bloodPressure}" placeholder="VD: 120/80">
                        </div>
                    </div>
                </div>

                <div class="detail-card">
                    <h3><i class="fas fa-stethoscope"></i> Triệu chứng</h3>
                    <div class="form-group">
                        <textarea name="symptoms" rows="4" placeholder="Mô tả triệu chứng...">${record.symptoms}</textarea>
                    </div>
                </div>

                <div class="detail-card">
                    <h3><i class="fas fa-diagnoses"></i> Chẩn đoán</h3>
                    <div class="form-group">
                        <textarea name="diagnosis" rows="4" placeholder="Kết quả chẩn đoán...">${record.diagnosis}</textarea>
                    </div>
                </div>

                <div class="detail-card">
                    <h3><i class="fas fa-procedures"></i> Phương pháp điều trị</h3>
                    <div class="form-group">
                        <textarea name="treatment" rows="4" placeholder="Phương pháp điều trị...">${record.treatment}</textarea>
                    </div>
                </div>

                <div class="detail-card">
                    <h3><i class="fas fa-prescription"></i> Đơn thuốc</h3>
                    <div class="form-group">
                        <textarea name="prescription" rows="4" placeholder="Tên thuốc, liều lượng, cách dùng...">${record.prescription}</textarea>
                    </div>
                </div>

                <div class="detail-card">
                    <h3><i class="fas fa-notes-medical"></i> Ghi chú</h3>
                    <div class="form-group">
                        <textarea name="notes" rows="3" placeholder="Ghi chú bổ sung...">${record.notes}</textarea>
                    </div>
                </div>

                <div class="detail-card">
                    <h3><i class="fas fa-calendar-check"></i> Lịch tái khám</h3>
                    <div class="info-grid">
                        <div class="form-group">
                            <label>Ngày tái khám:</label>
                            <input type="date" name="followUpDate" value="${record.followUpDate}">
                        </div>
                        <div class="form-group">
                            <label>Ghi chú tái khám:</label>
                            <input type="text" name="followUpNotes" value="${record.followUpNotes}" placeholder="Lưu ý cho lần tái khám...">
                        </div>
                    </div>
                </div>

                <div class="action-buttons">
                    <button type="button" onclick="toggleEditMode()" class="btn-action btn-secondary">
                        <i class="fas fa-times"></i> Hủy
                    </button>
                    <button type="submit" class="btn-action btn-primary">
                        <i class="fas fa-save"></i> Lưu thay đổi
                    </button>
                </div>
            </form>
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

function toggleEditMode() {
    const viewMode = document.getElementById('viewMode');
    const editMode = document.getElementById('editMode');
    const editBtn = document.getElementById('editBtn');
    
    if (editMode.classList.contains('active')) {
        editMode.classList.remove('active');
        viewMode.classList.remove('hidden');
        editBtn.innerHTML = '<i class="fas fa-edit"></i> Chỉnh sửa';
    } else {
        editMode.classList.add('active');
        viewMode.classList.add('hidden');
        editBtn.innerHTML = '<i class="fas fa-eye"></i> Xem';
    }
}
</script>

</body>
</html>
