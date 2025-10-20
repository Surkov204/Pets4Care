<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <title>Lịch làm việc & Đăng ký ca | Pet4Care</title>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/staff.css">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">

        <style>
            body {
                background: #f9fafb;
                font-family: 'Baloo 2', cursive;
            }

            .section-card {
                background: white;
                border-radius: 18px;
                box-shadow: 0 3px 8px rgba(0,0,0,0.08);
                padding: 2rem;
                margin: 2rem auto;
                width: 90%;
                max-width: 1100px;
            }

            .section-title {
                display: flex;
                align-items: center;
                justify-content: space-between;
                font-size: 1.4rem;
                font-weight: 700;
                color: #333;
                margin-bottom: 1rem;
            }

            .section-title i {
                color: #0ab5b5;
            }

            .add-btn {
                background: linear-gradient(135deg, #0ab5b5, #f5a623);
                color: white;
                border: none;
                border-radius: 10px;
                padding: 0.5rem 1rem;
                font-weight: 600;
                cursor: pointer;
                transition: 0.2s;
            }
            .add-btn:hover {
                transform: translateY(-2px);
                opacity: 0.9;
            }

            .weekly-table {
                width: 100%;
                border-collapse: collapse;
                border-radius: 10px;
                overflow: hidden;
            }
            .weekly-table th {
                background: linear-gradient(135deg, #0ab5b5, #f5a623);
                color: white;
                padding: 1rem;
            }
            .weekly-table td {
                text-align: center;
                padding: 0.8rem;
                border-bottom: 1px solid #eee;
            }
            .registered {
                color: #008000;
                font-weight: 600;
            }
            tr:hover td {
                background: #fafafa;
            }

            /* Modal styles */
            .modal {
                display: none; /* Ẩn mặc định */
                position: fixed;
                z-index: 1000;
                left: 0;
                top: 0;
                width: 100%;
                height: 100%;
                background: rgba(0,0,0,0.4);
            }
            .modal-content {
                background: #fff;
                border-radius: 16px;
                width: 400px;
                margin: 10% auto;
                padding: 2rem;
                box-shadow: 0 3px 10px rgba(0,0,0,0.2);
                position: relative;
            }
            .close-btn {
                position: absolute;
                top: 10px;
                right: 15px;
                font-size: 22px;
                cursor: pointer;
                color: #666;
            }
            .close-btn:hover {
                color: #000;
            }

            .form-group {
                margin-bottom: 1rem;
                text-align: left;
            }
            label {
                font-weight: 600;
            }
            select {
                width: 100%;
                padding: 0.5rem;
                border-radius: 8px;
                border: 1px solid #ccc;
                margin-top: 0.3rem;
            }
            .submit-btn {
                background: linear-gradient(135deg, #0ab5b5, #f5a623);
                color: white;
                border: none;
                border-radius: 8px;
                padding: 0.6rem 1.2rem;
                font-weight: 600;
                width: 100%;
                cursor: pointer;
                transition: 0.2s;
            }
            .submit-btn:hover {
                opacity: 0.9;
            }
            .add-btn:hover {
                transform: translateY(-2px);
                opacity: 0.9;
                box-shadow: 0 4px 10px rgba(0,0,0,0.15);
            }
        </style>
    </head>

    <body>

        <!-- 🟢 BẢNG LỊCH LÀM VIỆC -->
        <div class="section-card">
            <div class="section-title" style="justify-content: space-between; align-items: center;">
                <div style="display:flex; align-items:center; gap:10px;">
                    <i class="fa-solid fa-calendar-week"></i>
                    <span>Lịch làm việc</span>
                </div>

                <div style="display:flex; align-items:center; gap:15px;">
                    <form method="get" action="${pageContext.request.contextPath}/staff/mySchedule" style="display:inline;">
                        <input type="hidden" name="weekOffset" value="${weekOffset - 1}">
                        <button type="submit" class="add-btn">⟵</button>
                    </form>

                    <strong>
                        Tuần: 
                        <fmt:formatDate value="${startOfWeek}" pattern="dd/MM/yyyy"/>
                        –
                        <fmt:formatDate value="${endOfWeek}" pattern="dd/MM/yyyy"/>
                    </strong>

                    <form method="get" action="${pageContext.request.contextPath}/staff/mySchedule" style="display:inline;">
                        <input type="hidden" name="weekOffset" value="${weekOffset + 1}">
                        <button type="submit" class="add-btn">⟶</button>
                    </form>
                </div>
            </div>

            <table class="weekly-table">
                <thead>
                    <tr>
                        <th>Thứ</th>
                        <th>Ca sáng (8h–12h)</th>
                        <th>Ca chiều (13h–17h)</th>
                        <th>Ca tối (18h–22h)</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="day" items="${weekDays}">
                        <tr>
                            <td>
                                ${day.dayName}<br>
                                <small>${fn:substring(day.date, 8, 10)}/${fn:substring(day.date, 5, 7)}/${fn:substring(day.date, 0, 4)}</small>
                            </td>
                            <td><c:if test="${day.registeredShifts.contains('1')}">✅ 8:00 - 12:00</c:if></td>
                            <td><c:if test="${day.registeredShifts.contains('2')}">✅ 13:00 - 17:00</c:if></td>
                            <td><c:if test="${day.registeredShifts.contains('3')}">✅ 18:00 - 22:00</c:if></td>
                            </tr>
                    </c:forEach>
                </tbody>
            </table>
            <c:if test="${weekOffset == 0}">
                <div style="display:flex; justify-content:center; gap:20px; margin-top:2rem;">
                    <button class="add-btn" id="openModalBtn">
                        <i class="fa-solid fa-plus"></i> Đăng ký ca mới
                    </button>
                    <button class="add-btn" id="openCancelModalBtn"
                            style="background:linear-gradient(135deg,#e74c3c,#f39c12);">
                        <i class="fa-solid fa-trash"></i> Xem & Hủy ca
                    </button>
                </div>
            </c:if>           
        </div>


        <!-- 🟢 MODAL FORM ĐĂNG KÝ CA -->
        <div id="registerModal" class="modal">
            <div class="modal-content">
                <span class="close-btn" id="closeModalBtn">&times;</span>
                <h3 style="text-align:center; color:#0ab5b5;">Đăng ký ca làm</h3>
                <form method="post" action="${pageContext.request.contextPath}/staff/mySchedule">
                    <input type="hidden" name="action" value="register">

                    <div class="form-group">
                        <label for="daySelect">Chọn ngày:</label>
                        <select name="day" id="daySelect" required>
                            <c:forEach var="day" items="${weekDays}">

                                <option value="${day.date}">
                                    ${day.dayName} - 
                                    ${fn:substring(day.date, 8, 10)}/${fn:substring(day.date, 5, 7)}/${fn:substring(day.date, 0, 4)}
                                </option>
                            </c:forEach>
                        </select>
                    </div>

                    <div class="form-group">
                        <label for="shiftSelect">Chọn ca:</label>
                        <select name="shift" id="shiftSelect" required>
                            <option value="morning">Ca sáng (8h–12h)</option>
                            <option value="afternoon">Ca chiều (13h–17h)</option>
                            <option value="evening">Ca tối (18h–22h)</option>
                        </select>
                    </div>

                    <button type="submit" class="submit-btn">Xác nhận đăng ký</button>
                </form>
            </div>
        </div>

        <!-- 🟣 MODAL XEM & HỦY CA -->
        <div id="cancelModal" class="modal">
            <div class="modal-content" style="max-width:600px;">
                <span class="close-btn" id="closeCancelModalBtn">&times;</span>
                <h3 style="text-align:center; color:#e74c3c;">Danh sách ca đã đăng ký</h3>

                <form method="post" action="${pageContext.request.contextPath}/staff/mySchedule">
                    <input type="hidden" name="action" value="cancelMultiple">

                    <table class="weekly-table" style="margin-top:1rem;">
                        <thead>
                            <tr>
                                <th></th>
                                <th>Ngày</th>
                                <th>Ca</th>
                                <th>Giờ</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="day" items="${weekDays}">
                                <c:if test="${not empty day.registeredShifts}">
                                    <c:forEach var="shiftId" items="${day.registeredShifts}">
                                        <tr>
                                            <td><input type="checkbox" name="cancelItems"
                                                       value="${day.date}|${shiftId}">
                                            <td>${fn:substring(day.date, 8, 10)}/${fn:substring(day.date, 5, 7)}</td>
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
                                </c:if>
                            </c:forEach>
                        </tbody>
                    </table>

                    <button type="submit" class="submit-btn" style="margin-top:1rem;">
                        Hủy các ca đã chọn
                    </button>
                </form>
            </div>
        </div>

        <script>
            const modal = document.getElementById("registerModal");
            const openModalBtn = document.getElementById("openModalBtn");
            const closeModalBtn = document.getElementById("closeModalBtn");

            openModalBtn.onclick = () => modal.style.display = "block";
            closeModalBtn.onclick = () => modal.style.display = "none";
            window.onclick = (event) => {
                if (event.target === modal)
                    modal.style.display = "none";
            };
            const cancelModal = document.getElementById("cancelModal");
            const openCancelModalBtn = document.getElementById("openCancelModalBtn");
            const closeCancelModalBtn = document.getElementById("closeCancelModalBtn");

            if (openCancelModalBtn) {
                openCancelModalBtn.onclick = () => cancelModal.style.display = "block";
                closeCancelModalBtn.onclick = () => cancelModal.style.display = "none";
                window.onclick = (e) => {
                    if (e.target === cancelModal)
                        cancelModal.style.display = "none";
                };
            }
        </script>

    </body>
</html>
