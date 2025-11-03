<%@page import="model.Customer"%>
<%@page import="model.CartItem"%>
<%@page import="model.PetServiceModel"%>
<%@page import="model.Pet"%>
<%@page import="model.Review"%>
<%@page import="java.util.Map"%>
<%@page import="java.util.List"%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%
    Customer currentUser = (Customer) session.getAttribute("currentUser");
    Map<Integer, CartItem> cart = (Map<Integer, CartItem>) session.getAttribute("cart");
    int cartCount = 0;
    double cartTotal = 0;
    if (cart != null) {
        for (CartItem item : cart.values()) {
            if (item != null && item.getProduct() != null) {
                cartCount += item.getQuantity();
                cartTotal += item.getQuantity() * item.getProduct().getPrice();
            }
        }
    }
    
    // Get service from request attributes
    PetServiceModel service = (PetServiceModel) request.getAttribute("service");
    List<Review> reviews = (List<Review>) request.getAttribute("reviews");
    List<Pet> customerPets = (List<Pet>) request.getAttribute("customerPets");
    
    if (service == null) {
        response.sendRedirect(request.getContextPath() + "/spa-booking?action=services");
        return;
    }
    
    // Calculate average rating
    double avgRating = 0;
    if (reviews != null && !reviews.isEmpty()) {
        int totalRating = 0;
        int count = 0;
        for (Review review : reviews) {
            if (review != null && review.getRating() > 0) {
                totalRating += review.getRating();
                count++;
            }
        }
        if (count > 0) {
            avgRating = (double) totalRating / count;
        }
    }
%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title><%= service.getName() %> - Petcity</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.3/css/all.min.css" rel="stylesheet" />
    <link href="https://fonts.googleapis.com/css2?family=Quicksand:wght@300;400;500;600;700&family=Nunito:wght@300;400;500;600;700;800&family=Baloo+2:wght@400;500;600;700;800&display=swap" rel="stylesheet" />
    <link rel="stylesheet" href="css/homeStyle.css" />
    <style>
        .service-icon-large {
            font-size: 8rem;
            margin-bottom: 1rem;
        }
        .price-tag-large {
            background: linear-gradient(135deg, #ff6b6b, #ffa500);
            color: white;
            padding: 1rem 2rem;
            border-radius: 25px;
            font-weight: bold;
            font-size: 2rem;
            display: inline-block;
        }
        .detail-card {
            transition: all 0.3s ease;
            border-radius: 15px;
            overflow: hidden;
            box-shadow: 0 4px 15px rgba(0,0,0,0.1);
        }
        .btn-add-to-cart {
            background: linear-gradient(135deg, #ff6b6b, #ffa500);
            color: white;
            padding: 1rem 3rem;
            border-radius: 25px;
            text-decoration: none;
            font-weight: bold;
            font-size: 1.2rem;
            transition: all 0.3s ease;
            display: inline-block;
            border: none;
            cursor: pointer;
        }
        .btn-add-to-cart:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(255, 107, 107, 0.4);
        }
        .quantity-input {
            width: 80px;
            text-align: center;
            padding: 0.5rem;
            border: 2px solid #ddd;
            border-radius: 8px;
            font-size: 1.1rem;
        }
    </style>
</head>
<body class="bg-gray-50">
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
            <img src="https://storage.googleapis.com/a1aa/image/15870274-75b6-4029-e89c-1424dc010c18.jpg" width="60" height="60" alt="Logo Petcity" />
            <div>
                <div class="logo-text">petcity</div>
                <div class="logo-subtext">thành phố thú cưng</div>
            </div>
        </a>

        <form class="search-form relative" method="get" action="search" autocomplete="off">
            <input type="text" name="keyword" placeholder="🔍 Tìm kiếm dịch vụ..." required>
            <button type="submit"><i class="fas fa-search"></i></button>
        </form>

        <div class="contact-info">
            <div><i class="far fa-clock"></i> 08:00 - 17:00</div>
            <div>
                <% if (currentUser == null) { %>
                <a href="login.jsp" class="text-sm hover:underline">👤 Đăng Ký | Đăng Nhập</a>
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
            <div>
                <a href="<%= request.getContextPath()%>/cart/cart.jsp">
                    <i class="fas fa-shopping-cart"></i> Giỏ hàng / <span class="cart-amount"><%= String.format("%.2f", cartTotal)%></span>₫
                </a>
                <span class="cart-count"><%= cartCount%></span>
            </div>
            <div>
                <a href="<%= request.getContextPath()%>/spa-booking?action=cart">
                    <i class="fas fa-spa"></i> Giỏ Spa
                </a>
            </div>
        </div>
    </header>

    <!-- Navigation -->
    <nav>
        <ul>
            <li><a href="<%= request.getContextPath()%>/home">TRANG CHỦ</a></li>
            <li><a href="${pageContext.request.contextPath}/spa-service" style="background: rgba(255, 255, 255, 0.2);">DỊCH VỤ</a></li>
            <li><a href="<%= request.getContextPath()%>/health-check-booking">ĐẶT LỊCH KHÁM</a></li>
            <li><a href="search?categoryId=2">SẢN PHẨM</a></li>
            <li><a href="doctor.jsp">BÁC SĨ</a></li>
            <li><a href="gioi-thieu.jsp">GIỚI THIỆU</a></li>
            <li><a href="tin-tuc.jsp">TIN TỨC</a></li>
            <li><a href="<%= request.getContextPath()%>/home">LIÊN HỆ</a></li>
        </ul>
    </nav>

    <!-- Breadcrumb -->
    <div class="container mx-auto px-6 py-4">
        <nav class="text-sm text-gray-600">
            <a href="<%= request.getContextPath()%>/home" class="hover:text-orange-600">Trang chủ</a>
            <span class="mx-2">/</span>
            <a href="${pageContext.request.contextPath}/spa-service" class="hover:text-orange-600">Dịch vụ Spa</a>
            <span class="mx-2">/</span>
            <span class="text-gray-800"><%= service.getName() %></span>
        </nav>
    </div>

    <!-- Main Content -->
    <main class="container mx-auto px-6 py-10">
        <!-- Service Detail Card -->
        <div class="bg-white rounded-lg shadow-lg p-8 mb-8">
            <div class="grid md:grid-cols-2 gap-8">
                <!-- Left: Service Icon/Image -->
                <div class="text-center">
                    <div class="service-icon-large">
                        <% 
                            String icon = "🛁"; // default
                            String serviceName = service.getName().toLowerCase();
                            if (serviceName.contains("cắt") || serviceName.contains("tỉa")) {
                                icon = "✂️";
                            } else if (serviceName.contains("móng")) {
                                icon = "💅";
                            } else if (serviceName.contains("tai") || serviceName.contains("răng")) {
                                icon = "🦷";
                            } else if (serviceName.contains("massage")) {
                                icon = "💆";
                            } else if (serviceName.contains("cao cấp") || serviceName.contains("spa")) {
                                icon = "✨";
                            } else if (serviceName.contains("thuốc") || serviceName.contains("ký sinh")) {
                                icon = "🧴";
                            } else if (serviceName.contains("da") || serviceName.contains("lông")) {
                                icon = "🌿";
                            }
                        %>
                        <%= icon %>
                    </div>
                </div>

                <!-- Right: Service Info -->
                <div class="space-y-6">
                    <h1 class="text-4xl font-bold text-gray-800"><%= service.getName() %></h1>
                    
                    <!-- Rating -->
                    <div class="flex items-center gap-2">
                        <% 
                            int fullStars = (int) avgRating;
                            boolean hasHalfStar = avgRating - fullStars >= 0.5;
                            for (int i = 1; i <= 5; i++) {
                                if (i <= fullStars) {
                        %>
                        <i class="fas fa-star text-yellow-400 text-xl"></i>
                        <% } else if (i == fullStars + 1 && hasHalfStar) { %>
                        <i class="fas fa-star-half-alt text-yellow-400 text-xl"></i>
                        <% } else { %>
                        <i class="far fa-star text-yellow-400 text-xl"></i>
                        <% } } %>
                        <span class="text-gray-600 ml-2">
                            (<%= avgRating > 0 ? String.format("%.1f", avgRating) : "Chưa có"%>/5.0)
                        </span>
                        <span class="text-gray-500 text-sm">
                            <% if (reviews != null) { %>- <%= reviews.size() %> đánh giá<% } %>
                        </span>
                    </div>

                    <!-- Price -->
                    <div>
                        <span class="price-tag-large">
                            <fmt:formatNumber value="<%= service.getPrice() %>" type="currency" currencySymbol="₫" maxFractionDigits="0"/>
                        </span>
                    </div>

                    <!-- Duration -->
                    <div class="flex items-center gap-4">
                        <div class="bg-blue-100 text-blue-800 px-4 py-2 rounded-lg">
                            <i class="far fa-clock mr-2"></i>
                            <span class="font-semibold">Thời gian: <%= service.getDuration() %> phút</span>
                        </div>
                    </div>

                    <!-- Description -->
                    <div class="border-t pt-4">
                        <h3 class="text-lg font-semibold text-gray-800 mb-2">📝 Mô tả dịch vụ</h3>
                        <p class="text-gray-700 leading-relaxed">
                            <%= service.getDescription() != null && !service.getDescription().trim().isEmpty() 
                                ? service.getDescription() 
                                : "Dịch vụ spa chuyên nghiệp cho thú cưng của bạn. Được thực hiện bởi đội ngũ kỹ thuật viên giàu kinh nghiệm với các sản phẩm an toàn, tự nhiên." %>
                        </p>
                    </div>

                    <!-- Quantity Selection -->
                    <div class="flex items-center gap-4 border-t pt-4">
                        <label for="quantity" class="text-lg font-semibold text-gray-800">Số lượng:</label>
                        <div class="flex items-center gap-2">
                            <button type="button" onclick="decreaseQuantity()" class="bg-gray-200 hover:bg-gray-300 px-4 py-2 rounded-lg font-bold">-</button>
                            <input type="number" id="quantity" name="quantity" value="1" min="1" max="10" class="quantity-input" readonly>
                            <button type="button" onclick="increaseQuantity()" class="bg-gray-200 hover:bg-gray-300 px-4 py-2 rounded-lg font-bold">+</button>
                        </div>
                    </div>

                    <!-- Add to Cart Button -->
                    <div class="border-t pt-6">
                        <form method="POST" action="${pageContext.request.contextPath}/spa-booking" id="addToCartForm">
                            <input type="hidden" name="action" value="add-to-cart">
                            <input type="hidden" name="serviceId" value="<%= service.getServiceId() %>">
                            <input type="hidden" name="quantity" id="hiddenQuantity" value="1">
                            <button type="submit" class="btn-add-to-cart w-full">
                                🛒 Thêm vào giỏ Spa
                            </button>
                        </form>
                    </div>
                </div>
            </div>
        </div>

        <!-- Reviews Section -->
        <div class="bg-white rounded-lg shadow-lg p-8 mt-8">
            <div class="flex items-center justify-between mb-6">
                <h2 class="text-3xl font-bold text-gray-800">⭐ Đánh giá dịch vụ</h2>
                <div class="text-right">
                    <div class="text-2xl font-bold text-orange-600">
                        <%= avgRating > 0 ? String.format("%.1f", avgRating) : "0.0" %>/5.0
                    </div>
                    <div class="text-sm text-gray-600">
                        <% if (reviews != null && !reviews.isEmpty()) { %>
                            Từ <%= reviews.size() %> đánh giá
                        <% } else { %>
                            Chưa có đánh giá
                        <% } %>
                    </div>
                </div>
            </div>
            
            <% if (reviews == null || reviews.isEmpty()) { %>
            <div class="text-center py-16 bg-gray-50 rounded-lg">
                <div class="text-6xl mb-4">📝</div>
                <p class="text-gray-600 text-lg font-medium mb-2">Chưa có đánh giá nào cho dịch vụ này</p>
                <p class="text-gray-500 text-sm">Hãy là người đầu tiên đánh giá dịch vụ này sau khi sử dụng!</p>
            </div>
            <% } else { %>
            <!-- Rating Summary -->
            <div class="mb-6 pb-4 border-b">
                <div class="mb-3">
                    <button onclick="filterReviews(0)" id="filter-all" class="px-3 py-1.5 text-sm bg-blue-500 text-white rounded-lg hover:bg-blue-600 transition mr-2 font-medium">
                        Tất cả
                    </button>
                </div>
                <div class="space-y-2">
                    <% 
                        int[] ratingCounts = new int[6]; // 0-5
                        if (reviews != null) {
                            for (Review review : reviews) {
                                if (review != null && review.getRating() >= 1 && review.getRating() <= 5) {
                                    ratingCounts[review.getRating()]++;
                                }
                            }
                        }
                    %>
                    <% for (int star = 5; star >= 1; star--) { %>
                        <div class="flex items-center gap-3 cursor-pointer hover:bg-gray-50 p-1.5 rounded transition-colors" 
                             onclick="filterReviews(<%= star %>)" 
                             id="filter-rating-<%= star %>"
                             data-rating="<%= star %>">
                            <div class="flex items-center gap-1.5 min-w-[80px]">
                                <span class="text-gray-700 text-sm font-medium"><%= star %> sao</span>
                                <div class="flex">
                                    <% for (int i = 0; i < star; i++) { %>
                                    <i class="fas fa-star text-yellow-400 text-xs"></i>
                                    <% } %>
                                </div>
                            </div>
                            <div class="flex-1 bg-gray-200 rounded-full h-2 max-w-xs">
                                <% 
                                    double percentage = 0;
                                    if (reviews != null && reviews.size() > 0) {
                                        percentage = (ratingCounts[star] * 100.0) / reviews.size();
                                    }
                                %>
                                <div class="bg-yellow-400 h-2 rounded-full" 
                                     style="width: <%= String.format("%.1f", percentage) %>%"></div>
                            </div>
                            <span class="text-gray-600 text-xs font-medium min-w-[2rem] text-right"><%= ratingCounts[star] %></span>
                        </div>
                    <% } %>
                </div>
            </div>
            
            <!-- Reviews List -->
            <div class="space-y-6" id="reviews-container">
                <% 
                if (reviews != null && !reviews.isEmpty()) {
                    for (Review review : reviews) {
                        if (review == null) continue;
                %>
                <div class="border border-gray-200 rounded-lg p-6 hover:shadow-md transition-shadow review-item" 
                     data-rating="<%= review.getRating() %>"
                     style="opacity: 1; transition: opacity 0.3s ease;">
                    <div class="flex items-start gap-4">
                        <!-- Avatar -->
                        <div class="w-14 h-14 bg-gradient-to-br from-orange-400 to-pink-400 rounded-full flex items-center justify-center text-white font-bold text-xl flex-shrink-0">
                            <% 
                                String customerName = review.getCustomerName();
                                String initial = "U";
                                if (customerName != null && !customerName.isEmpty()) {
                                    initial = customerName.charAt(0) + "";
                                    initial = initial.toUpperCase();
                                }
                            %>
                            <%= initial %>
                        </div>
                        
                        <!-- Review Content -->
                        <div class="flex-1">
                            <div class="flex items-center justify-between mb-3">
                                <div>
                                    <span class="font-semibold text-gray-800 text-lg">
                                        <%= customerName != null && !customerName.isEmpty() ? customerName : "Khách hàng" %>
                                    </span>
                                    <span class="text-gray-500 text-sm ml-2">
                                        <% if (review.getCreatedAt() != null) { %>
                                            <%= new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm").format(review.getCreatedAt()) %>
                                        <% } %>
                                    </span>
                                </div>
                                <div class="flex items-center gap-1">
                                    <% 
                                        int rating = review.getRating();
                                        for (int i = 1; i <= 5; i++) {
                                            if (i <= rating) {
                                    %>
                                    <i class="fas fa-star text-yellow-400"></i>
                                    <% } else { %>
                                    <i class="far fa-star text-yellow-400"></i>
                                    <% } } %>
                                    <span class="ml-2 text-gray-600 font-medium"><%= rating %>/5</span>
                                </div>
                            </div>
                            
                            <% 
                                String comment = review.getComment();
                                if (comment != null && !comment.trim().isEmpty()) {
                            %>
                            <div class="bg-gray-50 rounded-lg p-4 mt-3">
                                <p class="text-gray-700 leading-relaxed"><%= comment %></p>
                            </div>
                            <% } else { %>
                            <p class="text-gray-500 italic text-sm mt-2">Khách hàng này chưa để lại nhận xét.</p>
                            <% } %>
                        </div>
                    </div>
                </div>
                <% 
                    }
                }
                %>
            </div>
            
            <!-- Pagination or Load More (if needed) -->
            <% if (reviews != null && reviews.size() >= 50) { %>
            <div class="mt-6 text-center">
                <p class="text-gray-500 text-sm">Đang hiển thị 50 đánh giá mới nhất</p>
            </div>
            <% } %>
            <% } %>
        </div>
    </main>

    <!-- Footer -->
    <footer>
        <div class="footer-content">
            <div class="footer-section">
                <h3>🏪 Thông tin liên hệ</h3>
                <p>📍 Địa chỉ: Môn SWP</p>
                <p>📞 Điện thoại: 090 900 900</p>
                <p>📧 Email: support@petcity.vn</p>
            </div>
            <div class="footer-section">
                <h3>📋 Chính sách</h3>
                <p><a href="#">Chính sách bảo mật</a></p>
                <p><a href="#">Điều khoản sử dụng</a></p>
                <p><a href="#">Chính sách đổi trả</a></p>
            </div>
            <div class="footer-section">
                <h3>🌐 Kết nối với chúng tôi</h3>
                <div class="social-links">
                    <a href="#" title="Facebook"><i class="fab fa-facebook-f"></i></a>
                    <a href="#" title="Instagram"><i class="fab fa-instagram"></i></a>
                    <a href="#" title="Twitter"><i class="fab fa-twitter"></i></a>
                    <a href="#" title="YouTube"><i class="fab fa-youtube"></i></a>
                </div>
            </div>
        </div>
        <div class="footer-bottom">
            <p>© 2025 Petcity. Bản quyền thuộc về G5. ❤️ Made with love for pets</p>
        </div>
    </footer>

    <script>
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

        // Quantity controls
        function increaseQuantity() {
            const qtyInput = document.getElementById('quantity');
            const hiddenQtyInput = document.getElementById('hiddenQuantity');
            let currentQty = parseInt(qtyInput.value) || 1;
            if (currentQty < 10) {
                currentQty++;
                qtyInput.value = currentQty;
                hiddenQtyInput.value = currentQty;
            }
        }

        function decreaseQuantity() {
            const qtyInput = document.getElementById('quantity');
            const hiddenQtyInput = document.getElementById('hiddenQuantity');
            let currentQty = parseInt(qtyInput.value) || 1;
            if (currentQty > 1) {
                currentQty--;
                qtyInput.value = currentQty;
                hiddenQtyInput.value = currentQty;
            }
        }

        // Filter reviews by rating
        let currentFilter = 0; // 0 = all, 1-5 = specific rating

        function filterReviews(rating) {
            currentFilter = rating;
            
            // Update button states
            const allButton = document.getElementById('filter-all');
            const ratingButtons = document.querySelectorAll('[id^="filter-rating-"]');
            
            // Reset all buttons
            allButton.classList.remove('bg-blue-600');
            allButton.classList.remove('bg-blue-500');
            ratingButtons.forEach(btn => {
                btn.classList.remove('bg-blue-100', 'border-2', 'border-blue-500');
            });
            
            // Highlight selected filter
            if (rating === 0) {
                allButton.classList.add('bg-blue-600');
            } else {
                const selectedBtn = document.getElementById('filter-rating-' + rating);
                if (selectedBtn) {
                    selectedBtn.classList.add('bg-blue-100', 'border-2', 'border-blue-500');
                }
            }
            
            // Filter review items
            const reviewItems = document.querySelectorAll('.review-item');
            let visibleCount = 0;
            
            reviewItems.forEach(item => {
                const itemRating = parseInt(item.getAttribute('data-rating'));
                
                if (rating === 0 || itemRating === rating) {
                    item.style.display = 'block';
                    visibleCount++;
                    // Add fade in animation
                    setTimeout(() => {
                        item.style.opacity = '1';
                    }, 10);
                } else {
                    item.style.display = 'none';
                }
            });
            
            // Show message if no reviews found
            const container = document.getElementById('reviews-container');
            let noResultsMsg = document.getElementById('no-results-message');
            
            if (visibleCount === 0 && rating > 0) {
                if (!noResultsMsg) {
                    noResultsMsg = document.createElement('div');
                    noResultsMsg.id = 'no-results-message';
                    noResultsMsg.className = 'text-center py-12 bg-gray-50 rounded-lg';
                }
                noResultsMsg.innerHTML = `
                    <div class="text-4xl mb-4">🔍</div>
                    <p class="text-gray-600 text-lg font-medium">Không có đánh giá ${rating} sao nào</p>
                `;
                noResultsMsg.style.display = 'block';
                container.appendChild(noResultsMsg);
            } else {
                if (noResultsMsg) {
                    noResultsMsg.style.display = 'none';
                }
            }
        }
        
        // Initialize: show all reviews by default
        document.addEventListener('DOMContentLoaded', function() {
            const allButton = document.getElementById('filter-all');
            if (allButton) {
                allButton.classList.add('bg-blue-600');
            }
        });
    </script>
</body>
</html>

