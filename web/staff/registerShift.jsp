<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>📅 Đăng ký ca làm việc | Pet4Care</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/staff.css">
    <style>
        body { background: #fff8f0; font-family: Arial; }
        .calendar { display: grid; grid-template-columns: repeat(7, 1fr); gap: 10px; }
        .day-cell { background: white; border-radius: 8px; padding: 10px; box-shadow: 0 2px 6px rgba(0,0,0,0.1); text-align: center; }
        .day-header { font-weight: bold; margin-bottom: 5px; }
        button { padding: 6px 10px; border: none; border-radius: 4px; cursor: pointer; }
        .register { background: #4caf50; color: white; }
        .cancel { background: #f44336; color: white; }
        .disabled { background: #ccc; color: #666; cursor: not-allowed; }
    </style>
</head>
<body>

<h2 style="text-align:center;">🐾 Đăng ký ca làm việc (${startOfWeek} → ${endOfWeek})</h2>

<div class="calendar">
    <c:forEach var="i" begin="0" end="6">
        <c:set var="currentDate" value="${startOfWeek.plusDays(i)}" />
        <div class="day-cell">
            <div class="day-header">${currentDate}</div>
            <c:forEach var="shift" items="${shiftList}">
                <form action="${pageContext.request.contextPath}/staff/register-shift" method="post" style="margin-top:5px;">
                    <input type="hidden" name="workDate" value="${currentDate}">
                    <input type="hidden" name="shiftId" value="${shift.shiftID}">
                    <c:set var="registered" value="false" />
                    <c:forEach var="r" items="${registeredList}">
                        <c:if test="${r.shiftId == shift.shiftID && r.workDate eq currentDate}">
                            <c:set var="registered" value="true" />
                        </c:if>
                    </c:forEach>
                    <div>${shift.shiftName}</div>
                    <c:choose>
                        <c:when test="${registered}">
                            <button type="submit" name="action" value="cancel" class="cancel">Hủy</button>
                        </c:when>
                        <c:otherwise>
                            <button type="submit" name="action" value="register" class="register">Đăng ký</button>
                        </c:otherwise>
                    </c:choose>
                </form>
            </c:forEach>
        </div>
    </c:forEach>
</div>

</body>
</html>
