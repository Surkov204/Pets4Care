<%@ page contentType="text/html;charset=UTF-8" language="java" isELIgnored="true" %>
<%@ page import="java.util.*, model.Customer, model.BoardingRoom" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page session="true" %>
<%
    Customer currentUser = (Customer) session.getAttribute("currentUser");
    List<BoardingRoom> boardingRooms = (List<BoardingRoom>) request.getAttribute("boardingRooms");
    String errorMessage = (String) request.getAttribute("errorMessage");
    
    if (boardingRooms == null) boardingRooms = new ArrayList<>();
%>
<html lang="vi">
    <head>
        <meta charset="UTF-8"/>
        <meta name="viewport" content="width=device-width, initial-scale=1"/>
        <title>🏠 Đặt Phòng Lưu Trú - Petcity</title>
        <script src="https://cdn.tailwindcss.com"></script>
        <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.3/css/all.min.css" rel="stylesheet" />
        <link href="https://fonts.googleapis.com/css2?family=Quicksand:wght@300;400;500;600;700&family=Nunito:wght@300;400;500;600;700;800&family=Baloo+2:wght@400;500;600;700;800&display=swap" rel="stylesheet" />
        <link rel="stylesheet" href="../css/homeStyle.css" />
        <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
        <style>
            body { background:#fafafa; font-family: 'Nunito', sans-serif; font-size:15px; line-height:1.6; }
            .btn { transition: background-color .3s ease, box-shadow .3s ease, transform .2s ease; }
            .btn:hover { box-shadow: 0 4px 10px rgba(0,0,0,.08); transform: translateY(-1px); }
        </style>
    </head>
    <body>
        <!-- Top Bar -->
        <header class="bg-white shadow-sm sticky top-0 z-40">
            <div class="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8 flex items-center justify-between h-16">
                <a href="<%= request.getContextPath()%>/home.jsp" class="flex items-center space-x-2">
                    <span class="text-2xl font-bold" style="color: var(--primary);">🏠 Petcity</span>
                </a>
                
                <% if (currentUser != null) { %>
                <div class="flex items-center space-x-4">
                    <a href="<%= request.getContextPath()%>/spa-booking?action=cart" 
                       class="text-gray-700 hover:text-blue-600 px-3 py-2 rounded-md text-sm font-medium">
                        🛒 Giỏ Spa
                    </a>
                    <a href="<%= request.getContextPath()%>/spa-booking?action=history" 
                       class="text-gray-700 hover:text-blue-600 px-3 py-2 rounded-md text-sm font-medium">
                        📋 Lịch sử
                    </a>
                    <div class="relative">
                        <button onclick="toggleUserMenu()" class="flex items-center text-sm font-medium text-gray-700 hover:text-blue-600">
                            <%= currentUser.getName() != null ? currentUser.getName() : "User" %>
                            <svg class="-mr-1 ml-2 h-5 w-5" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" aria-hidden="true">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
                            </svg>
                        </button>
                        <div class="origin-top-right absolute right-0 mt-2 w-56 rounded-md shadow-lg bg-white ring-1 ring-black ring-opacity-5 hidden z-50" id="userMenu">
                            <div class="py-1">
                                <a href="../user/user-info.jsp" class="text-gray-700 block px-4 py-2 text-sm hover:bg-gray-100">👤 Thông tin tài khoản</a>
                                <a href="../logout.jsp" class="text-gray-700 block px-4 py-2 text-sm hover:bg-gray-100">🚪 Đăng xuất</a>
                            </div>
                        </div>
                    </div>
                </div>
                <% } else { %>
                <div>
                    <a href="<%= request.getContextPath()%>/login.jsp" class="bg-blue-600 text-white px-4 py-2 rounded-md text-sm font-medium hover:bg-blue-700">
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

            <div class="mb-6">
                <h1 class="text-3xl font-bold text-gray-800 mb-2">🏠 Đặt Phòng Lưu Trú</h1>
                <p class="text-gray-600">Điền thông tin để đặt phòng lưu trú cho thú cưng của bạn</p>
            </div>

            <!-- Form Đặt Lưu Trú -->
            <div class="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
                <form id="boardingForm" class="space-y-6" onsubmit="return submitBoardingForm(event)">
                    <!-- Loại phòng -->
                    <div>
                        <label class="block text-sm font-medium text-slate-700 mb-2">Loại phòng *</label>
                        <select name="roomType" id="roomType" class="w-full border border-slate-300 rounded-lg px-3 h-10 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500" required>
                            <option value="">-- Chọn loại phòng --</option>
                            <option value="Phòng Tiêu Chuẩn">Phòng Tiêu Chuẩn</option>
                            <option value="Phòng VIP">Phòng VIP</option>
                            <option value="Phòng Siêu VIP">Phòng Siêu VIP</option>
                        </select>
                        <p class="text-xs text-slate-500 mt-1">Vui lòng chọn loại phòng phù hợp với thú cưng của bạn</p>
                    </div>

                    <!-- Ngày nhận / Ngày trả -->
                    <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                        <div>
                            <label class="block text-sm font-medium text-slate-700 mb-2">Ngày nhận *</label>
                            <input type="date" name="checkInDate" id="checkInDate" 
                                   class="w-full border border-slate-300 rounded-lg px-3 h-10 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500" 
                                   min="<%= java.time.LocalDate.now().toString() %>" 
                                   required>
                        </div>
                        <div>
                            <label class="block text-sm font-medium text-slate-700 mb-2">Ngày trả *</label>
                            <input type="date" name="checkOutDate" id="checkOutDate" 
                                   class="w-full border border-slate-300 rounded-lg px-3 h-10 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500" 
                                   min="<%= java.time.LocalDate.now().toString() %>" 
                                   required>
                        </div>
                    </div>

                    <!-- Giờ nhận / Giờ trả -->
                    <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                        <div>
                            <label class="block text-sm font-medium text-slate-700 mb-2">Giờ nhận *</label>
                            <input type="time" name="checkInTime" id="checkInTime" 
                                   class="w-full border border-slate-300 rounded-lg px-3 h-10 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500" 
                                   value="08:00" required>
                        </div>
                        <div>
                            <label class="block text-sm font-medium text-slate-700 mb-2">Giờ trả *</label>
                            <input type="time" name="checkOutTime" id="checkOutTime" 
                                   class="w-full border border-slate-300 rounded-lg px-3 h-10 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500" 
                                   value="17:00" required>
                        </div>
                    </div>

                    <!-- Thông tin thú cưng -->
                    <div>
                        <label class="block text-sm font-medium text-slate-700 mb-2">Thú cưng *</label>
                        <select name="petId" id="petSelect" class="w-full border border-slate-300 rounded-lg px-3 h-10 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500" required>
                            <option value="">-- Chọn thú cưng --</option>
                        </select>
                    </div>

                    <!-- Thông tin chi tiết thú cưng -->
                    <div>
                        <label class="block text-sm font-medium text-slate-700 mb-2">Thông tin thú cưng *</label>
                        <textarea name="petInfo" id="petInfo" rows="3" 
                                  class="w-full border border-slate-300 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500" 
                                  placeholder="Ví dụ: Chó 2 tuổi, nặng 5kg, đã tiêm phòng đầy đủ..." 
                                  required></textarea>
                    </div>

                    <!-- SĐT khẩn cấp -->
                    <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                        <div>
                            <label class="block text-sm font-medium text-slate-700 mb-2">SĐT khẩn cấp 1 *</label>
                            <input type="tel" name="emergencyPhone1" id="emergencyPhone1" 
                                   class="w-full border border-slate-300 rounded-lg px-3 h-10 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500" 
                                   placeholder="0901234567" 
                                   required>
                        </div>
                        <div>
                            <label class="block text-sm font-medium text-slate-700 mb-2">SĐT khẩn cấp 2 (tùy chọn)</label>
                            <input type="tel" name="emergencyPhone2" id="emergencyPhone2" 
                                   class="w-full border border-slate-300 rounded-lg px-3 h-10 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500" 
                                   placeholder="0987654321">
                        </div>
                    </div>

                    <!-- Ghi chú đặc biệt -->
                    <div>
                        <label class="block text-sm font-medium text-slate-700 mb-2">Ghi chú đặc biệt (tùy chọn)</label>
                        <textarea name="specialNotes" id="specialNotes" rows="3" 
                                  class="w-full border border-slate-300 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500" 
                                  placeholder="Ví dụ: Thú cưng cần chế độ ăn đặc biệt, không thích tiếp xúc với các thú cưng khác..."></textarea>
                    </div>

                    <!-- Phương thức thanh toán -->
                    <div>
                        <label class="block text-sm font-medium text-slate-700 mb-2">Phương thức thanh toán *</label>
                        <select name="paymentMethod" id="paymentMethod" class="w-full border border-slate-300 rounded-lg px-3 h-10 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500" required>
                            <option value="cash">Tiền mặt</option>
                            <option value="payos">PayOS</option>
                        </select>
                    </div>

                    <!-- Thông tin giá -->
                    <div class="bg-blue-50 rounded-lg p-4 border border-blue-200">
                        <div class="flex items-center justify-between mb-2">
                            <span class="text-sm font-medium text-gray-700">Giá/ngày:</span>
                            <span class="text-lg font-bold text-blue-600" id="pricePerDay">Chưa chọn</span>
                        </div>
                        <div class="flex items-center justify-between mb-2">
                            <span class="text-sm font-medium text-gray-700">Số ngày:</span>
                            <span class="text-lg font-bold text-gray-800" id="boardingDays">0 ngày</span>
                        </div>
                        <div class="flex items-center justify-between pt-2 border-t border-blue-200">
                            <span class="text-lg font-semibold text-gray-800">Tổng tiền:</span>
                            <span class="text-2xl font-bold text-green-600" id="totalPrice">0₫</span>
                        </div>
                    </div>

                    <!-- Validation message -->
                    <div>
                        <span id="validationMessage" class="text-sm text-gray-600" aria-live="polite"></span>
                    </div>

                    <!-- Buttons -->
                    <div class="flex items-center justify-between pt-4 border-t">
                        <a href="<%= request.getContextPath()%>/spa-booking?action=history" 
                           class="text-gray-600 hover:text-gray-800">
                            <i class="fas fa-arrow-left mr-2"></i>Quay lại
                        </a>
                        <div class="space-x-3">
                            <button type="button" onclick="calculatePrice()" 
                                    class="btn h-10 px-4 bg-blue-600 hover:bg-blue-700 text-white rounded-lg shadow-sm">
                                <i class="fas fa-calculator mr-2"></i>Tính giá
                            </button>
                            <button type="submit" id="submitBtn" 
                                    class="btn h-10 px-6 bg-green-600 hover:bg-green-700 text-white rounded-lg shadow-sm opacity-50 cursor-not-allowed" 
                                    disabled>
                                <i class="fas fa-check mr-2"></i>Đặt phòng lưu trú
                            </button>
                        </div>
                    </div>
                </form>
            </div>
        </div>

        <script>
            function toggleUserMenu() {
                const menu = document.getElementById('userMenu');
                menu.classList.toggle('hidden');
            }

            // Load danh sách thú cưng
            $(document).ready(function() {
                $.post('<%= request.getContextPath()%>/spa-booking', { action: 'get-customer-pets' }, function(pets){
                    if (!Array.isArray(pets)) return;
                    var options = '<option value="">-- Chọn thú cưng --</option>';
                    for (var i=0;i<pets.length;i++) {
                        var p = pets[i];
                        options += '<option value="' + p.id + '">' + p.petName + ' (' + p.species + ')</option>';
                    }
                    $('#petSelect').html(options);
                    if (pets.length > 0) {
                        $('#petSelect').val(String(pets[0].id));
                        // Auto fill pet info
                        var selectedPet = pets[0];
                        $('#petInfo').val(selectedPet.petName + ' (' + selectedPet.species + '), ' + selectedPet.age + ' tuổi');
                    }
                }, 'json');

                // Auto update khi chọn pet
                $('#petSelect').on('change', function() {
                    var petId = $(this).val();
                    if (petId) {
                        $.post('<%= request.getContextPath()%>/spa-booking', { action: 'get-customer-pets' }, function(pets){
                            var pet = pets.find(p => p.id == parseInt(petId));
                            if (pet) {
                                $('#petInfo').val(pet.petName + ' (' + pet.species + '), ' + pet.age + ' tuổi');
                            }
                        }, 'json');
                    }
                });

                // Auto calculate khi thay đổi ngày
                $('#checkInDate, #checkOutDate').on('change', function() {
                    validateDates();
                    calculatePrice();
                    checkFormValid();
                });

                // Auto calculate khi chọn loại phòng
                $('#roomType').on('change', function() {
                    updatePricePerDay();
                    calculatePrice();
                    checkFormValid();
                });
            });

            // Validate dates
            function validateDates() {
                const checkIn = new Date($('#checkInDate').val());
                const checkOut = new Date($('#checkOutDate').val());
                const today = new Date();
                today.setHours(0, 0, 0, 0);

                const messageEl = $('#validationMessage');
                
                if ($('#checkInDate').val() && $('#checkOutDate').val()) {
                    if (checkIn < today) {
                        messageEl.text('❌ Ngày nhận không được là ngày quá khứ').removeClass('text-green-600').addClass('text-red-600');
                        return false;
                    }
                    if (checkOut < checkIn) {
                        messageEl.text('❌ Ngày trả phải sau hoặc bằng ngày nhận').removeClass('text-green-600').addClass('text-red-600');
                        return false;
                    }
                    if (checkIn.getTime() === checkOut.getTime()) {
                        messageEl.text('⚠️ Ngày nhận và ngày trả không thể trùng nhau').removeClass('text-red-600').addClass('text-yellow-600');
                        return false;
                    }
                    messageEl.text('✅ Thời gian hợp lệ').removeClass('text-red-600 text-yellow-600').addClass('text-green-600');
                    return true;
                }
                return false;
            }

            // Update price per day based on room type
            function updatePricePerDay() {
                const roomType = $('#roomType').val();
                let price = 0;
                switch(roomType) {
                    case 'Phòng Tiêu Chuẩn':
                        price = 200000;
                        break;
                    case 'Phòng VIP':
                        price = 350000;
                        break;
                    case 'Phòng Siêu VIP':
                        price = 500000;
                        break;
                    default:
                        price = 0;
                }
                $('#pricePerDay').text(price > 0 ? price.toLocaleString() + '₫' : 'Chưa chọn');
            }

            // Calculate total price
            function calculatePrice() {
                const checkIn = new Date($('#checkInDate').val());
                const checkOut = new Date($('#checkOutDate').val());
                const roomType = $('#roomType').val();
                
                if (!checkIn || !checkOut || !roomType) {
                    $('#boardingDays').text('0 ngày');
                    $('#totalPrice').text('0₫');
                    return;
                }

                // Calculate days
                const diffTime = Math.abs(checkOut - checkIn);
                const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
                
                if (diffDays <= 0) {
                    $('#boardingDays').text('0 ngày');
                    $('#totalPrice').text('0₫');
                    return;
                }

                $('#boardingDays').text(diffDays + ' ngày');

                // Get price per day
                let pricePerDay = 0;
                switch(roomType) {
                    case 'Phòng Tiêu Chuẩn':
                        pricePerDay = 200000;
                        break;
                    case 'Phòng VIP':
                        pricePerDay = 350000;
                        break;
                    case 'Phòng Siêu VIP':
                        pricePerDay = 500000;
                        break;
                }

                const total = pricePerDay * diffDays;
                $('#totalPrice').text(total.toLocaleString() + '₫');
            }

            // Check form validity
            function checkFormValid() {
                const roomType = $('#roomType').val();
                const checkInDate = $('#checkInDate').val();
                const checkOutDate = $('#checkOutDate').val();
                const petId = $('#petSelect').val();
                const petInfo = $('#petInfo').val();
                const emergencyPhone1 = $('#emergencyPhone1').val();
                const paymentMethod = $('#paymentMethod').val();

                const isValid = roomType && checkInDate && checkOutDate && petId && petInfo && emergencyPhone1 && paymentMethod && validateDates();

                const btn = $('#submitBtn');
                if (isValid) {
                    btn.prop('disabled', false).removeClass('opacity-50 cursor-not-allowed');
                } else {
                    btn.prop('disabled', true).addClass('opacity-50 cursor-not-allowed');
                }
            }

            // Validate all fields on change
            $('#roomType, #checkInDate, #checkOutDate, #petSelect, #petInfo, #emergencyPhone1, #paymentMethod').on('change input', function() {
                checkFormValid();
            });

            // Submit form
            function submitBoardingForm(e) {
                e.preventDefault();
                
                // Validate form
                const roomType = $('#roomType').val();
                const checkInDate = $('#checkInDate').val();
                const checkOutDate = $('#checkOutDate').val();
                const petId = $('#petSelect').val();
                const petInfo = $('#petInfo').val();
                const emergencyPhone1 = $('#emergencyPhone1').val();
                const paymentMethod = $('#paymentMethod').val();
                
                if (!roomType || !checkInDate || !checkOutDate || !petId || !petInfo || !emergencyPhone1 || !paymentMethod) {
                    alert('Vui lòng điền đầy đủ thông tin bắt buộc');
                    return false;
                }
                
                if (!validateDates()) {
                    return false;
                }

                const formData = {
                    action: 'create-boarding-booking',
                    roomType: $('#roomType').val(),
                    pricePerDay: getPricePerDay(),
                    boardingDays: parseInt($('#boardingDays').text()),
                    checkInDate: $('#checkInDate').val(),
                    checkOutDate: $('#checkOutDate').val(),
                    checkInHour: $('#checkInTime').val().split(':')[0],
                    checkInMinute: $('#checkInTime').val().split(':')[1],
                    checkOutHour: $('#checkOutTime').val().split(':')[0],
                    checkOutMinute: $('#checkOutTime').val().split(':')[1],
                    petId: $('#petSelect').val(),
                    petInfo: $('#petInfo').val(),
                    specialNotes: $('#specialNotes').val(),
                    emergencyPhone1: $('#emergencyPhone1').val(),
                    emergencyPhone2: $('#emergencyPhone2').val(),
                    paymentMethod: $('#paymentMethod').val()
                };

                $.post('<%= request.getContextPath()%>/spa-booking', formData, function(response) {
                    if (response && response.success) {
                        alert('✅ Đặt phòng lưu trú thành công!');
                        window.location.href = '<%= request.getContextPath()%>/spa-booking?action=history';
                    } else {
                        alert('❌ ' + (response.message || 'Có lỗi xảy ra khi đặt phòng'));
                    }
                }, 'json').fail(function() {
                    alert('❌ Lỗi khi gửi form');
                });

                return false;
            }

            function getPricePerDay() {
                const roomType = $('#roomType').val();
                switch(roomType) {
                    case 'Phòng Tiêu Chuẩn': return 200000;
                    case 'Phòng VIP': return 350000;
                    case 'Phòng Siêu VIP': return 500000;
                    default: return 0;
                }
            }
        </script>
    </body>
</html>
