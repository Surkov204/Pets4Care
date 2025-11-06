<%@ page contentType="text/html;charset=UTF-8" language="java" isELIgnored="true" %>
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
            body { background:#fafafa; font-family: 'Nunito', sans-serif; font-size:15px; line-height:1.6; }
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
            /* Layout ổn định cho từng hàng dịch vụ */
            .spa-row { display: grid; grid-template-columns: 112px 1fr 360px; gap: 16px; align-items: start; }
            .spa-icon { width: 96px; height: 96px; }
            .spa-actions { min-width: 360px; display: flex; align-items: center; justify-content: flex-end; gap: 16px; }
            .spa-price { width: 96px; text-align: right; }
            .spa-qty { width: 64px; text-align: center; }
            .spa-total { width: 112px; text-align: right; }
            .spa-form { grid-column: 2 / 4; margin-left: 0; }
            @media (max-width: 1024px) {
                .spa-row { grid-template-columns: 96px 1fr; }
                .spa-actions { grid-column: 2; justify-content: flex-start; }
                .spa-form { grid-column: 1 / -1; margin-left: 96px; }
            }

            /* Buttons */
            .btn { transition: background-color .3s ease, box-shadow .3s ease, transform .2s ease; }
            .btn:hover { box-shadow: 0 4px 10px rgba(0,0,0,.08); transform: translateY(-1px); }

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
                        int quantity = spaCart.get(service.getServiceId()); // Giữ để tương thích, nhưng không dùng nữa
                        BigDecimal subtotal = service.getPrice(); // Giá sẽ tính theo số pet được chọn
                        int serviceId = service.getServiceId();
                        
                        // Check if this is a boarding service
                        boolean isBoardingService = serviceId >= 1000;
                %>
                <div class="spa-row border-b pb-4 rounded-xl bg-white transition hover:shadow <%= isBoardingService ? "bg-gradient-to-r from-green-50 to-blue-50 border-l-4 border-green-400" : "" %>" id="row-<%= serviceId%>">
                    <div class="flex items-center space-x-4">
                        <div class="flex-none spa-icon bg-gradient-to-br <%= isBoardingService ? "from-green-400 to-blue-400" : "from-orange-400 to-pink-400" %> rounded-xl ring-1 ring-white/50 shadow-lg flex items-center justify-center">
                            <i class="fas <%= isBoardingService ? "fa-home" : "fa-spa" %> text-white text-3xl"></i>
                        </div>
                        <div class="min-w-0 leading-5">
                            <div class="font-semibold text-lg <%= isBoardingService ? "text-green-700" : "" %> whitespace-nowrap mb-1">Đặt lịch: <span class="text-blue-700"><%= service.getName()%></span></div>
                            <div class="text-sm text-gray-500 whitespace-nowrap">Mã DV: <%= serviceId%></div>
                            <% if (isBoardingService) { %>
                                <div class="text-xs text-blue-600 whitespace-nowrap">🏠 Dịch vụ lưu trú thú cưng</div>
                            <% } else { %>
                                <div class="text-xs text-green-600 whitespace-nowrap">⏱️ Thời gian: <%= service.getDuration()%> phút</div>
                            <% } %>
                        </div>
                    </div>
                    <div class="spa-actions">
                        <div class="spa-price font-semibold text-blue-600 whitespace-nowrap">Giá mỗi pet: <%= String.format("%.0f", service.getPrice())%>₫</div>
                        <div class="spa-qty text-sm text-gray-500 whitespace-nowrap" id="pet-count-<%= serviceId%>">Chọn thú cưng</div>
                        <div class="spa-total font-bold text-green-600 whitespace-nowrap" id="item-total-<%= serviceId%>">0₫</div>
                        <div class="flex space-x-2">
                            <% if (isBoardingService) { %>
                                <button onclick="viewBoardingDetails(<%= serviceId%>)" class="text-blue-500 hover:text-blue-700" title="Xem chi tiết">
                                    <i class="fas fa-eye"></i>
                                </button>
                                <button onclick="editBoardingDetails(<%= serviceId%>)" class="text-orange-500 hover:text-orange-700" title="Sửa thông tin">
                                    <i class="fas fa-edit"></i>
                                </button>
                            <% } %>
                            <button onclick="removeItem(<%= serviceId%>)" class="text-red-500 hover:text-red-700" title="Xóa">
                                <i class="fas fa-trash"></i>
                            </button>
                        </div>
                    </div>
                    <% if (!isBoardingService) { %>
                    <!-- Per-service form (đặt dưới icon, canh lề theo icon) -->
                    <div class="spa-form mt-4">
                        <form class="w-full rounded-xl border border-slate-200 bg-white shadow-sm hover:shadow-md transition overflow-hidden"
                              data-service-id="<%= serviceId%>"
                              onsubmit="return submitSingleService(event,<%= serviceId%>)">
                            <!-- Header bar removed per request; service name already shown near icon -->
                            <div class="grid grid-cols-1 md:grid-cols-3 gap-6 p-5">
                                <div>
                                    <label class="block text-sm font-medium text-slate-700 mb-1">Ngày</label>
                                    <input type="date" name="date-<%= serviceId%>" class="w-full border border-slate-300 rounded-lg px-3 h-10 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500" min="<%= java.time.LocalDate.now().toString() %>">
                                </div>
                                <div>
                                    <label class="block text-sm font-medium text-slate-700 mb-1">Giờ hẹn</label>
                                    <div class="flex space-x-2">
                                        <select name="hour-<%= serviceId%>" id="hour-<%= serviceId%>" class="w-full border border-slate-300 rounded-lg px-3 h-10 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500" required>
                                            <option value="">Giờ</option>
                                            <% 
                                            // Chỉ hiển thị 8-11h và 13-17h
                                            for (int h = 8; h <= 11; h++) { 
                                            %>
                                            <option value="<%= String.format("%02d", h) %>"><%= String.format("%02d", h) %></option>
                                            <% } %>
                                            <% 
                                            for (int h = 13; h <= 17; h++) { 
                                            %>
                                            <option value="<%= String.format("%02d", h) %>"><%= String.format("%02d", h) %></option>
                                            <% } %>
                                        </select>
                                        <select name="minute-<%= serviceId%>" id="minute-<%= serviceId%>" class="w-full border border-slate-300 rounded-lg px-3 h-10 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500" required>
                                            <option value="">Phút</option>
                                            <% for (int m = 0; m < 60; m++) { %>
                                            <option value="<%= String.format("%02d", m) %>"><%= String.format("%02d", m) %></option>
                                            <% } %>
                                        </select>
                                    </div>
                                    <input type="hidden" name="time-<%= serviceId%>" id="selected-time-<%= serviceId%>" value="">
                                    <p class="text-xs text-slate-500 mt-1">Giờ làm việc: 08:00-12:00 và 13:00-17:00</p>
                                </div>
                                <div>
                                    <label class="block text-sm font-medium text-slate-700 mb-1">Chọn thú cưng</label>
                                    <div id="pet-checkboxes-<%= serviceId%>" class="border border-slate-300 rounded-lg px-3 py-2 max-h-40 overflow-y-auto bg-white">
                                        <p class="text-sm text-gray-500">Đang tải danh sách thú cưng...</p>
                                    </div>
                                    <p class="text-xs text-slate-500 mt-1">Giá sẽ tính theo số lượng thú cưng đã chọn</p>
                                </div>
                                <div>
                                    <label class="block text-sm font-medium text-slate-700 mb-1">Phương thức thanh toán</label>
                                    <select name="payment-<%= serviceId%>" class="w-full border border-slate-300 rounded-lg px-3 h-10 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500">
                                        <option value="payos">PayOS</option>
                                    </select>
                                </div>
                            </div>
                            <div class="px-5 pb-5 space-y-3">
                                <div>
                                    <label class="block text-sm font-medium text-slate-700 mb-1">Ghi chú (tuỳ chọn)</label>
                                    <input type="text" name="note-<%= serviceId%>" class="w-full border border-slate-300 rounded-lg px-3 h-10 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500" placeholder="Ghi chú cho nhân viên Spa...">
                                </div>
                                <div class="flex items-center justify-between">
                                    <span id="avail-<%= serviceId%>" class="text-sm text-gray-600" aria-live="polite"></span>
                                    <div class="space-x-2">
                                        <button type="button" class="btn h-10 px-4 bg-blue-600 hover:bg-blue-700 text-white rounded-lg shadow-sm"
                                                onclick="checkSingleAvailability(<%= serviceId%>)" title="Kiểm tra trống lịch">Kiểm tra</button>
                                        <button id="btn-book-<%= serviceId%>" type="submit" class="btn h-10 px-4 bg-green-600 hover:bg-green-700 text-white rounded-lg shadow-sm opacity-50 cursor-not-allowed"
                                                disabled title="Chọn ngày/giờ hợp lệ và khả dụng để đặt">Đặt dịch vụ</button>
                                    </div>
                                </div>
                            </div>
                        </form>
                    </div>
                    <% } %>
                </div>
                <% }%>

                <div class="flex flex-col md:flex-row md:items-center md:justify-between border-t pt-4">
                    <div class="mt-6 space-x-3">
                        <a href="<%= request.getContextPath()%>/spa-booking?action=history"
                           class="inline-block px-6 py-3 rounded font-semibold transition-all duration-300"
                           style="background: var(--card-bg-alt); color: var(--text); border: 2px solid rgba(111, 213, 221, 0.3); border-radius: var(--border-radius-small); text-decoration: none; font-family: 'Quicksand', sans-serif;">
                            📅 Xem lịch sử đặt lịch Spa
                        </a>
                        <a href="<%= request.getContextPath()%>/spa-service.jsp" 
                           class="inline-block px-6 py-3 rounded font-semibold transition-all duration-300"
                           style="background: linear-gradient(135deg, var(--accent), var(--accent-pink)); color: white; border-radius: var(--border-radius-small); box-shadow: var(--shadow-button); text-decoration: none; font-family: 'Quicksand', sans-serif;">
                            ⬅️ Tiếp tục chọn dịch vụ Spa
                        </a>
                    </div>
                    <div class="text-right mt-4 md:mt-6">
                        <div class="text-gray-500 text-sm">Tổng thời gian: <%= totalDuration%> phút</div>
                        <div class="text-gray-500 text-sm">Tổng cộng:</div>
                        <div class="text-2xl font-bold text-green-700" id="cart-total"><%= String.format("%.0f", totalPrice)%>₫</div>
                        <div class="text-xs text-gray-500 mt-1">Lưu ý: Mỗi dịch vụ có form đặt lịch riêng ngay bên dưới.</div>
                    </div>
                </div>
            </div>
            <% }%>
        </div>

        <!-- Review Section - Giống Lazada/Shopee -->
        <div class="mx-auto max-w-6xl mt-8 px-4 py-6 rounded-md shadow-md" style="background: var(--card-bg); border-radius: var(--border-radius); box-shadow: var(--shadow-light);">
            <div class="mb-6">
                <h2 class="text-2xl font-bold text-gray-800 flex items-center">
                    <i class="fas fa-star text-yellow-400 mr-2"></i>
                    Đánh giá dịch vụ Spa
                </h2>
                <p class="text-gray-600 mt-1">Chia sẻ trải nghiệm của bạn về dịch vụ Spa</p>
            </div>


            <!-- Reviews List by Service -->
            <% if (spaServices != null && !spaServices.isEmpty()) { %>
            <div class="space-y-6">
                <% for (PetServiceModel service : spaServices) { %>
                <div class="service-reviews bg-white rounded-lg border border-gray-200 p-6" data-service-id="<%= service.getServiceId() %>">
                    <div class="flex items-center justify-between mb-4">
                        <h4 class="text-lg font-semibold text-gray-800">
                            <i class="fas fa-spa text-blue-500 mr-2"></i>
                            <%= service.getName() %>
                        </h4>
                        <div class="flex items-center">
                            <span id="avg-rating-<%= service.getServiceId() %>" class="text-sm text-gray-600"></span>
                        </div>
                    </div>
                    
                    <div id="reviews-list-<%= service.getServiceId() %>" class="space-y-4">
                        <!-- Reviews will be loaded via AJAX -->
                        <div class="text-center py-8 text-gray-500">
                            <i class="fas fa-spinner fa-spin text-2xl mb-2"></i>
                            <p>Đang tải đánh giá...</p>
                        </div>
                    </div>
                </div>
                <% } %>
            </div>
            <% } else { %>
            <div class="text-center py-12 text-gray-500">
                <i class="fas fa-comment-slash text-4xl mb-4"></i>
                <p>Chưa có dịch vụ nào trong giỏ hàng để xem đánh giá</p>
            </div>
            <% } %>
        </div>

        <!-- Modal for viewing boarding details -->
        <div id="viewBoardingModal" class="fixed inset-0 bg-gray-600 bg-opacity-50 overflow-y-auto h-full w-full hidden z-50">
            <div class="relative top-20 mx-auto p-5 border w-96 shadow-lg rounded-md bg-white">
                <div class="mt-3">
                    <div class="flex items-center justify-between mb-4">
                        <h3 class="text-lg font-bold text-gray-900">🏠 Chi tiết lưu trú</h3>
                        <button onclick="closeViewModal()" class="text-gray-400 hover:text-gray-600">
                            <i class="fas fa-times"></i>
                        </button>
                    </div>
                    <div id="viewBoardingContent" class="space-y-3">
                        <!-- Content will be populated by JavaScript -->
                    </div>
                    <div class="mt-6 text-center">
                        <button onclick="closeViewModal()" class="bg-gray-500 text-white px-4 py-2 rounded hover:bg-gray-600">
                            Đóng
                        </button>
                    </div>
                </div>
            </div>
        </div>

        <!-- Modal for editing boarding details -->
        <div id="editBoardingModal" class="fixed inset-0 bg-gray-600 bg-opacity-50 overflow-y-auto h-full w-full hidden z-50">
            <div class="relative top-10 mx-auto p-5 border w-96 shadow-lg rounded-md bg-white max-h-screen overflow-y-auto">
                <div class="mt-3">
                    <div class="flex items-center justify-between mb-4">
                        <h3 class="text-lg font-bold text-gray-900">✏️ Sửa thông tin lưu trú</h3>
                        <button onclick="closeEditModal()" class="text-gray-400 hover:text-gray-600">
                            <i class="fas fa-times"></i>
                        </button>
                    </div>
                    <form id="editBoardingForm" onsubmit="saveBoardingDetails(event, this.dataset.serviceId)">
                        <div id="editBoardingContent" class="space-y-4">
                            <!-- Content will be populated by JavaScript -->
                        </div>
                        <div class="mt-6 flex space-x-3">
                            <button type="submit" class="flex-1 bg-green-500 text-white px-4 py-2 rounded hover:bg-green-600">
                                💾 Lưu thay đổi
                            </button>
                            <button type="button" onclick="closeEditModal()" class="flex-1 bg-gray-500 text-white px-4 py-2 rounded hover:bg-gray-600">
                                Hủy
                            </button>
                        </div>
                    </form>
                </div>
            </div>
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
            
            // View boarding details
            function viewBoardingDetails(serviceId) {
                // Lấy thông tin boarding details từ session
                const boardingDetails = getBoardingDetailsFromSession(serviceId);
                if (!boardingDetails) {
                    alert('Không tìm thấy thông tin chi tiết');
                    return;
                }
                
                // Populate view modal
                const content = `
                    <div class="space-y-2">
                        <div><strong>Loại phòng:</strong> ${boardingDetails.roomType}</div>
                        <div><strong>Giá/ngày:</strong> ${boardingDetails.pricePerDay.toLocaleString()}₫</div>
                        <div><strong>Số ngày:</strong> ${boardingDetails.boardingDays} ngày</div>
                        <div><strong>Ngày nhận:</strong> ${boardingDetails.checkInDate}</div>
                        <div><strong>Ngày trả:</strong> ${boardingDetails.checkOutDate}</div>
                        <div><strong>Giờ nhận:</strong> ${boardingDetails.checkInTime}</div>
                        <div><strong>Giờ trả:</strong> ${boardingDetails.checkOutTime}</div>
                        <div><strong>Thú cưng:</strong> ${boardingDetails.petInfo}</div>
                        <div><strong>SĐT khẩn cấp 1:</strong> ${boardingDetails.emergencyPhone1}</div>
                        <div><strong>SĐT khẩn cấp 2:</strong> ${boardingDetails.emergencyPhone2 || 'Chưa cung cấp'}</div>
                        <div><strong>Ghi chú đặc biệt:</strong> ${boardingDetails.specialNotes || 'Không có'}</div>
                    </div>
                `;
                
                document.getElementById('viewBoardingContent').innerHTML = content;
                document.getElementById('viewBoardingModal').classList.remove('hidden');
            }
            
            // Edit boarding details
            function editBoardingDetails(serviceId) {
                // Lấy thông tin boarding details từ session
                const boardingDetails = getBoardingDetailsFromSession(serviceId);
                if (!boardingDetails) {
                    alert('Không tìm thấy thông tin chi tiết');
                    return;
                }
                
                // Populate edit form
                const content = `
                    <input type="hidden" name="serviceId" value="${serviceId}">
                    <input type="hidden" name="pricePerDay" value="${boardingDetails.pricePerDay}">
                    
                    <div>
                        <label class="block text-sm font-medium text-gray-700">Ngày nhận:</label>
                        <input type="date" name="checkInDate" value="${boardingDetails.checkInDate}" required
                               class="w-full border rounded px-3 py-2">
                    </div>
                    
                    <div>
                        <label class="block text-sm font-medium text-gray-700">Ngày trả:</label>
                        <input type="date" name="checkOutDate" value="${boardingDetails.checkOutDate}" required
                               class="w-full border rounded px-3 py-2">
                    </div>
                    
                    <div>
                        <label class="block text-sm font-medium text-gray-700">Tên thú cưng:</label>
                        <input type="text" name="petInfo" value="${boardingDetails.petInfo}" required
                               class="w-full border rounded px-3 py-2">
                    </div>
                    
                    <div>
                        <label class="block text-sm font-medium text-gray-700">SĐT khẩn cấp 1:</label>
                        <input type="tel" name="emergencyPhone1" value="${boardingDetails.emergencyPhone1}" required
                               class="w-full border rounded px-3 py-2">
                    </div>
                    
                    <div>
                        <label class="block text-sm font-medium text-gray-700">SĐT khẩn cấp 2:</label>
                        <input type="tel" name="emergencyPhone2" value="${boardingDetails.emergencyPhone2 || ''}"
                               class="w-full border rounded px-3 py-2">
                    </div>
                    
                    <div>
                        <label class="block text-sm font-medium text-gray-700">Ghi chú đặc biệt:</label>
                        <textarea name="specialNotes" rows="3"
                                  class="w-full border rounded px-3 py-2">${boardingDetails.specialNotes || ''}</textarea>
                    </div>
                `;
                
                document.getElementById('editBoardingContent').innerHTML = content;
                document.getElementById('editBoardingForm').dataset.serviceId = serviceId;
                document.getElementById('editBoardingModal').classList.remove('hidden');
            }
            
            // Close modals
            function closeViewModal() {
                document.getElementById('viewBoardingModal').classList.add('hidden');
            }
            
            function closeEditModal() {
                document.getElementById('editBoardingModal').classList.add('hidden');
            }
            
            // Get boarding details from session via AJAX
            function getBoardingDetailsFromSession(serviceId) {
                let boardingDetails = null;
                $.ajax({
                    url: '<%= request.getContextPath()%>/spa-booking',
                    type: 'GET',
                    data: {
                        action: 'get-boarding-details',
                        serviceId: serviceId
                    },
                    async: false, // Synchronous để có thể return kết quả
                    success: function(response) {
                        if (response.success) {
                            boardingDetails = response.boardingDetails;
                        }
                    },
                    error: function() {
                        console.error('Lỗi khi lấy thông tin boarding details');
                    }
                });
                return boardingDetails;
            }
            
            // Save boarding details
            function saveBoardingDetails(event, serviceId) {
                event.preventDefault();
                
                const formData = new FormData(event.target);
                formData.append('action', 'update-boarding-details');
                formData.append('serviceId', serviceId);
                
                $.ajax({
                    url: '<%= request.getContextPath()%>/spa-booking',
                    type: 'POST',
                    data: formData,
                    processData: false,
                    contentType: false,
                    success: function(response) {
                        if (response.success) {
                            alert('✅ Cập nhật thông tin thành công!');
                            closeEditModal();
                            location.reload(); // Reload để cập nhật giá
                        } else {
                            alert('❌ Lỗi: ' + response.message);
                        }
                    },
                    error: function() {
                        alert('❌ Có lỗi xảy ra khi cập nhật thông tin');
                    }
                });
            }

            function updateCartTotal() {
                $.get('<%= request.getContextPath()%>/spa-booking', {
                    action: 'total'
                }, function (total) {
                    $('#cart-total').text(parseFloat(total).toFixed(0) + '₫');
                });
            }
            
            // Đã xóa hàm updateQuantity - không còn cho phép thay đổi số lượng
            
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
                // Đã xóa event listener cho quantity-input - không còn cho phép thay đổi số lượng
                // Giá sẽ tự động cập nhật khi chọn/bỏ chọn pet checkbox
                
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
                
                // Realtime check availability when date/hour/minute changes
                function triggerAvailabilityCheck() {
                    const d = document.querySelector('input[name="appointmentDate"]').value;
                    const h = document.querySelector('input[name="appointmentHour"]').value;
                    const m = document.querySelector('input[name="appointmentMinute"]').value;
                    const hint = document.getElementById('availabilityHint');
                    if (!d || h === '' || m === '') { hint.textContent = ''; return; }
                    const hh = String(h).padStart(2,'0');
                    const mm = String(m).padStart(2,'0');
                    hint.textContent = 'Đang kiểm tra khả dụng...';
                    $.post('<%= request.getContextPath()%>/spa-booking', {
                        action: 'check-availability',
                        appointmentDate: d,
                        appointmentTime: hh + ':' + mm
                    }, function(res){
                        if (res && res.success) {
                            hint.textContent = '✅ Khung giờ khả dụng';
                            hint.className = 'text-sm text-green-600';
                        } else {
                            hint.textContent = '❌ Khung giờ không khả dụng hoặc ngoài giờ làm việc 08:00-12:00 và 13:00-17:00';
                            hint.className = 'text-sm text-red-600';
                        }
                    }, 'json');
                }
                $(document).on('change input', 'input[name="appointmentDate"], input[name="appointmentHour"], input[name="appointmentMinute"]', triggerAvailabilityCheck);

                // Form validation function
                window.validateAppointmentForm = function() {
                    const appointmentDate = document.querySelector('input[name="appointmentDate"]').value;
                    const hEl = document.querySelector('input[name="appointmentHour"]');
                    const mEl = document.querySelector('input[name="appointmentMinute"]');
                    const h = parseInt(hEl.value, 10);
                    const m = parseInt(mEl.value, 10);
                    
                    if (!appointmentDate || Number.isNaN(h) || Number.isNaN(m)) {
                        alert('Vui lòng chọn đầy đủ ngày và giờ hẹn!');
                        return false;
                    }
                    // Kiểm tra giờ hẹn trong khoảng hợp lệ (8h-12h hoặc 13h-17h)
                    if (!((h >= 8 && h < 12) || (h >= 13 && h < 17)) || m < 0 || m > 59) {
                        alert('Giờ hẹn phải trong khoảng 08:00-12:00 hoặc 13:00-17:00 và phút 00-59');
                        return false;
                    }
                    
                    // Check if appointment is in the past
                    const hh = String(h).padStart(2,'0');
                    const mm = String(m).padStart(2,'0');
                    const appointmentDateTime = new Date(appointmentDate + ' ' + hh + ':' + mm);
                    const now = new Date();
                    
                    if (appointmentDateTime <= now) {
                        alert('Không thể đặt lịch cho thời gian đã qua. Vui lòng chọn ngày và giờ trong tương lai!');
                        return false;
                    }

                    // Gắn appointmentTime trước khi submit (server đang nhận appointmentTime)
                    let timeHidden = document.querySelector('input[name="appointmentTime"]');
                    if (!timeHidden) {
                        timeHidden = document.createElement('input');
                        timeHidden.type = 'hidden';
                        timeHidden.name = 'appointmentTime';
                        document.forms[0].appendChild(timeHidden);
                    }
                    timeHidden.value = hh + ':' + mm;
                    
                    return true;
                };

                // Load pets cho per-service checkboxes
                $.post('<%= request.getContextPath()%>/spa-booking', { action: 'get-customer-pets' }, function(pets){
                    if (!Array.isArray(pets) || pets.length === 0) {
                        $('[id^="pet-checkboxes-"]').html('<p class="text-sm text-gray-500">Bạn chưa có thú cưng nào. Vui lòng thêm thú cưng trước khi đặt dịch vụ.</p>');
                        return;
                    }
                    
                    // Tạo checkbox cho mỗi service
                    $('[id^="pet-checkboxes-"]').each(function(){
                        var checkboxContainer = this;
                        var match = checkboxContainer.id.match(/pet-checkboxes-(\d+)/);
                        if (!match) return;
                        
                        var serviceId = match[1];
                        // Lấy giá từ text "Giá mỗi pet: XXX₫"
                        var priceText = $('#pet-count-' + serviceId).closest('.spa-actions').find('.spa-price').text();
                        var servicePrice = parseFloat(priceText.replace(/[^\d.]/g, '')) || 0;
                        
                        var html = '';
                        for (var i=0; i<pets.length; i++) {
                            var p = pets[i];
                            html += '<label class="flex items-center space-x-2 py-1 cursor-pointer hover:bg-gray-50 px-2 rounded">';
                            html += '<input type="checkbox" name="pet-' + serviceId + '" value="' + p.id + '" ';
                            html += 'data-pet-name="' + p.petName + '" data-pet-species="' + p.species + '" ';
                            html += 'onchange="updatePetPrice(' + serviceId + ', ' + servicePrice + ')" ';
                            html += 'class="pet-checkbox w-4 h-4 text-blue-600 border-gray-300 rounded focus:ring-blue-500">';
                            html += '<span class="text-sm text-gray-700">' + p.petName + ' (' + p.species + ')</span>';
                            html += '</label>';
                        }
                        checkboxContainer.innerHTML = html;
                        
                        // Kiểm tra enable button sau khi load
                        setTimeout(function() {
                            if (typeof checkAndEnableBookButton === 'function') {
                                checkAndEnableBookButton(serviceId);
                            }
                        }, 100);
                    });
                }, 'json');
                
                // Hàm cập nhật giá khi chọn/bỏ chọn pet
                window.updatePetPrice = function(serviceId, pricePerPet) {
                    var checkboxes = document.querySelectorAll('input[name="pet-' + serviceId + '"]:checked');
                    var selectedCount = checkboxes.length;
                    var totalPrice = pricePerPet * selectedCount;
                    
                    // Cập nhật hiển thị
                    var petCountEl = document.getElementById('pet-count-' + serviceId);
                    var totalPriceEl = document.getElementById('item-total-' + serviceId);
                    
                    if (selectedCount > 0) {
                        petCountEl.textContent = selectedCount + ' thú cưng';
                        petCountEl.className = 'spa-qty text-sm text-green-600 whitespace-nowrap font-semibold';
                    } else {
                        petCountEl.textContent = 'Chọn thú cưng';
                        petCountEl.className = 'spa-qty text-sm text-gray-500 whitespace-nowrap';
                    }
                    
                    totalPriceEl.textContent = totalPrice.toLocaleString('vi-VN') + '₫';
                    
                    // Cập nhật tổng tiền cart
                    updateCartTotal();
                    
                    // Kiểm tra enable button
                    if (typeof checkAndEnableBookButton === 'function') {
                        checkAndEnableBookButton(serviceId);
                    }
                };
                
                // Hàm cập nhật tổng tiền cart
                function updateCartTotal() {
                    var total = 0;
                    $('[id^="item-total-"]').each(function() {
                        var priceText = $(this).text().replace(/[^\d.]/g, '');
                        total += parseFloat(priceText) || 0;
                    });
                    $('#cart-total').text(total.toLocaleString('vi-VN') + '₫');
                }

                // Hàm kiểm tra điều kiện và enable/disable nút đặt dịch vụ + cập nhật validation message
                function checkAndEnableBookButton(serviceId) {
                    var dateInput = document.querySelector('input[name="date-' + serviceId + '"]');
                    var hourSelect = document.getElementById('hour-' + serviceId);
                    var minuteSelect = document.getElementById('minute-' + serviceId);
                    var petCheckboxes = document.querySelectorAll('input[name="pet-' + serviceId + '"]:checked');
                    var btn = document.getElementById('btn-book-' + serviceId);
                    var availSpan = document.getElementById('avail-' + serviceId);
                    var selectedTimeInput = document.getElementById('selected-time-' + serviceId);
                    
                    if (!btn) return;
                    
                    var hasDate = dateInput && dateInput.value;
                    var hasHour = hourSelect && hourSelect.value;
                    var hasMinute = minuteSelect && minuteSelect.value;
                    var hasTime = hasHour && hasMinute;
                    var hasPet = petCheckboxes.length > 0;
                    var missing = [];
                    
                    // Cập nhật hidden time input từ hour và minute
                    if (hasHour && hasMinute && selectedTimeInput) {
                        selectedTimeInput.value = hourSelect.value + ':' + minuteSelect.value + ':00';
                    } else if (selectedTimeInput) {
                        selectedTimeInput.value = '';
                    }
                    
                    // Cập nhật validation message
                    if (availSpan) {
                        if (hasDate && hasTime && hasPet) {
                            availSpan.textContent = '✅ Đã sẵn sàng để đặt dịch vụ (' + petCheckboxes.length + ' thú cưng)';
                            availSpan.className = 'text-xs text-green-600';
                        } else {
                            if (!hasDate) missing.push('ngày');
                            if (!hasHour) missing.push('giờ');
                            if (!hasMinute) missing.push('phút');
                            if (!hasPet) missing.push('thú cưng');
                            
                            if (missing.length > 0) {
                                availSpan.textContent = 'Vui lòng chọn: ' + missing.join(', ');
                                availSpan.className = 'text-xs text-red-600';
                            } else {
                                availSpan.textContent = '';
                                availSpan.className = 'text-sm text-gray-600';
                            }
                        }
                    }
                    
                    // Enable/disable button
                    if (hasDate && hasTime && hasPet) {
                        btn.disabled = false;
                        btn.classList.remove('opacity-50', 'cursor-not-allowed');
                        btn.title = 'Đặt dịch vụ';
                    } else {
                        btn.disabled = true;
                        btn.classList.add('opacity-50', 'cursor-not-allowed');
                        btn.title = 'Vui lòng chọn: ' + missing.join(', ');
                    }
                }
                
                // Gắn sự kiện change cho date, hour, minute và pet selects
                function initTimePickers() {
                    var dateInputs = document.querySelectorAll('input[type="date"][name^="date-"]');
                    dateInputs.forEach(function(dateInput) {
                        var name = dateInput.name;
                        var match = name.match(/date-(\d+)/);
                        if (!match) return;
                        
                        var serviceId = match[1];
                        var hourSelect = document.getElementById('hour-' + serviceId);
                        var minuteSelect = document.getElementById('minute-' + serviceId);
                        var petSelect = document.querySelector('select[name="pet-' + serviceId + '"]');
                        
                        if (dateInput) {
                            dateInput.addEventListener('change', function() {
                                checkAndEnableBookButton(serviceId);
                            });
                        }
                        
                        if (hourSelect) {
                            hourSelect.addEventListener('change', function() {
                                checkAndEnableBookButton(serviceId);
                            });
                        }
                        
                        if (minuteSelect) {
                            minuteSelect.addEventListener('change', function() {
                                checkAndEnableBookButton(serviceId);
                            });
                        }
                        
                        if (petSelect) {
                            petSelect.addEventListener('change', function() {
                                checkAndEnableBookButton(serviceId);
                            });
                        }
                    });
                }
                
                // Khởi tạo ngay khi script chạy và sau khi DOM ready
                if (document.readyState === 'loading') {
                    document.addEventListener('DOMContentLoaded', initTimePickers);
                } else {
                    initTimePickers();
                }

                // Check single availability
                window.checkSingleAvailability = function(serviceId){
                    // Kiểm tra lại validation
                    if (typeof checkAndEnableBookButton === 'function') {
                        checkAndEnableBookButton(serviceId);
                    }
                };

                // Submit single service
                window.submitSingleService = function(e, serviceId){
                    e.preventDefault();
                    const d = document.querySelector('input[name="date-' + serviceId + '"]').value;
                    const hourSelect = document.getElementById('hour-' + serviceId);
                    const minuteSelect = document.getElementById('minute-' + serviceId);
                    const petCheckboxes = document.querySelectorAll('input[name="pet-' + serviceId + '"]:checked');
                    const note = document.querySelector('input[name="note-' + serviceId + '"]').value || '';
                    
                    if (!d || !hourSelect || !minuteSelect || !hourSelect.value || !minuteSelect.value || petCheckboxes.length === 0) { 
                        alert('Vui lòng nhập đủ ngày, giờ, phút và chọn ít nhất 1 thú cưng'); 
                        return false; 
                    }
                    
                    var h = parseInt(hourSelect.value, 10);
                    var m = parseInt(minuteSelect.value, 10);
                    
                    // Đã xóa tất cả validation thời gian - cho phép đặt bất kỳ giờ nào
                    if (m < 0 || m > 59) { 
                        alert('Phút phải từ 00 đến 59'); 
                        return false; 
                    }
                    
                    var hh = hourSelect.value.padStart(2, '0');
                    var mm = minuteSelect.value.padStart(2, '0');
                    var payMethod = document.querySelector('select[name="payment-' + serviceId + '"]').value || 'payos';
                    
                    // Lấy danh sách pet IDs đã chọn
                    var petIds = [];
                    var petNames = [];
                    petCheckboxes.forEach(function(checkbox) {
                        petIds.push(checkbox.value);
                        petNames.push(checkbox.dataset.petName + ' (' + checkbox.dataset.petSpecies + ')');
                    });
                    
                    console.log('Submitting booking request:', {
                        action: 'create-single-booking',
                        serviceId: serviceId,
                        quantity: petIds.length,
                        petIds: petIds.join(','),
                        paymentMethod: payMethod
                    });
                    
                    $.ajax({
                        url: '<%= request.getContextPath()%>/spa-booking',
                        type: 'POST',
                        data: {
                            action: 'create-single-booking',
                            serviceId: serviceId,
                            quantity: petIds.length, // Số lượng = số pet được chọn
                            petIds: petIds.join(','), // Danh sách pet IDs
                            note: note,
                            paymentMethod: payMethod,
                            appointmentDate: d,
                            appointmentTime: hh + ':' + mm
                        },
                        dataType: 'json',
                        success: function(res){
                            console.log('Booking response received:', res);
                            
                            if (res && res.success) {
                                if (res.payment === 'payos' && res.url) {
                                    console.log('Redirecting to PayOS URL:', res.url);
                                    if (res.url && res.url !== 'null' && res.url !== 'undefined') {
                                        window.location.href = res.url;
                                    } else {
                                        alert('❌ Link thanh toán PayOS không hợp lệ. Vui lòng thử lại.');
                                        console.error('Invalid PayOS URL:', res.url);
                                    }
                                    return;
                                }
                                alert('✅ Đặt dịch vụ thành công!');
                                window.location.href = '<%= request.getContextPath()%>/spa-booking?action=history';
                            } else {
                                var errorMsg = res && res.message ? res.message : 'Không thể đặt dịch vụ. Vui lòng thử lại hoặc liên hệ hỗ trợ.';
                                alert('❌ ' + errorMsg);
                                console.error('Booking error:', res);
                            }
                        },
                        error: function(xhr, status, error) {
                            console.error('AJAX error:', {
                                status: status,
                                error: error,
                                responseText: xhr.responseText,
                                statusCode: xhr.status
                            });
                            
                            var errorMsg = 'Lỗi kết nối: ' + error;
                            try {
                                var jsonResponse = JSON.parse(xhr.responseText);
                                if (jsonResponse && jsonResponse.message) {
                                    errorMsg = jsonResponse.message;
                                }
                            } catch (e) {
                                // Không phải JSON, giữ nguyên errorMsg
                            }
                            
                            alert('❌ ' + errorMsg + '. Vui lòng thử lại.');
                        }
                    });
                    return false;
                };

                // Tự kiểm tra + cập nhật tóm tắt khi đổi date/hour/minute/pet checkbox
                $(document).on('change input', 'input[name^="date-"], select[id^="hour-"], select[id^="minute-"]', function(){
                    var form = this.closest('form');
                    if (!form) return;
                    var sid = form.getAttribute('data-service-id');
                    if (!sid) return;
                    updateSummary(sid, form);
                });
                
                // Event listener riêng cho pet checkbox
                $(document).on('change', 'input[type="checkbox"][name^="pet-"]', function(){
                    var checkbox = this;
                    var match = checkbox.name.match(/pet-(\d+)/);
                    if (!match) return;
                    var sid = match[1];
                    var form = checkbox.closest('form');
                    if (!form) return;
                    updateSummary(sid, form);
                });
                
                // Hàm cập nhật summary
                function updateSummary(sid, form) {
                    var d = form.querySelector('input[name="date-' + sid + '"]').value || 'Chưa chọn ngày';
                    var hourSelect = document.getElementById('hour-' + sid);
                    var minuteSelect = document.getElementById('minute-' + sid);
                    var t = (hourSelect && hourSelect.value && minuteSelect && minuteSelect.value) 
                            ? (hourSelect.value + ':' + minuteSelect.value) 
                            : 'Chưa chọn giờ';
                    // Lấy danh sách pet đã chọn từ checkbox
                    var petCheckboxes = form.querySelectorAll('input[name="pet-' + sid + '"]:checked');
                    var petNames = [];
                    petCheckboxes.forEach(function(cb) {
                        var petName = cb.dataset.petName || '';
                        var petSpecies = cb.dataset.petSpecies || '';
                        if (petName) {
                            petNames.push(petName + (petSpecies ? ' (' + petSpecies + ')' : ''));
                        }
                    });
                    var p = petNames.length > 0 ? petNames.join(', ') : 'Chưa chọn thú cưng';
                    var elDate = form.querySelector('.summary-date-' + sid);
                    var elTime = form.querySelector('.summary-time-' + sid);
                    var elPet  = form.querySelector('.summary-pet-' + sid);
                    if (elDate) elDate.textContent = d;
                    if (elTime) elTime.textContent = t;
                    if (elPet)  elPet.textContent  = p;
                    // Auto check availability when all fields present
                    if (sid) checkSingleAvailability(parseInt(sid,10));
                }
            });

            // ====== REVIEW FUNCTIONALITY ======
            // (Form comment đã được xóa, chỉ giữ lại phần load reviews)

            // Load reviews for a service
            function loadServiceReviews(serviceId) {
                const $container = $(`#reviews-list-${serviceId}`);
                $container.html('<div class="text-center py-4"><i class="fas fa-spinner fa-spin text-xl"></i></div>');

                $.get('<%= request.getContextPath()%>/spa-booking', {
                    action: 'get-service-reviews',
                    serviceId: serviceId,
                    limit: 10
                }, function(data) {
                    if (data && data.reviews && data.reviews.length > 0) {
                        let html = '';
                        let totalRating = 0;
                        
                        data.reviews.forEach(function(review) {
                            totalRating += review.rating;
                            const date = new Date(review.createdAt).toLocaleDateString('vi-VN');
                            const stars = '★'.repeat(review.rating) + '☆'.repeat(5 - review.rating);
                            
                            html += `
                                <div class="review-item border-b border-gray-200 pb-4 last:border-0">
                                    <div class="flex items-start space-x-4">
                                        <div class="flex-shrink-0">
                                            <div class="w-12 h-12 bg-gradient-to-br from-blue-400 to-purple-400 rounded-full flex items-center justify-center text-white font-bold text-lg">
                                                ${(review.customerName || 'Khách').charAt(0).toUpperCase()}
                                            </div>
                                        </div>
                                        <div class="flex-1">
                                            <div class="flex items-center justify-between mb-2">
                                                <div>
                                                    <div class="font-semibold text-gray-800">${review.customerName || 'Khách hàng'}</div>
                                                    <div class="text-yellow-400 text-lg">${stars}</div>
                                                </div>
                                                <div class="text-sm text-gray-500">${date}</div>
                                            </div>
                                            ${review.comment ? `<p class="text-gray-700 mt-2">${review.comment}</p>` : ''}
                                        </div>
                                    </div>
                                </div>
                            `;
                        });
                        
                        const avgRating = (totalRating / data.reviews.length).toFixed(1);
                        $(`#avg-rating-${serviceId}`).html(
                            `<span class="text-yellow-400 text-xl">★</span> ` +
                            `<span class="font-semibold">${avgRating}</span> ` +
                            `<span class="text-gray-500">(${data.reviews.length} đánh giá)</span>`
                        );
                        
                        $container.html(html);
                    } else {
                        $container.html('<div class="text-center py-8 text-gray-500"><i class="fas fa-comment-slash text-3xl mb-2"></i><p>Chưa có đánh giá nào</p></div>');
                        $(`#avg-rating-${serviceId}`).html('<span class="text-gray-500">Chưa có đánh giá</span>');
                    }
                }, 'json').fail(function() {
                    $container.html('<div class="text-center py-8 text-red-500"><i class="fas fa-exclamation-triangle text-xl mb-2"></i><p>Lỗi khi tải đánh giá</p></div>');
                });
            }

            // Load reviews for all services in cart on page load
            $(document).ready(function() {
                $('.service-reviews').each(function() {
                    const serviceId = $(this).data('service-id');
                    if (serviceId) {
                        loadServiceReviews(serviceId);
                    }
                });
            });
        </script>

        <!-- Chatbox removed as requested -->
    </body>
</html>