<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*, model.Customer, model.PetServiceModel" %>
<%@ page import="java.math.BigDecimal" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%
    Customer currentUser = (Customer) session.getAttribute("currentUser");
    Map<Integer, Integer> spaCart = (Map<Integer, Integer>) request.getAttribute("spaCart");
    List<PetServiceModel> spaServices = (List<PetServiceModel>) request.getAttribute("spaServices");
    BigDecimal totalPrice = (BigDecimal) request.getAttribute("totalPrice");
    Integer totalDuration = (Integer) request.getAttribute("totalDuration");
    
    if (spaCart == null) spaCart = new HashMap<>();
    if (spaServices == null) spaServices = new ArrayList<>();
    if (totalPrice == null) totalPrice = BigDecimal.ZERO;
    if (totalDuration == null) totalDuration = 0;
%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>🛒 Giỏ Hàng Spa - Pets4Care</title>
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

        .btn {
            padding: 0.75rem 1.5rem;
            border-radius: 8px;
            font-weight: 600;
            text-decoration: none;
            display: inline-block;
            transition: all 0.3s ease;
            border: none;
            cursor: pointer;
            font-size: 1rem;
        }

        .btn-primary {
            background: linear-gradient(135deg, var(--primary), var(--secondary));
            color: white;
        }

        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: var(--shadow);
        }

        .btn-secondary {
            background: #f3f4f6;
            color: var(--text);
            border: 1px solid var(--border);
        }

        .btn-secondary:hover {
            background: #e5e7eb;
        }

        .btn-danger {
            background: #ef4444;
            color: white;
        }

        .btn-danger:hover {
            background: #dc2626;
        }

        .service-item {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 1rem;
            border: 1px solid var(--border);
            border-radius: 8px;
            margin-bottom: 1rem;
            background: white;
        }

        .service-info {
            flex: 1;
        }

        .service-name {
            font-size: 1.125rem;
            font-weight: 600;
            color: var(--text);
            margin-bottom: 0.25rem;
        }

        .service-details {
            color: #6b7280;
            font-size: 0.875rem;
        }

        .quantity-controls {
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }

        .quantity-btn {
            width: 32px;
            height: 32px;
            border: 1px solid var(--border);
            background: white;
            border-radius: 4px;
            display: flex;
            align-items: center;
            justify-content: center;
            cursor: pointer;
            transition: all 0.3s ease;
        }

        .quantity-btn:hover {
            background: var(--accent);
        }

        .quantity-input {
            width: 60px;
            text-align: center;
            border: 1px solid var(--border);
            border-radius: 4px;
            padding: 0.5rem;
        }

        .price-display {
            font-size: 1.125rem;
            font-weight: 600;
            color: var(--primary);
        }

        .total-section {
            background: var(--accent);
            padding: 1.5rem;
            border-radius: 8px;
            margin-top: 2rem;
        }

        .total-row {
            display: flex;
            justify-content: space-between;
            margin-bottom: 0.5rem;
        }

        .total-final {
            font-size: 1.25rem;
            font-weight: 700;
            color: var(--primary);
            border-top: 2px solid var(--primary);
            padding-top: 0.5rem;
        }

        .empty-cart {
            text-align: center;
            padding: 4rem 2rem;
            color: #6b7280;
        }

        .empty-cart i {
            font-size: 4rem;
            margin-bottom: 1rem;
            color: #d1d5db;
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

        .form-input, .form-select, .form-textarea {
            width: 100%;
            padding: 0.75rem;
            border: 2px solid var(--border);
            border-radius: 8px;
            font-size: 1rem;
            transition: border-color 0.3s ease;
        }

        .form-input:focus, .form-select:focus, .form-textarea:focus {
            outline: none;
            border-color: var(--primary);
        }
    </style>
</head>
<body>
    <!-- Header -->
    <header class="header">
        <div class="container">
            <div class="flex items-center justify-between mb-4">
                <a href="${pageContext.request.contextPath}/home" class="flex items-center gap-4 hover:opacity-80 transition-opacity">
                    <div class="text-2xl font-bold">🐾 Pets4Care</div>
                    <div class="text-sm opacity-90">Giỏ hàng dịch vụ Spa</div>
                </a>
                <div class="flex items-center gap-4">
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
                <li><a href="${pageContext.request.contextPath}/home">TRANG CHỦ</a></li>
                <li><a href="spa-service.jsp" style="background: rgba(255, 255, 255, 0.2);">DỊCH VỤ SPA</a></li>
                <li><a href="<%= request.getContextPath()%>/health-check-booking">ĐẶT LỊCH KHÁM</a></li>
                <li><a href="search?categoryId=2">SẢN PHẨM</a></li>
                <li><a href="doctor.jsp">BÁC SĨ</a></li>
                <li><a href="gioi-thieu.jsp">GIỚI THIỆU</a></li>
                <li><a href="tin-tuc.jsp">TIN TỨC</a></li>
                <li><a href="lien-he.jsp">LIÊN HỆ</a></li>
            </ul>
        </nav>
    </header>

    <div class="container">
        <!-- Page Title -->
        <div class="text-center mb-8">
            <h1 class="text-3xl font-bold text-orange-600 mb-2">🛒 Giỏ Hàng Spa</h1>
            <p class="text-gray-600">Quản lý dịch vụ spa cho thú cưng yêu quý của bạn</p>
        </div>

        <!-- Alerts -->
        <c:if test="${not empty success}">
            <div class="bg-green-100 border-l-4 border-green-500 text-green-700 p-4 mb-4 rounded">
                <i class="fas fa-check-circle mr-2"></i>${success}
            </div>
        </c:if>
        
        <c:if test="${not empty error}">
            <div class="bg-red-100 border-l-4 border-red-500 text-red-700 p-4 mb-4 rounded">
                <i class="fas fa-exclamation-circle mr-2"></i>${error}
            </div>
        </c:if>

        <% if (spaCart.isEmpty()) { %>
        <!-- Empty Cart -->
        <div class="card">
            <div class="empty-cart">
                <i class="fas fa-spa"></i>
                <h3 class="text-xl font-semibold mb-2">Giỏ hàng Spa trống</h3>
                <p class="mb-4">Bạn chưa thêm dịch vụ spa nào vào giỏ hàng</p>
                <a href="spa-service.jsp" class="btn btn-primary">
                    <i class="fas fa-plus mr-2"></i>Thêm dịch vụ Spa
                </a>
            </div>
        </div>
        <% } else { %>
        
        <!-- Cart Items -->
        <div class="card">
            <h2 class="text-xl font-bold mb-4">💆 Dịch vụ Spa đã chọn</h2>
            
            <% for (PetServiceModel service : spaServices) { 
                int quantity = spaCart.get(service.getServiceId());
                BigDecimal itemTotal = service.getPrice().multiply(BigDecimal.valueOf(quantity));
            %>
            <div class="service-item" id="service-<%= service.getServiceId() %>">
                <div class="service-info">
                    <div class="service-name"><%= service.getName() %></div>
                    <div class="service-details">
                        <i class="fas fa-clock mr-1"></i><%= service.getDuration() %> phút
                        <span class="mx-2">•</span>
                        <i class="fas fa-tag mr-1"></i><fmt:formatNumber value="<%= service.getPrice() %>" type="currency" currencySymbol="₫" maxFractionDigits="0"/>
                    </div>
                </div>
                
                <div class="quantity-controls">
                    <button class="quantity-btn" onclick="updateQuantity(<%= service.getServiceId() %>, <%= quantity - 1 %>)">
                        <i class="fas fa-minus"></i>
                    </button>
                    <input type="number" class="quantity-input" value="<%= quantity %>" 
                           onchange="updateQuantity(<%= service.getServiceId() %>, this.value)" min="1">
                    <button class="quantity-btn" onclick="updateQuantity(<%= service.getServiceId() %>, <%= quantity + 1 %>)">
                        <i class="fas fa-plus"></i>
                    </button>
                </div>
                
                <div class="price-display">
                    <fmt:formatNumber value="<%= itemTotal %>" type="currency" currencySymbol="₫" maxFractionDigits="0"/>
                </div>
                
                <button class="btn btn-danger" onclick="removeService(<%= service.getServiceId() %>)">
                    <i class="fas fa-trash"></i>
                </button>
            </div>
            <% } %>
        </div>

        <!-- Booking Form -->
        <div class="card">
            <h2 class="text-xl font-bold mb-4">📅 Đặt lịch Spa</h2>
            
            <% if (currentUser == null) { %>
            <div class="bg-yellow-50 border border-yellow-400 rounded p-4 mb-4">
                <p class="text-yellow-700 mb-2">⚠️ Bạn cần đăng nhập để đặt lịch spa</p>
                <a href="login.jsp" class="btn btn-primary">🔐 Đăng nhập ngay</a>
            </div>
            <% } else { %>
            
            <form method="POST" action="${pageContext.request.contextPath}/spa-booking">
                <input type="hidden" name="action" value="create-booking">
                
                <div class="form-group">
                    <label class="form-label">Ngày hẹn</label>
                    <input type="date" name="appointmentDate" class="form-input" required>
                </div>
                
                <div class="form-group">
                    <label class="form-label">Giờ hẹn</label>
                    <select name="appointmentTime" class="form-select" required>
                        <option value="">Chọn giờ hẹn</option>
                        <option value="08:00">08:00</option>
                        <option value="09:00">09:00</option>
                        <option value="10:00">10:00</option>
                        <option value="11:00">11:00</option>
                        <option value="14:00">14:00</option>
                        <option value="15:00">15:00</option>
                        <option value="16:00">16:00</option>
                        <option value="17:00">17:00</option>
                    </select>
                </div>
                
                <div class="form-group">
                    <label class="form-label">Ghi chú (tùy chọn)</label>
                    <textarea name="note" class="form-textarea" rows="3" 
                              placeholder="Ghi chú đặc biệt cho dịch vụ spa..."></textarea>
                </div>
                
                <div class="total-section">
                    <div class="total-row">
                        <span>Tổng thời gian:</span>
                        <span><%= totalDuration %> phút</span>
                    </div>
                    <div class="total-row">
                        <span>Tổng giá trị:</span>
                        <span class="total-final">
                            <fmt:formatNumber value="<%= totalPrice %>" type="currency" currencySymbol="₫" maxFractionDigits="0"/>
                        </span>
                    </div>
                </div>
                
                <div class="flex gap-4 mt-6">
                    <a href="spa-service.jsp" class="btn btn-secondary">
                        <i class="fas fa-arrow-left mr-2"></i>Tiếp tục chọn dịch vụ
                    </a>
                    <button type="submit" class="btn btn-primary">
                        <i class="fas fa-calendar-check mr-2"></i>Đặt lịch Spa
                    </button>
                </div>
            </form>
            <% } %>
        </div>
        <% } %>
    </div>

    <script>
        // Set minimum date to today
        document.addEventListener('DOMContentLoaded', function() {
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

        function updateQuantity(serviceId, newQuantity) {
            if (newQuantity < 1) {
                removeService(serviceId);
                return;
            }
            
            // Update quantity in session via AJAX
            fetch('${pageContext.request.contextPath}/spa-booking', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                },
                body: `action=update-quantity&serviceId=${serviceId}&quantity=${newQuantity}`
            })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    location.reload();
                } else {
                    alert('Có lỗi xảy ra: ' + data.error);
                }
            })
            .catch(error => {
                console.error('Error:', error);
                alert('Có lỗi xảy ra khi cập nhật số lượng');
            });
        }

        function removeService(serviceId) {
            if (confirm('Bạn có chắc chắn muốn xóa dịch vụ này khỏi giỏ hàng?')) {
                fetch('${pageContext.request.contextPath}/spa-booking', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/x-www-form-urlencoded',
                    },
                    body: `action=remove-service&serviceId=${serviceId}`
                })
                .then(response => response.json())
                .then(data => {
                    if (data.success) {
                        location.reload();
                    } else {
                        alert('Có lỗi xảy ra: ' + data.error);
                    }
                })
                .catch(error => {
                    console.error('Error:', error);
                    alert('Có lỗi xảy ra khi xóa dịch vụ');
                });
            }
        }

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
