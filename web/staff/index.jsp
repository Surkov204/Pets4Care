<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Staff Portal - Pets4Care</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <style>
        body {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
        }
        
        .portal-card {
            background: white;
            border-radius: 20px;
            box-shadow: 0 15px 35px rgba(0,0,0,0.1);
            overflow: hidden;
        }
        
        .portal-header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 3rem 2rem;
            text-align: center;
        }
        
        .portal-body {
            padding: 3rem 2rem;
        }
        
        .feature-card {
            border: none;
            border-radius: 15px;
            transition: all 0.3s ease;
            height: 100%;
        }
        
        .feature-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 10px 25px rgba(0,0,0,0.1);
        }
        
        .feature-icon {
            width: 80px;
            height: 80px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 1rem;
            font-size: 2rem;
        }
        
        .feature-1 { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; }
        .feature-2 { background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%); color: white; }
        .feature-3 { background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%); color: white; }
        .feature-4 { background: linear-gradient(135deg, #43e97b 0%, #38f9d7 100%); color: white; }
        
        .btn-portal {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            border: none;
            border-radius: 10px;
            padding: 0.75rem 2rem;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 1px;
            color: white;
            text-decoration: none;
            display: inline-block;
            transition: all 0.3s ease;
        }
        
        .btn-portal:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(102, 126, 234, 0.4);
            color: white;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="row justify-content-center">
            <div class="col-lg-10">
                <div class="portal-card">
                    <div class="portal-header">
                        <i class="fas fa-user-tie fa-4x mb-3"></i>
                        <h1 class="display-4 mb-3">Staff Portal</h1>
                        <p class="lead mb-0">Hệ thống quản lý đặt lịch dịch vụ thú cưng</p>
                    </div>
                    
                    <div class="portal-body">
                        <div class="row mb-5">
                            <div class="col-12 text-center">
                                <h2 class="mb-4">Chào mừng đến với hệ thống quản lý</h2>
                                <p class="text-muted mb-4">Đăng nhập để truy cập các chức năng quản lý đặt lịch dịch vụ</p>
                                <a href="${pageContext.request.contextPath}/staff/login" class="btn-portal">
                                    <i class="fas fa-sign-in-alt"></i> Đăng nhập Staff
                                </a>
                            </div>
                        </div>
                        
                        <div class="row">
                            <div class="col-md-6 col-lg-3 mb-4">
                                <div class="card feature-card text-center">
                                    <div class="card-body">
                                        <div class="feature-icon feature-1">
                                            <i class="fas fa-calendar-check"></i>
                                        </div>
                                        <h5 class="card-title">Quản lý đặt lịch</h5>
                                        <p class="card-text">Xem, cập nhật và quản lý tất cả các đặt lịch dịch vụ</p>
                                    </div>
                                </div>
                            </div>
                            
                            <div class="col-md-6 col-lg-3 mb-4">
                                <div class="card feature-card text-center">
                                    <div class="card-body">
                                        <div class="feature-icon feature-2">
                                            <i class="fas fa-chart-bar"></i>
                                        </div>
                                        <h5 class="card-title">Thống kê</h5>
                                        <p class="card-text">Xem báo cáo và thống kê về hoạt động dịch vụ</p>
                                    </div>
                                </div>
                            </div>
                            
                            <div class="col-md-6 col-lg-3 mb-4">
                                <div class="card feature-card text-center">
                                    <div class="card-body">
                                        <div class="feature-icon feature-3">
                                            <i class="fas fa-users"></i>
                                        </div>
                                        <h5 class="card-title">Quản lý khách hàng</h5>
                                        <p class="card-text">Xem thông tin và lịch sử dịch vụ của khách hàng</p>
                                    </div>
                                </div>
                            </div>
                            
                            <div class="col-md-6 col-lg-3 mb-4">
                                <div class="card feature-card text-center">
                                    <div class="card-body">
                                        <div class="feature-icon feature-4">
                                            <i class="fas fa-cog"></i>
                                        </div>
                                        <h5 class="card-title">Cài đặt</h5>
                                        <p class="card-text">Cấu hình hệ thống và quản lý tài khoản</p>
                                    </div>
                                </div>
                            </div>
                        </div>
                        
                        <hr class="my-5">
                        
                        <div class="row">
                            <div class="col-md-6">
                                <h5><i class="fas fa-info-circle"></i> Thông tin hệ thống</h5>
                                <ul class="list-unstyled">
                                    <li><i class="fas fa-check text-success"></i> Quản lý đặt lịch dịch vụ</li>
                                    <li><i class="fas fa-check text-success"></i> Theo dõi trạng thái đặt lịch</li>
                                    <li><i class="fas fa-check text-success"></i> Thống kê và báo cáo</li>
                                    <li><i class="fas fa-check text-success"></i> Phân công nhân viên</li>
                                </ul>
                            </div>
                            <div class="col-md-6">
                                <h5><i class="fas fa-shield-alt"></i> Bảo mật</h5>
                                <ul class="list-unstyled">
                                    <li><i class="fas fa-lock text-primary"></i> Xác thực tài khoản Staff</li>
                                    <li><i class="fas fa-user-shield text-primary"></i> Phân quyền theo vai trò</li>
                                    <li><i class="fas fa-history text-primary"></i> Theo dõi hoạt động</li>
                                    <li><i class="fas fa-key text-primary"></i> Mã hóa dữ liệu</li>
                                </ul>
                            </div>
                        </div>
                        
                        <div class="text-center mt-4">
                            <a href="${pageContext.request.contextPath}/" class="text-decoration-none">
                                <i class="fas fa-arrow-left"></i> Quay lại trang chủ
                            </a>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
