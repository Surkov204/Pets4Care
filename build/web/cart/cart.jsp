<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*, model.CartItem, model.Customer, dao.UserDAO, model.Order" %>
<%@ page session="true" %>
<html lang="vi">
    <head>
        <meta charset="UTF-8"/>
        <meta name="viewport" content="width=device-width, initial-scale=1"/>
        <title>🛒 Giỏ Hàng - Petcity</title>
        <script src="https://cdn.tailwindcss.com"></script>
        <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.3/css/all.min.css" rel="stylesheet" />
        <link href="https://fonts.googleapis.com/css2?family=Quicksand:wght@300;400;500;600;700&family=Nunito:wght@300;400;500;600;700;800&family=Baloo+2:wght@400;500;600;700;800&display=swap" rel="stylesheet" />
        <link rel="stylesheet" href="../css/homeStyle.css" />
        <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
        <style>
            .fa-spinner {
                color: var(--primary);
                font-size: 1.2rem;
            }
            .quantity-input {
                transition: all 0.3s ease;
            } 
            .quantity-input:focus {
                border-color: var(--primary) !important;
                box-shadow: 0 0 0 3px rgba(111, 213, 221, 0.2) !important;
            }
        </style>
    </head>
    <body>

        <%
            Customer currentUser = (Customer) session.getAttribute("currentUser");
            Map<Integer, CartItem> cart = (Map<Integer, CartItem>) session.getAttribute("cart");
            double total = 0;
            String errorMessage = (String) request.getAttribute("errorMessage");
        %>

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

            <div class="cart-title" style="font-family: 'Baloo 2', cursive; font-size: 1.5rem; color: var(--primary); font-weight: 700;">
                🛒 Giỏ Hàng
            </div>

            <div class="contact-info">
                <div><i class="far fa-clock"></i> 08:00 - 17:00</div>
                <% if (currentUser != null) {%>
                <div>
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
                                <a href="../user/user-info.jsp"
                                   class="text-gray-700 block px-4 py-2 text-sm hover:bg-gray-100">👤 Thông tin tài khoản</a>
                                <a href="../logout.jsp"
                                   class="text-gray-700 block px-4 py-2 text-sm hover:bg-gray-100">🚪 Đăng xuất</a>
                            </div>
                        </div>
                    </div>
                </div>
                <% } else {%>
                <div>
                    <a href="<%= request.getContextPath()%>/login.jsp"
                       class="px-4 py-2 text-white rounded"
                       style="background: var(--primary); font-family: 'Quicksand', sans-serif; text-decoration: none;">
                        🔐 Đăng nhập
                    </a>
                </div>
                <% } %>
            </div>
        </header>

        <!-- Main Content -->
        <div class="mx-auto max-w-6xl mt-6 px-4 py-6 rounded-md shadow-md" style="background: var(--card-bg); border-radius: var(--border-radius); box-shadow: var(--shadow-light);">
            <% if (errorMessage != null) {%>
            <div class="p-4 mb-4 rounded-md bg-red-100 border-l-4 border-red-500" role="alert">
                <p class="font-bold text-red-600">⚠️ Lỗi</p>
                <p><%= errorMessage%></p>
            </div>
            <% } %>

            <% if (cart == null || cart.isEmpty()) {%>
            <div class="text-center py-20 bg-gray-50 rounded">
                <div class="text-5xl mb-4">🛒</div>
                <p class="text-lg text-gray-600 mb-4">Giỏ hàng trống</p>
                <div class="space-x-4">
                    <a href="<%= request.getContextPath()%>/home" class="bg-blue-500 text-white px-6 py-3 rounded hover:bg-blue-600 transition">🎾 Tiếp tục mua sắm</a>
                    <%
                        // Hiển thị nút xem lịch sử đơn hàng nếu user đã đăng nhập
                        if (currentUser != null) {
                    %>
                    <a href="<%= request.getContextPath()%>/order/order-history.jsp"
                       class="inline-block px-6 py-3 rounded font-semibold transition-all duration-300"
                       style="background: var(--card-bg-alt); color: var(--text); border: 2px solid rgba(111, 213, 221, 0.3); border-radius: var(--border-radius-small); text-decoration: none; font-family: 'Quicksand', sans-serif;"
                       onmouseover="this.style.background = 'rgba(111, 213, 221, 0.1)'; this.style.transform = 'translateY(-2px)'"
                       onmouseout="this.style.background = 'var(--card-bg-alt)'; this.style.transform = 'translateY(0)'">
                        📦 Xem lịch sử đơn hàng
                    </a>
                    <% } %>
                </div>
            </div>
            <% } else { %>
            <div class="space-y-6">
                <% for (CartItem item : cart.values()) {
                        double subtotal = item.getQuantity() * item.getProduct().getPrice();
                        total += subtotal;
                        int productId = item.getProduct().getProductId();
                %>
                <div class="flex items-center justify-between border-b pb-4" id="row-<%= productId%>">
                    <div class="flex items-center space-x-4">
                        <img src="<%= request.getContextPath() + "/images/toy_" + productId + ".jpg"%>" class="w-24 h-24 object-cover rounded shadow">
                        <div>
                            <div class="font-semibold text-lg"><%= item.getProduct().getName()%></div>
                            <div class="text-sm text-gray-500">Mã SP: <%= productId%></div>
                            <div class="text-xs text-green-600">📦 Còn <%= item.getProduct().getStockQuantity()%> sản phẩm</div>
                        </div>
                    </div>
                    <div class="w-20 text-right font-semibold text-blue-600"><%= String.format("%.0f", item.getProduct().getPrice())%>₫</div>
                    <input type="number" min="1" max="<%= item.getProduct().getStockQuantity()%>" value="<%= item.getQuantity()%>" 
                           data-product-id="<%= productId%>" class="quantity-input w-16 text-center border rounded py-1 px-2">
                    <div class="w-24 text-right font-bold text-green-600" id="item-total-<%= productId%>"><%= String.format("%.0f", subtotal)%>₫</div>
                    <button onclick="removeItem(<%= productId%>)" class="text-red-500 hover:text-red-700"><i class="fas fa-trash"></i></button>
                </div>
                <% }%>

                <div class="flex justify-between items-center border-t pt-4">

                    <div class="mt-6 text-center space-x-4">
                        <%
                            // Hiển thị link lịch sử đơn hàng nếu người dùng đã đăng nhập
                            if (currentUser != null) {
                        %>
                        <a href="<%= request.getContextPath()%>/order/order-history.jsp"
                           class="inline-block px-6 py-3 rounded font-semibold transition-all duration-300"
                           style="background: var(--card-bg-alt); color: var(--text); border: 2px solid rgba(111, 213, 221, 0.3); border-radius: var(--border-radius-small); text-decoration: none; font-family: 'Quicksand', sans-serif;"
                           onmouseover="this.style.background = 'rgba(111, 213, 221, 0.1)'; this.style.transform = 'translateY(-2px)'"
                           onmouseout="this.style.background = 'var(--card-bg-alt)'; this.style.transform = 'translateY(0)'">
                            📦 Xem lịch sử đơn hàng
                        </a>
                        <% 
                            }
                        %>
                        <a href="<%= request.getContextPath()%>/home" 
                           class="inline-block px-6 py-3 rounded font-semibold transition-all duration-300"
                           style="background: linear-gradient(135deg, var(--accent), var(--accent-pink)); color: white; border-radius: var(--border-radius-small); box-shadow: var(--shadow-button); text-decoration: none; font-family: 'Quicksand', sans-serif;"
                           onmouseover="this.style.transform = 'translateY(-2px)'; this.style.boxShadow = 'var(--shadow-button-hover)'"
                           onmouseout="this.style.transform = 'translateY(0)'; this.style.boxShadow = 'var(--shadow-button)'">
                            ⬅️ Tiếp tục mua hàng
                        </a>
                    </div>

                    <div class="text-right">
                        <div class="text-gray-500 text-sm">Tổng cộng:</div>
                        <div class="text-2xl font-bold text-green-700" id="cart-total"><%= String.format("%.0f", total)%>₫</div>
                    </div>
                </div>

                <% if (currentUser != null) {%>
                <form action="<%= request.getContextPath()%>/orderservlet" method="post" class="mt-6 space-y-4">
                    <label class="block text-gray-700 font-semibold">Phương thức thanh toán:</label>
                    <select name="payment_method" required class="w-full border rounded px-4 py-2">
                        <option value="">-- Chọn phương thức --</option>
                        <option value="Tiền mặt">💵 Tiền mặt khi nhận hàng</option>
                        <option value="PayOS">💳 Thanh toán online (PayOS)</option>
                    </select>
                    <label class="block text-gray-700 font-semibold mt-4">Địa chỉ nhận hàng:</label>
                    <input type="text" name="shipping_address" placeholder="Số nhà, đường, phường/xã..." required
                           class="w-full border rounded px-4 py-2 mb-3" />

                    <!-- Trường ẩn để lưu toạ độ nếu chọn từ bản đồ -->
                    <input type="hidden" name="latitude" id="latitude" />
                    <input type="hidden" name="longitude" id="longitude" />

                    <!-- Nút chọn vị trí trên bản đồ -->
                    <div class="mb-3">
                        <button type="button" onclick="openMapPopup()" 
                                class="bg-blue-500 hover:bg-blue-600 text-white px-4 py-2 rounded">
                            🗺️ Chọn vị trí trên bản đồ
                        </button>
                        <div id="map-status" class="text-sm text-green-600 mt-1 hidden">📍 Vị trí đã được chọn</div>
                    </div>

                    <button type="submit" class="w-full bg-green-600 hover:bg-green-700 text-white font-bold py-3 rounded transition">
                        🛍️ Đặt hàng ngay
                    </button>
                </form>
                <% } else {%>
                <div class="text-center mt-8 bg-yellow-50 border border-yellow-400 rounded p-6">
                    <p class="text-lg font-semibold text-yellow-700 mb-4">⚠️ Bạn cần đăng nhập để tiến hành đặt hàng</p>
                    <a href="<%= request.getContextPath()%>/login.jsp" class="bg-yellow-500 text-white px-6 py-3 rounded hover:bg-yellow-600 transition">
                        🔐 Đăng nhập ngay
                    </a>
                </div>
                <% } %>
            </div>
            <% }%>
        </div>

        <!-- Popup chọn vị trí -->
        <div id="map-popup" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center hidden z-50">
        <div class="bg-white rounded shadow-lg w-11/12 md:w-3/4 h-96 relative flex flex-col">
            <button onclick="closeMapPopup()" class="absolute top-2 right-2 text-red-500 text-lg">✖</button>
            <div id="map" class="w-full flex-1 rounded"></div>
            <div class="p-3 border-t text-right">
                <button onclick="confirmLocation()" class="bg-green-600 hover:bg-green-700 text-white px-4 py-2 rounded">
                    ✅ Xác nhận vị trí
                </button>
            </div>
        </div>
    </div>

        <!-- Leaflet CSS & JS (miễn phí) -->
        <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" />
    <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
    <script>
        let map, marker, selectedLat, selectedLng;

        function openMapPopup() {
            $('#map-popup').removeClass('hidden');
            if (!map) {
                map = L.map('map');
                L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
                    attribution: '&copy; OpenStreetMap contributors'
                }).addTo(map);

                if (navigator.geolocation) {
                    navigator.geolocation.getCurrentPosition(function (position) {
                        map.setView([position.coords.latitude, position.coords.longitude], 15);
                    }, function () {
                        map.setView([21.0285, 105.8542], 13);
                    });
                } else {
                    map.setView([21.0285, 105.8542], 13);
                }

                map.on('click', function (e) {
                    selectedLat = e.latlng.lat;
                    selectedLng = e.latlng.lng;
                    if (marker) {
                        map.removeLayer(marker);
                    }
                    marker = L.marker([selectedLat, selectedLng], {
                        icon: L.icon({
                            iconUrl: 'https://maps.gstatic.com/mapfiles/api-3/images/spotlight-poi2_hdpi.png',
                            iconSize: [27, 43],
                            iconAnchor: [13, 41]
                        })
                    }).addTo(map);
                });
            }
        }

        function confirmLocation() {
            if (selectedLat && selectedLng) {
                $('#latitude').val(selectedLat);
                $('#longitude').val(selectedLng);
                $('#map-status').removeClass('hidden');
                closeMapPopup();
            } else {
                alert('📍 Vui lòng chọn vị trí trên bản đồ trước khi xác nhận.');
            }
        }

        function closeMapPopup() {
            $('#map-popup').addClass('hidden');
        }
    </script>



        <script>
            function removeItem(productId) {
                if (confirm('🗑️ Bạn có chắc chắn muốn xóa sản phẩm này?')) {
                    $.post('<%= request.getContextPath()%>/cartservlet', {
                        action: 'remove',
                        id: productId
                    }, function () {
                        $('#row-' + productId).fadeOut(300, function () {
                            $(this).remove();
                            updateCartTotal();
                        });
                    });
                }
            }

            function updateCartTotal() {
                $.get('<%= request.getContextPath()%>/cartservlet', {
                    action: 'total'
                }, function (total) {
                    $('#cart-total').text(parseFloat(total).toFixed(0) + '₫');
                });
            }

            $(document).ready(function () {
                const debounceTimers = {};
                $('.quantity-input').on('input', function () {
                    const $input = $(this);
                    const productId = $input.data('product-id');
                    const quantity = $input.val();
                    clearTimeout(debounceTimers[productId]);
                    debounceTimers[productId] = setTimeout(() => {
                        $.ajax({
                            url: '<%= request.getContextPath()%>/cartservlet',
                            type: 'POST',
                            data: {
                                action: 'update',
                                productId: productId,
                                quantity: quantity
                            },
                            dataType: 'json',
                            success: function (res) {
                                if (res.error) {
                                    alert(res.error);
                                    location.reload();
                                } else {
                                    $('#item-total-' + productId).text(res['item_' + productId] + '₫');
                                    $('#cart-total').text(res.total + '₫');
                                }
                            }
                        });
                    }, 500);
                });
            });
        </script>

        <jsp:include page="../chatbox.jsp"/>
    </body>
</html>