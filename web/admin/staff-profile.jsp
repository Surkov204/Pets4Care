<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.Staff" %>

<%
    Staff staff = (Staff) session.getAttribute("currentStaff");
    if (staff == null) {
        staff = new Staff(1, "Nguyễn Văn A", "a@gmail.com", "0901234567", "123", "Nhân viên");
        session.setAttribute("currentStaff", staff);
    }
%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Hồ sơ nhân viên - Quản trị viên</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.3/css/all.min.css" rel="stylesheet"/>
    <link href="https://fonts.googleapis.com/css2?family=Nunito:wght@400;600;700&display=swap" rel="stylesheet"/>
    <style>
        body {
            font-family: 'Nunito', sans-serif;
            background-color: #f9fafb;
        }

        .profile-card {
            background: white;
            border-radius: 1rem;
            padding: 2rem;
            max-width: 800px;
            margin: 2rem auto;
            box-shadow: 0 4px 10px rgba(0,0,0,0.1);
        }

        .profile-header {
            display: flex;
            align-items: center;
            gap: 20px;
            border-bottom: 1px solid #e5e7eb;
            padding-bottom: 1rem;
            margin-bottom: 1rem;
        }

        .profile-header img {
            width: 110px;
            height: 110px;
            border-radius: 50%;
            object-fit: cover;
            border: 3px solid #3b82f6;
        }

        .info-row {
            display: flex;
            justify-content: space-between;
            padding: 8px 0;
            border-bottom: 1px dashed #ddd;
        }

        .info-row span:first-child {
            font-weight: 600;
            color: #374151;
        }

        .btn-container {
            display: flex;
            gap: 1rem;
            margin-top: 1.5rem;
        }

        .btn-edit {
            background-color: #2563eb;
            color: white;
            padding: 10px 20px;
            border-radius: 8px;
            transition: 0.3s;
            text-decoration: none;
        }

        .btn-edit:hover {
            background-color: #1d4ed8;
        }

        .btn-delete {
            background-color: #dc2626;
            color: white;
            padding: 10px 20px;
            border-radius: 8px;
            transition: 0.3s;
            text-decoration: none;
        }

        .btn-delete:hover {
            background-color: #b91c1c;
        }
    </style>
</head>

<body>
    <!-- Header admin -->
    <jsp:include page="includes/header.jsp"/>

    <div class="profile-card">
        <div class="profile-header">
            <img src="../images/default_staff.jpg" alt="Staff Avatar">
            <div>
                <h2 class="text-2xl font-bold text-gray-800">👩‍💼 Hồ sơ nhân viên</h2>
                <p class="text-gray-600">Xin chào, <b><%= staff.getName() %></b></p>
                <p class="text-gray-500 text-sm"><i class="fas fa-id-card"></i> Mã nhân viên: <%= staff.getStaffId() %></p>
            </div>
        </div>

        <div class="info-row">
            <span>📧 Email:</span>
            <span><%= staff.getEmail() %></span>
        </div>
        <div class="info-row">
            <span>📞 Số điện thoại:</span>
            <span><%= staff.getPhone() %></span>
        </div>
        <div class="info-row">
            <span>🔑 Mật khẩu:</span>
            <span>******</span>
        </div>
        <div class="info-row">
            <span>🧭 Chức vụ:</span>
            <span><%= staff.getPosition() %></span>
        </div>

        <div class="btn-container">
            <a href="edit-staff.jsp?id=<%= staff.getStaffId() %>" class="btn-edit">
                ✏️ Chỉnh sửa thông tin
            </a>

            <a href="delete-staff?id=<%= staff.getStaffId() %>" class="btn-delete" 
               onclick="return confirm('⚠️ Bạn có chắc muốn xóa nhân viên này không?');">
                🗑️ Xóa nhân viên
            </a>
        </div>
    </div>

    <!-- Footer admin -->
    <jsp:include page="includes/footer.jsp"/>
</body>
</html>