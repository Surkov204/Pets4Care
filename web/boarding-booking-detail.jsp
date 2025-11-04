<%@page import="model.Customer"%>
<%@page import="model.BoardingBooking"%>
<%@page import="model.Pet"%>
<%@page import="java.util.List"%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%
    Customer currentUser = (Customer) session.getAttribute("currentUser");
    BoardingBooking booking = (BoardingBooking) request.getAttribute("boardingBooking");
    List<Pet> customerPets = (List<Pet>) request.getAttribute("customerPets");
    String errorMessage = (String) request.getAttribute("error");
    String successMessage = (String) request.getAttribute("success");
    
    // Lấy thông báo từ session (cho redirect)
    if (errorMessage == null) errorMessage = (String) session.getAttribute("errorMessage");
    if (successMessage == null) successMessage = (String) session.getAttribute("successMessage");
    
    // Xóa thông báo khỏi session sau khi hiển thị
    if (session.getAttribute("errorMessage") != null) session.removeAttribute("errorMessage");
    if (session.getAttribute("successMessage") != null) session.removeAttribute("successMessage");
    
    if (customerPets == null) customerPets = new java.util.ArrayList<>();
%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>🏠 Chi tiết đặt phòng lưu trú - Petcity</title>
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
            background: linear-gradient(135deg, #3b82f6, #2563eb);
            color: white;
        }
        
        /* Pet card animations and styles */
        .pet-card {
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
            position: relative;
            overflow: hidden;
        }
        .pet-card::before {
            content: '';
            position: absolute;
            top: 0;
            left: -100%;
            width: 100%;
            height: 100%;
            background: linear-gradient(90deg, transparent, rgba(255,255,255,0.2), transparent);
            transition: left 0.5s;
        }
        .pet-card:hover::before {
            left: 100%;
        }
        .pet-card:hover {
            transform: translateY(-4px) scale(1.02);
            box-shadow: 0 20px 40px rgba(0,0,0,0.1);
        }
        
        /* Pet info section styling */
        .pet-info-section {
            background: linear-gradient(135deg, #f8fafc 0%, #e2e8f0 100%);
            border: 1px solid #e2e8f0;
        }
        
        /* Responsive grid improvements */
        @media (max-width: 768px) {
            .pet-grid {
                grid-template-columns: 1fr;
            }
        }
        
        @media (min-width: 769px) and (max-width: 1024px) {
            .pet-grid {
                grid-template-columns: repeat(2, 1fr);
            }
        }
        
        @media (min-width: 1025px) {
            .pet-grid {
                grid-template-columns: repeat(3, 1fr);
            }
        }
        
        /* Pet status badge animation */
        .pet-status-badge {
            animation: pulse 2s infinite;
        }
        
        @keyframes pulse {
            0%, 100% {
                opacity: 1;
            }
            50% {
                opacity: 0.8;
            }
        }
        
        /* Loading animation for pet cards */
        .pet-card-loading {
            animation: shimmer 1.5s infinite;
        }
        
        @keyframes shimmer {
            0% {
                background-position: -200px 0;
            }
            100% {
                background-position: calc(200px + 100%) 0;
            }
        }
    </style>
</head>
<body class="bg-gray-50 font-quicksand">
    <!-- Header -->
    <header class="bg-white shadow-sm border-b border-gray-200">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div class="flex justify-between items-center py-4">
                <div class="flex items-center">
                    <a href="<%= request.getContextPath() %>/" class="flex items-center">
                        <img src="images/logo.png" alt="Petcity Logo" class="h-8 w-8 mr-3">
                        <span class="text-2xl font-bold text-gray-900">Petcity</span>
                    </a>
                </div>
                <div class="flex items-center space-x-4">
                    <span class="text-gray-700">Xin chào, <%= currentUser.getName() %></span>
                    <a href="<%= request.getContextPath() %>/logout" class="bg-red-500 text-white px-4 py-2 rounded-lg hover:bg-red-600 transition">
                        <i class="fas fa-sign-out-alt mr-1"></i>Đăng xuất
                    </a>
                </div>
            </div>
        </div>
    </header>

    <!-- Main Content -->
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <!-- Breadcrumb -->
        <nav class="flex mb-8" aria-label="Breadcrumb">
            <ol class="inline-flex items-center space-x-1 md:space-x-3">
                <li class="inline-flex items-center">
                    <a href="<%= request.getContextPath() %>/" class="text-gray-700 hover:text-blue-600">
                        <i class="fas fa-home mr-2"></i>Trang chủ
                    </a>
                </li>
                <li>
                    <div class="flex items-center">
                        <i class="fas fa-chevron-right text-gray-400 mx-2"></i>
                        <a href="<%= request.getContextPath() %>/spa-booking?action=history" class="text-gray-700 hover:text-blue-600">
                            Lịch sử đặt lịch
                        </a>
                    </div>
                </li>
                <li aria-current="page">
                    <div class="flex items-center">
                        <i class="fas fa-chevron-right text-gray-400 mx-2"></i>
                        <span class="text-gray-500">Chi tiết phòng lưu trú</span>
                    </div>
                </li>
            </ol>
        </nav>

        <!-- Error/Success Messages -->
        <% if (errorMessage != null) { %>
        <div class="mb-6 bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded-lg">
            <div class="flex items-center">
                <i class="fas fa-exclamation-circle mr-2"></i>
                <%= errorMessage %>
            </div>
        </div>
        <% } %>

        <% if (successMessage != null) { %>
        <div class="mb-6 bg-green-100 border border-green-400 text-green-700 px-4 py-3 rounded-lg">
            <div class="flex items-center">
                <i class="fas fa-check-circle mr-2"></i>
                <%= successMessage %>
            </div>
        </div>
        <% } %>

        <% if (booking != null) { %>
        <!-- Booking Details Card -->
        <div class="booking-card bg-white">
            <div class="p-8">
                <!-- Header -->
                <div class="flex justify-between items-start mb-6">
                    <div>
                        <h1 class="text-3xl font-bold text-gray-900 mb-2">🏠 Chi tiết phòng lưu trú</h1>
                        <p class="text-gray-600">Mã đặt phòng: #<%= booking.getBookingId() %></p>
                    </div>
                    <div class="text-right">
                        <span class="inline-flex items-center px-4 py-2 rounded-full text-sm font-medium
                            <% if ("Chờ xác nhận".equals(booking.getStatus()) || "pending".equals(booking.getStatus())) { %>status-pending<% } %>
                            <% if ("Chưa nhận thú cưng".equals(booking.getStatus())) { %>bg-blue-100 text-blue-800<% } %>
                            <% if ("Đang ở".equals(booking.getStatus()) || "Đang thuê".equals(booking.getStatus())) { %>status-confirmed<% } %>
                            <% if ("Đã nhận về".equals(booking.getStatus()) || "Hoàn thành".equals(booking.getStatus()) || "completed".equals(booking.getStatus())) { %>status-completed<% } %>
                            <% if ("cancelled".equals(booking.getStatus()) || "Đã hủy".equals(booking.getStatus())) { %>status-cancelled<% } %>">
                            <% if ("Chờ xác nhận".equals(booking.getStatus()) || "pending".equals(booking.getStatus())) { %><i class="fas fa-clock mr-1"></i>Chờ xác nhận<% } %>
                            <% if ("Chưa nhận thú cưng".equals(booking.getStatus())) { %><i class="fas fa-inbox mr-1"></i>Chưa nhận thú cưng<% } %>
                            <% if ("Đang ở".equals(booking.getStatus()) || "Đang thuê".equals(booking.getStatus())) { %><i class="fas fa-bed mr-1"></i>Đang ở<% } %>
                            <% if ("Đã nhận về".equals(booking.getStatus()) || "Hoàn thành".equals(booking.getStatus()) || "completed".equals(booking.getStatus())) { %><i class="fas fa-check-circle mr-1"></i>Đã nhận về<% } %>
                            <% if ("cancelled".equals(booking.getStatus()) || "Đã hủy".equals(booking.getStatus())) { %><i class="fas fa-ban mr-1"></i>Đã hủy<% } %>
                        </span>
                    </div>
                </div>

                <!-- Booking Information -->
                <div class="grid md:grid-cols-2 gap-8 mb-8">
                    <!-- Room Information -->
                    <div class="bg-gray-50 rounded-lg p-6">
                        <h3 class="text-xl font-semibold text-gray-900 mb-4">
                            <i class="fas fa-bed mr-2"></i>Thông tin phòng
                        </h3>
                        <div class="space-y-3">
                            <div class="flex justify-between">
                                <span class="text-gray-600">Loại phòng:</span>
                                <span class="font-semibold"><%= booking.getRoomType() %></span>
                            </div>
                            <div class="flex justify-between">
                                <span class="text-gray-600">Giá/ngày:</span>
                                <span class="font-semibold text-green-600">
                                    <fmt:formatNumber value="<%= booking.getPricePerDay() %>" type="currency" currencyCode="VND" pattern="#,###₫"/>
                                </span>
                            </div>
                            <div class="flex justify-between">
                                <span class="text-gray-600">Số ngày lưu trú:</span>
                                <span class="font-semibold"><%= booking.getBoardingDays() %> ngày</span>
                            </div>
                            <div class="flex justify-between">
                                <span class="text-gray-600">Tổng giá:</span>
                                <span class="font-semibold text-green-600 text-lg">
                                    <fmt:formatNumber value="<%= booking.getTotalPrice() %>" type="currency" currencyCode="VND" pattern="#,###₫"/>
                                </span>
                            </div>
                        </div>
                    </div>

                    <!-- Date & Time Information -->
                    <div class="bg-gray-50 rounded-lg p-6">
                        <h3 class="text-xl font-semibold text-gray-900 mb-4">
                            <i class="fas fa-calendar-alt mr-2"></i>Thời gian lưu trú
                        </h3>
                        <div class="space-y-3">
                            <div class="flex justify-between">
                                <span class="text-gray-600">Ngày nhận:</span>
                                <span class="font-semibold">
                                    <fmt:formatDate value="<%= booking.getCheckInDate() %>" pattern="dd/MM/yyyy"/>
                                </span>
                            </div>
                            <div class="flex justify-between">
                                <span class="text-gray-600">Giờ nhận:</span>
                                <span class="font-semibold"><%= booking.getCheckInTime() %></span>
                            </div>
                            <div class="flex justify-between">
                                <span class="text-gray-600">Ngày trả:</span>
                                <span class="font-semibold">
                                    <fmt:formatDate value="<%= booking.getCheckOutDate() %>" pattern="dd/MM/yyyy"/>
                                </span>
                            </div>
                            <div class="flex justify-between">
                                <span class="text-gray-600">Giờ trả:</span>
                                <span class="font-semibold"><%= booking.getCheckOutTime() %></span>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Pet Information -->
                <div class="pet-info-section rounded-lg p-6 mb-8">
                    <h3 class="text-2xl font-bold text-gray-900 mb-6 flex items-center">
                        <i class="fas fa-paw mr-3 text-blue-600"></i>Thông tin thú cưng
                        <span class="ml-3 text-sm font-normal text-gray-500">(<%= customerPets != null ? customerPets.size() : 0 %> thú cưng trong booking này)</span>
                    </h3>
                    
                    <% if (customerPets != null && !customerPets.isEmpty()) { %>
                    <!-- Display customer's pets in a beautiful card layout -->
                    <div class="pet-grid grid gap-6">
                        <% for (Pet pet : customerPets) { %>
                        <div class="pet-card bg-gradient-to-br from-blue-50 to-purple-50 border-2 border-blue-200 rounded-xl p-6 shadow-lg">
                            <!-- Pet Header -->
                            <div class="flex items-center mb-4">
                                <div class="text-4xl mr-4">
                                    <%= pet.getSpeciesEmoji() != null ? pet.getSpeciesEmoji() : "🐾" %>
                                </div>
                                <div class="flex-1">
                                    <h4 class="text-xl font-bold text-gray-800 mb-1"><%= pet.getPetName() %></h4>
                                    <p class="text-sm text-gray-600 font-medium">
                                        <%= pet.getSpeciesDisplayName() %>
                                        <% if (pet.getBreed() != null && !pet.getBreed().trim().isEmpty()) { %>
                                        - <%= pet.getBreed() %>
                                        <% } %>
                                    </p>
                                </div>
                            </div>
                            
                            <!-- Pet Details -->
                            <div class="space-y-3">
                                <div class="flex justify-between items-center py-2 border-b border-blue-100">
                                    <span class="text-gray-600 font-medium">Tuổi:</span>
                                    <span class="font-bold text-blue-700">
                                        <%= pet.getAgeText() != null ? pet.getAgeText() : "Không xác định" %>
                                    </span>
                                </div>
                                
                                <div class="flex justify-between items-center py-2 border-b border-blue-100">
                                    <span class="text-gray-600 font-medium">Giới tính:</span>
                                    <span class="font-bold text-blue-700">
                                        <%= pet.getGenderDisplayName() != null ? pet.getGenderDisplayName() : "Không xác định" %>
                                    </span>
                                </div>
                                
                                <div class="flex justify-between items-center py-2 border-b border-blue-100">
                                    <span class="text-gray-600 font-medium">Tình trạng sức khỏe:</span>
                                    <span class="font-bold text-green-600 flex items-center">
                                        <i class="fas fa-heart mr-1"></i>
                                        <%= pet.getHealthStatus() != null ? pet.getHealthStatus() : "Tốt" %>
                                    </span>
                                </div>
                                
                                <% if (pet.getDescription() != null && !pet.getDescription().trim().isEmpty()) { %>
                                <div class="mt-4 p-3 bg-white rounded-lg border border-blue-100">
                                    <span class="text-gray-600 font-medium text-sm block mb-2">Mô tả thêm:</span>
                                    <p class="text-gray-700 text-sm leading-relaxed"><%= pet.getDescription() %></p>
                                </div>
                                <% } %>
                            </div>
                            
                            <!-- Pet Status Badge -->
                            <div class="mt-4 flex justify-center">
                                <span class="pet-status-badge inline-flex items-center px-4 py-2 rounded-full text-sm font-medium bg-green-100 text-green-800 border border-green-200">
                                    <i class="fas fa-check-circle mr-2"></i>
                                    Sẵn sàng lưu trú
                                </span>
                            </div>
                        </div>
                        <% } %>
                    </div>
                    <% } else { %>
                    <!-- Fallback: Display pet info from booking if no pet objects available -->
                    <div class="bg-white rounded-lg p-6 border-2 border-orange-200">
                        <div class="flex items-center mb-4">
                            <i class="fas fa-info-circle text-orange-500 text-2xl mr-3"></i>
                            <h4 class="text-lg font-semibold text-gray-800">Thông tin thú cưng từ đặt phòng</h4>
                        </div>
                        <div class="bg-orange-50 rounded-lg p-4">
                            <p class="text-gray-800 leading-relaxed"><%= booking.getPetInfo() %></p>
                        </div>
                    </div>
                    <% } %>
                </div>

                <!-- Special Notes -->
                <% if (booking.getSpecialNotes() != null && !booking.getSpecialNotes().trim().isEmpty()) { %>
                <div class="bg-gray-50 rounded-lg p-6 mb-8">
                    <h3 class="text-xl font-semibold text-gray-900 mb-4">
                        <i class="fas fa-sticky-note mr-2"></i>Yêu cầu đặc biệt
                    </h3>
                    <div class="bg-white rounded-lg p-4">
                        <p class="text-gray-800"><%= booking.getSpecialNotes() %></p>
                    </div>
                </div>
                <% } %>

                <!-- Emergency Contacts -->
                <div class="bg-gray-50 rounded-lg p-6 mb-8">
                    <h3 class="text-xl font-semibold text-gray-900 mb-4">
                        <i class="fas fa-phone mr-2"></i>Liên hệ khẩn cấp
                    </h3>
                    <div class="grid md:grid-cols-2 gap-4">
                        <div>
                            <label class="text-sm text-gray-600">Số điện thoại 1:</label>
                            <p class="font-semibold"><%= booking.getEmergencyPhone1() %></p>
                        </div>
                        <% if (booking.getEmergencyPhone2() != null && !booking.getEmergencyPhone2().trim().isEmpty()) { %>
                        <div>
                            <label class="text-sm text-gray-600">Số điện thoại 2:</label>
                            <p class="font-semibold"><%= booking.getEmergencyPhone2() %></p>
                        </div>
                        <% } %>
                    </div>
                </div>

                <!-- Booking Actions -->
                <div class="flex justify-between items-center pt-6 border-t border-gray-200">
                    <div class="text-sm text-gray-500">
                        <p>Ngày tạo: <fmt:formatDate value="<%= booking.getCreatedAt() %>" pattern="dd/MM/yyyy HH:mm"/></p>
                    </div>
                    <div class="flex space-x-4">
                        <a href="<%= request.getContextPath() %>/spa-booking?action=history" 
                           class="px-6 py-2 bg-gray-500 text-white rounded-lg hover:bg-gray-600 transition">
                            <i class="fas fa-arrow-left mr-2"></i>Quay lại
                        </a>
                        <% 
                        String bookingStatus = booking.getStatus();
                        boolean canCancel = !"Đã nhận về".equals(bookingStatus) && 
                                           !"Hoàn thành".equals(bookingStatus) && 
                                           !"completed".equals(bookingStatus) &&
                                           !"cancelled".equals(bookingStatus) &&
                                           !"Đã hủy".equals(bookingStatus) &&
                                           !"Đang ở".equals(bookingStatus) &&
                                           !"Đang thuê".equals(bookingStatus);
                        %>
                        <% if (canCancel) { %>
                        <form method="POST" action="<%= request.getContextPath() %>/spa-booking" class="inline">
                            <input type="hidden" name="action" value="cancel-boarding-booking">
                            <input type="hidden" name="bookingId" value="<%= booking.getBookingId() %>">
                            <button type="submit" class="px-6 py-2 bg-red-500 text-white rounded-lg hover:bg-red-600 transition"
                                    onclick="return confirm('Bạn có chắc chắn muốn hủy lịch lưu trú này?')">
                                <i class="fas fa-ban mr-2"></i>Hủy lịch
                            </button>
                        </form>
                        <% } else if ("cancelled".equals(bookingStatus) || "Đã hủy".equals(bookingStatus)) { %>
                        <form method="POST" action="<%= request.getContextPath() %>/spa-booking" class="inline">
                            <input type="hidden" name="action" value="delete-boarding-booking">
                            <input type="hidden" name="bookingId" value="<%= booking.getBookingId() %>">
                            <button type="submit" class="px-6 py-2 bg-red-600 text-white rounded-lg hover:bg-red-700 transition"
                                    onclick="return confirm('Bạn có chắc chắn muốn xóa lịch lưu trú này khỏi danh sách? Hành động này không thể hoàn tác!')">
                                <i class="fas fa-trash mr-2"></i>Xóa khỏi danh sách
                            </button>
                        </form>
                        <% } %>
                    </div>
                </div>
            </div>
        </div>
        <% } else { %>
        <!-- No Booking Found -->
        <div class="text-center py-12">
            <i class="fas fa-exclamation-triangle text-6xl text-gray-400 mb-4"></i>
            <h2 class="text-2xl font-bold text-gray-900 mb-2">Không tìm thấy thông tin</h2>
            <p class="text-gray-600 mb-6">Không thể tìm thấy thông tin phòng lưu trú này.</p>
            <a href="<%= request.getContextPath() %>/spa-booking?action=history" 
               class="px-6 py-3 bg-blue-500 text-white rounded-lg hover:bg-blue-600 transition">
                <i class="fas fa-arrow-left mr-2"></i>Quay lại lịch sử
            </a>
        </div>
        <% } %>
    </div>

    <!-- Footer -->
    <footer class="bg-gray-900 text-white py-8 mt-12">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div class="text-center">
                <p>&copy; 2024 Petcity. Tất cả quyền được bảo lưu.</p>
            </div>
        </div>
    </footer>

    <script>
        // Pet card interactions
        document.addEventListener('DOMContentLoaded', function() {
            const petCards = document.querySelectorAll('.pet-card');
            
            petCards.forEach(card => {
                // Add click effect
                card.addEventListener('click', function() {
                    this.style.transform = 'scale(0.98)';
                    setTimeout(() => {
                        this.style.transform = '';
                    }, 150);
                });
                
                // Add hover sound effect (optional)
                card.addEventListener('mouseenter', function() {
                    // You can add a subtle sound effect here if desired
                });
            });
            
            // Animate pet cards on load
            petCards.forEach((card, index) => {
                card.style.opacity = '0';
                card.style.transform = 'translateY(20px)';
                
                setTimeout(() => {
                    card.style.transition = 'all 0.6s ease';
                    card.style.opacity = '1';
                    card.style.transform = 'translateY(0)';
                }, index * 100);
            });
            
            // Add loading state for pet information
            const petInfoSection = document.querySelector('.pet-info-section');
            if (petInfoSection) {
                petInfoSection.addEventListener('mouseenter', function() {
                    this.style.background = 'linear-gradient(135deg, #f1f5f9 0%, #e2e8f0 100%)';
                });
                
                petInfoSection.addEventListener('mouseleave', function() {
                    this.style.background = 'linear-gradient(135deg, #f8fafc 0%, #e2e8f0 100%)';
                });
            }
        });
        
        // Smooth scroll for better UX
        function smoothScrollTo(element) {
            element.scrollIntoView({
                behavior: 'smooth',
                block: 'start'
            });
        }
        
        // Add pet card click to scroll to details
        document.querySelectorAll('.pet-card').forEach(card => {
            card.addEventListener('click', function() {
                const petName = this.querySelector('h4').textContent;
                console.log('Clicked on pet:', petName);
                // You can add more functionality here like showing detailed pet info
            });
        });
    </script>
</body>
</html>
