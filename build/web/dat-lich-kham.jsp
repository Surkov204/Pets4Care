<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.Customer" %>
<%@ page import="model.CartItem" %>
<%@ page import="model.Pet" %>
<%@ page import="model.PetServiceModel" %>
<%@ page import="model.Booking" %>
<%@ page import="model.BookingServiceItem" %>
<%@ page import="model.MedicalRecord" %>
<%@ page import="java.util.*" %>
<%@ page import="java.text.SimpleDateFormat" %>
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
    
    // Get data from request attributes
    List<PetServiceModel> healthCheckServices = (List<PetServiceModel>) request.getAttribute("healthCheckServices");
    List<Booking> healthCheckBookings = (List<Booking>) request.getAttribute("healthCheckBookings");
    Pet pet = (Pet) request.getAttribute("pet");
    List<Pet> customerPets = (List<Pet>) request.getAttribute("customerPets");
    Map<Integer, List<MedicalRecord>> petsMedicalRecords = (Map<Integer, List<MedicalRecord>>) request.getAttribute("petsMedicalRecords");

    // Default values if no data
    if (healthCheckServices == null) healthCheckServices = new ArrayList<>();
    if (healthCheckBookings == null) healthCheckBookings = new ArrayList<>();
    if (customerPets == null) customerPets = new ArrayList<>();
    if (petsMedicalRecords == null) petsMedicalRecords = new HashMap<>();
    
    // Pet information
    String petName = "Chưa có thông tin";
    String species = "Chưa có thông tin";
    String breed = "Chưa có thông tin";
    String gender = "Chưa có thông tin";
    String ownerName = "Chưa có thông tin";
    String ownerPhone = "Chưa có thông tin";
    String petImage = "pets/placeholder.svg";
    int age = 0;
    
    if (pet != null) {
        petName = pet.getPetName() != null ? pet.getPetName() : "Chưa có tên";
        species = pet.getSpeciesDisplayName();
        breed = pet.getBreed() != null ? pet.getBreed() : "Chưa có thông tin";
        gender = pet.getGender() != null ? (pet.getGender().equals("male") ? "Đực" : "Cái") : "Chưa có thông tin";
        age = pet.getAge();
        petImage = pet.getImagePath() != null ? pet.getImagePath() : "pets/placeholder.svg";
    }
    
    if (currentUser != null) {
        ownerName = currentUser.getName() != null ? currentUser.getName() : "Chưa có tên";
        ownerPhone = currentUser.getPhone() != null ? currentUser.getPhone() : "Chưa có số điện thoại";
    }
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

        .two-column-layout {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 2rem;
            margin-bottom: 2rem;
        }

        @media (max-width: 1024px) {
            .two-column-layout {
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
                <li><a href="search?categoryId=2">SẢN PHẨM</a></li>
                <li><a href="doctor.jsp">BÁC SĨ</a></li>
                <li><a href="gioi-thieu.jsp">GIỚI THIỆU</a></li>
                <li><a href="tin-tuc.jsp">TIN TỨC</a></li>
                <li><a href="<%= request.getContextPath()%>/home">LIÊN HỆ</a></li>
            </ul>
        </nav>
    </header>

    <div class="container">
        <!-- Success/Error Messages -->
        <% 
            String successMessage = (String) session.getAttribute("successMessage");
            String errorMessage = (String) session.getAttribute("errorMessage");
            if (successMessage != null) {
                session.removeAttribute("successMessage");
        %>
        <div class="bg-green-100 border border-green-400 text-green-700 px-4 py-3 rounded mb-4">
            <i class="fas fa-check-circle mr-2"></i><%= successMessage %>
        </div>
        <% } %>
        <% if (errorMessage != null) {
                session.removeAttribute("errorMessage");
        %>
        <div class="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded mb-4">
            <i class="fas fa-exclamation-triangle mr-2"></i><%= errorMessage %>
        </div>
        <% } %>
        
        <!-- A & F: Thông tin thú cưng và Đặt lịch khám (song song) -->
        <div class="two-column-layout">
            <!-- A. Thông tin chung về thú cưng -->
            <div class="card">
            <h2 class="section-title">
                <i class="fas fa-paw"></i>
                A. Thông tin chung về thú cưng
            </h2>

            <!-- Pet Selection -->
            <div class="mb-6 p-4 bg-blue-50 border border-blue-200 rounded-lg">
                <h3 class="text-lg font-semibold text-blue-800 mb-3">
                    <i class="fas fa-hand-pointer mr-2"></i>Chọn thú cưng để đặt lịch khám
                </h3>
                <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
                    <% if (!customerPets.isEmpty()) { %>
                        <% for (Pet customerPet : customerPets) { %>
                        <div class="pet-option bg-white border-2 <%= (pet != null && pet.getId() == customerPet.getId()) ? "border-orange-500 bg-orange-50" : "border-gray-200" %> rounded-lg p-4 cursor-pointer hover:border-orange-300 transition-colors"
                             onclick="selectPet(<%= customerPet.getId() %>)">
                            <div class="flex items-center space-x-3">
                                <img src="<%= request.getContextPath()%>/images/<%= customerPet.getImagePath() != null ? customerPet.getImagePath() : "pets/placeholder.svg" %>"
                                     alt="<%= customerPet.getPetName() %>"
                                     class="w-12 h-12 rounded-full object-cover border-2 border-gray-200">
                                <div class="flex-1">
                                    <h4 class="font-semibold text-gray-800"><%= customerPet.getPetName() %></h4>
                                    <p class="text-sm text-gray-600">
                                        <%= customerPet.getSpeciesDisplayName() %> •
                                        <%= customerPet.getAge() %> tuổi •
                                        <%= customerPet.getGender() != null ? (customerPet.getGender().equals("male") ? "Đực" : "Cái") : "N/A" %>
                                    </p>
                                </div>
                                <% if (pet != null && pet.getId() == customerPet.getId()) { %>
                                <div class="text-orange-500">
                                    <i class="fas fa-check-circle text-xl"></i>
                                </div>
                                <% } %>
                            </div>
                        </div>
                        <% } %>
                    <% } else { %>
                    <div class="col-span-full text-center py-8">
                        <i class="fas fa-paw text-4xl text-gray-400 mb-4"></i>
                        <h3 class="text-xl font-semibold text-gray-600 mb-2">Chưa có thông tin thú cưng</h3>
                        <p class="text-gray-500 mb-4">Bạn cần cập nhật thông tin thú cưng trước khi đặt lịch khám</p>
                        <a href="<%= request.getContextPath()%>/petinfoservlet" class="btn-primary">
                            <i class="fas fa-plus mr-2"></i>Cập nhật thông tin thú cưng
                        </a>
                    </div>
                    <% } %>
                </div>
            </div>

            <% if (pet != null) { %>
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
            <% } %>
            </div>

            <!-- F. Đặt lịch khám mới -->
            <div class="card">
                <h2 class="section-title">
                    <i class="fas fa-calendar-plus"></i>
                    F. Đặt lịch khám mới
                </h2>

                <% if (currentUser == null) { %>
                <div class="bg-yellow-50 border border-yellow-400 rounded p-4 mb-4">
                    <p class="text-yellow-700 mb-2">⚠️ Bạn cần đăng nhập để đặt lịch khám</p>
                    <a href="login.jsp" class="btn-primary">🔐 Đăng nhập ngay</a>
                </div>
                <% } else if (customerPets.isEmpty()) { %>
                <div class="bg-blue-50 border border-blue-400 rounded p-4 mb-4">
                    <p class="text-blue-700 mb-2">ℹ️ Bạn cần cập nhật thông tin thú cưng trước khi đặt lịch khám</p>
                    <a href="<%= request.getContextPath()%>/petinfoservlet" class="btn-primary">🐾 Cập nhật thông tin thú cưng</a>
                </div>
                <% } else { %>

                <form action="${pageContext.request.contextPath}/health-check-booking" method="post" class="max-w-2xl">
                    <input type="hidden" name="action" value="create-booking">
                    <input type="hidden" name="petId" id="selectedPetId" value="<%= pet != null ? pet.getId() : "" %>">
                    
                    <div class="form-group">
                        <label class="form-label">Chọn dịch vụ khám sức khỏe</label>
                        <select class="form-select" name="serviceId" id="serviceIdSelect" required>
                            <option value="">Chọn dịch vụ khám</option>
                            <% for (PetServiceModel service : healthCheckServices) { %>
                            <option value="<%= service.getServiceId() %>">
                                <%= service.getName() %> - <fmt:formatNumber value="<%= service.getPrice() %>" type="currency" currencySymbol="₫" maxFractionDigits="0"/>
                            </option>
                            <% } %>
                        </select>
                        <p class="text-sm text-gray-600 mt-1">* Chọn dịch vụ khám phù hợp với tình trạng của thú cưng</p>
                    </div>
                    
                    <div class="form-group">
                        <label class="form-label">Ngày khám mong muốn</label>
                        <input type="date" class="form-input" name="appointmentDate" id="appointmentDateInput" required>
                    </div>
                    
                    <div class="form-group">
                        <label class="form-label">Giờ khám có sẵn</label>
                        <select class="form-select" name="appointmentTime" id="appointmentTimeSelect" required>
                            <option value="">Chọn giờ khám</option>
                            <option value="08:00">08:00</option>
                            <option value="09:00">09:00</option>
                            <option value="10:00">10:00</option>
                            <option value="11:00">11:00</option>
                            <option value="14:00">14:00</option>
                            <option value="15:00">15:00</option>
                            <option value="16:00">16:00</option>
                            <option value="17:00">17:00</option>
                        </select>
                        <p class="text-sm text-gray-600 mt-1">* Chỉ hiển thị các khung giờ còn trống</p>
                    </div>
                    
                    <div id="doctorInfoContainer" class="mb-4 p-4 bg-blue-50 border border-blue-200 rounded-lg">
                        <!-- Default message -->
                        <div id="defaultDoctorMessage">
                            <p class="text-sm text-blue-800">
                                <i class="fas fa-info-circle mr-2"></i>
                                <strong>Lưu ý:</strong> Hệ thống sẽ tự động chọn bác sĩ có chuyên khoa phù hợp với dịch vụ khám bạn đã chọn. Bác sĩ sẽ được phân công dựa trên chuyên môn và lịch có sẵn.
                            </p>
                        </div>
                        
                        <!-- Loading state -->
                        <div id="doctorLoadingInfo" style="display: none;">
                            <p class="text-sm text-blue-800 text-center">
                                <i class="fas fa-spinner fa-spin mr-2"></i>
                                Đang tìm bác sĩ phù hợp...
                            </p>
                        </div>
                        
                        <!-- Doctor info display -->
                        <div id="selectedDoctorInfo" style="display: none;">
                            <div class="flex items-start">
                                <i class="fas fa-user-md text-blue-600 text-xl mr-3 mt-1"></i>
                                <div class="flex-1">
                                    <h4 class="font-semibold text-blue-800 mb-2">Bác sĩ được phân công:</h4>
                                    <div class="text-blue-700">
                                        <p class="mb-1"><strong id="doctorNameDisplay"></strong></p>
                                        <p class="text-sm"><span id="doctorSpecializationDisplay"></span></p>
                                        <p id="doctorBusyWarning" class="text-sm text-orange-600 mt-2" style="display: none;">
                                            <i class="fas fa-exclamation-triangle mr-1"></i>
                                            <em>Lưu ý: Bác sĩ này có thể đã có lịch vào thời gian này. Hệ thống sẽ kiểm tra lại khi đặt lịch.</em>
                                        </p>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    
                    <div class="form-group">
                        <label class="form-label">Mô tả triệu chứng (tùy chọn)</label>
                        <textarea class="form-textarea" name="note" rows="4" 
                                  placeholder="Mô tả chi tiết các triệu chứng bạn quan sát được..."></textarea>
                    </div>
                    
                    <div class="form-group">
                        <button type="submit" class="btn-primary">
                            <i class="fas fa-calendar-check mr-2"></i>
                            Đặt lịch khám
                        </button>
                    </div>
                </form>
                <% } %>
            </div>
        </div>

        <!-- B. Thông tin sức khỏe hiện tại -->
        <div class="card">
            <h2 class="section-title">
                <i class="fas fa-heartbeat"></i>
                B. Thông tin sức khỏe hiện tại
            </h2>
            
            <% if (pet != null) { 
                // Lấy bệnh án mới nhất của thú cưng hiện tại
                MedicalRecord latestRecord = null;
                List<MedicalRecord> petRecords = petsMedicalRecords.get(pet.getId());
                if (petRecords != null && !petRecords.isEmpty()) {
                    // Sắp xếp theo ngày khám mới nhất (nếu có nhiều bệnh án)
                    petRecords.sort((r1, r2) -> {
                        if (r1.getExaminationDate() == null && r2.getExaminationDate() == null) return 0;
                        if (r1.getExaminationDate() == null) return 1;
                        if (r2.getExaminationDate() == null) return -1;
                        return r2.getExaminationDate().compareTo(r1.getExaminationDate());
                    });
                    latestRecord = petRecords.get(0);
                }
            %>
            <table class="info-table">
                <tr>
                    <th>Cân nặng</th>
                    <td>
                        <% if (latestRecord != null && latestRecord.getWeight() != null) { %>
                            <%= latestRecord.getWeight() %> kg
                        <% } else { %>
                            Chưa có thông tin <span class="text-gray-500 text-sm">(Cần cập nhật)</span>
                        <% } %>
                    </td>
                </tr>
                <tr>
                    <th>Tình trạng chung</th>
                    <td>
                        <% if (latestRecord != null && latestRecord.getDiagnosis() != null && !latestRecord.getDiagnosis().trim().isEmpty()) { %>
                            <span class="status-badge status-normal">Đã có chẩn đoán</span>
                            <span class="text-gray-600 text-sm ml-2">(<%= latestRecord.getDiagnosis() %>)</span>
                        <% } else { %>
                            <span class="status-badge status-normal">Cần khám định kỳ</span>
                        <% } %>
                    </td>
                </tr>
                <tr>
                    <th>Nhiệt độ</th>
                    <td>
                        <% if (latestRecord != null && latestRecord.getTemperature() != null) { %>
                            <%= latestRecord.getTemperature() %>°C
                        <% } else { %>
                            Chưa có thông tin
                        <% } %>
                    </td>
                </tr>
                <tr>
                    <th>Mạch</th>
                    <td>
                        <% if (latestRecord != null && latestRecord.getHeartRate() != null) { %>
                            <%= latestRecord.getHeartRate() %> bpm
                        <% } else { %>
                            Chưa có thông tin
                        <% } %>
                    </td>
                </tr>
                <tr>
                    <th>Nhịp thở</th>
                    <td>
                        <% if (latestRecord != null && latestRecord.getBloodPressure() != null && !latestRecord.getBloodPressure().trim().isEmpty()) { %>
                            <%= latestRecord.getBloodPressure() %>
                        <% } else { %>
                            Chưa có thông tin
                        <% } %>
                    </td>
                </tr>
                <tr>
                    <th>Triệu chứng</th>
                    <td>
                        <% if (latestRecord != null && latestRecord.getSymptoms() != null && !latestRecord.getSymptoms().trim().isEmpty()) { %>
                            <%= latestRecord.getSymptoms() %>
                        <% } else { %>
                            Chưa có triệu chứng nào được ghi nhận
                        <% } %>
                    </td>
                </tr>
                <tr>
                    <th>Ghi chú bác sĩ</th>
                    <td>
                        <% if (latestRecord != null && latestRecord.getNotes() != null && !latestRecord.getNotes().trim().isEmpty()) { %>
                            <%= latestRecord.getNotes() %>
                            <% if (latestRecord.getExaminationDate() != null) { %>
                                <span class="text-gray-500 text-sm ml-2">
                                    (Cập nhật: <%= new SimpleDateFormat("dd/MM/yyyy").format(latestRecord.getExaminationDate()) %>)
                                </span>
                            <% } %>
                        <% } else { %>
                            Chưa có ghi chú từ bác sĩ
                        <% } %>
                    </td>
                </tr>
            </table>
            <% } else { %>
            <div class="text-center py-8">
                <i class="fas fa-paw text-4xl text-gray-400 mb-4"></i>
                <h3 class="text-xl font-semibold text-gray-600 mb-2">Chưa có thông tin thú cưng</h3>
                <p class="text-gray-500 mb-4">Vui lòng cập nhật thông tin thú cưng để có thể đặt lịch khám</p>
                <a href="user/pet-info.jsp" class="btn-primary">
                    <i class="fas fa-plus mr-2"></i>Cập nhật thông tin thú cưng
                </a>
            </div>
            <% } %>
        </div>

        <!-- C. Lịch sử khám & tiêm chủng -->
        <div class="card">
            <h2 class="section-title">
                <i class="fas fa-history"></i>
                C. Lịch sử khám & tiêm chủng
            </h2>
            
            <% if (!healthCheckBookings.isEmpty()) { %>
            <div class="history-timeline">
                <% for (Booking booking : healthCheckBookings) { 
                    SimpleDateFormat dateFormat = new SimpleDateFormat("dd/MM/yyyy");
                    String statusClass = "";
                    String statusText = "";
                    switch (booking.getStatus()) {
                        case "completed":
                            statusClass = "status-normal";
                            statusText = "Hoàn thành";
                            break;
                        case "confirmed":
                            statusClass = "status-normal";
                            statusText = "Đã xác nhận";
                            break;
                        case "pending":
                            statusClass = "status-warning";
                            statusText = "Đang chờ";
                            break;
                        case "cancelled":
                            statusClass = "status-warning";
                            statusText = "Đã hủy";
                            break;
                        default:
                            statusClass = "status-warning";
                            statusText = "Chưa xác định";
                    }
                %>
                <div class="timeline-item">
                    <div class="timeline-content">
                        <div class="flex justify-between items-start">
                            <div>
                                <h4 class="font-semibold text-lg">Khám sức khỏe</h4>
                                <p class="text-gray-600"><%= dateFormat.format(booking.getAppointmentStart()) %></p>
                                <% if (booking.getNote() != null && !booking.getNote().trim().isEmpty()) { %>
                                <p class="mt-2"><%= booking.getNote() %></p>
                                <% } %>
                            </div>
                            <span class="status-badge <%= statusClass %>"><%= statusText %></span>
                        </div>
                    </div>
                </div>
                <% } %>
            </div>
            <% } else { %>
            <div class="text-center py-8">
                <i class="fas fa-calendar-times text-4xl text-gray-400 mb-4"></i>
                <h3 class="text-xl font-semibold text-gray-600 mb-2">Chưa có lịch sử khám</h3>
                <p class="text-gray-500">Thú cưng của bạn chưa có lịch sử khám nào được ghi nhận</p>
            </div>
            <% } %>
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
                <% if (!healthCheckBookings.isEmpty()) { %>
                <div class="space-y-4">
                    <% for (Booking booking : healthCheckBookings) { 
                        SimpleDateFormat dateFormat = new SimpleDateFormat("dd/MM/yyyy");
                        SimpleDateFormat timeFormat = new SimpleDateFormat("HH:mm");
                        String statusClass = "";
                        String statusText = "";
                        String bgClass = "";
                        
                        switch (booking.getStatus()) {
                            case "pending":
                                statusClass = "status-warning";
                                statusText = "Chờ xác nhận";
                                bgClass = "bg-yellow-50 border-l-4 border-yellow-400";
                                break;
                            case "confirmed":
                                statusClass = "status-normal";
                                statusText = "Đã xác nhận";
                                bgClass = "bg-green-50 border-l-4 border-green-400";
                                break;
                            case "cancelled":
                                statusClass = "status-warning";
                                statusText = "Đã hủy";
                                bgClass = "bg-red-50 border-l-4 border-red-400";
                                break;
                            default:
                                statusClass = "status-warning";
                                statusText = "Chưa xác định";
                                bgClass = "bg-gray-50 border-l-4 border-gray-400";
                        }
                    %>
                    <div class="<%= bgClass %> p-4 rounded-r-lg">
                        <div class="flex justify-between items-start">
                            <div>
                                <h4 class="font-semibold text-lg">Khám sức khỏe</h4>
                                <p class="text-gray-600">📅 Ngày: <%= dateFormat.format(booking.getAppointmentStart()) %> - <%= timeFormat.format(booking.getAppointmentStart()) %></p>
                                <% if (booking.getNote() != null && !booking.getNote().trim().isEmpty()) { %>
                                <p class="text-gray-600">📝 Ghi chú: <%= booking.getNote() %></p>
                                <% } %>
                            </div>
                            <span class="status-badge <%= statusClass %>"><%= statusText %></span>
                        </div>
                    </div>
                    <% } %>
                </div>
                <% } else { %>
                <div class="text-center py-8">
                    <i class="fas fa-calendar-plus text-4xl text-gray-400 mb-4"></i>
                    <h3 class="text-xl font-semibold text-gray-600 mb-2">Chưa có lịch khám nào</h3>
                    <p class="text-gray-500">Bạn chưa đặt lịch khám nào cho thú cưng</p>
                </div>
                <% } %>
            </div>
        </div>

        <!-- E. Lịch sử bệnh án các thú cưng khác -->
        <div class="card">
            <h2 class="section-title">
                <i class="fas fa-notes-medical"></i>
                E. Lịch sử bệnh án các thú cưng khác
            </h2>

            <% if (!petsMedicalRecords.isEmpty()) { %>
            <div class="space-y-6">
                <% for (Pet otherPet : customerPets) {
                    List<MedicalRecord> petRecords = petsMedicalRecords.get(otherPet.getId());
                    if (petRecords != null && !petRecords.isEmpty()) { %>
                <div class="pet-medical-history">
                    <h3 class="text-lg font-semibold text-gray-800 mb-3 flex items-center">
                        <i class="fas fa-paw mr-2 text-blue-500"></i>
                        <%= otherPet.getPetName() %> (<%= otherPet.getSpeciesDisplayName() %>)
                    </h3>

                    <div class="space-y-3">
                        <% for (MedicalRecord record : petRecords) {
                            SimpleDateFormat dateFormat = new SimpleDateFormat("dd/MM/yyyy");
                        %>
                        <div class="bg-gray-50 rounded-lg p-4 border-l-4 border-blue-400">
                            <div class="flex justify-between items-start mb-2">
                                <div class="font-medium text-gray-800">
                                    Khám ngày: <%= dateFormat.format(record.getExaminationDate()) %>
                                </div>
                                <div class="text-sm text-gray-600">
                                    Bác sĩ: <%= record.getDoctorName() != null ? record.getDoctorName() : "N/A" %>
                                </div>
                            </div>

                            <% if (record.getDiagnosis() != null && !record.getDiagnosis().trim().isEmpty()) { %>
                            <div class="mb-2">
                                <strong class="text-gray-700">Chẩn đoán:</strong>
                                <span class="text-gray-600"><%= record.getDiagnosis() %></span>
                            </div>
                            <% } %>

                            <% if (record.getTreatment() != null && !record.getTreatment().trim().isEmpty()) { %>
                            <div class="mb-2">
                                <strong class="text-gray-700">Phương pháp điều trị:</strong>
                                <span class="text-gray-600"><%= record.getTreatment() %></span>
                            </div>
                            <% } %>

                            <% if (record.getPrescription() != null && !record.getPrescription().trim().isEmpty()) { %>
                            <div class="mb-2">
                                <strong class="text-gray-700">Đơn thuốc:</strong>
                                <span class="text-gray-600"><%= record.getPrescription() %></span>
                            </div>
                            <% } %>

                            <% if (record.getNotes() != null && !record.getNotes().trim().isEmpty()) { %>
                            <div class="text-sm text-gray-600 italic">
                                "<%= record.getNotes() %>"
                            </div>
                            <% } %>
                        </div>
                        <% } %>
                    </div>
                </div>
                <% } } %>
            </div>
            <% } else { %>
            <div class="text-center py-8">
                <i class="fas fa-notes-medical text-4xl text-gray-400 mb-4"></i>
                <h3 class="text-xl font-semibold text-gray-600 mb-2">Chưa có lịch sử bệnh án</h3>
                <p class="text-gray-500">Các thú cưng khác của bạn chưa có bệnh án nào được ghi nhận</p>
            </div>
            <% } %>
        </div>
    </div>

    <script>
        // Set minimum date to today
        document.addEventListener('DOMContentLoaded', function() {
            console.log('DOMContentLoaded - Initializing doctor info loader...');
            
            const dateInput = document.querySelector('input[name="appointmentDate"]');
            if (dateInput) {
                const today = new Date().toISOString().split('T')[0];
                dateInput.min = today;
                
                // Set default date to tomorrow
                const tomorrow = new Date();
                tomorrow.setDate(tomorrow.getDate() + 1);
                dateInput.value = tomorrow.toISOString().split('T')[0];
            }
            
            // Load doctor info when service, date, or time changes
            const serviceSelect = document.getElementById('serviceIdSelect') || document.querySelector('select[name="serviceId"]');
            const appointmentDateInput = document.getElementById('appointmentDateInput') || document.querySelector('input[name="appointmentDate"]');
            const appointmentTimeSelect = document.getElementById('appointmentTimeSelect') || document.querySelector('select[name="appointmentTime"]');
            
            console.log('Elements found:', {
                serviceSelect: !!serviceSelect,
                appointmentDateInput: !!appointmentDateInput,
                appointmentTimeSelect: !!appointmentTimeSelect
            });
            
            function loadDoctorInfo() {
                const serviceId = serviceSelect ? serviceSelect.value : '';
                const appointmentDate = appointmentDateInput ? appointmentDateInput.value : '';
                const appointmentTime = appointmentTimeSelect ? appointmentTimeSelect.value : '';
                
                console.log('loadDoctorInfo called:', { serviceId, appointmentDate, appointmentTime });
                
                const defaultMessage = document.getElementById('defaultDoctorMessage');
                const doctorInfoDiv = document.getElementById('selectedDoctorInfo');
                const doctorLoadingDiv = document.getElementById('doctorLoadingInfo');
                
                if (!serviceId || !appointmentDate || !appointmentTime) {
                    // Show default message, hide others
                    if (defaultMessage) defaultMessage.style.display = 'block';
                    if (doctorInfoDiv) doctorInfoDiv.style.display = 'none';
                    if (doctorLoadingDiv) doctorLoadingDiv.style.display = 'none';
                    console.log('Missing required fields, showing default message');
                    return;
                }
                
                // Show loading, hide default message and doctor info
                defaultMessage.style.display = 'none';
                doctorLoadingDiv.style.display = 'block';
                doctorInfoDiv.style.display = 'none';
                
                // Fetch doctor info
                const url = '<%= request.getContextPath()%>/health-check-booking?action=get-suitable-doctor&serviceId=' + 
                           encodeURIComponent(serviceId) + 
                           '&appointmentDate=' + encodeURIComponent(appointmentDate) +
                           '&appointmentTime=' + encodeURIComponent(appointmentTime);
                
                console.log('Fetching doctor info:', url);
                
                fetch(url)
                    .then(response => {
                        console.log('Response status:', response.status);
                        if (!response.ok) {
                            throw new Error('Network response was not ok: ' + response.status);
                        }
                        return response.json();
                    })
                    .then(data => {
                        console.log('Doctor data received:', data);
                        doctorLoadingDiv.style.display = 'none';
                        
                        if (data.success) {
                            document.getElementById('doctorNameDisplay').textContent = data.doctorName;
                            document.getElementById('doctorSpecializationDisplay').textContent = '🩺 ' + data.specialization;
                            
                            const busyWarning = document.getElementById('doctorBusyWarning');
                            if (data.isBusy) {
                                busyWarning.style.display = 'block';
                            } else {
                                busyWarning.style.display = 'none';
                            }
                            
                            // Show doctor info, hide default message
                            defaultMessage.style.display = 'none';
                            doctorInfoDiv.style.display = 'block';
                            console.log('Doctor info displayed successfully');
                        } else {
                            // Show default message on error
                            defaultMessage.style.display = 'block';
                            doctorInfoDiv.style.display = 'none';
                            if (data.error) {
                                console.error('Error loading doctor:', data.error);
                            }
                        }
                    })
                    .catch(error => {
                        console.error('Error loading doctor info:', error);
                        // Show default message on error
                        defaultMessage.style.display = 'block';
                        doctorLoadingDiv.style.display = 'none';
                        doctorInfoDiv.style.display = 'none';
                    });
            }
            
            // Add event listeners
            if (serviceSelect) {
                serviceSelect.addEventListener('change', loadDoctorInfo);
            }
            if (appointmentDateInput) {
                appointmentDateInput.addEventListener('change', loadDoctorInfo);
            }
            if (appointmentTimeSelect) {
                appointmentTimeSelect.addEventListener('change', loadDoctorInfo);
            }
            
            // Also trigger on input for date field (for date picker)
            if (appointmentDateInput) {
                appointmentDateInput.addEventListener('input', loadDoctorInfo);
            }
            
            // Debug: Log when elements are found
            console.log('Doctor info loader initialized:', {
                serviceSelect: !!serviceSelect,
                appointmentDateInput: !!appointmentDateInput,
                appointmentTimeSelect: !!appointmentTimeSelect
            });
        });

        // Form submission handler - removed preventDefault to allow form submission
        // The form will now submit to the HealthCheckBookingServlet

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

        // Pet selection functionality
        function selectPet(petId) {
            // Update hidden input
            document.getElementById('selectedPetId').value = petId;

            // Update UI - remove previous selection
            document.querySelectorAll('.pet-option').forEach(option => {
                option.classList.remove('border-orange-500', 'bg-orange-50');
                const checkIcon = option.querySelector('.fa-check-circle');
                if (checkIcon) {
                    checkIcon.parentElement.remove();
                }
            });

            // Add selection to clicked pet
            const selectedOption = document.querySelector(`[onclick="selectPet(${petId})"]`);
            if (selectedOption) {
                selectedOption.classList.add('border-orange-500', 'bg-orange-50');
                const petInfo = selectedOption.querySelector('.flex-1');
                if (petInfo) {
                    const checkDiv = document.createElement('div');
                    checkDiv.className = 'text-orange-500';
                    checkDiv.innerHTML = '<i class="fas fa-check-circle text-xl"></i>';
                    petInfo.parentElement.appendChild(checkDiv);
                }
            }

            // Reload page with selected pet
            window.location.href = '${pageContext.request.contextPath}/health-check-booking?petId=' + petId;
        }


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

