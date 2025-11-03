<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>❌ Xác nhận thất bại - Petcity</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
</head>
<body class="flex items-center justify-center min-h-screen bg-red-50 font-sans">

    <div class="bg-white p-8 rounded-xl shadow-lg text-center max-w-md">
        <h1 class="text-3xl font-bold text-red-600 mb-4">❌ Xác nhận thanh toán thất bại</h1>

        <p class="text-gray-700 mb-4">Có lỗi xảy ra trong quá trình xử lý xác nhận đơn hàng.</p>
        <p class="text-gray-500 text-sm mb-6">Vui lòng thử lại hoặc liên hệ bộ phận hỗ trợ để được xử lý sớm nhất.</p>

        <a href="<%= request.getContextPath() %>/order/order-success.jsp"
           class="inline-block bg-red-600 hover:bg-red-700 text-white px-5 py-2 rounded shadow">
            🔁 Thử lại xác nhận
        </a>

        <a href="<%= request.getContextPath() %>/home"
           class="ml-4 inline-block text-gray-600 hover:underline">
            ⬅ Về trang chủ
        </a>
    </div>

</body>
</html>
