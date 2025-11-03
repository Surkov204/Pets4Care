<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<%@ page import="model.Customer" %>
<%@ page import="model.CartItem" %>
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
%>

<%
    // Sample doctor data - replace with actual database queries later
    String doctorId = request.getParameter("id") != null ? request.getParameter("id") : "1";
    
    Map<String, String> doctor = new HashMap<>();
    doctor.put("id", doctorId);
    doctor.put("name", "BS. Nguyễn Minh Anh");
    doctor.put("title", "Bác sĩ thú y cấp cao – Chuyên khoa da liễu");
    doctor.put("experience", "5 năm");
    doctor.put("location", "Phòng khám Pets4Care – Chi nhánh Hà Nội");
    doctor.put("rating", "4.8");
    doctor.put("reviewCount", "127");
    doctor.put("description", "Bác sĩ Minh Anh tốt nghiệp Đại học Nông nghiệp Hà Nội, có 5 năm kinh nghiệm điều trị các bệnh ngoài da, ký sinh trùng và dị ứng ở chó mèo. Bác sĩ được yêu thích bởi sự nhẹ nhàng và tận tâm với thú cưng.");
    doctor.put("specialty", "Da liễu & chăm sóc lông");
    doctor.put("education", "Đại học Nông nghiệp Hà Nội - Chuyên ngành Thú y");
    doctor.put("certifications", "Chứng chỉ Da liễu Thú y Quốc tế, Chứng chỉ Điều trị Dị ứng");
    doctor.put("languages", "Tiếng Việt, Tiếng Anh");
    
    // Sample reviews
    List<Map<String, String>> reviews = new ArrayList<>();
    
    Map<String, String> review1 = new HashMap<>();
    review1.put("customer", "Hoàng Anh");
    review1.put("rating", "5");
    review1.put("comment", "Bác sĩ rất thân thiện, Milu nhà mình hết rụng lông chỉ sau 2 tuần điều trị!");
    review1.put("date", "15/11/2025");
    review1.put("pet", "Milu (Chó Poodle)");
    reviews.add(review1);
    
    Map<String, String> review2 = new HashMap<>();
    review2.put("customer", "Minh Tuấn");
    review2.put("rating", "5");
    review2.put("comment", "Bác sĩ Minh Anh rất tận tâm và chuyên nghiệp. Con mèo nhà tôi bị viêm da nặng đã khỏi hoàn toàn.");
    review2.put("date", "08/11/2025");
    review2.put("pet", "Bé Mèo (Mèo Anh lông ngắn)");
    reviews.add(review2);
    
    Map<String, String> review3 = new HashMap<>();
    review3.put("customer", "Thảo Linh");
    review3.put("rating", "4");
    review3.put("comment", "Bác sĩ rất nhẹ nhàng với thú cưng, nhưng hơi đông khách nên phải đợi lâu.");
    review3.put("date", "02/11/2025");
    review3.put("pet", "Cookie (Chó Golden)");
    reviews.add(review3);
%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= doctor.get("name") %> - Pets4Care</title>
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

        .doctor-header {
            display: grid;
            grid-template-columns: auto 1fr auto;
            gap: 2rem;
            align-items: center;
            padding: 2rem 0;
        }

        .doctor-image {
            width: 150px;
            height: 150px;
            border-radius: 50%;
            object-fit: cover;
            border: 4px solid var(--accent);
        }

        .doctor-info h1 {
            font-size: 2rem;
            font-weight: 700;
            color: var(--primary);
            margin-bottom: 0.5rem;
        }

        .doctor-title {
            font-size: 1.1rem;
            color: var(--text);
            font-weight: 500;
            margin-bottom: 1rem;
        }

        .doctor-details {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 1rem;
        }

        .detail-item {
            display: flex;
            align-items: center;
            gap: 0.5rem;
            color: #6b7280;
        }

        .rating-display {
            display: flex;
            align-items: center;
            gap: 0.5rem;
            margin-top: 1rem;
        }

        .star {
            color: #fbbf24;
            font-size: 1.2rem;
        }

        .rating-text {
            font-size: 1.1rem;
            font-weight: 600;
            color: var(--text);
        }

        .review-count {
            color: #6b7280;
            font-size: 0.9rem;
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
            text-decoration: none;
            display: inline-block;
        }

        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: var(--shadow);
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

        .info-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 2rem;
        }

        .info-item {
            padding: 1rem;
            border-left: 4px solid var(--primary);
            background: #f8fafc;
            border-radius: 0 8px 8px 0;
        }

        .info-label {
            font-weight: 600;
            color: var(--primary);
            margin-bottom: 0.5rem;
        }

        .review-card {
            background: #f8fafc;
            border-radius: 8px;
            padding: 1.5rem;
            margin-bottom: 1rem;
            border-left: 4px solid var(--secondary);
        }

        .review-header {
            display: flex;
            justify-content: between;
            align-items: center;
            margin-bottom: 1rem;
        }

        .review-rating {
            display: flex;
            gap: 0.25rem;
            margin-bottom: 0.5rem;
        }

        .review-customer {
            font-weight: 600;
            color: var(--text);
        }

        .review-pet {
            color: #6b7280;
            font-size: 0.875rem;
        }

        .review-date {
            color: #6b7280;
            font-size: 0.875rem;
        }

        .review-comment {
            color: var(--text);
            line-height: 1.6;
        }

        .back-button {
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
            color: var(--primary);
            text-decoration: none;
            font-weight: 600;
            margin-bottom: 2rem;
            padding: 0.5rem 1rem;
            border-radius: 6px;
            transition: background 0.3s ease;
        }

        .back-button:hover {
            background: var(--accent);
        }

        @media (max-width: 768px) {
            .doctor-header {
                grid-template-columns: 1fr;
                text-align: center;
            }
            
            .doctor-details {
                grid-template-columns: 1fr;
            }
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
                    <div class="text-sm opacity-90">Hồ sơ bác sĩ</div>
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
                <li><a href="search?categoryId=2">SẢN PHẨM</a></li>
                <li><a href="doctor.jsp">BÁC SĨ</a></li>
                <li><a href="gioi-thieu.jsp">GIỚI THIỆU</a></li>
                <li><a href="tin-tuc.jsp">TIN TỨC</a></li>
                <li><a href="<%= request.getContextPath()%>/home">LIÊN HỆ</a></li>
            </ul>
        </nav>
    </header>

    <div class="container">
        <!-- Back Button -->
        <a href="doctor.jsp" class="back-button">
            <i class="fas fa-arrow-left"></i>
            Quay lại danh sách bác sĩ
        </a>

        <!-- Doctor Header -->
        <div class="card">
            <div class="doctor-header">
                <div class="doctor-image" style="background: linear-gradient(135deg, var(--primary), var(--secondary)); display: flex; align-items: center; justify-content: center; color: white; font-size: 3rem;">
                    👩‍⚕️
                </div>
                
                <div class="doctor-info">
                    <h1><%= doctor.get("name") %></h1>
                    <p class="doctor-title">🩺 <%= doctor.get("title") %></p>
                    
                    <div class="doctor-details">
                        <div class="detail-item">
                            <i class="fas fa-clock"></i>
                            <span>📅 <%= doctor.get("experience") %> kinh nghiệm</span>
                        </div>
                        <div class="detail-item">
                            <i class="fas fa-map-marker-alt"></i>
                            <span>📍 <%= doctor.get("location") %></span>
                        </div>
                        <div class="detail-item">
                            <i class="fas fa-graduation-cap"></i>
                            <span>🎓 <%= doctor.get("education") %></span>
                        </div>
                        <div class="detail-item">
                            <i class="fas fa-language"></i>
                            <span>🗣️ <%= doctor.get("languages") %></span>
                        </div>
                    </div>
                    
                    <div class="rating-display">
                        <% 
                        double rating = Double.parseDouble(doctor.get("rating"));
                        for (int i = 1; i <= 5; i++) {
                            if (i <= Math.floor(rating)) {
                        %>
                            <i class="fas fa-star star"></i>
                        <% } else if (i - 0.5 <= rating) { %>
                            <i class="fas fa-star-half-alt star"></i>
                        <% } else { %>
                            <i class="far fa-star star"></i>
                        <% }} %>
                        <span class="rating-text"><%= doctor.get("rating") %></span>
                        <span class="review-count">(<%= doctor.get("reviewCount") %> đánh giá)</span>
                    </div>
                </div>
                
                <div>
                    <a href="<%= request.getContextPath()%>/health-check-booking?doctor=<%= doctor.get("id") %>" class="btn-primary">
                        🩺 Đặt lịch với bác sĩ này
                    </a>
                </div>
            </div>
        </div>

        <!-- Doctor Description -->
        <div class="card">
            <h2 class="section-title">
                <i class="fas fa-info-circle"></i>
                Giới thiệu về bác sĩ
            </h2>
            <p class="text-lg leading-relaxed"><%= doctor.get("description") %></p>
        </div>

        <!-- Professional Information -->
        <div class="card">
            <h2 class="section-title">
                <i class="fas fa-user-md"></i>
                Thông tin chuyên môn
            </h2>
            <div class="info-grid">
                <div class="info-item">
                    <div class="info-label">Chuyên khoa</div>
                    <div>🩺 <%= doctor.get("specialty") %></div>
                </div>
                <div class="info-item">
                    <div class="info-label">Trình độ học vấn</div>
                    <div>🎓 <%= doctor.get("education") %></div>
                </div>
                <div class="info-item">
                    <div class="info-label">Chứng chỉ</div>
                    <div>📜 <%= doctor.get("certifications") %></div>
                </div>
                <div class="info-item">
                    <div class="info-label">Ngôn ngữ</div>
                    <div>🗣️ <%= doctor.get("languages") %></div>
                </div>
            </div>
        </div>

        <!-- Reviews Section -->
        <div class="card">
            <h2 class="section-title">
                <i class="fas fa-star"></i>
                Đánh giá & phản hồi từ khách hàng
            </h2>
            
            <% for (Map<String, String> review : reviews) { %>
            <div class="review-card">
                <div class="review-header">
                    <div>
                        <div class="review-rating">
                            <% 
                            int reviewRating = Integer.parseInt(review.get("rating"));
                            for (int i = 1; i <= 5; i++) {
                                if (i <= reviewRating) {
                            %>
                                <i class="fas fa-star star"></i>
                            <% } else { %>
                                <i class="far fa-star star"></i>
                            <% }} %>
                        </div>
                        <div class="review-customer">💬 <%= review.get("customer") %></div>
                        <div class="review-pet">🐾 <%= review.get("pet") %></div>
                        <div class="review-date">📅 <%= review.get("date") %></div>
                    </div>
                </div>
                <div class="review-comment">"<%= review.get("comment") %>"</div>
            </div>
            <% } %>
            
            <!-- Add Review Button -->
            <div class="text-center mt-6">
                <button class="btn-primary" onclick="alert('Tính năng đánh giá sẽ được triển khai sau khi hoàn thành dịch vụ!')">
                    <i class="fas fa-comment-dots mr-2"></i>
                    Để lại đánh giá
                </button>
            </div>
        </div>
    </div>

    <script>
        // Add smooth scrolling for better UX
        document.querySelectorAll('a[href^="#"]').forEach(anchor => {
            anchor.addEventListener('click', function (e) {
                e.preventDefault();
                document.querySelector(this.getAttribute('href')).scrollIntoView({
                    behavior: 'smooth'
                });
            });
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
