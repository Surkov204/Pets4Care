<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>🐾 Test Auto Role Detection | Pet4Care</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            max-width: 1000px;
            margin: 20px auto;
            padding: 20px;
            background-color: #f5f5f5;
        }
        .test-container {
            background: white;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            margin-bottom: 20px;
        }
        .test-account {
            background: #e8f5e8;
            padding: 15px;
            margin: 10px 0;
            border-radius: 5px;
            border-left: 4px solid #4CAF50;
        }
        .form-group {
            margin: 15px 0;
        }
        label {
            display: block;
            margin-bottom: 5px;
            font-weight: bold;
        }
        input {
            width: 100%;
            padding: 10px;
            border: 1px solid #ddd;
            border-radius: 5px;
            font-size: 16px;
        }
        button {
            background: #4CAF50;
            color: white;
            padding: 12px 24px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            font-size: 16px;
            margin: 5px;
        }
        button:hover {
            background: #45a049;
        }
        .success {
            color: #4CAF50;
            font-weight: bold;
            background: #e8f5e8;
            padding: 10px;
            border-radius: 5px;
        }
        .error {
            color: #f44336;
            font-weight: bold;
            background: #ffebee;
            padding: 10px;
            border-radius: 5px;
        }
        .info {
            background: #e3f2fd;
            padding: 15px;
            border-radius: 5px;
            border-left: 4px solid #2196F3;
        }
        .role-info {
            background: #fff3e0;
            padding: 15px;
            border-radius: 5px;
            border-left: 4px solid #FF9800;
            margin: 10px 0;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            margin: 20px 0;
        }
        th, td {
            border: 1px solid #ddd;
            padding: 12px;
            text-align: left;
        }
        th {
            background-color: #f2f2f2;
        }
    </style>
</head>
<body>
    <div class="test-container">
        <h1>🔍 Test Auto Role Detection</h1>
        
        <div class="info">
            <h3>📋 Mục đích test:</h3>
            <p>Kiểm tra xem hệ thống có thể tự động nhận diện loại tài khoản (Customer, Staff, Admin, Doctor) khi đăng nhập hay không.</p>
        </div>
        
        <c:if test="${not empty sessionScope.loginSuccess}">
            <div class="success">
                ✅ ${sessionScope.loginSuccess}
            </div>
        </c:if>
        
        <c:if test="${not empty error}">
            <div class="error">
                ❌ ${error}
            </div>
        </c:if>
        
        <h2>🎯 Test Cases:</h2>
        
        <table>
            <thead>
                <tr>
                    <th>Loại tài khoản</th>
                    <th>Email</th>
                    <th>Password</th>
                    <th>Bảng Database</th>
                    <th>Expected Role</th>
                    <th>Expected Redirect</th>
                </tr>
            </thead>
            <tbody>
                <tr>
                    <td><strong>Customer</strong></td>
                    <td>customer@example.com</td>
                    <td>password123</td>
                    <td>Customer</td>
                    <td>customer</td>
                    <td>/home</td>
                </tr>
                <tr>
                    <td><strong>Staff (Admin)</strong></td>
                    <td>admin@pets4care.com</td>
                    <td>admin123</td>
                    <td>Staff</td>
                    <td>admin</td>
                    <td>/staff/viewOrder</td>
                </tr>
                <tr>
                    <td><strong>Staff (Manager)</strong></td>
                    <td>manager@example.com</td>
                    <td>manager123</td>
                    <td>Staff</td>
                    <td>admin</td>
                    <td>/staff/viewOrder</td>
                </tr>
                <tr>
                    <td><strong>Staff (Employee)</strong></td>
                    <td>staff@pets4care.com</td>
                    <td>staff123</td>
                    <td>Staff</td>
                    <td>staff</td>
                    <td>/staff/viewOrder</td>
                </tr>
                <tr>
                    <td><strong>Admin</strong></td>
                    <td>admin@admin.com</td>
                    <td>adminpass</td>
                    <td>Admin</td>
                    <td>admin</td>
                    <td>/admin/dashboard.jsp</td>
                </tr>
                <tr>
                    <td><strong>Doctor</strong></td>
                    <td>doctorb@example.com</td>
                    <td>pass123</td>
                    <td>Doctor</td>
                    <td>doctor</td>
                    <td>/doctor/doctor-dashboard.jsp</td>
                </tr>
            </tbody>
        </table>
        
        <h2>🔐 Form đăng nhập (Auto Detection):</h2>
        
        <form action="login" method="post">
            <div class="form-group">
                <label for="email">Email:</label>
                <input type="email" name="email" id="email" required placeholder="Nhập email để test">
            </div>
            
            <div class="form-group">
                <label for="password">Password:</label>
                <input type="password" name="password" id="password" required placeholder="Nhập password">
            </div>
            
            <button type="submit">🔍 Test Auto Detection</button>
        </form>
        
        <h2>📊 Kết quả Session hiện tại:</h2>
        
        <c:choose>
            <c:when test="${not empty sessionScope.role}">
                <div class="role-info">
                    <h3>✅ Đã đăng nhập với role: <strong>${sessionScope.role}</strong></h3>
                    
                    <c:choose>
                        <c:when test="${sessionScope.role == 'customer'}">
                            <p><strong>Customer Info:</strong></p>
                            <ul>
                                <li>ID: ${sessionScope.userId}</li>
                                <li>Tên: ${sessionScope.userName}</li>
                                <li>Object: ${sessionScope.currentUser}</li>
                            </ul>
                        </c:when>
                        
                        <c:when test="${sessionScope.role == 'admin'}">
                            <c:choose>
                                <c:when test="${not empty sessionScope.admin}">
                                    <p><strong>Admin Info (từ bảng Admin):</strong></p>
                                    <ul>
                                        <li>ID: ${sessionScope.adminId}</li>
                                        <li>Tên: ${sessionScope.adminName}</li>
                                        <li>Username: ${sessionScope.adminUsername}</li>
                                        <li>Object: ${sessionScope.admin}</li>
                                    </ul>
                                </c:when>
                                <c:otherwise>
                                    <p><strong>Admin Info (từ bảng Staff):</strong></p>
                                    <ul>
                                        <li>ID: ${sessionScope.staffId}</li>
                                        <li>Tên: ${sessionScope.staffName}</li>
                                        <li>Position: ${sessionScope.staffPosition}</li>
                                        <li>Object: ${sessionScope.staff}</li>
                                    </ul>
                                </c:otherwise>
                            </c:choose>
                        </c:when>
                        
                        <c:when test="${sessionScope.role == 'staff'}">
                            <p><strong>Staff Info:</strong></p>
                            <ul>
                                <li>ID: ${sessionScope.staffId}</li>
                                <li>Tên: ${sessionScope.staffName}</li>
                                <li>Position: ${sessionScope.staffPosition}</li>
                                <li>Object: ${sessionScope.staff}</li>
                            </ul>
                        </c:when>
                        
                        <c:when test="${sessionScope.role == 'doctor'}">
                            <p><strong>Doctor Info:</strong></p>
                            <ul>
                                <li>ID: ${sessionScope.doctorId}</li>
                                <li>Tên: ${sessionScope.doctorName}</li>
                                <li>Email: ${sessionScope.doctorEmail}</li>
                                <li>Specialization: ${sessionScope.doctorSpecialization}</li>
                                <li>Object: ${sessionScope.doctor}</li>
                            </ul>
                        </c:when>
                    </c:choose>
                </div>
            </c:when>
            
            <c:otherwise>
                <p>❌ Chưa đăng nhập</p>
            </c:otherwise>
        </c:choose>
        
        <h2>🔍 Phân tích Logic hiện tại:</h2>
        
        <div class="info">
            <h3>Luồng đăng nhập trong LoginServlet:</h3>
            <ol>
                <li><strong>Bước 1:</strong> Kiểm tra bảng <code>Staff</code> trước</li>
                <li><strong>Bước 2:</strong> Nếu không phải Staff → kiểm tra bảng <code>Admin</code></li>
                <li><strong>Bước 3:</strong> Nếu không phải Admin → kiểm tra bảng <code>Customer</code></li>
                <li><strong>Bước 4:</strong> ❌ <strong>KHÔNG kiểm tra bảng Doctor</strong></li>
            </ol>
            
            <h3>Vấn đề phát hiện:</h3>
            <ul>
                <li>❌ <strong>Doctor không được hỗ trợ</strong> trong LoginServlet</li>
                <li>❌ Chỉ có AdminLoginServlet hỗ trợ Doctor nhưng cần chọn accountType</li>
                <li>✅ Customer, Staff, Admin được hỗ trợ tự động</li>
            </ul>
        </div>
        
        <div style="text-align: center; margin-top: 30px;">
            <a href="login.jsp" style="color: #2196F3; text-decoration: none;">← Quay lại trang đăng nhập chính</a>
        </div>
    </div>
</body>
</html>
