<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.Customer" %>
<%@ page import="model.CartItem" %>
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
<%@ page import="java.util.*" %>
<%@ page import="java.text.SimpleDateFormat" %>

<%
    // Sample data - replace with actual database queries later
    String petName = "Milu";
    String species = "Chó";
    String breed = "Poodle";
    String gender = "Đực";
    String ownerName = "Nguyễn Văn A";
    String ownerPhone = "0123 456 789";
    String petImage = "toy_1.jpg"; // Sample image
    
    // Calculate age (sample date)
    Calendar birthDate = Calendar.getInstance();
    birthDate.set(2020, 5, 15); // June 15, 2020
    Calendar now = Calendar.getInstance();
    int age = now.get(Calendar.YEAR) - birthDate.get(Calendar.YEAR);
    if (now.get(Calendar.DAY_OF_YEAR) < birthDate.get(Calendar.DAY_OF_YEAR)) {
        age--;
    }
    
    // Health information
    String weight = "8.2 kg";
    String condition = "Bình thường";
    String temperature = "38.5°C";
    String pulse = "120 bpm";
    String breathing = "20 nhịp/phút";
    String symptoms = "Ăn ít hơn bình thường";
    String doctorNotes = "Sức khỏe tổng thể tốt, cần theo dõi chế độ ăn";
    
    // Available time slots
    List<String> availableSlots = Arrays.asList(
        "08:00 - 09:00", "09:00 - 10:00", "10:00 - 11:00",
        "14:00 - 15:00", "15:00 - 16:00", "16:00 - 17:00"
    );
    
    // Available doctors
    List<String> doctors = Arrays.asList(
        "Bác sĩ Nguyễn Thị B", "Bác sĩ Trần Văn C", "Bác sĩ Lê Thị D"
    );
%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đặt Lịch Khám - Pets4Care</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <style>
        :root {
            --primary: #f97316;
            --secondary: #6FD5DD;
            --accent: #FFD6C0;
            --bg: #f8fafc;
            --card-bg: #ffffff;
            --text: #1e293b;
            --border: #e2e8f0;
            --border-radius: 12px;
            --shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
            --shadow-light: 0 2px 4px -1px rgba(0, 0, 0, 0.06);
        }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: var(--bg);
            color: var(--text);
            margin: 0;
            padding: 0;
        }

        .header {
            background: linear-gradient(135deg, var(--primary), var(--secondary));
            color: white;
            padding: 1rem 0;
            box-shadow: var(--shadow);
        }

        .nav ul {
            list-style: none;
            display: flex;
            justify-content: center;
            gap: 2rem;
            margin: 0;
            padding: 0;
        }

        .nav a {
            color: white;
            text-decoration: none;
            font-weight: 600;
            padding: 0.5rem 1rem;
            border-radius: 6px;
            transition: all 0.3s ease;
        }

        .nav a:hover {
            background: rgba(255, 255, 255, 0.2);
            transform: translateY(-2px);
        }

        .container {
            max-width: 1200px;
            margin: 2rem auto;
            padding: 0 1rem;
        }

        .card {
            background: var(--card-bg);
            border-radius: var(--border-radius);
            box-shadow: var(--shadow-light);
            padding: 2rem;
            margin-bottom: 2rem;
            border: 1px solid var(--border);
        }

        .pet-info-grid {
            display: grid;
            grid-template-columns: auto 1fr;
            gap: 1rem;
            align-items: center;
        }

        .pet-image {
            width: 120px;
            height: 120px;
            border-radius: 50%;
            object-fit: cover;
            border: 4px solid var(--accent);
        }

        .info-table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 1rem;
        }

        .info-table th,
        .info-table td {
            padding: 0.75rem;
            text-align: left;
            border-bottom: 1px solid var(--border);
        }

        .info-table th {
            background: var(--accent);
            font-weight: 600;
            width: 30%;
        }

        .history-timeline {
            position: relative;
            padding-left: 2rem;
        }

        .timeline-item {
            position: relative;
            padding-bottom: 2rem;
            border-left: 2px solid var(--secondary);
        }

        .timeline-item:before {
            content: '';
            position: absolute;
            left: -6px;
            top: 0;
            width: 10px;
            height: 10px;
            background: var(--primary);
            border-radius: 50%;
        }

        .timeline-content {
            background: var(--card-bg);
            padding: 1rem;
            border-radius: 8px;
            box-shadow: var(--shadow-light);
            margin-left: 1rem;
        }

        .form-group {
            margin-bottom: 1.5rem;
        }

        .form-label {
            display: block;
            margin-bottom: 0.5rem;
            font-weight: 600;
            color: var(--text);
        }

        .form-input,
        .form-select,
        .form-textarea {
            width: 100%;
            padding: 0.75rem;
            border: 2px solid var(--border);
            border-radius: 8px;
            font-size: 1rem;
            transition: border-color 0.3s ease;
        }

        .form-input:focus,
        .form-select:focus,
        .form-textarea:focus {
            outline: none;
            border-color: var(--primary);
        }

        .btn-primary {
            background: linear-gradient(135deg, var(--primary), var(--secondary));
            color: white;
            border: none;
            padding: 1rem 2rem;
            border-radius: 8px;
            font-size: 1rem;
            font-weight: 600;
            cursor: pointer;
            transition: transform 0.3s ease;
        }

        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: var(--shadow);
        }

        .status-badge {
            display: inline-block;
            padding: 0.25rem 0.75rem;
            border-radius: 20px;
            font-size: 0.875rem;
            font-weight: 500;
        }

        .status-normal {
            background: #dcfce7;
            color: #166534;
        }

        .status-warning {
            background: #fef3c7;
            color: #92400e;
        }

        .section-title {
            font-size: 1.5rem;
            font-weight: 700;
            color: var(--primary);
            margin-bottom: 1.5rem;
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }
    </style>
</head>
<body>
    <!-- Header -->
    <header class="header">
        <div class="container">
            <div class="flex items-center justify-between mb-4">
                <a href="<%= request.getContextPath()%>/home" class="flex items-center gap-4 hover:opacity-80 transition-opacity">
                    <div class="text-2xl font-bold">🐾 Pets4Care</div>
                    <div class="text-sm opacity-90">Đặt lịch khám thú cưng</div>
                </a>
                <div class="flex items-center gap-4">
                    <a href="<%= request.getContextPath()%>/cart/cart.jsp" class="text-white hover:underline">
                        <i class="fas fa-shopping-cart"></i> Giỏ hàng / <span class="cart-amount"><%= String.format("%.2f", cartTotal)%></span>₫
                        <span class="cart-count"><%= cartCount%></span>
                    </a>
                    <div>
                        <% if (currentUser == null) { %>
                        <a href="login.jsp" class="text-white text-sm hover:underline">👤 Đăng Ký | Đăng Nhập</a>
                        <% } else { %>
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
                        <% } %>
                    </div>
                </div>
            </div>
        </div>

        <!-- Navigation -->
        <nav class="nav">
            <ul>
                <li><a href="<%= request.getContextPath()%>/home">TRANG CHỦ</a></li>
                <li><a href="spa-service.jsp">DỊCH VỤ</a></li>
                <li><a href="dat-lich-kham.jsp" style="background: rgba(255, 255, 255, 0.2);">ĐẶT LỊCH KHÁM</a></li>
                <li><a href="search?categoryId=2">SẢN PHẨM</a></li>
                <li><a href="doctor.jsp">BÁC SĨ</a></li>
                <li><a href="gioi-thieu.jsp">GIỚI THIỆU</a></li>
                <li><a href="tin-tuc.jsp">TIN TỨC</a></li>
                <li><a href="lien-he.jsp">LIÊN HỆ</a></li>
            </ul>
        </nav>
    </header>

    <div class="container">
        <!-- A. Thông tin chung về thú cưng -->
        <div class="card">
            <h2 class="section-title">
                <i class="fas fa-paw"></i>
                A. Thông tin chung về thú cưng
            </h2>
            
            <div class="pet-info-grid">
                <img src="<%= request.getContextPath()%>/images/<%= petImage %>" 
                     alt="<%= petName %>" class="pet-image">
                <div>
                    <h3 class="text-2xl font-bold text-orange-600 mb-2">🐕 <%= petName %></h3>
                    <div class="grid grid-cols-2 gap-4">
                        <div>
                            <strong>Loài:</strong> <%= species %><br>
                            <strong>Giống:</strong> <%= breed %><br>
                            <strong>Tuổi:</strong> <%= age %> tuổi
                        </div>
                        <div>
                            <strong>Giới tính:</strong> <%= gender %><br>
                            <strong>Chủ sở hữu:</strong> <%= ownerName %><br>
                            <strong>SĐT:</strong> <%= ownerPhone %>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- B. Thông tin sức khỏe hiện tại -->
        <div class="card">
            <h2 class="section-title">
                <i class="fas fa-heartbeat"></i>
                B. Thông tin sức khỏe hiện tại
            </h2>
            
            <table class="info-table">
                <tr>
                    <th>Cân nặng</th>
                    <td><%= weight %> <span class="text-green-600 text-sm">(tăng 0.3kg so với lần trước)</span></td>
                </tr>
                <tr>
                    <th>Tình trạng chung</th>
                    <td><span class="status-badge status-normal"><%= condition %></span></td>
                </tr>
                <tr>
                    <th>Nhiệt độ</th>
                    <td><%= temperature %></td>
                </tr>
                <tr>
                    <th>Mạch</th>
                    <td><%= pulse %></td>
                </tr>
                <tr>
                    <th>Nhịp thở</th>
                    <td><%= breathing %></td>
                </tr>
                <tr>
                    <th>Triệu chứng</th>
                    <td><%= symptoms %></td>
                </tr>
                <tr>
                    <th>Ghi chú bác sĩ</th>
                    <td><%= doctorNotes %></td>
                </tr>
            </table>
        </div>

        <!-- C. Lịch sử khám & tiêm chủng -->
        <div class="card">
            <h2 class="section-title">
                <i class="fas fa-history"></i>
                C. Lịch sử khám & tiêm chủng
            </h2>
            
            <div class="history-timeline">
                <div class="timeline-item">
                    <div class="timeline-content">
                        <div class="flex justify-between items-start">
                            <div>
                                <h4 class="font-semibold text-lg">Khám tổng quát</h4>
                                <p class="text-gray-600">05/10/2025</p>
                            </div>
                            <span class="status-badge status-normal">Hoàn thành</span>
                        </div>
                        <p class="mt-2">Sức khỏe tốt, không có dấu hiệu bất thường</p>
                    </div>
                </div>
                
                <div class="timeline-item">
                    <div class="timeline-content">
                        <div class="flex justify-between items-start">
                            <div>
                                <h4 class="font-semibold text-lg">Tiêm phòng dại</h4>
                                <p class="text-gray-600">20/09/2025</p>
                            </div>
                            <span class="status-badge status-normal">Hoàn thành</span>
                        </div>
                        <p class="mt-2">Tiêm phòng dại định kỳ, không có phản ứng phụ</p>
                    </div>
                </div>
                
                <div class="timeline-item">
                    <div class="timeline-content">
                        <div class="flex justify-between items-start">
                            <div>
                                <h4 class="font-semibold text-lg">Khám tiêu hóa</h4>
                                <p class="text-gray-600">12/08/2025</p>
                            </div>
                            <span class="status-badge status-warning">Theo dõi</span>
                        </div>
                        <p class="mt-2">Dấu hiệu nhẹ của viêm ruột, đã kê đơn thuốc</p>
                    </div>
                </div>
            </div>
        </div>

        <!-- D. Lịch khám đã đặt -->
        <div class="card">
            <h2 class="section-title">
                <i class="fas fa-calendar-check"></i>
                D. Lịch khám đã đặt và đang chờ
            </h2>
            
            <div class="mb-6">
                <button id="showAppointments" class="btn-primary mr-4">
                    <i class="fas fa-eye mr-2"></i>
                    Xem lịch khám đã đặt
                </button>
                <button id="hideAppointments" class="btn-primary" style="background: #6b7280; display: none;">
                    <i class="fas fa-eye-slash mr-2"></i>
                    Ẩn lịch khám
                </button>
            </div>
            
            <div id="appointmentsList" style="display: none;">
                <div class="space-y-4">
                    <!-- Upcoming Appointment -->
                    <div class="bg-blue-50 border-l-4 border-blue-400 p-4 rounded-r-lg">
                        <div class="flex justify-between items-start">
                            <div>
                                <h4 class="font-semibold text-lg text-blue-800">Khám tổng quát định kỳ</h4>
                                <p class="text-blue-600">📅 Ngày: 15/12/2025 - 09:00</p>
                                <p class="text-blue-600">👨‍⚕️ Bác sĩ: Nguyễn Thị B</p>
                                <p class="text-blue-600">📝 Ghi chú: Khám định kỳ 6 tháng</p>
                            </div>
                            <span class="status-badge" style="background: #dbeafe; color: #1e40af;">Chờ xác nhận</span>
                        </div>
                    </div>
                    
                    <!-- Confirmed Appointment -->
                    <div class="bg-green-50 border-l-4 border-green-400 p-4 rounded-r-lg">
                        <div class="flex justify-between items-start">
                            <div>
                                <h4 class="font-semibold text-lg text-green-800">Tiêm phòng định kỳ</h4>
                                <p class="text-green-600">📅 Ngày: 22/12/2025 - 14:00</p>
                                <p class="text-green-600">👨‍⚕️ Bác sĩ: Trần Văn C</p>
                                <p class="text-green-600">📝 Ghi chú: Tiêm phòng dại + 5 bệnh</p>
                            </div>
                            <span class="status-badge" style="background: #dcfce7; color: #166534;">Đã xác nhận</span>
                        </div>
                    </div>
                    
                    <!-- Pending Appointment -->
                    <div class="bg-yellow-50 border-l-4 border-yellow-400 p-4 rounded-r-lg">
                        <div class="flex justify-between items-start">
                            <div>
                                <h4 class="font-semibold text-lg text-yellow-800">Khám da liễu</h4>
                                <p class="text-yellow-600">📅 Ngày: 28/12/2025 - 10:30</p>
                                <p class="text-yellow-600">👨‍⚕️ Bác sĩ: Lê Thị D</p>
                                <p class="text-yellow-600">📝 Ghi chú: Kiểm tra tình trạng rụng lông</p>
                            </div>
                            <span class="status-badge" style="background: #fef3c7; color: #92400e;">Đang chờ</span>
                        </div>
                        <div class="mt-3">
                            <button class="bg-red-500 text-white px-3 py-1 rounded text-sm hover:bg-red-600">
                                <i class="fas fa-times mr-1"></i>Hủy lịch
                            </button>
                            <button class="bg-blue-500 text-white px-3 py-1 rounded text-sm hover:bg-blue-600 ml-2">
                                <i class="fas fa-edit mr-1"></i>Chỉnh sửa
                            </button>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- E. Đặt lịch khám mới -->
        <div class="card">
            <h2 class="section-title">
                <i class="fas fa-calendar-plus"></i>
                E. Đặt lịch khám mới
            </h2>
            
            <form action="#" method="post" class="max-w-2xl">
                <div class="form-group">
                    <label class="form-label">Ngày khám mong muốn</label>
                    <input type="date" class="form-input" name="appointmentDate" required>
                </div>
                
                <div class="form-group">
                    <label class="form-label">Giờ khám có sẵn</label>
                    <select class="form-select" name="timeSlot" required>
                        <option value="">Chọn giờ khám</option>
                        <% for (String slot : availableSlots) { %>
                            <option value="<%= slot %>"><%= slot %></option>
                        <% } %>
                    </select>
                    <p class="text-sm text-gray-600 mt-1">* Chỉ hiển thị các khung giờ còn trống</p>
                </div>
                
                <div class="form-group">
                    <label class="form-label">Chọn bác sĩ</label>
                    <select class="form-select" name="doctor" required>
                        <option value="">Chọn bác sĩ</option>
                        <% for (String doctor : doctors) { %>
                            <option value="<%= doctor %>"><%= doctor %></option>
                        <% } %>
                    </select>
                    <p class="text-sm text-gray-600 mt-1">* Bác sĩ bận sẽ không hiển thị trong danh sách</p>
                </div>
                
                <div class="form-group">
                    <label class="form-label">Mô tả triệu chứng (tùy chọn)</label>
                    <textarea class="form-textarea" name="symptoms" rows="4" 
                              placeholder="Mô tả chi tiết các triệu chứng bạn quan sát được..."></textarea>
                </div>
                
                <div class="form-group">
                    <button type="submit" class="btn-primary">
                        <i class="fas fa-calendar-check mr-2"></i>
                        Đặt lịch khám
                    </button>
                </div>
            </form>
        </div>
    </div>

    <script>
        // Set minimum date to today
        document.addEventListener('DOMContentLoaded', function() {
            const dateInput = document.querySelector('input[name="appointmentDate"]');
            const today = new Date().toISOString().split('T')[0];
            dateInput.min = today;
            
            // Set default date to tomorrow
            const tomorrow = new Date();
            tomorrow.setDate(tomorrow.getDate() + 1);
            dateInput.value = tomorrow.toISOString().split('T')[0];
        });

        // Form submission handler
        document.querySelector('form').addEventListener('submit', function(e) {
            e.preventDefault();
            alert('Lịch khám đã được đặt thành công! Chúng tôi sẽ liên hệ lại để xác nhận.');
        });

        // Show/Hide appointments functionality
        document.getElementById('showAppointments').addEventListener('click', function() {
            document.getElementById('appointmentsList').style.display = 'block';
            document.getElementById('showAppointments').style.display = 'none';
            document.getElementById('hideAppointments').style.display = 'inline-block';
        });

        document.getElementById('hideAppointments').addEventListener('click', function() {
            document.getElementById('appointmentsList').style.display = 'none';
            document.getElementById('showAppointments').style.display = 'inline-block';
            document.getElementById('hideAppointments').style.display = 'none';
        });

        // Cancel appointment functionality
        document.addEventListener('click', function(e) {
            if (e.target.closest('.bg-red-500')) {
                if (confirm('Bạn có chắc chắn muốn hủy lịch khám này?')) {
                    e.target.closest('.bg-yellow-50').style.opacity = '0.5';
                    e.target.closest('.bg-yellow-50').style.textDecoration = 'line-through';
                    alert('Lịch khám đã được hủy thành công!');
                }
            }
        });

        // Edit appointment functionality
        document.addEventListener('click', function(e) {
            if (e.target.closest('.bg-blue-500')) {
                alert('Tính năng chỉnh sửa lịch khám sẽ được triển khai trong phiên bản tiếp theo!');
            }
        });

        // User menu toggle
        document.addEventListener("DOMContentLoaded", function () {
            const btn = document.getElementById("userToggleBtn");
            const menu = document.getElementById("userMenu");

            if (btn && menu) {
                btn.addEventListener("click", function (e) {
                    e.stopPropagation();
                    menu.classList.toggle("hidden");
                });

                document.addEventListener("click", function (e) {
                    if (!menu.contains(e.target) && e.target !== btn) {
                        menu.classList.add("hidden");
                    }
                });
            }
        });
    </script>
</body>
</html>
