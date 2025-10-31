<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.BoardingRoom, model.Customer, java.util.List" %>
<%@ page session="true" %>
<%
    BoardingRoom room = (BoardingRoom) request.getAttribute("room");
    List<BoardingRoom> similarRooms = (List<BoardingRoom>) request.getAttribute("similarRooms");
    String errorMessage = (String) request.getAttribute("errorMessage");
    Customer currentUser = (Customer) session.getAttribute("currentUser");
    
    if (similarRooms == null) similarRooms = new java.util.ArrayList<>();
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= room != null ? room.getRoomName() : "Chi tiết phòng" %> - Petcity</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.3/css/all.min.css" rel="stylesheet" />
    <link href="https://fonts.googleapis.com/css2?family=Quicksand:wght@300;400;500;600;700&family=Nunito:wght@300;400;500;600;700;800&family=Baloo+2:wght@400;500;600;700;800&display=swap" rel="stylesheet" />
    <link rel="stylesheet" href="../css/homeStyle.css" />
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <style>
        .amenity-item {
            transition: all 0.3s ease;
        }
        .amenity-item:hover {
            transform: scale(1.05);
        }
        .booking-form {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        }
    </style>
</head>
<body>
    <!-- Header -->
    <div class="bg-gradient-to-r from-blue-500 to-purple-600 text-white py-4">
        <div class="container mx-auto px-4">
            <div class="flex justify-between items-center">
                <div class="flex items-center space-x-4">
                    <a href="<%= request.getContextPath()%>/boarding-room?action=list" class="hover:text-yellow-300 transition">
                        <i class="fas fa-arrow-left"></i> Quay lại
                    </a>
                    <h1 class="text-2xl font-bold"><%= room != null ? room.getRoomName() : "Chi tiết phòng" %></h1>
                </div>
                <div class="flex space-x-4">
                    <a href="<%= request.getContextPath()%>/home.jsp" class="hover:text-yellow-300 transition">
                        <i class="fas fa-home"></i> Trang chủ
                    </a>
                    <% if (currentUser != null) { %>
                        <a href="<%= request.getContextPath()%>/boarding-room?action=my-bookings" class="hover:text-yellow-300 transition">
                            <i class="fas fa-calendar-alt"></i> Lịch sử đặt phòng
                        </a>
                    <% } %>
                </div>
            </div>
        </div>
    </div>

    <!-- Error Message -->
    <% if (errorMessage != null) { %>
        <div class="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded mx-4 mt-4">
            <i class="fas fa-exclamation-triangle"></i> <%= errorMessage %>
        </div>
    <% } %>

    <% if (room != null) { %>
        <div class="container mx-auto px-4 py-8">
            <div class="grid lg:grid-cols-2 gap-8">
                <!-- Room Images & Info -->
                <div>
                    <!-- Main Image -->
                    <div class="bg-gradient-to-br from-blue-400 to-purple-500 rounded-lg h-96 flex items-center justify-center mb-6">
                        <div class="text-8xl text-white"><%= room.getRoomEmoji() %></div>
                    </div>
                    
                    <!-- Room Details -->
                    <div class="bg-white rounded-lg shadow-lg p-6">
                        <div class="flex justify-between items-start mb-4">
                            <h2 class="text-3xl font-bold text-gray-800"><%= room.getRoomName() %></h2>
                            <span class="px-4 py-2 rounded-full text-sm font-medium <%= room.getStatusColor() %>">
                                <%= room.getStatusDisplayName() %>
                            </span>
                        </div>
                        
                        <div class="flex items-center mb-4">
                            <i class="fas fa-tag text-gray-400 mr-2"></i>
                            <span class="text-lg text-gray-600"><%= room.getRoomTypeDisplayName() %></span>
                        </div>
                        
                        <div class="flex items-center mb-4">
                            <i class="fas fa-users text-gray-400 mr-2"></i>
                            <span class="text-lg text-gray-600"><%= room.getCapacityText() %></span>
                        </div>
                        
                        <div class="text-3xl font-bold text-green-600 mb-6">
                            <%= room.getFormattedPrice() %>/ngày
                        </div>
                        
                        <div class="border-t pt-6">
                            <h3 class="text-xl font-bold text-gray-800 mb-3">Mô tả phòng</h3>
                            <p class="text-gray-700 leading-relaxed"><%= room.getDescription() %></p>
                        </div>
                    </div>
                </div>
                
                <!-- Booking Form -->
                <div>
                    <div class="booking-form rounded-lg p-6 text-white">
                        <h3 class="text-2xl font-bold mb-6">Đặt phòng ngay</h3>
                        
                        <% if (currentUser != null) { %>
                            <% if (room.isAvailable()) { %>
                                <form action="<%= request.getContextPath()%>/boarding-room" method="post" onsubmit="return validateBookingForm()">
                                    <input type="hidden" name="action" value="book-room">
                                    <input type="hidden" name="roomId" value="<%= room.getRoomId() %>">
                                    
                                    <div class="grid md:grid-cols-2 gap-4 mb-4">
                                        <div>
                                            <label class="block text-sm font-semibold mb-2">Ngày nhận *</label>
                                            <input type="date" name="checkInDate" required 
                                                   class="w-full px-4 py-3 rounded-lg text-gray-800"
                                                   min="<%= java.time.LocalDate.now().toString() %>">
                                        </div>
                                        <div>
                                            <label class="block text-sm font-semibold mb-2">Ngày trả *</label>
                                            <input type="date" name="checkOutDate" required 
                                                   class="w-full px-4 py-3 rounded-lg text-gray-800"
                                                   min="<%= java.time.LocalDate.now().toString() %>">
                                        </div>
                                    </div>
                                    
                                    <div class="grid md:grid-cols-2 gap-4 mb-4">
                                        <div>
                                            <label class="block text-sm font-semibold mb-2">Tên thú cưng *</label>
                                            <input type="text" name="petName" required 
                                                   class="w-full px-4 py-3 rounded-lg text-gray-800"
                                                   placeholder="Nhập tên thú cưng">
                                        </div>
                                        <div>
                                            <label class="block text-sm font-semibold mb-2">Loài thú cưng *</label>
                                            <select name="petType" required class="w-full px-4 py-3 rounded-lg text-gray-800">
                                                <option value="">Chọn loài</option>
                                                <option value="dog">Chó</option>
                                                <option value="cat">Mèo</option>
                                                <option value="rabbit">Thỏ</option>
                                                <option value="hamster">Hamster</option>
                                                <option value="bird">Chim</option>
                                                <option value="other">Khác</option>
                                            </select>
                                        </div>
                                    </div>
                                    
                                    <div class="mb-4">
                                        <label class="block text-sm font-semibold mb-2">Số điện thoại khẩn cấp *</label>
                                        <input type="tel" name="emergencyContact" required 
                                               class="w-full px-4 py-3 rounded-lg text-gray-800"
                                               placeholder="Nhập số điện thoại">
                                    </div>
                                    
                                    <div class="mb-6">
                                        <label class="block text-sm font-semibold mb-2">Yêu cầu đặc biệt</label>
                                        <textarea name="specialRequests" rows="3" 
                                                  class="w-full px-4 py-3 rounded-lg text-gray-800"
                                                  placeholder="Thức ăn đặc biệt, thuốc, thói quen..."></textarea>
                                    </div>
                                    
                                    <button type="submit" class="w-full bg-white text-purple-600 font-bold py-4 rounded-lg hover:bg-gray-100 transition">
                                        <i class="fas fa-calendar-check mr-2"></i> Đặt phòng ngay
                                    </button>
                                </form>
                            <% } else { %>
                                <div class="text-center py-8">
                                    <div class="text-4xl mb-4">🚫</div>
                                    <h4 class="text-xl font-bold mb-2">Phòng không có sẵn</h4>
                                    <p class="text-sm opacity-90">Phòng này hiện đang được sử dụng hoặc bảo trì</p>
                                </div>
                            <% } %>
                        <% } else { %>
                            <div class="text-center py-8">
                                <div class="text-4xl mb-4">🔐</div>
                                <h4 class="text-xl font-bold mb-2">Cần đăng nhập</h4>
                                <p class="text-sm opacity-90 mb-4">Bạn cần đăng nhập để đặt phòng</p>
                                <a href="<%= request.getContextPath()%>/login.jsp" 
                                   class="bg-white text-purple-600 font-bold py-3 px-6 rounded-lg hover:bg-gray-100 transition">
                                    <i class="fas fa-sign-in-alt mr-2"></i> Đăng nhập
                                </a>
                            </div>
                        <% } %>
                    </div>
                    
                    <!-- Price Calculator -->
                    <div class="bg-white rounded-lg shadow-lg p-6 mt-6">
                        <h3 class="text-xl font-bold text-gray-800 mb-4">Tính giá</h3>
                        <div id="price-calculation" class="text-gray-600">
                            <p>Chọn ngày để tính giá</p>
                        </div>
                    </div>
                </div>
            </div>
            
            <!-- Amenities Section -->
            <% if (room.getAmenities() != null && !room.getAmenities().isEmpty()) { %>
                <div class="mt-12">
                    <div class="bg-white rounded-lg shadow-lg p-8">
                        <h3 class="text-2xl font-bold text-gray-800 mb-6">Tiện nghi phòng</h3>
                        <div class="grid md:grid-cols-2 lg:grid-cols-3 gap-4">
                            <% 
                                String[] amenities = room.getAmenities().split(",");
                                for (String amenity : amenities) {
                                    String trimmedAmenity = amenity.trim();
                                    if (!trimmedAmenity.isEmpty()) {
                            %>
                                <div class="amenity-item bg-gray-50 rounded-lg p-4 text-center">
                                    <div class="text-2xl mb-2">🏠</div>
                                    <span class="text-gray-700 font-medium"><%= trimmedAmenity %></span>
                                </div>
                            <% 
                                    }
                                }
                            %>
                        </div>
                    </div>
                </div>
            <% } %>
            
            <!-- Similar Rooms -->
            <% if (!similarRooms.isEmpty()) { %>
                <div class="mt-12">
                    <h3 class="text-2xl font-bold text-gray-800 mb-6">Phòng tương tự</h3>
                    <div class="grid md:grid-cols-2 lg:grid-cols-3 gap-6">
                        <% for (BoardingRoom similarRoom : similarRooms) { %>
                            <div class="bg-white rounded-lg shadow-lg overflow-hidden hover:shadow-xl transition">
                                <div class="h-32 bg-gradient-to-br from-blue-400 to-purple-500 flex items-center justify-center">
                                    <div class="text-4xl text-white"><%= similarRoom.getRoomEmoji() %></div>
                                </div>
                                <div class="p-4">
                                    <h4 class="font-bold text-gray-800 mb-2"><%= similarRoom.getRoomName() %></h4>
                                    <p class="text-sm text-gray-600 mb-2"><%= similarRoom.getRoomTypeDisplayName() %></p>
                                    <div class="flex justify-between items-center">
                                        <span class="text-lg font-bold text-green-600"><%= similarRoom.getFormattedPrice() %>/ngày</span>
                                        <a href="<%= request.getContextPath()%>/boarding-room?action=detail&roomId=<%= similarRoom.getRoomId() %>" 
                                           class="bg-blue-500 text-white px-3 py-1 rounded text-sm hover:bg-blue-600 transition">
                                            Xem chi tiết
                                        </a>
                                    </div>
                                </div>
                            </div>
                        <% } %>
                    </div>
                </div>
            <% } %>
        </div>
    <% } else { %>
        <div class="container mx-auto px-4 py-16 text-center">
            <div class="text-6xl mb-4">❌</div>
            <h2 class="text-2xl font-bold text-gray-600 mb-2">Không tìm thấy phòng</h2>
            <p class="text-gray-500 mb-6">Phòng bạn đang tìm kiếm không tồn tại hoặc đã bị xóa</p>
            <a href="<%= request.getContextPath()%>/boarding-room?action=list" 
               class="bg-blue-500 text-white px-6 py-3 rounded-lg hover:bg-blue-600 transition">
                <i class="fas fa-arrow-left mr-2"></i> Quay lại danh sách
            </a>
        </div>
    <% } %>

    <script>
        function validateBookingForm() {
            const checkInDate = document.querySelector('input[name="checkInDate"]').value;
            const checkOutDate = document.querySelector('input[name="checkOutDate"]').value;
            const petName = document.querySelector('input[name="petName"]').value;
            const petType = document.querySelector('select[name="petType"]').value;
            const emergencyContact = document.querySelector('input[name="emergencyContact"]').value;
            
            if (!checkInDate || !checkOutDate || !petName || !petType || !emergencyContact) {
                alert('Vui lòng điền đầy đủ thông tin bắt buộc!');
                return false;
            }
            
            const checkIn = new Date(checkInDate);
            const checkOut = new Date(checkOutDate);
            const today = new Date();
            today.setHours(0, 0, 0, 0);
            
            if (checkIn < today) {
                alert('Ngày nhận không được là ngày quá khứ!');
                return false;
            }
            
            if (checkOut < checkIn) {
                alert('Ngày trả phải sau hoặc bằng ngày nhận!');
                return false;
            }
            
            return true;
        }
        
        // Price calculation
        function calculatePrice() {
            const checkInDate = document.querySelector('input[name="checkInDate"]').value;
            const checkOutDate = document.querySelector('input[name="checkOutDate"]').value;
            
            if (checkInDate && checkOutDate) {
                const checkIn = new Date(checkInDate);
                const checkOut = new Date(checkOutDate);
                const days = Math.ceil((checkOut - checkIn) / (1000 * 60 * 60 * 24));
                
                if (days > 0) {
                    const pricePerDay = <%= room != null ? room.getPricePerDay() : 0 %>;
                    const totalPrice = days * pricePerDay;
                    
                    document.getElementById('price-calculation').innerHTML = `
                        <div class="space-y-2">
                            <div class="flex justify-between">
                                <span>Số ngày:</span>
                                <span class="font-semibold">${days} ngày</span>
                            </div>
                            <div class="flex justify-between">
                                <span>Giá/ngày:</span>
                                <span class="font-semibold">${pricePerDay.toLocaleString()}₫</span>
                            </div>
                            <div class="border-t pt-2">
                                <div class="flex justify-between text-lg font-bold text-green-600">
                                    <span>Tổng cộng:</span>
                                    <span>${totalPrice.toLocaleString()}₫</span>
                                </div>
                            </div>
                        </div>
                    `;
                } else {
                    document.getElementById('price-calculation').innerHTML = '<p class="text-red-500">Ngày trả phải sau hoặc bằng ngày nhận!</p>';
                }
            }
        }
        
        // Add event listeners
        document.addEventListener('DOMContentLoaded', function() {
            const checkInInput = document.querySelector('input[name="checkInDate"]');
            const checkOutInput = document.querySelector('input[name="checkOutDate"]');
            
            if (checkInInput) {
                checkInInput.addEventListener('change', calculatePrice);
            }
            if (checkOutInput) {
                checkOutInput.addEventListener('change', calculatePrice);
            }
        });
    </script>
</body>
</html>
