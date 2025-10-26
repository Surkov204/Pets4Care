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
    request.setAttribute("doctor", fullDoctorInfo);
    
    // Xử lý active tab
    String activeTab = request.getParameter("tab");
    if (activeTab == null) activeTab = "info";
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Chỉnh sửa Profile | Pet4Care</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/staff.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <style>
        :root {
            --primary: #6FD5DD;
            --secondary: #FFD6C0;
            --accent: #FFC94D;
            --accent-pink: #FF8C94;
            --text: #34495E;
            --text-light: #A9A9A9;
            --bg: #FFFDF8;
            --card-bg: #FFFFFF;
            --shadow: 0 2px 12px rgba(140,170,205,0.12);
            --shadow-hover: 0 4px 20px rgba(140,170,205,0.18);
            --radius: 16px;
        }
        
        body {
            font-family: 'Quicksand', sans-serif;
            background: var(--bg);
            color: var(--text);
            margin: 0;
            padding: 0;
        }
        
        .page-wrapper {
            display: flex;
            min-height: 100vh;
        }
        
        /* Sidebar */
        .sidebar {
            width: 260px;
            background: white;
            box-shadow: var(--shadow);
            position: sticky;
            top: 0;
            height: 100vh;
            overflow-y: auto;
        }
        
        .sidebar-header {
            padding: 25px 20px;
            background: linear-gradient(135deg, var(--primary), var(--secondary));
            color: white;
            text-align: center;
        }
        
        .sidebar-header h3 {
            margin: 0;
            font-size: 17px;
            font-weight: 600;
        }
        
        .sidebar-menu {
            list-style: none;
            padding: 10px 0;
            margin: 0;
        }
        
        .sidebar-menu li a {
            display: flex;
            align-items: center;
            gap: 12px;
            padding: 14px 24px;
            color: var(--text);
            text-decoration: none;
            transition: all 0.2s;
            font-size: 14.5px;
        }
        
        .sidebar-menu li a:hover,
        .sidebar-menu li a.active {
            background: linear-gradient(90deg, var(--primary), var(--secondary));
            color: white;
        }
        
        /* Main Content */
        .main-content {
            flex: 1;
            padding: 30px;
            overflow-y: auto;
        }
        
        .breadcrumb {
            display: flex;
            align-items: center;
            gap: 8px;
            margin-bottom: 20px;
            font-size: 14px;
            color: var(--text-light);
        }
        
        .breadcrumb a {
            color: var(--primary);
            text-decoration: none;
        }
        
        .breadcrumb a:hover {
            text-decoration: underline;
        }
        
        .page-header {
            background: white;
            padding: 28px 32px;
            border-radius: var(--radius);
            margin-bottom: 24px;
            box-shadow: var(--shadow);
        }
        
        .page-header h1 {
            margin: 0 0 6px 0;
            font-size: 24px;
            color: var(--text);
            display: flex;
            align-items: center;
            gap: 10px;
            font-weight: 600;
        }
        
        .page-header p {
            margin: 0;
            color: var(--text-light);
            font-size: 13.5px;
        }
        
        .edit-card {
            background: white;
            border-radius: var(--radius);
            box-shadow: var(--shadow);
            overflow: hidden;
            max-width: 800px;
        }
        
        .tabs {
            display: flex;
            border-bottom: 2px solid #f0f0f0;
            background: #fafafa;
        }
        
        .tab {
            flex: 1;
            padding: 18px;
            background: transparent;
            border: none;
            cursor: pointer;
            font-size: 14.5px;
            font-weight: 600;
            color: var(--text-light);
            transition: all 0.2s;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
            position: relative;
        }
        
        .tab:hover {
            background: rgba(111, 213, 221, 0.08);
            color: var(--primary);
        }
        
        .tab.active {
            background: white;
            color: var(--primary);
        }
        
        .tab.active::after {
            content: '';
            position: absolute;
            bottom: -2px;
            left: 0;
            right: 0;
            height: 2px;
            background: var(--primary);
        }
        
        .tab-content {
            display: none;
            padding: 32px;
        }
        
        .tab-content.active {
            display: block;
            animation: fadeIn 0.3s;
        }
        
        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(8px); }
            to { opacity: 1; transform: translateY(0); }
        }
        
        .alert {
            padding: 12px 16px;
            border-radius: 10px;
            margin-bottom: 20px;
            display: flex;
            align-items: center;
            gap: 10px;
            font-size: 14px;
            animation: slideIn 0.3s;
        }
        
        @keyframes slideIn {
            from { opacity: 0; transform: translateY(-10px); }
            to { opacity: 1; transform: translateY(0); }
        }
        
        .alert-error {
            background: #fff0f0;
            color: #c73a3f;
            border-left: 3px solid var(--accent-pink);
        }
        
        .info-hint {
            background: #f0f9ff;
            border-left: 3px solid var(--primary);
            padding: 12px 16px;
            border-radius: 8px;
            margin-bottom: 20px;
            font-size: 14px;
            color: var(--text);
            display: flex;
            gap: 10px;
        }
        
        .info-hint i {
            color: var(--primary);
            margin-top: 2px;
        }
        
        .form-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 20px;
            margin-bottom: 6px;
        }
        
        .form-field {
            margin-bottom: 20px;
        }
        
        .form-field.full {
            grid-column: 1 / -1;
        }
        
        .form-field label {
            display: block;
            margin-bottom: 7px;
            font-weight: 600;
            color: var(--text);
            font-size: 13.5px;
        }
        
        .required {
            color: var(--accent-pink);
        }
        
        .input-wrapper {
            position: relative;
        }
        
        .input-wrapper i.icon {
            position: absolute;
            left: 12px;
            top: 50%;
            transform: translateY(-50%);
            color: var(--text-light);
            font-size: 14px;
        }
        
        .form-control {
            width: 100%;
            padding: 11px 14px 11px 40px;
            border: 1.5px solid #e0e0e0;
            border-radius: 10px;
            font-size: 14px;
            transition: all 0.2s;
            font-family: 'Quicksand', sans-serif;
            background: var(--card-bg);
        }
        
        .form-control:focus {
            outline: none;
            border-color: var(--primary);
            box-shadow: 0 0 0 3px rgba(111, 213, 221, 0.1);
        }
        
        textarea.form-control {
            resize: vertical;
            min-height: 90px;
            padding-left: 12px;
        }
        
        .toggle-password {
            position: absolute;
            right: 12px;
            top: 50%;
            transform: translateY(-50%);
            cursor: pointer;
            color: var(--text-light);
            font-size: 14px;
        }
        
        .toggle-password:hover {
            color: var(--primary);
        }
        
        .password-strength {
            margin-top: 6px;
            height: 3px;
            background: #f0f0f0;
            border-radius: 2px;
            overflow: hidden;
        }
        
        .password-strength-bar {
            height: 100%;
            width: 0;
            transition: all 0.3s;
        }
        
        .strength-weak { width: 33%; background: var(--accent-pink); }
        .strength-medium { width: 66%; background: var(--accent); }
        .strength-strong { width: 100%; background: #4CAF50; }
        
        .form-actions {
            display: flex;
            gap: 10px;
            justify-content: flex-end;
            margin-top: 25px;
            padding-top: 20px;
            border-top: 1.5px solid #f0f0f0;
        }
        
        .btn {
            padding: 11px 26px;
            border: none;
            border-radius: 10px;
            font-size: 14px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.2s;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            font-family: 'Quicksand', sans-serif;
        }
        
        .btn-primary {
            background: linear-gradient(135deg, var(--primary), var(--secondary));
            color: white;
            box-shadow: 0 2px 8px rgba(111, 213, 221, 0.3);
        }
        
        .btn-primary:hover {
            transform: translateY(-1px);
            box-shadow: 0 4px 12px rgba(111, 213, 221, 0.4);
        }
        
        .btn-secondary {
            background: #f5f5f5;
            color: var(--text);
            border: 1.5px solid #e0e0e0;
        }
        
        .btn-secondary:hover {
            background: #eaeaea;
        }
        
        @media (max-width: 768px) {
            .page-wrapper {
                flex-direction: column;
            }
            
            .sidebar {
                width: 100%;
                height: auto;
                position: relative;
            }
            
            .form-grid {
                grid-template-columns: 1fr;
            }
            
            .main-content {
                padding: 20px;
            }
        }
    </style>
</head>
<body>

<div class="page-wrapper">
    <!-- Sidebar -->
    <aside class="sidebar">
        <div class="sidebar-header">
            <i class="fas fa-user-md" style="font-size: 28px; margin-bottom: 8px;"></i>
            <h3>${doctor.name}</h3>
            <p style="margin: 5px 0 0 0; font-size: 13px; opacity: 0.9;">${doctor.specialization}</p>
        </div>
        
        <ul class="sidebar-menu">
            <li><a href="${pageContext.request.contextPath}/doctor/doctor-dashboard.jsp">
                <i class="fas fa-home"></i> Dashboard
            </a></li>
            <li><a href="${pageContext.request.contextPath}/doctor/appointments.jsp">
                <i class="fas fa-calendar-check"></i> Lịch hẹn
            </a></li>
            <li><a href="${pageContext.request.contextPath}/doctor/work-schedule.jsp">
                <i class="fas fa-clock"></i> Lịch làm việc
            </a></li>
            <li><a href="${pageContext.request.contextPath}/doctor/medical-record.jsp">
                <i class="fas fa-file-medical"></i> Hồ sơ bệnh án
            </a></li>
            <li><a href="${pageContext.request.contextPath}/doctor/doctor-profile.jsp" class="active">
                <i class="fas fa-user"></i> Profile
            </a></li>
            <li><a href="${pageContext.request.contextPath}/logout.jsp">
                <i class="fas fa-sign-out-alt"></i> Đăng xuất
            </a></li>
        </ul>
    </aside>

    <!-- Main Content -->
    <main class="main-content">
        <div class="breadcrumb">
            <a href="${pageContext.request.contextPath}/doctor/doctor-dashboard.jsp">Dashboard</a>
            <i class="fas fa-chevron-right" style="font-size: 10px;"></i>
            <a href="${pageContext.request.contextPath}/doctor/doctor-profile.jsp">Profile</a>
            <i class="fas fa-chevron-right" style="font-size: 10px;"></i>
            <span>Chỉnh sửa</span>
        </div>
        
        <div class="page-header">
            <h1>
                <i class="fas fa-user-edit"></i>
                Chỉnh sửa Profile
            </h1>
            <p>Cập nhật thông tin cá nhân và bảo mật tài khoản của bạn</p>
        </div>
        
        <div class="edit-card">
            <div class="tabs">
                <button class="tab <%= "info".equals(activeTab) ? "active" : "" %>" onclick="switchTab('info')">
                    <i class="fas fa-user-circle"></i>
                    Thông tin cá nhân
                </button>
                <button class="tab <%= "password".equals(activeTab) ? "active" : "" %>" onclick="switchTab('password')">
                    <i class="fas fa-lock"></i>
                    Đổi mật khẩu
                </button>
            </div>
            
            <!-- Tab: Thông tin cá nhân -->
            <div id="tab-info" class="tab-content <%= "info".equals(activeTab) ? "active" : "" %>">
                <c:if test="${param.error != null && param.tab != 'password'}">
                    <div class="alert alert-error">
                        <i class="fas fa-exclamation-circle"></i>
                        <span>
                            <c:choose>
                                <c:when test="${param.error == 'name_required'}">Vui lòng nhập họ tên!</c:when>
                                <c:when test="${param.error == 'email_required'}">Vui lòng nhập email!</c:when>
                                <c:when test="${param.error == 'update_failed'}">Cập nhật thất bại, vui lòng thử lại!</c:when>
                                <c:otherwise>Có lỗi xảy ra!</c:otherwise>
                            </c:choose>
                        </span>
                    </div>
                </c:if>
                
                <div class="info-hint">
                    <i class="fas fa-info-circle"></i>
                    <span>Thông tin của bạn sẽ được hiển thị cho khách hàng khi đặt lịch khám.</span>
                </div>
                
                <form action="${pageContext.request.contextPath}/doctor/update-profile" method="post">
                    <input type="hidden" name="action" value="updateInfo">
                    
                    <div class="form-grid">
                        <div class="form-field">
                            <label>Họ và tên <span class="required">*</span></label>
                            <div class="input-wrapper">
                                <i class="fas fa-user icon"></i>
                                <input type="text" name="name" class="form-control" value="${doctor.name}" required placeholder="Nhập họ tên">
                            </div>
                        </div>
                        
                        <div class="form-field">
                            <label>Email <span class="required">*</span></label>
                            <div class="input-wrapper">
                                <i class="fas fa-envelope icon"></i>
                                <input type="email" name="email" class="form-control" value="${doctor.email}" required placeholder="email@example.com">
                            </div>
                        </div>
                    </div>
                    
                    <div class="form-grid">
                        <div class="form-field">
                            <label>Số điện thoại</label>
                            <div class="input-wrapper">
                                <i class="fas fa-phone icon"></i>
                                <input type="tel" name="phone" class="form-control" value="${doctor.phone}" placeholder="0909 123 456">
                            </div>
                        </div>
                        
                        <div class="form-field">
                            <label>Chuyên khoa</label>
                            <div class="input-wrapper">
                                <i class="fas fa-stethoscope icon"></i>
                                <input type="text" name="specialization" class="form-control" value="${doctor.specialization}" placeholder="Thú y tổng quát">
                            </div>
                        </div>
                    </div>
                    
                    <div class="form-field full">
                        <label>Mô tả / Ghi chú</label>
                        <textarea name="scheduleNote" class="form-control" placeholder="Ghi chú về lịch làm việc, kinh nghiệm, chứng chỉ...">${doctor.scheduleNote}</textarea>
                    </div>
                    
                    <div class="form-actions">
                        <button type="button" class="btn btn-secondary" onclick="window.location.href='${pageContext.request.contextPath}/doctor/doctor-profile.jsp'">
                            <i class="fas fa-times"></i>
                            Hủy
                        </button>
                        <button type="submit" class="btn btn-primary">
                            <i class="fas fa-save"></i>
                            Lưu thay đổi
                        </button>
                    </div>
                </form>
            </div>

            <!-- Tab: Đổi mật khẩu -->
            <div id="tab-password" class="tab-content <%= "password".equals(activeTab) ? "active" : "" %>">
                <c:if test="${param.error != null && param.tab == 'password'}">
                    <div class="alert alert-error">
                        <i class="fas fa-exclamation-circle"></i>
                        <span>
                            <c:choose>
                                <c:when test="${param.error == 'password_required'}">Vui lòng nhập đầy đủ thông tin!</c:when>
                                <c:when test="${param.error == 'wrong_password'}">Mật khẩu hiện tại không đúng!</c:when>
                                <c:when test="${param.error == 'password_mismatch'}">Mật khẩu mới không khớp!</c:when>
                                <c:when test="${param.error == 'password_update_failed'}">Đổi mật khẩu thất bại!</c:when>
                                <c:otherwise>Có lỗi xảy ra!</c:otherwise>
                            </c:choose>
                        </span>
                    </div>
                </c:if>
                
                <div class="info-hint">
                    <i class="fas fa-shield-alt"></i>
                    <span>Sử dụng mật khẩu mạnh với ít nhất 6 ký tự để bảo mật tài khoản.</span>
                </div>
                
                <form action="${pageContext.request.contextPath}/doctor/update-profile" method="post" id="passwordForm">
                    <input type="hidden" name="action" value="changePassword">
                    
                    <div class="form-field">
                        <label>Mật khẩu hiện tại <span class="required">*</span></label>
                        <div class="input-wrapper">
                            <i class="fas fa-key icon"></i>
                            <input type="password" name="currentPassword" id="currentPassword" class="form-control" required placeholder="Nhập mật khẩu hiện tại">
                            <i class="fas fa-eye toggle-password" onclick="togglePassword('currentPassword')"></i>
                        </div>
                    </div>
                    
                    <div class="form-field">
                        <label>Mật khẩu mới <span class="required">*</span></label>
                        <div class="input-wrapper">
                            <i class="fas fa-lock icon"></i>
                            <input type="password" name="newPassword" id="newPassword" class="form-control" required minlength="6" placeholder="Nhập mật khẩu mới" oninput="checkPasswordStrength()">
                            <i class="fas fa-eye toggle-password" onclick="togglePassword('newPassword')"></i>
                        </div>
                        <div class="password-strength">
                            <div class="password-strength-bar" id="strengthBar"></div>
                        </div>
                    </div>
                    
                    <div class="form-field">
                        <label>Xác nhận mật khẩu mới <span class="required">*</span></label>
                        <div class="input-wrapper">
                            <i class="fas fa-check-circle icon"></i>
                            <input type="password" name="confirmPassword" id="confirmPassword" class="form-control" required minlength="6" placeholder="Nhập lại mật khẩu mới">
                            <i class="fas fa-eye toggle-password" onclick="togglePassword('confirmPassword')"></i>
                        </div>
                    </div>
                    
                    <div class="form-actions">
                        <button type="button" class="btn btn-secondary" onclick="window.location.href='${pageContext.request.contextPath}/doctor/doctor-profile.jsp'">
                            <i class="fas fa-times"></i>
                            Hủy
                        </button>
                        <button type="submit" class="btn btn-primary">
                            <i class="fas fa-key"></i>
                            Đổi mật khẩu
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </main>
</div>

<script>
    function switchTab(tabName) {
        document.querySelectorAll('.tab').forEach(btn => btn.classList.remove('active'));
        document.querySelectorAll('.tab-content').forEach(content => content.classList.remove('active'));
        
        event.target.closest('.tab').classList.add('active');
        document.getElementById('tab-' + tabName).classList.add('active');
    }
    
    function togglePassword(inputId) {
        const input = document.getElementById(inputId);
        const icon = event.target;
        
        if (input.type === 'password') {
            input.type = 'text';
            icon.classList.remove('fa-eye');
            icon.classList.add('fa-eye-slash');
        } else {
            input.type = 'password';
            icon.classList.remove('fa-eye-slash');
            icon.classList.add('fa-eye');
        }
    }
    
    function checkPasswordStrength() {
        const password = document.getElementById('newPassword').value;
        const strengthBar = document.getElementById('strengthBar');
        
        strengthBar.className = 'password-strength-bar';
        if (password.length === 0) return;
        
        let strength = 0;
        if (password.length >= 6) strength++;
        if (password.length >= 10) strength++;
        if (/[a-z]/.test(password) && /[A-Z]/.test(password)) strength++;
        if (/\d/.test(password)) strength++;
        if (/[^a-zA-Z\d]/.test(password)) strength++;
        
        if (strength <= 2) strengthBar.classList.add('strength-weak');
        else if (strength <= 3) strengthBar.classList.add('strength-medium');
        else strengthBar.classList.add('strength-strong');
    }
    
    document.getElementById('passwordForm').addEventListener('submit', function(e) {
        const newPassword = document.getElementById('newPassword').value;
        const confirmPassword = document.getElementById('confirmPassword').value;
        
        if (newPassword !== confirmPassword) {
            e.preventDefault();
            alert('Mật khẩu mới và xác nhận không khớp!');
        }
    });
</script>

</body>
</html>
