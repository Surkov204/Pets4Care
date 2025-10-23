<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <title>Lịch làm việc | Pet4Care</title>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
        <style>
            body {
                background: #f8fafc;
                font-family: 'Poppins', sans-serif;
                color: #333;
            }

            /* CARD */
            .section-card {
                background: #fff;
                border-radius: 20px;
                box-shadow: 0 2px 10px rgba(0,0,0,0.05);
                padding: 2rem;
                margin: 2rem auto;
                width: 90%;
                max-width: 1100px;
            }

            /* TITLE */
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

            /* WEEK NAV */
            .week-nav {
                display: flex;
                justify-content: space-between;
                align-items: center;
                margin-bottom: 1rem;
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

            .btn-group {
                display: flex;
                justify-content: center;
                gap: 10px;
                margin-top: 1.5rem;
            }

            /* TABLES */
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

            /* ===== Ô lịch làm việc ===== */
            .work-schedule-table td {
                border: none !important;
                padding: 5px !important;
            }

            .schedule-cell {
                border-radius: 10px;
                transition: 0.2s ease;
                text-align: center;
                padding: 10px;
                min-height: 90px;
            }

            .schedule-cell.has-staff {
                background: #e6f8ec;
                border: 2px solid #8ed6a8;
                box-shadow: 0 2px 5px rgba(0, 128, 0, 0.05);
            }

            .schedule-cell.no-staff {
                background: #f1f3f5;
                border: 2px solid #cfd4da;
            }

            .schedule-cell:hover {
                transform: scale(1.02);
                box-shadow: 0 3px 8px rgba(0,0,0,0.08);
            }

            .schedule-cell.has-staff:hover {
                background: #dbf7e6;
                border-color: #6dc790;
            }

            .schedule-cell.no-staff:hover {
                background: #e7eaec;
                border-color: #b4b9be;
            }

            .remain-label {
                display: inline-block;
                border-radius: 6px;
                padding: 4px 8px;
                font-size: 0.8rem;
                font-weight: 500;
                margin-bottom: 5px;
                background: #4b5563;
                color: #fff;
            }

            .remain-label.empty {
                background: #d1d5db;
                color: #374151;
            }

            .staff-name {
                background: #d1fae5;
                color: #065f46;
                border-radius: 6px;
                padding: 4px 8px;
                margin-top: 3px;
                font-weight: 500;
                display: inline-block;
            }

            .staff-name i {
                color: #10b981;
                margin-right: 5px;
            }

            body {
                background: #f8fafc;
                font-family: 'Poppins', sans-serif;
                color: #333;
            }

            /* MODAL */
            .modal {
                display: flex;
                justify-content: center;
                align-items: center;
                position: fixed;
                top: 50%;
                left: 50%;
                transform: translate(-50%, -50%);
                width: auto;
                height: auto;
                background: rgba(0, 0, 0, 0.3);
                backdrop-filter: blur(3px);
                z-index: 1000;
            }

            /* FORM POPUP */
            .modal-content {
                background: #fff;
                border-radius: 18px;
                width: 450px;
                padding: 2rem;
                box-shadow: 0 6px 24px rgba(0, 0, 0, 0.15);
                position: relative;
                animation: popIn 0.25s ease;
            }
            /* Cải thiện animation */
            @keyframes popIn {
                from {
                    transform: scale(0.9);
                    opacity: 0;
                }
                to {
                    transform: scale(1);
                    opacity: 1;
                }
            }

            /* Nút đóng */
            .close-btn {
                position: absolute;
                right: 16px;
                top: 10px;
                font-size: 20px;
                cursor: pointer;
                color: #777;
                transition: 0.2s;
            }

            .close-btn:hover {
                color: #000;
            }

            /* Tiêu đề modal */
            .modal-content h3 {
                text-align: center;
                font-size: 1.4rem;
                font-weight: 600;
                color: #2f3e46;
                margin-bottom: 1.5rem;
            }

            /* FORM */
            .modal-content form {
                display: flex;
                flex-direction: column;
                gap: 1rem;
            }

            /* Labeled inputs */
            .modal-content label {
                font-weight: 500;
                color: #374151;
                font-size: 1rem;
                margin-bottom: 0.5rem;
            }

            /* Định dạng các dropdowns */
            .modal-content select {
                width: 100%;
                padding: 10px 14px;
                border-radius: 10px;
                border: 1px solid #d1d5db;
                font-size: 1rem;
                background: #f9fafb;
                transition: 0.3s;
                margin-bottom: 1rem;
            }

            .modal-content select:focus {
                border-color: #4b5563;
                box-shadow: 0 0 0 2px #a6e3e9;
                outline: none;
            }

            /* Cải thiện nút */
            .submit-btn {
                background: linear-gradient(90deg, #a6e3e9, #f9e4d4);
                border: none;
                color: #2f3e46;
                border-radius: 12px;
                width: 100%;
                padding: 12px;
                font-weight: 600;
                cursor: pointer;
                font-size: 1.1rem;
                transition: 0.3s;
                margin-top: 1rem;
            }

            .submit-btn:hover {
                transform: translateY(-2px);
                box-shadow: 0 3px 8px rgba(0, 0, 0, 0.15);
                background: linear-gradient(90deg, #92dcd9, #fbd0b1);
            }

            /* Center the modal content */
            .centered {
                text-align: center;
            }
            .section-card table thead {
                position: relative;
                background: none !important;
            }

            .section-card table thead::before {
                content: "";
                position: absolute;
                inset: 0;
                background: linear-gradient(90deg, #A6E3E9 0%, #F9E4D4 100%);
                border-top-left-radius: 12px;
                border-top-right-radius: 12px;
                z-index: 0;
            }

            .section-card table thead tr th {
                position: relative;
                background: transparent !important;
                color: #2f3e46;
                font-weight: 600;
                padding: 12px;
                border: none;
                z-index: 1;
            }

            /* Giữ viền mềm mượt */
            .section-card table {
                border-collapse: collapse;
                border-radius: 12px;
                overflow: hidden;
            }
            /* ===== HEADER DẠNG LIỀN MẠCH THẬT ===== */
            .section-card table thead {
                position: relative;
                background: none !important;
            }

            .section-card table thead::before {
                content: "";
                position: absolute;
                inset: 0;
                background: linear-gradient(90deg, #A6E3E9 0%, #F9E4D4 100%);
                border-top-left-radius: 12px;
                border-top-right-radius: 12px;
                z-index: 0;
            }

            .section-card table thead tr th {
                position: relative;
                background: transparent !important;
                color: #2f3e46;
                font-weight: 600;
                padding: 12px;
                border: none;
                z-index: 1;
            }

            /* Giữ viền mềm mượt */
            .section-card table {
                border-collapse: collapse;
                border-radius: 12px;
                overflow: hidden;
            }

        </style>
    </head>
    <body>

        <!-- 🗓️ LỊCH CỦA TÔI -->
        <div class="section-card">
            <div class="section-title">
                <i class="fa-solid fa-calendar-week"></i> Lịch làm việc của tôi
            </div>

            <div class="week-nav">
                <form method="get" action="${pageContext.request.contextPath}/staff/mySchedule">
                    <input type="hidden" name="weekOffset" value="${weekOffset - 1}">
                    <button type="submit" class="btn">← Tuần trước</button>
                </form>

                <strong>
                    Tuần:
                    <fmt:formatDate value="${startOfWeek}" pattern="dd/MM/yyyy"/> –
                    <fmt:formatDate value="${endOfWeek}" pattern="dd/MM/yyyy"/>
                </strong>

                <form method="get" action="${pageContext.request.contextPath}/staff/mySchedule">
                    <input type="hidden" name="weekOffset" value="${weekOffset + 1}">
                    <button type="submit" class="btn">Tuần sau →</button>
                </form>
            </div>

            <table>
                <thead>
                    <tr>
                        <th>Thứ</th>
                        <th>Ca sáng (8h–12h)</th>
                        <th>Ca chiều (13h–17h)</th>
                        <th>Ca tối (18h–22h)</th>
                    </tr>
                </thead>
                <tbody>
                    <c:if test="${empty staffList}">
                    <p>Không có nhân viên trong danh sách.</p>
                </c:if>
                <c:forEach var="day" items="${weekDays}">
                    <tr>
                        <td>${day.dayName}<br>
                            <small>${fn:substring(day.date,8,10)}/${fn:substring(day.date,5,7)}</small>
                        </td>
                        <td><c:if test="${day.registeredShifts.contains('1')}">✅ 8:00–12:00</c:if></td>
                        <td><c:if test="${day.registeredShifts.contains('2')}">✅ 13:00–17:00</c:if></td>
                        <td><c:if test="${day.registeredShifts.contains('3')}">✅ 18:00–22:00</c:if></td>
                        </tr>
                </c:forEach>
                </tbody>
            </table>

            <div class="btn-group">
                <button class="btn" id="openModalBtn"><i class="fa-solid fa-plus"></i> Đăng ký ca</button>
                <button class="btn btn-danger" id="openCancelModalBtn"><i class="fa-solid fa-trash"></i> Hủy ca</button>
                <button class="btn" id="openSwapModalBtn">
                    <i class="fa-solid fa-repeat"></i> Yêu cầu đổi ca
                </button>
            </div>
        </div>

        <!-- 👥 LỊCH LÀM VIỆC CHUNG -->
        <div class="section-card">
            <div class="section-title centered">
                <i class="fa-solid fa-users"></i> Lịch làm việc chung của toàn bộ nhân viên
            </div>

            <table class="work-schedule-table">
                <thead>
                    <tr>
                        <th>Ca / Ngày</th>
                            <c:forEach var="day" items="${weekDays}">
                            <th>${day.dayName}<br>
                                <small>${fn:substring(day.date,8,10)}/${fn:substring(day.date,5,7)}</small>
                            </th>
                        </c:forEach>
                    </tr>
                </thead>
                <tbody>

                    <!-- 🕗 Ca sáng -->
                    <tr>
                        <td class="shift-label"><strong>Ca sáng</strong><br><small>08:00 – 12:00</small></td>
                            <c:forEach var="day" items="${weekDays}">
                                <c:set var="key" value="${day.date} - Ca sáng"/>
                                <c:set var="dayStaffList" value="${commonSchedule[key]}"/>
                                <c:set var="maxStaff" value="5"/>
                                <c:set var="registeredCount" value="${fn:length(dayStaffList)}"/>
                                <c:set var="remaining" value="${maxStaff - registeredCount}"/>

                            <td>
                                <div class="schedule-cell ${registeredCount > 0 ? 'has-staff' : 'no-staff'}">
                                    <c:choose>
                                        <c:when test="${registeredCount > 0}">
                                            <div class="remain-label">Còn thiếu ${remaining} nhân viên</div>
                                            <c:forEach var="name" items="${dayStaffList}">
                                                <div class="staff-name"><i class="fa-solid fa-user"></i> ${name}</div>
                                            </c:forEach>
                                        </c:when>
                                        <c:otherwise>
                                            <div class="remain-label empty">Chưa có nhân viên đăng ký</div>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </td>
                        </c:forEach>
                    </tr>

                    <!-- 🕐 Ca chiều -->
                    <tr>
                        <td class="shift-label"><strong>Ca chiều</strong><br><small>13:00 – 17:00</small></td>
                            <c:forEach var="day" items="${weekDays}">
                                <c:set var="key" value="${day.date} - Ca chiều"/>
                                <c:set var="dayStaffList" value="${commonSchedule[key]}"/>
                                <c:set var="maxStaff" value="5"/>
                                <c:set var="registeredCount" value="${fn:length(dayStaffList)}"/>
                                <c:set var="remaining" value="${maxStaff - registeredCount}"/>

                            <td>
                                <div class="schedule-cell ${registeredCount > 0 ? 'has-staff' : 'no-staff'}">
                                    <c:choose>
                                        <c:when test="${registeredCount > 0}">
                                            <div class="remain-label">Còn thiếu ${remaining} nhân viên</div>
                                            <c:forEach var="name" items="${dayStaffList}">
                                                <div class="staff-name"><i class="fa-solid fa-user"></i> ${name}</div>
                                            </c:forEach>
                                        </c:when>
                                        <c:otherwise>
                                            <div class="remain-label empty">Chưa có nhân viên đăng ký</div>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </td>
                        </c:forEach>
                    </tr>

                    <!-- 🌙 Ca tối -->
                    <tr>
                        <td class="shift-label"><strong>Ca tối</strong><br><small>18:00 – 22:00</small></td>
                            <c:forEach var="day" items="${weekDays}">
                                <c:set var="key" value="${day.date} - Ca tối"/>
                                <c:set var="dayStaffList" value="${commonSchedule[key]}"/>
                                <c:set var="maxStaff" value="5"/>
                                <c:set var="registeredCount" value="${fn:length(dayStaffList)}"/>
                                <c:set var="remaining" value="${maxStaff - registeredCount}"/>

                            <td>
                                <div class="schedule-cell ${registeredCount > 0 ? 'has-staff' : 'no-staff'}">
                                    <c:choose>
                                        <c:when test="${registeredCount > 0}">
                                            <div class="remain-label">Còn thiếu ${remaining} nhân viên</div>
                                            <c:forEach var="name" items="${dayStaffList}">
                                                <div class="staff-name"><i class="fa-solid fa-user"></i> ${name}</div>
                                            </c:forEach>
                                        </c:when>
                                        <c:otherwise>
                                            <div class="remain-label empty">Chưa có nhân viên đăng ký</div>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </td>
                        </c:forEach>
                    </tr>

                </tbody>
            </table>
        </div>

        <!-- 🔹 Modal đăng ký -->
        <div id="registerModal" class="modal">
            <div class="modal-content">
                <span class="close-btn" id="closeModalBtn">&times;</span>
                <h3 class="centered">Đăng ký ca làm</h3>
                <form method="post" action="${pageContext.request.contextPath}/staff/mySchedule">
                    <input type="hidden" name="action" value="register">

                    <label>Chọn ngày:</label>
                    <select name="day" required>
                        <c:forEach var="day" items="${weekDays}">
                            <option value="${day.date}">
                                ${day.dayName} - ${fn:substring(day.date,8,10)}/${fn:substring(day.date,5,7)}
                            </option>
                        </c:forEach>
                    </select>

                    <label>Chọn ca:</label>
                    <select name="shift" required>
                        <option value="morning">Ca sáng (8h–12h)</option>
                        <option value="afternoon">Ca chiều (13h–17h)</option>
                        <option value="evening">Ca tối (18h–22h)</option>
                    </select>

                    <button type="submit" class="submit-btn">Xác nhận</button>
                </form>
            </div>
        </div>

        <!-- 🔹 Modal hủy -->
        <div id="cancelModal" class="modal">
            <div class="modal-content" style="max-width:600px;">
                <span class="close-btn" id="closeCancelModalBtn">&times;</span>
                <h3 class="centered">Danh sách ca đã đăng ký</h3>
                <form method="post" action="${pageContext.request.contextPath}/staff/mySchedule">
                    <input type="hidden" name="action" value="cancelMultiple">
                    <table>
                        <thead><tr><th></th><th>Ngày</th><th>Ca</th><th>Giờ</th></tr></thead>
                        <tbody>
                            <c:forEach var="day" items="${weekDays}">
                                <c:forEach var="shiftId" items="${day.registeredShifts}">
                                    <tr>
                                        <td><input type="checkbox" name="cancelItems" value="${day.date}|${shiftId}"></td>
                                        <td>${fn:substring(day.date,8,10)}/${fn:substring(day.date,5,7)}</td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${shiftId eq '1'}">Ca sáng</c:when>
                                                <c:when test="${shiftId eq '2'}">Ca chiều</c:when>
                                                <c:when test="${shiftId eq '3'}">Ca tối</c:when>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${shiftId eq '1'}">8:00–12:00</c:when>
                                                <c:when test="${shiftId eq '2'}">13:00–17:00</c:when>
                                                <c:when test="${shiftId eq '3'}">18:00–22:00</c:when>
                                            </c:choose>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:forEach>
                        </tbody>
                    </table>
                    <button type="submit" class="submit-btn">Hủy các ca đã chọn</button>
                </form>
            </div>
        </div>

        <!-- 🔹 Modal đổi ca -->
        <div id="swapModal" class="modal">
            <div class="modal-content" style="max-width: 600px;">
                <span class="close-btn" id="closeSwapModalBtn">&times;</span>
                <h3 class="centered">Yêu cầu đổi ca</h3>

                <form method="post" action="${pageContext.request.contextPath}/staff/swapShift">
                    <input type="hidden" name="action" value="swap">

                    <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 1.5rem;">

                        <!-- 🕐 Ca cần đổi -->
                        <div style="flex: 1; text-align: center;">
                            <label style="font-weight: 600;">Ca cần đổi</label>
                            <div style="margin-top: 10px;">
                                <select name="fromDate" required style="width: 90%; padding: 10px; border-radius: 10px; border: 1px solid #ccc;">
                                    <c:forEach var="day" items="${weekDays}">
                                        <option value="${day.date}">
                                            ${day.dayName} - ${fn:substring(day.date,8,10)}/${fn:substring(day.date,5,7)}
                                        </option>
                                    </c:forEach>
                                </select>

                                <select name="fromShiftId" required style="width: 90%; padding: 10px; margin-top: 10px; border-radius: 10px; border: 1px solid #ccc;">
                                    <option value="1">Ca sáng (8h–12h)</option>
                                    <option value="2">Ca chiều (13h–17h)</option>
                                    <option value="3">Ca tối (18h–22h)</option>
                                </select>
                            </div>
                        </div>

                        <!-- ↔ Biểu tượng đổi -->
                        <div style="flex: 0 0 60px; text-align: center; font-size: 28px; color: #00bfa6;">
                            <i class="fa-solid fa-right-left"></i>
                        </div>

                        <!-- 🌙 Ca muốn đổi -->
                        <div style="flex: 1; text-align: center;">
                            <label style="font-weight: 600;">Ca muốn đổi</label>
                            <div style="margin-top: 10px;">
                                <select name="toDate" required style="width: 90%; padding: 10px; border-radius: 10px; border: 1px solid #ccc;">
                                    <c:forEach var="day" items="${weekDays}">
                                        <option value="${day.date}">
                                            ${day.dayName} - ${fn:substring(day.date,8,10)}/${fn:substring(day.date,5,7)}
                                        </option>
                                    </c:forEach>
                                </select>

                                <select name="toShiftId" required style="width: 90%; padding: 10px; margin-top: 10px; border-radius: 10px; border: 1px solid #ccc;">
                                    <option value="1">Ca sáng (8h–12h)</option>
                                    <option value="2">Ca chiều (13h–17h)</option>
                                    <option value="3">Ca tối (18h–22h)</option>
                                </select>
                            </div>
                        </div>
                    </div>

                    <!-- 👤 Chọn người cần đổi -->
                    <div style="text-align: center;">
                        <label style="font-weight: 600;">Chọn người cần đổi</label><br>
                        <select name="toStaffId" required style="width: 80%; padding: 10px; margin-top: 10px; border-radius: 10px; border: 1px solid #ccc;">
                            <c:forEach var="s" items="${staffList}">
                                <option value="${s.staffId}">${s.name}</option>
                            </c:forEach>
                        </select>
                    </div>

                    <div style="text-align: center; margin-top: 20px;">
                        <label>Lý do (tùy chọn):</label><br>
                        <textarea name="reason" rows="2" style="width: 80%; border-radius: 10px; border: 1px solid #ccc; padding: 10px;" placeholder="Ví dụ: bận công việc cá nhân, xin đổi ca..."></textarea>
                    </div>

                    <button type="submit" class="submit-btn" style="margin-top: 25px;">
                        <i class="fa-solid fa-paper-plane"></i> Gửi yêu cầu
                    </button>
                </form>
            </div>
        </div>


        <script>
            const regModal = document.getElementById("registerModal");
            const cancelModal = document.getElementById("cancelModal");
            const swapModal = document.getElementById("swapModal");

            document.getElementById("openModalBtn").onclick = () => regModal.style.display = "block";
            document.getElementById("closeModalBtn").onclick = () => regModal.style.display = "none";
            document.getElementById("openCancelModalBtn").onclick = () => cancelModal.style.display = "block";
            document.getElementById("closeCancelModalBtn").onclick = () => cancelModal.style.display = "none";
            document.getElementById("openSwapModalBtn").onclick = () => swapModal.style.display = "block";
            document.getElementById("closeSwapModalBtn").onclick = () => swapModal.style.display = "none";
            window.onclick = (e) => {
                if (e.target === regModal)
                    regModal.style.display = "none";
                if (e.target === cancelModal)
                    cancelModal.style.display = "none";
                if (e.target === swapModal)
                    swapModal.style.display = "none";
            };
            window.onload = function () {
                regModal.style.display = "none";
                cancelModal.style.display = "none";
                swapModal.style.display = "none";
            };
        </script>
    </body>
</html>
