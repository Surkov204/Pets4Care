<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*, utils.DBConnection" %>
<%@ page session="true" %>
<%
    // Kết nối database và lấy danh sách phòng
    List<Object[]> rooms = new java.util.ArrayList<>();
    String errorMessage = null;
    
    try (Connection conn = DBConnection.getConnection()) {
        String sql = "SELECT room_id, room_name, room_type, capacity, price_per_day, description, status FROM BoardingRoom WHERE is_active = 1 ORDER BY room_type, room_name";
        try (PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            
            while (rs.next()) {
                Object[] room = new Object[7];
                room[0] = rs.getInt("room_id");
                room[1] = rs.getString("room_name");
                room[2] = rs.getString("room_type");
                room[3] = rs.getInt("capacity");
                room[4] = rs.getDouble("price_per_day");
                room[5] = rs.getString("description");
                room[6] = rs.getString("status");
                rooms.add(room);
            }
        }
    } catch (Exception e) {
        errorMessage = "Lỗi kết nối database: " + e.getMessage();
        e.printStackTrace();
    }
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>🏠 Danh Sách Phòng Lưu Trú - Petcity</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.3/css/all.min.css" rel="stylesheet" />
    <style>
        .room-card {
            transition: all 0.3s ease;
        }
        .room-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 10px 25px rgba(0,0,0,0.1);
        }
    </style>
</head>
<body>
    <!-- Header -->
    <div class="bg-gradient-to-r from-blue-500 to-purple-600 text-white py-4">
        <div class="container mx-auto px-4">
            <div class="flex justify-between items-center">
                <h1 class="text-2xl font-bold">🏠 Danh Sách Phòng Lưu Trú</h1>
                <div class="flex space-x-4">
                    <a href="<%= request.getContextPath()%>/home.jsp" class="hover:text-yellow-300 transition">
                        <i class="fas fa-home"></i> Trang chủ
                    </a>
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

    <!-- Success Message -->
    <% if (rooms.size() > 0) { %>
        <div class="bg-green-100 border border-green-400 text-green-700 px-4 py-3 rounded mx-4 mt-4">
            <i class="fas fa-check-circle"></i> Đã tải thành công <%= rooms.size() %> phòng lưu trú
        </div>
    <% } %>

    <!-- Filter Section -->
    <div class="bg-gray-50 py-6">
        <div class="container mx-auto px-4">
            <div class="text-center mb-6">
                <h2 class="text-3xl font-bold text-gray-800 mb-2">Chọn Phòng Phù Hợp</h2>
                <p class="text-gray-600">Tìm phòng lưu trú hoàn hảo cho thú cưng của bạn</p>
            </div>
            
            <div class="flex flex-wrap justify-center gap-4 mb-6">
                <button onclick="filterRooms('')" 
                        class="px-6 py-3 rounded-full border-2 border-gray-300 hover:border-blue-500 transition bg-blue-500 text-white">
                    <i class="fas fa-th-large"></i> Tất cả (<%= rooms.size() %>)
                </button>
                <button onclick="filterRooms('dog_large')" 
                        class="px-6 py-3 rounded-full border-2 border-gray-300 hover:border-blue-500 transition">
                    <i class="fas fa-dog"></i> Chó Lớn
                </button>
                <button onclick="filterRooms('dog_small')" 
                        class="px-6 py-3 rounded-full border-2 border-gray-300 hover:border-blue-500 transition">
                    <i class="fas fa-dog"></i> Chó Nhỏ
                </button>
                <button onclick="filterRooms('cat_standard')" 
                        class="px-6 py-3 rounded-full border-2 border-gray-300 hover:border-blue-500 transition">
                    <i class="fas fa-cat"></i> Mèo Tiêu Chuẩn
                </button>
                <button onclick="filterRooms('cat_vip')" 
                        class="px-6 py-3 rounded-full border-2 border-gray-300 hover:border-blue-500 transition">
                    <i class="fas fa-crown"></i> Mèo VIP
                </button>
            </div>
        </div>
    </div>

    <!-- Rooms Grid -->
    <div class="container mx-auto px-4 py-8">
        <% if (rooms.isEmpty()) { %>
            <div class="text-center py-16">
                <div class="text-6xl mb-4">🏠</div>
                <h3 class="text-2xl font-bold text-gray-600 mb-2">Không có phòng nào</h3>
                <p class="text-gray-500">Hiện tại chưa có phòng lưu trú nào trong hệ thống</p>
            </div>
        <% } else { %>
            <div class="grid md:grid-cols-2 lg:grid-cols-3 gap-6">
                <% for (Object[] room : rooms) { 
                    int roomId = (Integer) room[0];
                    String roomName = (String) room[1];
                    String roomType = (String) room[2];
                    int capacity = (Integer) room[3];
                    double pricePerDay = (Double) room[4];
                    String description = (String) room[5];
                    String status = (String) room[6];
                    
                    // Helper functions
                    String getRoomEmoji(String type) {
                        switch (type) {
                            case "dog_large":
                            case "dog_small":
                                return "🐕";
                            case "cat_standard":
                            case "cat_vip":
                                return "🐱";
                            default:
                                return "🏠";
                        }
                    }
                    
                    String getRoomTypeDisplayName(String type) {
                        switch (type) {
                            case "dog_large":
                                return "Phòng Chó Lớn";
                            case "dog_small":
                                return "Phòng Chó Nhỏ";
                            case "cat_standard":
                                return "Phòng Mèo Tiêu Chuẩn";
                            case "cat_vip":
                                return "Phòng Mèo VIP";
                            default:
                                return type;
                        }
                    }
                    
                    String getStatusDisplayName(String status) {
                        switch (status) {
                            case "available":
                                return "Có sẵn";
                            case "occupied":
                                return "Đã thuê";
                            case "maintenance":
                                return "Bảo trì";
                            default:
                                return status;
                        }
                    }
                    
                    String getStatusColor(String status) {
                        switch (status) {
                            case "available":
                                return "text-green-600 bg-green-100";
                            case "occupied":
                                return "text-red-600 bg-red-100";
                            case "maintenance":
                                return "text-yellow-600 bg-yellow-100";
                            default:
                                return "text-gray-600 bg-gray-100";
                        }
                    }
                    
                    boolean isAvailable = "available".equals(status);
                %>
                    <div class="room-card bg-white rounded-lg shadow-lg overflow-hidden" data-room-type="<%= roomType %>">
                        <!-- Room Image -->
                        <div class="h-48 bg-gradient-to-br from-blue-400 to-purple-500 flex items-center justify-center">
                            <div class="text-6xl text-white"><%= getRoomEmoji(roomType) %></div>
                        </div>
                        
                        <!-- Room Info -->
                        <div class="p-6">
                            <div class="flex justify-between items-start mb-2">
                                <h3 class="text-xl font-bold text-gray-800"><%= roomName %></h3>
                                <span class="px-3 py-1 rounded-full text-sm font-medium <%= getStatusColor(status) %>">
                                    <%= getStatusDisplayName(status) %>
                                </span>
                            </div>
                            
                            <p class="text-gray-600 mb-3"><%= getRoomTypeDisplayName(roomType) %></p>
                            
                            <div class="flex items-center mb-3">
                                <i class="fas fa-users text-gray-400 mr-2"></i>
                                <span class="text-sm text-gray-600">
                                    <%= capacity == 1 ? "1 thú cưng" : capacity + " thú cưng" %>
                                </span>
                            </div>
                            
                            <p class="text-gray-700 text-sm mb-4 line-clamp-2"><%= description %></p>
                            
                            <div class="flex justify-between items-center mb-4">
                                <div class="text-2xl font-bold text-green-600">
                                    <%= String.format("%.0f₫", pricePerDay) %>/ngày
                                </div>
                            </div>
                            
                            <div class="flex space-x-2">
                                <button onclick="showRoomDetail(<%= roomId %>)" 
                                        class="flex-1 bg-blue-500 text-white text-center py-2 px-4 rounded hover:bg-blue-600 transition">
                                    <i class="fas fa-eye mr-1"></i> Xem chi tiết
                                </button>
                                <% if (isAvailable) { %>
                                    <button onclick="bookRoom(<%= roomId %>)" 
                                            class="flex-1 bg-green-500 text-white text-center py-2 px-4 rounded hover:bg-green-600 transition">
                                        <i class="fas fa-calendar-plus mr-1"></i> Đặt phòng
                                    </button>
                                <% } else { %>
                                    <button disabled class="flex-1 bg-gray-400 text-white text-center py-2 px-4 rounded cursor-not-allowed">
                                        <i class="fas fa-times mr-1"></i> Không có sẵn
                                    </button>
                                <% } %>
                            </div>
                        </div>
                    </div>
                <% } %>
            </div>
        <% } %>
    </div>

    <!-- Features Section -->
    <div class="bg-gray-50 py-16">
        <div class="container mx-auto px-4">
            <div class="text-center mb-12">
                <h2 class="text-3xl font-bold text-gray-800 mb-4">Tại Sao Chọn Chúng Tôi?</h2>
                <p class="text-gray-600 max-w-2xl mx-auto">Chúng tôi cam kết mang đến dịch vụ lưu trú thú cưng tốt nhất với sự chăm sóc tận tâm</p>
            </div>
            
            <div class="grid md:grid-cols-3 gap-8">
                <div class="text-center">
                    <div class="bg-blue-100 w-16 h-16 rounded-full flex items-center justify-center mx-auto mb-4">
                        <i class="fas fa-shield-alt text-2xl text-blue-600"></i>
                    </div>
                    <h3 class="text-xl font-bold text-gray-800 mb-2">An Toàn Tuyệt Đối</h3>
                    <p class="text-gray-600">Hệ thống camera giám sát 24/7, chuồng trại an toàn, đội ngũ nhân viên chuyên nghiệp</p>
                </div>
                
                <div class="text-center">
                    <div class="bg-green-100 w-16 h-16 rounded-full flex items-center justify-center mx-auto mb-4">
                        <i class="fas fa-heart text-2xl text-green-600"></i>
                    </div>
                    <h3 class="text-xl font-bold text-gray-800 mb-2">Chăm Sóc Tận Tâm</h3>
                    <p class="text-gray-600">Thức ăn chất lượng cao, vận động hàng ngày, chăm sóc y tế khi cần thiết</p>
                </div>
                
                <div class="text-center">
                    <div class="bg-purple-100 w-16 h-16 rounded-full flex items-center justify-center mx-auto mb-4">
                        <i class="fas fa-mobile-alt text-2xl text-purple-600"></i>
                    </div>
                    <h3 class="text-xl font-bold text-gray-800 mb-2">Cập Nhật Thường Xuyên</h3>
                    <p class="text-gray-600">Nhận hình ảnh và video hàng ngày, báo cáo tình trạng sức khỏe chi tiết</p>
                </div>
            </div>
        </div>
    </div>

    <!-- Footer -->
    <footer class="bg-gray-800 text-white py-8">
        <div class="container mx-auto px-4 text-center">
            <p>&copy; 2024 Petcity - Dịch vụ lưu trú thú cưng chuyên nghiệp</p>
            <p class="text-gray-400 mt-2">Hotline: 1900-xxxx | Email: info@petcity.com</p>
        </div>
    </footer>

    <script>
        function filterRooms(type) {
            const cards = document.querySelectorAll('.room-card');
            cards.forEach(card => {
                if (type === '' || card.dataset.roomType === type) {
                    card.style.display = 'block';
                } else {
                    card.style.display = 'none';
                }
            });
            
            // Update active button
            document.querySelectorAll('button').forEach(btn => {
                btn.classList.remove('bg-blue-500', 'text-white');
                btn.classList.add('border-gray-300');
            });
            event.target.classList.add('bg-blue-500', 'text-white');
            event.target.classList.remove('border-gray-300');
        }
        
        function showRoomDetail(roomId) {
            alert('Chi tiết phòng ID: ' + roomId + '\n(Tính năng này sẽ được triển khai sau)');
        }
        
        function bookRoom(roomId) {
            alert('Đặt phòng ID: ' + roomId + '\n(Tính năng này sẽ được triển khai sau)');
        }
        
        // Initialize
        document.addEventListener('DOMContentLoaded', function() {
            console.log('Trang đã tải xong với <%= rooms.size() %> phòng');
        });
    </script>
</body>
</html>
