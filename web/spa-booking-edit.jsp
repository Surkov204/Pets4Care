<%@page import="model.Customer"%>
<%@page import="model.Booking"%>
<%@page import="model.PetServiceModel"%>
<%@page import="java.util.List"%>
<%@page import="java.util.ArrayList"%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%
    Customer currentUser = (Customer) session.getAttribute("currentUser");
    Booking booking = (Booking) request.getAttribute("booking");
    List<PetServiceModel> spaServices = (List<PetServiceModel>) request.getAttribute("spaServices");
    String errorMessage = (String) request.getAttribute("errorMessage");
    String successMessage = (String) request.getAttribute("successMessage");
    
    if (spaServices == null) spaServices = new ArrayList<>();
    
    if (booking == null) {
        response.sendRedirect(request.getContextPath() + "/spa-booking?action=history");
        return;
    }
%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>✏️ Chỉnh sửa lịch hẹn Spa - Petcity</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.3/css/all.min.css" rel="stylesheet" />
    <link href="https://fonts.googleapis.com/css2?family=Quicksand:wght@300;400;500;600;700&family=Nunito:wght@300;400;500;600;700;800&family=Baloo+2:wght@400;500;600;700;800&display=swap" rel="stylesheet" />
    <link rel="stylesheet" href="css/homeStyle.css" />
    <style>
        .edit-card {
            transition: all 0.3s ease;
            border-radius: 15px;
            overflow: hidden;
            box-shadow: 0 4px 15px rgba(0,0,0,0.1);
        }
        .edit-card:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 25px rgba(0,0,0,0.15);
        }
    </style>
</head>
<body class="bg-gray-50">
    <!-- Header -->
    <header class="bg-white shadow-sm border-b">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div class="flex justify-between items-center py-4">
                <div class="flex items-center">
                    <a href="<%= request.getContextPath()%>/home" class="text-2xl font-bold text-gray-800">
                        🐾 Petcity
                    </a>
                </div>
                <div class="flex items-center space-x-4">
                    <% if (currentUser != null) { %>
                    <span class="text-gray-600">Xin chào, <%= currentUser.getFullName() %></span>
                    <a href="<%= request.getContextPath()%>/logout" class="text-red-600 hover:text-red-800">Đăng xuất</a>
                    <% } %>
                </div>
            </div>
        </div>
    </header>

    <!-- Main Content -->
    <div class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <!-- Page Title -->
        <div class="text-center mb-8">
            <h1 class="text-3xl font-bold text-gray-800 mb-2">✏️ Chỉnh sửa lịch hẹn Spa</h1>
            <p class="text-gray-600">Cập nhật thông tin lịch hẹn của bạn</p>
        </div>

        <!-- Error/Success Messages -->
        <% if (errorMessage != null) { %>
        <div class="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded mb-6">
            <div class="flex items-center">
                <i class="fas fa-exclamation-circle mr-2"></i>
                <%= errorMessage %>
            </div>
        </div>
        <% } %>

        <% if (successMessage != null) { %>
        <div class="bg-green-100 border border-green-400 text-green-700 px-4 py-3 rounded mb-6">
            <div class="flex items-center">
                <i class="fas fa-check-circle mr-2"></i>
                <%= successMessage %>
            </div>
        </div>
        <% } %>

        <!-- Edit Form -->
        <div class="edit-card bg-white">
            <div class="p-6">
                <form action="<%= request.getContextPath()%>/spa-booking" method="post" class="space-y-6">
                    <input type="hidden" name="action" value="update-spa-booking">
                    <input type="hidden" name="bookingId" value="<%= booking.getBookingId() %>">
                    
                    <!-- Current Booking Info -->
                    <div class="bg-blue-50 border border-blue-200 rounded-lg p-4 mb-6">
                        <h3 class="text-lg font-semibold text-blue-800 mb-3">📋 Thông tin booking hiện tại</h3>
                        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                            <div>
                                <label class="block text-sm font-medium text-gray-700">Dịch vụ:</label>
                                <p class="text-gray-900 font-medium"><%= booking.getServiceNames() %></p>
                            </div>
                            <div>
                                <label class="block text-sm font-medium text-gray-700">Trạng thái:</label>
                                <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium
                                    <% if ("pending".equals(booking.getStatus())) { %>bg-yellow-100 text-yellow-800<% } %>
                                    <% if ("confirmed".equals(booking.getStatus())) { %>bg-green-100 text-green-800<% } %>
                                    <% if ("cancelled".equals(booking.getStatus())) { %>bg-red-100 text-red-800<% } %>
                                    <% if ("completed".equals(booking.getStatus())) { %>bg-blue-100 text-blue-800<% } %>">
                                    <% if ("pending".equals(booking.getStatus())) { %>⏳ Đang chờ xác nhận<% } %>
                                    <% if ("confirmed".equals(booking.getStatus())) { %>✅ Đã xác nhận<% } %>
                                    <% if ("cancelled".equals(booking.getStatus())) { %>❌ Đã hủy<% } %>
                                    <% if ("completed".equals(booking.getStatus())) { %>✅ Hoàn thành<% } %>
                                </span>
                            </div>
                            <div>
                                <label class="block text-sm font-medium text-gray-700">Ngày hẹn:</label>
                                <p class="text-gray-900"><fmt:formatDate value="<%= booking.getAppointmentStart() %>" pattern="dd/MM/yyyy HH:mm"/></p>
                            </div>
                            <div>
                                <label class="block text-sm font-medium text-gray-700">Tạo lúc:</label>
                                <p class="text-gray-900"><fmt:formatDate value="<%= booking.getCreatedAt() %>" pattern="dd/MM/yyyy HH:mm"/></p>
                            </div>
                        </div>
                    </div>

                    <!-- New Appointment Time -->
                    <div class="bg-green-50 border border-green-200 rounded-lg p-4">
                        <h3 class="text-lg font-semibold text-green-800 mb-3">📅 Cập nhật thời gian hẹn</h3>
                        
                        <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
                            <div>
                                <label for="appointmentDate" class="block text-sm font-medium text-gray-700 mb-2">Ngày hẹn:</label>
                                <input type="date" id="appointmentDate" name="appointmentDate" required
                                       class="w-full border border-gray-300 rounded-md px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent">
                            </div>
                            <div>
                                <label for="appointmentHour" class="block text-sm font-medium text-gray-700 mb-2">Giờ:</label>
                                <select id="appointmentHour" name="appointmentHour" required
                                        class="w-full border border-gray-300 rounded-md px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent">
                                    <option value="">Chọn giờ</option>
                                    <% for (int hour = 8; hour <= 20; hour++) { %>
                                    <option value="<%= String.format("%02d", hour) %>"><%= String.format("%02d", hour) %></option>
                                    <% } %>
                                </select>
                            </div>
                            <div>
                                <label for="appointmentMinute" class="block text-sm font-medium text-gray-700 mb-2">Phút:</label>
                                <select id="appointmentMinute" name="appointmentMinute" required
                                        class="w-full border border-gray-300 rounded-md px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent">
                                    <option value="">Chọn phút</option>
                                    <option value="00">00</option>
                                    <option value="15">15</option>
                                    <option value="30">30</option>
                                    <option value="45">45</option>
                                </select>
                            </div>
                        </div>
                    </div>

                    <!-- Note -->
                    <div>
                        <label for="note" class="block text-sm font-medium text-gray-700 mb-2">Ghi chú:</label>
                        <textarea id="note" name="note" rows="3" 
                                  class="w-full border border-gray-300 rounded-md px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                                  placeholder="Nhập ghi chú cho lịch hẹn..."><%= booking.getNote() != null ? booking.getNote() : "" %></textarea>
                    </div>

                    <!-- Action Buttons -->
                    <div class="flex justify-between items-center pt-6 border-t">
                        <a href="<%= request.getContextPath()%>/spa-booking?action=history" 
                           class="px-6 py-3 bg-gray-500 text-white rounded-lg hover:bg-gray-600 transition duration-300">
                            <i class="fas fa-arrow-left mr-2"></i>Quay lại
                        </a>
                        
                        <div class="flex space-x-3">
                            <button type="submit" 
                                    class="px-6 py-3 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition duration-300"
                                    onclick="return confirm('Bạn có chắc chắn muốn cập nhật lịch hẹn này?')">
                                <i class="fas fa-save mr-2"></i>Cập nhật lịch hẹn
                            </button>
                        </div>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <script>
        // Set default values from current booking
        document.addEventListener('DOMContentLoaded', function() {
            const appointmentStart = new Date('<%= booking.getAppointmentStart() %>');
            
            // Set date
            const dateInput = document.getElementById('appointmentDate');
            dateInput.value = appointmentStart.toISOString().split('T')[0];
            
            // Set hour
            const hourSelect = document.getElementById('appointmentHour');
            hourSelect.value = String(appointmentStart.getHours()).padStart(2, '0');
            
            // Set minute
            const minuteSelect = document.getElementById('appointmentMinute');
            minuteSelect.value = String(appointmentStart.getMinutes()).padStart(2, '0');
        });
    </script>
</body>
</html>
