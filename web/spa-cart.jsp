<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*, model.Customer, model.PetServiceModel" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page session="true" %>
<%
    Customer currentUser = (Customer) session.getAttribute("currentUser");
    Map<Integer, Integer> spaCart = (Map<Integer, Integer>) request.getAttribute("spaCart");
    List<PetServiceModel> spaServices = (List<PetServiceModel>) request.getAttribute("spaServices");
    BigDecimal totalPrice = (BigDecimal) request.getAttribute("totalPrice");
    Integer totalDuration = (Integer) request.getAttribute("totalDuration");
    String errorMessage = (String) request.getAttribute("errorMessage");
    
    if (spaCart == null) spaCart = new HashMap<>();
    if (spaServices == null) spaServices = new ArrayList<>();
    if (totalPrice == null) totalPrice = BigDecimal.ZERO;
    if (totalDuration == null) totalDuration = Integer.valueOf(0);
%>
<html lang="vi">
    <head>
        <meta charset="UTF-8"/>
        <meta name="viewport" content="width=device-width, initial-scale=1"/>
        <title>🛒 Giỏ Hàng Spa - Petcity</title>
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
                🛒 Giỏ Hàng Spa
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

            <% if (spaCart.isEmpty()) {%>
            <div class="text-center py-12 bg-gradient-to-br from-blue-50 to-purple-50 rounded-lg border-2 border-dashed border-blue-200">
                <div class="text-6xl mb-6">🛒</div>
                <h3 class="text-2xl font-bold text-gray-700 mb-4">Giỏ hàng Spa trống</h3>
                <p class="text-lg text-gray-600 mb-6">Bạn chưa có dịch vụ spa nào trong giỏ hàng</p>
                <p class="text-sm text-gray-500 mb-8">Hãy khám phá các dịch vụ spa tuyệt vời của chúng tôi!</p>
                
                <div class="space-y-4">
                    <a href="<%= request.getContextPath()%>/spa-service.jsp" 
                       class="inline-block px-8 py-4 bg-gradient-to-r from-blue-500 to-purple-600 text-white font-bold rounded-lg shadow-lg hover:shadow-xl transform hover:-translate-y-1 transition-all duration-300 text-decoration-none"
                       style="font-family: 'Quicksand', sans-serif;">
                        <i class="fas fa-spa mr-2"></i>
                        🎯 Khám phá dịch vụ Spa
                    </a>
                    
                    <div class="text-center">
                        <a href="<%= request.getContextPath()%>/spa-booking?action=history" 
                           class="inline-block px-6 py-3 text-blue-600 hover:text-blue-800 font-semibold transition-colors duration-300 text-decoration-none"
                           style="font-family: 'Quicksand', sans-serif;">
                            <i class="fas fa-history mr-2"></i>
                            📅 Xem lịch sử đặt lịch
                        </a>
                    </div>
                </div>
            </div>
            <% } else { %>
            <div class="space-y-6">
                <% for (PetServiceModel service : spaServices) {
                        int quantity = spaCart.get(service.getServiceId());
                        BigDecimal subtotal = service.getPrice().multiply(BigDecimal.valueOf(quantity));
                        int serviceId = service.getServiceId();
                %>
                <div class="flex items-center justify-between border-b pb-4" id="row-<%= serviceId%>">
                    <div class="flex items-center space-x-4">
                        <div class="w-24 h-24 bg-gradient-to-br from-orange-400 to-pink-400 rounded shadow flex items-center justify-center">
                            <i class="fas fa-spa text-white text-3xl"></i>
                        </div>
                        <div>
                            <div class="font-semibold text-lg"><%= service.getName()%></div>
                            <div class="text-sm text-gray-500">Mã DV: <%= serviceId%></div>
                            <div class="text-xs text-green-600">⏱️ Thời gian: <%= service.getDuration()%> phút</div>
                        </div>
                    </div>
                    <div class="w-20 text-right font-semibold text-blue-600"><%= String.format("%.0f", service.getPrice())%>₫</div>
                    <input type="number" min="1" value="<%= quantity%>" 
                           data-service-id="<%= serviceId%>" class="quantity-input w-16 text-center border rounded py-1 px-2">
                    <div class="w-24 text-right font-bold text-green-600" id="item-total-<%= serviceId%>"><%= String.format("%.0f", subtotal)%>₫</div>
                    <button onclick="removeItem(<%= serviceId%>)" class="text-red-500 hover:text-red-700"><i class="fas fa-trash"></i></button>
                </div>
                <% }%>

                <div class="flex justify-between items-center border-t pt-4">

                    <div class="mt-6 text-center space-x-4">
                        <a href="<%= request.getContextPath()%>/spa-booking?action=history"
                           class="inline-block px-6 py-3 rounded font-semibold transition-all duration-300"
                           style="background: var(--card-bg-alt); color: var(--text); border: 2px solid rgba(111, 213, 221, 0.3); border-radius: var(--border-radius-small); text-decoration: none; font-family: 'Quicksand', sans-serif;"
                           onmouseover="this.style.background = 'rgba(111, 213, 221, 0.1)'; this.style.transform = 'translateY(-2px)'"
                           onmouseout="this.style.background = 'var(--card-bg-alt)'; this.style.transform = 'translateY(0)'">
                            📅 Xem lịch sử đặt lịch Spa
                        </a>

                        <a href="<%= request.getContextPath()%>/spa-service.jsp" 
                           class="inline-block px-6 py-3 rounded font-semibold transition-all duration-300"
                           style="background: linear-gradient(135deg, var(--accent), var(--accent-pink)); color: white; border-radius: var(--border-radius-small); box-shadow: var(--shadow-button); text-decoration: none; font-family: 'Quicksand', sans-serif;"
                           onmouseover="this.style.transform = 'translateY(-2px)'; this.style.boxShadow = 'var(--shadow-button-hover)'"
                           onmouseout="this.style.transform = 'translateY(0)'; this.style.boxShadow = 'var(--shadow-button)'">
                            ⬅️ Tiếp tục chọn dịch vụ Spa
                        </a>
                    </div>

                    <div class="text-right">
                        <div class="text-gray-500 text-sm">Tổng thời gian: <%= totalDuration%> phút</div>
                        <div class="text-gray-500 text-sm">Tổng cộng:</div>
                        <div class="text-2xl font-bold text-green-700" id="cart-total"><%= String.format("%.0f", totalPrice)%>₫</div>
                    </div>
                </div>

                <% if (currentUser != null) {%>
                <form action="<%= request.getContextPath()%>/spa-booking" method="post" class="mt-6 space-y-4">
                    <input type="hidden" name="action" value="create-booking">
                    
                    <label class="block text-gray-700 font-semibold">Ngày hẹn:</label>
                    <input type="date" name="appointmentDate" required
                           class="w-full border rounded px-4 py-2 mb-3" />
                    
                    <label class="block text-gray-700 font-semibold">Giờ hẹn:</label>
                    <select name="appointmentTime" required class="w-full border rounded px-4 py-2 mb-3">
                        <option value="">-- Chọn giờ hẹn --</option>
                        <option value="08:00">08:00</option>
                        <option value="09:00">09:00</option>
                        <option value="10:00">10:00</option>
                        <option value="11:00">11:00</option>
                        <option value="14:00">14:00</option>
                        <option value="15:00">15:00</option>
                        <option value="16:00">16:00</option>
                        <option value="17:00">17:00</option>
                    </select>
                    
                    <label class="block text-gray-700 font-semibold mt-4">Ghi chú:</label>
                    <textarea name="note" placeholder="Ghi chú đặc biệt cho dịch vụ spa..."
                              class="w-full border rounded px-4 py-2 mb-3" rows="3"></textarea>

                    <button type="submit" class="w-full bg-green-600 hover:bg-green-700 text-white font-bold py-3 rounded transition">
                        💆 Đặt lịch Spa ngay
                    </button>
                </form>
                <% } else {%>
                <div class="text-center mt-8 bg-yellow-50 border border-yellow-400 rounded p-6">
                    <p class="text-lg font-semibold text-yellow-700 mb-4">⚠️ Bạn cần đăng nhập để tiến hành đặt lịch Spa</p>
                    <a href="<%= request.getContextPath()%>/login.jsp" class="bg-yellow-500 text-white px-6 py-3 rounded hover:bg-yellow-600 transition">
                        🔐 Đăng nhập ngay
                    </a>
                </div>
                <% } %>
            </div>
            <% }%>
        </div>

        <script>
            function removeItem(serviceId) {
                if (confirm('🗑️ Bạn có chắc chắn muốn xóa dịch vụ này?')) {
                    $.post('<%= request.getContextPath()%>/spa-booking', {
                        action: 'remove-service',
                        serviceId: serviceId
                    }, function () {
                        $('#row-' + serviceId).fadeOut(300, function () {
                            $(this).remove();
                            updateCartTotal();
                        });
                    });
                }
            }

            function updateCartTotal() {
                $.get('<%= request.getContextPath()%>/spa-booking', {
                    action: 'total'
                }, function (total) {
                    $('#cart-total').text(parseFloat(total).toFixed(0) + '₫');
                });
            }
            
            function updateQuantity(serviceId, change) {
                const quantitySpan = document.getElementById('quantity-' + serviceId);
                let currentQuantity = parseInt(quantitySpan.textContent) || 0;
                let newQuantity = currentQuantity + change;
                
                if (newQuantity < 0) newQuantity = 0;
                
                // Update display
                quantitySpan.textContent = newQuantity;
                
                // Send AJAX request to update cart
                $.post('<%= request.getContextPath()%>/spa-booking', {
                    action: 'update-service',
                    serviceId: serviceId,
                    quantity: newQuantity
                }, function(response) {
                    if (response.success) {
                        // Reload page to update totals
                        location.reload();
                    } else {
                        // Revert display
                        quantitySpan.textContent = currentQuantity;
                        alert('❌ Lỗi: ' + response.message);
                    }
                });
            }
            
            function removeFromCart(serviceId) {
                if (confirm('🗑️ Bạn có chắc chắn muốn xóa dịch vụ này khỏi giỏ hàng?')) {
                    $.post('<%= request.getContextPath()%>/spa-booking', {
                        action: 'remove-service',
                        serviceId: serviceId
                    }, function(response) {
                        if (response.success) {
                            location.reload();
                        } else {
                            alert('❌ Lỗi: ' + response.message);
                        }
                    });
                }
            }

            $(document).ready(function () {
                const debounceTimers = {};
                $('.quantity-input').on('input', function () {
                    const $input = $(this);
                    const serviceId = $input.data('service-id');
                    const quantity = $input.val();
                    clearTimeout(debounceTimers[serviceId]);
                    debounceTimers[serviceId] = setTimeout(() => {
                        $.ajax({
                            url: '<%= request.getContextPath()%>/spa-booking',
                            type: 'POST',
                            data: {
                                action: 'update-quantity',
                                serviceId: serviceId,
                                quantity: quantity
                            },
                            dataType: 'json',
                            success: function (res) {
                                if (res.error) {
                                    alert(res.error);
                                    location.reload();
                                } else {
                                    $('#item-total-' + serviceId).text(res['item_' + serviceId] + '₫');
                                    $('#cart-total').text(res.total + '₫');
                                }
                            }
                        });
                    }, 500);
                });
                
                // Set minimum date to today
                const dateInput = document.querySelector('input[name="appointmentDate"]');
                if (dateInput) {
                    const today = new Date().toISOString().split('T')[0];
                    dateInput.min = today;
                    
                    // Set default date to tomorrow
                    const tomorrow = new Date();
                    tomorrow.setDate(tomorrow.getDate() + 1);
                    dateInput.value = tomorrow.toISOString().split('T')[0];
                }
            });
        </script>

        <!-- Chatbox removed as requested -->
    </body>
</html>
