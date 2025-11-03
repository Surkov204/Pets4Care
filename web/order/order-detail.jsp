<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.util.*, model.CartItem, model.Product, model.Order, model.Customer, dao.UserDao" %>
<%@ page session="true" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>📦 Chi tiết đơn hàng - Petcity</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.3/css/all.min.css" rel="stylesheet" />
    <link href="https://fonts.googleapis.com/css2?family=Quicksand:wght@300;400;500;600;700&family=Nunito:wght@300;400;500;600;700;800&family=Baloo+2:wght@400;500;600;700;800&display=swap" rel="stylesheet" />
    <link rel="stylesheet" href="../css/homeStyle.css" />
    <style>
        body {
            font-family: 'Quicksand', 'Nunito', 'Baloo 2', Arial, sans-serif;
        }
        .order-info-card {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border-radius: 15px;
            padding: 1.5rem;
            margin-bottom: 1.5rem;
        }
        @media (max-width: 768px) {
            .order-table {
                font-size: 0.875rem;
            }
        }
    </style>
</head>
<body>

<%
    String orderIdRaw = request.getParameter("id");
    if (orderIdRaw == null) {
        response.sendRedirect("order-history.jsp");
        return;
    }

    int orderId = Integer.parseInt(orderIdRaw);
    UserDao userDao = new UserDao();
    List<CartItem> items = userDao.getOrderDetails(orderId);
    Order order = userDao.getOrderById(orderId); // cần hàm getOrderById
    Customer currentUser = (Customer) session.getAttribute("currentUser");
%>

    <!-- Top Bar -->
    <div class="top-bar">
        <div class="left">🐾 PETCITY - SIÊU THỊ THÚ CƯNG ONLINE 🐾</div>
        <div class="right">
            <div>✨ CẦN LÀ CÓ - MÒ LÀ THẤY ✨</div>
        </div>
    </div>

    <!-- Header -->
    <header class="header-bar">
        <a href="<%= request.getContextPath()%>/home" class="logo">
            <img src="https://storage.googleapis.com/a1aa/image/15870274-75b6-4029-e89c-1424dc010c18.jpg" alt="Logo Petcity" />
            <div>
                <div class="logo-text">petcity</div>
                <div class="logo-subtext">thành phố thú cưng</div>
            </div>
        </a>
        <div class="contact-info">
            <div><i class="far fa-clock"></i> 08:00 - 17:00</div>
        </div>
    </header>

    <!-- Main Content -->
    <div class="mx-auto max-w-6xl mt-6 px-4 py-6">
        <!-- Breadcrumb -->
        <nav class="mb-6 text-sm text-gray-600">
            <a href="<%= request.getContextPath()%>/home" class="hover:text-blue-600">Trang chủ</a>
            <span class="mx-2">/</span>
            <a href="order-history.jsp" class="hover:text-blue-600">Lịch sử đơn hàng</a>
            <span class="mx-2">/</span>
            <span class="text-gray-800 font-semibold">Chi tiết đơn hàng</span>
        </nav>

        <!-- Page Title -->
        <h1 class="text-3xl font-bold mb-6" style="font-family: 'Baloo 2', cursive; color: var(--primary);">
            📦 Chi tiết đơn hàng <span class="text-blue-600">#<%= orderId %></span>
        </h1>

        <% if (order == null || items == null || items.isEmpty()) { %>
            <div class="bg-red-50 border-l-4 border-red-500 p-4 rounded mb-6">
                <p class="text-red-700 font-semibold"><i class="fas fa-exclamation-circle"></i> Không tìm thấy chi tiết đơn hàng.</p>
            </div>
        <% } else { %>

        <!-- Order Info Card -->
        <div class="order-info-card">
            <h3 class="text-xl font-bold mb-4"><i class="fas fa-info-circle"></i> Thông tin đơn hàng</h3>
            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div>
                    <p class="mb-2"><strong>👤 Người mua:</strong> <%= currentUser != null ? currentUser.getName() : "Không rõ" %></p>
                    <p class="mb-2"><strong>🕒 Ngày đặt:</strong> <%= order.getOrderDate() %></p>
                </div>
                <div>
                    <p class="mb-2"><strong>💳 Thanh toán:</strong> <%= order.getPaymentMethod() %> - <%= order.getPaymentStatus() %></p>
                    <p class="mb-2"><strong>📌 Trạng thái đơn:</strong> <%= order.getStatus() %></p>
                </div>
            </div>
        </div>

        <!-- Order Items Table -->
        <div class="bg-white rounded-lg shadow-md overflow-hidden mb-6">
            <div class="overflow-x-auto">
                <table class="min-w-full border-collapse">
                    <thead class="bg-gradient-to-r from-blue-400 to-blue-600 text-white">
                        <tr>
                            <th class="px-4 py-3 text-left font-semibold">Tên sản phẩm</th>
                            <th class="px-4 py-3 text-left font-semibold hidden md:table-cell">Mô tả</th>
                            <th class="px-4 py-3 text-left font-semibold">Giá</th>
                            <th class="px-4 py-3 text-left font-semibold">Số lượng</th>
                            <th class="px-4 py-3 text-left font-semibold">Thành tiền</th>
                        </tr>
                    </thead>
                    <tbody>
                    <%
                        double total = 0;
                        for (CartItem item : items) {
                            double sub = item.getQuantity() * item.getProduct().getPrice();
                            total += sub;
                    %>
                        <tr class="border-b hover:bg-gray-50 transition-colors">
                            <td class="px-4 py-3 font-semibold text-gray-800"><%= item.getProduct().getName() %></td>
                            <td class="px-4 py-3 text-gray-600 hidden md:table-cell"><%= item.getProduct().getDescription() %></td>
                            <td class="px-4 py-3 text-gray-600"><%= String.format("%.0f", item.getProduct().getPrice()) %>₫</td>
                            <td class="px-4 py-3 text-gray-600"><%= item.getQuantity() %></td>
                            <td class="px-4 py-3 font-bold text-green-600"><%= String.format("%.0f", sub) %>₫</td>
                        </tr>
                    <% } %>
                    </tbody>
                </table>
            </div>
        </div>

        <!-- Total -->
        <div class="bg-gradient-to-r from-green-50 to-green-100 rounded-lg p-6 mb-6">
            <div class="flex justify-between items-center">
                <span class="text-2xl font-bold text-gray-700">🧾 Tổng cộng:</span>
                <span class="text-3xl font-bold text-green-600"><%= String.format("%.0f", total) %>₫</span>
            </div>
        </div>

        <% } %>

        <!-- Back Button -->
        <div class="mt-6">
            <a href="order-history.jsp" 
               class="inline-flex items-center px-6 py-3 bg-gradient-to-r from-blue-500 to-purple-600 text-white font-semibold rounded-lg hover:from-blue-600 hover:to-purple-700 transition shadow-md">
                <i class="fas fa-arrow-left mr-2"></i> Quay lại lịch sử đơn hàng
            </a>
        </div>
    </div>

    <jsp:include page="../chatbox.jsp"/>
</body>
</html>
