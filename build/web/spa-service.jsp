<%@page import="model.Customer"%>
<%@page import="model.CartItem"%>
<%@page import="model.PetServiceModel"%>
<%@page import="java.util.Map"%>
<%@page import="java.util.List"%>
<%@page import="java.util.ArrayList"%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%
    Customer currentUser = (Customer) session.getAttribute("currentUser");
    Map<Integer, CartItem> cart = (Map<Integer, CartItem>) session.getAttribute("cart");
    int cartCount = 0;
    double cartTotal = 0;
    if (cart != null) {
        for (CartItem item : cart.values()) {
            if (item != null && item.getProduct() != null) {
                cartCount += item.getQuantity();
                cartTotal += item.getQuantity() * item.getProduct().getPrice();
            }
        }
    }
    
    // Get spa services from request attributes
    List<PetServiceModel> spaServices = (List<PetServiceModel>) request.getAttribute("spaServices");
    if (spaServices == null) {
        // Nếu không có dữ liệu từ servlet, thử load từ service trực tiếp
        try {
            service.SpaBookingService spaService = new service.SpaBookingService();
            spaServices = spaService.getActiveSpaServices();
        } catch (Exception e) {
            spaServices = new ArrayList<>();
        }
    }
%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>💆 Dịch vụ Spa cho thú cưng - Petcity</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.3/css/all.min.css" rel="stylesheet" />
    <link href="https://fonts.googleapis.com/css2?family=Quicksand:wght@300;400;500;600;700&family=Nunito:wght@300;400;500;600;700;800&family=Baloo+2:wght@400;500;600;700;800&display=swap" rel="stylesheet" />
    <link rel="stylesheet" href="css/homeStyle.css" />
    <style>
        .service-card {
            transition: all 0.3s ease;
            border-radius: 15px;
            overflow: hidden;
            box-shadow: 0 4px 15px rgba(0,0,0,0.1);
        }
        .service-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 8px 25px rgba(0,0,0,0.15);
        }
        .service-icon {
            font-size: 3rem;
            margin-bottom: 1rem;
        }
        .price-tag {
            background: linear-gradient(135deg, #ff6b6b, #ffa500);
            color: white;
            padding: 0.5rem 1rem;
            border-radius: 25px;
            font-weight: bold;
            display: inline-block;
        }
        .duration-badge {
            background: linear-gradient(135deg, #4ecdc4, #44a08d);
            color: white;
            padding: 0.3rem 0.8rem;
            border-radius: 15px;
            font-size: 0.9rem;
        }
        .hero-section {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 4rem 0;
            text-align: center;
        }
        .booking-btn {
            background: linear-gradient(135deg, #ff6b6b, #ffa500);
            color: white;
            padding: 0.8rem 2rem;
            border-radius: 25px;
            text-decoration: none;
            font-weight: bold;
            transition: all 0.3s ease;
            display: inline-block;
        }
        .booking-btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(255, 107, 107, 0.4);
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
                <a href="<%= request.getContextPath()%>/cart/cart.jsp">
                    <i class="fas fa-shopping-cart"></i> Giỏ hàng / <span class="cart-amount"><%= String.format("%.2f", cartTotal)%></span>₫
                </a>
                <span class="cart-count"><%= cartCount%></span>
            </div>
            <div>
                <a href="<%= request.getContextPath()%>/spa-booking?action=cart">
                    <i class="fas fa-spa"></i> Giỏ Spa
                </a>
            </div>
        </div>
    </header>

    <!-- Navigation -->
    <nav>
        <ul>
            <li><a href="<%= request.getContextPath()%>/home">TRANG CHỦ</a></li>
            <li><a href="${pageContext.request.contextPath}/spa-service" style="background: rgba(255, 255, 255, 0.2);">DỊCH VỤ</a></li>
            <li><a href="search?categoryId=2">SẢN PHẨM</a></li>
            <li><a href="doctor.jsp">BÁC SĨ</a></li>
            <li><a href="gioi-thieu.jsp">GIỚI THIỆU</a></li>
            <li><a href="tin-tuc.jsp">TIN TỨC</a></li>
            <li><a href="<%= request.getContextPath()%>/home">LIÊN HỆ</a></li>
        </ul>
    </nav>

    <!-- Hero Section -->
    <section class="hero-section">
        <div class="container mx-auto px-6">
            <h1 class="text-5xl font-bold mb-4">💆 Dịch vụ Spa cho thú cưng</h1>
            <p class="text-xl mb-8 max-w-3xl mx-auto">
                Chăm sóc và làm đẹp toàn diện cho thú cưng yêu quý của bạn với các dịch vụ spa chuyên nghiệp
            </p>
            <div class="flex flex-wrap justify-center gap-4">
                <div class="bg-white bg-opacity-20 rounded-lg p-4">
                    <i class="fas fa-shield-alt text-2xl mb-2"></i>
                    <p class="font-semibold">An toàn tuyệt đối</p>
                </div>
                <div class="bg-white bg-opacity-20 rounded-lg p-4">
                    <i class="fas fa-star text-2xl mb-2"></i>
                    <p class="font-semibold">Chất lượng cao</p>
                </div>
                <div class="bg-white bg-opacity-20 rounded-lg p-4">
                    <i class="fas fa-heart text-2xl mb-2"></i>
                    <p class="font-semibold">Yêu thương thú cưng</p>
                </div>
            </div>
        </div>
    </section>

    <!-- Services Section -->
    <main class="main-content px-6 py-10 bg-white rounded shadow mt-4 max-w-7xl mx-auto">
        <section class="mb-16">
            <h2 class="text-4xl font-bold mb-10 text-center text-orange-600">🌟 Các dịch vụ Spa</h2>
            
            <% if (spaServices != null && !spaServices.isEmpty()) { %>
            <div class="grid md:grid-cols-2 lg:grid-cols-3 gap-8">
                <% for (PetServiceModel service : spaServices) { %>
                <div class="service-card bg-white">
                    <div class="p-6 text-center">
                        <div class="service-icon">
                            <% 
                                String icon = "🛁"; // default
                                String serviceName = service.getName().toLowerCase();
                                if (serviceName.contains("cắt") || serviceName.contains("tỉa")) {
                                    icon = "✂️";
                                } else if (serviceName.contains("móng")) {
                                    icon = "💅";
                                } else if (serviceName.contains("tai") || serviceName.contains("răng")) {
                                    icon = "🦷";
                                } else if (serviceName.contains("massage")) {
                                    icon = "💆";
                                } else if (serviceName.contains("cao cấp") || serviceName.contains("spa")) {
                                    icon = "✨";
                                } else if (serviceName.contains("thuốc") || serviceName.contains("ký sinh")) {
                                    icon = "🧴";
                                } else if (serviceName.contains("da") || serviceName.contains("lông")) {
                                    icon = "🌿";
                                }
                            %>
                            <%= icon %>
                        </div>
                        <h3 class="text-xl font-bold text-gray-800 mb-3"><%= service.getName() %></h3>
                        <p class="text-gray-600 mb-4 leading-relaxed"><%= service.getDescription() != null ? service.getDescription() : "Dịch vụ spa chuyên nghiệp cho thú cưng" %></p>
                        <div class="flex justify-between items-center mb-4">
                            <span class="price-tag">
                                <fmt:formatNumber value="<%= service.getPrice() %>" type="currency" currencySymbol="₫" maxFractionDigits="0"/>
                            </span>
                            <span class="duration-badge"><%= service.getDuration() %> phút</span>
                        </div>
                        <a href="<%= request.getContextPath() %>/spa-booking?action=service-detail&serviceId=<%= service.getServiceId() %>" class="booking-btn">
                            👁️ Xem chi tiết
                        </a>
                    </div>
                </div>
                <% } %>
            </div>
            <% } else { %>
            <div class="text-center py-16">
                <i class="fas fa-spa text-6xl text-gray-400 mb-4"></i>
                <h3 class="text-2xl font-semibold text-gray-600 mb-2">Chưa có dịch vụ Spa</h3>
                <p class="text-gray-500 mb-6">Hiện tại chưa có dịch vụ spa nào được cung cấp</p>
                <a href="${pageContext.request.contextPath}/home" class="booking-btn">
                    <i class="fas fa-home mr-2"></i>Về trang chủ
                </a>
            </div>
            <% } %>
        </section>

        <!-- Pet Boarding Services Section -->
        <section class="mb-16">
            <h2 class="text-4xl font-bold mb-10 text-center text-green-600">🏠 Dịch vụ Lưu trú Thú cưng</h2>
            
            <div class="grid md:grid-cols-2 lg:grid-cols-3 gap-8">
                <!-- Phòng Chó Lớn -->
                <div class="service-card bg-white">
                    <div class="p-6 text-center">
                        <div class="service-icon">
                            🐕
                        </div>
                        <h3 class="text-xl font-bold text-gray-800 mb-3">Phòng Chó Lớn</h3>
                        <p class="text-gray-600 mb-4 leading-relaxed">Phòng rộng rãi, có camera và điều hòa cho chó lớn. Chăm sóc 24/7 với đội ngũ chuyên nghiệp.</p>
                        <div class="flex justify-between items-center mb-4">
                            <span class="price-tag">
                                ₫400,000
                            </span>
                            <span class="duration-badge">1 ngày</span>
                        </div>
                        <button type="button" onclick="openBoardingModal(1, 'dog_large', 400000)" class="booking-btn">
                            🏠 Đặt phòng lưu trú
                        </button>
                    </div>
                </div>

                <!-- Phòng Chó Nhỏ -->
                <div class="service-card bg-white">
                    <div class="p-6 text-center">
                        <div class="service-icon">
                            🐕
                        </div>
                        <h3 class="text-xl font-bold text-gray-800 mb-3">Phòng Chó Nhỏ</h3>
                        <p class="text-gray-600 mb-4 leading-relaxed">Phòng đôi cho chó nhỏ, có giường riêng. Không gian ấm cúng và an toàn.</p>
                        <div class="flex justify-between items-center mb-4">
                            <span class="price-tag">
                                ₫300,000
                            </span>
                            <span class="duration-badge">1 ngày</span>
                        </div>
                        <button type="button" onclick="openBoardingModal(3, 'dog_small', 300000)" class="booking-btn">
                            🏠 Đặt phòng lưu trú
                        </button>
                    </div>
                </div>

                <!-- Phòng Mèo Tiêu Chuẩn -->
                <div class="service-card bg-white">
                    <div class="p-6 text-center">
                        <div class="service-icon">
                            🐱
                        </div>
                        <h3 class="text-xl font-bold text-gray-800 mb-3">Phòng Mèo Tiêu Chuẩn</h3>
                        <p class="text-gray-600 mb-4 leading-relaxed">Phòng cho mèo, có cát vệ sinh và đồ chơi. Môi trường thoải mái cho mèo.</p>
                        <div class="flex justify-between items-center mb-4">
                            <span class="price-tag">
                                ₫250,000
                            </span>
                            <span class="duration-badge">1 ngày</span>
                        </div>
                        <button type="button" onclick="openBoardingModal(5, 'cat_standard', 250000)" class="booking-btn">
                            🏠 Đặt phòng lưu trú
                        </button>
                    </div>
                </div>

                <!-- Phòng Mèo VIP -->
                <div class="service-card bg-white">
                    <div class="p-6 text-center">
                        <div class="service-icon">
                            🐱
                        </div>
                        <h3 class="text-xl font-bold text-gray-800 mb-3">Phòng Mèo VIP</h3>
                        <p class="text-gray-600 mb-4 leading-relaxed">Phòng VIP cho mèo, có khu chơi riêng và máy lạnh. Dịch vụ cao cấp nhất.</p>
                        <div class="flex justify-between items-center mb-4">
                            <span class="price-tag">
                                ₫350,000
                            </span>
                            <span class="duration-badge">1 ngày</span>
                        </div>
                        <button type="button" onclick="openBoardingModal(7, 'cat_vip', 350000)" class="booking-btn">
                            🏠 Đặt phòng lưu trú
                        </button>
                    </div>
                </div>
            </div>
        </section>

        <!-- Health Check Services Section -->
        <section class="mb-16">
            <h2 class="text-4xl font-bold mb-10 text-center text-blue-600">🏥 Dịch vụ Khám sức khỏe</h2>
            
            <div class="grid md:grid-cols-2 lg:grid-cols-3 gap-8">
                <!-- Khám sức khỏe tổng quát -->
                <div class="service-card bg-white">
                    <div class="p-6 text-center">
                        <div class="service-icon">
                            🩺
                        </div>
                        <h3 class="text-xl font-bold text-gray-800 mb-3">Khám sức khỏe tổng quát</h3>
                        <p class="text-gray-600 mb-4 leading-relaxed">Kiểm tra sức khỏe tổng quát: khám lâm sàng, đo nhiệt độ, nhịp tim</p>
                        <div class="flex justify-between items-center mb-4">
                            <span class="price-tag">
                                ₫200,000
                            </span>
                            <span class="duration-badge">30 phút</span>
                        </div>
                        <form method="POST" action="/Pets4Care/health-check-booking" style="display: inline;">
                            <input type="hidden" name="action" value="add-to-cart">
                            <input type="hidden" name="serviceId" value="1">
                            <input type="hidden" name="quantity" value="1">
                            <button type="submit" class="booking-btn">
                                🛒 Thêm vào giỏ Khám
                            </button>
                        </form>
                    </div>
                </div>

                <!-- Khám chuyên sâu -->
                <div class="service-card bg-white">
                    <div class="p-6 text-center">
                        <div class="service-icon">
                            🔬
                        </div>
                        <h3 class="text-xl font-bold text-gray-800 mb-3">Khám chuyên sâu</h3>
                        <p class="text-gray-600 mb-4 leading-relaxed">Khám chuyên sâu: xét nghiệm máu, nước tiểu, X-quang</p>
                        <div class="flex justify-between items-center mb-4">
                            <span class="price-tag">
                                ₫500,000
                            </span>
                            <span class="duration-badge">60 phút</span>
                        </div>
                        <form method="POST" action="/Pets4Care/health-check-booking" style="display: inline;">
                            <input type="hidden" name="action" value="add-to-cart">
                            <input type="hidden" name="serviceId" value="2">
                            <input type="hidden" name="quantity" value="1">
                            <button type="submit" class="booking-btn">
                                🛒 Thêm vào giỏ Khám
                            </button>
                        </form>
                    </div>
                </div>

                <!-- Khám định kỳ -->
                <div class="service-card bg-white">
                    <div class="p-6 text-center">
                        <div class="service-icon">
                            📅
                        </div>
                        <h3 class="text-xl font-bold text-gray-800 mb-3">Khám định kỳ</h3>
                        <p class="text-gray-600 mb-4 leading-relaxed">Khám định kỳ 6 tháng/1 lần: kiểm tra cơ bản</p>
                        <div class="flex justify-between items-center mb-4">
                            <span class="price-tag">
                                ₫150,000
                            </span>
                            <span class="duration-badge">20 phút</span>
                        </div>
                        <form method="POST" action="/Pets4Care/health-check-booking" style="display: inline;">
                            <input type="hidden" name="action" value="add-to-cart">
                            <input type="hidden" name="serviceId" value="3">
                            <input type="hidden" name="quantity" value="1">
                            <button type="submit" class="booking-btn">
                                🛒 Thêm vào giỏ Khám
                            </button>
                        </form>
                    </div>
                </div>

                <!-- Tiêm phòng cơ bản -->
                <div class="service-card bg-white">
                    <div class="p-6 text-center">
                        <div class="service-icon">
                            💉
                        </div>
                        <h3 class="text-xl font-bold text-gray-800 mb-3">Tiêm phòng cơ bản</h3>
                        <p class="text-gray-600 mb-4 leading-relaxed">Tiêm phòng: dại, viêm gan, parvo, distemper</p>
                        <div class="flex justify-between items-center mb-4">
                            <span class="price-tag">
                                ₫300,000
                            </span>
                            <span class="duration-badge">20 phút</span>
                        </div>
                        <form method="POST" action="/Pets4Care/health-check-booking" style="display: inline;">
                            <input type="hidden" name="action" value="add-to-cart">
                            <input type="hidden" name="serviceId" value="4">
                            <input type="hidden" name="quantity" value="1">
                            <button type="submit" class="booking-btn">
                                🛒 Thêm vào giỏ Khám
                            </button>
                        </form>
                    </div>
                </div>

                <!-- Tư vấn dinh dưỡng -->
                <div class="service-card bg-white">
                    <div class="p-6 text-center">
                        <div class="service-icon">
                            🥗
                        </div>
                        <h3 class="text-xl font-bold text-gray-800 mb-3">Tư vấn dinh dưỡng</h3>
                        <p class="text-gray-600 mb-4 leading-relaxed">Tư vấn chế độ dinh dưỡng phù hợp</p>
                        <div class="flex justify-between items-center mb-4">
                            <span class="price-tag">
                                ₫100,000
                            </span>
                            <span class="duration-badge">30 phút</span>
                        </div>
                        <form method="POST" action="/Pets4Care/health-check-booking" style="display: inline;">
                            <input type="hidden" name="action" value="add-to-cart">
                            <input type="hidden" name="serviceId" value="5">
                            <input type="hidden" name="quantity" value="1">
                            <button type="submit" class="booking-btn">
                                🛒 Thêm vào giỏ Khám
                            </button>
                        </form>
                    </div>
                </div>
            </div>
        </section>

        <!-- Why Choose Us Section -->
        <section class="mb-16 bg-gradient-to-r from-blue-50 to-purple-50 rounded-2xl p-8">
            <h3 class="text-3xl font-bold text-center text-gray-800 mb-8">🎯 Tại sao chọn Petcity Spa?</h3>
            <div class="grid md:grid-cols-3 gap-8">
                <div class="text-center">
                    <div class="bg-blue-100 rounded-full w-16 h-16 flex items-center justify-center mx-auto mb-4">
                        <i class="fas fa-user-md text-2xl text-blue-600"></i>
                    </div>
                    <h4 class="text-xl font-bold text-gray-800 mb-2">Chuyên gia giàu kinh nghiệm</h4>
                    <p class="text-gray-600">Đội ngũ kỹ thuật viên được đào tạo chuyên nghiệp, có nhiều năm kinh nghiệm trong lĩnh vực chăm sóc thú cưng.</p>
                </div>
                <div class="text-center">
                    <div class="bg-green-100 rounded-full w-16 h-16 flex items-center justify-center mx-auto mb-4">
                        <i class="fas fa-leaf text-2xl text-green-600"></i>
                    </div>
                    <h4 class="text-xl font-bold text-gray-800 mb-2">Sản phẩm tự nhiên</h4>
                    <p class="text-gray-600">Sử dụng các sản phẩm chăm sóc tự nhiên, an toàn cho da và lông thú cưng, không gây kích ứng.</p>
                </div>
                <div class="text-center">
                    <div class="bg-purple-100 rounded-full w-16 h-16 flex items-center justify-center mx-auto mb-4">
                        <i class="fas fa-home text-2xl text-purple-600"></i>
                    </div>
                    <h4 class="text-xl font-bold text-gray-800 mb-2">Môi trường thân thiện</h4>
                    <p class="text-gray-600">Không gian spa thoải mái, giúp thú cưng cảm thấy an toàn và thư giãn trong quá trình chăm sóc.</p>
                </div>
            </div>
        </section>

        <!-- Booking Process Section -->
        <section class="mb-16">
            <h3 class="text-3xl font-bold text-center text-gray-800 mb-8">📋 Quy trình đặt lịch</h3>
            <div class="grid md:grid-cols-4 gap-6">
                <div class="text-center">
                    <div class="bg-orange-500 text-white rounded-full w-12 h-12 flex items-center justify-center mx-auto mb-4 text-xl font-bold">1</div>
                    <h4 class="font-bold text-gray-800 mb-2">Chọn dịch vụ</h4>
                    <p class="text-gray-600 text-sm">Lựa chọn dịch vụ spa phù hợp với nhu cầu của thú cưng</p>
                </div>
                <div class="text-center">
                    <div class="bg-orange-500 text-white rounded-full w-12 h-12 flex items-center justify-center mx-auto mb-4 text-xl font-bold">2</div>
                    <h4 class="font-bold text-gray-800 mb-2">Đặt lịch hẹn</h4>
                    <p class="text-gray-600 text-sm">Chọn thời gian và ngày phù hợp với lịch trình của bạn</p>
                </div>
                <div class="text-center">
                    <div class="bg-orange-500 text-white rounded-full w-12 h-12 flex items-center justify-center mx-auto mb-4 text-xl font-bold">3</div>
                    <h4 class="font-bold text-gray-800 mb-2">Đến spa</h4>
                    <p class="text-gray-600 text-sm">Mang thú cưng đến spa đúng giờ hẹn</p>
                </div>
                <div class="text-center">
                    <div class="bg-orange-500 text-white rounded-full w-12 h-12 flex items-center justify-center mx-auto mb-4 text-xl font-bold">4</div>
                    <h4 class="font-bold text-gray-800 mb-2">Tận hưởng</h4>
                    <p class="text-gray-600 text-sm">Thú cưng được chăm sóc và bạn nhận lại một em bé xinh đẹp</p>
                </div>
            </div>
        </section>

        <!-- Contact Section -->
        <section class="text-center bg-gray-100 rounded-2xl p-8">
            <h3 class="text-2xl font-bold text-gray-800 mb-4">📞 Liên hệ đặt lịch</h3>
            <p class="text-gray-600 mb-6">Để đặt lịch spa cho thú cưng, vui lòng liên hệ với chúng tôi</p>
            <div class="flex flex-wrap justify-center gap-4 mb-6">
                <a href="tel:090900900" class="bg-green-500 text-white px-6 py-3 rounded-full hover:bg-green-600 transition">
                    <i class="fas fa-phone mr-2"></i>090 900 900
                </a>
                <a href="mailto:support@petcity.vn" class="bg-blue-500 text-white px-6 py-3 rounded-full hover:bg-blue-600 transition">
                    <i class="fas fa-envelope mr-2"></i>support@petcity.vn
                </a>
            </div>
            <p class="text-sm text-gray-500">⏰ Giờ làm việc: 8:00 - 17:00 (Thứ 2 - Chủ nhật)</p>
        </section>
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

    <!-- Boarding Modal -->
    <div id="boardingModal" class="fixed inset-0 bg-black bg-opacity-50 hidden z-50">
        <div class="flex items-center justify-center min-h-screen p-4">
            <div class="bg-white rounded-lg max-w-2xl w-full max-h-[90vh] overflow-y-auto">
                <div class="p-6">
                    <div class="flex justify-between items-center mb-6">
                        <h3 class="text-2xl font-bold text-gray-800">🏠 Đặt phòng lưu trú</h3>
                        <button onclick="closeBoardingModal()" class="text-gray-500 hover:text-gray-700">
                            <i class="fas fa-times text-xl"></i>
                        </button>
                    </div>
                    
                    <form id="boardingForm" method="POST" action="${pageContext.request.contextPath}/spa-booking">
                        <input type="hidden" name="action" value="create-boarding-booking">
                        <input type="hidden" name="roomId" id="selectedRoomId">
                        <input type="hidden" name="roomType" id="selectedRoomType">
                        <input type="hidden" name="pricePerDay" id="selectedPricePerDay">
                        
                        <!-- Room Info -->
                        <div class="bg-gray-50 rounded-lg p-4 mb-6">
                            <h4 class="font-semibold text-gray-800 mb-2">Thông tin phòng</h4>
                            <div class="grid md:grid-cols-2 gap-4">
                                <div>
                                    <label class="text-sm text-gray-600">Loại phòng:</label>
                                    <p class="font-semibold" id="roomTypeDisplay"></p>
                                </div>
                                <div>
                                    <label class="text-sm text-gray-600">Giá/ngày:</label>
                                    <p class="font-semibold text-green-600" id="priceDisplay"></p>
                                </div>
                            </div>
                        </div>
                        
                        <!-- Booking Details -->
                        <div class="grid md:grid-cols-2 gap-4 mb-4">
                            <div>
                                <label class="block text-sm font-semibold text-gray-700 mb-2">Số ngày lưu trú *</label>
                                <input type="number" name="boardingDays" id="boardingDays" min="0" max="30" value="0" 
                                       class="w-full border rounded px-3 py-2" required onchange="calculateBoardingPrice()">
                            </div>
                            <div>
                                <label class="block text-sm font-semibold text-gray-700 mb-2">Tổng giá</label>
                                <div class="bg-green-50 border border-green-200 rounded px-3 py-2">
                                    <span class="font-bold text-green-600" id="totalPrice">₫400,000</span>
                                </div>
                            </div>
                        </div>
                        
                        <div class="grid md:grid-cols-2 gap-4 mb-4">
                            <div>
                                <label class="block text-sm font-semibold text-gray-700 mb-2">Ngày nhận *</label>
                                <input type="date" name="checkInDate" id="checkInDate" 
                                       class="w-full border rounded px-3 py-2" required>
                            </div>
                            <div>
                                <label class="block text-sm font-semibold text-gray-700 mb-2">Ngày trả *</label>
                                <input type="date" name="checkOutDate" id="checkOutDate" 
                                       class="w-full border rounded px-3 py-2" required readonly>
                            </div>
                        </div>
                        
                        <div class="grid md:grid-cols-2 gap-4 mb-4">
                            <div>
                                <label class="block text-sm font-semibold text-gray-700 mb-2">Giờ nhận</label>
                                <div class="grid grid-cols-2 gap-2">
                                    <div>
                                        <select name="checkInHour" class="w-full border rounded px-3 py-2">
                                            <option value="07">07</option>
                                            <option value="08">08</option>
                                            <option value="09">09</option>
                                            <option value="10">10</option>
                                            <option value="11">11</option>
                                            <option value="12">12</option>
                                            <option value="13">13</option>
                                            <option value="14">14</option>
                                            <option value="15">15</option>
                                            <option value="16">16</option>
                                            <option value="17">17</option>
                                            <option value="18">18</option>
                                            <option value="19">19</option>
                                            <option value="20">20</option>
                                            <option value="21">21</option>
                                            <option value="22">22</option>
                                        </select>
                                        <label class="text-xs text-gray-500 mt-1 block text-center">giờ</label>
                                    </div>
                                    <div>
                                        <select name="checkInMinute" class="w-full border rounded px-3 py-2">
                                            <option value="00">00</option>
                                            <option value="01">01</option>
                                            <option value="02">02</option>
                                            <option value="03">03</option>
                                            <option value="04">04</option>
                                            <option value="05">05</option>
                                            <option value="06">06</option>
                                            <option value="07">07</option>
                                            <option value="08">08</option>
                                            <option value="09">09</option>
                                            <option value="10">10</option>
                                            <option value="11">11</option>
                                            <option value="12">12</option>
                                            <option value="13">13</option>
                                            <option value="14">14</option>
                                            <option value="15">15</option>
                                            <option value="16">16</option>
                                            <option value="17">17</option>
                                            <option value="18">18</option>
                                            <option value="19">19</option>
                                            <option value="20">20</option>
                                            <option value="21">21</option>
                                            <option value="22">22</option>
                                            <option value="23">23</option>
                                            <option value="24">24</option>
                                            <option value="25">25</option>
                                            <option value="26">26</option>
                                            <option value="27">27</option>
                                            <option value="28">28</option>
                                            <option value="29">29</option>
                                            <option value="30">30</option>
                                            <option value="31">31</option>
                                            <option value="32">32</option>
                                            <option value="33">33</option>
                                            <option value="34">34</option>
                                            <option value="35">35</option>
                                            <option value="36">36</option>
                                            <option value="37">37</option>
                                            <option value="38">38</option>
                                            <option value="39">39</option>
                                            <option value="40">40</option>
                                            <option value="41">41</option>
                                            <option value="42">42</option>
                                            <option value="43">43</option>
                                            <option value="44">44</option>
                                            <option value="45">45</option>
                                            <option value="46">46</option>
                                            <option value="47">47</option>
                                            <option value="48">48</option>
                                            <option value="49">49</option>
                                            <option value="50">50</option>
                                            <option value="51">51</option>
                                            <option value="52">52</option>
                                            <option value="53">53</option>
                                            <option value="54">54</option>
                                            <option value="55">55</option>
                                            <option value="56">56</option>
                                            <option value="57">57</option>
                                            <option value="58">58</option>
                                            <option value="59">59</option>
                                        </select>
                                        <label class="text-xs text-gray-500 mt-1 block text-center">phút</label>
                                    </div>
                                </div>
                            </div>
                            <div>
                                <label class="block text-sm font-semibold text-gray-700 mb-2">Giờ trả</label>
                                <div class="grid grid-cols-2 gap-2">
                                    <div>
                                        <select name="checkOutHour" class="w-full border rounded px-3 py-2">
                                            <option value="07">07</option>
                                            <option value="08">08</option>
                                            <option value="09">09</option>
                                            <option value="10">10</option>
                                            <option value="11">11</option>
                                            <option value="12">12</option>
                                            <option value="13">13</option>
                                            <option value="14">14</option>
                                            <option value="15">15</option>
                                            <option value="16">16</option>
                                            <option value="17">17</option>
                                            <option value="18">18</option>
                                            <option value="19">19</option>
                                            <option value="20">20</option>
                                            <option value="21">21</option>
                                            <option value="22">22</option>
                                        </select>
                                        <label class="text-xs text-gray-500 mt-1 block text-center">giờ</label>
                                    </div>
                                    <div>
                                        <select name="checkOutMinute" class="w-full border rounded px-3 py-2">
                                            <option value="00">00</option>
                                            <option value="01">01</option>
                                            <option value="02">02</option>
                                            <option value="03">03</option>
                                            <option value="04">04</option>
                                            <option value="05">05</option>
                                            <option value="06">06</option>
                                            <option value="07">07</option>
                                            <option value="08">08</option>
                                            <option value="09">09</option>
                                            <option value="10">10</option>
                                            <option value="11">11</option>
                                            <option value="12">12</option>
                                            <option value="13">13</option>
                                            <option value="14">14</option>
                                            <option value="15">15</option>
                                            <option value="16">16</option>
                                            <option value="17">17</option>
                                            <option value="18">18</option>
                                            <option value="19">19</option>
                                            <option value="20">20</option>
                                            <option value="21">21</option>
                                            <option value="22">22</option>
                                            <option value="23">23</option>
                                            <option value="24">24</option>
                                            <option value="25">25</option>
                                            <option value="26">26</option>
                                            <option value="27">27</option>
                                            <option value="28">28</option>
                                            <option value="29">29</option>
                                            <option value="30">30</option>
                                            <option value="31">31</option>
                                            <option value="32">32</option>
                                            <option value="33">33</option>
                                            <option value="34">34</option>
                                            <option value="35">35</option>
                                            <option value="36">36</option>
                                            <option value="37">37</option>
                                            <option value="38">38</option>
                                            <option value="39">39</option>
                                            <option value="40">40</option>
                                            <option value="41">41</option>
                                            <option value="42">42</option>
                                            <option value="43">43</option>
                                            <option value="44">44</option>
                                            <option value="45">45</option>
                                            <option value="46">46</option>
                                            <option value="47">47</option>
                                            <option value="48">48</option>
                                            <option value="49">49</option>
                                            <option value="50">50</option>
                                            <option value="51">51</option>
                                            <option value="52">52</option>
                                            <option value="53">53</option>
                                            <option value="54">54</option>
                                            <option value="55">55</option>
                                            <option value="56">56</option>
                                            <option value="57">57</option>
                                            <option value="58">58</option>
                                            <option value="59">59</option>
                                        </select>
                                        <label class="text-xs text-gray-500 mt-1 block text-center">phút</label>
                                    </div>
                                </div>
                            </div>
                        </div>
                        
                        <div class="mb-4">
                            <label class="block text-sm font-semibold text-gray-700 mb-2">Thông tin thú cưng</label>
                            <div class="mb-2">
                                <select id="petSelect" class="w-full border rounded px-3 py-2" onchange="loadPetInfo()">
                                    <option value="">-- Chọn thú cưng --</option>
                                </select>
                            </div>
                            <textarea name="petInfo" id="petInfo" rows="3" 
                                      class="w-full border rounded px-3 py-2" 
                                      placeholder="Thông tin thú cưng sẽ được tự động điền..." readonly></textarea>
                        </div>
                        
                        <div class="mb-4">
                            <label class="block text-sm font-semibold text-gray-700 mb-2">Yêu cầu đặc biệt</label>
                            <textarea name="specialNotes" rows="2" 
                                      class="w-full border rounded px-3 py-2" 
                                      placeholder="Thức ăn đặc biệt, thuốc, thói quen, sở thích..."></textarea>
                        </div>
                        
                        <div class="grid md:grid-cols-2 gap-4 mb-6">
                            <div>
                                <label class="block text-sm font-semibold text-gray-700 mb-2">Số điện thoại khẩn cấp 1 *</label>
                                <input type="tel" name="emergencyPhone1" id="emergencyPhone1"
                                       class="w-full border rounded px-3 py-2" required placeholder="Nhập số điện thoại 10-11 chữ số">
                                <div class="text-xs text-red-500 mt-1" id="phone1-error" style="display: none;">Số điện thoại không hợp lệ</div>
                            </div>
                            <div>
                                <label class="block text-sm font-semibold text-gray-700 mb-2">Số điện thoại khẩn cấp 2</label>
                                <input type="tel" name="emergencyPhone2" id="emergencyPhone2"
                                       class="w-full border rounded px-3 py-2" placeholder="Nhập số điện thoại 10-11 chữ số (tùy chọn)">
                                <div class="text-xs text-red-500 mt-1" id="phone2-error" style="display: none;">Số điện thoại không hợp lệ</div>
                            </div>
                        </div>
                        
                        <!-- Payment Method -->
                        <div class="mb-6">
                            <label class="block text-sm font-semibold text-gray-700 mb-3">💰 Phương thức thanh toán</label>
                            <div class="grid grid-cols-2 gap-3">
                                <div class="border-2 rounded-lg p-3 cursor-pointer" id="payment-cash" onclick="selectPaymentMethod('cash')">
                                    <input type="radio" name="paymentMethod" value="cash" checked id="radio-cash" class="sr-only">
                                    <div class="flex items-center space-x-2">
                                        <div class="w-5 h-5 rounded-full border-2 border-green-500 flex items-center justify-center">
                                            <div class="w-3 h-3 rounded-full bg-green-500" id="check-cash"></div>
                                        </div>
                                        <div>
                                            <div class="font-semibold text-gray-800">💵 Tiền mặt</div>
                                            <div class="text-xs text-gray-500">Thanh toán khi nhận</div>
                                        </div>
                                    </div>
                                </div>
                                <div class="border-2 rounded-lg p-3 cursor-pointer" id="payment-payos" onclick="selectPaymentMethod('payos')">
                                    <input type="radio" name="paymentMethod" value="payos" id="radio-payos" class="sr-only">
                                    <div class="flex items-center space-x-2">
                                        <div class="w-5 h-5 rounded-full border-2 border-gray-300 flex items-center justify-center">
                                            <div class="w-3 h-3 rounded-full bg-green-500 hidden" id="check-payos"></div>
                                        </div>
                                        <div>
                                            <div class="font-semibold text-gray-800">💳 PayOS Online</div>
                                            <div class="text-xs text-gray-500">Thanh toán trực tuyến</div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                        
                        <!-- Terms and Conditions -->
                        <div class="bg-yellow-50 border border-yellow-200 rounded-lg p-4 mb-6">
                            <h4 class="font-semibold text-gray-800 mb-2">📋 Điều khoản lưu trú</h4>
                            <ul class="text-sm text-gray-700 space-y-1">
                                <li>• Phải đón thú cưng đúng hạn, phí trễ: 300,000₫/ngày</li>
                                <li>• Sau 7 ngày không đón, có thể chuyển giao cho tổ chức cứu trợ</li>
                                <li>• Chủ sở hữu chịu trách nhiệm chi phí ăn uống, vệ sinh, thuốc thang</li>
                                <li>• Được phép chăm sóc y tế khẩn cấp khi cần thiết</li>
                                <li>• Cần cung cấp 2 số điện thoại liên lạc khẩn cấp</li>
                            </ul>
                        </div>
                        
                        <div class="flex space-x-4">
                            <button type="button" onclick="closeBoardingModal()" 
                                    class="flex-1 bg-gray-500 text-white py-3 rounded hover:bg-gray-600 transition">
                                ❌ Hủy
                            </button>
                            <button type="submit" 
                                    class="flex-1 bg-green-500 text-white py-3 rounded hover:bg-green-600 transition"
                                    onclick="submitBoardingForm()">
                                🛒 Thêm vào giỏ Spa
                            </button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>

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
            
            // Set minimum date to today
            const today = new Date().toISOString().split('T')[0];
            document.getElementById('checkInDate').min = today;
        });
        
        // Boarding modal functions (moved to enhanced version below)
        
        function closeBoardingModal() {
            document.getElementById('boardingModal').classList.add('hidden');
        }
        
        function calculateBoardingPrice() {
            const days = parseInt(document.getElementById('boardingDays').value) || 0;
            const pricePerDay = parseInt(document.getElementById('selectedPricePerDay').value) || 0;
            
            console.log('calculateBoardingPrice called with days:', days, 'pricePerDay:', pricePerDay);
            
            // Lấy thời gian nhận và trả
            const checkInHour = parseInt(document.querySelector('select[name="checkInHour"]').value) || 8;
            const checkInMinute = parseInt(document.querySelector('select[name="checkInMinute"]').value) || 0;
            const checkOutHour = parseInt(document.querySelector('select[name="checkOutHour"]').value) || 17;
            const checkOutMinute = parseInt(document.querySelector('select[name="checkOutMinute"]').value) || 0;
            
            console.log('Time inputs - checkIn:', checkInHour + ':' + checkInMinute, 'checkOut:', checkOutHour + ':' + checkOutMinute);
            
            // Tính tổng số giờ lưu trú
            const totalHours = calculateTotalHours(days, checkInHour, checkInMinute, checkOutHour, checkOutMinute);
            
            console.log('Total hours calculated:', totalHours);
            
            // Tính giá theo logic 12 tiếng
            const totalPrice = calculatePriceByHours(totalHours, pricePerDay);
            
            console.log('Total price calculated:', totalPrice);
            
            document.getElementById('totalPrice').textContent = totalPrice.toLocaleString() + '₫';
            
            // Update check-out date
            updateCheckOutDate();
        }
        
        function calculateTotalHours(days, checkInHour, checkInMinute, checkOutHour, checkOutMinute) {
            // Tính tổng số giờ chính xác
            if (days === 0) {
                // Nếu 0 ngày, tính từ giờ nhận đến giờ trả trong cùng ngày
                const checkInDecimal = checkInHour + checkInMinute/60.0;
                const checkOutDecimal = checkOutHour + checkOutMinute/60.0;
                return Math.max(0, checkOutDecimal - checkInDecimal);
            } else if (days === 1) {
                // Nếu 1 ngày, tính từ giờ nhận đến giờ trả ngày hôm sau
                const checkInDecimal = checkInHour + checkInMinute/60.0;
                const checkOutDecimal = checkOutHour + checkOutMinute/60.0;
                return 24.0 - checkInDecimal + checkOutDecimal;
            } else {
                // Nếu nhiều ngày: ngày đầu + ngày giữa + ngày cuối
                const firstDayHours = 24.0 - (checkInHour + checkInMinute/60.0);
                const lastDayHours = checkOutHour + checkOutMinute/60.0;
                const middleDaysHours = (days - 1) * 24.0; // Sửa: (days - 1) thay vì (days - 2)
                const totalHours = firstDayHours + middleDaysHours + lastDayHours;
                
                console.log('Multi-day calculation:', {
                    days: days,
                    firstDayHours: firstDayHours,
                    middleDaysHours: middleDaysHours,
                    lastDayHours: lastDayHours,
                    totalHours: totalHours
                });
                
                return totalHours;
            }
        }
        
        function calculatePriceByHours(totalHours, pricePerDay) {
            // Logic tính giá mới:
            // - 24h đầu tiên: Mỗi 3 giờ tính 1 lần (12.5% giá 24h)
            // - Ngày 2 trở đi: Mỗi 6 giờ tính 1 lần (25% giá 24h)
            
            console.log(`calculatePriceByHours called with totalHours: ${totalHours}, pricePerDay: ${pricePerDay}`);
            
            if (totalHours <= 0) {
                // Không có thời gian: Miễn phí
                console.log(`Boarding duration: ${totalHours} hours - FREE (no time)`);
                return 0;
            } else if (totalHours < 0.5) {
                // Dưới 30 phút: Miễn phí
                console.log(`Boarding duration: ${totalHours} hours - FREE (under 30 minutes)`);
                return 0;
            } else if (totalHours < 1.0) {
                // 30 phút - 1 tiếng: Phí tối thiểu 5% giá 24h
                const minimumPrice = pricePerDay * 0.05;
                console.log(`Boarding duration: ${totalHours} hours - MINIMUM CHARGE (5% of 24h): ${minimumPrice}`);
                return minimumPrice;
            } else {
                let totalPrice = 0;
                
                if (totalHours <= 24.0) {
                    // 24h đầu tiên: Mỗi 3 giờ tính 1 lần (12.5% mỗi chu kỳ)
                    const full3HourPeriods = Math.ceil(totalHours / 3.0);
                    const pricePer3Hours = pricePerDay * 0.125;
                    totalPrice = pricePer3Hours * full3HourPeriods;
                    
                    console.log(`Boarding duration: ${totalHours} hours - ${full3HourPeriods} periods of 3h (12.5% each): ${totalPrice}`);
                } else {
                    // Ngày 2 trở đi: Mỗi 6 giờ tính 1 lần
                    // 24h đầu: 8 chu kỳ 3h = 8 * 12.5% = 100% giá 24h
                    const firstDayPrice = pricePerDay;
                    
                    // Phần còn lại: Mỗi 6 giờ tính 1 lần (25% mỗi chu kỳ)
                    const remainingHours = totalHours - 24.0;
                    const full6HourPeriods = Math.ceil(remainingHours / 6.0);
                    const pricePer6Hours = pricePerDay * 0.25;
                    const remainingPrice = pricePer6Hours * full6HourPeriods;
                    
                    totalPrice = firstDayPrice + remainingPrice;
                    
                    console.log(`Boarding duration: ${totalHours} hours - First 24h: ${firstDayPrice} + Remaining ${remainingHours}h (${full6HourPeriods} periods of 6h): ${remainingPrice} = ${totalPrice}`);
                }
                
                return totalPrice;
            }
        }
        
        function updateCheckOutDate() {
            const checkInDate = document.getElementById('checkInDate').value;
            const days = parseInt(document.getElementById('boardingDays').value) || 0;
            
            if (checkInDate) {
                const checkIn = new Date(checkInDate);
                const checkOut = new Date(checkIn);
                checkOut.setDate(checkOut.getDate() + days);
                
                document.getElementById('checkOutDate').value = checkOut.toISOString().split('T')[0];
            }
        }
        
        function selectPaymentMethod(method) {
            // Unselect all payment options
            document.getElementById('payment-cash').classList.remove('border-green-500');
            document.getElementById('payment-payos').classList.remove('border-green-500');
            document.getElementById('check-cash').classList.add('hidden');
            document.getElementById('check-payos').classList.add('hidden');
            
            // Select the clicked option
            document.getElementById('payment-' + method).classList.add('border-green-500');
            document.getElementById('check-' + method).classList.remove('hidden');
            document.getElementById('radio-' + method).checked = true;
        }
        
        function submitBoardingForm() {
            console.log('Submitting boarding form...');
            const form = document.getElementById('boardingForm');
            if (form) {
                form.submit();
            } else {
                console.error('Boarding form not found!');
            }
        }
        
        // Add event listeners
        document.getElementById('checkInDate').addEventListener('change', updateCheckOutDate);
        document.getElementById('boardingDays').addEventListener('change', calculateBoardingPrice);
        
        // Add event listeners for time changes
        document.querySelector('select[name="checkInHour"]').addEventListener('change', calculateBoardingPrice);
        document.querySelector('select[name="checkInMinute"]').addEventListener('change', calculateBoardingPrice);
        document.querySelector('select[name="checkOutHour"]').addEventListener('change', calculateBoardingPrice);
        document.querySelector('select[name="checkOutMinute"]').addEventListener('change', calculateBoardingPrice);
        
        // Load pets when page loads
        loadPets();
        
        // Store pets data globally
        let petsData = [];
        
        // Function to load pets from database
        function loadPets() {
            fetch('/Pets4Care/pet-info')
                .then(response => response.json())
                .then(data => {
                    console.log('Pets loaded:', data);
                    petsData = data.pets || []; // Store pets data globally
                    
                    const petSelect = document.getElementById('petSelect');
                    if (petSelect) {
                        // Clear existing options
                        petSelect.innerHTML = '<option value="">-- Chọn thú cưng --</option>';
                        
                        if (petsData.length > 0) {
                            petsData.forEach(pet => {
                                const option = document.createElement('option');
                                option.value = pet.id;
                                option.textContent = pet.name + ' (' + pet.species + ')';
                                petSelect.appendChild(option);
                            });
                        } else {
                            const option = document.createElement('option');
                            option.value = '';
                            option.textContent = 'Không có thú cưng nào';
                            petSelect.appendChild(option);
                        }
                    }
                })
                .catch(error => {
                    console.error('Error loading pets:', error);
                });
        }
        
        // Function to load pet info when selected
        function loadPetInfo() {
            const petSelect = document.getElementById('petSelect');
            const petInfo = document.getElementById('petInfo');
            
            if (petSelect && petInfo) {
                const selectedPetId = petSelect.value;
                if (selectedPetId) {
                    // Find pet data from stored petsData
                    const selectedPet = petsData.find(pet => pet.id == selectedPetId);
                    
                    if (selectedPet) {
                        // Tạo thông tin chi tiết từ database
                        petInfo.value = '🐾 THÔNG TIN THÚ CƯNG 🐾\n' +
                                      'Tên: ' + selectedPet.name + '\n' +
                                      'Loài: ' + selectedPet.species + '\n' +
                                      'Giống: ' + (selectedPet.breed || 'Không xác định') + '\n' +
                                      'Tuổi: ' + selectedPet.age + ' tuổi\n' +
                                      'Giới tính: ' + (selectedPet.gender === 'male' ? 'Đực' : 'Cái') + '\n' +
                                      'Tình trạng sức khỏe: ' + (selectedPet.healthStatus || 'Không xác định') + '\n' +
                                      'Mô tả: ' + (selectedPet.specialNotes || 'Không có mô tả');
                    } else {
                        petInfo.value = 'Không tìm thấy thông tin thú cưng';
                    }
                } else {
                    petInfo.value = '';
                }
            }
        }
    </script>
    
    <!-- Phone Validation Script -->
    <script src="js/phone-validation.js"></script>
    
    <script>
        // Enhanced phone validation for boarding modal
        function validatePhoneNumber(phone) {
            if (!phone || phone.trim() === '') {
                return false;
            }
            
            // Remove all non-digit characters
            const cleanPhone = phone.replace(/\D/g, '');
            
            // Check if phone has 10 or 11 digits
            const isValid = cleanPhone.length === 10 || cleanPhone.length === 11;
            
            console.log('Phone validation:', {
                original: phone,
                clean: cleanPhone,
                length: cleanPhone.length,
                isValid: isValid
            });
            
            return isValid;
        }
        
        function formatPhoneNumber(phone) {
            if (!phone) return '';
            
            // Remove all non-digit characters
            const cleanPhone = phone.replace(/\D/g, '');
            
            // Format based on length
            if (cleanPhone.length === 10) {
                return cleanPhone.replace(/(\d{4})(\d{3})(\d{3})/, '$1 $2 $3');
            } else if (cleanPhone.length === 11) {
                return cleanPhone.replace(/(\d{4})(\d{3})(\d{4})/, '$1 $2 $3');
            }
            
            return cleanPhone;
        }
        
        function validatePhoneInput(input) {
            const phone = input.value;
            const isValid = validatePhoneNumber(phone);
            const errorDiv = document.getElementById(input.id + '-error');
            
            // Remove validation classes
            input.classList.remove('border-red-500', 'border-green-500');
            
            if (phone.trim() === '') {
                // Empty input - neutral state
                input.classList.add('border-gray-300');
                if (errorDiv) errorDiv.style.display = 'none';
                input.setCustomValidity(''); // Clear HTML5 validation
                return true;
            }
            
            if (isValid) {
                input.classList.add('border-green-500');
                input.setCustomValidity(''); // Clear HTML5 validation
                if (errorDiv) errorDiv.style.display = 'none';
                return true;
            } else {
                input.classList.add('border-red-500');
                input.setCustomValidity('Số điện thoại phải có 10 hoặc 11 chữ số');
                if (errorDiv) errorDiv.style.display = 'block';
                return false;
            }
        }
        
        function formatPhoneInput(input) {
            const formatted = formatPhoneNumber(input.value);
            if (formatted !== input.value) {
                input.value = formatted;
            }
        }
        
        // Helper function to get room type display name
        function getRoomTypeDisplay(roomType) {
            const roomTypes = {
                'dog_small': 'Phòng Chó Nhỏ',
                'dog_medium': 'Phòng Chó Vừa',
                'dog_large': 'Phòng Chó Lớn',
                'cat_standard': 'Phòng Mèo Tiêu Chuẩn',
                'cat_premium': 'Phòng Mèo Cao Cấp',
                'vip': 'Phòng VIP'
            };
            return roomTypes[roomType] || roomType;
        }
        
        // Helper function to format price
        function formatPrice(price) {
            return new Intl.NumberFormat('vi-VN', {
                style: 'currency',
                currency: 'VND'
            }).format(price).replace('₫', '₫');
        }
        
        // Initialize phone validation when modal opens
        function openBoardingModal(roomId, roomType, pricePerDay) {
            // Set form values
            document.getElementById('selectedRoomId').value = roomId;
            document.getElementById('selectedRoomType').value = roomType;
            document.getElementById('selectedPricePerDay').value = pricePerDay;
            
            // Update display
            document.getElementById('roomTypeDisplay').textContent = getRoomTypeDisplay(roomType);
            document.getElementById('priceDisplay').textContent = formatPrice(pricePerDay);
            
            // Show modal
            document.getElementById('boardingModal').classList.remove('hidden');
            
            // Auto-calculate price when modal opens
            setTimeout(() => {
                calculateBoardingPrice();
                loadPets(); // Load pet information
            }, 100);
            
            // Initialize phone validation
            setTimeout(() => {
                const emergencyPhone1 = document.getElementById('emergencyPhone1');
                const emergencyPhone2 = document.getElementById('emergencyPhone2');
                
                if (emergencyPhone1) {
                    emergencyPhone1.addEventListener('input', function() {
                        formatPhoneInput(this);
                        validatePhoneInput(this);
                    });
                    
                    emergencyPhone1.addEventListener('blur', function() {
                        validatePhoneInput(this);
                    });
                }
                
                if (emergencyPhone2) {
                    emergencyPhone2.addEventListener('input', function() {
                        formatPhoneInput(this);
                        validatePhoneInput(this);
                    });
                    
                    emergencyPhone2.addEventListener('blur', function() {
                        validatePhoneInput(this);
                    });
                }
            }, 100);
        }
        
        // Enhanced form submission with comprehensive validation
        function submitBoardingForm() {
            // Validate form trước khi submit
            const validationResult = validateBoardingForm();
            if (!validationResult.isValid) {
                showErrorMessage(validationResult.message);
                return false;
            }
            
            // Submit form
            const form = document.getElementById('boardingForm');
            if (form) {
                form.submit();
            }
        }
        
        function validateBoardingForm() {
            // Lấy các trường từ form
            const checkInDate = document.getElementById('checkInDate').value;
            const checkOutDate = document.getElementById('checkOutDate').value;
            const checkInHour = document.getElementById('checkInHour').value;
            const checkInMinute = document.getElementById('checkInMinute').value;
            const checkOutHour = document.getElementById('checkOutHour').value;
            const checkOutMinute = document.getElementById('checkOutMinute').value;
            const roomType = document.getElementById('roomType').value;
            const petSelect = document.getElementById('petSelect').value;
            const petInfo = document.getElementById('petInfo').value;
            const emergencyContact = document.getElementById('emergencyContact').value;
            const emergencyPhone1 = document.getElementById('emergencyPhone1').value;
            const emergencyPhone2 = document.getElementById('emergencyPhone2').value;
            const specialRequests = document.getElementById('specialRequests').value;
            
            // Validate ngày nhận
            if (!checkInDate) {
                return {
                    isValid: false,
                    message: '❌ Vui lòng chọn ngày nhận thú cưng'
                };
            }
            
            // Validate ngày trả
            if (!checkOutDate) {
                return {
                    isValid: false,
                    message: '❌ Vui lòng chọn ngày trả thú cưng'
                };
            }
            
            // Validate giờ nhận
            if (!checkInHour || !checkInMinute) {
                return {
                    isValid: false,
                    message: '❌ Vui lòng chọn giờ nhận thú cưng'
                };
            }
            
            // Validate giờ trả
            if (!checkOutHour || !checkOutMinute) {
                return {
                    isValid: false,
                    message: '❌ Vui lòng chọn giờ trả thú cưng'
                };
            }
            
            // Validate loại phòng
            if (!roomType) {
                return {
                    isValid: false,
                    message: '❌ Vui lòng chọn loại phòng lưu trú'
                };
            }
            
            // Validate thú cưng
            if (!petSelect) {
                return {
                    isValid: false,
                    message: '❌ Vui lòng chọn thú cưng cần lưu trú'
                };
            }
            
            // Validate thông tin thú cưng
            if (!petInfo || petInfo.trim().length < 10) {
                return {
                    isValid: false,
                    message: '❌ Vui lòng nhập đầy đủ thông tin thú cưng (ít nhất 10 ký tự)'
                };
            }
            
            // Validate liên hệ khẩn cấp
            if (!emergencyContact || emergencyContact.trim().length < 2) {
                return {
                    isValid: false,
                    message: '❌ Vui lòng nhập tên người liên hệ khẩn cấp'
                };
            }
            
            // Validate số điện thoại khẩn cấp 1 (bắt buộc)
            if (!emergencyPhone1 || emergencyPhone1.trim().length < 10) {
                return {
                    isValid: false,
                    message: '❌ Vui lòng nhập số điện thoại liên hệ khẩn cấp (ít nhất 10 số)'
                };
            }
            
            // Validate số điện thoại 1 (chỉ chứa số)
            const phoneRegex = /^[0-9]+$/;
            if (!phoneRegex.test(emergencyPhone1)) {
                return {
                    isValid: false,
                    message: '❌ Số điện thoại liên hệ khẩn cấp chỉ được chứa số (0-9)'
                };
            }
            
            // Validate số điện thoại 2 (nếu có)
            if (emergencyPhone2 && emergencyPhone2.trim() !== '') {
                if (emergencyPhone2.trim().length < 10) {
                    return {
                        isValid: false,
                        message: '❌ Số điện thoại liên hệ khẩn cấp 2 phải có ít nhất 10 số'
                    };
                }
                if (!phoneRegex.test(emergencyPhone2)) {
                    return {
                        isValid: false,
                        message: '❌ Số điện thoại liên hệ khẩn cấp 2 chỉ được chứa số (0-9)'
                    };
                }
            }
            
            // Validate ngày trả phải sau hoặc bằng ngày nhận
            const checkInDateObj = new Date(checkInDate);
            const checkOutDateObj = new Date(checkOutDate);
            
            if (checkOutDateObj < checkInDateObj) {
                return {
                    isValid: false,
                    message: '❌ Ngày trả phải sau hoặc bằng ngày nhận'
                };
            }
            
            // Validate giờ trả phải sau giờ nhận (nếu cùng ngày)
            if (checkInDate === checkOutDate) {
                const checkInTime = parseInt(checkInHour) * 60 + parseInt(checkInMinute);
                const checkOutTime = parseInt(checkOutHour) * 60 + parseInt(checkOutMinute);
                
                if (checkOutTime <= checkInTime) {
                    return {
                        isValid: false,
                        message: '❌ Giờ trả phải sau giờ nhận (cùng ngày)'
                    };
                }
            }
            
            // Validate thời gian tối thiểu (ít nhất 30 phút)
            const checkInDateTime = new Date(checkInDate + ' ' + checkInHour + ':' + checkInMinute);
            const checkOutDateTime = new Date(checkOutDate + ' ' + checkOutHour + ':' + checkOutMinute);
            const timeDiff = (checkOutDateTime - checkInDateTime) / (1000 * 60); // phút
            
            if (timeDiff < 30) {
                return {
                    isValid: false,
                    message: '❌ Thời gian lưu trú tối thiểu là 30 phút'
                };
            }
            
            // Tất cả validation đều pass
            return {
                isValid: true,
                message: '✅ Tất cả thông tin đã được điền đầy đủ'
            };
        }
    </script>
</body>
</html>
