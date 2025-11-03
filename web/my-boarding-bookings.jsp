<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*, model.Customer" %>
<%@ page session="true" %>
<%
    List<Object> bookings = (List<Object>) request.getAttribute("bookings");
    String errorMessage = (String) request.getAttribute("errorMessage");
    String successMessage = (String) session.getAttribute("successMessage");
    Customer currentUser = (Customer) session.getAttribute("currentUser");
    
    if (bookings == null) bookings = new ArrayList<>();
    
    // Clear success message after displaying
    if (successMessage != null) {
        session.removeAttribute("successMessage");
    }
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>📅 Lịch Sử Đặt Phòng - Petcity</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.3/css/all.min.css" rel="stylesheet" />
    <link href="https://fonts.googleapis.com/css2?family=Quicksand:wght@300;400;500;600;700&family=Nunito:wght@300;400;500;600;700;800&family=Baloo+2:wght@400;500;600;700;800&display=swap" rel="stylesheet" />
    <link rel="stylesheet" href="../css/homeStyle.css" />
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <style>
        .booking-card {
            transition: all 0.3s ease;
        }
        .booking-card:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 25px rgba(0,0,0,0.1);
        }
        .status-badge {
            transition: all 0.3s ease;
        }
    </style>
</head>
<body>
    <!-- Header -->
    <div class="bg-gradient-to-r from-blue-500 to-purple-600 text-white py-4">
        <div class="container mx-auto px-4">
            <div class="flex justify-between items-center">
                <div class="flex items-center space-x-4">
                    <a href="<%= request.getContextPath()%>/boarding-room?action=list" class="hover:text-yellow-300 transition">
                        <i class="fas fa-arrow-left"></i> Quay lại
                    </a>
                    <h1 class="text-2xl font-bold">📅 Lịch Sử Đặt Phòng</h1>
                </div>
                <div class="flex space-x-4">
                    <a href="<%= request.getContextPath()%>/home.jsp" class="hover:text-yellow-300 transition">
                        <i class="fas fa-home"></i> Trang chủ
                    </a>
                    <a href="<%= request.getContextPath()%>/boarding-room?action=list" class="hover:text-yellow-300 transition">
                        <i class="fas fa-plus"></i> Đặt phòng mới
                    </a>
                </div>
            </div>
        </div>
    </div>

    <!-- Success Message -->
    <% if (successMessage != null) { %>
        <div class="bg-green-100 border border-green-400 text-green-700 px-4 py-3 rounded mx-4 mt-4">
            <i class="fas fa-check-circle"></i> <%= successMessage %>
        </div>
    <% } %>

    <!-- Error Message -->
    <% if (errorMessage != null) { %>
        <div class="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded mx-4 mt-4">
            <i class="fas fa-exclamation-triangle"></i> <%= errorMessage %>
        </div>
    <% } %>

    <div class="container mx-auto px-4 py-8">
        <!-- User Info -->
        <% if (currentUser != null) { %>
            <div class="bg-white rounded-lg shadow-lg p-6 mb-8">
                <div class="flex items-center space-x-4">
                    <div class="bg-blue-100 w-16 h-16 rounded-full flex items-center justify-center">
                        <i class="fas fa-user text-2xl text-blue-600"></i>
                    </div>
                    <div>
                        <h2 class="text-2xl font-bold text-gray-800"><%= currentUser.getFullName() %></h2>
                        <p class="text-gray-600"><%= currentUser.getEmail() %></p>
                        <p class="text-gray-600"><%= currentUser.getPhone() %></p>
                    </div>
                </div>
            </div>
        <% } %>

        <!-- Filter Section -->
        <div class="bg-white rounded-lg shadow-lg p-6 mb-8">
            <h3 class="text-xl font-bold text-gray-800 mb-4">Bộ lọc</h3>
            <div class="flex flex-wrap gap-4">
                <button onclick="filterBookings('all')" 
                        class="filter-btn px-4 py-2 rounded-full border-2 border-gray-300 hover:border-blue-500 transition active">
                    <i class="fas fa-list"></i> Tất cả
                </button>
                <button onclick="filterBookings('confirmed')" 
                        class="filter-btn px-4 py-2 rounded-full border-2 border-gray-300 hover:border-blue-500 transition">
                    <i class="fas fa-check"></i> Đã xác nhận
                </button>
                <button onclick="filterBookings('pending')" 
                        class="filter-btn px-4 py-2 rounded-full border-2 border-gray-300 hover:border-blue-500 transition">
                    <i class="fas fa-clock"></i> Chờ xác nhận
                </button>
                <button onclick="filterBookings('cancelled')" 
                        class="filter-btn px-4 py-2 rounded-full border-2 border-gray-300 hover:border-blue-500 transition">
                    <i class="fas fa-times"></i> Đã hủy
                </button>
            </div>
        </div>

        <!-- Bookings List -->
        <% if (bookings.isEmpty()) { %>
            <div class="text-center py-16">
                <div class="text-6xl mb-4">📅</div>
                <h3 class="text-2xl font-bold text-gray-600 mb-2">Chưa có đặt phòng nào</h3>
                <p class="text-gray-500 mb-6">Bạn chưa đặt phòng lưu trú nào. Hãy đặt phòng đầu tiên!</p>
                <a href="<%= request.getContextPath()%>/boarding-room?action=list" 
                   class="bg-blue-500 text-white px-6 py-3 rounded-lg hover:bg-blue-600 transition">
                    <i class="fas fa-plus mr-2"></i> Đặt phòng ngay
                </a>
            </div>
        <% } else { %>
            <div class="space-y-6">
                <!-- Sample booking cards (will be replaced with real data) -->
                <div class="booking-card bg-white rounded-lg shadow-lg p-6">
                    <div class="flex justify-between items-start mb-4">
                        <div>
                            <h3 class="text-xl font-bold text-gray-800">Dog Room 1</h3>
                            <p class="text-gray-600">Phòng Chó Lớn</p>
                        </div>
                        <span class="status-badge px-3 py-1 rounded-full text-sm font-medium bg-green-100 text-green-600">
                            Đã xác nhận
                        </span>
                    </div>
                    
                    <div class="grid md:grid-cols-3 gap-4 mb-4">
                        <div>
                            <label class="text-sm text-gray-500">Thú cưng</label>
                            <p class="font-semibold">Buddy</p>
                        </div>
                        <div>
                            <label class="text-sm text-gray-500">Ngày nhận</label>
                            <p class="font-semibold">25/12/2024</p>
                        </div>
                        <div>
                            <label class="text-sm text-gray-500">Ngày trả</label>
                            <p class="font-semibold">30/12/2024</p>
                        </div>
                    </div>
                    
                    <div class="flex justify-between items-center">
                        <div class="text-2xl font-bold text-green-600">1,500,000₫</div>
                        <div class="flex space-x-2">
                            <button class="bg-blue-500 text-white px-4 py-2 rounded hover:bg-blue-600 transition">
                                <i class="fas fa-eye mr-1"></i> Chi tiết
                            </button>
                            <button class="bg-red-500 text-white px-4 py-2 rounded hover:bg-red-600 transition">
                                <i class="fas fa-times mr-1"></i> Hủy
                            </button>
                        </div>
                    </div>
                </div>
                
                <div class="booking-card bg-white rounded-lg shadow-lg p-6">
                    <div class="flex justify-between items-start mb-4">
                        <div>
                            <h3 class="text-xl font-bold text-gray-800">Cat Room VIP</h3>
                            <p class="text-gray-600">Phòng Mèo VIP</p>
                        </div>
                        <span class="status-badge px-3 py-1 rounded-full text-sm font-medium bg-yellow-100 text-yellow-600">
                            Chờ xác nhận
                        </span>
                    </div>
                    
                    <div class="grid md:grid-cols-3 gap-4 mb-4">
                        <div>
                            <label class="text-sm text-gray-500">Thú cưng</label>
                            <p class="font-semibold">Luna</p>
                        </div>
                        <div>
                            <label class="text-sm text-gray-500">Ngày nhận</label>
                            <p class="font-semibold">28/12/2024</p>
                        </div>
                        <div>
                            <label class="text-sm text-gray-500">Ngày trả</label>
                            <p class="font-semibold">02/01/2025</p>
                        </div>
                    </div>
                    
                    <div class="flex justify-between items-center">
                        <div class="text-2xl font-bold text-green-600">1,750,000₫</div>
                        <div class="flex space-x-2">
                            <button class="bg-blue-500 text-white px-4 py-2 rounded hover:bg-blue-600 transition">
                                <i class="fas fa-eye mr-1"></i> Chi tiết
                            </button>
                            <button class="bg-red-500 text-white px-4 py-2 rounded hover:bg-red-600 transition">
                                <i class="fas fa-times mr-1"></i> Hủy
                            </button>
                        </div>
                    </div>
                </div>
            </div>
        <% } %>
    </div>

    <!-- Statistics Section -->
    <div class="bg-gray-50 py-12">
        <div class="container mx-auto px-4">
            <h3 class="text-2xl font-bold text-gray-800 text-center mb-8">Thống kê đặt phòng</h3>
            <div class="grid md:grid-cols-4 gap-6">
                <div class="bg-white rounded-lg shadow-lg p-6 text-center">
                    <div class="text-3xl font-bold text-blue-600 mb-2">0</div>
                    <p class="text-gray-600">Tổng đặt phòng</p>
                </div>
                <div class="bg-white rounded-lg shadow-lg p-6 text-center">
                    <div class="text-3xl font-bold text-green-600 mb-2">0</div>
                    <p class="text-gray-600">Đã xác nhận</p>
                </div>
                <div class="bg-white rounded-lg shadow-lg p-6 text-center">
                    <div class="text-3xl font-bold text-yellow-600 mb-2">0</div>
                    <p class="text-gray-600">Chờ xác nhận</p>
                </div>
                <div class="bg-white rounded-lg shadow-lg p-6 text-center">
                    <div class="text-3xl font-bold text-red-600 mb-2">0</div>
                    <p class="text-gray-600">Đã hủy</p>
                </div>
            </div>
        </div>
    </div>

    <!-- Footer -->
    <footer class="bg-gray-800 text-white py-8">
        <div class="container mx-auto px-4 text-center">
            <p>&copy; 2024 Petcity - Dịch vụ lưu trú thú cưng chuyên nghiệp</p>
            <p class="text-gray-400 mt-2">Hotline: 1900-xxxx | Email: info@petcity.com</p>
        </div>
    </footer>

    <script>
        function filterBookings(status) {
            // Remove active class from all buttons
            document.querySelectorAll('.filter-btn').forEach(btn => {
                btn.classList.remove('active');
            });
            
            // Add active class to clicked button
            event.target.classList.add('active');
            
            // Filter logic will be implemented when real data is available
            console.log('Filtering by status:', status);
        }
        
        // Add smooth scrolling
        document.querySelectorAll('a[href^="#"]').forEach(anchor => {
            anchor.addEventListener('click', function (e) {
                e.preventDefault();
                const target = document.querySelector(this.getAttribute('href'));
                if (target) {
                    target.scrollIntoView({
                        behavior: 'smooth'
                    });
                }
            });
        });
    </script>
</body>
</html>
