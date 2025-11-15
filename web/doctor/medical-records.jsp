<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ page import="model.Doctor" %>
<%
    Doctor doctor = (Doctor) session.getAttribute("doctor");
    if (doctor == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Hồ sơ y tế | Pet4Care</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/staff.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <style>
        .records-table {
            background: white;
            border-radius: 10px;
            overflow: hidden;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            margin-top: 20px;
        }
        
        .records-table table {
            width: 100%;
            border-collapse: collapse;
        }
        
        .records-table th {
            background: #f8f9fa;
            padding: 15px;
            text-align: left;
            font-weight: 600;
            border-bottom: 2px solid #dee2e6;
        }
        
        .records-table td {
            padding: 15px;
            border-bottom: 1px solid #dee2e6;
        }
        
        .records-table tr:hover {
            background: #f8f9fa;
        }
        
        .btn-create {
            background: #4CAF50;
            color: white;
            padding: 8px 15px;
            border-radius: 5px;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 5px;
        }
        
        .btn-create:hover {
            background: #45a049;
        }
        
        .no-records {
            text-align: center;
            padding: 40px;
            color: #666;
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
            <h2><i class="fas fa-notes-medical"></i> Hồ sơ y tế bệnh nhân</h2>
            <p>Quản lý hồ sơ y tế của bệnh nhân</p>
        </section>

        <div class="records-table">
            <c:choose>
                <c:when test="${not empty patients}">
                    <table>
                        <thead>
                            <tr>
                                <th>Bệnh nhân</th>
                                <th>Chủ sở hữu</th>
                                <th>Loài</th>
                                <th>Hồ sơ gần nhất</th>
                                <th>Hành động</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="patient" items="${patients}">
                                <tr>
                                    <td>
                                        <strong>${patient.petName}</strong>
                                    </td>
                                    <td>${patient.ownerName}</td>
                                    <td>${patient.species}</td>
                                    <td>
                                        <c:if test="${not empty patient.lastRecordDate}">
                                            ${patient.lastRecordDate}
                                        </c:if>
                                        <c:if test="${empty patient.lastRecordDate}">
                                            <em>Chưa có hồ sơ</em>
                                        </c:if>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${not empty patient.lastRecordDate}">
                                                <a href="${pageContext.request.contextPath}/doctor/medical-record-detail?id=${patient.lastRecordId}" class="btn-small">
                                                    <i class="fas fa-eye"></i> Xem hồ sơ
                                                </a>
                                            </c:when>
                                            <c:otherwise>
                                                <form action="${pageContext.request.contextPath}/doctor/medical-records" method="post" style="display:inline;">
                                                    <input type="hidden" name="action" value="create">
                                                    <input type="hidden" name="petId" value="${patient.petId}">
                                                    <button type="submit" class="btn-create">
                                                        <i class="fas fa-plus"></i> Tạo hồ sơ
                                                    </button>
                                                </form>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </c:when>
                <c:otherwise>
                    <div class="no-records">
                        <i class="fas fa-file-medical" style="font-size:48px;"></i>
                        <h3>Không có bệnh nhân nào</h3>
                        <p>Hiện chưa có bệnh nhân nào trong hệ thống</p>
                    </div>
                </c:otherwise>
            </c:choose>
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