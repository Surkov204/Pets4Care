<%@page import="model.Customer"%>
<%@page import="model.CartItem"%>
<%@page import="java.util.Map"%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%
    Customer currentUser = (Customer) session.getAttribute("currentUser");
    Map<Integer, CartItem> cart = (Map<Integer, CartItem>) session.getAttribute("cart");
    int cartCount = 0;
    double cartTotal = 0;
    if (cart != null) {
        for (CartItem item : cart.values()) {
            if (item != null && item.getToy() != null) {
                cartCount += item.getQuantity();
                cartTotal += item.getQuantity() * item.getToy().getPrice();
            }
        }
    }
%>

<c:set var="services" value="${[
    'Tắm & Gội đầu cho thú cưng',
    'Cắt tỉa lông chuyên nghiệp', 
    'Cắt móng chân an toàn',
    'Làm sạch tai & răng',
    'Massage thư giãn',
    'Spa cao cấp cho chó mèo',
    'Tắm thuốc trị ký sinh trùng',
    'Chăm sóc da & lông đặc biệt'
]}" />

<c:set var="descriptions" value="${[
    'Dịch vụ tắm gội chuyên nghiệp với dầu gội đặc biệt, giúp thú cưng sạch sẽ và thơm tho suốt ngày.',
    'Cắt tỉa lông theo phong cách hiện đại, tạo kiểu đẹp mắt và phù hợp với từng giống chó mèo.',
    'Cắt móng chân an toàn, không gây đau đớn, giúp thú cưng di chuyển thoải mái hơn.',
    'Làm sạch tai và răng chuyên nghiệp, ngăn ngừa các bệnh về tai và răng miệng.',
    'Massage thư giãn giúp thú cưng giảm stress, cải thiện tuần hoàn máu và tăng cường sức khỏe.',
    'Gói spa cao cấp bao gồm tắm, cắt tỉa, massage và chăm sóc toàn diện cho thú cưng.',
    'Tắm thuốc đặc trị các loại ký sinh trùng như bọ chét, ve, rận an toàn và hiệu quả.',
    'Chăm sóc da và lông đặc biệt cho thú cưng có vấn đề về da, giúp phục hồi và tái tạo.'
]}" />

<c:set var="prices" value="${[
    '150.000₫',
    '200.000₫', 
    '80.000₫',
    '120.000₫',
    '180.000₫',
    '350.000₫',
    '250.000₫',
    '300.000₫'
]}" />

<c:set var="durations" value="${[
    '45 phút',
    '60 phút',
    '30 phút', 
    '40 phút',
    '50 phút',
    '90 phút',
    '60 phút',
    '75 phút'
]}" />

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
        </div>
    </header>

    <!-- Navigation -->
    <nav>
        <ul>
            <li><a href="<%= request.getContextPath()%>/home">TRANG CHỦ</a></li>
            <li><a href="spa-service.jsp" style="background: rgba(255, 255, 255, 0.2);">DỊCH VỤ</a></li>
            <li><a href="dat-lich-kham.jsp">ĐẶT LỊCH KHÁM</a></li>
            <li><a href="search?categoryId=2">SẢN PHẨM</a></li>
            <li><a href="doctor.jsp">BÁC SĨ</a></li>
            <li><a href="gioi-thieu.jsp">GIỚI THIỆU</a></li>
            <li><a href="tin-tuc.jsp">TIN TỨC</a></li>
            <li><a href="lien-he.jsp">LIÊN HỆ</a></li>
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
            <div class="grid md:grid-cols-2 lg:grid-cols-3 gap-8">
                <c:forEach var="i" begin="0" end="7">
                    <div class="service-card bg-white">
                        <div class="p-6 text-center">
                            <div class="service-icon">
                                <c:choose>
                                    <c:when test="${i == 0}">🛁</c:when>
                                    <c:when test="${i == 1}">✂️</c:when>
                                    <c:when test="${i == 2}">💅</c:when>
                                    <c:when test="${i == 3}">🦷</c:when>
                                    <c:when test="${i == 4}">💆</c:when>
                                    <c:when test="${i == 5}">✨</c:when>
                                    <c:when test="${i == 6}">🧴</c:when>
                                    <c:when test="${i == 7}">🌿</c:when>
                                </c:choose>
                            </div>
                            <h3 class="text-xl font-bold text-gray-800 mb-3">${services[i]}</h3>
                            <p class="text-gray-600 mb-4 leading-relaxed">${descriptions[i]}</p>
                            <div class="flex justify-between items-center mb-4">
                                <span class="price-tag">${prices[i]}</span>
                                <span class="duration-badge">${durations[i]}</span>
                            </div>
                            <a href="#" class="booking-btn">📅 Đặt lịch ngay</a>
                        </div>
                    </div>
                </c:forEach>
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
    </script>
</body>
</html>
