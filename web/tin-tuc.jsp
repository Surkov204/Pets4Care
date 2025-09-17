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

<c:set var="tieuDe" value="${['Chó cưng được tập gym',
                             'Thú cưng AI được ưa chuộng ở Trung Quốc',
                             'Thành phố có số thú cưng nhiều hơn trẻ em',
                             'Bị kiện vì nịnh mèo hàng xóm bằng đồ ăn',
                             'Kiện bác sĩ thú y nhổ răng làm chết cún cưng',
                             'Nhiều người tiêm phòng dại khi chưa bị chó cắn']}" />

<c:set var="moTa" value="${[
    'Gogogym ở Thượng Hải gây sốt bởi dịch vụ tập gym cho thú cưng với hồ bơi, máy chạy bộ và huấn luyện viên chuyên nghiệp giúp vật nuôi nâng cao thể lực.',
    'Thú cưng AI không phải cho ăn, chỉ cần sạc pin nhưng có thể giúp bạn trẻ bớt cô đơn, hỗ trợ người già qua đường, chăm sóc sức khỏe... nên được ưa chuộng ở Trung Quốc. ',
    'Thống kê chính phủ cho thấy hiện tại thủ đô Buenos Aires có hơn 493.600 chó cưng, trong khi số trẻ em dưới 14 tuổi chỉ khoảng 460.600. ',
    'Bà lão 68 tuổi bị hàng xóm kiện vì thường xuyên cho mèo cưng của họ ăn khiến nó quấn bà hơn chủ nhân và sang ở hẳn đó không về',
    'Chủ của chú chó Coco cáo buộc bác sĩ thú y nhổ liền 16 chiếc răng của nó và không đưa đi cấp cứu khi bị ngừng tim, kiện đòi bồi thường 4,6 triệu USD.',
    'Huỳnh Minh Chước, 27 tuổi, Bình Thuận, đưa vợ và con trai đi tiêm phòng dại sau khi chó của gia đình nuôi chết để yên tâm.'
]}" />

<c:set var="link" value="${[
  'https://vnexpress.net/cho-cung-duoc-tap-gym-4896847.html',
  'https://vnexpress.net/thu-cung-ai-duoc-ua-chuong-o-trung-quoc-4893247.html',
  'https://vnexpress.net/thanh-pho-co-so-thu-cung-nhieu-hon-tre-em-4891133.html',
  'https://vnexpress.net/bi-kien-vi-ninh-meo-hang-xom-bang-do-an-4885986.html',
  'https://vnexpress.net/kien-bac-si-thu-y-nho-lien-16-rang-khien-cun-cung-chet-4885524.html',
  'https://vnexpress.net/nhieu-nguoi-tiem-phong-dai-khi-chua-bi-cho-can-4885499.html'
]}" />

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Tin tức - Petcity</title>
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

<main class="main-content px-6 py-10 bg-white rounded shadow mt-4 max-w-6xl mx-auto space-y-20">
    <section>
        <h2 class="text-4xl font-bold mb-10 text-center text-orange-600 animate-bounce">📰 Tin Tức Mới Nhất</h2>
        <div class="grid md:grid-cols-3 gap-10">
            <c:forEach var="i" begin="0" end="5">
                <div class="bg-white rounded shadow hover:shadow-xl transition duration-300 transform hover:-translate-y-1">
                    <img src="images/petnews${i + 1}.jpg" class="w-full h-52 object-cover rounded-t" alt="${tieuDe[i]}">
                    <div class="p-5">
                        <h3 class="text-xl font-semibold text-gray-800 mb-2">${tieuDe[i]}</h3>
                        <p class="text-gray-600 text-sm leading-relaxed">${moTa[i]}</p>
                        <a href="${link[i]}" target="_blank" class="text-blue-500 text-sm mt-2 inline-block hover:underline">Đọc thêm</a>
                    </div>
                </div>
            </c:forEach>
        </div>
    </section>

    <section class="text-center py-10 bg-orange-50 rounded-xl shadow-md">
        <h3 class="text-2xl font-bold text-orange-600 mb-6">🌟 Câu chuyện thú cưng nổi bật</h3>
        <p class="max-w-2xl mx-auto text-gray-700 leading-loose">Chúng tôi sẽ chia sẻ các câu chuyện cảm động, hài hước và truyền cảm hứng về thú cưng được cộng đồng yêu thích. Cùng lan toả năng lượng tích cực đến mọi nhà.</p>
        <video controls class="mx-auto rounded-lg shadow-md w-96">
            <source src="images/video.mp4" type="video/mp4">
        </video>

    </section>

    <section class="py-12">
        <h3 class="text-2xl font-bold text-center text-orange-600 mb-6">📣 Chia sẻ từ khách hàng</h3>
        <div class="grid md:grid-cols-2 gap-8">
            <div class="bg-white border-l-4 border-orange-500 p-6 rounded shadow">
                <p class="italic text-gray-700">“Petcity thật sự là nơi lý tưởng để chăm sóc thú cưng của tôi. Đội ngũ tận tâm, sản phẩm đa dạng và dịch vụ tuyệt vời.”</p>
                <p class="text-sm text-right text-gray-500 mt-2">- Minh Anh, Hà Nội</p>
            </div>
            <div class="bg-white border-l-4 border-orange-500 p-6 rounded shadow">
                <p class="italic text-gray-700">“Tôi rất thích những bài viết chia sẻ về cách nuôi dạy chó mèo, rất hữu ích và dễ áp dụng.”</p>
                <p class="text-sm text-right text-gray-500 mt-2">- Tuấn, TP.HCM</p>
            </div>
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

<jsp:include page="chatbox.jsp"/>
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
