<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="model.Order" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    List<Order> orders = (List<Order>) request.getAttribute("orders");
    String keyword = request.getParameter("keyword") != null ? request.getParameter("keyword") : "";
    String statusFilter = request.getParameter("status") != null ? request.getParameter("status") : "all";
    
    // Lấy thông báo từ session
    String success = (String) request.getSession().getAttribute("success");
    String error = (String) request.getSession().getAttribute("error");
    request.getSession().removeAttribute("success");
    request.getSession().removeAttribute("error");
    
    SimpleDateFormat dateFormat = new SimpleDateFormat("dd/MM/yyyy HH:mm");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản lý đơn hàng</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <style>
        .status-badge {
            padding: 0.25rem 0.5rem;
            border-radius: 9999px;
            font-size: 0.75rem;
            font-weight: 500;
            display: inline-block;
            min-width: 100px;
            text-align: center;
        }
        .processing {
            background-color: #fef9c3;
            color: #b45309;
        }
        .completed {
            background-color: #dcfce7;
            color: #166534;
        }
        .cancelled {
            background-color: #fee2e2;
            color: #991b1b;
        }
        .order-row:hover {
            background-color: #f8fafc;
        }
        .pagination {
            display: flex;
            justify-content: center;
            margin-top: 1rem;
        }
        .pagination a {
            margin: 0 0.25rem;
            padding: 0.5rem 0.75rem;
            border: 1px solid #e2e8f0;
            border-radius: 0.25rem;
        }
        .pagination a.active {
            background-color: #3b82f6;
            color: white;
            border-color: #3b82f6;
        }
    </style>
</head>
<body class="bg-gray-100 min-h-screen font-sans flex">
    <!-- Sidebar -->
    <div class="w-1/5 bg-white shadow h-screen p-6 fixed top-0 left-0 border-r border-orange-100">
        <h2 class="text-xl font-bold text-orange-600 mb-6">📋 Danh mục quản lý</h2>
        <ul class="space-y-3">
            <li>
                <a href="toys?action=list"
                   class="block px-3 py-2 rounded-md text-blue-600 hover:bg-orange-50 hover:text-orange-700 transition font-medium">
                    <i class="fas fa-cube mr-2"></i>Sản phẩm
                </a>
            </li>
            <li>
                <a href="SupplierServlet?action=list"
                   class="block px-3 py-2 rounded-md text-blue-600 hover:bg-orange-50 hover:text-orange-700 transition font-medium">
                    <i class="fas fa-building mr-2"></i>Nhà cung cấp
                </a>
            </li>
            <li>
                <a href="manage-customer"
                   class="block px-3 py-2 rounded-md text-blue-600 hover:bg-orange-50 hover:text-orange-700 transition font-semibold">
                    <i class="fas fa-users mr-2"></i>Khách hàng
                </a>
            </li>
            <li>
                <a href="manage-order"
                   class="block px-3 py-2 rounded-md bg-orange-50 text-orange-700 font-medium">
                    <i class="fas fa-clipboard-list mr-2"></i>Đơn hàng
                </a>
            </li>
            <li>
                <a href="statistics?type=day"
                   class="block px-3 py-2 rounded-md text-blue-600 hover:bg-orange-50 hover:text-orange-700 transition font-medium">
                    <i class="fas fa-chart-line mr-2"></i>Thống kê
                </a>
            </li>
        </ul>

        <div class="mt-10 space-y-2">
            <a href="dashboard.jsp"
               class="block text-center bg-gray-100 hover:bg-gray-200 text-sm text-gray-700 font-medium py-2 px-3 rounded-md transition">
                <i class="fas fa-arrow-left mr-2"></i>Quay về Dashboard
            </a>
            <a href="../home"
               class="block text-center bg-orange-100 hover:bg-orange-200 text-sm text-orange-800 font-medium py-2 px-3 rounded-md transition">
                <i class="fas fa-home mr-2"></i>Về trang chủ
            </a>
        </div>
    </div>

    <!-- Main Content -->
    <div class="ml-[20%] w-[80%] p-8">
        <!-- Header -->
        <div class="mb-6 border-b pb-4">
            <h1 class="text-2xl font-bold text-orange-600 flex items-center">
                <i class="fas fa-clipboard-list mr-2"></i>Quản lý đơn hàng
            </h1>
            
            <!-- Hiển thị thông báo -->
            <% if (success != null) { %>
                <div id="success-alert" class="bg-green-100 border border-green-400 text-green-700 px-4 py-3 rounded relative mb-4 flex justify-between items-center" role="alert">
                    <span><i class="fas fa-check-circle mr-2"></i><%= success %></span>
                    <button onclick="document.getElementById('success-alert').remove()" class="text-green-700 hover:text-green-900">
                        <i class="fas fa-times"></i>
                    </button>
                </div>
            <% } %>
            
            <% if (error != null) { %>
                <div id="error-alert" class="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded relative mb-4 flex justify-between items-center" role="alert">
                    <span><i class="fas fa-exclamation-circle mr-2"></i><%= error %></span>
                    <button onclick="document.getElementById('error-alert').remove()" class="text-red-700 hover:text-red-900">
                        <i class="fas fa-times"></i>
                    </button>
                </div>
            <% } %>
        </div>

        <!-- Bộ lọc và tìm kiếm -->
        <div class="bg-white p-4 rounded-lg shadow mb-6">
            <form method="get" action="manage-order" class="flex flex-wrap items-center gap-4">
                <div class="flex-1 min-w-[250px]">
                    <label for="keyword" class="block text-sm font-medium text-gray-700 mb-1">Tìm kiếm</label>
                    <div class="relative">
                        <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                            <i class="fas fa-search text-gray-400"></i>
                        </div>
                        <input type="text" id="keyword" name="keyword" placeholder="Tìm theo tên khách hoặc mã đơn" value="<%= keyword %>"
                               class="pl-10 border px-3 py-2 rounded w-full focus:ring-orange-500 focus:border-orange-500" />
                    </div>
                </div>
                
                <div class="w-48">
                    <label for="status" class="block text-sm font-medium text-gray-700 mb-1">Trạng thái</label>
                    <select id="status" name="status" class="border px-3 py-2 rounded w-full focus:ring-orange-500 focus:border-orange-500">
                        <option value="all" <%= "all".equals(statusFilter) ? "selected" : "" %>>Tất cả trạng thái</option>
                        <option value="Đang xử lý" <%= "Đang xử lý".equals(statusFilter) ? "selected" : "" %>>Đang xử lý</option>
                        <option value="Hoàn tất" <%= "Hoàn tất".equals(statusFilter) ? "selected" : "" %>>Hoàn tất</option>
                        <option value="Đã hủy" <%= "Đã hủy".equals(statusFilter) ? "selected" : "" %>>Đã hủy</option>
                    </select>
                </div>
                
                <div class="self-end">
                    <button type="submit" class="bg-orange-500 hover:bg-orange-600 text-white px-4 py-2 rounded flex items-center">
                        <i class="fas fa-filter mr-2"></i>Lọc
                    </button>
                </div>
                
                <div class="self-end">
                    <a href="manage-order" class="bg-gray-200 hover:bg-gray-300 text-gray-800 px-4 py-2 rounded flex items-center">
                        <i class="fas fa-sync-alt mr-2"></i>Reset
                    </a>
                </div>
            </form>
        </div>

        <!-- Bảng đơn hàng -->
        <div class="bg-white rounded-lg shadow overflow-hidden">
            <div class="overflow-x-auto">
                <table class="w-full table-auto">
                    <thead class="bg-gray-50">
                        <tr class="text-left text-gray-600 uppercase text-sm">
                            <th class="px-6 py-3 font-medium">Mã đơn</th>
                            <th class="px-6 py-3 font-medium">Ngày đặt</th>
                            <th class="px-6 py-3 font-medium">Khách hàng</th>
                            <th class="px-6 py-3 font-medium text-right">Tổng tiền</th>
                            <th class="px-6 py-3 font-medium">Thanh toán</th>
                            <th class="px-6 py-3 font-medium">Trạng thái</th>
                            <th class="px-6 py-3 font-medium text-center">Hành động</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-gray-200">
                        <% if (orders != null && !orders.isEmpty()) {
                            for (Order o : orders) { %>
                        <tr class="order-row hover:bg-gray-50">
                            <td class="px-6 py-4">
                                <span class="font-medium text-blue-600">#<%= o.getOrderId() %></span>
                            </td>
                            <td class="px-6 py-4">
                                <%= dateFormat.format(o.getOrderDate()) %>
                            </td>
                            <td class="px-6 py-4">
                                <div class="font-medium"><%= o.getCustomerName() %></div>
                                <% if (o.getShippingAddress() != null && !o.getShippingAddress().isEmpty()) { %>
                                    <div class="text-sm text-gray-500 mt-1" title="<%= o.getShippingAddress() %>">
                                        <i class="fas fa-map-marker-alt mr-1"></i>
                                        <%= o.getShippingAddress().length() > 20 ? 
                                            o.getShippingAddress().substring(0, 20) + "..." : 
                                            o.getShippingAddress() %>
                                    </div>
                                <% } %>
                            </td>
                            <td class="px-6 py-4 text-right font-medium">
                                <%= String.format("%,.0f", o.getTotalAmount()) %> đ
                            </td>
                            <td class="px-6 py-4">
                                <div class="flex flex-col">
                                    <span class="text-sm font-medium"><%= o.getPaymentMethod() %></span>
                                    <span class="text-xs <%= "Đã thanh toán".equals(o.getPaymentStatus()) ? "text-green-600" : "text-yellow-600" %>">
                                        <%= o.getPaymentStatus() %>
                                    </span>
                                </div>
                            </td>
                            <td class="px-6 py-4">
                                <% if ("Đang xử lý".equals(o.getStatus())) { %>
                                    <form method="post" action="update-order-status" onsubmit="return confirm('Bạn có chắc muốn thay đổi trạng thái đơn hàng #<%= o.getOrderId() %>?');">
                                        <input type="hidden" name="orderId" value="<%= o.getOrderId() %>">
                                        <div class="flex items-center gap-2">
                                            <select name="newStatus" class="border px-2 py-1 rounded text-sm focus:ring-orange-500 focus:border-orange-500">
                                                <option value="Đang xử lý" selected>Đang xử lý</option>
                                                <option value="Hoàn tất">Hoàn tất</option>
                                                <option value="Đã hủy">Đã hủy</option>
                                            </select>
                                            <button type="submit" class="bg-blue-500 hover:bg-blue-600 text-white px-2 py-1 rounded text-sm flex items-center">
                                                <i class="fas fa-save mr-1"></i>Lưu
                                            </button>
                                        </div>
                                    </form>
                                <% } else { %>
                                    <span class="status-badge <%= 
                                        "Đang xử lý".equals(o.getStatus()) ? "processing" : 
                                        "Hoàn tất".equals(o.getStatus()) ? "completed" : "cancelled" %>">
                                        <i class="<%= 
                                            "Đang xử lý".equals(o.getStatus()) ? "fas fa-spinner mr-1" : 
                                            "Hoàn tất".equals(o.getStatus()) ? "fas fa-check-circle mr-1" : "fas fa-times-circle mr-1" %>"></i>
                                        <%= o.getStatus() %>
                                    </span>
                                <% } %>
                            </td>
                            <td class="px-6 py-4 text-center">
                                <div class="flex justify-center space-x-2">
                                    <a href="order-detail?orderId=<%= o.getOrderId() %>"
                                       class="text-blue-600 hover:text-blue-800 p-1 rounded-full hover:bg-blue-50"
                                       title="Xem chi tiết">
                                        <i class="fas fa-eye"></i>
                                    </a>
                                    <a href="#" 
                                       class="text-orange-600 hover:text-orange-800 p-1 rounded-full hover:bg-orange-50"
                                       title="In hóa đơn">
                                        <i class="fas fa-print"></i>
                                    </a>
                                </div>
                            </td>
                        </tr>
                        <% }
                        } else { %>
                        <tr>
                            <td colspan="7" class="px-6 py-4 text-center text-gray-500">
                                <div class="flex flex-col items-center justify-center py-8">
                                    <i class="fas fa-clipboard-list text-4xl text-gray-300 mb-2"></i>
                                    <p class="text-lg">Không tìm thấy đơn hàng nào</p>
                                    <% if (!keyword.isEmpty() || !"all".equals(statusFilter)) { %>
                                        <a href="manage-order" class="text-blue-600 hover:underline mt-2">
                                            <i class="fas fa-sync-alt mr-1"></i>Xóa bộ lọc
                                        </a>
                                    <% } %>
                                </div>
                            </td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
            
            <!-- Phân trang -->
            <% if (orders != null && !orders.isEmpty()) { %>
            <div class="pagination bg-gray-50 px-6 py-3 border-t">
                <a href="#" class="active">1</a>
                <a href="#">2</a>
                <a href="#">3</a>
                <a href="#"><i class="fas fa-chevron-right"></i></a>
            </div>
            <% } %>
        </div>
    </div>
    
    <script>
        // Tự động ẩn thông báo sau 5 giây
        setTimeout(() => {
            const alerts = document.querySelectorAll('[role="alert"]');
            alerts.forEach(alert => {
                alert.style.transition = 'opacity 1s ease-out';
                alert.style.opacity = '0';
                setTimeout(() => alert.remove(), 1000);
            });
        }, 5000);
        
        // Xác nhận trước khi hủy đơn hàng
        function confirmCancel(orderId) {
            return confirm(`Bạn có chắc chắn muốn hủy đơn hàng #${orderId}?`);
        }
    </script>
</body>
</html>