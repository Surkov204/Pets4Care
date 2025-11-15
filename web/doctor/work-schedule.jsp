<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
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
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>📅 Lịch làm việc | Pet4Care</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/staff.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <style>
        body {
            background: #f8fafc;
            font-family: 'Poppins', sans-serif;
            color: #333;
        }

        .section-card {
            background: #fff;
            border-radius: 20px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.05);
            padding: 2rem;
            margin: 2rem auto;
            width: 90%;
            max-width: 1100px;
        }

        .section-title {
            font-size: 1.4rem;
            font-weight: 600;
            color: #2f3e46;
            margin-bottom: 1rem;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .section-title i {
            color: #00bfa6;
        }

        .week-nav {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 1.5rem;
        }

        .btn {
            background: linear-gradient(90deg, #a7e1df, #fde1ca);
            border: none;
            color: #2f3e46;
            padding: 8px 16px;
            border-radius: 10px;
            font-weight: 600;
            cursor: pointer;
            transition: 0.2s;
        }

        .btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 3px 6px rgba(0,0,0,0.15);
        }

        .btn-danger {
            background: linear-gradient(90deg, #ffd3c4, #f2a29b);
            color: #fff;
        }

        table {
            width: 100%;
            border-collapse: collapse;
            text-align: center;
            border-radius: 10px;
            overflow: hidden;
            margin-top: 10px;
        }

        th {
            background: linear-gradient(90deg, #a6e3e9 0%, #f9e4d4 100%);
            color: #2f3e46;
            font-weight: 600;
            padding: 10px;
            border: 1px solid #e5e7eb;
        }

        td {
            border: 1px solid #e5e7eb;
            padding: 8px;
        }

        .shift-label {
            background: #f8f9fa;
            font-weight: 600;
            color: #374151;
            width: 160px;
        }

        .registered-shift {
            background: #d1fae5;
            color: #065f46;
            padding: 8px;
            border-radius: 8px;
            font-weight: 600;
        }

        .empty-shift {
            background: #f3f4f6;
            color: #9ca3af;
            padding: 8px;
        }

        .alert {
            padding: 12px 20px;
            border-radius: 8px;
            margin-bottom: 15px;
            font-weight: 500;
        }

        .alert-success {
            background: #d1fae5;
            color: #065f46;
            border-left: 4px solid #10b981;
        }

        .alert-error {
            background: #fee2e2;
            color: #991b1b;
            border-left: 4px solid #ef4444;
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

        .checkbox-group {
            display: flex;
            gap: 10px;
            align-items: center;
            justify-content: center;
        }

        input[type="checkbox"] {
            width: 18px;
            height: 18px;
            cursor: pointer;
        }

        .btn-group {
            display: flex;
            justify-content: center;
            gap: 12px;
            margin-top: 20px;
            flex-wrap: wrap;
        }

        .modal {
            display: none;
            position: fixed;
            inset: 0;
            background: rgba(0,0,0,0.3);
            z-index: 2000;
            align-items: center;
            justify-content: center;
        }

        .modal.show {
            display: flex;
        }

        .modal-content {
            background: #fff;
            border-radius: 16px;
            padding: 2rem;
            width: 460px;
            max-width: 90%;
            position: relative;
            box-shadow: 0 12px 30px rgba(0,0,0,0.15);
        }

        .close-btn {
            position: absolute;
            top: 12px;
            right: 16px;
            font-size: 20px;
            cursor: pointer;
            color: #555;
        }

        .close-btn:hover {
            color: #000;
        }

        .modal form {
            display: flex;
            flex-direction: column;
            gap: 1rem;
        }

        .modal label {
            font-weight: 600;
            color: #374151;
        }

        .modal select,
        .modal textarea {
            width: 100%;
            border-radius: 10px;
            border: 1px solid #d1d5db;
            padding: 10px;
        }

        .submit-btn {
            background: linear-gradient(90deg, #a6e3e9, #f9e4d4);
            border: none;
            color: #2f3e46;
            border-radius: 12px;
            padding: 12px;
            font-weight: 600;
            cursor: pointer;
            transition: 0.3s;
        }

        .submit-btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 10px rgba(0,0,0,0.12);
        }

        textarea[name="cancelReason"] {
            margin-top: 12px;
            width: 100%;
            border-radius: 10px;
            border: 1px solid #d1d5db;
            padding: 10px;
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
            <li><a href="${pageContext.request.contextPath}/doctor/medical-records"><i class="fas fa-notes-medical"></i> Medical Records</a></li>
            <li><a href="${pageContext.request.contextPath}/doctor/work-schedule" class="active"><i class="fas fa-calendar-alt"></i> Work Schedule</a></li>
            <li><a href="${pageContext.request.contextPath}/doctor/appointments"><i class="fas fa-stethoscope"></i> Appointments</a></li>
            <li><a href="${pageContext.request.contextPath}/doctor/profile"><i class="fas fa-user-md"></i> Doctor Profile</a></li>
        </ul>
    </aside>

    <main class="staff-content">
        <c:if test="${not empty sessionScope.successMessage}">
            <div class="alert alert-success">${sessionScope.successMessage}</div>
            <c:remove var="successMessage" scope="session"/>
        </c:if>
        
        <c:if test="${not empty sessionScope.errorMessage}">
            <div class="alert alert-error">${sessionScope.errorMessage}</div>
            <c:remove var="errorMessage" scope="session"/>
        </c:if>

        <section class="section-card">
            <div class="section-title">
                <i class="fas fa-calendar-week"></i> Lịch làm việc hiện tại
            </div>

            <div class="week-nav">
                <form method="get" style="display: inline;">
                    <input type="hidden" name="weekOffset" value="${weekOffset - 1}">
                    <button type="submit" class="btn"><i class="fas fa-chevron-left"></i> Tuần trước</button>
                </form>
                
                <h3><fmt:formatDate value="${startOfWeek}" pattern="dd/MM/yyyy"/> – <fmt:formatDate value="${endOfWeek}" pattern="dd/MM/yyyy"/></h3>
                
                <form method="get" style="display: inline;">
                    <input type="hidden" name="weekOffset" value="${weekOffset + 1}">
                    <button type="submit" class="btn">Tuần sau <i class="fas fa-chevron-right"></i></button>
                </form>
            </div>

            <form method="post" action="${pageContext.request.contextPath}/doctor/work-schedule">
                <input type="hidden" name="action" value="cancelMultiple">
                <table>
                    <thead>
                        <tr>
                            <th>Ca / Ngày</th>
                            <c:forEach var="day" items="${weekDays}">
                                <th>${day.dayName}<br><small>${day.date}</small></th>
                            </c:forEach>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="shift" items="${shifts}">
                            <tr>
                                <td class="shift-label">${shift.shiftName}<br><small>${fn:substring(shift.startTime,0,5)} – ${fn:substring(shift.endTime,0,5)}</small></td>
                                <c:forEach var="day" items="${weekDays}">
                                    <td>
                                        <c:set var="hasShift" value="false"/>
                                        <c:forEach var="registeredShiftId" items="${day.registeredShifts}">
                                            <c:if test="${registeredShiftId == shift.shiftID}">
                                                <c:set var="hasShift" value="true"/>
                                            </c:if>
                                        </c:forEach>
                                        
                                        <c:choose>
                                            <c:when test="${hasShift}">
                                                <div class="registered-shift">
                                                    <i class="fas fa-check-circle"></i> Đã đăng ký
                                                </div>
                                                <div class="checkbox-group">
                                                    <input type="checkbox" name="cancelItems" value="${day.date}|${shift.shiftID}">
                                                    <label>Hủy</label>
                                                </div>
                                            </c:when>
                                            <c:otherwise>
                                                <div class="empty-shift">—</div>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                </c:forEach>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
                <textarea name="cancelReason" rows="2" placeholder="Lý do hủy ca (tùy chọn)"></textarea>
                <div class="btn-group">
                    <button type="submit" class="btn btn-danger"><i class="fas fa-times"></i> Gửi yêu cầu hủy ca</button>
                </div>
            </form>

            <div class="btn-group">
                <c:choose>
                    <c:when test="${canRegister}">
                        <button type="button" class="btn" id="openRegisterModal"><i class="fas fa-plus"></i> Đăng ký ca tuần sau</button>
                    </c:when>
                    <c:otherwise>
                        <button type="button" class="btn" disabled style="opacity:0.6;cursor:not-allowed;"><i class="fas fa-lock"></i> Đăng ký ca (đang khóa)</button>
                    </c:otherwise>
                </c:choose>
                <c:choose>
                    <c:when test="${not empty otherDoctors}">
                        <button type="button" class="btn" id="openSwapModal"><i class="fas fa-repeat"></i> Yêu cầu đổi ca</button>
                    </c:when>
                    <c:otherwise>
                        <button type="button" class="btn" disabled style="opacity:0.6;cursor:not-allowed;"><i class="fas fa-user-slash"></i> Không có bác sĩ để đổi</button>
                    </c:otherwise>
                </c:choose>
                <c:choose>
                    <c:when test="${not empty otherDoctors}">
                        <button type="button" class="btn" id="openPassModal"><i class="fas fa-handshake"></i> Nhờ bác sĩ khác làm</button>
                    </c:when>
                    <c:otherwise>
                        <button type="button" class="btn" disabled style="opacity:0.6;cursor:not-allowed;"><i class="fas fa-user-slash"></i> Không có bác sĩ để nhờ</button>
                    </c:otherwise>
                </c:choose>
            </div>
        </section>

        <div id="registerModal" class="modal">
            <div class="modal-content">
                <span class="close-btn" data-close="registerModal">&times;</span>
                <h3>Yêu cầu đăng ký ca</h3>
                <form method="post" action="${pageContext.request.contextPath}/doctor/work-schedule">
                    <input type="hidden" name="action" value="register">
                    <label>Ngày làm (tuần sau)</label>
                    <select name="day" required>
                        <c:forEach var="day" items="${nextWeekDays}">
                            <option value="${day.date}">${day.dayName} - ${day.date}</option>
                        </c:forEach>
                    </select>
                    <label>Ca làm</label>
                    <select name="shift" required>
                        <option value="morning">Ca sáng (08:00 – 12:00)</option>
                        <option value="afternoon">Ca chiều (13:00 – 17:00)</option>
                        <option value="evening">Ca tối (18:00 – 22:00)</option>
                    </select>
                    <label>Lý do (tùy chọn)</label>
                    <textarea name="reason" rows="2" placeholder="Ví dụ: muốn hỗ trợ thêm ca..."></textarea>
                    <button type="submit" class="submit-btn">Gửi yêu cầu</button>
                </form>
            </div>
        </div>

        <div id="swapModal" class="modal">
            <div class="modal-content">
                <span class="close-btn" data-close="swapModal">&times;</span>
                <h3>Yêu cầu đổi ca</h3>
                <form method="post" action="${pageContext.request.contextPath}/doctor/work-schedule">
                    <input type="hidden" name="action" value="swap">
                    <label>Ca của bạn</label>
                    <select name="swapFromDate" required>
                        <c:forEach var="day" items="${weekDays}">
                            <option value="${day.date}">${day.dayName} - ${day.date}</option>
                        </c:forEach>
                    </select>
                    <select name="swapFromShiftId" required>
                        <option value="1">Ca sáng (08:00 – 12:00)</option>
                        <option value="2">Ca chiều (13:00 – 17:00)</option>
                        <option value="3">Ca tối (18:00 – 22:00)</option>
                    </select>
                    <label>Ca muốn đổi</label>
                    <select name="swapToDate" required>
                        <c:forEach var="day" items="${weekDays}">
                            <option value="${day.date}">${day.dayName} - ${day.date}</option>
                        </c:forEach>
                    </select>
                    <select name="swapToShiftId" required>
                        <option value="1">Ca sáng (08:00 – 12:00)</option>
                        <option value="2">Ca chiều (13:00 – 17:00)</option>
                        <option value="3">Ca tối (18:00 – 22:00)</option>
                    </select>
                    <label>Bác sĩ muốn đổi cùng</label>
                    <select name="swapToDoctorId" required>
                        <c:forEach var="doc" items="${otherDoctors}">
                            <option value="${doc.doctorId}">${doc.name}</option>
                        </c:forEach>
                    </select>
                    <label>Lý do (tùy chọn)</label>
                    <textarea name="swapReason" rows="2" placeholder="Ví dụ: trùng lịch công tác..."></textarea>
                    <button type="submit" class="submit-btn">Gửi yêu cầu</button>
                </form>
            </div>
        </div>

        <div id="passModal" class="modal">
            <div class="modal-content">
                <span class="close-btn" data-close="passModal">&times;</span>
                <h3>Nhờ bác sĩ khác làm thay</h3>
                <form method="post" action="${pageContext.request.contextPath}/doctor/work-schedule">
                    <input type="hidden" name="action" value="pass">
                    <label>Ngày làm</label>
                    <select name="passDate" required>
                        <c:forEach var="day" items="${weekDays}">
                            <option value="${day.date}">${day.dayName} - ${day.date}</option>
                        </c:forEach>
                    </select>
                    <label>Ca làm</label>
                    <select name="passShiftId" required>
                        <option value="1">Ca sáng (08:00 – 12:00)</option>
                        <option value="2">Ca chiều (13:00 – 17:00)</option>
                        <option value="3">Ca tối (18:00 – 22:00)</option>
                    </select>
                    <label>Bác sĩ nhận ca</label>
                    <select name="passToDoctorId" required>
                        <c:forEach var="doc" items="${otherDoctors}">
                            <option value="${doc.doctorId}">${doc.name}</option>
                        </c:forEach>
                    </select>
                    <label>Lý do (tùy chọn)</label>
                    <textarea name="passReason" rows="2" placeholder="Ví dụ: có lịch phẫu thuật khác..."></textarea>
                    <button type="submit" class="submit-btn">Gửi yêu cầu</button>
                </form>
            </div>
        </div>


        <c:if test="${not empty upcomingSchedules}">
            <section class="section-card">
                <div class="section-title">
                    <i class="fas fa-clock"></i> Ca làm sắp tới (7 ngày)
                </div>
                <table>
                    <thead>
                        <tr>
                            <th>Ngày</th>
                            <th>Ca làm</th>
                            <th>Giờ</th>
                            <th>Địa điểm</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="schedule" items="${upcomingSchedules}">
                            <tr>
                                <td><fmt:formatDate value="${schedule.workDate}" pattern="dd/MM/yyyy (EEEE)" /></td>
                                <td><strong>${schedule.shiftName}</strong></td>
                                <td><fmt:formatDate value="${schedule.startTime}" pattern="HH:mm"/> – <fmt:formatDate value="${schedule.endTime}" pattern="HH:mm"/></td>
                                <td>${schedule.location}</td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </section>
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

const modalMap = {
    registerModal: document.getElementById('registerModal'),
    swapModal: document.getElementById('swapModal'),
    passModal: document.getElementById('passModal')
};

[{ id: 'openRegisterModal', modal: 'registerModal' },
 { id: 'openSwapModal', modal: 'swapModal' },
 { id: 'openPassModal', modal: 'passModal' }
].forEach(({ id, modal }) => {
    const trigger = document.getElementById(id);
    const target = modalMap[modal];
    if (trigger && target) {
        trigger.addEventListener('click', () => target.classList.add('show'));
    }
});

document.querySelectorAll('.close-btn').forEach(btn => {
    const target = modalMap[btn.getAttribute('data-close')];
    btn.addEventListener('click', () => {
        if (target) {
            target.classList.remove('show');
        }
    });
});

window.addEventListener('click', event => {
    Object.values(modalMap).forEach(modal => {
        if (modal && event.target === modal) {
            modal.classList.remove('show');
        }
    });
});
</script>

</body>
</html>
