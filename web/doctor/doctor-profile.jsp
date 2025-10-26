<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
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
    <title>🐾 Doctor Profile | Pet4Care</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/staff.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <style>
        .profile-container {
            background: white;
            border-radius: 10px;
            padding: 30px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            margin-bottom: 20px;
        }
        
        .profile-header {
            display: flex;
            align-items: center;
            margin-bottom: 30px;
            padding-bottom: 20px;
            border-bottom: 2px solid #f0f0f0;
        }
        
        .profile-avatar {
            width: 120px;
            height: 120px;
            border-radius: 50%;
            background: #f0f0f0;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 48px;
            color: #666;
            margin-right: 30px;
        }
        
        .profile-info h2 {
            margin: 0 0 10px 0;
            color: #333;
        }
        
        .profile-info .specialization {
            background: #e3f2fd;
            color: #1565c0;
            padding: 5px 15px;
            border-radius: 20px;
            font-size: 14px;
            font-weight: 600;
            display: inline-block;
            margin-bottom: 10px;
        }
        
        .profile-info .email {
            color: #666;
            font-size: 16px;
        }
        
        .profile-details {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 30px;
        }
        
        .detail-section {
            background: #f8f9fa;
            padding: 20px;
            border-radius: 8px;
        }
        
        .detail-section h3 {
            margin: 0 0 15px 0;
            color: #333;
            font-size: 18px;
        }
        
        .detail-item {
            display: flex;
            justify-content: space-between;
            padding: 10px 0;
            border-bottom: 1px solid #e0e0e0;
        }
        
        .detail-item:last-child {
            border-bottom: none;
        }
        
        .detail-label {
            font-weight: 600;
            color: #555;
        }
        
        .detail-value {
            color: #333;
        }
        
        .schedule-note {
            background: #e8f5e8;
            padding: 15px;
            border-radius: 8px;
            border-left: 4px solid #4CAF50;
            margin-top: 20px;
        }
        
        .edit-button {
            background: #4CAF50;
            color: white;
            padding: 10px 20px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            font-size: 16px;
            margin-top: 20px;
        }
        
        .edit-button:hover {
            background: #45a049;
        }
        
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin-top: 30px;
        }
        
        .stat-card {
            background: white;
            padding: 20px;
            border-radius: 8px;
            text-align: center;
            box-shadow: 0 2px 5px rgba(0,0,0,0.1);
        }
        
        .stat-card i {
            font-size: 32px;
            margin-bottom: 10px;
        }
        
        .stat-card .stat-number {
            font-size: 24px;
            font-weight: bold;
            color: #333;
        }
        
        .stat-card .stat-label {
            color: #666;
            font-size: 14px;
        }
        
        .stat-card.appointments { border-top: 4px solid #4CAF50; }
        .stat-card.appointments i { color: #4CAF50; }
        
        .stat-card.customers { border-top: 4px solid #2196F3; }
        .stat-card.customers i { color: #2196F3; }
        
        .stat-card.experience { border-top: 4px solid #FF9800; }
        .stat-card.experience i { color: #FF9800; }
        
        .stat-card.rating { border-top: 4px solid #9C27B0; }
        .stat-card.rating i { color: #9C27B0; }
        .btn-edit:hover {
            background: #0056b3;
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
            <li><a href="work-schedule.jsp"><i class="fas fa-calendar-alt"></i> Work Schedule</a></li>
            <li><a href="appointments.jsp"><i class="fas fa-stethoscope"></i> Appointments</a></li>
            <li><a href="doctor-profile.jsp" class="active"><i class="fas fa-user-md"></i> Doctor Profile</a></li>
        </ul>
    </aside>

    <!-- Main Content -->
    <main class="staff-content">
        <div class="profile-container">
            <div class="profile-header">
                <div class="profile-avatar">
                    <i class="fas fa-user-md"></i>
                </div>
                <div class="profile-info">
                    <h2>${fullDoctorInfo.name}</h2>
                    <div class="specialization">${fullDoctorInfo.specialization}</div>
                    <div class="email">
                        <i class="fas fa-envelope"></i> ${fullDoctorInfo.email}
                    </div>
                </div>
                <div>
                    <a href="${pageContext.request.contextPath}/doctor/update-profile" class="edit-button">
                        <i class="fas fa-edit"></i> Chỉnh sửa Profile
                    </a>
                </div>
            </div>
            
            <!-- Success Messages -->
            <c:if test="${param.success != null}">
                <div style="background: #d4edda; color: #155724; padding: 12px 20px; border-radius: 6px; margin-bottom: 20px; display: flex; align-items: center; gap: 10px;">
                    <i class="fas fa-check-circle"></i>
                    <span>
                        <c:choose>
                            <c:when test="${param.success == 'profile_updated'}">Cập nhật thông tin thành công!</c:when>
                            <c:when test="${param.success == 'password_changed'}">Đổi mật khẩu thành công!</c:when>
                            <c:otherwise>Thao tác thành công!</c:otherwise>
                        </c:choose>
                    </span>
                </div>
            </c:if>

            <div class="profile-details">
                <div class="detail-section">
                    <h3><i class="fas fa-info-circle"></i> Thông tin cá nhân</h3>
                    <div class="detail-item">
                        <span class="detail-label">ID Bác sĩ:</span>
                        <span class="detail-value">#${fullDoctorInfo.doctorId}</span>
                    </div>
                    <div class="detail-item">
                        <span class="detail-label">Họ và tên:</span>
                        <span class="detail-value">${fullDoctorInfo.name}</span>
                    </div>
                    <div class="detail-item">
                        <span class="detail-label">Email:</span>
                        <span class="detail-value">${fullDoctorInfo.email}</span>
                    </div>
                    <div class="detail-item">
                        <span class="detail-label">Số điện thoại:</span>
                        <span class="detail-value">
                            <c:choose>
                                <c:when test="${not empty fullDoctorInfo.phone}">
                                    ${fullDoctorInfo.phone}
                                </c:when>
                                <c:otherwise>
                                    <em>Chưa cập nhật</em>
                                </c:otherwise>
                            </c:choose>
                        </span>
                    </div>
                </div>

                <div class="detail-section">
                    <h3><i class="fas fa-graduation-cap"></i> Chuyên môn</h3>
                    <div class="detail-item">
                        <span class="detail-label">Chuyên khoa:</span>
                        <span class="detail-value">${fullDoctorInfo.specialization}</span>
                    </div>
                    <div class="detail-item">
                        <span class="detail-label">Trạng thái:</span>
                        <span class="detail-value" style="color: #4CAF50; font-weight: bold;">
                            <i class="fas fa-check-circle"></i> Đang hoạt động
                        </span>
                    </div>
                    <div class="detail-item">
                        <span class="detail-label">Ngày tham gia:</span>
                        <span class="detail-value">Tháng 1, 2025</span>
                    </div>
                </div>
            </div>

            <c:if test="${not empty fullDoctorInfo.scheduleNote}">
                <div class="schedule-note">
                    <h4><i class="fas fa-calendar"></i> Lịch làm việc</h4>
                    <p>${fullDoctorInfo.scheduleNote}</p>
                </div>
            </c:if>

            <button class="edit-button" onclick="editProfile()">
                <i class="fas fa-edit"></i> Chỉnh sửa thông tin
            </button>
        </div>

        <!-- Statistics -->
        <div class="stats-grid">
            <div class="stat-card appointments">
                <i class="fas fa-calendar-check"></i>
                <div class="stat-number">24</div>
                <div class="stat-label">Cuộc hẹn tháng này</div>
            </div>
            <div class="stat-card customers">
                <i class="fas fa-users"></i>
                <div class="stat-number">156</div>
                <div class="stat-label">Khách hàng đã khám</div>
            </div>
            <div class="stat-card experience">
                <i class="fas fa-award"></i>
                <div class="stat-number">5+</div>
                <div class="stat-label">Năm kinh nghiệm</div>
            </div>
            <div class="stat-card rating">
                <i class="fas fa-star"></i>
                <div class="stat-number">4.8</div>
                <div class="stat-label">Đánh giá trung bình</div>
            </div>
        </div>

        <!-- Recent Reviews -->
        <div class="profile-container">
            <h3><i class="fas fa-comments"></i> Đánh giá gần đây</h3>
            <div style="margin-top: 20px;">
                <div style="background: #f8f9fa; padding: 15px; border-radius: 8px; margin-bottom: 15px;">
                    <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 10px;">
                        <strong>Nguyễn Thị Lan</strong>
                        <div style="color: #FF9800;">
                            <i class="fas fa-star"></i>
                            <i class="fas fa-star"></i>
                            <i class="fas fa-star"></i>
                            <i class="fas fa-star"></i>
                            <i class="fas fa-star"></i>
                        </div>
                    </div>
                    <p style="margin: 0; color: #666;">"Bác sĩ rất tận tâm và chuyên nghiệp. Mèo nhà tôi đã khỏi bệnh hoàn toàn nhờ sự chăm sóc của bác sĩ."</p>
                </div>
                
                <div style="background: #f8f9fa; padding: 15px; border-radius: 8px; margin-bottom: 15px;">
                    <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 10px;">
                        <strong>Trần Văn Minh</strong>
                        <div style="color: #FF9800;">
                            <i class="fas fa-star"></i>
                            <i class="fas fa-star"></i>
                            <i class="fas fa-star"></i>
                            <i class="fas fa-star"></i>
                            <i class="fas fa-star"></i>
                        </div>
                    </div>
                    <p style="margin: 0; color: #666;">"Dịch vụ tuyệt vời! Bác sĩ giải thích rất rõ ràng và cún nhà tôi rất thích."</p>
                </div>
            </div>
        </div>
    </main>
</div>

<footer class="staff-footer">
    <p>© 2025 Pet4Care — Dedicated to Pet Health & Happiness 🐶🐱</p>
</footer>

<script>
function editProfile() {
    // TODO: Implement edit profile functionality
    alert('Chức năng chỉnh sửa thông tin sẽ được phát triển trong phiên bản tiếp theo!');
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
