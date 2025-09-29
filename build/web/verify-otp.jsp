<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Xác nhận OTP - Petcity</title>
    <style>
        body {
            font-family: 'Arial', sans-serif;
            background-color: #f5f5f5;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            margin: 0;
        }
        .otp-container {
            background: white;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 4px 8px rgba(0,0,0,0.1);
            width: 350px;
            text-align: center;
        }
        .otp-input {
            font-size: 24px;
            letter-spacing: 10px;
            padding: 10px;
            width: 200px;
            text-align: center;
            margin: 20px auto;
        }
        .btn {
            background-color: #6FD5DD;
            color: white;
            border: none;
            padding: 10px 20px;
            border-radius: 5px;
            cursor: pointer;
            font-size: 16px;
        }
        .alert {
            padding: 10px;
            margin-bottom: 20px;
            border-radius: 5px;
        }
        .alert-success {
            background-color: #d4edda;
            color: #155724;
        }
        .alert-error {
            background-color: #f8d7da;
            color: #721c24;
        }
    </style>
</head>
<body>
    <div class="otp-container">
        <h2>Xác nhận mã OTP</h2>
        
        <c:if test="${not empty message_verify}">
            <div class="alert alert-${messageType}">
                ${message_verify}
            </div>
        </c:if>
        
        <form action="verifyotp" method="post">
            <p>Nhập mã 6 số đã gửi đến email của bạn</p>
            <input type="text" name="otp" class="otp-input" maxlength="6" required 
                   pattern="\d{6}" title="Vui lòng nhập đúng 6 chữ số">
            <br>
            <button type="submit" class="btn">Xác nhận</button>
        </form>
        
        <form action="resendotp" method="post" style="margin-top: 20px;">
            <button type="submit" class="btn">Gửi lại mã OTP</button>
        </form>
    </div>
</body>
</html>