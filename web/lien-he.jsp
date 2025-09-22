<%@page import="model.Customer"%>
<%@page import="model.CartItem"%>
<%@page import="java.util.Map"%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
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
    <title>Liên hệ - Petcity</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.3/css/all.min.css" rel="stylesheet" />
    <link rel="stylesheet" href="css/homeStyle.css" />
</head>
<body class="bg-gray-50">

<!-- Header -->
<div class="top-bar">
    <div class="left">🐾 PETCITY - SIÊU THỊ THÚ CƯNG ONLINE 🐾</div>
    <div class="right">
        <div>CẦN LÀ CÓ - MÒ LÀ THẤY</div>
        <a href="#"><i class="fab fa-facebook-f"></i></a>
        <a href="#"><i class="fab fa-instagram"></i></a>
        <a href="#"><i class="fab fa-twitter"></i></a>
        <a href="#"><i class="fas fa-envelope"></i></a>
    </div>
</div>

<header class="header-bar">
    <a href="<%= request.getContextPath() %>/home" class="logo">
        <img src="https://storage.googleapis.com/a1aa/image/15870274-75b6-4029-e89c-1424dc010c18.jpg" width="60" height="60" alt="Logo Petcity" />
        <div>
            <div class="logo-text">petcity</div>
            <div class="logo-subtext">thành phố thú cưng</div>
        </div>
    </a>
    <form class="search-form" method="get" action="search">
        <input type="text" name="keyword" placeholder="Tìm kiếm..." required>
        <button type="submit"><i class="fas fa-search"></i></button>
    </form>
    <div class="contact-info">
        <div><i class="far fa-clock"></i> 08:00 - 17:00</div>
        <div>
            <% if (currentUser == null) { %>
                <a href="login.jsp" class="text-sm text-blue-600 hover:underline">Đăng Ký | Đăng Nhập</a>
            <% } else { %>
                <div class="relative inline-block text-left">
                    <button type="button" id="userToggleBtn"
                        class="inline-flex justify-center w-full rounded-md border border-gray-300 shadow-sm px-3 py-1 bg-white text-sm font-medium text-gray-700 hover:bg-gray-50">
                        👤 Xin chào, <b><%= currentUser.getName() %></b>
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
            <a href="<%= request.getContextPath() %>/cart/cart.jsp"><i class="fas fa-shopping-cart"></i> Giỏ hàng / <span class="cart-amount"><%= String.format("%.2f", cartTotal) %></span>₫</a>
            <span class="cart-count"><%= cartCount %></span>
        </div>
    </div>
</header>

<nav>
    <ul>
        <li><a href="<%= request.getContextPath() %>/home">TRANG CHỦ</a></li>
        <li><a href="gioi-thieu.jsp">GIỚI THIỆU</a></li>
        <li><a href="search?categoryId=1">SHOP CÚN CƯNG</a></li>
        <li><a href="search?categoryId=2">SHOP MÈO CƯNG</a></li>
        <li><a href="search?categoryId=3">SHOP VẬT NUÔI KHÁC</a></li>
        <li><a href="tin-tuc.jsp">TIN TỨC</a></li>
        <li><a href="meo-vat.jsp">MẸO VẶT</a></li>
        <li><a href="lien-he.jsp">LIÊN HỆ</a></li>
    </ul>
</nav>

<main class="max-w-6xl mx-auto mt-10 px-6 space-y-20">

    <!-- 👥 Nhóm thực hiện -->
    <section class="text-center">
        <h2 class="text-3xl font-bold text-orange-600 mb-10">👨‍💻 Nhóm Thực Hiện</h2>
        <div class="grid grid-cols-1 md:grid-cols-3 gap-10">
            <div>
                <img src="images/member1.jpg" class="w-56 h-56 object-cover object-center mx-auto rounded-full shadow" alt="Nguyễn Minh Tuấn">
                <h3 class="mt-4 text-xl font-semibold text-gray-800">Nguyễn Minh Tuấn</h3>
                <p class="text-gray-600">Trưởng nhóm - Thiết kế hệ thống</p>
            </div>
            <div>
                <img src="images/member2.jpg" class="w-56 h-56 object-cover object-center mx-auto rounded-full shadow" alt="Lê Vĩnh Tiến">
                <h3 class="mt-4 text-xl font-semibold text-gray-800">Lê Vĩnh Tiến</h3>
                <p class="text-gray-600">Backend & Cơ sở dữ liệu</p>
            </div>
            <div>
                <img src="images/member3.jpg" class="w-56 h-56 object-cover object-center mx-auto rounded-full shadow" alt="Trần Hồng Sơn">
                <h3 class="mt-4 text-xl font-semibold text-gray-800">Trần Hồng Sơn</h3>
                <p class="text-gray-600">Giao diện & Frontend</p>
            </div>
        </div>
    </section>

    <!-- 📬 Liên hệ -->
    <section>
        <h2 class="text-3xl font-bold text-orange-600 mb-6 text-center">📬 Gửi tin nhắn liên hệ</h2>
        <div class="grid md:grid-cols-2 gap-10">
            <form action="mailto:deptrailaphaitheok12321@gmail.com" method="post" enctype="text/plain" class="space-y-4">
                <input type="text" name="name" placeholder="Họ và tên" required class="w-full p-3 border rounded">
                <input type="email" name="email" placeholder="Email" required class="w-full p-3 border rounded">
                <textarea name="message" rows="6" placeholder="Nội dung liên hệ..." required class="w-full p-3 border rounded"></textarea>
                <button type="submit" class="bg-orange-500 hover:bg-orange-600 text-white px-5 py-2 rounded">
                    Gửi liên hệ
                </button>
            </form>

            <div>
                <h4 class="text-lg font-semibold text-gray-700 mb-2">📍 Địa chỉ nhóm</h4>
                <p>Trường Đại học FPT Đà Nẵng</p>
                <p>Email: <a href="mailto:petcity@example.com" class="text-blue-500 underline">vinhhtien110@gmail.com</a></p>
                <p>Điện thoại: 091 613 4642</p>
            </div>
        </div>
    </section>

    <!-- 🗺️ Google Map -->
    <section>
        <h2 class="text-2xl font-bold text-orange-600 mb-4 text-center">🗺️ Bản đồ (Google Maps)</h2>
        <div class="rounded overflow-hidden shadow-lg">
            <iframe
                class="w-full h-96"
                src="https://www.google.com/maps/embed?pb=!1m18!1m12!1m3!1d3471.2499585610826!2d108.25831637459808!3d15.968891042117235!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x3142116949840599%3A0x365b35580f52e8d5!2sFPT%20University%20Danang!5e1!3m2!1sen!2s!4v1752143131746!5m2!1sen!2s"
                style="border:0;" allowfullscreen="" loading="lazy"
                referrerpolicy="no-referrer-when-downgrade">
            </iframe>
        </div>
    </section>

</main>

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
<script>
    document.addEventListener("DOMContentLoaded", function() {
        const btn = document.getElementById("userToggleBtn");
        const menu = document.getElementById("userMenu");

        btn.addEventListener("click", function(e) {
            e.stopPropagation();
            menu.classList.toggle("hidden");
        });

        document.addEventListener("click", function(e) {
            if (!menu.contains(e.target) && e.target !== btn) {
                menu.classList.add("hidden");
            }
        });
    });
</script>

</body>
</html>
