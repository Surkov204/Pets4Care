<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.Customer, dao.UserDAO, model.Order, java.util.*" %>
<%@ page session="true" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>📦 Lịch sử đơn hàng - Petcity</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.3/css/all.min.css" rel="stylesheet" />
    <link href="https://fonts.googleapis.com/css2?family=Quicksand:wght@300;400;500;600;700&family=Nunito:wght@300;400;500;600;700;800&family=Baloo+2:wght@400;500;600;700;800&display=swap" rel="stylesheet" />
    <link rel="stylesheet" href="../css/homeStyle.css" />
    <style>
        body {
            font-family: 'Quicksand', 'Nunito', 'Baloo 2', Arial, sans-serif;
        }
        .order-table {
            overflow-x: auto;
        }
        @media (max-width: 768px) {
            .order-table {
                font-size: 0.875rem;
            }
            .order-table th,
            .order-table td {
                padding: 0.5rem;
            }
        }
        .status-badge {
            padding: 0.25rem 0.75rem;
            border-radius: 9999px;
            font-size: 0.875rem;
            font-weight: 600;
        }
        .status-cancelled {
            background-color: #fee2e2;
            color: #dc2626;
        }
        .status-completed {
            background-color: #d1fae5;
            color: #059669;
        }
        .status-pending {
            background-color: #fef3c7;
            color: #d97706;
        }
    </style>
</head>
<body>

<%
    Customer customer = (Customer) session.getAttribute("currentUser");
    if (customer == null) {
        response.sendRedirect("../login.jsp");
        return;
    }

    List<Order> orders = new UserDAO().getOrdersByCustomerId(customer.getCustomerId());
    
    // Kiểm tra nếu chưa có đơn hàng nào, redirect về trang chủ
    if (orders == null || orders.isEmpty()) {
        session.setAttribute("errorMessage", "Bạn chưa có đơn hàng nào để xem lịch sử.");
        response.sendRedirect(request.getContextPath() + "/home");
        return;
    }
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
            <div>
                <a href="<%= request.getContextPath()%>/home" class="text-sm hover:underline">🏠 Về trang chủ</a>
            </div>
        </div>
    </header>

    <!-- Main Content -->
    <div class="mx-auto max-w-6xl mt-6 px-4 py-6">
        <!-- Breadcrumb -->
        <nav class="mb-6 text-sm text-gray-600">
            <a href="<%= request.getContextPath()%>/home" class="hover:text-blue-600">Trang chủ</a>
            <span class="mx-2">/</span>
            <span class="text-gray-800 font-semibold">Lịch sử đơn hàng</span>
        </nav>

        <!-- Page Title -->
        <h1 class="text-3xl font-bold mb-6" style="font-family: 'Baloo 2', cursive; color: var(--primary);">
            📦 Lịch sử đơn hàng của <%= customer.getName() %>
        </h1>

        <% 
            // Chỉ hiển thị bảng nếu có đơn hàng (đã kiểm tra ở trên, nhưng để đảm bảo)
            if (orders != null && !orders.isEmpty()) { 
        %>
        <div class="order-table bg-white rounded-lg shadow-md overflow-hidden">
            <table class="min-w-full border-collapse">
                <thead class="bg-gradient-to-r from-green-400 to-green-600 text-white">
                    <tr>
                        <th class="px-4 py-3 text-left font-semibold">Mã đơn</th>
                        <th class="px-4 py-3 text-left font-semibold">Ngày đặt</th>
                        <th class="px-4 py-3 text-left font-semibold">Thanh toán</th>
                        <th class="px-4 py-3 text-left font-semibold">Phương thức</th>
                        <th class="px-4 py-3 text-left font-semibold">Trạng thái</th>
                        <th class="px-4 py-3 text-left font-semibold">Tổng tiền</th>
                        <th class="px-4 py-3 text-left font-semibold">Thao tác</th>
                    </tr>
                </thead>
                <tbody>
                <% for (Order o : orders) { %>
                    <tr class="border-b hover:bg-gray-50 transition-colors">
                        <td class="px-4 py-3 font-semibold text-gray-800">#<%= o.getOrderId() %></td>
                        <td class="px-4 py-3 text-gray-600"><%= o.getOrderDate() %></td>
                        <td class="px-4 py-3 text-gray-600"><%= o.getPaymentStatus() %></td>
                        <td class="px-4 py-3 text-gray-600"><%= o.getPaymentMethod() %></td>
                        <td class="px-4 py-3">
                            <% if ("Đã hủy".equals(o.getStatus())) { %>
                                <span class="status-badge status-cancelled">Đã hủy</span>
                            <% } else if ("Hoàn tất".equals(o.getStatus())) { %>
                                <span class="status-badge status-completed">Hoàn tất</span>
                            <% } else { %>
                                <span class="status-badge status-pending"><%= o.getStatus() %></span>
                            <% } %>
                        </td>
                        <td class="px-4 py-3 font-bold text-green-600"><%= String.format("%.0f", o.getTotalAmount()) %>₫</td>
                        <td class="px-4 py-3">
                            <a class="inline-block px-3 py-1 bg-blue-500 text-white rounded hover:bg-blue-600 transition text-sm" 
                               href="order-detail.jsp?id=<%= o.getOrderId() %>">
                                <i class="fas fa-eye"></i> Chi tiết
                            </a>
                            <% if (!"Đã hủy".equals(o.getStatus()) && !"Hoàn tất".equals(o.getStatus())) { %>
                                <a class="inline-block px-3 py-1 bg-red-500 text-white rounded hover:bg-red-600 transition text-sm ml-2"
                                   href="<%= request.getContextPath() %>/cancelorder?id=<%= o.getOrderId() %>"
                                   onclick="return confirm('Bạn có chắc muốn hủy đơn hàng này?');">
                                    <i class="fas fa-times"></i> Hủy
                                </a>
                            <% } %>
                        </td>
                    </tr>
                <% } %>
                </tbody>
            </table>
        </div>
        <% 
            } else {
                // Nếu đến đây mà không có đơn hàng (trường hợp bất thường), redirect về home
                session.setAttribute("errorMessage", "Bạn chưa có đơn hàng nào để xem lịch sử.");
                response.sendRedirect(request.getContextPath() + "/home");
                return;
            }
        %>

        <!-- Back Button -->
        <div class="mt-6">
            <a href="<%= request.getContextPath() %>/home" 
               class="inline-flex items-center px-6 py-3 bg-gradient-to-r from-blue-500 to-purple-600 text-white font-semibold rounded-lg hover:from-blue-600 hover:to-purple-700 transition shadow-md">
                <i class="fas fa-arrow-left mr-2"></i> Quay về trang chủ
            </a>
        </div>
    </div>

    <jsp:include page="../chatbox.jsp"/>
</body>
</html>
