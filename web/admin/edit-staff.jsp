<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.Staff" %>

<%
    Staff staff = (Staff) session.getAttribute("currentStaff");
    if (staff == null) {
        response.sendRedirect(request.getContextPath() + "/admin/login.jsp");
        return;
    }
%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Chỉnh sửa thông tin nhân viên</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.3/css/all.min.css" rel="stylesheet"/>
    <link href="https://fonts.googleapis.com/css2?family=Nunito:wght@400;600;700&display=swap" rel="stylesheet"/>
    <style>
        body {
            font-family: 'Nunito', sans-serif;
            background-color: #f3f4f6;
        }

        .form-container {
            background: white;
            max-width: 600px;
            margin: 2rem auto;
            padding: 2rem;
            border-radius: 1rem;
            box-shadow: 0 4px 12px rgba(0,0,0,0.1);
        }

        label {
            font-weight: 600;
            color: #374151;
        }

        input {
            width: 100%;
            border: 1px solid #d1d5db;
            border-radius: 0.5rem;
            padding: 10px;
            margin-top: 5px;
            margin-bottom: 15px;
            outline: none;
            transition: border-color 0.2s;
        }

        input:focus {
            border-color: #2563eb;
        }

        .btn-primary {
            background-color: #2563eb;
            color: white;
            padding: 10px 20px;
            border-radius: 8px;
            transition: 0.3s;
        }

        .btn-primary:hover {
            background-color: #1d4ed8;
        }

        .btn-cancel {
            background-color: #9ca3af;
            color: white;
            padding: 10px 20px;
            border-radius: 8px;
            transition: 0.3s;
        }

        .btn-cancel:hover {
            background-color: #6b7280;
        }
    </style>
</head>

<body>
    <jsp:include page="includes/header.jsp"/>

    <div class="form-container">
        <h2 class="text-2xl font-bold text-gray-800 mb-6">✏️ Chỉnh sửa thông tin nhân viên</h2>

        <form action="${pageContext.request.contextPath}/AdminUpdateStaffServlet" method="post">
            <input type="hidden" name="staffId" value="<%= staff.getStaffId() %>"/>

            <label for="name">Họ và tên</label>
            <input type="text" id="name" name="name" value="<%= staff.getName() %>" required/>

            <label for="email">Email</label>
            <input type="email" id="email" name="email" value="<%= staff.getEmail() %>" required/>

            <label for="phone">Số điện thoại</label>
            <input type="text" id="phone" name="phone" value="<%= staff.getPhone() %>" required/>

            <label for="password">Mật khẩu</label>
            <input type="password" id="password" name="password" value="<%= staff.getPassword() %>" required/>

            <label for="position">Chức vụ</label>
            <input type="text" id="position" name="position" value="<%= staff.getPosition() %>" required/>

            <div class="flex justify-between mt-6">
                <a href="staff-profile.jsp" class="btn-cancel">⬅ Quay lại</a>
                <button type="submit" class="btn-primary">💾 Lưu thay đổi</button>
            </div>
        </form>
    </div>

    <jsp:include page="includes/footer.jsp"/>
</body>
</html>
