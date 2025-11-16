<%@page import="java.util.HashMap"%>
<%@page import="java.util.Map"%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.Admin, model.Staff, model.ShiftRequest, java.util.List" %>
<%@ page import="dao.ShiftRequestDAO" %>
<%@ page import="dao.WorkScheduleDAO" %>
<%@ page import="model.WorkSchedule" %>
<%@ page import="java.util.List" %>
<%@ page import="dao.ShiftDAO" %>
<%@ page import="model.Shift" %>
<%@ page import="java.util.List" %>
<%@ page import="dao.DoctorDAO" %>
<%@ page import="model.Doctor" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<%
    Admin admin = (Admin) session.getAttribute("admin");
    if (admin == null) {
        response.sendRedirect("../login.jsp");
        return;
    }
    ShiftDAO shiftDAO = new ShiftDAO();
    List<Shift> shiftList = shiftDAO.getAllShifts();
    request.setAttribute("shiftList", shiftList);

    WorkScheduleDAO scheduleDAO = new WorkScheduleDAO();
    List<WorkSchedule> scheduleList = scheduleDAO.getAllSchedules();
    request.setAttribute("scheduleList", scheduleList);

    ShiftRequestDAO reqDAO = new ShiftRequestDAO();
    List<ShiftRequest> requestList = reqDAO.getAllRequests();
    request.setAttribute("requestList", requestList);

    // Dữ liệu nhân viên (phần 1)
    DoctorDAO doctorDAO = new DoctorDAO();
    List<Doctor> doctorList = doctorDAO.getAllExcept(0);
    request.setAttribute("doctorList", doctorList);
    dao.StaffDAO sdao = new dao.StaffDAO();
    List<Staff> staffList = sdao.getAllStaff();
    request.setAttribute("staffList", staffList);
    Integer adminCount = (Integer) request.getAttribute("adminCount");
    Integer managerCount = (Integer) request.getAttribute("managerCount");
    Integer staffCount = (Integer) request.getAttribute("staffCount");

    if (adminCount == null) {
        adminCount = 0;
    }
    if (managerCount == null) {
        managerCount = 0;
    }
    if (staffCount == null)
        staffCount = 0;
%>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Quản lý nhân viên | PET TOY SHOP</title>
        <link rel="stylesheet" href="../css/homeStyle.css">
        <style>
            body {
                font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
                background: #f9fafb;
                color: #333;
                margin: 0;
            }
            .admin-layout {
                display: flex;
            }
            /* Sidebar */
            .admin-sidebar {
                width: 250px;
                background: linear-gradient(180deg, #5BC0EB, #4EA8DE);
                color: #fff;
                padding: 2rem 1.2rem;
                height: 100vh;
                position: fixed;
                left: 0;
                top: 0;
            }
            .admin-sidebar h2 {
                font-size: 1.4rem;
                font-family: 'Baloo 2', cursive;
                text-align: center;
                margin-bottom: 1.5rem;
            }
            .admin-sidebar ul {
                list-style: none;
                padding: 0;
            }
            .admin-sidebar li {
                margin: 1rem 0;
            }
            .admin-sidebar a {
                color: #eaf8ff;
                text-decoration: none;
                font-weight: 600;
                display: block;
                padding: 8px 12px;
                border-radius: 8px;
                transition: 0.3s;
            }
            .admin-sidebar a:hover,
            .admin-sidebar a.active {
                background: rgba(255,255,255,0.2);
            }
            .back-to-site {
                display: block;
                margin-top: 2rem;
                background: #FF9F1C;
                color: white;
                text-align: center;
                padding: 10px;
                border-radius: 8px;
                text-decoration: none;
            }

            /* Main content */
            .admin-main {
                flex: 1;
                margin-left: 250px;
                padding: 2rem;
            }

            .page-header h1 {
                font-size: 2rem;
                color: #0077b6;
                margin-bottom: 0.2rem;
            }

            .tab-buttons {
                display: flex;
                gap: 10px;
                margin: 20px 0;
                flex-wrap: wrap;
            }

            .tab-buttons button {
                border: none;
                padding: 10px 16px;
                border-radius: 20px;
                background: #e0f2fe;
                color: #0369a1;
                cursor: pointer;
                font-weight: 600;
                transition: 0.25s;
            }

            .tab-buttons button.active {
                background: linear-gradient(90deg, #5BC0EB, #4EA8DE);
                color: #fff;
                box-shadow: 0 3px 10px rgba(91,192,235,0.3);
            }

            .tab-content {
                display: none;
            }
            .tab-content.active {
                display: block;
                animation: fadeIn 0.3s ease-in-out;
            }

            @keyframes fadeIn {
                from {
                    opacity: 0;
                }
                to {
                    opacity: 1;
                }
            }

            table {
                width: 100%;
                border-collapse: collapse;
                background: #fff;
                border-radius: 10px;
                overflow: hidden;
                margin-top: 10px;
            }

            th {
                background: #ff9800;
                color: white;
                padding: 10px;
                text-align: center;
            }

            td {
                padding: 10px;
                text-align: center;
                border-bottom: 1px solid #ddd;
            }

            tr:hover {
                background: #fff3e0;
            }

            .btn {
                padding: 6px 10px;
                border-radius: 6px;
                text-decoration: none;
                color: white;
                font-weight: 600;
                display: inline-block;
                margin: 2px 4px;
                white-space: nowrap
            }
            .approve {
                background: #4caf50;
            }
            .deny {
                background: #f44336;
            }
            .edit {
                background: #2196F3;
            }
            .delete {
                background: #e53935;
            }
            .add {
                background: #ff9800;
            }

            .stat-boxes {
                display: flex;
                gap: 1rem;
                flex-wrap: wrap;
                margin: 15px 0;
            }

            .stat-box {
                background: #fff;
                border-radius: 10px;
                padding: 1rem;
                box-shadow: 0 2px 8px rgba(0,0,0,0.1);
                flex: 1 1 200px;
                text-align: center;
            }

            .stat-box h3 {
                margin-bottom: 5px;
                color: #0077b6;
            }
            .stat-box .number {
                font-size: 1.8rem;
                font-weight: bold;
                color: #333;
            }
        </style>
    </head>
    <body>
        <div class="admin-layout">
            <!-- Sidebar -->
            <aside class="admin-sidebar">
                <h2>📋 Quản lý nhân viên</h2>
                <ul>
                    <li><a href="#" class="active">👥 Quản lý nhân viên</a></li>
                    <li><a href="../admin/dashboard.jsp">🏠 Trang quản trị</a></li>
                </ul>
                <a href="../home" class="back-to-site">🏡 Về trang chủ</a>
            </aside>

            <!-- Main -->
            <div class="admin-main">
                <div class="page-header">
                    <h1>👥 Quản lý nhân viên</h1>
                    <p>Quản lý thông tin, ca làm, lịch làm việc và yêu cầu đổi ca</p>
                </div>

                <!-- Tabs -->
                <div class="tab-buttons">
                    <button onclick="showTab('info', this)">👔 Thông tin nhân viên</button>
                    <button onclick="showTab('shift', this)">⏰ Ca làm việc</button>
                    <button onclick="showTab('schedule', this)">🗓️ Danh sách các ca làm</button>
                    <button onclick="showTab('request', this)">🔄 Yêu cầu đổi / làm thay</button>
                    <button onclick="showTab('worktable', this)">📅 Bảng làm việc</button>
                </div>

                <!-- Tab 1: Thông tin nhân viên -->
                <div id="tab-info" class="tab-content active">

                    <div class="stat-boxes">
                        <div class="stat-box"><h3>👑 Admin</h3><div class="number"><%= adminCount%></div></div>
                        <div class="stat-box"><h3>👔 Quản lý</h3><div class="number"><%= managerCount%></div></div>
                        <div class="stat-box"><h3>👨‍💼 Nhân viên</h3><div class="number"><%= staffCount%></div></div>
                    </div>

                    <table>
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>Tên</th>
                                <th>Email</th>
                                <th>Vị trí</th>

                                <th>Lương/Giờ</th>
                                <th>Ghi chú</th>
                                <th>Hành động</th>

                                <th>Lương/Tháng</th>
                                <th>Ca chuẩn</th>
                                <th>Hành động</th>
                            </tr>
                        </thead>

                        <tbody>
                            <%
                                if (staffList != null && !staffList.isEmpty()) {

                                    dao.StaffSalaryDAO salaryDAO = new dao.StaffSalaryDAO();

                                    for (Staff s : staffList) {
                                        Double rate = salaryDAO.getHourlyRate(s.getStaffId());
                                        Double base = salaryDAO.getMonthlyBaseSalary(s.getStaffId());
                                        Integer standardShifts = salaryDAO.getStandardShifts(s.getStaffId());
                            %>

                            <tr>
                                <td><%= s.getStaffId()%></td>
                                <td><%= s.getName()%></td>
                                <td><%= s.getEmail()%></td>
                                <td><%= s.getPosition()%></td>

                                <!-- Lương theo giờ -->
                                <td><%= rate != null ? String.format("%,.0f", rate) : "18000"%></td>

                                <!-- Ghi chú -->
                                <td><%= s.getScheduleNote() != null ? s.getScheduleNote() : "-"%></td>

                                <!-- Xem / Xóa -->
                                <td>
                                    <a href="view-staff?id=<%= s.getStaffId()%>" class="btn edit">✏️ Xem</a>
                                    <a href="delete-staff?id=<%= s.getStaffId()%>" class="btn delete"
                                       onclick="return confirm('Xóa nhân viên này?')">🗑️ Xóa</a>
                                </td>

                                <!-- Lương tháng -->
                                <td><%= base != null ? String.format("%,.0f", base) : "Chưa đặt"%></td>

                                <!-- Ca chuẩn -->
                                <td><%= standardShifts != null ? standardShifts : "-"%></td>

                                <!-- Nút mở modal -->
                                <td>
                                    <button class="btn approve"
                                            onclick="openSalaryModal(
                                            <%= s.getStaffId()%>,
                                                            '<%= base != null ? base : ""%>',
                                                            '<%= standardShifts != null ? standardShifts : ""%>'
                                                            )">
                                        💰 Lương tháng
                                    </button>
                                </td>

                            </tr>

                            <%
                                }
                            } else {
                            %>
                            <tr><td colspan="10">Không có nhân viên nào.</td></tr>
                            <% } %>
                        </tbody>
                    </table>

                </div>

                <!-- Tab 2: Ca làm việc -->
                <div id="tab-shift" class="tab-content">
                    <h2>📋 Danh sách ca làm việc</h2>
                    <a href="${pageContext.request.contextPath}/shift?action=new">
                        <button>➕ Thêm ca làm</button>
                    </a>
                    <br><br>

                    <table>
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>Mã ca</th>
                                <th>Tên ca</th>
                                <th>Bắt đầu</th>
                                <th>Kết thúc</th>
                                <th>Nghỉ (phút)</th>
                                <th>Vị trí</th>
                                <th>Thao tác</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="s" items="${shiftList}">
                                <tr>
                                    <td>${s.shiftID}</td>
                                    <td>${s.shiftCode}</td>
                                    <td>${s.shiftName}</td>
                                    <td>${s.startTime}</td>
                                    <td>${s.endTime}</td>
                                    <td>${s.breakMinutes}</td>
                                    <td>${s.location}</td>
                                    <td>
                                        <a href="${pageContext.request.contextPath}/shift?action=edit&id=${s.shiftID}"
                                           class="btn edit">✏️ Sửa</a>
                                        <a href="${pageContext.request.contextPath}/shift?action=delete&id=${s.shiftID}"
                                           class="btn delete"
                                           onclick="return confirm('Xóa ca này?')">🗑️ Xóa</a>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>

                <!-- Tab 3: Lịch làm việc -->
                <div id="tab-schedule" class="tab-content">
                    <h2>🗓️ Lịch làm việc</h2>
                    <table>
                        <tr>
                            <th>ID</th>
                            <th>Bác sĩ</th>
                            <th>Nhân viên</th>
                            <th>Ngày</th>
                            <th>Giờ bắt đầu</th>
                            <th>Giờ kết thúc</th>
                            <th>Trạng thái</th>
                            <th>Ghi chú</th>
                            <th>Hành động</th>
                        </tr>
                        <c:forEach var="w" items="${scheduleList}">
                            <tr>
                                <td>${w.scheduleId}</td>
                                <td>${w.doctorId}</td>
                                <td>${w.staffId}</td>
                                <td>${w.workDate}</td>
                                <td>${w.startTime}</td>
                                <td>${w.endTime}</td>
                                <td>${w.status}</td>
                                <td>${w.note}</td>
                                <td>
                                    <a href="${pageContext.request.contextPath}/schedule?action=delete&id=${w.scheduleId}" 
                                       onclick="return confirm('Xóa lịch này?')">🗑️ Xóa</a>
                                </td>
                            </tr>
                        </c:forEach>
                    </table>
                </div>

                <!-- Tab 4: Yêu cầu đổi / làm thay -->
                <div id="tab-request" class="tab-content">
                    <h2>🔄 Yêu cầu đổi / làm thay</h2>
                    <table>
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>Nhân viên yêu cầu</th>
                                <th>Người liên quan</th>
                                <th>Loại</th>
                                <th>Ngày</th>
                                <th>Từ ca</th>
                                <th>Đến ca</th>
                                <th>Lý do</th>
                                <th>Trạng thái</th>
                                <th>Thao tác</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="r" items="${requestList}">
                                <tr>
                                    <td>${r.requestID}</td>
                                    <td>${r.employeeID}</td>
                                    <td>${r.toStaffID}</td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${r.type eq 'Leave'}">
                                                <span style="color:#9C27B0;font-weight:bold;">Nhờ làm thay</span>
                                            </c:when>
                                            <c:when test="${r.type eq 'Cancel'}">
                                                <span style="color:#FF5722;font-weight:bold;">Hủy ca</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span style="color:#2196F3;font-weight:bold;">Đổi ca</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${r.type eq 'Leave'}">${r.fromDate}</c:when>
                                            <c:otherwise>${r.fromDate} → ${r.toDate}</c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>${r.fromShiftID}</td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${r.type eq 'Leave' || r.type eq 'Cancel'}">
                                                <span style="color:#999;">—</span>
                                            </c:when>
                                            <c:otherwise>${r.toShiftID}</c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>${r.reason}</td>
                                    <td style="
                                        color: ${r.status eq 'ApprovedByAdmin' or r.status eq 'Approved' ? '#4CAF50' :
                                                 (r.status eq 'Rejected' ? '#F44336' :
                                                 (r.status eq 'N.A' ? '#2196F3' : '#FF9800'))};
                                        font-weight: bold;">
                                        <c:choose>
                                            <c:when test="${r.status eq 'ApprovedByAdmin'}">Approved</c:when>
                                            <c:otherwise>${r.status}</c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${r.status eq 'Pending' || r.status eq 'AcceptedByTo'}">
                                                <a href="${pageContext.request.contextPath}/admin/approveShiftRequest?id=${r.requestID}"
                                                   class="btn approve">✔️ Duyệt</a>
                                                <a href="${pageContext.request.contextPath}/admin/approveShiftRequest?id=${r.requestID}&action=reject"
                                                   class="btn deny">❌ Từ chối</a>

                                            </c:when>
                                            <c:otherwise><span style="color:#999;">Đã xử lý</span></c:otherwise>
                                        </c:choose>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
                <!-- Tab 5: Bảng làm việc -->
                <div id="tab-worktable" class="tab-content">
                    <%
                        dao.WorkScheduleDAO wsDao = new dao.WorkScheduleDAO();
                        dao.StaffDAO staffDAO = new dao.StaffDAO();
                        Map<Integer, String> staffNameCache = new HashMap<>();
                        for (model.Staff st : staffDAO.getAllStaff()) {
                            staffNameCache.put(st.getStaffId(), st.getName());
                        }
                        Map<Integer, String> doctorNameCache = new HashMap<>();
                        for (model.Doctor d : doctorDAO.getAllExcept(0)) {
                            doctorNameCache.put(d.getDoctorId(), d.getName());
                        }
                        int weekOffset = 0;
                        String offsetStr = request.getParameter("weekOffset");
                        if (offsetStr != null) {
                            try {
                                weekOffset = Integer.parseInt(offsetStr);
                            } catch (Exception e) {
                            }
                        }

                        java.time.LocalDate today = java.time.LocalDate.now();
                        java.time.LocalDate monday = today.with(java.time.DayOfWeek.MONDAY).plusWeeks(weekOffset);

                        java.time.LocalDate startWeek = monday;
                        java.time.LocalDate endWeek = monday.plusDays(6);

                        // 🔥 load lịch tuần này
                        List<model.WorkSchedule> allSchedules = wsDao.getSchedulesInRange(startWeek, endWeek);

                        // 🔥 load ca làm (dịch lên đây)
                        List<model.Shift> shifts = shiftDAO.getAllShifts();

                        // 🔥 load 7 ngày
                        java.util.List<java.time.LocalDate> days = new java.util.ArrayList<>();
                        for (int i = 0; i < 7; i++) {
                            days.add(monday.plusDays(i));
                        }
                    %>
                    <h2 style="color:#0077b6; margin-bottom:12px;">
                        📅 Lịch làm việc chung của toàn bộ nhân viên
                    </h2>

                    <style>
                        /* ====== BẢNG LỊCH LÀM ====== */
                        .shift-grid {
                            width: 100%;
                            border-collapse: separate;
                            border-spacing: 0;
                            border-radius: 10px;
                            overflow: hidden;
                            background: #fff;
                            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
                        }
                        .shift-grid thead tr {
                            background: linear-gradient(90deg, #4EA8DE, #5BC0EB);
                        }
                        .shift-grid th {
                            color: #fff;
                            font-weight: 600;
                            text-align: center;
                            padding: 12px;
                            border: none;
                            font-size: 0.95rem;
                        }
                        .shift-grid th:first-child {
                            border-top-left-radius: 10px;
                        }
                        .shift-grid th:last-child {
                            border-top-right-radius: 10px;
                        }

                        .shift-grid td {
                            border-top: 1px solid #e0e0e0;
                            border-right: 1px solid #e0e0e0;
                            text-align: center;
                            vertical-align: top;
                            padding: 12px 10px;
                        }
                        .shift-grid td:last-child {
                            border-right: none;
                        }
                        .shift-grid td:hover {
                            background: #f9fafc;
                            transition: 0.2s;
                        }

                        /* ====== NHÃN CA ====== */
                        .shift-label {
                            background: #f1f9ff;
                            color: #0077b6;
                            font-weight: 700;
                            font-size: 1rem;
                            width: 140px;
                            border-right: 2px solid #e0e0e0;
                        }
                        .shift-label small {
                            display: block;
                            color: #555;
                            font-weight: 500;
                            font-size: 0.85rem;
                            margin-top: 3px;
                        }

                        /* ====== THẺ NHÂN VIÊN ====== */
                        .shift-card {
                            background: #e6fffa;
                            border-radius: 10px;
                            padding: 6px 8px;
                            color: #02735e;
                            font-weight: 600;
                            box-shadow: 0 1px 3px rgba(0,0,0,0.1);
                            margin: 5px auto;
                            width: 90%;
                            display: flex;
                            align-items: center;
                            justify-content: space-between;
                        }

                        .shift-card button {
                            background: #ef5350;
                            border: none;
                            border-radius: 6px;
                            color: white;
                            font-size: 0.8rem;
                            padding: 2px 6px;
                            cursor: pointer;
                            transition: 0.2s;
                        }
                        .shift-card button:hover {
                            background: #d32f2f;
                        }

                        /* ====== THÔNG TIN PHỤ ====== */
                        .missing-info {
                            background: #1f2937;
                            color: #fff;
                            font-size: 0.8rem;
                            border-radius: 8px;
                            padding: 4px 6px;
                            display: inline-block;
                            margin-bottom: 6px;
                            box-shadow: 0 1px 2px rgba(0,0,0,0.1);
                        }
                        .empty-slot {
                            background: #f3f4f6;
                            color: #888;
                            border-radius: 8px;
                            padding: 12px;
                            font-style: italic;
                            font-weight: 500;
                            box-shadow: inset 0 1px 3px rgba(0,0,0,0.05);
                        }

                        /* ====== NÚT THÊM ====== */
                        .mini-btn {
                            background: #4caf50;
                            color: #fff;
                            border: none;
                            border-radius: 6px;
                            padding: 4px 8px;
                            margin-top: 8px;
                            font-weight: 600;
                            font-size: 0.8rem;
                            cursor: pointer;
                            transition: 0.2s;
                        }
                        .mini-btn:hover {
                            background: #43a047;
                        }

                        .modal {
                            display: none;
                            justify-content: center;
                            align-items: center;
                            position: fixed;
                            top: 0;
                            left: 0;
                            width: 100%;
                            height: 100%;
                            background: rgba(0,0,0,0.3);
                            z-index: 1000;
                        }
                        .modal-content {
                            background: #fff;
                            border-radius: 12px;
                            padding: 20px;
                            box-shadow: 0 3px 8px rgba(0,0,0,0.15);
                            width: 400px;
                            animation: fadeIn 0.3s ease;
                        }
                        @keyframes fadeIn {
                            from {
                                opacity: 0;
                                transform: scale(0.9);
                            }
                            to {
                                opacity: 1;
                                transform: scale(1);
                            }
                        }
                        .close-btn {
                            float: right;
                            font-size: 20px;
                            cursor: pointer;
                            color: #666;
                        }
                        .close-btn:hover {
                            color: #000;
                        }
                    </style>


                    <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:10px;">
                        <form method="get" style="margin:0;">
                            <input type="hidden" name="weekOffset" value="<%= weekOffset - 1%>">
                            <input type="hidden" name="tab" value="worktable"> <!-- thêm dòng này -->
                            <button type="submit" style="padding:6px 10px; border:none; background:#4EA8DE; color:white; border-radius:6px;">
                                ⬅️ Tuần trước
                            </button>
                        </form>

                        <form method="get" style="margin:0;">
                            <input type="hidden" name="weekOffset" value="<%= weekOffset + 1%>">
                            <input type="hidden" name="tab" value="worktable"> <!-- thêm dòng này -->
                            <button type="submit" style="padding:6px 10px; border:none; background:#4EA8DE; color:white; border-radius:6px;">
                                Tuần sau ➡️
                            </button>
                        </form>
                    </div>
                    <table class="shift-grid">
                        <thead>
                            <tr>
                                <th>Ca / Ngày</th>
                                    <% for (java.time.LocalDate d : days) {%>
                                <th>
                                    Thứ <%= d.getDayOfWeek().getValue()%><br>
                                    <%= d.format(java.time.format.DateTimeFormatter.ofPattern("dd/MM"))%>
                                </th>
                                <% } %>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (model.Shift shift : shifts) {%>
                            <tr>
                                <td class="shift-label">
                                    <%= shift.getStartTime().substring(0, 5)%> – <%= shift.getEndTime().substring(0, 5)%>
                                </td>
                                <% for (java.time.LocalDate d : days) {
                                        java.util.List<model.WorkSchedule> schedulesForSlot = new java.util.ArrayList<>();
                                        for (model.WorkSchedule ws : allSchedules) {
                                            if (ws.getWorkDate() != null
                                                    && ws.getWorkDate().toLocalDate().equals(d)
                                                    && ws.getShiftId() == shift.getShiftID()) {
                                                schedulesForSlot.add(ws);
                                            }
                                        }
                                %>
                                <td>
                                    <% if (!schedulesForSlot.isEmpty()) {%>
                                    <span class="missing-info">Còn thiếu <%= 5 - schedulesForSlot.size()%> nhân viên</span>
                                    <% for (model.WorkSchedule ws : schedulesForSlot) {%>
                                    <%
                                        String displayName = "Không rõ";

                                        if (ws.getStaffId() != null) {
                                            displayName = staffNameCache.get(ws.getStaffId());
                                        } else if (ws.getDoctorId() != null) {
                                            displayName = doctorNameCache.get(ws.getDoctorId());
                                        }
                                    %>

                                    <div class="shift-card">
                                        👤 <%= displayName%>
                                        <form method="post" action="${pageContext.request.contextPath}/admin/manageSchedule" style="display:inline;">
                                            <input type="hidden" name="action" value="unassign">
                                            <input type="hidden" name="scheduleId" value="<%= ws.getScheduleId()%>">
                                            <input type="hidden" name="weekOffset" value="<%= weekOffset%>">
                                            <button type="submit">✖</button>
                                        </form>
                                    </div>
                                    <% } %>
                                    <% } else { %>
                                    <div class="empty-slot">Chưa có nhân viên đăng ký</div>
                                    <% }%>
                                    <!-- Nút thêm -->
                                    <button class="mini-btn" onclick="openAssignModal('<%= d%>', '<%= shift.getShiftID()%>')">➕ Gán</button>
                                </td>
                                <% } %>
                            </tr>
                            <% }%>
                        </tbody>
                    </table>

                    <!-- Modal thêm nhân viên -->
                    <div id="assignModal" class="modal">
                        <div class="modal-content">
                            <span class="close-btn" onclick="closeAssignModal()">&times;</span>
                            <h3 style="text-align:center;">Gán nhân viên vào ca</h3>
                            <form method="post" action="${pageContext.request.contextPath}/admin/manageSchedule">
                                <input type="hidden" name="action" value="assign">
                                <input type="hidden" id="assignDate" name="date">
                                <input type="hidden" id="assignShiftId" name="shiftType">
                                <input type="hidden" name="weekOffset" value="<%= weekOffset%>">

                                <label>Chọn nhân viên:</label>
                                <label>Chọn người làm việc:</label>
                                <select name="personId" required>

                                    <!-- Nhân viên -->
                                    <optgroup label="Nhân viên">
                                        <c:forEach var="s" items="${staffList}">
                                            <option value="staff-${s.staffId}">${s.name}</option>
                                        </c:forEach>
                                    </optgroup>

                                    <!-- Bác sĩ -->
                                    <optgroup label="Bác sĩ">
                                        <c:forEach var="d" items="${doctorList}">
                                            <option value="doctor-${d.doctorId}">BS. ${d.name}</option>
                                        </c:forEach>
                                    </optgroup>

                                </select>

                                <button type="submit" class="mini-btn" style="width:100%;margin-top:10px;">Xác nhận</button>
                            </form>
                        </div>
                    </div>

                    <script>
                        function openAssignModal(date, shiftId) {
                            document.getElementById("assignDate").value = date;
                            document.getElementById("assignShiftId").value = shiftId;
                            document.getElementById("assignModal").style.display = "flex";
                        }
                        function closeAssignModal() {
                            document.getElementById("assignModal").style.display = "none";
                        }
                        window.onclick = function (e) {
                            const modal = document.getElementById("assignModal");
                            if (e.target === modal)
                                modal.style.display = "none";
                        }
                    </script>

                </div>
                <!-- ⚙️ QUYỀN ĐĂNG KÝ CA -->
                <%@ page import="dao.SystemSettingDAO" %>
                <%
                    dao.SystemSettingDAO settingDAO = new dao.SystemSettingDAO();
                    boolean canRegister = settingDAO.isShiftRegistrationEnabled();
                %>

                <div style="margin-top:25px; background:#fff; padding:20px; border-radius:10px; box-shadow:0 2px 8px rgba(0,0,0,0.05);">
                    <h3 style="color:#0077b6;">⚙️ Cấp quyền đăng ký ca cho nhân viên</h3>
                    <p>Cho phép nhân viên đăng ký ca làm việc cho tuần kế tiếp.</p>

                    <form method="post" action="${pageContext.request.contextPath}/admin/toggleShiftRegistration">
                        <input type="hidden" name="status" value="<%= canRegister ? "OFF" : "ON"%>">
                        <button type="submit"
                                style="background:<%= canRegister ? "#f44336" : "#4caf50"%>;
                                color:white; border:none; padding:10px 16px;
                                border-radius:8px; cursor:pointer; font-weight:600;">
                            <%= canRegister ? "🔒 Đang MỞ – Nhấn để TẮT" : "🔓 Đang TẮT – Nhấn để MỞ"%>
                        </button>
                    </form>


                    <p style="margin-top:10px; color:<%= canRegister ? "#4caf50" : "#f44336"%>; font-weight:600;">
                        Trạng thái hiện tại: <%= canRegister ? "ĐÃ MỞ đăng ký ca" : "ĐANG TẮT đăng ký ca"%>
                    </p>
                </div>

                <div id="salaryModal" class="modal">
                    <div class="modal-content" style="width:350px;">
                        <span class="close-btn" onclick="closeSalaryModal()">&times;</span>
                        <h3 style="text-align:center;">💰 Cập nhật lương tháng</h3>

                        <form id="salaryForm">
                            <input type="hidden" id="salaryStaffId" name="staffId">

                            <label>Lương cơ bản / tháng (₫):</label>
                            <input type="number" id="baseSalary" name="baseSalary" required min="3000000"
                                   style="width:100%; padding:8px; margin-top:6px;">

                            <label style="margin-top:10px;">Số ca chuẩn / tháng:</label>
                            <input type="number" id="standardShifts" name="standardShifts" required min="10" max="30"
                                   style="width:100%; padding:8px; margin-top:6px;">

                            <button type="submit" class="mini-btn" style="width:100%; margin-top:12px;">
                                💾 Lưu thay đổi
                            </button>
                        </form>
                    </div>
                </div>
            </div>
        </div>

        <script>
            function closeSalaryModal() {
                document.getElementById('salaryModal').style.display = 'none';
            }

            document.getElementById('salaryForm').addEventListener('submit', async (e) => {
                e.preventDefault();
                const formData = new URLSearchParams(new FormData(e.target)).toString();
                const res = await fetch('${pageContext.request.contextPath}/admin/updateSalary', {
                    method: 'POST',
                    headers: {'Content-Type': 'application/x-www-form-urlencoded'},
                    body: formData
                });
                const data = await res.json();
                alert(data.message);
                if (data.status === 'success')
                    window.location.reload();
            });
            function openSalaryModal(id, base, standardShifts) {
                document.getElementById('salaryStaffId').value = id;
                document.getElementById('baseSalary').value = base;
                document.getElementById('standardShifts').value = standardShifts;

                document.getElementById('salaryModal').style.display = 'flex';
            }

            function showTab(name, el) {
                document.querySelectorAll('.tab-content').forEach(t => t.classList.remove('active'));
                document.querySelectorAll('.tab-buttons button').forEach(b => b.classList.remove('active'));
                document.getElementById('tab-' + name).classList.add('active');
                el.classList.add('active');

                // Cập nhật URL để nhớ tab hiện tại
                const url = new URL(window.location);
                url.searchParams.set('tab', name);
                window.history.replaceState({}, '', url);
            }

// Khi load trang, tự mở đúng tab theo URL
            window.addEventListener('DOMContentLoaded', () => {
                const params = new URLSearchParams(window.location.search);
                const tab = params.get('tab') || 'info'; // nếu không có thì mặc định 'info'
                const tabContent = document.getElementById('tab-' + tab);
                const tabButton = document.querySelector(`.tab-buttons button[onclick*="${tab}"]`);

                // Reset lại tất cả rồi mở đúng tab
                document.querySelectorAll('.tab-content').forEach(t => t.classList.remove('active'));
                document.querySelectorAll('.tab-buttons button').forEach(b => b.classList.remove('active'));
                if (tabContent)
                    tabContent.classList.add('active');
                if (tabButton)
                    tabButton.classList.add('active');
            });
        </script>
    </body>
</html>
