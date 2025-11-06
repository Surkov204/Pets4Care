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
    
    // Kiểm tra có cần hiển thị popup hoàn tiền không
    String showRefundPopup = (String) session.getAttribute("showRefundPopup");
    boolean showRefund = "true".equals(showRefundPopup);
    
    // Xóa thông báo khỏi session sau khi hiển thị
    if (session.getAttribute("errorMessage") != null) session.removeAttribute("errorMessage");
    if (session.getAttribute("successMessage") != null) session.removeAttribute("successMessage");
    if (session.getAttribute("showRefundPopup") != null) session.removeAttribute("showRefundPopup");
    
    if (spaBookings == null) spaBookings = new ArrayList<>();
    if (boardingServices == null) boardingServices = new ArrayList<>();
    if (spaStatusMap == null) spaStatusMap = new java.util.HashMap<>();
%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
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
        
        /* Cải thiện thông báo hoàn tiền */
        .refund-notice {
            animation: fadeInUp 0.4s ease-out;
        }
        
        @keyframes fadeInUp {
            from {
                opacity: 0;
                transform: translateY(10px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }
        
        /* Cải thiện status badge */
        .status-badge {
            transition: all 0.2s ease;
        }
        
        .status-badge:hover {
            transform: scale(1.05);
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
        </div>
    </header>

    <!-- Navigation -->
    <nav>
        <ul>
            <li><a href="<%= request.getContextPath()%>/home">TRANG CHỦ</a></li>
            <li><a href="<%= request.getContextPath()%>/spa-service">DỊCH VỤ</a></li>
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
                    <div class="bg-white border border-gray-200 rounded-xl shadow-sm hover:shadow-md transition-shadow duration-300 p-6">
                        <div class="flex justify-between items-start mb-5">
                            <div class="flex-1">
                                <h3 class="text-xl font-bold text-gray-800 mb-3">
                                    <%= boarding.get("serviceName") %>
                                </h3>
                                <div class="grid grid-cols-1 md:grid-cols-3 gap-3 text-sm text-gray-600 mb-4">
                                    <div class="flex items-center bg-gray-50 px-3 py-2 rounded-lg">
                                        <i class="fas fa-calendar-alt mr-2 text-blue-500"></i>
                                        <span class="font-medium">Nhận: <%= boarding.get("checkInDate") %> 
                                        <% if (boarding.get("checkInTime") != null && !boarding.get("checkInTime").toString().isEmpty()) { %>
                                        <span class="text-gray-500"><%= boarding.get("checkInTime") %></span>
                                        <% } %>
                                        </span>
                                    </div>
                                    <div class="flex items-center bg-gray-50 px-3 py-2 rounded-lg">
                                        <i class="fas fa-calendar-check mr-2 text-green-500"></i>
                                        <span class="font-medium">Trả: <%= boarding.get("checkOutDate") %> 
                                        <% if (boarding.get("checkOutTime") != null && !boarding.get("checkOutTime").toString().isEmpty()) { %>
                                        <span class="text-gray-500"><%= boarding.get("checkOutTime") %></span>
                                        <% } %>
                                        </span>
                                    </div>
                                    <div class="flex items-center bg-gray-50 px-3 py-2 rounded-lg">
                                        <i class="fas fa-paw mr-2 text-purple-500"></i>
                                        <span class="font-medium"><%= boarding.get("petInfo") %></span>
                                    </div>
                                </div>
                            </div>
                            <div class="text-right ml-6">
                                <div class="text-2xl font-bold text-gray-800 mb-1">
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
                                <div class="text-xs text-gray-500">Tổng cộng</div>
                            </div>
                        </div>
                        <div class="flex justify-between items-center pt-4 border-t border-gray-100">
                            <div class="flex items-center">
                                <% 
                                String status = (String) boarding.get("status");
                                if (status == null) status = "pending";
                                %>
                                <span class="px-4 py-2 rounded-full text-sm font-semibold shadow-sm
                                    <% if ("Chờ xác nhận".equals(status) || "pending".equals(status)) { %>bg-yellow-50 text-yellow-700 border border-yellow-200<% } %>
                                    <% if ("Chưa nhận thú cưng".equals(status)) { %>bg-blue-50 text-blue-700 border border-blue-200<% } %>
                                    <% if ("Đang ở".equals(status) || "Đang thuê".equals(status)) { %>bg-green-50 text-green-700 border border-green-200<% } %>
                                    <% if ("Đã nhận về".equals(status) || "Hoàn thành".equals(status) || "completed".equals(status)) { %>bg-purple-50 text-purple-700 border border-purple-200<% } %>
                                    <% if ("cancelled".equals(status) || "Đã hủy".equals(status)) { %>bg-red-50 text-red-700 border border-red-200<% } %>">
                                    <% if ("Chờ xác nhận".equals(status) || "pending".equals(status)) { %><i class="fas fa-clock mr-2"></i>Chờ xác nhận<% } %>
                                    <% if ("Chưa nhận thú cưng".equals(status)) { %><i class="fas fa-inbox mr-2"></i>Chưa nhận thú cưng<% } %>
                                    <% if ("Đang ở".equals(status) || "Đang thuê".equals(status)) { %><i class="fas fa-bed mr-2"></i>Đang ở<% } %>
                                    <% if ("Đã nhận về".equals(status) || "Hoàn thành".equals(status) || "completed".equals(status)) { %><i class="fas fa-check-circle mr-2"></i>Đã nhận về<% } %>
                                    <% if ("cancelled".equals(status) || "Đã hủy".equals(status)) { %><i class="fas fa-ban mr-2"></i>Đã hủy<% } %>
                                </span>
                            </div>
                            <div class="flex space-x-2">
                                <button onclick="viewBoardingDetails(<%= boarding.get("bookingId") %>)" 
                                        class="px-4 py-2 bg-blue-500 text-white rounded-lg hover:bg-blue-600 transition-all duration-200 shadow-sm hover:shadow-md">
                                    <i class="fas fa-eye mr-2"></i>Xem chi tiết
                                </button>
                                <% 
                                // Chỉ cho phép hủy ở "Chờ xác nhận" hoặc "Chưa nhận thú cưng"
                                boolean canCancel = ("Chờ xác nhận".equals(status) || "pending".equals(status) || "Chưa nhận thú cưng".equals(status));
                                boolean isCancelled = ("cancelled".equals(status) || "Đã hủy".equals(status));
                                %>
                                <% if (canCancel) { %>
                                <button onclick="cancelBoardingBooking(<%= boarding.get("bookingId") %>)" 
                                        class="px-4 py-2 bg-red-500 text-white rounded-lg hover:bg-red-600 transition-all duration-200 shadow-sm hover:shadow-md">
                                    <i class="fas fa-ban mr-2"></i>Hủy
                                </button>
                                <% } else if (isCancelled) { %>
                                <button onclick="deleteBoardingBooking(<%= boarding.get("bookingId") %>)" 
                                        class="px-4 py-2 bg-gray-500 text-white rounded-lg hover:bg-gray-600 transition-all duration-200 shadow-sm hover:shadow-md">
                                    <i class="fas fa-trash mr-2"></i>Xóa khỏi danh sách
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
                            <div class="flex justify-between items-start mb-5">
                                <div class="flex-1">
                                    <h3 class="text-2xl font-bold text-gray-800 mb-3 leading-tight">
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
                                    <div class="flex flex-wrap items-center gap-4 text-sm text-gray-600">
                                        <div class="flex items-center bg-gray-50 px-3 py-1.5 rounded-lg">
                                            <i class="fas fa-calendar-alt mr-2 text-blue-500"></i>
                                            <span class="font-medium"><fmt:formatDate value="<%= booking.getAppointmentStart() %>" pattern="dd/MM/yyyy"/></span>
                                        </div>
                                        <div class="flex items-center bg-gray-50 px-3 py-1.5 rounded-lg">
                                            <i class="fas fa-clock mr-2 text-purple-500"></i>
                                            <span class="font-medium">
                                                <fmt:formatDate value="<%= booking.getAppointmentStart() %>" pattern="HH:mm"/>
                                                - 
                                                <fmt:formatDate value="<%= booking.getAppointmentEnd() %>" pattern="HH:mm"/>
                                            </span>
                                        </div>
                                        <% if (booking.getPetName() != null && !booking.getPetName().trim().isEmpty()) { %>
                                        <div class="flex items-center bg-green-50 px-3 py-1.5 rounded-lg">
                                            <i class="fas fa-paw mr-2 text-green-500"></i>
                                            <span class="font-medium text-gray-700"><%= booking.getPetName() %></span>
                                        </div>
                                        <% } %>
                                    </div>
                                </div>
                                <div class="text-right ml-4">
                                    <% 
                                    // Khai báo biến một lần cho toàn bộ phần booking
                                    String bookingStatus = booking.getStatus();
                                    String displayStatus = spaStatusMap.get(booking.getBookingId());
                                    if (displayStatus == null || displayStatus.isEmpty()) {
                                        displayStatus = "Hủy thanh toán"; // default
                                    }
                                    
                                    // Cho phép hủy CHỈ khi status là "Đã thanh toán" (không cho "Hủy thanh toán" hoặc "Chưa thanh toán")
                                    boolean isPaidBooking = (bookingStatus != null && 
                                                           ("Đã thanh toán".equals(bookingStatus) || 
                                                            "Đã thanh toán".equalsIgnoreCase(bookingStatus)));
                                    boolean isPaidDisplay = (displayStatus != null && 
                                                           displayStatus.equals("Đã thanh toán"));
                                    // Chỉ cho phép hủy nếu là "Đã thanh toán", KHÔNG phải "Hủy thanh toán"
                                    boolean canCancel = (isPaidBooking || isPaidDisplay) && 
                                                       !displayStatus.equals("Hủy thanh toán");
                                    // Kiểm tra đã hủy - CHỈ các status đã hủy thực sự, KHÔNG phải "Hủy thanh toán"
                                    boolean isCancelled = "Đã hủy".equals(bookingStatus) || 
                                                         "Yêu cầu hoàn tiền".equals(bookingStatus) ||
                                                         (displayStatus != null && 
                                                          (displayStatus.equals("Đã hủy") || 
                                                           displayStatus.equals("Đã hủy lịch") ||
                                                           displayStatus.contains("Yêu cầu hoàn tiền")));
                                    // Hiển thị thông báo hoàn tiền nếu booking đã bị hủy và đã thanh toán
                                    boolean needsRefundNotice = "Yêu cầu hoàn tiền".equals(bookingStatus) || 
                                                               (displayStatus != null && displayStatus.contains("Đã hủy lịch"));
                                    
                                    // Xác định class và icon cho status
                                    String statusClass = "";
                                    String statusIcon = "";
                                    if (displayStatus.contains("Hủy") || displayStatus.contains("Đã hủy") || displayStatus.equalsIgnoreCase("cancelled") || displayStatus.equalsIgnoreCase("đã hủy") || displayStatus.contains("Đã hủy lịch")) {
                                        statusClass = "bg-gradient-to-r from-pink-100 to-rose-100 text-pink-700 border border-pink-200";
                                        statusIcon = "❌";
                                    } else if (displayStatus.contains("Yêu cầu hoàn tiền")) {
                                        statusClass = "bg-orange-100 text-orange-800 border border-orange-200";
                                        statusIcon = "💰";
                                    } else if (displayStatus.contains("Hoàn thành")) {
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
                                    <span class="inline-flex items-center px-4 py-2 rounded-full text-sm font-semibold shadow-sm <%= statusClass %>">
                                        <span class="mr-2"><%= statusIcon %></span>
                                        <%= displayStatus %>
                                    </span>
                                </div>
                            </div>
                            
                            <% if (booking.getNote() != null && !booking.getNote().trim().isEmpty()) { %>
                            <div class="mb-4 p-3 bg-blue-50 rounded-lg border-l-3 border-blue-400">
                                <p class="text-sm text-gray-700">
                                    <i class="fas fa-sticky-note mr-2 text-blue-500"></i>
                                    <strong class="text-blue-800">Ghi chú:</strong> 
                                    <span class="text-gray-700"><%= booking.getNote() %></span>
                                </p>
                            </div>
                            <% } %>
                            
                            <% if (needsRefundNotice) { %>
                            <div class="mb-5 p-5 bg-gradient-to-r from-amber-50 to-yellow-50 rounded-lg shadow-sm">
                                <div class="flex items-start">
                                    <div class="flex-shrink-0">
                                        <div class="flex items-center justify-center w-10 h-10 rounded-full bg-amber-100">
                                            <i class="fas fa-exclamation-triangle text-amber-600 text-xl"></i>
                                        </div>
                                    </div>
                                    <div class="ml-4 flex-1">
                                        <div class="flex items-center mb-2">
                                            <i class="fas fa-money-bill-wave text-amber-600 mr-2"></i>
                                            <h4 class="text-base font-bold text-amber-900">Thông báo hoàn tiền</h4>
                                        </div>
                                        <p class="text-sm text-amber-800 mb-3 leading-relaxed">
                                            Lịch hẹn đã được hủy. Vui lòng đến tiệm để được hoàn tiền theo chính sách của chúng tôi.
                                        </p>
                                        <div class="flex items-start bg-amber-100/50 rounded-md p-3 border border-amber-200">
                                            <i class="fas fa-info-circle text-amber-600 mr-2 mt-0.5"></i>
                                            <p class="text-xs text-amber-700 leading-relaxed">
                                                Biên lai hoàn tiền đã được gửi vào email của bạn.
                                            </p>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <% } %>
                            
                            <div class="flex justify-between items-center pt-4 border-t border-gray-200">
                                <div class="flex items-center text-sm text-gray-500 bg-gray-50 px-4 py-2 rounded-lg">
                                    <i class="fas fa-calendar-plus mr-2 text-gray-400"></i>
                                    <span class="font-medium">Tạo lúc: <fmt:formatDate value="<%= booking.getCreatedAt() %>" pattern="dd/MM/yyyy HH:mm"/></span>
                                </div>
                                <div class="flex space-x-3 items-center">
                                    <a href="<%= request.getContextPath()%>/spa-booking?action=detail&id=<%= booking.getBookingId() %>" 
                                       class="btn-primary inline-flex items-center px-5 py-2.5 rounded-lg font-semibold shadow-md hover:shadow-lg transition-all duration-200">
                                        Xem chi tiết
                                    </a>
                                    
                                    <% if (canCancel && !isCancelled) { %>
                                    <button type="button" 
                                            class="btn-danger inline-flex items-center px-5 py-2.5 rounded-lg font-semibold shadow-md hover:shadow-lg transition-all duration-200" 
                                            onclick="confirmCancelBooking(<%= booking.getBookingId() %>)">
                                        <i class="fas fa-times mr-2"></i>Hủy lịch
                                    </button>
                                    <% } %>
                                    
                                    <!-- Nút xóa: CHỈ cho phép xóa nếu CHƯA thanh toán -->
                                    <% 
                                    boolean canDelete = !"Đã thanh toán".equals(bookingStatus) && 
                                                        !(displayStatus != null && displayStatus.contains("Đã thanh toán")) &&
                                                        !isCancelled;
                                    %>
                                    <% if (canDelete) { %>
                                    <button onclick="deleteSpaBooking(<%= booking.getBookingId() %>)" 
                                            class="inline-flex items-center px-4 py-2.5 bg-gray-600 text-white rounded-lg font-semibold hover:bg-gray-700 transition-all duration-200 shadow-md hover:shadow-lg">
                                        <i class="fas fa-trash mr-2"></i>Xóa
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
        
        // Hàm hủy booking với confirmation và popup thông báo hoàn tiền
        function confirmCancelBooking(bookingId) {
            // Hiển thị dialog xác nhận đẹp hơn
            const confirmMessage = 'Bạn có chắc chắn muốn hủy lịch hẹn này?\n\n' +
                                  '📌 Lưu ý: Sau khi hủy, bạn cần đến cửa hàng để được hoàn tiền.\n' +
                                  'Biên lai hoàn tiền sẽ được gửi vào email của bạn.';
            
            if (confirm(confirmMessage)) {
                // Tạo form để hủy booking
                const form = document.createElement('form');
                form.method = 'POST';
                form.action = '<%= request.getContextPath()%>/spa-booking';
                
                const actionInput = document.createElement('input');
                actionInput.type = 'hidden';
                actionInput.name = 'action';
                actionInput.value = 'cancel';
                
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
        
        // Hiển thị popup thông báo hoàn tiền sau khi hủy thành công
        <% if (showRefund) { %>
        document.addEventListener('DOMContentLoaded', function() {
            showRefundPopup();
        });
        <% } %>
        
        function showRefundPopup() {
            // Tạo modal popup đẹp
            const modal = document.createElement('div');
            modal.id = 'refundPopup';
            modal.className = 'fixed inset-0 bg-black bg-opacity-50 z-50 flex items-center justify-center p-4';
            modal.style.animation = 'fadeIn 0.3s ease-out';
            
            modal.innerHTML = `
                <div class="bg-white rounded-2xl shadow-2xl max-w-md w-full transform transition-all" style="animation: slideUp 0.3s ease-out">
                    <div class="p-6">
                        <!-- Icon và Header -->
                        <div class="text-center mb-4">
                            <div class="mx-auto flex items-center justify-center h-16 w-16 rounded-full bg-yellow-100 mb-4">
                                <i class="fas fa-exclamation-triangle text-yellow-600 text-3xl"></i>
                            </div>
                            <h3 class="text-2xl font-bold text-gray-800 mb-2">💰 Thông báo hoàn tiền</h3>
                        </div>
                        
                        <!-- Content -->
                        <div class="mb-6">
                            <p class="text-gray-700 text-center mb-4">
                                Lịch hẹn của bạn đã được hủy thành công.
                            </p>
                            <div class="bg-yellow-50 border-l-4 border-yellow-400 p-4 rounded">
                                <p class="text-sm text-yellow-800 font-semibold mb-2">
                                    <i class="fas fa-info-circle mr-2"></i>Vui lòng đến cửa hàng để được hoàn tiền
                                </p>
                                <ul class="text-xs text-yellow-700 space-y-1 ml-6 list-disc">
                                    <li>Mang theo CMND/CCCD để xác nhận</li>
                                    <li>Biên lai hoàn tiền đã được gửi vào email của bạn</li>
                                    <li>Thời gian hoàn tiền: Trong vòng 3-5 ngày làm việc</li>
                                </ul>
                            </div>
                        </div>
                        
                        <!-- Footer -->
                        <div class="flex justify-center space-x-3">
                            <button onclick="closeRefundPopup()" 
                                    class="px-6 py-3 bg-gradient-to-r from-blue-500 to-blue-600 text-white rounded-lg font-semibold hover:from-blue-600 hover:to-blue-700 transition-all duration-200 shadow-lg hover:shadow-xl transform hover:-translate-y-0.5">
                                <i class="fas fa-check mr-2"></i>Đã hiểu
                            </button>
                        </div>
                    </div>
                </div>
            `;
            
            document.body.appendChild(modal);
            
            // Thêm animation CSS nếu chưa có
            if (!document.getElementById('refundPopupStyles')) {
                const style = document.createElement('style');
                style.id = 'refundPopupStyles';
                style.textContent = `
                    @keyframes fadeIn {
                        from { opacity: 0; }
                        to { opacity: 1; }
                    }
                    @keyframes slideUp {
                        from { 
                            opacity: 0;
                            transform: translateY(20px);
                        }
                        to { 
                            opacity: 1;
                            transform: translateY(0);
                        }
                    }
                `;
                document.head.appendChild(style);
            }
            
            // Đóng modal khi click bên ngoài
            modal.addEventListener('click', function(e) {
                if (e.target === modal) {
                    closeRefundPopup();
                }
            });
            
            // Đóng modal khi nhấn ESC
            document.addEventListener('keydown', function(e) {
                if (e.key === 'Escape') {
                    closeRefundPopup();
                }
            });
        }
        
        function closeRefundPopup() {
            const modal = document.getElementById('refundPopup');
            if (modal) {
                modal.style.animation = 'fadeOut 0.3s ease-out';
                setTimeout(() => {
                    modal.remove();
                }, 300);
            }
        }
        
    </script>
</body>
</html>

