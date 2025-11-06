<%@page import="model.Customer"%>
<%@page import="model.Booking"%>
<%@page import="model.BookingServiceItem"%>
<%@page import="model.Pet"%>
<%@page import="java.util.List"%>
<%@page import="java.util.ArrayList"%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%
    Customer currentUser = (Customer) session.getAttribute("currentUser");
    Booking booking = (Booking) request.getAttribute("booking");
    List<BookingServiceItem> spaBookingDetails = (List<BookingServiceItem>) request.getAttribute("spaBookingDetails");
    List<Pet> customerPets = (List<Pet>) request.getAttribute("customerPets");
    String errorMessage = (String) request.getAttribute("error");
    
    // Lấy thông báo từ session (cho redirect)
    if (errorMessage == null) errorMessage = (String) session.getAttribute("errorMessage");
    String successMessage = (String) session.getAttribute("successMessage");
    
    // Xóa thông báo khỏi session sau khi hiển thị
    if (session.getAttribute("errorMessage") != null) session.removeAttribute("errorMessage");
    if (session.getAttribute("successMessage") != null) session.removeAttribute("successMessage");
    
    if (spaBookingDetails == null) spaBookingDetails = new ArrayList<>();
    if (customerPets == null) customerPets = new ArrayList<>();
%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>📋 Chi tiết lịch hẹn Spa - Petcity</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.3/css/all.min.css" rel="stylesheet" />
    <link href="https://fonts.googleapis.com/css2?family=Quicksand:wght@300;400;500;600;700&family=Nunito:wght@300;400;500;600;700;800&family=Baloo+2:wght@400;500;600;700;800&display=swap" rel="stylesheet" />
    <link rel="stylesheet" href="css/homeStyle.css" />
    <style>
        .detail-card {
            transition: all 0.3s ease;
            border-radius: 15px;
            overflow: hidden;
            box-shadow: 0 4px 15px rgba(0,0,0,0.1);
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
            <li><a href="search?categoryId=2">SẢN PHẨM</a></li>
            <li><a href="doctor.jsp">BÁC SĨ</a></li>
            <li><a href="gioi-thieu.jsp">GIỚI THIỆU</a></li>
            <li><a href="tin-tuc.jsp">TIN TỨC</a></li>
            <li><a href="<%= request.getContextPath()%>/home">LIÊN HỆ</a></li>
        </ul>
    </nav>

    <!-- Main Content -->
    <main class="container mx-auto px-6 py-10">
        <% if (booking == null) { %>
        <div class="bg-white rounded-lg shadow-lg p-8 text-center">
            <div class="text-6xl mb-4">❌</div>
            <h1 class="text-2xl font-bold text-gray-800 mb-4">Không tìm thấy lịch hẹn</h1>
            <p class="text-gray-600 mb-6">Lịch hẹn bạn tìm kiếm không tồn tại hoặc bạn không có quyền xem.</p>
            <a href="<%= request.getContextPath()%>/spa-booking?action=history" class="btn-primary">
                <i class="fas fa-arrow-left mr-2"></i>Quay lại lịch sử
            </a>
        </div>
        <% } else { %>
        <div class="bg-white rounded-lg shadow-lg p-8">
            <!-- Header -->
            <div class="flex justify-between items-center mb-8">
                <div>
                    <h1 class="text-3xl font-bold text-gray-800 mb-2">📋 Chi tiết lịch hẹn Spa</h1>
                    <p class="text-gray-600">Thông tin chi tiết về 
                        <% 
                        String serviceName = booking.getServiceNames();
                        if (serviceName != null && !serviceName.trim().isEmpty()) {
                            out.print(serviceName);
                        } else {
                            out.print("lịch hẹn #" + booking.getBookingId());
                        }
                        %>
                    </p>
                </div>
                <div class="flex space-x-4">
                    <a href="<%= request.getContextPath()%>/spa-booking?action=history" class="btn-primary">
                        <i class="fas fa-arrow-left mr-2"></i>Quay lại
                    </a>
                    <% 
                    // Kiểm tra có thể hủy không - sử dụng trạng thái từ booking object thay vì query database
                    boolean canCancel = "pending".equals(booking.getStatus()) || "confirmed".equals(booking.getStatus());
                    %>
                    
                    <% if (canCancel) { %>
                    <form method="POST" action="<%= request.getContextPath()%>/spa-booking" style="display: inline;">
                        <input type="hidden" name="action" value="cancel">
                        <input type="hidden" name="bookingId" value="<%= booking.getBookingId() %>">
                        <button type="submit" class="btn-danger" 
                                onclick="return confirm('Bạn có chắc chắn muốn hủy lịch hẹn này?')">
                            <i class="fas fa-times mr-2"></i>Hủy lịch
                        </button>
                    </form>
                    <% } else if ("cancelled".equals(booking.getStatus())) { %>
                    <button onclick="deleteSpaBooking(<%= booking.getBookingId() %>)" 
                            class="px-4 py-2 bg-red-600 text-white rounded hover:bg-red-700 transition">
                        <i class="fas fa-trash mr-2"></i>Xóa khỏi danh sách
                    </button>
                    <% } else if ("completed".equalsIgnoreCase(booking.getStatus()) || "đã thanh toán".equals(booking.getStatus()) || "hoàn thành".equalsIgnoreCase(booking.getStatus())) { %>
                    <button onclick="deleteSpaBooking(<%= booking.getBookingId() %>)" 
                            class="px-4 py-2 bg-gray-600 text-white rounded hover:bg-gray-700 transition">
                        <i class="fas fa-trash mr-2"></i>Xóa khỏi lịch sử
                    </button>
                    <% } %>
                </div>
            </div>

            <!-- Messages -->
            <% if (errorMessage != null) { %>
            <div class="p-4 mb-6 rounded-md bg-red-100 border-l-4 border-red-500" role="alert">
                <p class="font-bold text-red-600">⚠️ Lỗi</p>
                <p><%= errorMessage %></p>
            </div>
            <% } %>

            <% if (successMessage != null) { %>
            <div class="p-4 mb-6 rounded-md bg-green-100 border-l-4 border-green-500" role="alert">
                <p class="font-bold text-green-600">✅ Thành công</p>
                <p><%= successMessage %></p>
            </div>
            <% } %>

            <!-- Booking Information -->
            <div class="grid md:grid-cols-2 gap-8 mb-8">
                <!-- Basic Info -->
                <div class="detail-card bg-white border border-gray-200">
                    <div class="p-6">
                        <h3 class="text-xl font-bold text-gray-800 mb-4">📅 Thông tin lịch hẹn</h3>
                        <div class="space-y-3">
                            <div class="flex justify-between">
                                <span class="text-gray-600">Mã lịch hẹn:</span>
                                <span class="font-semibold">#<%= booking.getBookingId() %></span>
                            </div>
                            <div class="flex justify-between">
                                <span class="text-gray-600">Dịch vụ:</span>
                                <span class="font-semibold">
                                    <% 
                                    String bookingServiceName = booking.getServiceNames();
                                    if (bookingServiceName != null && !bookingServiceName.trim().isEmpty()) {
                                        out.print(bookingServiceName);
                                    } else {
                                        out.print("Không có thông tin");
                                    }
                                    %>
                                </span>
                            </div>
                            <div class="flex justify-between">
                                <span class="text-gray-600">Ngày hẹn:</span>
                                <span class="font-semibold">
                                    <fmt:formatDate value="<%= booking.getAppointmentStart() %>" pattern="dd/MM/yyyy"/>
                                </span>
                            </div>
                            <div class="flex justify-between">
                                <span class="text-gray-600">Thời gian:</span>
                                <span class="font-semibold">
                                    <fmt:formatDate value="<%= booking.getAppointmentStart() %>" pattern="HH:mm"/>
                                    - 
                                    <fmt:formatDate value="<%= booking.getAppointmentEnd() %>" pattern="HH:mm"/>
                                </span>
                            </div>
                            <div class="flex justify-between">
                                <span class="text-gray-600">Trạng thái:</span>
                                <span class="px-3 py-1 rounded-full text-sm font-semibold
                                    <% if ("pending".equals(booking.getStatus())) { %>status-pending<% } %>
                                    <% if ("confirmed".equals(booking.getStatus())) { %>status-confirmed<% } %>
                                    <% if ("cancelled".equals(booking.getStatus())) { %>status-cancelled<% } %>
                                    <% if ("completed".equals(booking.getStatus())) { %>status-completed<% } %>">
                                    <% if ("pending".equals(booking.getStatus())) { %>⏳ Chờ xác nhận<% } %>
                                    <% if ("confirmed".equals(booking.getStatus())) { %>✅ Đã xác nhận<% } %>
                                    <% if ("cancelled".equals(booking.getStatus())) { %>❌ Đã hủy<% } %>
                                    <% if ("completed".equals(booking.getStatus())) { %>✅ Hoàn thành<% } %>
                                </span>
                            </div>
                            <div class="flex justify-between">
                                <span class="text-gray-600">Tạo lúc:</span>
                                <span class="font-semibold">
                                    <fmt:formatDate value="<%= booking.getCreatedAt() %>" pattern="dd/MM/yyyy HH:mm"/>
                                </span>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Customer Info -->
                <div class="detail-card bg-white border border-gray-200">
                    <div class="p-6">
                        <h3 class="text-xl font-bold text-gray-800 mb-4">👤 Thông tin khách hàng</h3>
                        <div class="space-y-3">
                            <div class="flex justify-between">
                                <span class="text-gray-600">Tên:</span>
                                <span class="font-semibold"><%= currentUser.getName() %></span>
                            </div>
                            <div class="flex justify-between">
                                <span class="text-gray-600">Email:</span>
                                <span class="font-semibold"><%= currentUser.getEmail() %></span>
                            </div>
                            <div class="flex justify-between">
                                <span class="text-gray-600">Số điện thoại:</span>
                                <span class="font-semibold"><%= currentUser.getPhone() %></span>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Pet Information - Chỉ hiển thị thú cưng đã được chọn cho booking này -->
            <% if (customerPets != null && !customerPets.isEmpty()) { %>
            <div class="detail-card bg-white border border-gray-200 mb-8">
                <div class="p-6">
                    <h3 class="text-xl font-bold text-gray-800 mb-4">🐾 Thú cưng đã đặt dịch vụ</h3>
                    <div class="grid md:grid-cols-2 lg:grid-cols-3 gap-4">
                        <% for (Pet pet : customerPets) { %>
                        <div class="bg-gradient-to-r from-blue-50 to-purple-50 border border-blue-200 rounded-lg p-4">
                            <div class="flex items-center mb-3">
                                <div class="text-2xl mr-3"><%= pet.getSpeciesEmoji() %></div>
                                <div>
                                    <h4 class="font-bold text-gray-800"><%= pet.getPetName() %></h4>
                                    <p class="text-sm text-gray-600"><%= pet.getSpeciesDisplayName() %> - <%= pet.getBreed() %></p>
                                </div>
                            </div>
                            <div class="space-y-2 text-sm">
                                <div class="flex justify-between">
                                    <span class="text-gray-600">Tuổi:</span>
                                    <span class="font-semibold"><%= pet.getAgeText() %></span>
                                </div>
                                <div class="flex justify-between">
                                    <span class="text-gray-600">Giới tính:</span>
                                    <span class="font-semibold"><%= pet.getGenderDisplayName() %></span>
                                </div>
                                <div class="flex justify-between">
                                    <span class="text-gray-600">Sức khỏe:</span>
                                    <span class="font-semibold text-green-600"><%= pet.getHealthStatus() %></span>
                                </div>
                                <% if (pet.getDescription() != null && !pet.getDescription().trim().isEmpty()) { %>
                                <div class="mt-2">
                                    <span class="text-gray-600">Mô tả:</span>
                                    <p class="text-sm text-gray-700 mt-1"><%= pet.getDescription() %></p>
                                </div>
                                <% } %>
                            </div>
                        </div>
                        <% } %>
                    </div>
                </div>
            </div>
            <% } %>

            <!-- Services -->
            <div class="detail-card bg-white border border-gray-200 mb-8">
                <div class="p-6">
                    <h3 class="text-xl font-bold text-gray-800 mb-4">💆 Dịch vụ Spa</h3>
                    <% if (spaBookingDetails.isEmpty()) { %>
                    <div class="text-center py-8">
                        <div class="text-4xl mb-4">🛁</div>
                        <p class="text-gray-600">Không có thông tin dịch vụ</p>
                    </div>
                    <% } else { %>
                    <div class="space-y-4">
                        <% for (BookingServiceItem detail : spaBookingDetails) { %>
                        <div class="flex justify-between items-center p-4 bg-gray-50 rounded-lg">
                            <div class="flex-1">
                                <h4 class="font-semibold text-gray-800">Dịch vụ ID: <%= detail.getServiceId() %></h4>
                                <p class="text-gray-600 text-sm">Số lượng: <%= detail.getQuantity() %></p>
                                <% if (detail.getNote() != null && !detail.getNote().trim().isEmpty()) { %>
                                <p class="text-gray-600 text-sm">Ghi chú: <%= detail.getNote() %></p>
                                <% } %>
                            </div>
                            <div class="text-right">
                                <div class="text-lg font-bold text-green-600">
                                    <fmt:formatNumber value="<%= detail.getPrice().multiply(java.math.BigDecimal.valueOf(detail.getQuantity())) %>" 
                                                      type="currency" currencySymbol="₫" maxFractionDigits="0"/>
                                </div>
                                <div class="text-sm text-gray-500">
                                    <fmt:formatNumber value="<%= detail.getPrice() %>" 
                                                      type="currency" currencySymbol="₫" maxFractionDigits="0"/> × <%= detail.getQuantity() %>
                                </div>
                            </div>
                        </div>
                        <% } %>
                    </div>
                    <% } %>
                </div>
            </div>

            <!-- Notes -->
            <% if (booking.getNote() != null && !booking.getNote().trim().isEmpty()) { %>
            <div class="detail-card bg-white border border-gray-200">
                <div class="p-6">
                    <h3 class="text-xl font-bold text-gray-800 mb-4">📝 Ghi chú</h3>
                    <p class="text-gray-600"><%= booking.getNote() %></p>
                </div>
            </div>
            <% } %>
        </div>
        <% } %>
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
