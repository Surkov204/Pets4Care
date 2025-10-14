<%@page import="model.OrderStats"%>
<%@page import="java.util.Map"%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="model.Customer" %>
<%
    List<Customer> customers = (List<Customer>) request.getAttribute("customers");
    Map<Integer, OrderStats> orderStats = (Map<Integer, OrderStats>) request.getAttribute("orderStats");
    String keyword = request.getParameter("keyword") != null ? request.getParameter("keyword") : "";
    String statusFilter = request.getParameter("status") != null ? request.getParameter("status") : "all";
%>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <title>Quản lý khách hàng</title>
        <script src="https://cdn.tailwindcss.com"></script>
    </head>
    <body class="bg-gray-100 min-h-screen font-sans flex">


        <!-- Sidebar -->
        <div class="w-1/5 bg-white shadow h-screen p-6 fixed top-0 left-0 border-r border-orange-100">
            <h2 class="text-xl font-bold text-orange-600 mb-6 font-baloo">📋 Danh mục quản lý</h2>
            <ul class="space-y-3">
                <li>
                    <a href="toys?action=list"
                       class="block px-3 py-2 rounded-md text-blue-600 hover:bg-orange-50 hover:text-orange-700 transition font-medium">
                        🧸 Sản phẩm
                    </a>
                </li>
                <li>
                    <a href="SupplierServlet?action=list"
                       class="block px-3 py-2 rounded-md text-blue-600 hover:bg-orange-50 hover:text-orange-700 transition font-medium">
                        🏢 Nhà cung cấp
                    </a>
                </li>
                <li>
                    <a href="manage-customer"
                       class="block px-3 py-2 rounded-md text-blue-600 hover:bg-orange-50 hover:text-orange-700 transition font-semibold">
                        👤 Khách hàng
                    </a>
                </li>
                <li>
                    <a href="manage-order"
                       class="block px-3 py-2 rounded-md text-blue-600 hover:bg-orange-50 hover:text-orange-700 transition font-medium">
                        📦 Đơn hàng
                    </a>
                </li>
                <li>
                    <a href="statistics?type=day"
                       class="block px-3 py-2 rounded-md text-blue-600 hover:bg-orange-50 hover:text-orange-700 transition font-medium">
                        📈 Thống kê
                    </a>
                </li>
            </ul>

            <div class="mt-10 space-y-2">
                <a href="dashboard.jsp"
                   class="block text-center bg-gray-100 hover:bg-gray-200 text-sm text-gray-700 font-medium py-2 px-3 rounded-md transition">
                    🔙 Quay về Dashboard
                </a>
                <a href="../home"
                   class="block text-center bg-orange-100 hover:bg-orange-200 text-sm text-orange-800 font-medium py-2 px-3 rounded-md transition">
                    🏠 Về trang chủ
                </a>
            </div>
        </div>


        <!-- Main Content -->
        <div class="ml-[20%] w-[80%] p-8">
            <div class="mb-6 border-b pb-4">
                <h1 class="text-2xl font-bold text-orange-600">👤 Quản lý khách hàng</h1>
            </div>

            <div class="grid grid-cols-2 md:grid-cols-4 gap-4 mb-6">
                <div class="bg-white p-4 rounded shadow text-center">
                    <h3 class="text-gray-500 text-sm">Khách đang hoạt động</h3>
                    <div class="text-xl font-bold text-green-600">${activeCount}</div>
                </div>
                <div class="bg-white p-4 rounded shadow text-center">
                    <h3 class="text-gray-500 text-sm">Khách bị khóa</h3>
                    <div class="text-xl font-bold text-red-600">${inactiveCount}</div>
                </div>
            </div>

            <form method="get" action="manage-customer" class="flex items-center gap-2 mb-4">
                <input type="text" name="keyword" placeholder="Tìm theo tên hoặc email" value="<%= keyword%>"
                       class="border px-3 py-2 rounded w-72" />
                <select name="status" class="border px-2 py-2 rounded text-sm">
                    <option value="all" <%= "all".equals(statusFilter) ? "selected" : ""%>>Tất cả</option>
                    <option value="active" <%= "active".equals(statusFilter) ? "selected" : ""%>>Đang hoạt động</option>
                    <option value="inactive" <%= "inactive".equals(statusFilter) ? "selected" : ""%>>Đã bị khóa</option>
                </select>
                <button type="submit" class="bg-blue-500 hover:bg-blue-600 text-white px-4 py-2 rounded">Lọc / Tìm</button>
            </form>

            <div class="overflow-x-auto">
                <table class="w-full table-auto border border-collapse bg-white shadow text-sm">
                    <thead class="bg-gray-100 text-gray-700 font-semibold">
                        <tr>
                            <th class="border px-4 py-2">ID</th>
                            <th class="border px-4 py-2">Tên</th>
                            <th class="border px-4 py-2">Email</th>
                            <th class="border px-4 py-2">Google ID</th>
                            <th class="border px-4 py-2">SĐT</th>
                            <th class="border px-4 py-2">Địa chỉ</th>
                            <th class="border px-4 py-2">Số đơn</th>
                            <th class="border px-4 py-2">Tổng tiền</th>
                            <th class="border px-4 py-2">Đơn gần nhất</th>
                            <th class="border px-4 py-2">Trạng thái</th>
                            <th class="border px-4 py-2">Khóa/Mở</th>
                            <th class="border px-4 py-2">Đơn hàng</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% if (customers != null && !customers.isEmpty()) {
                                for (Customer c : customers) {
                                    OrderStats stats = orderStats.get(c.getCustomerId());
                        %>
                        <tr class="hover:bg-gray-50">
                            <td class="border px-4 py-2"><%= c.getCustomerId()%></td>
                            <td class="border px-4 py-2"><%= c.getName()%></td>
                            <td class="border px-4 py-2"><%= c.getEmail()%></td>
                            <td class="border px-4 py-2"><%= c.getGoogleId() != null ? c.getGoogleId() : "-"%></td>
                            <td class="border px-4 py-2"><%= c.getPhone()%></td>
                            <td class="border px-4 py-2"><%= c.getAddressCustomer()%></td>
                            <td class="border px-4 py-2 text-center"><%= stats.getTotalOrders()%></td>
                            <td class="border px-4 py-2 text-right"><%= String.format("%,.0f", stats.getTotalAmount())%> đ</td>
                            <td class="border px-4 py-2 text-center"><%= stats.getLatestStatus() != null ? stats.getLatestStatus() : "-"%></td>
                            <td class="border px-4 py-2"><%= c.getStatus() != null && c.getStatus().equals("active") ? "Đang hoạt động" : "Đã bị khóa"%></td>
                            <td class="border px-4 py-2 text-center">
                                <form action="manage-customer" method="post" onsubmit="return confirm('Bạn có chắc không?')">
                                    <input type="hidden" name="action" value="toggle-status" />
                                    <input type="hidden" name="customerId" value="<%= c.getCustomerId()%>" />
                                    <input type="hidden" name="currentStatus" value="<%= c.getStatus()%>" />
                                    <button class="px-3 py-1 rounded text-white <%= c.getStatus() != null && c.getStatus().equals("active") ? "bg-red-600 hover:bg-red-700" : "bg-green-600 hover:bg-green-700"%>">
                                        <%= c.getStatus() != null && c.getStatus().equals("active") ? "Khóa" : "Mở"%>
                                    </button>

                                </form>
                            </td>
                            <td class="border px-4 py-2 text-center">
                                <a href="customer-orders?customerId=<%= c.getCustomerId()%>"
                                   class="inline-block bg-blue-500 hover:bg-blue-600 text-white px-3 py-1 rounded transition">
                                    Xem đơn hàng
                                </a>
                            </td>
                        </tr>
                        <% }
                } else { %>
                        <tr>
                            <td colspan="12" class="text-center text-gray-500 py-4">Không tìm thấy khách hàng nào.</td>
                        </tr>
                        <% }%>
                    </tbody>
                </table>
            </div>
        </div>
    </body>
</html>
