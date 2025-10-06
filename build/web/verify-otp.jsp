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
            background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
            margin: 0;
            padding: 20px;
        }
        .otp-container {
            background: white;
            padding: 40px;
            border-radius: 20px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.1);
            width: 100%;
            max-width: 400px;
            text-align: center;
            border: 2px solid rgba(111, 213, 221, 0.2);
        }
        .otp-container h2 {
            color: #6FD5DD;
            margin-bottom: 20px;
            font-size: 1.8rem;
        }
        .otp-input {
            font-size: 28px;
            letter-spacing: 15px;
            padding: 15px;
            width: 250px;
            text-align: center;
            margin: 20px auto;
            border: 2px solid #e0e0e0;
            border-radius: 10px;
            transition: all 0.3s ease;
            font-weight: bold;
        }
        .otp-input:focus {
            border-color: #6FD5DD;
            outline: none;
            box-shadow: 0 0 10px rgba(111, 213, 221, 0.3);
        }
        .btn {
            background: linear-gradient(135deg, #6FD5DD, #FFD6C0);
            color: white;
            border: none;
            padding: 12px 25px;
            border-radius: 25px;
            cursor: pointer;
            font-size: 16px;
            font-weight: 600;
            transition: all 0.3s ease;
            margin: 5px;
        }
        .btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(111, 213, 221, 0.4);
        }
        .alert {
            padding: 15px;
            margin-bottom: 20px;
            border-radius: 10px;
            font-weight: 500;
        }
        .alert-success {
            background: linear-gradient(135deg, #d4edda, #c3e6cb);
            color: #155724;
            border-left: 4px solid #28a745;
        }
        .alert-error {
            background: linear-gradient(135deg, #f8d7da, #f5c6cb);
            color: #721c24;
            border-left: 4px solid #dc3545;
        }
        .info-box {
            background: linear-gradient(135deg, #e3f2fd, #bbdefb);
            border-radius: 10px;
            padding: 15px;
            margin-top: 20px;
            border-left: 4px solid #2196f3;
        }
        .info-box p {
            margin: 5px 0;
            color: #1565c0;
            font-size: 0.9rem;
        }
    </style>
</head>
<body>
    <div class="otp-container">
        <h2>🐾 Xác nhận mã OTP</h2>
        
        <c:if test="${not empty message_verify}">
            <div class="alert alert-${messageType}">
                <c:choose>
                    <c:when test="${messageType == 'success'}">
                        ✅ ${message_verify}
                    </c:when>
                    <c:otherwise>
                        ❌ ${message_verify}
                    </c:otherwise>
                </c:choose>
            </div>
        </c:if>
        
        <c:if test="${not empty message_register}">
            <div class="alert alert-${messageType}" style="margin-top: 1rem;">
                <c:choose>
                    <c:when test="${messageType == 'success'}">
                        ✅ ${message_register}
                    </c:when>
                    <c:otherwise>
                        ❌ ${message_register}
                    </c:otherwise>
                </c:choose>
            </div>
        </c:if>
        
        <form action="verifyotp" method="post">
            <p>Nhập mã 6 số đã gửi đến email của bạn</p>
            <input type="text" name="otp" class="otp-input" maxlength="6" required 
                   pattern="\d{6}" title="Vui lòng nhập đúng 6 chữ số" 
                   placeholder="000000">
            <br>
            <button type="submit" class="btn">🔐 Xác nhận</button>
        </form>
        
        <form action="resendotp" method="post" style="margin-top: 20px;">
            <button type="submit" class="btn">📧 Gửi lại mã OTP</button>
        </form>
        
        <div class="info-box">
            <p>💡 <strong>Lưu ý:</strong> Mã OTP có hiệu lực trong 5 phút</p>
            <p>🔄 Bạn có thể gửi lại mã nếu chưa nhận được</p>
        </div>
    </div>

    <script>
        // Auto focus vào input OTP
        document.addEventListener('DOMContentLoaded', function() {
            const otpInput = document.querySelector('.otp-input');
            if (otpInput) {
                otpInput.focus();
                
                // Chỉ cho phép nhập số
                otpInput.addEventListener('input', function(e) {
                    this.value = this.value.replace(/[^0-9]/g, '');
                });
                
                // Auto submit khi nhập đủ 6 số
                otpInput.addEventListener('input', function(e) {
                    if (this.value.length === 6) {
                        // Tự động submit form sau 0.5 giây
                        setTimeout(() => {
                            this.form.submit();
                        }, 500);
                    }
                });
            }
            
            // Hiệu ứng typing cho input
            const inputs = document.querySelectorAll('.otp-input');
            inputs.forEach(input => {
                input.addEventListener('focus', function() {
                    this.style.transform = 'scale(1.05)';
                    this.style.boxShadow = '0 0 10px rgba(111, 213, 221, 0.3)';
                });
                
                input.addEventListener('blur', function() {
                    this.style.transform = 'scale(1)';
                    this.style.boxShadow = 'none';
                });
            });
        });
    </script>
</body>
</html>