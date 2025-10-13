<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.Customer" %>

<%
    Customer customer = (Customer) session.getAttribute("customer");
    if (customer == null) {
        response.sendRedirect("../login.jsp");
        return;
    }
%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Chỉnh sửa thông tin khách hàng</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.3/css/all.min.css" rel="stylesheet"/>
</head>

<body class="bg-gray-100 font-sans">
    <jsp:include page="includes/header.jsp"/>

    <main class="flex justify-center items-center min-h-screen p-6">
        <form action="../UpdateCustomerServlet" method="post"
              class="w-full max-w-2xl bg-white rounded-lg shadow-lg p-8">

            <h2 class="text-2xl font-bold text-gray-800 mb-6 text-center">
                ✏️ Chỉnh sửa thông tin khách hàng
            </h2>

            <input type="hidden" name="customerId" value="<%= customer.getCustomerId() %>"/>

            <!-- Họ tên -->
            <div class="mb-4">
                <label class="block text-gray-700 font-semibold mb-2">Họ và tên</label>
                <input type="text" name="name" value="<%= customer.getName() %>"
                       class="w-full border rounded-lg px-4 py-2 focus:ring-2 focus:ring-green-500" required/>
            </div>

            <!-- Email -->
            <div class="mb-4">
                <label class="block text-gray-700 font-semibold mb-2">Email</label>
                <input type="email" name="email" value="<%= customer.getEmail() %>"
                       class="w-full border rounded-lg px-4 py-2 focus:ring-2 focus:ring-green-500" required/>
            </div>

            <!-- Số điện thoại -->
            <div class="mb-4">
                <label class="block text-gray-700 font-semibold mb-2">Số điện thoại</label>
                <input type="text" name="phone" value="<%= customer.getPhone() %>"
                       class="w-full border rounded-lg px-4 py-2 focus:ring-2 focus:ring-green-500" required/>
            </div>

            <!-- Địa chỉ -->
            <div class="mb-4">
                <label class="block text-gray-700 font-semibold mb-2">Địa chỉ</label>
                <input type="text" name="addressCustomer" value="<%= customer.getAddressCustomer() %>"
                       class="w-full border rounded-lg px-4 py-2 focus:ring-2 focus:ring-green-500"/>
            </div>

            <!-- Mật khẩu -->
            <div class="mb-4">
                <label class="block text-gray-700 font-semibold mb-2">Mật khẩu</label>
                <input type="password" name="password" value="<%= customer.getPassword() %>"
                       class="w-full border rounded-lg px-4 py-2 focus:ring-2 focus:ring-green-500" required/>
            </div>

            <!-- Nút hành động -->
            <div class="flex justify-center mt-8 gap-4">
                <button type="submit"
                        class="bg-green-600 text-white px-6 py-2 rounded-lg shadow hover:bg-green-700 transition">
                    💾 Cập nhật
                </button>
                <a href="customer-profile.jsp"
                   class="bg-gray-400 text-white px-6 py-2 rounded-lg shadow hover:bg-gray-500 transition">
                    ⬅️ Quay lại
                </a>
            </div>
        </form>
    </main>

    <jsp:include page="includes/footer.jsp"/>
</body>
</html>
