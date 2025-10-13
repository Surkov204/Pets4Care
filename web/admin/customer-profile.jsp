<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.Customer" %>

<%
    // Lấy thông tin khách hàng từ session
    Customer customer = (Customer) session.getAttribute("customer");

    // Nếu chưa đăng nhập, chuyển về trang đăng nhập
    if (customer == null) {
        response.sendRedirect("../login.jsp");
        return;
    }
%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Hồ sơ khách hàng</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.3/css/all.min.css" rel="stylesheet"/>
</head>

<body class="bg-gray-100 font-sans">

    <!-- Header -->
    <jsp:include page="includes/header.jsp" flush="true" />

    <main class="flex justify-center items-center min-h-screen p-6">
        <div class="w-full max-w-3xl bg-white rounded-lg shadow-lg p-8">
            
            <!-- Header hồ sơ -->
            <div class="flex items-center gap-6 border-b pb-4 mb-6">
                <img src="../images/default_customer.jpg" alt="Avatar"
                     class="w-24 h-24 rounded-full border-4 border-green-500 object-cover">
                <div>
                    <h2 class="text-2xl font-bold text-gray-800">👤 Hồ sơ khách hàng</h2>
                    <p class="text-gray-600">Xin chào, <b><%= customer.getName() %></b></p>
                    <p class="text-gray-500 text-sm">
                        <i class="fas fa-id-card"></i> Mã KH: <%= customer.getCustomerId() %>
                    </p>
                </div>
            </div>

            <!-- Thông tin khách hàng -->
            <div class="space-y-4">
                <div class="flex justify-between border-b pb-2">
                    <span class="font-semibold text-gray-700">📧 Email:</span>
                    <span class="text-gray-600"><%= customer.getEmail() %></span>
                </div>
                <div class="flex justify-between border-b pb-2">
                    <span class="font-semibold text-gray-700">📞 Số điện thoại:</span>
                    <span class="text-gray-600"><%= customer.getPhone() %></span>
                </div>
                <div class="flex justify-between border-b pb-2">
                    <span class="font-semibold text-gray-700">🏠 Địa chỉ:</span>
                    <span class="text-gray-600"><%= customer.getAddressCustomer() %></span>
                </div>
                <div class="flex justify-between border-b pb-2">
                    <span class="font-semibold text-gray-700">🔒 Mật khẩu:</span>
                    <span class="text-gray-600">******</span>
                </div>
                <div class="flex justify-between border-b pb-2">
                    <span class="font-semibold text-gray-700">🌐 Trạng thái:</span>
                    <span class="text-gray-600"><%= customer.getStatus() %></span>
                </div>
            </div>

            <!-- Nút chỉnh sửa & xóa -->
            <div class="flex justify-center gap-4 mt-8">
                <a href="edit-customer.jsp?id=<%= customer.getCustomerId() %>"
                   class="bg-green-600 text-white px-6 py-2 rounded-lg shadow hover:bg-green-700 transition">
                    ✏️ Chỉnh sửa thông tin
                </a>

                <form action="../DeleteCustomerServlet" method="post" 
                      onsubmit="return confirm('Bạn có chắc muốn xóa tài khoản này không?');">
                    <input type="hidden" name="id" value="<%= customer.getCustomerId() %>">
                    <button type="submit" 
                            class="bg-red-600 text-white px-6 py-2 rounded-lg shadow hover:bg-red-700 transition">
                        🗑️ Xóa tài khoản
                    </button>
                </form>
            </div>
        </div>
    </main>

    <!-- Footer -->
    <jsp:include page="includes/footer.jsp" flush="true" />

</body>
</html>
