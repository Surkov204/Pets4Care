<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản lý lịch làm việc | Pet4Care Admin</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin.css">
    <style>
        body { background: #fdf6ec; font-family: Arial; }
        h2 { color: #333; }
        table { border-collapse: collapse; width: 100%; background: white; box-shadow: 0 2px 8px rgba(0,0,0,0.1); }
        th, td { padding: 10px; text-align: center; border-bottom: 1px solid #ddd; }
        th { background: #ff9800; color: white; }
        tr:hover { background-color: #fff3e0; }
        button { background: #ff9800; border: none; padding: 10px 16px; color: white; border-radius: 6px; cursor: pointer; }
        button:hover { background: #e68900; }
    </style>
</head>
<body>

<h2>🗓️ Quản lý lịch làm việc</h2>
<a href="${pageContext.request.contextPath}/schedule?action=new"><button>➕ Thêm lịch làm việc</button></a>
<br><br>

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
                <a href="${pageContext.request.contextPath}/schedule?action=delete&id=${w.scheduleId}" onclick="return confirm('Xóa lịch này?')">🗑️ Xóa</a>
            </td>
        </tr>
    </c:forEach>
</table>

</body>
</html>
