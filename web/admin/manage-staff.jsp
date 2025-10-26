<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.Admin, model.Staff, model.ShiftRequest, java.util.List" %>
<%@ page import="dao.ShiftRequestDAO" %>
<%@ page import="dao.WorkScheduleDAO" %>
<%@ page import="model.WorkSchedule" %>
<%@ page import="java.util.List" %>
<%@ page import="dao.ShiftDAO" %>
<%@ page import="model.Shift" %>
<%@ page import="java.util.List" %>

<%@ taglib uri="jakarta.tags.core" prefix="c" %>

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
    List<Staff> staffList = (List<Staff>) request.getAttribute("staffList");
    if (staffList == null) {
        response.sendRedirect("manage-staff");
        return;
    }

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
                    <button class="active" onclick="showTab('info', this)">👔 Thông tin nhân viên</button>
                    <button onclick="showTab('shift', this)">⏰ Ca làm việc</button>
                    <button onclick="showTab('schedule', this)">🗓️ Lịch làm việc</button>
                    <button onclick="showTab('request', this)">🔄 Yêu cầu đổi / làm thay</button>
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
                                <th>ID</th><th>Tên</th><th>Email</th><th>Vị trí</th><th>Ghi chú</th><th>Hành động</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% if (staffList != null && !staffList.isEmpty()) {
                                    for (Staff s : staffList) {%>
                            <tr>
                                <td><%= s.getStaffId()%></td>
                                <td><%= s.getName()%></td>
                                <td><%= s.getEmail()%></td>
                                <td><%= s.getPosition()%></td>
                                <td><%= s.getScheduleNote() != null ? s.getScheduleNote() : "-"%></td>
                                <td>
                                    <a href="view-staff?id=<%= s.getStaffId()%>" class="btn edit">✏️ Xem</a>
                                    <a href="delete-staff?id=<%= s.getStaffId()%>" class="btn delete" onclick="return confirm('Xóa nhân viên này?')">🗑️ Xóa</a>
                                </td>
                            </tr>
                            <% }
                            } else { %>
                            <tr><td colspan="6">Không có nhân viên nào.</td></tr>
                            <% }%>
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
                                            <c:when test="${r.type eq 'Leave'}">
                                                <span style="color:#999;">—</span>
                                            </c:when>
                                            <c:otherwise>${r.toShiftID}</c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>${r.reason}</td>
                                    <td style="
                                        color: ${r.status eq 'ApprovedByAdmin' ? '#4CAF50' :
                                                 (r.status eq 'Rejected' ? '#F44336' :
                                                 (r.status eq 'AcceptedByTo' ? '#2196F3' : '#FF9800'))};
                                        font-weight: bold;">
                                        ${r.status}
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${r.status eq 'Pending' || r.status eq 'AcceptedByTo'}">
                                                <a href="${pageContext.request.contextPath}/admin/approveShiftRequest?id=${r.requestID}"
                                                   class="btn approve">✔️ Duyệt</a>
                                                <a href="${pageContext.request.contextPath}/admin/rejectShiftRequest?id=${r.requestID}"
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
            </div>
        </div>

        <script>
            function showTab(name, el) {
                document.querySelectorAll('.tab-content').forEach(t => t.classList.remove('active'));
                document.querySelectorAll('.tab-buttons button').forEach(b => b.classList.remove('active'));
                document.getElementById('tab-' + name).classList.add('active');
                el.classList.add('active');
            }
        </script>
    </body>
</html>
