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
        <link rel="stylesheet" href="css/homeStyle.css" />
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

            /* Responsive fallback (optional) */
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
                <div>
                    <% if (currentUser == null) { %>
                    <a href="login.jsp" class="text-sm hover:underline">👤 Đăng Ký | Đăng Nhập</a>
                    <% } else {%>
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
                    <% }%>
                </div>
                <div class="cart-fixed">
                    <a href="<%= request.getContextPath()%>/cart/cart.jsp">
                        <i class="fas fa-shopping-cart"></i>
                        Giỏ hàng /
                        <span class="cart-amount"><%= String.format("%.2f", cartTotal)%></span>₫
                    </a>
                </div>

            </div>
        </header>

                    <style>
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
    color: #f97316; /* Cam pastel */
  }

  /* Responsive nhỏ hơn */
  @media (max-width: 768px) {
    .cart-fixed {
      top: unset;
      bottom: 20px;
      right: 10px;
      padding: 10px 12px;
    }
  }
</style>


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

            <!-- Hero Text -->
            <div class="hero-text flex-1">
                <h1 class="text-3xl font-bold mb-2">🌟 Thế giới đồ chơi & phụ kiện cho thú cưng 🌟</h1>
                <p class="mb-4 text-gray-700">Mang lại niềm vui và hạnh phúc cho những người bạn bốn chân yêu quý của bạn</p>
                <button class="hero-cta bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded"
                        onclick="document.querySelector('.featured-categories').scrollIntoView({behavior: 'smooth'})">
                    🎾 Khám phá ngay
                </button>
            </div>

            <!-- Slideshow -->
            <div class="slideshow">
                <div class="slide active">
                    <img src="images/slide_4.jpg" alt="Slide 1">
                </div>
                <div class="slide">
                    <img src="images/slide_2.jpg" alt="Slide 2">
                </div>
                <div class="slide">
                    <img src="images/slide_3.jpg" alt="Slide 3">
                </div>
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
                    <div class="category-card" onclick="location.href = 'search?categoryId=4'">
                        <div class="category-icon">🍖</div>
                        <h3>Thức ăn</h3>
                        <p>Dinh dưỡng tốt nhất cho thú cưng</p>
                    </div>
                    <div class="category-card" onclick="location.href = 'search?categoryId=1'">
                        <div class="category-icon">🎾</div>
                        <h3>Đồ chơi</h3>
                        <p>Giải trí và rèn luyện trí tuệ</p>
                    </div>
                    <div class="category-card" onclick="location.href = 'search?categoryId=11'">
                        <div class="category-icon">👕</div>
                        <h3>Phụ kiện</h3>
                        <p>Thời trang và tiện ích</p>
                    </div>
                    <div class="category-card" onclick="location.href = 'search?categoryId=6'">
                        <div class="category-icon">🏠</div>
                        <h3>Chuồng & Nhà</h3>
                        <p>Không gian sống thoải mái</p>
                    </div>
                    <div class="category-card" onclick="location.href = 'search?categoryId=9'">
                        <div class="category-icon">💊</div>
                        <h3>Sức khỏe</h3>
                        <p>Chăm sóc và bảo vệ sức khỏe</p>
                    </div>
                    <div class="category-card" onclick="location.href = 'search?categoryId=8'">
                        <div class="category-icon">💎</div>
                        <h3>Trang sức</h3>
                        <p>Làm đẹp cho thú cưng</p>
                    </div>
                </div>
            </div>
        </section>

        <!-- Main Content -->
        <div class="content-wrapper">
            <aside class="sidebar">
                <div class="category">
                    <h3>🐕 Shop cún cưng</h3>
                    <ul>
                        <li><a href="search?categoryId=4">Thức ăn cho chó</a></li>
                        <li><a href="search?categoryId=11">Áo Quần cho chó</a></li>
                        <li><a href="search?categoryId=6">Chuồng cho chó</a></li>
                        <li><a href="search?categoryId=9">Thuốc cho chó</a></li>
                    </ul>
                </div>

                <img src="https://storage.googleapis.com/a1aa/image/570e3849-419a-4b12-9d59-9826de293e13.jpg" alt="pet shop image" />

                <div class="category">
                    <h3>🐱 Shop mèo cưng</h3>
                    <ul>
                        <li><a href="search?categoryId=5">Thức ăn cho mèo</a></li>
                        <li><a href="search?categoryId=12">Áo Quần cho mèo</a></li>
                        <li><a href="search?categoryId=7">Chuồng cho mèo</a></li>
                        <li><a href="search?categoryId=10">Thuốc cho mèo</a></li>
                    </ul>
                </div>

                <div class="category">
                    <h3>✨ Phụ Kiện Khác</h3>
                    <ul>
                        <li><a href="search?categoryId=8">Trang sức</a></li>
                    </ul>
                </div>
            </aside>

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

                                <c:choose>
                                    <c:when test="${toy.stockQuantity == 0}">
                                        <span class="bg-red-100 text-red-700 text-sm font-bold px-3 py-1 rounded-full border border-red-400 inline-block animate-pulse">
                                            ❌ HẾT HÀNG
                                        </span>
                                    </c:when>

                                    <c:otherwise>
                                        <button class="btn-add-cart" onclick="addToCart(this, ${toy.toyId}, ${toy.price})">
                                            Thêm vào giỏ
                                        </button>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </c:forEach>
                    </div>

                    <div class="pagination">
                        <c:forEach begin="1" end="${totalPages}" var="i">
                            <a href="home?page=${i}" class="${i == currentPage ? 'active' : ''}">
                                ${i}
                            </a>
                        </c:forEach>
                    </div>
                </section>
            </main>
        </div>

        <!-- Customer Reviews -->
        <section class="customer-reviews">
            <div class="container">
                <h2>💝 Khách hàng nói gì về chúng tôi</h2>
                <div class="reviews-grid">
                    <div class="review-card">
                        <div class="review-avatar">🐕</div>
                        <div class="review-content">
                            <div class="review-stars">⭐⭐⭐⭐⭐</div>
                            <p>"Sản phẩm chất lượng tuyệt vời! Chó nhà mình rất thích những món đồ chơi từ Petcity."</p>
                            <div class="review-author">- Minh Anh, Hà Nội</div>
                        </div>
                    </div>
                    <div class="review-card">
                        <div class="review-avatar">🐱</div>
                        <div class="review-content">
                            <div class="review-stars">⭐⭐⭐⭐⭐</div>
                            <p>"Giao hàng nhanh, đóng gói cẩn thận. Mèo cưng của tôi rất hài lòng với những món quà mới."</p>
                            <div class="review-author">- Thu Hà, TP.HCM</div>
                        </div>
                    </div>
                    <div class="review-card">
                        <div class="review-avatar">🐹</div>
                        <div class="review-content">
                            <div class="review-stars">⭐⭐⭐⭐⭐</div>
                            <p>"Dịch vụ tư vấn nhiệt tình, giúp tôi chọn được sản phẩm phù hợp nhất cho thú cưng."</p>
                            <div class="review-author">- Văn Nam, Đà Nẵng</div>
                        </div>
                    </div>
                </div>
            </div>
        </section>

        <!-- Footer -->
        <footer>
            <div class="footer-content">
                <div class="footer-section">
                    <h3>🏪 Thông tin liên hệ</h3>
                    <p>📍 Địa chỉ: Môn PRJ</p>
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
                <p>© 2025 Petcity. Bản quyền thuộc về Tiến. ❤️ Made with love for pets</p>
            </div>
        </footer>

        <!-- Toast Notification -->
        <div class="toast" id="toast"></div>

        <!-- Scripts -->
        <script>
            function addToCart(button, toyId, price) {
                console.log("Adding to cart - ToyID:", toyId, "Price:", price);

                const params = new URLSearchParams();
                params.append('action', 'add');
                params.append('id', toyId);
                params.append('quantity', '1');

                fetch("<%=request.getContextPath()%>/cartservlet", {
                    method: "POST",
                    headers: {
                        "Content-Type": "application/x-www-form-urlencoded"
                    },
                    body: params
                })
                        .then(response => {
                            console.log("Response status:", response.status);
                            if (!response.ok) {
                                throw new Error(`HTTP error! status: ${response.status}`);
                            }
                            return response.text();
                        })
                        .then(result => {
                            console.log("Server response:", result);
                            if (result.trim() === "success") {
                                showToast("🛒 Đã thêm vào giỏ hàng!");
                                updateCartCount();

                                // Add cute animation to button
                                button.style.transform = 'scale(0.95)';
                                setTimeout(() => {
                                    button.style.transform = 'scale(1)';
                                }, 150);
                            } else {
                                showToast("❌ " + result);
                            }
                        })
                        .catch(error => {
                            console.error("Error adding to cart:", error);
                            showToast("⚠️ Lỗi: " + error.message);
                        });
            }

            function updateCartCount() {
                fetch("<%=request.getContextPath()%>/cartservlet?action=count")
                        .then(response => response.text())
                        .then(count => {
                            document.querySelector(".cart-count").textContent = count;
                        });

                fetch("<%=request.getContextPath()%>/cartservlet?action=total")
                        .then(response => response.text())
                        .then(total => {
                            document.querySelector(".cart-amount").textContent = total + "₫";
                        });
            }

            function showToast(message) {
                const toast = document.getElementById("toast");
                toast.textContent = message;
                toast.style.display = "block";
                setTimeout(() => {
                    toast.style.display = "none";
                }, 3000);
            }

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

        <!-- Slideshow Script -->
        <script>
            let slideIndex = 0;
            const slides = document.querySelectorAll(".slide");
            showSlides();

            function showSlides() {
                slides.forEach((slide, i) => {
                    slide.classList.remove("active");
                });
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