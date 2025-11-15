<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <title>Yêu cầu ca làm hoặc nhờ làm thay | Quản trị</title>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin.css">
        <style>
            body {
                background: #fff8e1;
                font-family: Arial, sans-serif;
            }
            h2 {
                text-align: center;
                margin: 20px 0;
                color: #ff9800;
            }
            table {
                border-collapse: collapse;
                width: 100%;
                background: white;
                border-radius: 10px;
                overflow: hidden;
            }
            th, td {
                padding: 10px;
                text-align: center;
                border-bottom: 1px solid #ddd;
            }
            th {
                background: #ff9800;
                color: white;
            }
            tr:hover {
                background: #fff3e0;
            }
            .btn {
                padding: 6px 10px;
                border-radius: 6px;
                text-decoration: none;
                color: white;
            }
            .approve {
                background: #4caf50;
            }
            .deny {
                background: #f44336;
            }
            .swap {
                color: #2196F3;
                font-weight: bold;
            }
            .pass {
                color: #9C27B0;
                font-weight: bold;
            }
        </style>
    </head>
    <body>

        <h2>📨 Danh sách yêu cầu đổi / làm thay</h2>

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

                        <!-- Loại yêu cầu -->
                        <td>
                            <c:choose>
                                <c:when test="${r.type eq 'Leave'}">
                                    <span class="pass">Nhờ làm thay</span>
                                </c:when>
                                <c:when test="${r.type eq 'DoctorPass'}">
                                    <span class="pass">Bác sĩ nhờ làm thay</span>
                                </c:when>
                                <c:when test="${r.type eq 'DoctorCancel'}">
                                    <span class="pass">Bác sĩ hủy ca</span>
                                </c:when>
                                <c:when test="${r.type eq 'DoctorRegister'}">
                                    <span class="swap">Bác sĩ đăng ký ca</span>
                                </c:when>
                                <c:when test="${r.type eq 'Cancel'}">
                                    <span class="pass">Hủy ca</span>
                                </c:when>
                                <c:when test="${r.type eq 'DoctorSwap'}">
                                    <span class="swap">Bác sĩ đổi ca</span>
                                </c:when>
                                <c:otherwise>
                                    <span class="swap">Đổi ca</span>
                                </c:otherwise>
                            </c:choose>
                        </td>

                        <!-- Ngày -->
                        <td>
                            <c:choose>
                                <c:when test="${r.type eq 'Leave' || r.type eq 'DoctorPass' || r.type eq 'DoctorCancel' || r.type eq 'DoctorRegister'}">
                                    ${r.fromDate}
                                </c:when>
                                <c:otherwise>
                                    ${r.fromDate} → ${r.toDate}
                                </c:otherwise>
                            </c:choose>
                        </td>

                        <!-- Từ ca / Đến ca -->
                        <td>${r.fromShiftID}</td>
                        <td>
                            <c:choose>
                                <c:when test="${r.type eq 'Leave' || r.type eq 'DoctorPass' || r.type eq 'DoctorCancel' || r.type eq 'DoctorRegister'}">
                                    <span style="color:#999;">—</span>
                                </c:when>
                                <c:otherwise>
                                    ${r.toShiftID}
                                </c:otherwise>
                            </c:choose>
                        </td>

                        <!-- Lý do -->
                        <td>${r.reason}</td>

                        <!-- Trạng thái màu -->
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

                        <!-- Nút thao tác -->
                        <td>
                            <c:choose>
                                <c:when test="${r.status eq 'Pending' || r.status eq 'AcceptedByTo'}">
                                    <a href="${pageContext.request.contextPath}/admin/approveShiftRequest?id=${r.requestID}"
                                       class="btn approve">✔️ Duyệt</a>
                                    <a href="${pageContext.request.contextPath}/admin/rejectShiftRequest?id=${r.requestID}"
                                       class="btn deny">❌ Từ chối</a>
                                </c:when>
                                <c:otherwise>
                                    <span style="color:#999;">Đã xử lý</span>
                                </c:otherwise>
                            </c:choose>
                        </td>
                    </tr>
                </c:forEach>
            </tbody>
        </table>

    </body>
</html>