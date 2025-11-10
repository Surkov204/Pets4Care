<%@page import="dao.ProductDAO"%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.Customer" %>
<%@ page import="model.CartItem" %>
<%@ page import="model.Product" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<%
    Customer currentUser = (Customer) session.getAttribute("currentUser");

    boolean canReview = true; // Đã đăng nhập thì luôn true
    // Lấy productId từ URL, kiểm tra cả tham số "productId" và "id"
    String productIdStr = request.getParameter("productId");
    if (productIdStr == null || productIdStr.isEmpty()) {
        productIdStr = request.getParameter("id"); // Nếu productId không có, thử lấy "id"
    }

    // Nếu cả productId và id đều không có, redirect về trang chủ
    if (productIdStr == null || productIdStr.isEmpty()) {
        response.sendRedirect("home.jsp");
        return;
    }

    // Chuyển đổi productId từ String sang int
    int productId = Integer.parseInt(productIdStr);

    // Lấy sản phẩm từ database
    Product product = new ProductDAO().getProductById(productId);
    if (product == null) {
        response.sendRedirect("home.jsp"); // Nếu không tìm thấy sản phẩm, redirect về trang chủ
        return;
    }

    // Lấy thông tin về đánh giá và sản phẩm tương tự
    Double avgRating = new ProductDAO().getAverageRating(productId);
    java.util.List reviews = new ProductDAO().getReviewsByProductId(productId);
    java.util.List similar = new ProductDAO().getSimilarProducts(product.getCategoryId(), productId, 4); // 4 sản phẩm tương tự

    // Tính toán giỏ hàng
    java.util.Map<Integer, CartItem> cart = (java.util.Map<Integer, CartItem>) session.getAttribute("cart");
    int cartCount = 0;
    double cartTotal = 0;
    if (cart != null) {
        for (CartItem item : cart.values()) {
            cartCount += item.getQuantity();
            cartTotal += item.getQuantity() * item.getProduct().getPrice();
        }
    }


%>

<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title><%= product.getName()%> | Petcity</title>
        <script src="https://cdn.tailwindcss.com"></script>
        <link rel="stylesheet" href="<%= request.getContextPath()%>/css/homeStyle.css" />
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css" />
    </head>
    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" />
    <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>

    <body>

        <!-- HEADER -->
        <div class="top-bar">
            <div class="left">PETCITY - SIÊU THỊ THÚ CƯNG ONLINE</div>
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
                <img src="https://storage.googleapis.com/a1aa/image/15870274-75b6-4029-e89c-1424dc010c18.jpg" width="60" height="60" alt="Logo Petcity"/>
                <div>
                    <div class="logo-text">petcity</div>
                    <div class="logo-subtext">thành phố thú cưng</div>
                </div>
            </a> 
            <form class="search-form" method="get" action="<%= request.getContextPath()%>/search">
                <input type="text" name="keyword" placeholder="Tìm kiếm...">
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
                                <a href="user/user-info.jsp" class="text-gray-700 block px-4 py-2 text-sm hover:bg-gray-100">👤 Thông tin tài khoản</a>
                                <a href="<%= request.getContextPath()%>/logout.jsp" class="text-gray-700 block px-4 py-2 text-sm hover:bg-gray-100">🚪 Đăng xuất</a>
                            </div>
                        </div>
                    </div>
                    <% }%>
                </div>
                <div>
                    <a href="<%= request.getContextPath()%>/cart/cart.jsp">
                        <i class="fas fa-shopping-cart"></i> Giỏ hàng /
                        <span class="cart-amount"><%= String.format("%.2f", cartTotal)%></span>đ
                    </a>
                    <span class="cart-count"><%= cartCount%></span>
                </div>
            </div>
        </header>

        <nav>
            <ul>
                <li><a href="<%= request.getContextPath()%>/home">TRANG CHỦ</a></li>
                <li><a href="spa-service.jsp">DỊCH VỤ</a></li>
                <li><a href="search?categoryId=2">SẢN PHẨM</a></li>
                <li><a href="doctor.jsp">BÁC SĨ</a></li>
                <li><a href="gioi-thieu.jsp">GIỚI THIỆU</a></li>
                <li><a href="tin-tuc.jsp">TIN TỨC</a></li>
                <li><a href="<%= request.getContextPath()%>/home">LIÊN HỆ</a></li>
            </ul>
        </nav>

        <!-- MAIN -->
        <div class="content-wrapper">
            <main class="main-content space-y-10">

                <!-- Chi tiết sản phẩm -->
                <div class="flex flex-col lg:flex-row gap-8 bg-white p-6 rounded-xl shadow">
                    <div class="w-full lg:w-[40%]">
                        <img src="<%= request.getContextPath()%>/images/toy_<%= product.getProductId()%>.jpg"
                             onerror="this.src='<%= request.getContextPath()%>/images/default.jpg'" class="w-full h-[380px] object-contain border rounded-lg"
                             alt="<%= product.getName()%>" />
                    </div>
                    <div class="flex-1 space-y-4">
                        <h1 class="text-xl font-semibold text-slate-800"><%= product.getName()%></h1>
                        <div class="flex items-center gap-1">
                            <%
                                int full = avgRating != null ? avgRating.intValue() : 0;
                                boolean half = avgRating != null && avgRating - full >= 0.5;
                                for (int i = 1; i <= 5; i++) {
                                    if (i <= full) { %><i class="fa-solid fa-star text-yellow-400"></i><% } else if (i == full + 1 && half) { %><i class="fa-solid fa-star-half-stroke text-yellow-400"></i><% } else { %><i class="fa-regular fa-star text-yellow-400"></i><% }
                                        }
                                %>
                            <span class="text-sm text-gray-500 ml-2">
                                (<%= avgRating != null ? String.format("%.2f", avgRating) : "Chưa có đánh giá"%>/5)
                            </span>
                        </div>
                        <p class="text-red-600 text-2xl font-bold"><%= String.format("%,.0f", product.getPrice())%>₫</p>
                        <p class="text-gray-600 text-sm">Kho: <%= product.getStockQuantity()%> sản phẩm</p>
                        <p class="text-gray-700 text-base"><%= product.getDescription()%></p>

                        <div class="flex items-center gap-3">
                            <label for="qty" class="text-sm font-medium">Số lượng:</label>
                            <input id="qty" type="number" value="1" min="1" max="<%= product.getStockQuantity()%>"
                                   class="w-20 border rounded px-2 py-1 text-sm focus:ring-2 focus:ring-blue-400" <% if (product.getStockQuantity() == 0) { %>disabled<% } %>/>
                        </div>

                        <div class="mt-4 space-x-2">
                            <% if (product.getStockQuantity() == 0) { %>
                            <span class="text-red-500 font-semibold">Hết hàng</span>
                            <% } else {%>
                            <button class="btn-add-cart" onclick="addToCart(<%= product.getProductId()%>, <%= product.getPrice()%>, true)">🛒 Thêm vào giỏ</button>
                            <button class="btn-add-cart" style="background: var(--primary);" onclick="openBuyNow()">⚡ Mua ngay</button>
                            <% }%>
                        </div>
                    </div>
                </div>

                <!-- Đánh giá -->
                <section class="space-y-6 bg-white p-6 rounded-xl shadow">
                    <h2 class="text-lg font-semibold">Đánh giá sản phẩm</h2>

                    <c:choose>
                        <c:when test="${not empty sessionScope.currentUser and canReview}">
                            <form method="post" action="toydetailservlet" class="space-y-4">
                                <input type="hidden" name="productId" value="${product.productId}" />
                                <label class="block text-sm">Số sao:</label>
                                <select name="rating" class="border rounded p-2">
                                    <c:forEach var="i" begin="1" end="5">
                                        <option value="${i}">${i} sao</option>
                                    </c:forEach>
                                </select>

                                <label class="block text-sm">Nhận xét:</label>
                                <textarea name="comment" rows="4" class="w-full border rounded p-2"></textarea>

                                <button type="submit" class="bg-blue-500 text-white px-4 py-2 rounded">Gửi đánh giá</button>
                            </form>
                        </c:when>

                        <c:when test="${not empty sessionScope.currentUser and not canReview}">
                            <p class="text-sm text-red-500">⚠️ Bạn cần <b>mua và hoàn tất đơn hàng</b> mới được đánh giá sản phẩm này.</p>
                        </c:when>

                        <c:otherwise>
                            <p class="text-sm text-red-500">* Vui lòng <a href="<%= request.getContextPath()%>/login.jsp" class="text-blue-600 underline">đăng nhập</a> để đánh giá.</p>
                        </c:otherwise>
                    </c:choose>

                    <div class="space-y-4">
                        <c:forEach var="r" items="${reviews}">
                            <div class="border-b pb-3">
                                <p class="text-sm font-medium">${r.customerName} -
                                    <c:forEach begin="1" end="5" var="i">
                                        <i class="fa${i <= r.rating ? '-solid' : '-regular'} fa-star text-yellow-400"></i>
                                    </c:forEach>
                                </p>
                                <p class="text-sm text-gray-600">${r.comment}</p>
                                <p class="text-xs text-gray-400">${r.createdAt}</p>
                            </div>
                        </c:forEach>
                    </div>
                </section>

                <!-- Thông báo -->
                <c:if test="${not empty message}">
                    <div class="p-3 text-green-700 bg-green-100 rounded">${message}</div>
                </c:if>
                <c:if test="${not empty error}">
                    <div class="p-3 text-red-700 bg-red-100 rounded">${error}</div>
                </c:if>

                <!-- Sản phẩm tương tự -->
                <section class="space-y-4">
                    <h2 class="text-lg font-semibold">Sản phẩm tương tự</h2>
                    <div class="toys-grid grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4">
                        <c:forEach var="product" items="${similar}">
                            <div class="border p-3 rounded hover:shadow">
                                <a href="toydetailservlet?id=${product.productId}">
                                    <img src="images/toy_${product.productId}.jpg" onerror="this.src='images/default.jpg'" class="h-32 w-full object-contain" />
                                    <p class="toy-name font-semibold mt-2">${product.name}</p>
                                </a>
                                <p class="toy-price text-red-600">${product.price}₫</p>
                                <button class="btn-add-cart mt-2 w-full bg-blue-500 text-white py-1 rounded" onclick="addToCart(${product.productId}, ${product.price})">🛒 Thêm vào giỏ</button>
                            </div>
                        </c:forEach>
                    </div>

                </section>

            </main>
        </div>

        <!-- Buy Now Modal -->
        <div id="buy-now-modal" class="fixed inset-0 bg-black bg-opacity-40 hidden items-center justify-center z-50">
            <div class="bg-white rounded-xl shadow-lg w-96 p-5" style="border-radius: var(--border-radius);">
                <div class="flex justify-between items-center mb-3">
                    <h3 class="text-lg font-semibold">Mua ngay</h3>
                    <button onclick="closeBuyNow()" class="text-red-500 text-xl">✖</button>
                </div>
                <!-- Popup chọn vị trí trong Mua ngay -->
                <div id="buy-map-popup" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center hidden z-50">
                    <div class="bg-white rounded shadow-lg w-11/12 md:w-3/4 h-96 relative flex flex-col">
                        <button onclick="closeBuyMap()" class="absolute top-2 right-2 text-red-500 text-lg">✖</button>
                        <div id="buy-map" class="w-full flex-1 rounded"></div>
                        <div class="p-3 border-t text-right">
                            <button onclick="confirmBuyLocation()" class="bg-green-600 hover:bg-green-700 text-white px-4 py-2 rounded">
                                ✅ Xác nhận vị trí
                            </button>
                        </div>
                    </div>
                </div>

                <form method="post" action="<%= request.getContextPath()%>/buynowservlet" class="space-y-4">
                    <input type="hidden" name="productId" value="<%= product.getProductId()%>"/>
                    <div class="flex items-center gap-3">
                        <label for="buy-now-qty" class="text-sm font-medium">Số lượng:</label>
                        <input id="buy-now-qty" name="quantity" type="number" value="1" min="1" max="<%= product.getStockQuantity()%>" class="w-24 border rounded px-2 py-1 text-sm">
                    </div>
                    <div>
                        <label class="text-sm font-medium">Phương thức thanh toán:</label>
                        <select name="payment_method" required class="w-full border rounded px-3 py-2">
                            <option value="">-- Chọn phương thức --</option>
                            <option value="Tiền mặt">💵 Tiền mặt khi nhận hàng</option>
                            <option value="PayOS">💳 Thanh toán online (PayOS)</option>
                        </select>
                    </div>
                    <div>
                        <label class="text-sm font-medium">Địa chỉ nhận hàng:</label>
                        <input type="text" id="buy_address" name="shipping_address" required 
                               class="w-full border rounded px-3 py-2 mb-2"
                               placeholder="Số nhà, đường, phường/xã..."
                               value="<%= currentUser != null ? currentUser.getAddressCustomer() : ""%>"/>

                        <div class="flex items-center gap-2">
                            <button type="button" onclick="openBuyMap()" 
                                    class="bg-blue-500 hover:bg-blue-600 text-white px-3 py-1 rounded">
                                🗺️ Chọn vị trí trên bản đồ
                            </button>
                            <span id="buy-map-status" class="text-sm text-green-600 hidden">📍 Đã chọn vị trí</span>
                        </div>

                        <!-- ẩn tọa độ -->
                        <input type="hidden" name="latitude" id="buy_latitude" />
                        <input type="hidden" name="longitude" id="buy_longitude" />
                    </div>

                    <div class="flex gap-2 pt-1">
                        <button type="button" class="bg-gray-200 hover:bg-gray-300 text-gray-800 px-4 py-2 rounded w-1/2" onclick="closeBuyNow()">Hủy</button>
                        <button type="submit" class="btn-add-cart w-1/2">🛍️ Đặt hàng</button>
                    </div>
                    <p class="text-xs text-gray-500">Đơn hàng sẽ chỉ bao gồm sản phẩm này.</p>
                </form>
            </div>
        </div>

        <!-- Toast -->
        <div id="toast" class="fixed bottom-5 right-5 bg-black text-white px-4 py-2 rounded hidden z-50"></div>

        <script>
            function addToCart(id, price, useQty = false) {
                let qty = 1;
                if (useQty) {
                    const input = document.getElementById('qty');
                    if (input) {
                        qty = parseInt(input.value || "1");
                        if (isNaN(qty) || qty <= 0)
                            qty = 1;  // Đảm bảo qty hợp lệ
                    }
                }

                fetch("<%=request.getContextPath()%>/cartservlet", {
                    method: "POST",
                    headers: {
                        "Content-Type": "application/x-www-form-urlencoded"
                    },
                    body: new URLSearchParams({
                        action: "add", // Đảm bảo action là "add"
                        id: id, // Truyền productId
                        quantity: qty   // Truyền số lượng
                    })
                })
                        .then(res => {
                            if (res.ok) {
                                showToast("🛒 Đã thêm vào giỏ hàng!");
                                incrementCart(price * qty, qty);  // Cập nhật giỏ hàng ngay lập tức
                            }
                        })
                        .catch(err => {
                            showToast("⚠️ Lỗi: " + err.message);
                        });
            }


            function incrementCart(amount, count = 1) {
                const cnt = document.querySelector(".cart-count");
                const amt = document.querySelector(".cart-amount");

                const currentCount = parseInt(cnt.innerText || "0");
                const currentAmount = parseFloat(amt.innerText.replace(/[^\d.]/g, "") || "0");

                cnt.innerText = currentCount + count;
                amt.innerText = (currentAmount + amount).toFixed(2);
            }

            function showToast(message) {
                const toast = document.getElementById("toast");
                toast.textContent = message;
                toast.classList.remove("hidden");
                toast.style.opacity = "1";

                setTimeout(() => {
                    toast.style.opacity = "0";
                    setTimeout(() => toast.classList.add("hidden"), 300);
                }, 3000);
            }
            document.addEventListener("DOMContentLoaded", function () {
                const btn = document.getElementById("userToggleBtn");
                const menu = document.getElementById("userMenu");

                btn.addEventListener("click", function (e) {
                    e.stopPropagation();
                    menu.classList.toggle("hidden");
                });

                document.addEventListener("click", function (e) {
                    if (!menu.contains(e.target)) {
                        menu.classList.add("hidden");
                    }
                });
            });

            function openBuyNow() {
                const modal = document.getElementById('buy-now-modal');
                if (modal) {
                    modal.classList.remove('hidden');
                    modal.classList.add('flex');
                }
            }

            function closeBuyNow() {
                const modal = document.getElementById('buy-now-modal');
                if (modal) {
                    modal.classList.add('hidden');
                    modal.classList.remove('flex');
                }
            }

            function confirmBuyNow(productId) {
                const qtyInput = document.getElementById('buy-now-qty');
                let qty = parseInt(qtyInput && qtyInput.value ? qtyInput.value : '1');
                if (isNaN(qty) || qty <= 0)
                    qty = 1;

                fetch("<%=request.getContextPath()%>/cartservlet", {
                    method: "POST",
                    headers: {"Content-Type": "application/x-www-form-urlencoded"},
                    body: new URLSearchParams({action: 'add', id: productId, quantity: qty})
                }).then(res => {
                    if (!res.ok)
                        throw new Error('Không thể thêm vào giỏ');
                    // Chuyển tới giỏ để chọn phương thức thanh toán (Tiền mặt hoặc PayOS)
                    window.location.href = '<%= request.getContextPath()%>/cart/cart.jsp#checkout';
                }).catch(err => {
                    showToast('⚠️ ' + err.message);
                });
            }

            let buyMap, buyMarker, buyLat, buyLng;

            function openBuyMap() {
                const popup = document.getElementById('buy-map-popup');
                popup.classList.remove('hidden');

                setTimeout(() => {
                    if (!buyMap) {
                        buyMap = L.map('buy-map');
                        L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
                            attribution: '&copy; OpenStreetMap contributors'
                        }).addTo(buyMap);

                        // Khi click chọn vị trí
                        buyMap.on('click', function (e) {
                            buyLat = e.latlng.lat;
                            buyLng = e.latlng.lng;
                            if (buyMarker)
                                buyMap.removeLayer(buyMarker);
                            buyMarker = L.marker([buyLat, buyLng]).addTo(buyMap);

                            fetch('https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=' + buyLat + '&lon=' + buyLng)
                                    .then(r => r.json())
                                    .then(d => {
                                        if (d && d.display_name) {
                                            document.getElementById('buy_address').value = d.display_name;
                                            document.getElementById('buy-map-status').classList.remove('hidden');
                                        }
                                    })
                                    .catch(() => alert('Không truy vấn được địa chỉ.'));
                        });
                    }

                    // Nếu có địa chỉ sẵn thì tìm tọa độ
                    const addr = document.getElementById('buy_address').value;
                    if (addr && addr.trim().length > 5) {
                        fetch('https://nominatim.openstreetmap.org/search?format=json&q=' + encodeURIComponent(addr))
                                .then(r => r.json())
                                .then(results => {
                                    if (results && results.length > 0) {
                                        const {lat, lon} = results[0];
                                        buyLat = parseFloat(lat);
                                        buyLng = parseFloat(lon);
                                        buyMap.setView([buyLat, buyLng], 16);
                                        if (buyMarker)
                                            buyMap.removeLayer(buyMarker);
                                        buyMarker = L.marker([buyLat, buyLng]).addTo(buyMap);
                                    } else {
                                        buyMap.setView([21.0285, 105.8542], 13);
                                    }
                                });
                    } else {
                        buyMap.setView([21.0285, 105.8542], 13);
                    }

                    // Refresh map size sau khi popup hiển thị
                    setTimeout(() => buyMap.invalidateSize(), 300);
                }, 400);
            }

            function closeBuyMap() {
                document.getElementById('buy-map-popup').classList.add('hidden');
            }

            function confirmBuyLocation() {
                if (buyLat && buyLng) {
                    document.getElementById('buy_latitude').value = buyLat;
                    document.getElementById('buy_longitude').value = buyLng;
                    document.getElementById('buy-map-status').classList.remove('hidden');
                    closeBuyMap();
                } else {
                    alert('📍 Vui lòng chọn vị trí trên bản đồ trước khi xác nhận.');
                }
            }

        </script>
        <jsp:include page="../chatbox.jsp"/>
    </body>
</html>
