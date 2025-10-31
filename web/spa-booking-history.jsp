<%@page import="model.Customer"%>
<%@page import="model.Booking"%>
<%@page import="model.BookingServiceItem"%>
<%@page import="java.util.List"%>
<%@page import="java.util.ArrayList"%>
<%@page import="java.util.Map"%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%
    Customer currentUser = (Customer) session.getAttribute("currentUser");
    List<Booking> spaBookings = (List<Booking>) request.getAttribute("spaBookings");
    @SuppressWarnings("unchecked")
    Map<Integer, String> spaStatusMap = (Map<Integer, String>) request.getAttribute("spaStatusMap");
    List<Map<String, Object>> boardingServices = (List<Map<String, Object>>) request.getAttribute("boardingServices");
    String errorMessage = (String) request.getAttribute("error");
    String successMessage = (String) request.getAttribute("success");
    
    // Lấy thông báo từ session (cho redirect)
    if (errorMessage == null) errorMessage = (String) session.getAttribute("errorMessage");
    if (successMessage == null) successMessage = (String) session.getAttribute("successMessage");
    
    // Xóa thông báo khỏi session sau khi hiển thị
    if (session.getAttribute("errorMessage") != null) session.removeAttribute("errorMessage");
    if (session.getAttribute("successMessage") != null) session.removeAttribute("successMessage");
    
    if (spaBookings == null) spaBookings = new ArrayList<>();
    if (boardingServices == null) boardingServices = new ArrayList<>();
    if (spaStatusMap == null) spaStatusMap = new java.util.HashMap<>();
%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>📋 Lịch sử đặt lịch Spa - Petcity</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.3/css/all.min.css" rel="stylesheet" />
    <link href="https://fonts.googleapis.com/css2?family=Quicksand:wght@300;400;500;600;700&family=Nunito:wght@300;400;500;600;700;800&family=Baloo+2:wght@400;500;600;700;800&display=swap" rel="stylesheet" />
    <link rel="stylesheet" href="css/homeStyle.css" />
    <style>
        .booking-card {
            transition: all 0.3s ease;
            border-radius: 15px;
            overflow: hidden;
            box-shadow: 0 4px 15px rgba(0,0,0,0.1);
        }
        .booking-card:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 25px rgba(0,0,0,0.15);
        }
        .status-pending {
            background: linear-gradient(135deg, #fbbf24, #f59e0b);
            color: white;
        }
        .status-confirmed {
            background: linear-gradient(135deg, #10b981, #059669);
            color: white;
        }
        .status-cancelled {
            background: linear-gradient(135deg, #ef4444, #dc2626);
            color: white;
        }
        .status-completed {
            background: linear-gradient(135deg, #6366f1, #4f46e5);
            color: white;
        }
        .btn-primary {
            background: linear-gradient(135deg, #3b82f6, #2563eb);
            color: white;
            padding: 0.5rem 1rem;
            border-radius: 8px;
            text-decoration: none;
            font-weight: bold;
            transition: all 0.3s ease;
            display: inline-block;
        }
        .btn-primary:hover {
            transform: translateY(-1px);
            box-shadow: 0 4px 12px rgba(59, 130, 246, 0.4);
        }
        .btn-danger {
            background: linear-gradient(135deg, #ef4444, #dc2626);
            color: white;
            padding: 0.5rem 1rem;
            border-radius: 8px;
            text-decoration: none;
            font-weight: bold;
            transition: all 0.3s ease;
            display: inline-block;
        }
        .btn-danger:hover {
            transform: translateY(-1px);
            box-shadow: 0 4px 12px rgba(239, 68, 68, 0.4);
        }
    </style>
</head>
<body class="bg-gray-50">
    <!-- Top Bar -->
    <div class="top-bar">
        <div class="left">🐾 PETCITY - SIÊU THỊ THÚ CƯNG ONLINE 🐾</div>
        <div class="right">
            <div>✨ CẦN LÀ CÓ - MÒ LÀ THẤY ✨</div>
            <a href="#" title="Facebook"><i class="fab fa-facebook-f"></i></a>
            <a href="#" title="Instagram"><i class="fab fa-instagram"></i></a>
            <a href="#" title="Twitter"><i class="fab fa-twitter"></i></a>
            <a href="#" title="Email"><i class="fas fa-envelope"></i></a>
        </div>
    </div>

    <!-- Header -->
    <header class="header-bar">
        <a href="<%= request.getContextPath()%>/home" class="logo">
            <img src="https://storage.googleapis.com/a1aa/image/15870274-75b6-4029-e89c-1424dc010c18.jpg" width="60" height="60" alt="Logo Petcity" />
            <div>
                <div class="logo-text">petcity</div>
                <div class="logo-subtext">thành phố thú cưng</div>
            </div>
        </a>

        <form class="search-form relative" method="get" action="search" autocomplete="off">
            <input type="text" name="keyword" placeholder="🔍 Tìm kiếm dịch vụ..." required>
            <button type="submit"><i class="fas fa-search"></i></button>
        </form>

        <div class="contact-info">
            <div><i class="far fa-clock"></i> 08:00 - 17:00</div>
            <div>
                <% if (currentUser == null) { %>
                <a href="login.jsp" class="text-sm hover:underline">👤 Đăng Ký | Đăng Nhập</a>
                <% } else { %>
                <div class="relative inline-block text-left">
                    <button type="button" id="userToggleBtn"
                            class="inline-flex justify-center w-full rounded-md border border-gray-300 shadow-sm px-3 py-1 bg-white text-sm font-medium text-gray-700 hover:bg-gray-50">
                        👤 Xin chào, <b><%= currentUser.getName()%></b>
                        <svg class="-mr-1 ml-2 h-5 w-5" xmlns="http://www.w3.org/2000/svg" fill="none"
                             viewBox="0 0 24 24" stroke="currentColor" aria-hidden="true">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                              d="M19 9l-7 7-7-7" />
                        </svg>
                    </button>
                    <div class="origin-top-right absolute right-0 mt-2 w-56 rounded-md shadow-lg bg-white ring-1 ring-black ring-opacity-5 hidden z-50"
                         id="userMenu">
                        <div class="py-1">
                            <a href="user/user-info.jsp"
                               class="text-gray-700 block px-4 py-2 text-sm hover:bg-gray-100">👤 Thông tin tài khoản</a>
                            <a href="logout.jsp"
                               class="text-gray-700 block px-4 py-2 text-sm hover:bg-gray-100">🚪 Đăng xuất</a>
                        </div>
                    </div>
                </div>
                <% } %>
            </div>
            <div>
                <a href="<%= request.getContextPath()%>/spa-service">
                    <i class="fas fa-spa"></i> Dịch vụ Spa
                </a>
            </div>
            <div>
                <a href="<%= request.getContextPath()%>/spa-booking?action=cart">
                    <i class="fas fa-shopping-cart"></i> Giỏ Spa
                </a>
            </div>
        </div>
    </header>

    <!-- Navigation -->
    <nav>
        <ul>
            <li><a href="<%= request.getContextPath()%>/home">TRANG CHỦ</a></li>
            <li><a href="<%= request.getContextPath()%>/spa-service">DỊCH VỤ</a></li>
            <li><a href="<%= request.getContextPath()%>/health-check-booking">ĐẶT LỊCH KHÁM</a></li>
            <li><a href="search?categoryId=2">SẢN PHẨM</a></li>
            <li><a href="doctor.jsp">BÁC SĨ</a></li>
            <li><a href="gioi-thieu.jsp">GIỚI THIỆU</a></li>
            <li><a href="tin-tuc.jsp">TIN TỨC</a></li>
            <li><a href="<%= request.getContextPath()%>/home">LIÊN HỆ</a></li>
        </ul>
    </nav>

    <!-- Main Content -->
    <main class="container mx-auto px-6 py-10">
        <div class="bg-white rounded-lg shadow-lg p-8">
            <!-- Header -->
            <div class="flex justify-between items-center mb-8">
                <div>
                    <h1 class="text-3xl font-bold text-gray-800 mb-2">📋 Lịch sử đặt lịch Spa</h1>
                    <p class="text-gray-600">Xem và quản lý các lịch hẹn spa của bạn</p>
                </div>
                <div class="flex space-x-4">
                    <a href="<%= request.getContextPath()%>/spa-service" class="btn-primary">
                        <i class="fas fa-plus mr-2"></i>Đặt lịch mới
                    </a>
                    <a href="<%= request.getContextPath()%>/spa-cart" class="btn-primary">
                        <i class="fas fa-shopping-cart mr-2"></i>Giỏ Spa
                    </a>
                </div>
            </div>

            <!-- Messages -->
            <% if (errorMessage != null) { %>
            <div id="errorAlert" class="p-4 mb-6 rounded-md bg-red-100 border-l-4 border-red-500" role="alert">
                <p class="font-bold text-red-600">⚠️ Lỗi</p>
                <p><%= errorMessage %></p>
            </div>
            <% } %>

            <% if (successMessage != null) { %>
            <div id="successAlert" class="p-4 mb-6 rounded-md bg-green-100 border-l-4 border-green-500" role="alert">
                <p class="font-bold text-green-600">✅ Thành công</p>
                <p><%= successMessage %></p>
            </div>
            <% } %>


            <!-- Boarding Services Section -->
            <div class="mb-8">
                <h2 class="text-2xl font-bold text-green-600 mb-4">🏠 Dịch vụ Lưu trú</h2>
                <form method="get" class="mb-4 flex flex-wrap items-center gap-2" action="spa-booking" id="dateForm">
                    <input type="hidden" name="action" value="history">
                    <button type="button" id="prevDayBtn" class="btn-primary">←</button>
                    <label>Ngày:
                        <input type="date" name="dateBoarding" id="boardingDateInput" value="<%= request.getParameter("dateBoarding") != null ? request.getParameter("dateBoarding") : "" %>" class="border rounded px-2 py-1 mx-1">
                    </label>
                    <button type="button" id="nextDayBtn" class="btn-primary">→</button>
                    <button type="submit" class="btn-primary ml-2">Xem ngày</button>
                </form>
                <script>
                    const boardingDateInput = document.getElementById('boardingDateInput');
                    document.getElementById('prevDayBtn').onclick = function() {
                        if (boardingDateInput.value) {
                            let d = new Date(boardingDateInput.value);
                            d.setDate(d.getDate()-1);
                            boardingDateInput.value = d.toISOString().slice(0,10);
                            document.getElementById('dateForm').submit();
                        }
                    };
                    document.getElementById('nextDayBtn').onclick = function() {
                        if (boardingDateInput.value) {
                            let d = new Date(boardingDateInput.value);
                            d.setDate(d.getDate()+1);
                            boardingDateInput.value = d.toISOString().slice(0,10);
                            document.getElementById('dateForm').submit();
                        }
                    };
                </script>
                <%
                    String dateParam = request.getParameter("date") != null ? request.getParameter("date") : "";
                %>
                <% if (boardingServices != null && !boardingServices.isEmpty()) { %>
                <div class="space-y-4">
                    <% for (Map<String, Object> boarding : boardingServices) { %>
                    <div class="bg-gradient-to-r from-green-50 to-blue-50 border-l-4 border-green-400 rounded-lg p-6">
                        <div class="flex justify-between items-start mb-4">
                            <div>
                                <h3 class="text-xl font-bold text-green-700 mb-2">
                                    <%= boarding.get("serviceName") %>
                                </h3>
                                <div class="flex items-center space-x-4 text-sm text-gray-600">
                                    <span><i class="fas fa-calendar-alt mr-1"></i>Nhận: <%= boarding.get("checkInDate") %></span>
                                    <span><i class="fas fa-calendar-check mr-1"></i>Trả: <%= boarding.get("checkOutDate") %></span>
                                    <span><i class="fas fa-paw mr-1"></i><%= boarding.get("petInfo") %></span>
                                </div>
                            </div>
                            <div class="text-right">
                                <div class="text-2xl font-bold text-green-600">
                                    <% 
                                    Object totalPriceObj = boarding.get("totalPrice");
                                    if (totalPriceObj instanceof java.math.BigDecimal) {
                                        java.math.BigDecimal totalPrice = (java.math.BigDecimal) totalPriceObj;
                                        out.print(String.format("%.0f", totalPrice.doubleValue()));
                                    } else if (totalPriceObj instanceof Double) {
                                        out.print(String.format("%.0f", (Double) totalPriceObj));
                                    } else {
                                        out.print("0");
                                    }
                                    %>₫
                                </div>
                                <div class="text-sm text-gray-500">Tổng cộng</div>
                            </div>
                        </div>
                        <div class="flex justify-between items-center">
                            <div class="flex items-center space-x-2">
                                <% 
                                String status = (String) boarding.get("status");
                                if (status == null) status = "pending";
                                %>
                                <span class="px-3 py-1 rounded-full text-sm font-medium
                                    <% if ("pending".equals(status)) { %>bg-yellow-100 text-yellow-800<% } %>
                                    <% if ("confirmed".equals(status)) { %>bg-green-100 text-green-800<% } %>
                                    <% if ("cancelled".equals(status)) { %>bg-red-100 text-red-800<% } %>
                                    <% if ("completed".equals(status)) { %>bg-blue-100 text-blue-800<% } %>">
                                    <% if ("pending".equals(status)) { %><i class="fas fa-clock mr-1"></i>Chờ xác nhận<% } %>
                                    <% if ("confirmed".equals(status)) { %><i class="fas fa-check mr-1"></i>Đã xác nhận<% } %>
                                    <% if ("cancelled".equals(status)) { %><i class="fas fa-ban mr-1"></i>Đã hủy<% } %>
                                    <% if ("completed".equals(status)) { %><i class="fas fa-check-circle mr-1"></i>Hoàn thành<% } %>
                                </span>
                            </div>
                            <div class="flex space-x-2">
                                <button onclick="viewBoardingDetails(<%= boarding.get("bookingId") %>)" 
                                        class="px-4 py-2 bg-blue-500 text-white rounded hover:bg-blue-600 transition">
                                    <i class="fas fa-eye mr-1"></i>Xem chi tiết
                                </button>
                                <% if (!"cancelled".equals(status)) { %>
                                <button onclick="cancelBoardingBooking(<%= boarding.get("bookingId") %>)" 
                                        class="px-4 py-2 bg-red-500 text-white rounded hover:bg-red-600 transition">
                                    <i class="fas fa-ban mr-1"></i>Hủy
                                </button>
                                <% } else { %>
                                <button onclick="deleteBoardingBooking(<%= boarding.get("bookingId") %>)" 
                                        class="px-4 py-2 bg-red-600 text-white rounded hover:bg-red-700 transition">
                                    <i class="fas fa-trash mr-1"></i>Xóa khỏi danh sách
                                </button>
                                <% } %>
                            </div>
                        </div>
                    </div>
                    <% } %>
                </div>
                <% } else { %>
                <div class="text-center py-8 bg-gray-50 rounded-lg">
                    <div class="text-4xl mb-3">🏠</div>
                    <h3 class="text-lg font-semibold text-gray-600 mb-2">Chưa có dịch vụ lưu trú nào</h3>
                    <p class="text-gray-500 mb-4">Bạn chưa đặt dịch vụ lưu trú nào cho thú cưng.</p>
                    <a href="<%= request.getContextPath()%>/spa-service" class="btn-primary">
                        <i class="fas fa-plus mr-2"></i>Đặt dịch vụ lưu trú
                    </a>
                </div>
                <% } %>
            </div>

            <!-- Spa Bookings Section -->
            <div class="mb-8">
                <h2 class="text-2xl font-bold text-orange-600 mb-4">💆 Lịch hẹn Spa</h2>
                <form method="get" class="mb-4 flex flex-wrap items-center gap-2" action="spa-booking" id="spaDateForm">
                    <input type="hidden" name="action" value="history">
                    <button type="button" id="spaPrevDayBtn" class="btn-primary">←</button>
                    <label>Ngày:
                        <input type="date" name="dateSpa" id="spaDateInput" value="<%= request.getParameter("dateSpa") != null ? request.getParameter("dateSpa") : "" %>" class="border rounded px-2 py-1 mx-1" />
                    </label>
                    <button type="button" id="spaNextDayBtn" class="btn-primary">→</button>
                    <button type="submit" class="btn-primary ml-2">Xem ngày</button>
                </form>
                <script>
                    const spaDateInput = document.getElementById('spaDateInput');
                    document.getElementById('spaPrevDayBtn').onclick = function() {
                        if (spaDateInput.value) {
                            let d = new Date(spaDateInput.value);
                            d.setDate(d.getDate()-1);
                            spaDateInput.value = d.toISOString().slice(0,10);
                            document.getElementById('spaDateForm').submit();
                        }
                    };
                    document.getElementById('spaNextDayBtn').onclick = function() {
                        if (spaDateInput.value) {
                            let d = new Date(spaDateInput.value);
                            d.setDate(d.getDate()+1);
                            spaDateInput.value = d.toISOString().slice(0,10);
                            document.getElementById('spaDateForm').submit();
                        }
                    };
                </script>
                <% if (spaBookings.isEmpty()) { %>
                <div class="text-center py-8 bg-gray-50 rounded-lg">
                    <div class="text-4xl mb-3">💆</div>
                    <h3 class="text-lg font-semibold text-gray-600 mb-2">Chưa có lịch hẹn spa nào</h3>
                    <p class="text-gray-500 mb-4">Bạn chưa có lịch hẹn spa nào. Hãy đặt lịch để thú cưng được chăm sóc!</p>
                    <a href="<%= request.getContextPath()%>/spa-service" class="btn-primary">
                        <i class="fas fa-calendar-plus mr-2"></i>Đặt lịch ngay
                    </a>
                </div>
                <% } else { %>
                <div class="space-y-6">
                    <% for (Booking booking : spaBookings) { %>
                    <div class="booking-card bg-white border border-gray-200">
                        <div class="p-6">
                            <div class="flex justify-between items-start mb-4">
                                <div>
                                    <h3 class="text-xl font-bold text-gray-800 mb-2">
                                        <% 
                                        // Lấy tên dịch vụ từ booking
                                        String serviceName = booking.getServiceNames();
                                        if (serviceName != null && !serviceName.trim().isEmpty()) {
                                            out.print(serviceName);
                                        } else {
                                            out.print("Lịch hẹn #" + booking.getBookingId());
                                        }
                                        %>
                                    </h3>
                                    <div class="flex items-center space-x-4 text-sm text-gray-600">
                                        <div class="flex items-center">
                                            <i class="fas fa-calendar mr-2"></i>
                                            <fmt:formatDate value="<%= booking.getAppointmentStart() %>" pattern="dd/MM/yyyy"/>
                                        </div>
                                        <div class="flex items-center">
                                            <i class="fas fa-clock mr-2"></i>
                                            <fmt:formatDate value="<%= booking.getAppointmentStart() %>" pattern="HH:mm"/>
                                            - 
                                            <fmt:formatDate value="<%= booking.getAppointmentEnd() %>" pattern="HH:mm"/>
                                        </div>
                                    </div>
                                </div>
                                <div class="text-right">
                                    <% 
                                        String displayStatus = spaStatusMap.get(booking.getBookingId());
                                        if (displayStatus == null || displayStatus.isEmpty()) {
                                            displayStatus = "Chưa thanh toán"; // default
                                        }
                                        String statusClass = "";
                                        String statusIcon = "";
                                        if (displayStatus.contains("Hoàn thành")) {
                                            statusClass = "status-completed";
                                            statusIcon = "✅";
                                        } else if (displayStatus.contains("Đã thanh toán")) {
                                            statusClass = "status-confirmed";
                                            statusIcon = "✅";
                                        } else {
                                            statusClass = "status-pending";
                                            statusIcon = "⏳";
                                        }
                                    %>
                                    <span class="px-3 py-1 rounded-full text-sm font-semibold <%= statusClass %>">
                                        <%= statusIcon %> <%= displayStatus %>
                                    </span>
                                </div>
                            </div>

                            <% if (booking.getNote() != null && !booking.getNote().trim().isEmpty()) { %>
                            <div class="mb-4">
                                <p class="text-gray-600"><strong>Ghi chú:</strong> <%= booking.getNote() %></p>
                            </div>
                            <% } %>

                            <div class="flex justify-between items-center">
                                <div class="text-sm text-gray-500">
                                    <i class="fas fa-calendar-plus mr-1"></i>
                                    Tạo lúc: <fmt:formatDate value="<%= booking.getCreatedAt() %>" pattern="dd/MM/yyyy HH:mm"/>
                                </div>
                                <div class="flex space-x-2">
                                    <a href="<%= request.getContextPath()%>/spa-booking?action=detail&id=<%= booking.getBookingId() %>" 
                                       class="btn-primary">
                                        <i class="fas fa-eye mr-1"></i>Xem chi tiết
                                    </a>
                                    <% 
                                    // Kiểm tra có thể chỉnh sửa không - chỉ cho phép chỉnh sửa khi đang pending
                                    boolean canEdit = "pending".equals(booking.getStatus());
                                    // Kiểm tra có thể hủy không - sử dụng trạng thái từ booking object thay vì query database
                                    boolean canCancel = "pending".equals(booking.getStatus()) || "confirmed".equals(booking.getStatus());
                                    %>
                                    
                                    <% if (canEdit) { %>
                                    <a href="<%= request.getContextPath()%>/spa-booking?action=edit&id=<%= booking.getBookingId() %>" 
                                       class="px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-700 transition">
                                        <i class="fas fa-edit mr-1"></i>Chỉnh sửa
                                    </a>
                                    <% } %>
                                    
                                    <% if (canCancel) { %>
                                    <form method="POST" action="<%= request.getContextPath()%>/spa-booking" style="display: inline;">
                                        <input type="hidden" name="action" value="cancel">
                                        <input type="hidden" name="bookingId" value="<%= booking.getBookingId() %>">
                                        <button type="submit" class="btn-danger" 
                                                onclick="return confirm('Bạn có chắc chắn muốn hủy lịch hẹn này?')">
                                            <i class="fas fa-times mr-1"></i>Hủy lịch
                                        </button>
                                    </form>
                                    <% } else if ("cancelled".equals(booking.getStatus())) { %>
                                    <button onclick="deleteSpaBooking(<%= booking.getBookingId() %>)" 
                                            class="px-4 py-2 bg-red-600 text-white rounded hover:bg-red-700 transition">
                                        <i class="fas fa-trash mr-1"></i>Xóa khỏi danh sách
                                    </button>
                                    <% } else if ("completed".equalsIgnoreCase(booking.getStatus()) || "đã thanh toán".equals(booking.getStatus()) || "hoàn thành".equalsIgnoreCase(booking.getStatus())) { %>
                                    <button onclick="deleteSpaBooking(<%= booking.getBookingId() %>)" 
                                            class="px-4 py-2 bg-gray-600 text-white rounded hover:bg-gray-700 transition">
                                        <i class="fas fa-trash mr-1"></i>Xóa khỏi lịch sử
                                    </button>
                                    <% } %>
                                </div>
                            </div>
                        </div>
                    </div>
                    <% } %>
                </div>
                <% } %>
            </div>
            
            <!-- Empty State for Both Sections -->
            <% if ((spaBookings == null || spaBookings.isEmpty()) && (boardingServices == null || boardingServices.isEmpty())) { %>
            <div class="text-center py-16 bg-gradient-to-br from-blue-50 to-purple-50 rounded-lg">
                <div class="text-8xl mb-6">🐾</div>
                <h2 class="text-3xl font-bold text-gray-700 mb-4">Chào mừng đến với Petcity!</h2>
                <p class="text-lg text-gray-600 mb-8">Bạn chưa có lịch hẹn nào. Hãy bắt đầu chăm sóc thú cưng ngay hôm nay!</p>
                <div class="flex justify-center space-x-4">
                    <a href="<%= request.getContextPath()%>/spa-service" class="btn-primary text-lg px-6 py-3">
                        <i class="fas fa-spa mr-2"></i>Dịch vụ Spa
                    </a>
                    <a href="<%= request.getContextPath()%>/health-check-booking" class="btn-primary text-lg px-6 py-3">
                        <i class="fas fa-stethoscope mr-2"></i>Khám sức khỏe
                    </a>
                </div>
            </div>
            <% } %>
        </div>
    </main>

    <!-- Footer -->
    <footer>
        <div class="footer-content">
            <div class="footer-section">
                <h3>🏪 Thông tin liên hệ</h3>
                <p>📍 Địa chỉ: Môn SWP</p>
                <p>📞 Điện thoại: 090 900 900</p>
                <p>📧 Email: support@petcity.vn</p>
            </div>
            <div class="footer-section">
                <h3>📋 Chính sách</h3>
                <p><a href="#">Chính sách bảo mật</a></p>
                <p><a href="#">Điều khoản sử dụng</a></p>
                <p><a href="#">Chính sách đổi trả</a></p>
            </div>
            <div class="footer-section">
                <h3>🌐 Kết nối với chúng tôi</h3>
                <div class="social-links">
                    <a href="#" title="Facebook"><i class="fab fa-facebook-f"></i></a>
                    <a href="#" title="Instagram"><i class="fab fa-instagram"></i></a>
                    <a href="#" title="Twitter"><i class="fab fa-twitter"></i></a>
                    <a href="#" title="YouTube"><i class="fab fa-youtube"></i></a>
                </div>
            </div>
        </div>
        <div class="footer-bottom">
            <p>© 2025 Petcity. Bản quyền thuộc về G5. ❤️ Made with love for pets</p>
        </div>
    </footer>

    <jsp:include page="chatbox.jsp"/>
    
    <script>
        // Auto-hide success/error messages after 10 seconds
        document.addEventListener('DOMContentLoaded', function() {
            const successAlert = document.getElementById('successAlert');
            const errorAlert = document.getElementById('errorAlert');
            
            if (successAlert) {
                setTimeout(function() {
                    successAlert.style.transition = 'opacity 0.5s ease-out';
                    successAlert.style.opacity = '0';
                    setTimeout(function() {
                        successAlert.remove();
                    }, 500);
                }, 10000); // 10 seconds
            }
            
            if (errorAlert) {
                setTimeout(function() {
                    errorAlert.style.transition = 'opacity 0.5s ease-out';
                    errorAlert.style.opacity = '0';
                    setTimeout(function() {
                        errorAlert.remove();
                    }, 500);
                }, 10000); // 10 seconds
            }
        });

        // User menu toggle
        document.addEventListener("DOMContentLoaded", function () {
            const btn = document.getElementById("userToggleBtn");
            const menu = document.getElementById("userMenu");

            if (btn && menu) {
                btn.addEventListener("click", function (e) {
                    e.stopPropagation();
                    menu.classList.toggle("hidden");
                });

                document.addEventListener("click", function (e) {
                    if (!menu.contains(e.target) && e.target !== btn) {
                        menu.classList.add("hidden");
                    }
                });
            }
        });
        
        // Boarding details functions
        // Biến theo dõi thay đổi chưa lưu trong modal
        let boardingModalDirty = false;
        let boardingModalInitialSnapshot = '';

        function viewBoardingDetails(bookingId) {
            // Redirect to boarding detail page
            window.location.href = '<%= request.getContextPath()%>/spa-booking?action=boarding-detail&id=' + bookingId;
        }
        
        function viewBoardingDetailsOld(serviceId) {
            fetch('<%= request.getContextPath()%>/spa-booking?action=get-boarding-details&serviceId=' + serviceId)
                .then(response => response.json())
                .then(data => {
                    if (!data.success) {
                        alert('Không thể tải chi tiết: ' + (data.message || 'Lỗi không xác định'));
                        return;
                    }

                    const d = data.boardingDetails || {};
                    const html =
                        '<div id="boardingModalRoot" class="fixed inset-0 bg-black bg-opacity-50 z-50 flex items-center justify-center p-4">' +
                          '<div class="bg-white rounded-lg max-w-2xl w-full max-h-[90vh] overflow-y-auto">' +
                            '<form id="boardingEditForm" class="p-6" oninput="boardingModalDirty=true">' +
                              '<div class="flex justify-between items-center mb-6">' +
                                '<h3 class="text-2xl font-bold text-gray-800">🏠 Chi tiết lưu trú</h3>' +
                                '<button type="button" onclick="closeViewModal()" class="text-gray-500 hover:text-gray-700"><i class="fas fa-times text-xl"></i></button>' +
                              '</div>' +

                              '<input type="hidden" name="serviceId" value="' + serviceId + '">' +
                              '<input type="hidden" name="action" value="update-boarding-details">' +
                              '<input type="hidden" name="pricePerDay" value="' + (d.pricePerDay || 0) + '">' +

                              '<div class="bg-gray-50 rounded-lg p-4 mb-4">' +
                                '<h4 class="font-semibold text-gray-800 mb-2">Thông tin phòng</h4>' +
                                '<div class="grid md:grid-cols-3 gap-3">' +
                                  '<div><label class="text-sm text-gray-600">Loại phòng</label><input name="roomType" value="' + (d.roomType || '') + '" class="w-full border rounded px-3 py-2"></div>' +
                                  '<div><label class="text-sm text-gray-600">Giá/ngày</label><input name="pricePerDayDisplay" value="' + (d.pricePerDay || 0) + '" class="w-full border rounded px-3 py-2" disabled></div>' +
                                  '<div><label class="text-sm text-gray-600">Số ngày</label><input type="number" min="0" max="30" name="boardingDays" value="' + (d.boardingDays || 0) + '" class="w-full border rounded px-3 py-2"></div>' +
                                '</div>' +
                              '</div>' +

                              '<div class="bg-blue-50 rounded-lg p-4 mb-4">' +
                                '<h4 class="font-semibold text-gray-800 mb-2">Thời gian lưu trú</h4>' +
                                '<div class="grid md:grid-cols-2 gap-3">' +
                                  '<div><label class="text-sm text-gray-600">Ngày nhận</label><input type="date" name="checkInDate" value="' + (d.checkInDate || '') + '" class="w-full border rounded px-3 py-2"></div>' +
                                  '<div><label class="text-sm text-gray-600">Ngày trả</label><input type="date" name="checkOutDate" value="' + (d.checkOutDate || '') + '" class="w-full border rounded px-3 py-2"></div>' +
                                  '<div><label class="text-sm text-gray-600">Giờ nhận</label><input name="checkInTime" value="' + (d.checkInTime || '') + '" class="w-full border rounded px-3 py-2"></div>' +
                                  '<div><label class="text-sm text-gray-600">Giờ trả</label><input name="checkOutTime" value="' + (d.checkOutTime || '') + '" class="w-full border rounded px-3 py-2"></div>' +
                                '</div>' +
                              '</div>' +

                              '<div class="bg-green-50 rounded-lg p-4 mb-4">' +
                                '<h4 class="font-semibold text-gray-800 mb-2">Thông tin thú cưng</h4>' +
                                '<textarea name="petInfo" rows="3" class="w-full border rounded px-3 py-2" placeholder="Tên thú cưng, loài, giống...">' + (d.petInfo || '') + '</textarea>' +
                                '<textarea name="specialNotes" rows="2" class="w-full border rounded px-3 py-2 mt-2" placeholder="Yêu cầu đặc biệt">' + (d.specialNotes || '') + '</textarea>' +
                              '</div>' +

                              '<div class="bg-yellow-50 rounded-lg p-4">' +
                                '<h4 class="font-semibold text-gray-800 mb-2">Liên hệ khẩn cấp</h4>' +
                                '<div class="grid md:grid-cols-2 gap-3">' +
                                  '<div><label class="text-sm text-gray-600">SĐT 1</label><input name="emergencyPhone1" value="' + (d.emergencyPhone1 || '') + '" class="w-full border rounded px-3 py-2"></div>' +
                                  '<div><label class="text-sm text-gray-600">SĐT 2</label><input name="emergencyPhone2" value="' + (d.emergencyPhone2 || '') + '" class="w-full border rounded px-3 py-2"></div>' +
                                '</div>' +
                              '</div>' +

                              '<div class="mt-6 flex justify-end gap-3">' +
                                '<button type="button" class="px-4 py-2 bg-gray-500 text-white rounded hover:bg-gray-600" onclick="closeViewModal()">Đóng</button>' +
                                '<button type="button" class="px-4 py-2 bg-green-600 text-white rounded hover:bg-green-700" onclick="saveBoardingDetails(' + serviceId + ')">Lưu</button>' +
                              '</div>' +
                            '</form>' +
                          '</div>' +
                        '</div>';

                    document.body.insertAdjacentHTML('beforeend', html);
                    // Lưu snapshot ban đầu để so sánh thay đổi
                    const form = document.getElementById('boardingEditForm');
                    boardingModalInitialSnapshot = new URLSearchParams(new FormData(form)).toString();
                    boardingModalDirty = false;
                    
                  })
                  .catch(err => {
                    console.error(err);
                    alert('Có lỗi xảy ra khi tải chi tiết');
                  });
        }

        function saveBoardingDetails(serviceId) {
            const form = document.getElementById('boardingEditForm');
            if (!form) return;
            const formData = new FormData(form);

            fetch('<%= request.getContextPath()%>/spa-booking', {
                method: 'POST',
                headers: { 'Accept': 'application/json' },
                body: formData
            })
            .then(res => res.json().catch(() => ({})))
            .then(res => {
                // Chấp nhận cả phản hồi JSON hoặc chuyển hướng
                boardingModalDirty = false;
                closeViewModal(true);
                // Reload để cập nhật lịch sử
                window.location.href = '<%= request.getContextPath()%>/spa-booking?action=history';
            })
            .catch(err => {
                console.error(err);
                alert('Không thể lưu thay đổi');
            });
        }
        
        function editBoardingDetails(serviceId) {
            // Show confirmation dialog for cancellation
            if (confirm('Bạn có chắc chắn muốn hủy lịch lưu trú này?')) {
                // Create a form and submit it like spa bookings
                const form = document.createElement('form');
                form.method = 'POST';
                form.action = '<%= request.getContextPath()%>/spa-booking';
                
                const actionInput = document.createElement('input');
                actionInput.type = 'hidden';
                actionInput.name = 'action';
                actionInput.value = 'remove-service';
                form.appendChild(actionInput);
                
                const serviceIdInput = document.createElement('input');
                serviceIdInput.type = 'hidden';
                serviceIdInput.name = 'serviceId';
                serviceIdInput.value = serviceId;
                form.appendChild(serviceIdInput);
                
                document.body.appendChild(form);
                form.submit();
            }
        }
        
        function closeViewModal(force) {
            const modal = document.getElementById('boardingModalRoot') || document.querySelector('.fixed.inset-0.bg-black.bg-opacity-50');
            if (!modal) return;

            if (!force && boardingModalDirty) {
                const confirmSave = confirm('Bạn có thay đổi chưa lưu. Bạn có muốn lưu trước khi thoát?');
                if (confirmSave) {
                    // Gọi lưu, sau đó sẽ đóng modal trong saveBoardingDetails
                    const form = document.getElementById('boardingEditForm');
                    if (form) {
                        const paramsNow = new URLSearchParams(new FormData(form)).toString();
                        if (paramsNow !== boardingModalInitialSnapshot) {
                            // Chỉ lưu nếu khác
                            const serviceId = form.querySelector('input[name="serviceId"]').value;
                            saveBoardingDetails(serviceId);
                            return;
                        }
                    }
                }
            }

            modal.remove();
            boardingModalDirty = false;
        }
        
        
        function cancelBoardingBooking(bookingId) {
            if (confirm('Bạn có chắc chắn muốn hủy lịch lưu trú này?')) {
                // Tạo form để hủy booking
            const form = document.createElement('form');
            form.method = 'POST';
            form.action = '<%= request.getContextPath()%>/spa-booking';
            
                const actionInput = document.createElement('input');
                actionInput.type = 'hidden';
                actionInput.name = 'action';
                actionInput.value = 'cancel-boarding-booking';
                form.appendChild(actionInput);
                
                const bookingIdInput = document.createElement('input');
                bookingIdInput.type = 'hidden';
                bookingIdInput.name = 'bookingId';
                bookingIdInput.value = bookingId;
                form.appendChild(bookingIdInput);
                
                document.body.appendChild(form);
                form.submit();
            }
        }
        
        function migrateSessionToDB() {
            if (confirm('Bạn có chắc chắn muốn migrate dữ liệu từ session sang database? Dữ liệu session sẽ bị xóa sau khi migrate.')) {
                // Tạo form để migrate
                const form = document.createElement('form');
                form.method = 'POST';
                form.action = '<%= request.getContextPath()%>/spa-booking';
                
                const actionInput = document.createElement('input');
                actionInput.type = 'hidden';
                actionInput.name = 'action';
                actionInput.value = 'migrate-session-to-db';
                form.appendChild(actionInput);
                
                document.body.appendChild(form);
                form.submit();
            }
        }
        
        function deleteBoardingBooking(bookingId) {
            if (confirm('Bạn có chắc chắn muốn xóa lịch lưu trú này khỏi danh sách? Hành động này không thể hoàn tác!')) {
                // Tạo form để xóa booking
                const form = document.createElement('form');
                form.method = 'POST';
                form.action = '<%= request.getContextPath()%>/spa-booking';
                
                const actionInput = document.createElement('input');
                actionInput.type = 'hidden';
                actionInput.name = 'action';
                actionInput.value = 'delete-boarding-booking';
                
                const bookingIdInput = document.createElement('input');
                bookingIdInput.type = 'hidden';
                bookingIdInput.name = 'bookingId';
                bookingIdInput.value = bookingId;
                
                form.appendChild(actionInput);
                form.appendChild(bookingIdInput);
                
                document.body.appendChild(form);
                form.submit();
            }
        }
        
        function deleteSpaBooking(bookingId) {
            if (confirm('Bạn có chắc chắn muốn xóa lịch spa này khỏi danh sách? Hành động này không thể hoàn tác!')) {
                // Tạo form để xóa booking
                const form = document.createElement('form');
                form.method = 'POST';
                form.action = '<%= request.getContextPath()%>/spa-booking';
                
                const actionInput = document.createElement('input');
                actionInput.type = 'hidden';
                actionInput.name = 'action';
                actionInput.value = 'delete-spa-booking';
                
                const bookingIdInput = document.createElement('input');
                bookingIdInput.type = 'hidden';
                bookingIdInput.name = 'bookingId';
                bookingIdInput.value = bookingId;
                
                form.appendChild(actionInput);
                form.appendChild(bookingIdInput);
                
                document.body.appendChild(form);
                form.submit();
            }
        }
    </script>
</body>
</html>

