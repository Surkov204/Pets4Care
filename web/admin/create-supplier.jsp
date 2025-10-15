<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.Admin" %>
<%
    Admin admin = (Admin) session.getAttribute("admin");
    if (admin == null) {
        response.sendRedirect("../login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Thêm nhà cung cấp</title>
    <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-gray-100 p-6">

    <div class="max-w-2xl mx-auto bg-white shadow-md p-6 rounded">
        <h1 class="text-2xl font-bold mb-4 text-orange-600">➕ Thêm Nhà Cung Cấp Mới</h1>

        <form action="SupplierServlet" method="post">
            <input type="hidden" name="action" value="create" />

            <div class="mb-4">
                <label class="block font-semibold">Tên công ty:</label>
                <input type="text" name="nameCompany" required class="w-full border p-2 rounded" />
            </div>

            <div class="mb-4">
                <label class="block font-semibold">Địa chỉ:</label>
                <input type="text" name="address" required class="w-full border p-2 rounded" />
            </div>

            <div class="mb-4">
                <label class="block font-semibold">Số điện thoại:</label>
                <input type="text" name="phone" required class="w-full border p-2 rounded" />
            </div>

            <div class="flex justify-end">
                <button type="submit" class="bg-green-500 hover:bg-green-600 text-white px-4 py-2 rounded">Lưu</button>
            </div>
        </form>
    </div>

</body>
</html>
