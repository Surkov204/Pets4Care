<%@page import="model.Customer"%>
<%@page import="model.CartItem"%>
<%@page import="java.util.Map"%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
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

    if (currentUser == null) {
        response.sendRedirect("../login.jsp");
        return;
    }
%>

<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>🐾 Thông tin thú cưng - Petcity</title>
        <script src="https://cdn.tailwindcss.com"></script>
        <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.3/css/all.min.css" rel="stylesheet" />
        <link rel="stylesheet" href="<%= request.getContextPath()%>/css/homeStyle.css" />
        <style>
            .error-message {
                color: red;
                font-size: 0.9rem;
                margin-top: -0.5rem;
                margin-bottom: 1rem;
            }
            .input-error {
                border-color: red !important;
            }
            .upload-area {
                border: 2px dashed #6FD5DD;
                border-radius: 18px;
                padding: 2rem;
                text-align: center;
                background: #F6FCF7;
                transition: all 0.3s ease;
                cursor: pointer;
            }
            .upload-area:hover {
                border-color: #FF8C94;
                background: #FFFDF8;
            }
            .upload-area.dragover {
                border-color: #FF8C94;
                background: #FFFDF8;
                transform: scale(1.02);
            }
            .preview-image {
                max-width: 200px;
                max-height: 200px;
                border-radius: 18px;
                box-shadow: 0 4px 16px rgba(111, 213, 221, 0.2);
                margin: 1rem auto;
                display: block;
            }
            .pet-info-card {
                background: linear-gradient(135deg, #FFFDF8, #F6FCF7);
                border: 2px solid rgba(111, 213, 221, 0.3);
                box-shadow: 0 4px 32px rgba(140, 170, 205, 0.18);
            }
            .form-section {
                background: white;
                border-radius: 18px;
                padding: 2rem;
                margin-bottom: 1.5rem;
                box-shadow: 0 2px 16px rgba(140, 170, 205, 0.12);
            }
            .section-title {
                color: #6FD5DD;
                font-size: 1.3rem;
                font-weight: 700;
                font-family: 'Baloo 2', cursive;
                margin-bottom: 1.5rem;
                display: flex;
                align-items: center;
                gap: 0.5rem;
            }
            .form-group {
                margin-bottom: 1.5rem;
            }
            .form-label {
                display: block;
                color: #34495E;
                margin-bottom: 0.5rem;
                font-weight: 600;
                font-size: 0.95rem;
                display: flex;
                align-items: center;
                gap: 0.5rem;
            }
            .form-input, .form-select, .form-textarea {
                width: 100%;
                padding: 0.9rem 1.1rem;
                border: 2px solid rgba(111, 213, 221, 0.3);
                border-radius: 18px;
                background: #F6FCF7;
                transition: all 0.2s ease;
                font-family: 'Quicksand', sans-serif;
                font-size: 0.95rem;
                color: #34495E;
            }
            .form-input:focus, .form-select:focus, .form-textarea:focus {
                border-color: #6FD5DD;
                background: white;
                outline: none;
                box-shadow: 0 0 0 3px rgba(111, 213, 221, 0.2);
                transform: translateY(-2px);
            }
            
            /* Remove any overlay effects */
            .form-input, .form-select, .form-textarea {
                position: relative;
                z-index: 1;
            }
            
            /* Remove any pseudo-elements that might cause overlay */
            .form-input::before, .form-input::after,
            .form-select::before, .form-select::after,
            .form-textarea::before, .form-textarea::after {
                display: none !important;
            }
            .form-textarea {
                resize: vertical;
                min-height: 100px;
            }
            .btn-primary {
                background: linear-gradient(135deg, #6FD5DD, #FFD6C0);
                color: white;
                border: none;
                padding: 1rem 2rem;
                border-radius: 18px;
                font-weight: 600;
                font-family: 'Quicksand', sans-serif;
                font-size: 1rem;
                cursor: pointer;
                transition: all 0.2s ease;
                box-shadow: 0 2px 8px rgba(140, 170, 205, 0.12);
                position: relative;
                overflow: hidden;
            }
            .btn-primary::before {
                content: '';
                position: absolute;
                top: 0;
                left: -100%;
                width: 100%;
                height: 100%;
                background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.2), transparent);
                transition: left 0.5s ease;
            }
            .btn-primary:hover::before {
                left: 100%;
            }
            .btn-primary:hover {
                transform: translateY(-3px);
                box-shadow: 0 4px 18px rgba(255, 181, 163, 0.18);
            }
            .btn-secondary {
                background: #F6FCF7;
                color: #34495E;
                border: 2px solid rgba(111, 213, 221, 0.3);
                padding: 0.8rem 1.5rem;
                border-radius: 18px;
                font-weight: 600;
                font-family: 'Quicksand', sans-serif;
                text-decoration: none;
                display: inline-block;
                transition: all 0.2s ease;
            }
            .btn-secondary:hover {
                background: rgba(111, 213, 221, 0.1);
                transform: translateY(-2px);
            }
            .success-message {
                background: linear-gradient(135deg, #f0fff4, #c6f6d5);
                color: #38a169;
                padding: 1rem;
                border-radius: 18px;
                border-left: 4px solid #38a169;
                margin-bottom: 1.5rem;
                font-weight: 600;
            }
            .error-message {
                background: linear-gradient(135deg, #fff5f5, #fed7d7);
                color: #e53e3e;
                padding: 1rem;
                border-radius: 18px;
                border-left: 4px solid #e53e3e;
                margin-bottom: 1.5rem;
                font-weight: 600;
            }
            .floating-pets {
                position: fixed;
                top: 0;
                left: 0;
                width: 100%;
                height: 100%;
                pointer-events: none;
                z-index: 0;
            }
            .floating-pet {
                position: absolute;
                font-size: 1.5rem;
                opacity: 0.1;
                animation: float 6s ease-in-out infinite;
            }
            .floating-pet:nth-child(1) {
                top: 10%;
                left: 10%;
                animation-delay: 0s;
            }
            .floating-pet:nth-child(2) {
                top: 20%;
                right: 15%;
                animation-delay: 1s;
            }
            .floating-pet:nth-child(3) {
                bottom: 20%;
                left: 20%;
                animation-delay: 2s;
            }
            .floating-pet:nth-child(4) {
                bottom: 30%;
                right: 10%;
                animation-delay: 3s;
            }
            .floating-pet:nth-child(5) {
                top: 60%;
                left: 5%;
                animation-delay: 4s;
            }
            .floating-pet:nth-child(6) {
                top: 40%;
                right: 25%;
                animation-delay: 5s;
            }

            @keyframes float {
                0%, 100% {
                    transform: translateY(0px) rotate(0deg);
                }
                50% {
                    transform: translateY(-20px) rotate(5deg);
                }
            }

            .main-content {
                position: relative;
                z-index: 1;
            }
        </style>
        <script>
            function validateForm() {
                var isValid = true;
                var petName = document.forms["petInfoForm"]["petName"].value;
                var species = document.forms["petInfoForm"]["species"].value;
                var breed = document.forms["petInfoForm"]["breed"].value;
                var age = document.forms["petInfoForm"]["age"].value;
                var gender = document.forms["petInfoForm"]["gender"].value;

                // Reset error styles
                document.getElementById("petNameError").innerText = "";
                document.getElementById("speciesError").innerText = "";
                document.getElementById("breedError").innerText = "";
                document.getElementById("ageError").innerText = "";
                document.getElementById("genderError").innerText = "";

                document.forms["petInfoForm"]["petName"].classList.remove("input-error");
                document.forms["petInfoForm"]["species"].classList.remove("input-error");
                document.forms["petInfoForm"]["breed"].classList.remove("input-error");
                document.forms["petInfoForm"]["age"].classList.remove("input-error");
                document.forms["petInfoForm"]["gender"].classList.remove("input-error");

                // Validate pet name
                if (petName == "" || petName.trim().length < 2) {
                    document.getElementById("petNameError").innerText = "Tên thú cưng phải có ít nhất 2 ký tự!";
                    document.forms["petInfoForm"]["petName"].classList.add("input-error");
                    isValid = false;
                }

                // Validate species
                if (species == "") {
                    document.getElementById("speciesError").innerText = "Vui lòng chọn loài thú cưng!";
                    document.forms["petInfoForm"]["species"].classList.add("input-error");
                    isValid = false;
                }

                // Validate breed
                if (breed == "" || breed.trim().length < 2) {
                    document.getElementById("breedError").innerText = "Giống thú cưng phải có ít nhất 2 ký tự!";
                    document.forms["petInfoForm"]["breed"].classList.add("input-error");
                    isValid = false;
                }

                // Validate age
                if (age == "" || isNaN(age) || parseInt(age) < 0 || parseInt(age) > 30) {
                    document.getElementById("ageError").innerText = "Tuổi phải là số từ 0 đến 30!";
                    document.forms["petInfoForm"]["age"].classList.add("input-error");
                    isValid = false;
                }

                // Validate gender
                if (gender == "") {
                    document.getElementById("genderError").innerText = "Vui lòng chọn giới tính!";
                    document.forms["petInfoForm"]["gender"].classList.add("input-error");
                    isValid = false;
                }

                return isValid;
            }

            function previewImage(input) {
                if (input.files && input.files[0]) {
                    var reader = new FileReader();
                    reader.onload = function (e) {
                        var preview = document.getElementById('imagePreview');
                        preview.innerHTML = '<img src="' + e.target.result + '" class="preview-image" alt="Preview">';
                        preview.style.display = 'block';
                    }
                    reader.readAsDataURL(input.files[0]);
                }
            }

            function handleDragOver(e) {
                e.preventDefault();
                e.currentTarget.classList.add('dragover');
            }

            function handleDragLeave(e) {
                e.preventDefault();
                e.currentTarget.classList.remove('dragover');
            }

            function handleDrop(e) {
                e.preventDefault();
                e.currentTarget.classList.remove('dragover');

                var files = e.dataTransfer.files;
                if (files.length > 0) {
                    document.getElementById('petImage').files = files;
                    previewImage(document.getElementById('petImage'));
                }
            }
        </script>
    </head>

    <body class="bg-gray-50">
        <!-- Floating Pets Background -->
        <div class="floating-pets">
            <div class="floating-pet">🐶</div>
            <div class="floating-pet">🐱</div>
            <div class="floating-pet">🐰</div>
            <div class="floating-pet">🐹</div>
            <div class="floating-pet">🐻</div>
            <div class="floating-pet">🦊</div>
        </div>

        <!-- Top Bar -->
        <div class="top-bar">
            <div class="left">PETCITY - SIÊU THỊ THÚ CƯNG ONLINE</div>
            <div class="right">
                <div>CẦN LÀ CÓ - MÒ LÀ THẤY</div>
                <a href="#"><i class="fab fa-facebook-f"></i></a>
                <a href="#"><i class="fab fa-instagram"></i></a>
                <a href="#"><i class="fab fa-twitter"></i></a>
                <a href="#"><i class="fas fa-envelope"></i></a>
            </div>
        </div>

        <!-- Header -->
        <header class="header-bar">
            <a href="<%= request.getContextPath()%>/home" class="logo">
                <div>
                    <div class="logo-text">petcity</div>
                    <div class="logo-subtext">thành phố thú cưng</div>
                </div>
            </a>
            <form class="search-form" method="get" action="search">
                <input type="text" name="keyword" placeholder="Tìm kiếm..." required>
                <button type="submit"><i class="fas fa-search"></i></button>
            </form>
            <div class="contact-info">
                <div><i class="far fa-clock"></i> 08:00 - 17:00</div>
                <div>
                    👤 Xin chào, <b><%= currentUser.getName()%></b>
                    <a href="<%= request.getContextPath()%>/logout.jsp" class="text-blue-500 hover:underline ml-2">[Đăng xuất]</a>
                </div>
                <div>
                    <a href="<%= request.getContextPath()%>/cart/cart.jsp"><i class="fas fa-shopping-cart"></i> Giỏ hàng / <span class="cart-amount"><%= String.format("%.2f", cartTotal)%></span>₫</a>
                    <span class="cart-count"><%= cartCount%></span>
                </div>
            </div>
        </header>

         <!-- Navigation -->
         <nav>
             <ul>
                 <li><a href="<%= request.getContextPath()%>/home">TRANG CHỦ</a></li>
                 <li><a href="<%= request.getContextPath()%>/spa-service.jsp">DỊCH VỤ</a></li>
                 <li><a href="<%= request.getContextPath()%>/search?categoryId=2">SẢN PHẨM</a></li>
                 <li><a href="<%= request.getContextPath()%>/doctor.jsp">BÁC SĨ</a></li>
                 <li><a href="<%= request.getContextPath()%>/gioi-thieu.jsp">GIỚI THIỆU</a></li>
                 <li><a href="<%= request.getContextPath()%>/tin-tuc.jsp">TIN TỨC</a></li>
                 <li><a href="<%= request.getContextPath()%>/home">LIÊN HỆ</a></li>
             </ul>
         </nav>

        <!-- Breadcrumbs and Quick Nav -->
        <div class="max-w-4xl mx-auto mt-6 px-6">
            <nav class="text-sm text-gray-500 mb-4" aria-label="Breadcrumb">
                <ol class="list-reset flex">
                    <li><a href="<%= request.getContextPath()%>/home" class="text-blue-600 hover:underline">Trang chủ</a></li>
                    <li><span class="mx-2">/</span></li>
                    <li><a href="<%= request.getContextPath()%>/user/user-info.jsp" class="text-blue-600 hover:underline">Tài khoản</a></li>
                    <li><span class="mx-2">/</span></li>
                    <li class="text-gray-700">Thú cưng</li>
                </ol>
            </nav>
            <div class="flex gap-2 overflow-x-auto pb-2 -mx-1">
                <a href="#basic" class="px-3 py-2 rounded-lg bg-gray-100 text-gray-700 hover:bg-gray-200 whitespace-nowrap"><i class="fas fa-info-circle mr-2"></i>Cơ bản</a>
                <a href="#photo" class="px-3 py-2 rounded-lg bg-gray-100 text-gray-700 hover:bg-gray-200 whitespace-nowrap"><i class="fas fa-camera mr-2"></i>Ảnh</a>
                <a href="#desc" class="px-3 py-2 rounded-lg bg-gray-100 text-gray-700 hover:bg-gray-200 whitespace-nowrap"><i class="fas fa-notes-medical mr-2"></i>Mô tả & sức khỏe</a>
            </div>
        </div>

        <!-- MAIN CONTENT -->
        <main class="main-content max-w-4xl mx-auto mt-4 px-6 space-y-10">
            <div class="pet-info-card p-8">
                <h2 class="text-3xl font-bold text-center mb-8" style="color: #6FD5DD; font-family: 'Baloo 2', cursive;">
                    🐾 Thông Tin Thú Cưng Của Bạn 🐾
                </h2>

                <% String message = (String) request.getAttribute("message"); %>
                <% if (message != null) {%>
                <div class="success-message">
                    <i class="fas fa-check-circle"></i> <%= message%>
                </div>
                <% } %>

                <% String error = (String) request.getAttribute("error"); %>
                <% if (error != null) {%>
                <div class="error-message">
                    <i class="fas fa-exclamation-triangle"></i> <%= error%>
                </div>
                <% }%>

                 <form name="petInfoForm" onsubmit="return validateForm()" action="<%= request.getContextPath()%>/updatepetservlet" method="post" enctype="multipart/form-data" class="space-y-6">
                     
                     <!-- Hiển thị thông tin pet hiện có nếu có -->
                     <% 
                         model.Pet pet = (model.Pet) request.getAttribute("pet");
                         boolean hasPet = pet != null;
                     %>
                     
                     <% if (hasPet) { %>
                     <div class="bg-blue-50 border border-blue-200 rounded-lg p-4 mb-6">
                         <h4 class="text-blue-800 font-semibold mb-2">
                             <i class="fas fa-info-circle mr-2"></i>Thông tin thú cưng hiện tại
                         </h4>
                        <%
                            String rawPath = pet.getImagePath();
                            boolean hasImg = rawPath != null && !rawPath.trim().isEmpty();
                            String imageUrl = null;
                            if (hasImg) {
                                String trimmed = rawPath.trim();
                                if (trimmed.startsWith("http://") || trimmed.startsWith("https://")) {
                                    imageUrl = trimmed;
                                } else {
                                    while (trimmed.startsWith("/")) trimmed = trimmed.substring(1);
                                    imageUrl = request.getContextPath() + "/" + trimmed;
                                }
                            }
                            
                            // Debug: Log image path
                            System.out.println("=== DEBUG PET IMAGE ===");
                            System.out.println("Raw path: " + rawPath);
                            System.out.println("Has image: " + hasImg);
                            System.out.println("Image URL: " + imageUrl);
                        %>
                        <div class="mb-4 flex justify-center">
                            <img src="<%= hasImg ? imageUrl : (request.getContextPath()+"/images/pets/placeholder.svg") %>" 
                                 alt="Ảnh thú cưng hiện tại" 
                                 class="w-32 h-32 rounded-full object-cover border-4 border-blue-200"
                                 onerror="this.src='<%= request.getContextPath() %>/images/pets/placeholder.svg'"/>
                        </div>
                        
                        <div class="grid grid-cols-2 gap-4 text-sm">
                             <div><strong>Tên:</strong> <%= pet.getPetName() %></div>
                             <div><strong>Loài:</strong> <%= pet.getSpecies() %></div>
                             <div><strong>Giống:</strong> <%= pet.getBreed() %></div>
                             <div><strong>Tuổi:</strong> <%= pet.getAge() %> tuổi</div>
                             <div><strong>Giới tính:</strong> <%= pet.getGender().equals("male") ? "Đực" : "Cái" %></div>
                             <div><strong>Cập nhật lần cuối:</strong> <%= pet.getUpdatedAt() %></div>
                         </div>

                         <!-- Medical Records Button -->
                         <div class="mt-4 pt-4 border-t border-blue-200">
                             <a href="<%= request.getContextPath()%>/customer/pet-medical-records?petId=<%= pet.getId() %>"
                                class="inline-flex items-center px-4 py-2 bg-gradient-to-r from-blue-500 to-purple-600 text-white rounded-lg hover:from-blue-600 hover:to-purple-700 transition-all shadow-md hover:shadow-lg">
                                 <i class="fas fa-notes-medical mr-2"></i>
                                 <span>Xem hồ sơ y tế</span>
                             </a>
                         </div>
                     </div>
                     <% } %>

                    <!-- Thông tin cơ bản -->
                    <div id="basic" class="form-section">
                        <h3 class="section-title">
                            <i class="fas fa-paw"></i> Thông tin cơ bản
                        </h3>

                        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                            <div class="form-group">
                                <label class="form-label">
                                    <i class="fas fa-heart"></i> Tên thú cưng
                                </label>
                                <input type="text" name="petName" class="form-input" placeholder="Nhập tên thú cưng" 
                                       value="<%= hasPet ? pet.getPetName() : "" %>" required>
                            </div>

                            <div class="form-group">
                                <label class="form-label">
                                    <i class="fas fa-dog"></i> Loài
                                </label>
                                <select name="species" class="form-select" required>
                                    <option value="">Chọn loài thú cưng</option>
                                    <option value="dog" <%= hasPet && "dog".equals(pet.getSpecies()) ? "selected" : "" %>>🐶 Chó</option>
                                    <option value="cat" <%= hasPet && "cat".equals(pet.getSpecies()) ? "selected" : "" %>>🐱 Mèo</option>
                                    <option value="bird" <%= hasPet && "bird".equals(pet.getSpecies()) ? "selected" : "" %>>🐦 Chim</option>
                                    <option value="rabbit" <%= hasPet && "rabbit".equals(pet.getSpecies()) ? "selected" : "" %>>🐰 Thỏ</option>
                                    <option value="hamster" <%= hasPet && "hamster".equals(pet.getSpecies()) ? "selected" : "" %>>🐹 Hamster</option>
                                    <option value="fish" <%= hasPet && "fish".equals(pet.getSpecies()) ? "selected" : "" %>>🐠 Cá</option>
                                    <option value="other" <%= hasPet && "other".equals(pet.getSpecies()) ? "selected" : "" %>>🐾 Khác</option>
                                </select>
                            </div>
                        </div>

                        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                            <div class="form-group">
                                <label class="form-label">
                                    <i class="fas fa-dna"></i> Giống
                                </label>
                                <input type="text" name="breed" class="form-input" placeholder="Ví dụ: Golden Retriever, Persian..." 
                                       value="<%= hasPet ? pet.getBreed() : "" %>" required>
                            </div>

                            <div class="form-group">
                                <label class="form-label">
                                    <i class="fas fa-birthday-cake"></i> Tuổi
                                </label>
                                <input type="number" name="age" class="form-input" placeholder="Tuổi (năm)" min="0" max="30" 
                                       value="<%= hasPet ? pet.getAge() : "" %>" required>
                            </div>
                        </div>

                        <div class="form-group">
                            <label class="form-label">
                                <i class="fas fa-venus-mars"></i> Giới tính
                            </label>
                            <div class="flex gap-4">
                                <label class="flex items-center">
                                    <input type="radio" name="gender" value="male" class="mr-2" 
                                           <%= hasPet && "male".equals(pet.getGender()) ? "checked" : "" %>>
                                    <span>♂️ Đực</span>
                                </label>
                                <label class="flex items-center">
                                    <input type="radio" name="gender" value="female" class="mr-2"
                                           <%= hasPet && "female".equals(pet.getGender()) ? "checked" : "" %>>
                                    <span>♀️ Cái</span>
                                </label>
                            </div>
                        </div>
                    </div>

                    <!-- Upload ảnh -->
                    <div id="photo" class="form-section">
                        <h3 class="section-title">
                            <i class="fas fa-camera"></i> Ảnh thú cưng
                        </h3>

                        <div class="upload-area" 
                             onclick="document.getElementById('petImage').click()"
                             ondragover="handleDragOver(event)"
                             ondragleave="handleDragLeave(event)"
                             ondrop="handleDrop(event)">
                            <i class="fas fa-cloud-upload-alt text-4xl mb-4" style="color: #6FD5DD;"></i>
                            <p class="text-lg font-semibold mb-2" style="color: #34495E;">Kéo thả ảnh vào đây hoặc click để chọn</p>
                            <p class="text-sm" style="color: #A9A9A9;">Hỗ trợ: JPG, PNG, GIF (tối đa 5MB)</p>
                            <input type="file" id="petImage" name="petImage" accept="image/*" style="display: none;" onchange="previewImage(this)">
                        </div>

                        <div id="imagePreview" style="display: none;"></div>
                    </div>

                    <!-- Mô tả thêm -->
                    <div id="desc" class="form-section">
                        <h3 class="section-title">
                            <i class="fas fa-edit"></i> Mô tả thêm
                        </h3>

                        <div class="form-group">
                            <label class="form-label">
                                <i class="fas fa-info-circle"></i> Mô tả về thú cưng
                            </label>
                            <textarea name="description" class="form-textarea" placeholder="Kể về tính cách, sở thích, đặc điểm đặc biệt của thú cưng..."><%= hasPet && pet.getDescription() != null ? pet.getDescription() : "" %></textarea>
                        </div>

                        <div class="form-group">
                            <label class="form-label">
                                <i class="fas fa-heartbeat"></i> Tình trạng sức khỏe
                            </label>
                            <textarea name="healthStatus" class="form-textarea" placeholder="Tình trạng sức khỏe hiện tại, bệnh tật, dị ứng..."><%= hasPet && pet.getHealthStatus() != null ? pet.getHealthStatus() : "" %></textarea>
                        </div>
                    </div>

                    <!-- Nút submit -->
                    <div class="text-center space-y-4">
                        <div class="flex flex-col md:flex-row gap-3 justify-center">
                            <button type="submit" class="btn-primary w-full md:w-auto">
                                <i class="fas fa-save"></i> Lưu thông tin thú cưng
                            </button>
                            <button type="reset" class="btn-secondary">
                                <i class="fas fa-undo"></i> Đặt lại
                            </button>
                        </div>
                        <div class="flex justify-center gap-4">
                            <a href="<%= request.getContextPath()%>/home" class="btn-secondary">
                                <i class="fas fa-home"></i> Về trang chủ
                            </a>
                            <a href="user-info.jsp" class="btn-secondary">
                                <i class="fas fa-user"></i> Thông tin tài khoản
                            </a>
                            <a href="<%= request.getContextPath()%>/health-check-booking" class="btn-secondary">
                                <i class="fas fa-calendar-check"></i> Đặt lịch khám
                            </a>
                        </div>
                    </div>
                    <!-- Hidden field cho pet ID -->
                    <% if (hasPet) { %>
                    <input type="hidden" name="petId" value="<%= pet.getId() %>">
                    <% } %>
                </form>
            </div>
        </main>


        <footer class="mt-10 text-sm text-gray-500 py-4">
            <p><strong>Petcity - Siêu thị thú cưng online</strong></p>
            <p>Địa chỉ: Môn SWP</p>
            <p>Điện thoại: 090 900 900</p>
            <p>Email: support@petcity.vn</p>
            <p>© 2025 Petcity. Bản quyền thuộc về G5.</p>
        </footer>

        <jsp:include page="/chatbox.jsp"/>
    </body>
</html>