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
        response.sendRedirect("login.jsp");
        return;
    }
%>

<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <title>Thông tin tài khoản - Petcity</title>
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
            
            /* Sidebar Navigation Styles */
            .sidebar-nav {
                position: sticky;
                top: 20px;
                background: white;
                border-radius: 12px;
                box-shadow: 0 2px 8px rgba(0,0,0,0.1);
                padding: 1.5rem;
            }
            
            .sidebar-nav-item {
                display: flex;
                align-items: center;
                padding: 0.75rem 1rem;
                margin-bottom: 0.5rem;
                border-radius: 8px;
                text-decoration: none;
                color: #4b5563;
                transition: all 0.2s;
                cursor: pointer;
            }
            
            .sidebar-nav-item:hover {
                background: #f3f4f6;
                color: #f97316;
            }
            
            .sidebar-nav-item.active {
                background: linear-gradient(135deg, #f97316, #fb923c);
                color: white;
            }
            
            .sidebar-nav-item i {
                margin-right: 0.75rem;
                font-size: 1.1rem;
            }
            
            @media (max-width: 768px) {
                .sidebar-nav {
                    position: relative;
                    top: 0;
                    margin-bottom: 2rem;
                }
                
                .sidebar-nav-item {
                    font-size: 0.9rem;
                    padding: 0.6rem 0.8rem;
                }
            }
        </style>
        <script>
            function validateForm() {
                var isValid = true;
                var phone = document.forms["userInfoForm"]["phone"].value;
                var email = document.forms["userInfoForm"]["email"].value;
                var name = document.forms["userInfoForm"]["name"].value;
                var address = document.forms["userInfoForm"]["address"].value;

                var phoneRegex = /^0(3|5|7|8|9)\d{8}$/;
                var emailRegex = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$/;
                var nameRegex = /^[A-Za-zÀ-ỹ\s]+$/;

                // Reset error styles
                document.getElementById("nameError").innerText = "";
                document.getElementById("phoneError").innerText = "";
                document.getElementById("emailError").innerText = "";
                document.getElementById("addressError").innerText = "";

                document.forms["userInfoForm"]["name"].classList.remove("input-error");
                document.forms["userInfoForm"]["phone"].classList.remove("input-error");
                document.forms["userInfoForm"]["email"].classList.remove("input-error");
                document.forms["userInfoForm"]["address"].classList.remove("input-error");

                // Validate name
                if (name == "" || !nameRegex.test(name)) {
                    document.getElementById("nameError").innerText = "Họ và tên không hợp lệ! Chỉ chứa chữ cái và khoảng trắng.";
                    document.forms["userInfoForm"]["name"].classList.add("input-error");
                    isValid = false;
                }

                // Validate phone
                if (!phoneRegex.test(phone)) {
                    document.getElementById("phoneError").innerText = "Số điện thoại không hợp lệ! Số điện thoại phải bắt đầu bằng 0 và có độ dài 10 chữ số.";
                    document.forms["userInfoForm"]["phone"].classList.add("input-error");
                    isValid = false;
                }

                // Validate email
                if (!emailRegex.test(email)) {
                    document.getElementById("emailError").innerText = "Email không hợp lệ!";
                    document.forms["userInfoForm"]["email"].classList.add("input-error");
                    isValid = false;
                }

                // Validate address
                if (address == "") {
                    document.getElementById("addressError").innerText = "Địa chỉ không được để trống!";
                    document.forms["userInfoForm"]["address"].classList.add("input-error");
                    isValid = false;
                }

                return isValid;
            }

            function checkNameInput() {
                var name = document.forms["userInfoForm"]["name"].value;
                var nameRegex = /^[A-Za-zÀ-ỹ\s]+$/;

                if (nameRegex.test(name)) {
                    document.getElementById("nameError").innerText = "";
                    document.forms["userInfoForm"]["name"].classList.remove("input-error");
                } else {
                    document.getElementById("nameError").innerText = "Họ và tên không hợp lệ! Chỉ chứa chữ cái và khoảng trắng.";
                    document.forms["userInfoForm"]["name"].classList.add("input-error");
                }
            }
        </script>
    </head>

    <body class="bg-gray-50">

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
                <li><a href="spa-service.jsp">DỊCH VỤ</a></li>
                <li><a href="<%= request.getContextPath()%>/health-check-booking">ĐẶT LỊCH KHÁM</a></li>
                <li><a href="search?categoryId=2">SẢN PHẨM</a></li>
                <li><a href="doctor.jsp">BÁC SĨ</a></li>
                <li><a href="gioi-thieu.jsp">GIỚI THIỆU</a></li>
                <li><a href="tin-tuc.jsp">TIN TỨC</a></li>
                <li><a href="lien-he.jsp">LIÊN HỆ</a></li>
            </ul>
        </nav>

        <!-- Breadcrumbs -->
        <div class="max-w-7xl mx-auto mt-6 px-6">
            <nav class="text-sm text-gray-500 mb-4" aria-label="Breadcrumb">
                <ol class="list-reset flex">
                    <li><a href="<%= request.getContextPath()%>/home" class="text-blue-600 hover:underline">Trang chủ</a></li>
                    <li><span class="mx-2">/</span></li>
                    <li class="text-gray-700">Tài khoản</li>
                </ol>
            </nav>
        </div>

        <!-- MAIN CONTENT WITH SIDEBAR -->
        <main class="max-w-7xl mx-auto mt-4 px-6 pb-10">
            <div class="grid grid-cols-1 md:grid-cols-4 gap-6">
                <!-- Sidebar Navigation -->
                <aside class="md:col-span-1">
                    <div class="sidebar-nav">
                        <h3 class="text-lg font-bold text-gray-800 mb-4">Quản lý tài khoản</h3>
                        <a href="#account" class="sidebar-nav-item active" data-section="account">
                            <i class="fas fa-user"></i>
                            <span>Thông tin tài khoản</span>
                        </a>
                        <a href="#password" class="sidebar-nav-item" data-section="password">
                            <i class="fas fa-lock"></i>
                            <span>Đổi mật khẩu</span>
                        </a>
                        <a href="#pet" class="sidebar-nav-item" data-section="pet">
                            <i class="fas fa-paw"></i>
                            <span>Thông tin thú cưng</span>
                        </a>
                        <hr class="my-3 border-gray-200">
                        <a href="<%= request.getContextPath()%>/health-check-booking" class="sidebar-nav-item">
                            <i class="fas fa-calendar-check"></i>
                            <span>Đặt lịch khám</span>
                        </a>
                        <a href="<%= request.getContextPath()%>/home" class="sidebar-nav-item">
                            <i class="fas fa-home"></i>
                            <span>Về trang chủ</span>
                        </a>
                    </div>
                </aside>

                <!-- Main Content Area -->
                <div class="md:col-span-3 space-y-10">
            <section id="account" class="bg-white shadow rounded p-8">
                <h2 class="text-2xl font-bold text-orange-600 mb-6 text-center">👤 Thông Tin Tài Khoản</h2>

                <% String message = (String) request.getAttribute("message"); %>
                <% if (message != null) {%>
                <div class="bg-green-100 text-green-700 px-4 py-3 rounded mb-4">
                    <%= message%>
                </div>
                <% } %>

                <% String error = (String) request.getAttribute("error"); %>
                <% if (error != null) {%>
                <div class="bg-red-100 text-red-700 px-4 py-3 rounded mb-4">
                    <%= error%>
                </div>
                <% }%>

                <form name="userInfoForm" onsubmit="return validateForm()" action="<%= request.getContextPath()%>/updateuserservlet" method="post" class="space-y-4">
                    <div>
                        <label class="block text-gray-700 mb-1">Họ và tên</label>
                        <input type="text" name="name" value="<%= currentUser.getName()%>" oninput="checkNameInput()" class="w-full border border-gray-300 p-3 rounded" required>
                        <span id="nameError" class="error-message"></span>
                    </div>
                    <div>
                        <label class="block text-gray-700 mb-1">Email</label>
                        <input type="email" name="email" value="<%= currentUser.getEmail()%>" class="w-full border border-gray-300 p-3 rounded" required>
                        <span id="emailError" class="error-message">
                            <c:if test="${not empty emailError}">${emailError}</c:if>
                            </span>
                            <p class="text-sm text-orange-600 mt-1">⚠️ Nếu thay đổi email, bạn sẽ cần xác thực OTP qua email mới</p>
                        </div>
                        <div>
                            <label class="block text-gray-700 mb-1">Số điện thoại</label>
                            <input type="text" name="phone" value="<%= currentUser.getPhone()%>" class="w-full border border-gray-300 p-3 rounded" required>
                        <span id="phoneError" class="error-message">
                            <c:if test="${not empty phoneError}">${phoneError}</c:if>
                            </span>
                        </div>
                        <div>
                            <label class="block text-gray-700 mb-1">Địa chỉ</label>
                            <input type="text" name="address" value="<%= currentUser.getAddressCustomer()%>" class="w-full border border-gray-300 p-3 rounded" required>
                        <span id="addressError" class="error-message"></span>
                    </div>
                    <div class="flex flex-col md:flex-row gap-3">
                        <button type="submit" class="bg-orange-500 hover:bg-orange-600 text-white w-full md:w-auto px-6 py-3 rounded">
                            <i class="fas fa-save mr-2"></i>Cập nhật thông tin
                        </button>
                        <button type="reset" class="bg-gray-100 hover:bg-gray-200 text-gray-700 w-full md:w-auto px-6 py-3 rounded border border-gray-300">
                            <i class="fas fa-undo mr-2"></i>Đặt lại
                        </button>
                    </div>
                </form>
                <div class="mt-4 text-center">
                    <a href="<%= request.getContextPath()%>/home" class="text-blue-500 hover:underline">← Về trang chủ</a>
                </div>
            </section>

            <!-- Change Password Section -->
            <section id="password" class="bg-white shadow rounded p-8">
                <h2 class="text-2xl font-bold text-orange-600 mb-6 text-center">🔒 Đổi mật khẩu</h2>

                <% String changePwdMsg = (String) request.getAttribute("changePwdMsg"); %>
                <% String changePwdErr = (String) request.getAttribute("changePwdErr"); %>
                <% if (changePwdMsg != null) {%>
                <div class="bg-green-100 text-green-700 px-4 py-3 rounded mb-4"><%= changePwdMsg%></div>
                <% } %>
                <% if (changePwdErr != null) {%>
                <div class="bg-red-100 text-red-700 px-4 py-3 rounded mb-4"><%= changePwdErr%></div>
                <% }%>

                <form action="<%= request.getContextPath()%>/changepassword" method="post" class="space-y-4">
                    <div>
                        <label class="block text-gray-700 mb-1">Mật khẩu hiện tại</label>
                        <input type="password" name="currentPassword" class="w-full border border-gray-300 p-3 rounded" required>
                    </div>
                    <div>
                        <label class="block text-gray-700 mb-1">Mật khẩu mới</label>
                        <input type="password" name="newPassword" class="w-full border border-gray-300 p-3 rounded" required minlength="6">
                    </div>
                    <div>
                        <label class="block text-gray-700 mb-1">Xác nhận mật khẩu mới</label>
                        <input type="password" name="confirmPassword" class="w-full border border-gray-300 p-3 rounded" required minlength="6">
                    </div>
                    <button type="submit" class="bg-blue-600 hover:bg-blue-700 text-white w-full py-3 rounded">Đổi mật khẩu</button>
                </form>
            </section>

            <!-- Pet Information Section -->
            <section id="pet" class="bg-white shadow rounded p-8">
                <h2 class="text-2xl font-bold text-orange-600 mb-6 text-center">🐾 Thông tin thú cưng</h2>
                
                <div class="text-center mb-6">
                    <p class="text-gray-600 mb-4">Quản lý thông tin thú cưng của bạn để có trải nghiệm mua sắm tốt nhất</p>
                    <div class="flex flex-col sm:flex-row gap-3 justify-center">
                        <a href="<%= request.getContextPath()%>/petinfoservlet" class="bg-gradient-to-r from-pink-500 to-purple-600 hover:from-pink-600 hover:to-purple-700 text-white font-bold py-3 px-6 rounded-lg transition-all duration-300 transform hover:scale-105 shadow-lg">
                            <i class="fas fa-paw mr-2"></i> Quản lý thông tin thú cưng
                        </a>
                        <a href="<%= request.getContextPath()%>/health-check-booking" class="bg-blue-50 hover:bg-blue-100 text-blue-700 font-semibold py-3 px-6 rounded-lg border border-blue-200">
                            <i class="fas fa-calendar-check mr-2"></i> Đặt lịch khám
                        </a>
                    </div>
                </div>
                
                <div class="grid grid-cols-1 md:grid-cols-3 gap-4 mt-6">
                    <div class="bg-gradient-to-br from-blue-50 to-blue-100 p-4 rounded-lg text-center">
                        <i class="fas fa-heart text-blue-500 text-2xl mb-2"></i>
                        <h3 class="font-semibold text-blue-700">Thông tin cơ bản</h3>
                        <p class="text-sm text-blue-600">Tên, loài, giống, tuổi</p>
                    </div>
                    <div class="bg-gradient-to-br from-green-50 to-green-100 p-4 rounded-lg text-center">
                        <i class="fas fa-camera text-green-500 text-2xl mb-2"></i>
                        <h3 class="font-semibold text-green-700">Ảnh thú cưng</h3>
                        <p class="text-sm text-green-600">Upload ảnh đáng yêu</p>
                    </div>
                    <div class="bg-gradient-to-br from-purple-50 to-purple-100 p-4 rounded-lg text-center">
                        <i class="fas fa-notes-medical text-purple-500 text-2xl mb-2"></i>
                        <h3 class="font-semibold text-purple-700">Sức khỏe</h3>
                        <p class="text-sm text-purple-600">Tình trạng sức khỏe</p>
                    </div>
                </div>
            </section>
                </div>
            </div>
        </main>
        
        <script>
            // Sidebar navigation active state
            document.addEventListener('DOMContentLoaded', function() {
                const navItems = document.querySelectorAll('.sidebar-nav-item[data-section]');
                const sections = document.querySelectorAll('section[id]');
                
                // Update active state on scroll
                window.addEventListener('scroll', function() {
                    let current = '';
                    sections.forEach(section => {
                        const sectionTop = section.offsetTop;
                        const sectionHeight = section.clientHeight;
                        if (pageYOffset >= (sectionTop - 200)) {
                            current = section.getAttribute('id');
                        }
                    });
                    
                    navItems.forEach(item => {
                        item.classList.remove('active');
                        if (item.getAttribute('data-section') === current) {
                            item.classList.add('active');
                        }
                    });
                });
                
                // Smooth scroll on click
                navItems.forEach(item => {
                    item.addEventListener('click', function(e) {
                        e.preventDefault();
                        const targetId = this.getAttribute('data-section');
                        const targetSection = document.getElementById(targetId);
                        if (targetSection) {
                            targetSection.scrollIntoView({ behavior: 'smooth', block: 'start' });
                        }
                    });
                });
            });
        </script>

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