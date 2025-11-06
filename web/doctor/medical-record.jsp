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
                                        <button onclick="openUpdateModal(${record.bookingId}, '${record.petName}', '${record.customerName}', '${record.status}')"
                                                class="btn-small" style="background: #2196F3; margin-right: 5px;">
                                            <i class="fas fa-edit"></i> Cập nhật
                                        </button>
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

        <!-- Update Medical Record Modal -->
        <div id="updateModal" class="modal" style="display: none; position: fixed; z-index: 1000; left: 0; top: 0; width: 100%; height: 100%; overflow: auto; background-color: rgba(0,0,0,0.4);">
            <div class="modal-content" style="background-color: #fefefe; margin: 2% auto; padding: 0; border-radius: 10px; width: 90%; max-width: 800px; box-shadow: 0 4px 20px rgba(0,0,0,0.2);">
                <div style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 20px; border-radius: 10px 10px 0 0;">
                    <span class="close" onclick="closeUpdateModal()" style="float: right; font-size: 28px; font-weight: bold; cursor: pointer;">&times;</span>
                    <h2 style="margin: 0;"><i class="fas fa-notes-medical"></i> Cập nhật hồ sơ y tế</h2>
                    <p id="modalPetInfo" style="margin: 10px 0 0 0; opacity: 0.9;"></p>
                </div>

                <form action="${pageContext.request.contextPath}/doctor/update-medical-record" method="post" style="padding: 20px;">
                    <input type="hidden" id="bookingId" name="bookingId">

                    <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 20px;">
                        <!-- Left Column -->
                        <div>
                            <h3 style="color: #667eea; margin-bottom: 15px;"><i class="fas fa-clipboard-list"></i> Thông tin khám bệnh</h3>

                            <div style="margin-bottom: 15px;">
                                <label style="display: block; margin-bottom: 5px; font-weight: 600;">Triệu chứng:</label>
                                <textarea name="symptoms" rows="3" style="width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 5px; font-family: inherit;" placeholder="Mô tả triệu chứng..."></textarea>
                            </div>

                            <div style="margin-bottom: 15px;">
                                <label style="display: block; margin-bottom: 5px; font-weight: 600;">Chẩn đoán:</label>
                                <textarea name="diagnosis" rows="3" style="width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 5px; font-family: inherit;" placeholder="Kết quả chẩn đoán..."></textarea>
                            </div>

                            <div style="margin-bottom: 15px;">
                                <label style="display: block; margin-bottom: 5px; font-weight: 600;">Phương pháp điều trị:</label>
                                <textarea name="treatment" rows="3" style="width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 5px; font-family: inherit;" placeholder="Phương pháp điều trị..."></textarea>
                            </div>

                            <div style="margin-bottom: 15px;">
                                <label style="display: block; margin-bottom: 5px; font-weight: 600;">Đơn thuốc:</label>
                                <textarea name="prescription" rows="3" style="width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 5px; font-family: inherit;" placeholder="Tên thuốc, liều lượng, cách dùng..."></textarea>
                            </div>
                        </div>

                        <!-- Right Column -->
                        <div>
                            <h3 style="color: #667eea; margin-bottom: 15px;"><i class="fas fa-heartbeat"></i> Chỉ số sức khỏe</h3>

                            <div style="margin-bottom: 15px;">
                                <label style="display: block; margin-bottom: 5px; font-weight: 600;">Cân nặng (kg):</label>
                                <input type="number" name="weight" step="0.01" style="width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 5px;" placeholder="VD: 5.5">
                            </div>

                            <div style="margin-bottom: 15px;">
                                <label style="display: block; margin-bottom: 5px; font-weight: 600;">Nhiệt độ (°C):</label>
                                <input type="number" name="temperature" step="0.1" style="width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 5px;" placeholder="VD: 38.5">
                            </div>

                            <div style="margin-bottom: 15px;">
                                <label style="display: block; margin-bottom: 5px; font-weight: 600;">Nhịp tim (bpm):</label>
                                <input type="number" name="heartRate" style="width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 5px;" placeholder="VD: 120">
                            </div>

                            <div style="margin-bottom: 15px;">
                                <label style="display: block; margin-bottom: 5px; font-weight: 600;">Huyết áp:</label>
                                <input type="text" name="bloodPressure" style="width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 5px;" placeholder="VD: 120/80">
                            </div>

                            <div style="margin-bottom: 15px;">
                                <label style="display: block; margin-bottom: 5px; font-weight: 600;">Ngày tái khám:</label>
                                <input type="date" name="followUpDate" style="width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 5px;">
                            </div>

                            <div style="margin-bottom: 15px;">
                                <label style="display: block; margin-bottom: 5px; font-weight: 600;">Trạng thái:</label>
                                <select name="status" id="statusSelect" style="width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 5px;">
                                    <option value="confirmed">Đã xác nhận</option>
                                    <option value="in_progress">Đang khám</option>
                                    <option value="completed">Hoàn thành</option>
                                </select>
                            </div>
                        </div>
                    </div>

                    <!-- Full Width Fields -->
                    <div style="margin-top: 20px;">
                        <label style="display: block; margin-bottom: 5px; font-weight: 600;">Ghi chú thêm:</label>
                        <textarea name="notes" rows="3" style="width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 5px; font-family: inherit;" placeholder="Ghi chú bổ sung..."></textarea>
                    </div>

                    <div style="margin-top: 20px;">
                        <label style="display: block; margin-bottom: 5px; font-weight: 600;">Ghi chú tái khám:</label>
                        <textarea name="followUpNotes" rows="2" style="width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 5px; font-family: inherit;" placeholder="Lưu ý cho lần tái khám..."></textarea>
                    </div>

                    <div style="margin-top: 25px; text-align: right; border-top: 1px solid #ddd; padding-top: 20px;">
                        <button type="button" onclick="closeUpdateModal()" style="background: #6c757d; color: white; padding: 12px 24px; border: none; border-radius: 5px; cursor: pointer; margin-right: 10px;">
                            <i class="fas fa-times"></i> Hủy
                        </button>
                        <button type="submit" style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 12px 24px; border: none; border-radius: 5px; cursor: pointer;">
                            <i class="fas fa-save"></i> Lưu hồ sơ
                        </button>
                    </div>
                </form>
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

// Modal functions
function openUpdateModal(bookingId, petName, customerName, status) {
    document.getElementById('bookingId').value = bookingId;
    document.getElementById('modalPetInfo').textContent = 'Thú cưng: ' + petName + ' | Chủ: ' + customerName;
    document.getElementById('statusSelect').value = status;
    document.getElementById('updateModal').style.display = 'block';
}

function closeUpdateModal() {
    document.getElementById('updateModal').style.display = 'none';
}

// Close modal when clicking outside
window.onclick = function(event) {
    const modal = document.getElementById('updateModal');
    if (event.target == modal) {
        closeUpdateModal();
    }
}

// Show success/error messages
window.onload = function() {
    const urlParams = new URLSearchParams(window.location.search);
    if (urlParams.get('success') === 'updated') {
        alert('✅ Cập nhật hồ sơ y tế thành công!');
        // Remove query params from URL
        window.history.replaceState({}, document.title, window.location.pathname);
    } else if (urlParams.get('error')) {
        const error = urlParams.get('error');
        let message = '❌ Có lỗi xảy ra!';
        if (error === 'unauthorized') message = '❌ Bạn không có quyền cập nhật hồ sơ này!';
        else if (error === 'booking_not_found') message = '❌ Không tìm thấy lịch hẹn!';
        else if (error === 'update_failed') message = '❌ Cập nhật thất bại!';
        alert(message);
        window.history.replaceState({}, document.title, window.location.pathname);
    }
}
</script>

</body>
</html>
