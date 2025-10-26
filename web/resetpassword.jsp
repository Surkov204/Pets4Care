<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đặt lại mật khẩu - Petcity</title>
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
        
        .reset-password-container {
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
        
        input[type="password"] {
            width: 100%;
            padding: 1rem;
            border: 2px solid rgba(111, 213, 221, 0.3);
            border-radius: 12px;
            font-family: 'Quicksand', sans-serif;
            font-size: 1rem;
        }
        
        input[type="password"]:focus {
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
    <div class="reset-password-container">
        <div class="logo">🐾</div>
        <h1>Đặt lại mật khẩu</h1>
        <p class="subtitle">Nhập mật khẩu mới cho tài khoản của bạn</p>
        
        <c:if test="${not empty message_resetpass}">
            <div class="alert alert-${messageType}">
                <i class="fas ${messageType == 'success' ? 'fa-check-circle' : 'fa-exclamation-circle'}"></i>
                ${message_resetpass}
            </div>
        </c:if>
        
        <form action="resetpasswordservlet" method="post">
            <input type="hidden" name="email" value="${verifiedEmail}">
            
            <div class="form-group">
                <label for="newPassword"><i class="fas fa-lock"></i> Mật khẩu mới</label>
                <input type="password" id="newPassword" name="newPassword" required 
                       placeholder="Nhập mật khẩu mới (tối thiểu 8 ký tự)" minlength="8">
            </div>
            
            <div class="form-group">
                <label for="confirmPassword"><i class="fas fa-lock"></i> Xác nhận mật khẩu</label>
                <input type="password" id="confirmPassword" name="confirmPassword" required 
                       placeholder="Nhập lại mật khẩu mới">
            </div>
            
            <button type="submit" class="btn">
                <i class="fas fa-save"></i> Đặt lại mật khẩu
            </button>
        </form>
        
        <script>
            const newPassword = document.getElementById('newPassword');
            const confirmPassword = document.getElementById('confirmPassword');
            
            confirmPassword.addEventListener('input', function() {
                if (this.value !== newPassword.value) {
                    this.setCustomValidity('Mật khẩu không khớp');
                } else {
                    this.setCustomValidity('');
                }
            });
        </script>
    </div>
</body>
</html>