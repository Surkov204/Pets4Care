<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Yêu cầu đổi ca | Quản trị</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin.css">
    <style>
        body { background: #fff8e1; font-family: Arial; }
        table { border-collapse: collapse; width: 100%; background: white; }
        th, td { padding: 10px; text-align: center; border-bottom: 1px solid #ddd; }
        th { background: #ff9800; color: white; }
        tr:hover { background: #fff3e0; }
        .btn { padding: 6px 10px; border-radius: 6px; text-decoration: none; color: white; }
        .approve { background: #4caf50; }
        .deny { background: #f44336; }
    </style>
</head>
<body>

<h2>📨 Danh sách yêu cầu đổi ca</h2>
<table>
    <tr>
        <th>ID</th>
        <th>Nhân viên</th>
        <th>Loại</th>
        <th>Ngày</th>
        <th>Từ ca</th>
        <th>Đến ca</th>
        <th>Lý do</th>
        <th>Trạng thái</th>
        <th>Duyệt</th>
    </tr>
    <c:forEach var="r" items="${requestList}">
        <tr>
            <td>${r.requestID}</td>
            <td>${r.employeeID}</td>
            <td>${r.type}</td>
            <td>${r.targetDate}</td>
            <td>${r.fromShiftID}</td>
            <td>${r.toShiftID}</td>
            <td>${r.reason}</td>
            <td>${r.status}</td>
            <td>
                <a href="${pageContext.request.contextPath}/shift-request?action=approve&id=${r.requestID}" class="btn approve">✔️ Duyệt</a>
                <a href="${pageContext.request.contextPath}/shift-request?action=deny&id=${r.requestID}" class="btn deny">❌ Từ chối</a>
            </td>
        </tr>
    </c:forEach>
</table>

</body>
</html>
