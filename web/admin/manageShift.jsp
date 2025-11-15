<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản lý ca làm việc | Pet4Care Admin</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin.css">
    <style>
        body { background: #fafafa; font-family: Arial; }
        table { border-collapse: collapse; width: 100%; background: white; box-shadow: 0 2px 8px rgba(0,0,0,0.1); }
        th, td { padding: 10px; text-align: center; border-bottom: 1px solid #ddd; }
        th { background: #ff9800; color: white; }
        tr:hover { background-color: #fff3e0; }
        form { margin: 20px auto; background: white; padding: 20px; border-radius: 8px; max-width: 600px; }
        input { width: 100%; padding: 8px; margin: 5px 0; border: 1px solid #ccc; border-radius: 4px; }
        button { background: #ff9800; border: none; padding: 10px 16px; color: white; border-radius: 6px; cursor: pointer; }
        button:hover { background: #e68900; }
        .action-btn { margin: 0 5px; text-decoration: none; color: #007bff; }
    </style>
</head>
<body>

<h2>📋 Danh sách ca làm việc</h2>
<a href="${pageContext.request.contextPath}/shift?action=new"><button>➕ Thêm ca làm</button></a>
<br><br>

<table>
    <tr>
        <th>ID</th><th>Mã ca</th><th>Tên ca</th><th>Bắt đầu</th><th>Kết thúc</th><th>Nghỉ (phút)</th><th>Vị trí</th><th>Thao tác</th>
    </tr>
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
                <a href="${pageContext.request.contextPath}/shift?action=edit&id=${s.shiftID}" class="action-btn">✏️ Sửa</a>
                <a href="${pageContext.request.contextPath}/shift?action=delete&id=${s.shiftID}" class="action-btn" onclick="return confirm('Xóa ca này?')">🗑️ Xóa</a>
            </td>
        </tr>
    </c:forEach>
</table>

</body>
</html>
