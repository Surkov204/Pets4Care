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
            if (item != null && item.getToy() != null) {
                cartCount += item.getQuantity();
                cartTotal += item.getQuantity() * item.getToy().getPrice();
            }
        }
    }
%>

<%
    // Sample doctor data - replace with actual database queries later
    List<Map<String, String>> doctors = new ArrayList<>();
    
    Map<String, String> doctor1 = new HashMap<>();
    doctor1.put("id", "1");
    doctor1.put("name", "BS. Nguyễn Minh Anh");
    doctor1.put("specialty", "Da liễu & chăm sóc lông");
    doctor1.put("experience", "5 năm");
    doctor1.put("rating", "4.8");
    doctor1.put("location", "Chi nhánh Hà Nội");
    doctors.add(doctor1);
    
    Map<String, String> doctor2 = new HashMap<>();
    doctor2.put("id", "2");
    doctor2.put("name", "BS. Trần Văn Cường");
    doctor2.put("specialty", "Phẫu thuật & chỉnh hình");
    doctor2.put("experience", "8 năm");
    doctor2.put("rating", "4.9");
    doctor2.put("location", "Chi nhánh TP.HCM");
    doctors.add(doctor2);
    
    Map<String, String> doctor3 = new HashMap<>();
    doctor3.put("id", "3");
    doctor3.put("name", "BS. Lê Thị Mai");
    doctor3.put("specialty", "Tim mạch & hô hấp");
    doctor3.put("experience", "6 năm");
    doctor3.put("rating", "4.7");
    doctor3.put("location", "Chi nhánh Hà Nội");
    doctors.add(doctor3);
    
    Map<String, String> doctor4 = new HashMap<>();
    doctor4.put("id", "4");
    doctor4.put("name", "BS. Phạm Đức Minh");
    doctor4.put("specialty", "Tiêu hóa & dinh dưỡng");
    doctor4.put("experience", "4 năm");
    doctor4.put("rating", "4.6");
    doctor4.put("location", "Chi nhánh Đà Nẵng");
    doctors.add(doctor4);
    
    Map<String, String> doctor5 = new HashMap<>();
    doctor5.put("id", "5");
    doctor5.put("name", "BS. Võ Thị Hương");
    doctor5.put("specialty", "Sản khoa & sinh sản");
    doctor5.put("experience", "7 năm");
    doctor5.put("rating", "4.9");
    doctor5.put("location", "Chi nhánh TP.HCM");
    doctors.add(doctor5);
    
    Map<String, String> doctor6 = new HashMap<>();
    doctor6.put("id", "6");
    doctor6.put("name", "BS. Đặng Văn Tùng");
    doctor6.put("specialty", "Thần kinh & hành vi");
    doctor6.put("experience", "10 năm");
    doctor6.put("rating", "5.0");
    doctor6.put("location", "Chi nhánh Hà Nội");
    doctors.add(doctor6);
%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đội Ngũ Bác Sĩ - Pets4Care</title>
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

        .doctor-card {
            background: var(--card-bg);
            border-radius: var(--border-radius);
            box-shadow: var(--shadow-light);
            padding: 1.5rem;
            text-align: center;
            transition: transform 0.3s ease, box-shadow 0.3s ease;
            border: 1px solid var(--border);
        }

        .doctor-card:hover {
            transform: translateY(-4px);
            box-shadow: var(--shadow);
        }

        .doctor-image {
            width: 120px;
            height: 120px;
            border-radius: 50%;
            object-fit: cover;
            border: 4px solid var(--accent);
            margin: 0 auto 1rem;
        }

        .doctor-name {
            font-size: 1.25rem;
            font-weight: 700;
            color: var(--primary);
            margin-bottom: 0.5rem;
        }

        .doctor-specialty {
            color: var(--text);
            font-weight: 500;
            margin-bottom: 0.5rem;
        }

        .doctor-experience {
            color: #6b7280;
            font-size: 0.875rem;
            margin-bottom: 0.5rem;
        }

        .doctor-rating {
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 0.25rem;
            margin-bottom: 1rem;
        }

        .star {
            color: #fbbf24;
        }

        .rating-text {
            color: #6b7280;
            font-size: 0.875rem;
            margin-left: 0.25rem;
        }

        .btn {
            padding: 0.5rem 1rem;
            border-radius: 6px;
            font-weight: 600;
            text-decoration: none;
            display: inline-block;
            transition: all 0.3s ease;
            margin: 0.25rem;
            font-size: 0.875rem;
        }

        .btn-primary {
            background: linear-gradient(135deg, var(--primary), var(--secondary));
            color: white;
            border: none;
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

        .section-title {
            font-size: 2rem;
            font-weight: 700;
            color: var(--primary);
            text-align: center;
            margin-bottom: 1rem;
        }

        .section-subtitle {
            text-align: center;
            color: #6b7280;
            margin-bottom: 3rem;
        }

        .grid-3-cols {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 2rem;
        }

        .search-filter {
            background: var(--card-bg);
            border-radius: var(--border-radius);
            box-shadow: var(--shadow-light);
            padding: 1.5rem;
            margin-bottom: 2rem;
            border: 1px solid var(--border);
        }

        .search-input {
            width: 100%;
            padding: 0.75rem;
            border: 2px solid var(--border);
            border-radius: 8px;
            font-size: 1rem;
            transition: border-color 0.3s ease;
        }

        .search-input:focus {
            outline: none;
            border-color: var(--primary);
        }

        .filter-buttons {
            display: flex;
            gap: 0.5rem;
            margin-top: 1rem;
            flex-wrap: wrap;
        }

        .filter-btn {
            padding: 0.5rem 1rem;
            border: 1px solid var(--border);
            background: white;
            border-radius: 20px;
            font-size: 0.875rem;
            cursor: pointer;
            transition: all 0.3s ease;
        }

        .filter-btn.active {
            background: var(--primary);
            color: white;
            border-color: var(--primary);
        }

        .filter-btn:hover {
            background: var(--accent);
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
                    <div class="text-sm opacity-90">Đội ngũ bác sĩ chuyên nghiệp</div>
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
                <li><a href="dat-lich-kham.jsp">ĐẶT LỊCH KHÁM</a></li>
                <li><a href="search?categoryId=2">SẢN PHẨM</a></li>
                <li><a href="doctor.jsp" style="background: rgba(255, 255, 255, 0.2);">BÁC SĨ</a></li>
                <li><a href="gioi-thieu.jsp">GIỚI THIỆU</a></li>
                <li><a href="tin-tuc.jsp">TIN TỨC</a></li>
                <li><a href="lien-he.jsp">LIÊN HỆ</a></li>
            </ul>
        </nav>
    </header>

    <div class="container">
        <!-- Page Title -->
        <div class="text-center mb-8">
            <h1 class="section-title">👩‍⚕️ Đội Ngũ Bác Sĩ</h1>
            <p class="section-subtitle">Đội ngũ bác sĩ thú y giàu kinh nghiệm, tận tâm với từng chú thú cưng</p>
        </div>

        <!-- Search and Filter -->
        <div class="search-filter">
            <input type="text" id="searchInput" class="search-input" placeholder="🔍 Tìm kiếm bác sĩ theo tên hoặc chuyên khoa...">
            <div class="filter-buttons">
                <button class="filter-btn active" data-filter="all">Tất cả</button>
                <button class="filter-btn" data-filter="da-lieu">Da liễu</button>
                <button class="filter-btn" data-filter="phau-thuat">Phẫu thuật</button>
                <button class="filter-btn" data-filter="tim-mach">Tim mạch</button>
                <button class="filter-btn" data-filter="tieu-hoa">Tiêu hóa</button>
                <button class="filter-btn" data-filter="san-khoa">Sản khoa</button>
                <button class="filter-btn" data-filter="than-kinh">Thần kinh</button>
            </div>
        </div>

        <!-- Doctor Grid -->
        <div class="grid-3-cols" id="doctorGrid">
            <% for (Map<String, String> doctor : doctors) { %>
            <div class="doctor-card" data-specialty="<%= doctor.get("specialty").toLowerCase() %>">
                <div class="doctor-image" style="background: linear-gradient(135deg, var(--primary), var(--secondary)); display: flex; align-items: center; justify-content: center; color: white; font-size: 2.5rem;">
                    👩‍⚕️
                </div>
                
                <h3 class="doctor-name"><%= doctor.get("name") %></h3>
                <p class="doctor-specialty">🩺 <%= doctor.get("specialty") %></p>
                <p class="doctor-experience">📅 <%= doctor.get("experience") %> kinh nghiệm</p>
                
                <div class="doctor-rating">
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
                    <span class="rating-text">(<%= doctor.get("rating") %>/5)</span>
                </div>
                
                <p class="text-sm text-gray-600 mb-4">📍 <%= doctor.get("location") %></p>
                
                <div>
                    <a href="doctor-detail.jsp?id=<%= doctor.get("id") %>" class="btn btn-secondary">
                        <i class="fas fa-user-md mr-1"></i>Xem hồ sơ
                    </a>
                    <a href="dat-lich-kham.jsp?doctor=<%= doctor.get("id") %>" class="btn btn-primary">
                        <i class="fas fa-calendar-plus mr-1"></i>Đặt lịch
                    </a>
                </div>
            </div>
            <% } %>
        </div>

        <!-- Empty State -->
        <div id="noResults" style="display: none; text-align: center; padding: 3rem;">
            <i class="fas fa-search text-6xl text-gray-300 mb-4"></i>
            <h3 class="text-xl font-semibold text-gray-600 mb-2">Không tìm thấy bác sĩ</h3>
            <p class="text-gray-500">Hãy thử tìm kiếm với từ khóa khác hoặc chọn chuyên khoa khác.</p>
        </div>
    </div>

    <script>
        // Search functionality
        document.getElementById('searchInput').addEventListener('input', function() {
            const searchTerm = this.value.toLowerCase();
            const doctorCards = document.querySelectorAll('.doctor-card');
            let visibleCount = 0;

            doctorCards.forEach(card => {
                const name = card.querySelector('.doctor-name').textContent.toLowerCase();
                const specialty = card.querySelector('.doctor-specialty').textContent.toLowerCase();
                
                if (name.includes(searchTerm) || specialty.includes(searchTerm)) {
                    card.style.display = 'block';
                    visibleCount++;
                } else {
                    card.style.display = 'none';
                }
            });

            document.getElementById('noResults').style.display = visibleCount === 0 ? 'block' : 'none';
        });

        // Filter functionality
        document.querySelectorAll('.filter-btn').forEach(btn => {
            btn.addEventListener('click', function() {
                // Remove active class from all buttons
                document.querySelectorAll('.filter-btn').forEach(b => b.classList.remove('active'));
                // Add active class to clicked button
                this.classList.add('active');

                const filter = this.dataset.filter;
                const doctorCards = document.querySelectorAll('.doctor-card');
                let visibleCount = 0;

                doctorCards.forEach(card => {
                    if (filter === 'all') {
                        card.style.display = 'block';
                        visibleCount++;
                    } else {
                        const specialty = card.dataset.specialty;
                        if (specialty.includes(filter.replace('-', ' '))) {
                            card.style.display = 'block';
                            visibleCount++;
                        } else {
                            card.style.display = 'none';
                        }
                    }
                });

                document.getElementById('noResults').style.display = visibleCount === 0 ? 'block' : 'none';
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
