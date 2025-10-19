<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Lịch làm việc của tôi | Pet4Care</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/staff.css">
    <style>
        .schedule-table {
            width: 100%;
            border-collapse: collapse;
            background: #fff;
            border-radius: 12px;
            overflow: hidden;
            box-shadow: 0 4px 8px rgba(0,0,0,0.1);
        }
        th, td {
            border-bottom: 1px solid #ddd;
            padding: 12px;
            text-align: center;
        }
        th {
            background: #ff9800;
            color: white;
        }
        tr:hover {
            background: #fdf3e6;
        }
        h2 {
            color: #333;
            margin-bottom: 16px;
        }
    </style>
</head>
<body>
<div class="staff-content">
    <h2>📅 Lịch làm việc của bạn</h2>
    <table class="schedule-table">
        <tr>
            <th>Ngày làm</th>
            <th>Giờ bắt đầu</th>
            <th>Giờ kết thúc</th>
            <th>Trạng thái</th>
            <th>Ghi chú</th>
        </tr>
        <c:forEach var="s" items="${scheduleList}">
            <tr>
                <td>${s.workDate}</td>
                <td>${s.startTime}</td>
                <td>${s.endTime}</td>
                <td>${s.status}</td>
                <td>${s.note}</td>
            </tr>
        </c:forEach>
        <c:if test="${empty scheduleList}">
            <tr><td colspan="5">Không có lịch làm việc nào được phân công.</td></tr>
        </c:if>
    </table>
</div>
</body>
</html>