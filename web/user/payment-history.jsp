<%@page import="model.Customer"%>
<%@page import="model.Payment"%>
<%@page import="dao.PaymentDAO"%>
<%@page import="java.util.List"%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    Customer currentUser = (Customer) session.getAttribute("currentUser");
    if (currentUser == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    
    PaymentDAO paymentDAO = new PaymentDAO();
    List<Payment> payments = paymentDAO.getPaymentHistoryWithDetails(currentUser.getCustomerId());
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>💳 Lịch sử thanh toán - Petcity</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <link rel="stylesheet" href="<%= request.getContextPath()%>/css/homeStyle.css" />
    <style>
        .sidebar-nav {
            position: sticky;
            top: 20px;
            background: white;
            border-radius: 12px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
            padding: 1.5rem;
        }

        .sidebar-nav-item {
            display: flex;
            align-items: center;
            padding: 0.75rem 1rem;
            margin-bottom: 0.5rem;
            border-radius: 8px;
            text-decoration: none;
            color: #4b5563;
            transition: all 0.2s;
            cursor: pointer;
        }

        .sidebar-nav-item:hover {
            background: #f3f4f6;
            color: #f97316;
        }

        .sidebar-nav-item.active {
            background: linear-gradient(135deg, #f97316, #fb923c);
            color: white;
        }

        .sidebar-nav-item i {
            margin-right: 0.75rem;
            font-size: 1.1rem;
        }

        .status-badge {
            display: inline-block;
            padding: 0.25rem 0.75rem;
            border-radius: 9999px;
            font-size: 0.875rem;
            font-weight: 500;
        }

        .status-paid {
            background-color: #d1fae5;
            color: #065f46;
        }

        .status-pending {
            background-color: #fef3c7;
            color: #92400e;
        }

        .status-cancelled {
            background-color: #fee2e2;
            color: #991b1b;
        }

        .status-failed {
            background-color: #fee2e2;
            color: #991b1b;
        }

        .status-refunded {
            background-color: #e0e7ff;
            color: #3730a3;
        }
    </style>
</head>
<body class="bg-gray-50">
    <!-- Top Bar -->
    <div class="top-bar">
        <div class="left">PETCITY - SIÊU THỊ THÚ CƯNG ONLINE</div>
        <div class="right">
            <div>CẦN LÀ CÓ - MÒ LÀ THẤY</div>
            <a href="#"><i class="fab fa-facebook-f"></i></a>
            <a href="#"><i class="fab fa-instagram"></i></a>
            <a href="#"><i class="fab fa-twitter"></i></a>
            <a href="#"><i class="fas fa-envelope"></i></a>
        </div>
    </div>

    <!-- Header -->
    <header class="header-bar">
        <a href="<%= request.getContextPath()%>/home" class="logo">
            <div>
                <div class="logo-text">petcity</div>
                <div class="logo-subtext">thành phố thú cưng</div>
            </div>
        </a>
        <form class="search-form" method="get" action="search">
            <input type="text" name="keyword" placeholder="Tìm kiếm..." required>
            <button type="submit"><i class="fas fa-search"></i></button>
        </form>
        <div class="contact-info">
            <div><i class="far fa-clock"></i> 08:00 - 17:00</div>
            <div>
                👤 Xin chào, <b><%= currentUser.getName()%></b>
                <a href="<%= request.getContextPath()%>/logout.jsp" class="text-blue-500 hover:underline ml-2">[Đăng xuất]</a>
            </div>
        </div>
    </header>

    <!-- Navigation -->
    <nav>
        <ul>
            <li><a href="<%= request.getContextPath()%>/home">TRANG CHỦ</a></li>
            <li><a href="spa-service.jsp">DỊCH VỤ</a></li>
            <li><a href="search?categoryId=2">SẢN PHẨM</a></li>
            <li><a href="doctor.jsp">BÁC SĨ</a></li>
            <li><a href="gioi-thieu.jsp">GIỚI THIỆU</a></li>
            <li><a href="tin-tuc.jsp">TIN TỨC</a></li>
            <li><a href="<%= request.getContextPath()%>/home">LIÊN HỆ</a></li>
        </ul>
    </nav>

    <!-- Breadcrumbs -->
    <div class="max-w-7xl mx-auto mt-6 px-6">
        <nav class="text-sm text-gray-500 mb-4" aria-label="Breadcrumb">
            <ol class="list-reset flex">
                <li><a href="<%= request.getContextPath()%>/home" class="text-blue-600 hover:underline">Trang chủ</a></li>
                <li><span class="mx-2">/</span></li>
                <li><a href="<%= request.getContextPath()%>/user/user-info.jsp" class="text-blue-600 hover:underline">Tài khoản</a></li>
                <li><span class="mx-2">/</span></li>
                <li class="text-gray-700">Lịch sử thanh toán</li>
            </ol>
        </nav>
    </div>

    <!-- MAIN CONTENT WITH SIDEBAR -->
    <main class="max-w-7xl mx-auto mt-4 px-6 pb-10">
        <div class="grid grid-cols-1 md:grid-cols-4 gap-6">
            <!-- Sidebar Navigation -->
            <aside class="md:col-span-1">
                <div class="sidebar-nav">
                    <h3 class="text-lg font-bold text-gray-800 mb-4">Quản lý tài khoản</h3>
                    <a href="<%= request.getContextPath()%>/user/user-info.jsp#account" class="sidebar-nav-item">
                        <i class="fas fa-user"></i>
                        <span>Thông tin tài khoản</span>
                    </a>
                    <a href="<%= request.getContextPath()%>/user/user-info.jsp#password" class="sidebar-nav-item">
                        <i class="fas fa-lock"></i>
                        <span>Đổi mật khẩu</span>
                    </a>
                    <a href="<%= request.getContextPath()%>/user/user-info.jsp#pet" class="sidebar-nav-item">
                        <i class="fas fa-paw"></i>
                        <span>Thông tin thú cưng</span>
                    </a>
                    <hr class="my-3 border-gray-200">
                    <a href="<%= request.getContextPath()%>/health-check-booking" class="sidebar-nav-item">
                        <i class="fas fa-calendar-check"></i>
                        <span>Đặt lịch khám</span>
                    </a>
                    <a href="<%= request.getContextPath()%>/user/payment-history.jsp" class="sidebar-nav-item active">
                        <i class="fas fa-credit-card"></i>
                        <span>Lịch sử thanh toán</span>
                    </a>
                    <a href="<%= request.getContextPath()%>/home" class="sidebar-nav-item">
                        <i class="fas fa-home"></i>
                        <span>Về trang chủ</span>
                    </a>
                </div>
            </aside>

            <!-- Main Content Area -->
            <div class="md:col-span-3">
                <div class="bg-white shadow rounded-lg p-8">
                    <h2 class="text-2xl font-bold text-orange-600 mb-6">
                        <i class="fas fa-credit-card mr-2"></i>Lịch sử thanh toán
                    </h2>

                    <% if (payments == null || payments.isEmpty()) { %>
                        <div class="text-center py-12">
                            <i class="fas fa-receipt text-gray-300 text-6xl mb-4"></i>
                            <p class="text-gray-500 text-lg">Bạn chưa có giao dịch thanh toán nào</p>
                            <a href="<%= request.getContextPath()%>/home" class="text-blue-600 hover:underline mt-4 inline-block">
                                <i class="fas fa-arrow-left mr-2"></i>Về trang chủ
                            </a>
                        </div>
                    <% } else { %>
                        <div class="overflow-x-auto">
                            <table class="min-w-full divide-y divide-gray-200">
                                <thead class="bg-gray-50">
                                    <tr>
                                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Mã giao dịch</th>
                                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Loại dịch vụ</th>
                                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Dịch vụ/Sản phẩm</th>
                                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Số tiền</th>
                                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Phương thức</th>
                                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Trạng thái</th>
                                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Ngày tạo</th>
                                    </tr>
                                </thead>
                                <tbody class="bg-white divide-y divide-gray-200">
                                    <% for (Payment payment : payments) { %>
                                        <tr class="hover:bg-gray-50">
                                            <td class="px-6 py-4 whitespace-nowrap">
                                                <div class="text-sm font-medium text-gray-900">
                                                    #<%= payment.getPaymentId() %>
                                                </div>
                                                <% if (payment.getOrderCode() != null && !payment.getOrderCode().isEmpty()) { %>
                                                    <div class="text-xs text-gray-500">
                                                        Mã: <%= payment.getOrderCode() %>
                                                    </div>
                                                <% } %>
                                            </td>
                                            <td class="px-6 py-4 whitespace-nowrap">
                                                <div class="text-sm text-gray-900">
                                                    <%= payment.getPaymentTypeDisplay() %>
                                                </div>
                                            </td>
                                            <td class="px-6 py-4">
                                                <div class="text-sm text-gray-900">
                                                    <%= payment.getServiceName() != null ? payment.getServiceName() : "N/A" %>
                                                </div>
                                            </td>
                                            <td class="px-6 py-4 whitespace-nowrap">
                                                <div class="text-sm font-semibold text-green-600">
                                                    <%= String.format("%,.0f", payment.getAmount().doubleValue()) %> ₫
                                                </div>
                                            </td>
                                            <td class="px-6 py-4 whitespace-nowrap">
                                                <div class="text-sm text-gray-900">
                                                    <%= payment.getPaymentMethodDisplay() %>
                                                </div>
                                            </td>
                                            <td class="px-6 py-4 whitespace-nowrap">
                                                <span class="status-badge status-<%= payment.getPaymentStatus() %>">
                                                    <%= payment.getPaymentStatusDisplay() %>
                                                </span>
                                            </td>
                                            <td class="px-6 py-4 whitespace-nowrap">
                                                <div class="text-sm text-gray-500">
                                                    <% if (payment.getCreatedAt() != null) { %>
                                                        <%= new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm:ss").format(payment.getCreatedAt()) %>
                                                    <% } else { %>
                                                        N/A
                                                    <% } %>
                                                </div>
                                                <% if (payment.getPaidAt() != null && "paid".equals(payment.getPaymentStatus())) { %>
                                                    <div class="text-xs text-green-600">
                                                        Đã thanh toán: <%= new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm:ss").format(payment.getPaidAt()) %>
                                                    </div>
                                                <% } %>
                                            </td>
                                        </tr>
                                    <% } %>
                                </tbody>
                            </table>
                        </div>

                        <div class="mt-6 text-sm text-gray-500">
                            <p><i class="fas fa-info-circle mr-2"></i>Tổng cộng: <strong><%= payments.size() %></strong> giao dịch</p>
                        </div>
                    <% } %>
                </div>
            </div>
        </div>
    </main>

    <footer class="mt-10 text-sm text-gray-500 py-4">
        <p><strong>Petcity - Siêu thị thú cưng online</strong></p>
        <p>Địa chỉ: Môn SWP</p>
        <p>Điện thoại: 090 900 900</p>
        <p>Email: support@petcity.vn</p>
        <p>© 2025 Petcity. Bản quyền thuộc về G5.</p>
    </footer>

    <jsp:include page="/chatbox.jsp"/>
</body>
</html>

