<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page isErrorPage="true" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Lỗi - Pets4Care</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <style>
        .error-animation {
            animation: bounce 2s infinite;
        }
        @keyframes bounce {
            0%, 20%, 50%, 80%, 100% {
                transform: translateY(0);
            }
            40% {
                transform: translateY(-10px);
            }
            60% {
                transform: translateY(-5px);
            }
        }
    </style>
</head>
<body class="bg-gradient-to-br from-red-50 to-orange-50 min-h-screen flex items-center justify-center">
    <div class="max-w-md w-full mx-4">
        <div class="bg-white rounded-2xl shadow-2xl p-8 text-center">
            <!-- Error Icon -->
            <div class="error-animation mb-6">
                <div class="bg-red-100 rounded-full w-24 h-24 flex items-center justify-center mx-auto">
                    <i class="fas fa-exclamation-triangle text-4xl text-red-500"></i>
                </div>
            </div>
            
            <!-- Error Message -->
            <h1 class="text-3xl font-bold text-gray-800 mb-4">Oops! Có lỗi xảy ra</h1>
            <p class="text-gray-600 mb-6">
                Xin lỗi, đã có lỗi xảy ra trong quá trình xử lý yêu cầu của bạn. 
                Vui lòng thử lại sau hoặc liên hệ với chúng tôi nếu vấn đề vẫn tiếp diễn.
            </p>
            
            <!-- Error Details (only show in development) -->
            <% if (exception != null && request.getServerName().contains("localhost")) { %>
            <div class="bg-gray-100 rounded-lg p-4 mb-6 text-left">
                <h3 class="font-semibold text-gray-700 mb-2">Chi tiết lỗi:</h3>
                <p class="text-sm text-gray-600 font-mono">
                    <%= exception.getClass().getSimpleName() %>: <%= exception.getMessage() %>
                </p>
            </div>
            <% } %>
            
            <!-- Action Buttons -->
            <div class="space-y-3">
                <a href="${pageContext.request.contextPath}/home" 
                   class="block w-full bg-orange-500 hover:bg-orange-600 text-white font-semibold py-3 px-6 rounded-lg transition duration-300">
                    <i class="fas fa-home mr-2"></i>Về trang chủ
                </a>
                
                <a href="javascript:history.back()" 
                   class="block w-full bg-gray-500 hover:bg-gray-600 text-white font-semibold py-3 px-6 rounded-lg transition duration-300">
                    <i class="fas fa-arrow-left mr-2"></i>Quay lại
                </a>
                
                <a href="mailto:support@pets4care.com" 
                   class="block w-full bg-blue-500 hover:bg-blue-600 text-white font-semibold py-3 px-6 rounded-lg transition duration-300">
                    <i class="fas fa-envelope mr-2"></i>Liên hệ hỗ trợ
                </a>
            </div>
            
            <!-- Additional Help -->
            <div class="mt-8 pt-6 border-t border-gray-200">
                <p class="text-sm text-gray-500">
                    Nếu bạn cần hỗ trợ ngay lập tức, vui lòng gọi hotline: 
                    <span class="font-semibold text-orange-600">1900-1234</span>
                </p>
            </div>
        </div>
        
        <!-- Footer -->
        <div class="text-center mt-8">
            <p class="text-gray-500 text-sm">
                © 2024 Pets4Care. Tất cả quyền được bảo lưu.
            </p>
        </div>
    </div>
</body>
</html>
