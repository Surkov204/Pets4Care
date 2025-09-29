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
        <title>Kết quả tìm kiếm - Petcity</title>
        <script src="https://cdn.tailwindcss.com"></script>
        <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.3/css/all.min.css" rel="stylesheet" />
        <link href="https://fonts.googleapis.com/css2?family=Roboto&display=swap" rel="stylesheet" />
        <link rel="stylesheet" href="css/homeStyle.css" />
    </head>
    <body>
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
            <form class="search-form relative" method="get" action="search" autocomplete="off">
                <input type="text" id="searchInput" name="keyword" placeholder="Tìm kiếm..." value="${keyword}" required>
                <button type="submit"><i class="fas fa-search"></i></button>
                <!--<ul id="suggestionsList" class="absolute bg-white border w-full mt-1 z-50 hidden max-h-60 overflow-y-auto rounded shadow text-sm"></ul>-->
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

        <div class="content-wrapper">
            <aside class="sidebar">
                <div class="category">
                    <h3>Shop cún cưng</h3>
                    <ul>
                        <li><a href="search?categoryId=4">Thức ăn cho chó</a></li>
                        <li><a href="search?categoryId=11">Áo Quần cho chó</a></li>
                        <li><a href="search?categoryId=6">Chuồng cho chó</a></li>
                        <li><a href="search?categoryId=9">Thuốc cho chó</a></li>
                    </ul>
                </div>

                <img src="https://storage.googleapis.com/a1aa/image/570e3849-419a-4b12-9d59-9826de293e13.jpg" alt="pet shop image" style="max-width: 100%; border-radius: 8px; margin: 12px 0;" />

                <div class="category">
                    <h3>Shop mèo cưng</h3>
                    <ul>
                        <li><a href="search?categoryId=5">Thức ăn cho mèo</a></li>
                        <li><a href="search?categoryId=12">Áo Quần cho mèo</a></li>
                        <li><a href="search?categoryId=7">Chuồng cho mèo</a></li>
                        <li><a href="search?categoryId=10">Thuốc cho mèo</a></li>
                    </ul>
                </div>
                <div class="category">
                    <h3>Phụ Kiện Khác</h3>
                    <ul>
                        <li><a href="search?categoryId=8">Trang sức</a></li>
                    </ul>
                </div>
            </aside>


            <main class="main-content">
                <section class="toys">
                    <c:choose>
                        <c:when test="${not empty keyword}">
                            <h2>Kết quả tìm kiếm cho "<span class='text-blue-600'>${keyword}</span>"</h2>
                        </c:when>
                        <c:when test="${not empty categoryName}">
                            <h2>Sản phẩm theo danh mục: <span class='text-blue-600'>${categoryName}</span></h2>
                            </c:when>
                            <c:otherwise>
                            <h2>Tất cả sản phẩm</h2>
                        </c:otherwise>
                    </c:choose>

                    <c:choose>
                        <c:when test="${empty searchResults}">
                            <p>Không tìm thấy sản phẩm nào phù hợp.</p>
                        </c:when>
                        <c:otherwise>
                            <div class="toys-grid">
                                <c:forEach var="toy" items="${searchResults}">
                                    <div class="toy-item">
                                        <a href="toydetailservlet?id=${toy.toyId}">
                                            <img src="images/toy_${toy.toyId}.jpg" alt="${toy.name}" onerror="this.src='images/default.jpg'" />
                                            <p class="toy-name">${toy.name}</p>
                                        </a>
                                        <p class="toy-price">${toy.price}₫</p>
                                        <p class="toy-stock">Kho: ${toy.stockQuantity}</p>

                                        <c:choose>
                                            <c:when test="${toy.stockQuantity == 0}">
                                                <span class="bg-red-100 text-red-700 text-sm font-bold px-3 py-1 rounded-full border border-red-400 inline-block animate-pulse">
                                                    ❌ HẾT HÀNG
                                                </span>
                                            </c:when>

                                            <c:otherwise>
                                                <button class="btn-add-cart" onclick="addToCart(this, ${toy.toyId}, ${toy.price})">Thêm vào giỏ</button>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                                </c:forEach>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </section>
            </main>        </div>

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
                <p>© 2025 Petcity. Bản quyền thuộc về G5. ❤️ Made with love for pets</p>
            </div>
        </footer>

        <div class="toast" id="toast"></div>
        <script>
            function addToCart(button, toyId, price) {
                const params = new URLSearchParams();
                params.append('action', 'add');
                params.append('id', toyId);
                params.append('quantity', '1');

                fetch('<%= request.getContextPath()%>/cartservlet', {
                    method: "POST",
                    headers: {
                        "Content-Type": "application/x-www-form-urlencoded"
                    },
                    body: params
                })
                        .then(response => response.text())
                        .then(result => {
                            if (result.trim() === "success") {
                                showToast("🛒 Đã thêm vào giỏ hàng!");
                                updateCartCount();

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
        </script>
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
        <script>
            document.addEventListener("DOMContentLoaded", function () {
                const searchInput = document.getElementById("searchInput");
                const suggestionsList = document.getElementById("suggestionsList");

                searchInput.addEventListener("input", async function () {
                    const query = searchInput.value.trim();
                    if (query.length < 1) {
                        suggestionsList.classList.add("hidden");
                        return;
                    }

                    try {
                        const response = await fetch("search-suggest?q=" + encodeURIComponent(query));
                        const suggestions = await response.json();

                        suggestionsList.innerHTML = "";
                        if (suggestions.length === 0) {
                            suggestionsList.classList.add("hidden");
                            return;
                        }

                        suggestions.forEach(suggestion => {
                            const li = document.createElement("li");
                            li.textContent = suggestion;
                            li.classList.add("px-4", "py-2", "hover:bg-gray-100", "cursor-pointer");
                            li.addEventListener("click", () => {
                                searchInput.value = suggestion;
                                suggestionsList.classList.add("hidden");
                            });
                            suggestionsList.appendChild(li);
                        });

                        suggestionsList.classList.remove("hidden");
                    } catch (error) {
                        console.error("Search suggest error:", error);
                        suggestionsList.classList.add("hidden");
                    }
                });

                // Ẩn dropdown khi click bên ngoài
                document.addEventListener("click", (e) => {
                    if (!suggestionsList.contains(e.target) && e.target !== searchInput) {
                        suggestionsList.classList.add("hidden");
                    }
                });
            });
        </script>


    </body>
</html>
