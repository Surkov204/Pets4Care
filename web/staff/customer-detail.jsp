<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Chi tiết khách hàng - Staff</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <style>
        .customer-detail-card { border-left: 4px solid #28a745; }
        .order-card { border-left: 4px solid #007bff; transition: all 0.3s ease; }
        .order-card:hover { transform: translateY(-2px); box-shadow: 0 4px 15px rgba(0,0,0,0.1); }
        .status-badge { font-size: 0.8em; padding: 0.4em 0.8em; }
        .status-active { background-color: #28a745; color: #fff; }
        .status-inactive { background-color: #dc3545; color: #fff; }
        .status-pending { background-color: #ffc107; color: #000; }
        .status-completed { background-color: #28a745; color: #fff; }
        .status-cancelled { background-color: #dc3545; color: #fff; }
    </style>
</head>
<body>
    <div class="container-fluid">
        <div class="row">
            <!-- Sidebar -->
            <nav class="col-md-3 col-lg-2 d-md-block bg-light sidebar collapse">
                <div class="position-sticky pt-3">
                    <ul class="nav flex-column">
                        <li class="nav-item">
                            <a class="nav-link" href="${pageContext.request.contextPath}/staff/bookings">
                                <i class="fas fa-calendar-check"></i> Xem đặt lịch dịch vụ
                            </a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link active" href="${pageContext.request.contextPath}/staff/customers">
                                <i class="fas fa-users"></i> Xem thông tin khách hàng
                            </a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link" href="${pageContext.request.contextPath}/staff/products">
                                <i class="fas fa-box"></i> Xem tất cả sản phẩm
                            </a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link" href="${pageContext.request.contextPath}/staff-home">
                                <i class="fas fa-home"></i> Quay lại trang home
                            </a>
                        </li>
                    </ul>
                </div>
            </nav>

            <!-- Main content -->
            <main class="col-md-9 ms-sm-auto col-lg-10 px-md-4">
                <div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pt-3 pb-2 mb-3 border-bottom">
                    <h1 class="h2"><i class="fas fa-user"></i> Chi tiết khách hàng</h1>
                    <div class="btn-toolbar mb-2 mb-md-0">
                        <a href="${pageContext.request.contextPath}/staff/customers" class="btn btn-outline-secondary">
                            <i class="fas fa-arrow-left"></i> Quay lại
                        </a>
                    </div>
                </div>

                <c:if test="${not empty error}">
                    <div class="alert alert-danger alert-dismissible fade show" role="alert">
                        <i class="fas fa-exclamation-circle"></i> ${error}
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                </c:if>

                <div class="row mb-4">
                    <div class="col-12">
                        <div class="card customer-detail-card">
                            <div class="card-header"><h5 class="mb-0"><i class="fas fa-user-circle"></i> Thông tin khách hàng</h5></div>
                            <div class="card-body">
                                <div class="row">
                                    <div class="col-md-6">
                                        <p><strong><i class="fas fa-id-card"></i> ID:</strong> ${customer.customerId}</p>
                                        <p><strong><i class="fas fa-user"></i> Tên:</strong> ${customer.name}</p>
                                        <p><strong><i class="fas fa-envelope"></i> Email:</strong> ${customer.email}</p>
                                        <p><strong><i class="fas fa-phone"></i> SĐT:</strong> ${customer.phone}</p>
                                    </div>
                                    <div class="col-md-6">
                                        <p><strong><i class="fas fa-map-marker-alt"></i> Địa chỉ:</strong> 
                                            <c:choose>
                                                <c:when test="${not empty customer.addressCustomer}">${customer.addressCustomer}</c:when>
                                                <c:otherwise><span class="text-muted">Chưa cập nhật</span></c:otherwise>
                                            </c:choose>
                                        </p>
                                        <p><strong><i class="fas fa-info-circle"></i> Trạng thái:</strong> 
                                            <span class="badge status-badge status-${customer.status != null ? customer.status : 'active'}">
                                                ${customer.status != null ? customer.status : 'active'}
                                            </span>
                                        </p>
                                        <c:if test="${not empty customer.googleId}">
                                            <p><strong><i class="fab fa-google"></i> Google ID:</strong> ${customer.googleId}</p>
                                        </c:if>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </main>
        </div>
    </div>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>

