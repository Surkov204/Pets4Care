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
            if (item != null && item.getToy() != null) {
                cartCount += item.getQuantity();
                cartTotal += item.getQuantity() * item.getToy().getPrice();
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
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/homeStyle.css" />
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
    <a href="<%= request.getContextPath() %>/home" class="logo">
        <img src="https://storage.googleapis.com/a1aa/image/15870274-75b6-4029-e89c-1424dc010c18.jpg" width="60" height="60" alt="Logo Petcity" />
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
            👤 Xin chào, <b><%= currentUser.getName() %></b>
            <a href="<%= request.getContextPath() %>/logout.jsp" class="text-blue-500 hover:underline ml-2">[Đăng xuất]</a>
        </div>
        <div>
            <a href="<%= request.getContextPath() %>/cart/cart.jsp"><i class="fas fa-shopping-cart"></i> Giỏ hàng / <span class="cart-amount"><%= String.format("%.2f", cartTotal) %></span>₫</a>
            <span class="cart-count"><%= cartCount %></span>
        </div>
    </div>
</header>

<!-- Navigation -->
<nav>
    <ul>
        <li><a href="<%= request.getContextPath() %>/home">TRANG CHỦ</a></li>
        <li><a href="gioi-thieu.jsp">GIỚI THIỆU</a></li>
        <li><a href="search?categoryId=1">SHOP CÚN CƯNG</a></li>
        <li><a href="search?categoryId=2">SHOP MÈO CƯNG</a></li>
        <li><a href="search?categoryId=3">SHOP VẬT NUÔI KHÁC</a></li>
        <li><a href="tin-tuc.jsp">TIN TỨC</a></li>
        <li><a href="meo-vat.jsp">MẸO VẶT</a></li>
        <li><a href="lien-he.jsp">LIÊN HỆ</a></li>
    </ul>
</nav>

<!-- MAIN CONTENT -->
<main class="max-w-4xl mx-auto mt-10 px-6 space-y-10">
    <section class="bg-white shadow rounded p-8">
        <h2 class="text-2xl font-bold text-orange-600 mb-6 text-center">👤 Thông Tin Tài Khoản</h2>

        <% String message = (String) request.getAttribute("message"); %>
        <% if (message != null) { %>
            <div class="bg-green-100 text-green-700 px-4 py-3 rounded mb-4">
                <%= message %>
            </div>
        <% } %>

        <% String error = (String) request.getAttribute("error"); %>
        <% if (error != null) { %>
            <div class="bg-red-100 text-red-700 px-4 py-3 rounded mb-4">
                <%= error %>
            </div>
        <% } %>

        <form name="userInfoForm" onsubmit="return validateForm()" action="<%= request.getContextPath() %>/updateuserservlet" method="post" class="space-y-4">
            <div>
                <label class="block text-gray-700 mb-1">Họ và tên</label>
                <input type="text" name="name" value="<%= currentUser.getName() %>" oninput="checkNameInput()" class="w-full border border-gray-300 p-3 rounded" required>
                <span id="nameError" class="error-message"></span>
            </div>
            <div>
                <label class="block text-gray-700 mb-1">Email</label>
                <input type="email" name="email" value="<%= currentUser.getEmail() %>" class="w-full border border-gray-300 p-3 rounded" required>
                <span id="emailError" class="error-message">
                    <c:if test="${not empty emailError}">${emailError}</c:if>
                </span>
            </div>
            <div>
                <label class="block text-gray-700 mb-1">Số điện thoại</label>
                <input type="text" name="phone" value="<%= currentUser.getPhone() %>" class="w-full border border-gray-300 p-3 rounded" required>
                <span id="phoneError" class="error-message">
                    <c:if test="${not empty phoneError}">${phoneError}</c:if>
                </span>
            </div>
            <div>
                <label class="block text-gray-700 mb-1">Địa chỉ</label>
                <input type="text" name="address" value="<%= currentUser.getAddressCustomer() %>" class="w-full border border-gray-300 p-3 rounded" required>
                <span id="addressError" class="error-message"></span>
            </div>
            <button type="submit" class="bg-orange-500 hover:bg-orange-600 text-white w-full py-3 rounded">
                Cập nhật thông tin
            </button>
        </form>
        <div class="mt-4 text-center">
            <a href="<%= request.getContextPath() %>/home" class="text-blue-500 hover:underline">← Về trang chủ</a>
        </div>
    </section>
</main>

<footer class="mt-10 text-center text-sm text-gray-500 py-4">
    <p><strong>Petcity - Siêu thị thú cưng online</strong></p>
    <p>Địa chỉ: Môn PRJ</p>
    <p>Điện thoại: 090 900 900</p>
    <p>Email: support@petcity.vn</p>
    <p>© 2025 Petcity. Bản quyền thuộc về Tiến.</p>
</footer>

<jsp:include page="/chatbox.jsp"/>
</body>
</html>