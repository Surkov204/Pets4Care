<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Yêu cầu đổi ca | Pet4Care</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/staff.css">
    <style>
        body { background-color: #fff8f0; }
        form {
            background: white;
            max-width: 600px;
            margin: 40px auto;
            padding: 25px;
            border-radius: 12px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.1);
        }
        input, select, textarea {
            width: 100%;
            padding: 10px;
            margin: 8px 0;
            border: 1px solid #ddd;
            border-radius: 6px;
        }
        button {
            background: #ff9800;
            color: white;
            padding: 10px 20px;
            border: none;
            border-radius: 6px;
            cursor: pointer;
        }
        button:hover {
            background: #e68900;
        }
    </style>
</head>
<body>
<h2 style="text-align:center;">🐾 Gửi yêu cầu đổi ca</h2>
<form action="${pageContext.request.contextPath}/staff/requestShift" method="post">
    <label>Loại yêu cầu:</label>
    <select name="type" required>
        <option value="change">Đổi ca</option>
        <option value="off">Xin nghỉ</option>
    </select>

    <label>Ngày muốn đổi:</label>
    <input type="date" name="targetDate" required>

    <label>Ca hiện tại (From Shift ID):</label>
    <input type="number" name="fromShiftID" placeholder="VD: 1" required>

    <label>Ca muốn đổi sang (To Shift ID):</label>
    <input type="number" name="toShiftID" placeholder="VD: 2" required>

    <label>Lý do:</label>
    <textarea name="reason" rows="4" placeholder="Nhập lý do..." required></textarea>

    <button type="submit">Gửi yêu cầu</button>
</form>
</body>
</html>
