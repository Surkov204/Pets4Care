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
            if (item != null && item.getProduct() != null) {
                cartCount += item.getQuantity();
                cartTotal += item.getQuantity() * item.getProduct().getPrice();
            }
        }
    }
%>

<c:set var="tieuDe" value="${[
                             'Cách tắm cho mèo không bị cào',
                             'Dạy chó đi vệ sinh đúng chỗ',
                             'Tự làm đồ chơi từ vật dụng cũ',
                             'Cách cắt móng cho mèo an toàn',
                             'Xử lý khi thú cưng bỏ ăn',
                             'Chăm sóc lông cho chó mèo mùa hè'
                             ]}" />

<c:set var="moTa" value="${[
                           'Mẹo tắm cho mèo tại nhà mà không bị cào cấu – áp dụng cho cả mèo hoang lẫn mèo nhà.',
                           'Hướng dẫn huấn luyện chó đi vệ sinh đúng nơi trong thời gian ngắn.',
                           'Tái chế đồ cũ thành đồ chơi thú vị cho thú cưng, tiết kiệm & sáng tạo.',
                           'Hướng dẫn từng bước cắt móng cho mèo mà không làm mèo hoảng sợ.',
                           'Các bước xử lý khi thú cưng có biểu hiện bỏ ăn, mệt mỏi hoặc stress.',
                           'Làm sao để chó mèo thoải mái, mượt lông và không sốc nhiệt mùa hè.'
                           ]}" />

<c:set var="link" value="${[
                           'https://ipetshop.vn/lam-sao-de-tam-cho-meo-ma-khong-bi-cao',
                           'https://www.bachhoaxanh.com/kinh-nghiem-hay/3-cach-day-cho-di-ve-sinh-dung-cho-1342975',
                           'https://paddy.vn/blogs/cham-soc-thu-cung/cach-lam-do-choi-cho-cho-don-gian-va-de-dang?srsltid=AfmBOoqKU3wjpvrd15_lMQcy5m1yMLRG9TrGoe0greJPgy-qxOvPZ1Y7',
                           'https://vcpetshop.com/cach-cat-mong-cho-meo/',
                           'https://pethealth.vn/blogs/kien-thuc/meo-bo-an',
                           'https://catcity.vn/p/tips-giu-cho-thu-cung-nha-ban-luon-thoai-mai-trong-mua-he'
                           ]}" />

<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <title>Mẹo Vặt - Petcity</title>
        <script src="https://cdn.tailwindcss.com"></script>
        <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.3/css/all.min.css" rel="stylesheet" />
        <link rel="stylesheet" href="css/homeStyle.css" />
    </head>
    <body class="bg-gray-50">
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
            <a href="<%= request.getContextPath()%>/home" class="logo">
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
                    <a href="<%= request.getContextPath()%>/cart/cart.jsp"><i class="fas fa-shopping-cart"></i> Giỏ hàng / <span class="cart-amount"><%= String.format("%.2f", cartTotal)%></span>₫</a>
                    <span class="cart-count"><%= cartCount%></span>
                </div>
            </div>
        </header>

        <nav>
            <ul>
                <li><a href="<%= request.getContextPath()%>/home">TRANG CHỦ</a></li>
                <li><a href="gioi-thieu.jsp">GIỚI THIỆU</a></li>
                <li><a href="search?categoryId=1">ĐẶT LỊCH KHÁM</a></li>
                <li><a href="search?categoryId=2">HỒ SƠ BÁC SĨ</a></li>
                <li><a href="search?categoryId=3">DỊCH VỤ SPA</a></li>
                <li><a href="tin-tuc.jsp">TIN TỨC</a></li>
                <li><a href="meo-vat.jsp">MẸO VẶT</a></li>
                <li><a href="lien-he.jsp">LIÊN HỆ</a></li>
            </ul>
        </nav>

        <main class="main-content px-6 py-10 bg-white rounded shadow mt-4 max-w-6xl mx-auto space-y-20">
            <section>
                <h2 class="text-4xl font-bold mb-10 text-center text-orange-600 animate-bounce">💡 Mẹo Vặt Nuôi Thú Cưng</h2>
                <div class="grid md:grid-cols-3 gap-10">
                    <c:forEach var="i" begin="0" end="5">
                        <div class="bg-white rounded shadow hover:shadow-xl transition duration-300 transform hover:-translate-y-1">
                            <img src="images/meovat${i + 1}.jpg" class="w-full h-52 object-cover rounded-t" alt="${tieuDe[i]}">
                            <div class="p-5">
                                <h3 class="text-xl font-semibold text-gray-800 mb-2">${tieuDe[i]}</h3>
                                <p class="text-gray-600 text-sm leading-relaxed">${moTa[i]}</p>
                                <a href="${link[i]}" target="_blank" class="text-orange-500 text-sm mt-2 inline-block hover:underline">Xem chi tiết</a>
                            </div>
                        </div>
                    </c:forEach>
                </div>
            </section>
        </main>

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
            document.addEventListener("DOMContentLoaded", function () {
                const btn = document.getElementById("userToggleBtn");
                const menu = document.getElementById("userMenu");

                btn.addEventListener("click", function (e) {
                    e.stopPropagation();
                    menu.classList.toggle("hidden");
                });

                document.addEventListener("click", function (e) {
                    if (!menu.contains(e.target) && e.target !== btn) {
                        menu.classList.add("hidden");
                    }
                });
            });
        </script>

    </body>
</html>
