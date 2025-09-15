<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%
    // Tạm bỏ Customer và CartItem vì chưa có model/DAO
    int cartCount = 0;
    double cartTotal = 0;

    int currentPage = request.getAttribute("currentPage") != null ? (Integer) request.getAttribute("currentPage") : 1;
    int totalPages = request.getAttribute("totalPages") != null ? (Integer) request.getAttribute("totalPages") : 1;
%>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <title>Petcity - Thế giới đồ chơi & phụ kiện cho thú cưng</title>
        <script src="https://cdn.tailwindcss.com"></script>
        <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.3/css/all.min.css" rel="stylesheet" />
        <link href="https://fonts.googleapis.com/css2?family=Quicksand:wght@300;400;500;600;700&family=Nunito:wght@300;400;500;600;700;800&family=Baloo+2:wght@400;500;600;700;800&display=swap" rel="stylesheet" />
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/homeStyle.css">
        <style>
            .slideshow {
                position: relative;
                width: 800px;
                height: 400px;
                margin: 2rem auto;
                overflow: hidden;
                border-radius: 10px;
                box-shadow: 0 4px 12px rgba(0,0,0,0.1);
            }
            .slide {
                display: none;
                width: 100%;
                height: 100%;
            }
            .slide.active {
                display: block;
            }
            .slide img {
                width: 100%;
                height: 100%;
                object-fit: cover;
            }
            .slideshow-controls {
                position: absolute;
                top: 50%;
                width: 100%;
                display: flex;
                justify-content: space-between;
                transform: translateY(-50%);
                padding: 0 1rem;
            }
            .slideshow-controls button {
                background: rgba(0, 0, 0, 0.5);
                color: white;
                border: none;
                padding: 10px 15px;
                font-size: 18px;
                border-radius: 50%;
                cursor: pointer;
                transition: background 0.3s ease;
            }
            .slideshow-controls button:hover {
                background: rgba(0, 0, 0, 0.7);
            }
            @media (max-width: 850px) {
                .slideshow {
                    width: 100%;
                    height: auto;
                }
                .slide img {
                    height: auto;
                    max-height: 400px;
                }
            }
            .cart-fixed {
                position: fixed;
                top: 20px;
                right: 20px;
                background-color: #fff;
                padding: 8px 14px;
                border-radius: 8px;
                box-shadow: 0 2px 6px rgba(0,0,0,0.2);
                z-index: 1000;
                font-weight: 600;
                color: #333;
            }
            .cart-fixed a {
                text-decoration: none;
                color: inherit;
                display: flex;
                align-items: center;
                gap: 6px;
            }
            .cart-fixed i {
                color: #f97316;
            }
            @media (max-width: 768px) {
                .cart-fixed {
                    top: unset;
                    bottom: 20px;
                    right: 10px;
                    padding: 10px 12px;
                }
            }
        </style>
    </head>
    <body>
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
                <img src="https://storage.googleapis.com/a1aa/image/15870274-75b6-4029-e89c-1424dc010c18.jpg" alt="Logo Petcity" />
                <div>
                    <div class="logo-text">petcity</div>
                    <div class="logo-subtext">thành phố thú cưng</div>
                </div>
            </a>

            <form class="search-form relative" method="get" action="search" autocomplete="off">
                <input type="text" id="searchInput" name="keyword" placeholder="🔍 Tìm kiếm sản phẩm..." value="${keyword}" required>
                <button type="submit"><i class="fas fa-search"></i></button>
            </form>

            <div class="contact-info">
                <div><i class="far fa-clock"></i> 08:00 - 17:00</div>
                <!-- Luôn hiển thị nút login (tạm chưa có currentUser) -->
                <div><a href="login.jsp" class="text-sm hover:underline">👤 Đăng Ký | Đăng Nhập</a></div>
                <!-- Giỏ hàng fix tạm -->
                <div class="cart-fixed">
                    <a href="#">
                        <i class="fas fa-shopping-cart"></i>
                        Giỏ hàng / <span class="cart-amount">0</span>₫
                    </a>
                </div>
            </div>
        </header>

        <!-- Navigation -->
        <nav>
            <ul>
                <li><a href="<%= request.getContextPath()%>/home">TRANG CHỦ</a></li>
                <li><a href="gioi-thieu.jsp">GIỚI THIỆU</a></li>
                <li><a href="search?categoryId=1">SHOP CÚN CƯNG</a></li>
                <li><a href="search?categoryId=2">SHOP MÈO CƯNG</a></li>
                <li><a href="search?categoryId=3">SHOP VẬT NUÔI KHÁC</a></li>
                <li><a href="tin-tuc.jsp">TIN TỨC</a></li>
                <li><a href="meo-vat.jsp">MẸO VẶT</a></li>
                <li><a href="lien-he.jsp">LIÊN HỆ</a></li>
            </ul>
        </nav>

        <!-- Hero Banner + Slideshow -->
        <section class="hero-banner flex flex-col lg:flex-row items-center justify-between gap-6 px-4 py-6">
            <div class="hero-text flex-1">
                <h1 class="text-3xl font-bold mb-2">🌟 Thế giới đồ chơi & phụ kiện cho thú cưng 🌟</h1>
                <p class="mb-4 text-gray-700">Mang lại niềm vui và hạnh phúc cho những người bạn bốn chân yêu quý của bạn</p>
                <button class="hero-cta bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded"
                        onclick="document.querySelector('.featured-categories').scrollIntoView({behavior: 'smooth'})">
                    🎾 Khám phá ngay
                </button>
            </div>
            <div class="slideshow">
                <div class="slide active"><img src="images/slide_4.jpg" alt="Slide 1"></div>
                <div class="slide"><img src="images/slide_2.jpg" alt="Slide 2"></div>
                <div class="slide"><img src="images/slide_3.jpg" alt="Slide 3"></div>
                <div class="slideshow-controls">
                    <button onclick="plusSlides(-1)">&#10094;</button>
                    <button onclick="plusSlides(1)">&#10095;</button>
                </div>
            </div>
        </section>

        <!-- Featured Categories -->
        <section class="featured-categories">
            <div class="container">
                <h2>🎯 Danh mục nổi bật</h2>
                <div class="categories-grid">
                    <div class="category-card" onclick="location.href = 'search?categoryId=4'"><div class="category-icon">🍖</div><h3>Thức ăn</h3></div>
                    <div class="category-card" onclick="location.href = 'search?categoryId=1'"><div class="category-icon">🎾</div><h3>Đồ chơi</h3></div>
                    <div class="category-card" onclick="location.href = 'search?categoryId=11'"><div class="category-icon">👕</div><h3>Phụ kiện</h3></div>
                    <div class="category-card" onclick="location.href = 'search?categoryId=6'"><div class="category-icon">🏠</div><h3>Chuồng & Nhà</h3></div>
                    <div class="category-card" onclick="location.href = 'search?categoryId=9'"><div class="category-icon">💊</div><h3>Sức khỏe</h3></div>
                    <div class="category-card" onclick="location.href = 'search?categoryId=8'"><div class="category-icon">💎</div><h3>Trang sức</h3></div>
                </div>
            </div>
        </section>

        <!-- Products -->
        <div class="content-wrapper">
            <main class="main-content">
                <section class="toys">
                    <h2>🌟 Sản phẩm nổi bật</h2>
                    <div class="toys-grid">
                        <c:forEach var="toy" items="${toys}">
                            <div class="toy-item">
                                <div class="toy-badge">✨ Mới</div>
                                <a href="<c:url value='/toydetailservlet'/>?id=${toy.toyId}">
                                    <img src="images/toy_${toy.toyId}.jpg" alt="${toy.name}" onerror="this.src='images/default.jpg'" />
                                    <p class="toy-name">${toy.name}</p>
                                </a>
                                <p class="toy-price">${toy.price}₫</p>
                                <p class="toy-stock">📦 Kho: ${toy.stockQuantity}</p>
                            </div>
                        </c:forEach>
                    </div>
                    <div class="pagination">
                        <c:forEach begin="1" end="${totalPages}" var="i">
                            <a href="home?page=${i}" class="${i == currentPage ? 'active' : ''}">${i}</a>
                        </c:forEach>
                    </div>
                </section>
            </main>
        </div>

        <!-- Footer -->
        <footer>
            <div class="footer-content">
                <div class="footer-section">
                    <h3>🏪 Thông tin liên hệ</h3>
                    <p>📍 Địa chỉ: Môn PRJ</p>
                    <p>📞 Điện thoại: 090 900 900</p>
                    <p>📧 Email: support@petcity.vn</p>
                </div>
            </div>
            <div class="footer-bottom">
                <p>© 2025 Petcity. Bản quyền thuộc về team. ❤️ Made with love for pets</p>
            </div>
        </footer>

        <!-- Slideshow Script -->
        <script>
            let slideIndex = 0;
            const slides = document.querySelectorAll(".slide");
            showSlides();
            function showSlides() {
                slides.forEach(slide => slide.classList.remove("active"));
                slideIndex = (slideIndex + 1) % slides.length;
                slides[slideIndex].classList.add("active");
                setTimeout(showSlides, 5000);
            }
            function plusSlides(n) {
                slideIndex = (slideIndex + n + slides.length) % slides.length;
                slides.forEach(slide => slide.classList.remove("active"));
                slides[slideIndex].classList.add("active");
            }
        </script>

        <jsp:include page="chatbox.jsp"/>
    </body>
</html>
