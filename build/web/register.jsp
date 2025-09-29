<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <title>Đăng ký</title>
    <link href="https://fonts.googleapis.com/css2?family=Baloo+2:wght@600&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/tailwindcss@2.2.19/dist/tailwind.min.css" rel="stylesheet">
    <script>
        function validateForm() {
            var phone = document.forms["registerForm"]["phone"].value;
            var email = document.forms["registerForm"]["email"].value;
            var name = document.forms["registerForm"]["name"].value;
            var password = document.forms["registerForm"]["password"].value;
            var address = document.forms["registerForm"]["address"].value;

            var phoneRegex = /^0(3|5|7|8|9)\d{8}$/;
            var emailRegex = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$/;
            var nameRegex = /^[A-Za-zÀ-ỹ\s]+$/;
            
            // Validate name
            if (name == "" || !nameRegex.test(name)) {
                alert("Họ và tên không hợp lệ! Chỉ chứa chữ cái và khoảng trắng.");
                return false;
            }

            // Validate phone
            if (!phoneRegex.test(phone)) {
                alert("Số điện thoại không hợp lệ! Số điện thoại phải bắt đầu bằng 0 và có độ dài 10 chữ số.");
                return false;
            }

            // Validate email
            if (!emailRegex.test(email)) {
                alert("Email không hợp lệ!");
                return false;
            }

            // Validate password
            if (password == "") {
                alert("Mật khẩu không được để trống!");
                return false;
            }

            // Validate address
            if (address == "") {
                alert("Địa chỉ không được để trống!");
                return false;
            }

            return true;
        }

        function checkNameInput() {
            var name = document.forms["registerForm"]["name"].value;
            var nameRegex = /^[A-Za-zÀ-ỹ\s]+$/;

            if (nameRegex.test(name)) {
                document.getElementById("nameError").innerText = "";
            } else {
                document.getElementById("nameError").innerText = "Họ và tên không hợp lệ! Chỉ chứa chữ cái và khoảng trắng.";
            }
        }
    </script>
    <style>
        body {
    font-family: 'Baloo 2', cursive;
    background: linear-gradient(120deg, #fffafc 60%, #ffece0 100%);
    min-height: 100vh;
    display: flex;
    justify-content: center;
    align-items: center;
}

.register-box {
    background: #fff3f7;
    padding: 2rem 3rem;
    border-radius: 20px;
    box-shadow: 0 8px 20px rgba(255, 180, 190, 0.4);
    width: 100%;
    max-width: 480px;
}

.register-title {
    font-size: 2rem;
    color: #ff7090;
    text-align: center;
    margin-bottom: 1.5rem;
    font-weight: bold;
}

.cute-btn {
    background: linear-gradient(90deg, #ffe7be 45%, #ffd9ee 100%);
    color: #ff5c8a;
    font-weight: bold;
    border-radius: 16px;
    border: none;
    box-shadow: 0 2px 8px #ffe3cb66;
    padding: 10px 24px;
    width: 100%;
    font-size: 1rem;
    transition: transform 0.15s, box-shadow 0.2s;
    cursor: pointer;
}

.cute-btn:hover {
    background: linear-gradient(90deg, #ffd4ec 40%, #ffe7be 95%);
    color: #ff9e00;
    box-shadow: 0 4px 16px #ffbaba99;
    transform: scale(1.05);
}

input {
    font-family: inherit;
    border-radius: 12px;
    border: 1px solid #ffd6e2;
    padding: 10px;
    width: 100%;
    background: #fff8fb;
    margin-bottom: 1rem;
    transition: border 0.18s;
}

input:focus {
    border: 1.5px solid #ff94b8;
    background: #fff7fc;
    outline: none;
}

.error {
    color: red;
    font-size: 0.9rem;
}

        .error-message {
            color: red;
            font-size: 0.9rem;
            margin-top: -0.5rem;
            margin-bottom: 1rem;
        }
    </style>
</head>
<body>
<div class="register-box">
    <h2 class="register-title">🐶 Đăng Ký Thành Viên</h2>
    <form name="registerForm" onsubmit="return validateForm()" action="register" method="post">
        <label>Họ và tên:</label>
        <input type="text" name="name" oninput="checkNameInput()" required />
        <span id="nameError" class="error"></span>

        <label>Số điện thoại:</label>
        <input type="text" name="phone" required />
        <c:if test="${not empty phoneError}">
            <p class="error-message">${phoneError}</p>
        </c:if>

        <label>Email:</label>
        <input type="email" name="email" required />
        <c:if test="${not empty emailError}">
            <p class="error-message">${emailError}</p>
        </c:if>

        <label>Mật khẩu:</label>
        <input type="password" name="password" required />

        <label>Địa chỉ:</label>
        <input type="text" name="address" required />

        <button type="submit" class="cute-btn">Đăng ký</button>
    </form>

    <c:if test="${not empty error}">
        <p class="text-center mt-3 text-red-500 font-semibold">${error}</p>
    </c:if>

    <p class="text-center mt-4">Đã có tài khoản? <a href="login.jsp" class="text-pink-500 font-bold hover:underline">Đăng nhập</a></p>
</div>
</body>
</html>