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
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <title>🐾 Giới thiệu - Petcity</title>
        <script src="https://cdn.tailwindcss.com"></script>
        <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.3/css/all.min.css" rel="stylesheet" />
        <link href="https://fonts.googleapis.com/css2?family=Quicksand:wght@300;400;500;600;700&family=Nunito:wght@300;400;500;600;700;800&family=Baloo+2:wght@400;500;600;700;800&display=swap" rel="stylesheet" />
        <link rel="stylesheet" href="css/homeStyle.css" />
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
                <input type="text" name="keyword" placeholder="🔍 Tìm kiếm sản phẩm..." required>
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
                <li><a href="gioi-thieu.jsp" style="background: rgba(255, 255, 255, 0.2);">GIỚI THIỆU</a></li>
                <li><a href="search?categoryId=1">ĐẶT LỊCH KHÁM</a></li>
                <li><a href="search?categoryId=2">HỒ SƠ BÁC SĨ</a></li>
                <li><a href="search?categoryId=3">DỊCH VỤ SPA</a></li>
                <li><a href="tin-tuc.jsp">TIN TỨC</a></li>
                <li><a href="meo-vat.jsp">MẸO VẶT</a></li>
                <li><a href="lien-he.jsp">LIÊN HỆ</a></li>
            </ul>
        </nav>

        <!-- Main Content -->
        <main class="main-content px-6 py-10 bg-white rounded shadow mt-4 max-w-6xl mx-auto" style="margin: 2rem auto; background: var(--card-bg); border-radius: var(--border-radius); box-shadow: var(--shadow-light);">
            <h2 class="text-4xl font-bold mb-8 text-center animate-pulse" style="color: var(--primary); font-family: 'Baloo 2', cursive;">
                🌟 Chào mừng đến với Petcity! 🌟
            </h2>

            <div class="grid lg:grid-cols-2 gap-10 items-center">
                <img src="images/gt.jpg" class="rounded-xl shadow-xl w-full object-cover hover:scale-105 transition-transform duration-500" alt="Giới thiệu thú cưng" style="border-radius: var(--border-radius); box-shadow: var(--shadow-hover);"/>
                <div class="space-y-5 leading-relaxed" style="color: var(--text);">
                    <p><strong style="color: var(--primary);">Petcity</strong> là chuỗi siêu thị thú cưng hàng đầu tại Việt Nam, nơi bạn có thể tìm thấy mọi thứ cho thú cưng thân yêu của mình từ thức ăn, đồ chơi đến các dịch vụ chăm sóc hiện đại.</p>
                    <p>Chúng tôi hoạt động với sứ mệnh mang lại cuộc sống tốt đẹp hơn cho thú cưng và trải nghiệm tiện lợi cho người nuôi. Với sự tận tâm và chuyên nghiệp, Petcity là lựa chọn hàng đầu cho mọi người yêu động vật.</p>
                    <p>Từ năm 2020, chúng tôi đã phục vụ hơn <span style="color: var(--accent); font-weight: 700;">500.000 khách hàng</span> và không ngừng mở rộng trên toàn quốc. Sự hài lòng của bạn là động lực để chúng tôi phát triển mỗi ngày.</p>
                </div>
            </div>

            <div class="mt-16 grid md:grid-cols-3 gap-8 text-center">
                <div class="p-6 rounded-xl shadow hover:shadow-lg transition duration-300" style="background: var(--card-bg-alt); border-radius: var(--border-radius); box-shadow: var(--shadow-light);">
                    <i class="fas fa-dog text-5xl mb-4" style="color: var(--accent);"></i>
                    <h3 class="text-xl font-bold mb-2" style="color: var(--primary);">Sản phẩm chất lượng</h3>
                    <p style="color: var(--text);">Chúng tôi chỉ cung cấp sản phẩm an toàn và được kiểm định bởi chuyên gia thú y.</p>
                </div>
                <div class="p-6 rounded-xl shadow hover:shadow-lg transition duration-300" style="background: var(--card-bg-alt); border-radius: var(--border-radius); box-shadow: var(--shadow-light);">
                    <i class="fas fa-heart text-5xl mb-4" style="color: var(--accent-pink);"></i>
                    <h3 class="text-xl font-bold mb-2" style="color: var(--primary);">Yêu thương thú cưng</h3>
                    <p style="color: var(--text);">Đội ngũ của chúng tôi luôn đặt quyền lợi và cảm xúc của thú cưng lên hàng đầu.</p>
                </div>
                <div class="p-6 rounded-xl shadow hover:shadow-lg transition duration-300" style="background: var(--card-bg-alt); border-radius: var(--border-radius); box-shadow: var(--shadow-light);">
                    <i class="fas fa-shipping-fast text-5xl mb-4" style="color: var(--primary);"></i>
                    <h3 class="text-xl font-bold mb-2" style="color: var(--primary);">Giao hàng nhanh chóng</h3>
                    <p style="color: var(--text);">Hệ thống giao hàng toàn quốc giúp bạn nhận hàng trong thời gian sớm nhất.</p>
                </div>
            </div>

            <section class="text-center mt-20">
                <h3 class="text-2xl font-bold mb-4" style="color: var(--accent); font-family: 'Baloo 2', cursive;">🎯 Sứ mệnh của chúng tôi</h3>
                <p class="max-w-3xl mx-auto leading-loose" style="color: var(--text);">
                    Petcity không chỉ là nơi mua sắm, mà còn là ngôi nhà của hàng triệu thú cưng và chủ nuôi tại Việt Nam. Chúng tôi mong muốn xây dựng cộng đồng yêu thú cưng văn minh, nơi mà mỗi thú cưng đều được yêu thương, chăm sóc đầy đủ và hạnh phúc.
                </p>
            </section>
        </main>

        <!-- Include unified footer -->
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

        <div class="toast" id="toast"></div>
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