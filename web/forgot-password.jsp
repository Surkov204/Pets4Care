<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quên mật khẩu - Petcity</title>
    <link href="https://fonts.googleapis.com/css2?family=Quicksand:wght@300;400;500;600;700&family=Nunito:wght@300;400;500;600;700;800&family=Baloo+2:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.3/css/all.min.css" rel="stylesheet" />
    <style>
        :root {
            --main-bg: #FFFDF8;
            --card-bg: #FFFFFF;
            --primary: #6FD5DD;
            --secondary: #FFD6C0;
            --text: #34495E;
            --text-light: #A9A9A9;
            --error: #e53e3e;
            --success: #38a169;
            --border-radius: 20px;
            --shadow: 0 4px 28px rgba(140, 170, 205, 0.18);
        }
        
        body {
            font-family: 'Quicksand', sans-serif;
            background: var(--main-bg);
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            padding: 1rem;
            margin: 0;
        }
        
        .forgot-password-container {
            background: var(--card-bg);
            padding: 2.5rem;
            border-radius: var(--border-radius);
            box-shadow: var(--shadow);
            width: 100%;
            max-width: 450px;
            text-align: center;
        }
        
        .logo {
            color: var(--primary);
            font-size: 2.5rem;
            margin-bottom: 1rem;
        }
        
        h1 {
            color: var(--primary);
            font-family: 'Baloo 2', cursive;
            margin-bottom: 0.5rem;
        }
        
        .subtitle {
            color: var(--text-light);
            margin-bottom: 2rem;
        }
        
        .form-group {
            margin-bottom: 1.5rem;
            text-align: left;
        }
        
        label {
            display: block;
            color: var(--primary);
            margin-bottom: 0.5rem;
            font-weight: 600;
        }
        
        input[type="email"] {
            width: 100%;
            padding: 1rem;
            border: 2px solid rgba(111, 213, 221, 0.3);
            border-radius: 12px;
            font-family: 'Quicksand', sans-serif;
            font-size: 1rem;
        }
        
        input[type="email"]:focus {
            outline: none;
            border-color: var(--primary);
            box-shadow: 0 0 0 3px rgba(111, 213, 221, 0.2);
        }
        
        .btn {
            background: linear-gradient(135deg, var(--primary), var(--secondary));
            color: white;
            border: none;
            padding: 1rem;
            width: 100%;
            border-radius: 12px;
            font-family: 'Quicksand', sans-serif;
            font-size: 1rem;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.2s;
            margin-top: 0.5rem;
        }
        
        .btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(111, 213, 221, 0.3);
        }
        
        .back-link {
            display: inline-block;
            margin-top: 1.5rem;
            color: var(--primary);
            text-decoration: none;
            font-weight: 600;
        }
        
        .back-link:hover {
            text-decoration: underline;
        }
        
        .alert {
            padding: 1rem;
            border-radius: 12px;
            margin-bottom: 1.5rem;
            text-align: center;
        }
        
        .alert-success {
            background-color: #f0fff4;
            color: var(--success);
            border-left: 4px solid var(--success);
        }
        
        .alert-error {
            background-color: #fff5f5;
            color: var(--error);
            border-left: 4px solid var(--error);
        }
    </style>
</head>
<body>
    <div class="forgot-password-container">
        <div class="logo">🐾</div>
        <h1>Quên mật khẩu</h1>
        <p class="subtitle">Nhập email của bạn để nhận mã xác nhận</p>
        
        <c:if test="${not empty message_forgotpass}">
            <div class="alert alert-${messageType}">
                <i class="fas ${messageType == 'success' ? 'fa-check-circle' : 'fa-exclamation-circle'}"></i>
                ${message_forgotpass}
            </div>
        </c:if>
        
        <form action="forgotpasswordservlet" method="post">
            <div class="form-group">
                <label for="email"><i class="fas fa-envelope"></i> Email</label>
                <input type="email" id="email" name="email" required 
                       placeholder="Nhập email đã đăng ký">
            </div>
            
            <button type="submit" class="btn">
                <i class="fas fa-paper-plane"></i> Gửi mã xác nhận
            </button>
        </form>
        
        <a href="login.jsp" class="back-link">
            <i class="fas fa-arrow-left"></i> Quay lại trang đăng nhập
        </a>
    </div>
</body>
</html>