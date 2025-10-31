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
                        int quantity = spaCart.get(service.getServiceId());
                        BigDecimal subtotal = service.getPrice().multiply(BigDecimal.valueOf(quantity));
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
                        <div class="spa-price font-semibold text-blue-600 whitespace-nowrap"><%= String.format("%.0f", service.getPrice())%>₫</div>
                        <% if (isBoardingService) { %>
                            <!-- Boarding services không cho phép thay đổi số lượng -->
                            <div class="spa-qty text-sm text-gray-500 whitespace-nowrap">x1</div>
                        <% } else { %>
                            <!-- Spa services cho phép thay đổi số lượng -->
                            <input type="number" min="1" value="<%= quantity%>" 
                                   data-service-id="<%= serviceId%>" class="quantity-input spa-qty border rounded py-1 px-2">
                        <% } %>
                        <div class="spa-total font-bold text-green-600 whitespace-nowrap" id="item-total-<%= serviceId%>"><%= String.format("%.0f", subtotal)%>₫</div>
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
                              data-service-id="<%= serviceId%>" data-quantity="<%= quantity%>"
                              onsubmit="return submitSingleService(event,<%= serviceId%>, <%= quantity%>)">
                            <!-- Header bar removed per request; service name already shown near icon -->
                            <div class="grid grid-cols-1 md:grid-cols-3 gap-6 p-5">
                                <div>
                                    <label class="block text-sm font-medium text-slate-700 mb-1">Ngày</label>
                                    <input type="date" name="date-<%= serviceId%>" class="w-full border border-slate-300 rounded-lg px-3 h-10 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500" min="<%= java.time.LocalDate.now().toString() %>">
                                </div>
                                <div>
                                    <label class="block text-sm font-medium text-slate-700 mb-1">Giờ (08:00-18:00)</label>
                                    <input type="time" name="time-<%= serviceId%>" class="w-full border border-slate-300 rounded-lg px-3 h-10 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500" min="08:00" max="18:00" step="300" placeholder="08:00">
                                    <p class="text-xs text-slate-500 mt-1">Khung giờ mở cửa 08:00 - 18:00</p>
                                </div>
                                <div>
                                    <label class="block text-sm font-medium text-slate-700 mb-1">Thú cưng</label>
                                    <select name="pet-<%= serviceId%>" class="w-full border border-slate-300 rounded-lg px-3 h-10 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500">
                                        <option value="">-- Chọn thú cưng --</option>
                                    </select>
                                </div>
                                <div>
                                    <label class="block text-sm font-medium text-slate-700 mb-1">Phương thức thanh toán</label>
                                    <select name="payment-<%= serviceId%>" class="w-full border border-slate-300 rounded-lg px-3 h-10 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500">
                                        <option value="cash">Tiền mặt</option>
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
                                                onclick="checkSingleAvailability(<%= serviceId%>, <%= quantity%>)" title="Kiểm tra trống lịch">Kiểm tra</button>
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
                            hint.textContent = '❌ Khung giờ không khả dụng hoặc ngoài giờ 08:00-18:00';
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
                    if (h < 8 || h > 18 || m < 0 || m > 59) {
                        alert('Giờ hẹn phải từ 08-18h và phút 00-59');
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

                // Load pets cho per-service selects + auto chọn pet đầu tiên
                $.post('<%= request.getContextPath()%>/spa-booking', { action: 'get-customer-pets' }, function(pets){
                    if (!Array.isArray(pets)) return;
                    var options = '<option value="">-- Chọn thú cưng --</option>';
                    for (var i=0;i<pets.length;i++) {
                        var p = pets[i];
                        options += '<option value="' + p.id + '">' + p.petName + ' (' + p.species + ')</option>';
                    }
                    $('select[name^="pet-"]').each(function(){
                        this.innerHTML = options;
                        if (pets.length > 0) this.value = String(pets[0].id);
                    });
                }, 'json');

                // Check single availability
                window.checkSingleAvailability = function(serviceId, quantity){
                    const d = document.querySelector('input[name="date-' + serviceId + '"]').value;
                    const t = document.querySelector('input[name="time-' + serviceId + '"]').value;
                    const el = document.getElementById('avail-' + serviceId);
                    if (!d || !t) { el.textContent = 'Vui lòng nhập đủ ngày/giờ'; el.className='text-xs text-red-600'; return; }
                    const parts = t.split(':');
                    const hh = parts[0];
                    const mm = parts[1];
                    el.textContent = 'Đang kiểm tra...'; el.className='text-xs text-gray-500';
                    $.post('<%= request.getContextPath()%>/spa-booking', {
                        action: 'check-single-availability',
                        serviceId: serviceId,
                        quantity: quantity,
                        appointmentDate: d,
                        appointmentTime: hh + ':' + mm
                    }, function(res){
                        var btn = document.getElementById('btn-book-' + serviceId);
                        if (res && res.success) {
                            el.textContent = '✅ Khả dụng';
                            el.className='text-xs text-green-600';
                            if (btn) { btn.disabled = false; btn.classList.remove('opacity-50','cursor-not-allowed'); }
                        } else {
                            el.textContent = '❌ Không khả dụng hoặc ngoài giờ';
                            el.className='text-xs text-red-600';
                            if (btn) { btn.disabled = true; btn.classList.add('opacity-50','cursor-not-allowed'); }
                        }
                    }, 'json');
                };

                // Submit single service
                window.submitSingleService = function(e, serviceId, quantity){
                    e.preventDefault();
                    const d = document.querySelector('input[name="date-' + serviceId + '"]').value;
                    const t = document.querySelector('input[name="time-' + serviceId + '"]').value;
                    const pet = document.querySelector('select[name="pet-' + serviceId + '"]').value;
                    const note = document.querySelector('input[name="note-' + serviceId + '"]').value || '';
                    if (!d || !t || !pet) { alert('Vui lòng nhập đủ ngày/giờ và chọn thú cưng'); return false; }
                    var parts = t.split(':');
                    var h = parseInt(parts[0], 10);
                    var m = parseInt(parts[1], 10);
                    if (h < 8 || h > 18 || m < 0 || m > 59) { alert('Giờ này Spa đã đóng cửa 🕕. Khung 08:00 – 18:00'); return false; }
                    var hh = parts[0];
                    var mm = parts[1];
                    var payMethod = document.querySelector('select[name="payment-' + serviceId + '"]').value || 'cash';
                    $.post('<%= request.getContextPath()%>/spa-booking', {
                        action: 'create-single-booking',
                        serviceId: serviceId,
                        quantity: quantity,
                        petId: pet,
                        note: note,
                        paymentMethod: payMethod,
                        appointmentDate: d,
                        appointmentTime: hh + ':' + mm
                    }, function(res){
                        if (res && res.success) {
                            if (res.payment === 'payos' && res.url) {
                                window.location.href = res.url;
                                return;
                            }
                            alert('✅ Đặt dịch vụ thành công!');
                            window.location.href = '<%= request.getContextPath()%>/spa-booking?action=history';
                        } else {
                            alert('❌ Không thể đặt dịch vụ. Vui lòng chọn thời gian khác.');
                        }
                    }, 'json');
                    return false;
                };

                // Tự kiểm tra + cập nhật tóm tắt khi đổi date/time/pet
                $(document).on('change input', 'input[name^="date-"], input[name^="time-"], select[name^="pet-"]', function(){
                    var form = this.closest('form');
                    if (!form) return;
                    var sid = form.getAttribute('data-service-id');
                    var qty = form.getAttribute('data-quantity');
                    // Update summary preview
                    var d = form.querySelector('input[name="date-' + sid + '"]').value || 'Chưa chọn ngày';
                    var t = form.querySelector('input[name="time-' + sid + '"]').value || 'Chưa chọn giờ';
                    var pSel = form.querySelector('select[name="pet-' + sid + '"]');
                    var p = pSel && pSel.value ? (pSel.options[pSel.selectedIndex].text) : 'Chưa chọn thú cưng';
                    var elDate = form.querySelector('.summary-date-' + sid);
                    var elTime = form.querySelector('.summary-time-' + sid);
                    var elPet  = form.querySelector('.summary-pet-' + sid);
                    if (elDate) elDate.textContent = d;
                    if (elTime) elTime.textContent = t;
                    if (elPet)  elPet.textContent  = p;
                    // Auto check availability when all fields present
                    if (sid && qty) checkSingleAvailability(parseInt(sid,10), parseInt(qty,10));
                });
            });
        </script>

        <!-- Chatbox removed as requested -->
    </body>
</html>