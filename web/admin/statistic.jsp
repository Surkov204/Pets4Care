<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.List" %>
<%
    Map<String, Double> revenueData = (Map<String, Double>) request.getAttribute("revenueData");
    String type = (String) request.getAttribute("type");
    Double totalRevenue = (Double) request.getAttribute("totalRevenue");
    if (type == null) {
        type = "day";
    }
    List<String> labels = new ArrayList<>(revenueData.keySet());
    List<Double> values = new ArrayList<>(revenueData.values());

    StringBuilder labelJS = new StringBuilder("[");
    for (int i = 0; i < labels.size(); i++) {
        labelJS.append("'").append(labels.get(i).replace("'", "\\'")).append("'");
        if (i < labels.size() - 1) {
            labelJS.append(", ");
        }
    }
    labelJS.append("]");

    StringBuilder valueJS = new StringBuilder("[");
    for (int i = 0; i < values.size(); i++) {
        valueJS.append(values.get(i));
        if (i < values.size() - 1) {
            valueJS.append(", ");
        }
    }
    valueJS.append("]");
%>

<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <title>Thống kê doanh thu | Admin</title>
        <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
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
            <div class="flex justify-between items-center mb-6">
                <h1 class="text-2xl font-bold text-orange-600">📊 Thống kê doanh thu theo 
                    <%= "day".equals(type) ? "ngày" : "month".equals(type) ? "tháng" : "năm"%></h1>
                <div class="space-x-2">
                    <a href="statistics?type=day" class="px-4 py-2 bg-blue-500 text-white rounded hover:bg-blue-600">Ngày</a>
                    <a href="statistics?type=month" class="px-4 py-2 bg-blue-500 text-white rounded hover:bg-blue-600">Tháng</a>
                    <a href="statistics?type=year" class="px-4 py-2 bg-blue-500 text-white rounded hover:bg-blue-600">Năm</a>
                </div>
            </div>

            <div class="bg-white p-6 rounded shadow mb-4">
                <h3 class="text-lg font-semibold">Tổng doanh thu: <%= request.getAttribute("totalRevenueFormatted") %> ₫</h3>

            </div>

            <div class="bg-white p-6 rounded shadow">
                <canvas id="revenueChart" height="400"></canvas>
            </div>
        </div>

        <script>
            const labels = <%= labelJS.toString() %>;
            const values = <%= valueJS.toString() %>;

            const ctx = document.getElementById('revenueChart').getContext('2d');
            new Chart(ctx, {
                type: 'line',
                data: {
                    labels: labels,
                    datasets: [{
                            label: 'Doanh thu (VND)',
                            data: values,
                            borderColor: 'rgba(75, 192, 192, 1)',
                            backgroundColor: 'rgba(75, 192, 192, 0.2)',
                            fill: true,
                            tension: 0.3,
                            pointRadius: 4,
                            pointHoverRadius: 6
                        }]
                },
                options: {
                    responsive: true,
                    scales: {
                        y: {
                            beginAtZero: true,
                            ticks: {
                                callback: function (value) {
                                    return value.toLocaleString("vi-VN") + ' ₫';
                                }
                            }
                        }
                    },
                    plugins: {
                        legend: { position: 'top' },
                        title: { display: true, text: 'Biểu đồ Doanh thu' }
                    }
                }
            });
        </script>
    </body>
</html>