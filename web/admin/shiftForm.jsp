<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <title>Ca làm việc | Pet4Care</title>
        <style>
            body {
                font-family: Arial, sans-serif;
                background: #fafafa;
                margin: 2rem;
            }
            form {
                max-width: 500px;
                margin: auto;
                background: white;
                padding: 20px;
                border-radius: 10px;
                box-shadow: 0 3px 8px rgba(0,0,0,0.15);
            }
            label {
                display: block;
                margin-top: 10px;
                font-weight: bold;
            }
            input {
                width: 100%;
                padding: 8px;
                margin-top: 5px;
                border: 1px solid #ccc;
                border-radius: 5px;
            }
            button {
                margin-top: 15px;
                padding: 10px 16px;
                background-color: #ff9800;
                color: white;
                border: none;
                border-radius: 6px;
                cursor: pointer;
            }
            button:hover {
                background-color: #e68900;
            }
            a {
                display: inline-block;
                margin-top: 10px;
                text-decoration: none;
                color: #007bff;
            }
        </style>
    </head>
    <body>

        <h2>
            <c:choose>
                <c:when test="${shift == null}">
                    Thêm ca làm mới
                </c:when>
                <c:otherwise>
                    Chỉnh sửa ca làm #${shift.shiftID}
                </c:otherwise>
            </c:choose>
        </h2>

        <form action="${pageContext.request.contextPath}/shift" method="post">
            <input type="hidden" name="shiftID" value="${shift.shiftID}">

            <label>Mã ca:</label>
            <input type="text" name="shiftCode" value="${shift.shiftCode}" required>

            <label>Tên ca:</label>
            <input type="text" name="shiftName" value="${shift.shiftName}" required>

            <label>Bắt đầu:</label>
            <input type="time" name="startTime" value="${shift.startTime}" required>

            <label>Kết thúc:</label>
            <input type="time" name="endTime" value="${shift.endTime}" required>

            <label>Nghỉ (phút):</label>
            <input type="number" name="breakMinutes" value="${shift.breakMinutes}" required>

            <label>Vị trí:</label>
            <input type="text" name="location" value="${shift.location}">

            <button type="submit">💾 Lưu</button>
        </form>

        <a href="${pageContext.request.contextPath}/admin/manage-staff">⬅ Quay lại danh sách</a>

    </body>
</html>