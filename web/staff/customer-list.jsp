<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản lý khách hàng - Staff</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <style>
        .customer-card {
            border-left: 4px solid #28a745;
            transition: all 0.3s ease;
        }
        
        .customer-card:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 15px rgba(0,0,0,0.1);
        }
        
        .filter-section {
            background-color: #f8f9fa;
            border-radius: 10px;
            padding: 1.5rem;
            margin-bottom: 2rem;
        }
        
        .status-badge {
            font-size: 0.8em;
            padding: 0.4em 0.8em;
        }
        
        .status-active { background-color: #28a745; color: #fff; }
        .status-inactive { background-color: #dc3545; color: #fff; }
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
                            <a class="nav-link" href="${pageContext.request.contextPath}/home">
                                <i class="fas fa-home"></i> Quay lại trang home
                            </a>
                        </li>
                    </ul>
                </div>
            </nav>

            <!-- Main content -->
            <main class="col-md-9 ms-sm-auto col-lg-10 px-md-4">
                <div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pt-3 pb-2 mb-3 border-bottom">
                    <h1 class="h2">
                        <i class="fas fa-users"></i> Quản lý khách hàng
                    </h1>
                    <div class="btn-toolbar mb-2 mb-md-0">
                        <span class="badge bg-primary fs-6">
                            Tổng: ${totalCustomers} khách hàng
                        </span>
                    </div>
                </div>

                <!-- Alerts -->
                <c:if test="${not empty success}">
                    <div class="alert alert-success alert-dismissible fade show" role="alert">
                        <i class="fas fa-check-circle"></i> ${success}
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                </c:if>
                
                <c:if test="${not empty error}">
                    <div class="alert alert-danger alert-dismissible fade show" role="alert">
                        <i class="fas fa-exclamation-circle"></i> ${error}
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                </c:if>

                <!-- Search -->
                <div class="filter-section">
                    <form method="GET" action="${pageContext.request.contextPath}/staff/customers">
                        <input type="hidden" name="action" value="search">
                        <div class="row">
                            <div class="col-md-8">
                                <div class="input-group">
                                    <input type="text" class="form-control" name="keyword" 
                                           placeholder="Tìm kiếm theo tên, email, số điện thoại..." 
                                           value="${keyword}">
                                    <button class="btn btn-outline-primary" type="submit">
                                        <i class="fas fa-search"></i> Tìm kiếm
                                    </button>
                                </div>
                            </div>
                            <div class="col-md-4">
                                <a href="${pageContext.request.contextPath}/staff/customers" class="btn btn-outline-secondary">
                                    <i class="fas fa-list"></i> Xem tất cả
                                </a>
                            </div>
                        </div>
                    </form>
                </div>

                <!-- Customers List -->
                <div class="row">
                    <c:choose>
                        <c:when test="${not empty customers}">
                            <c:forEach var="customer" items="${customers}">
                                <div class="col-md-6 col-lg-4 mb-4">
                                    <div class="card customer-card h-100">
                                        <div class="card-header d-flex justify-content-between align-items-center">
                                            <h6 class="mb-0">
                                                <i class="fas fa-user"></i> #${customer.customerId}
                                            </h6>
                                            <span class="badge status-badge status-${customer.status != null ? customer.status : 'active'}">
                                                ${customer.status != null ? customer.status : 'active'}
                                            </span>
                                        </div>
                                        <div class="card-body">
                                            <h6 class="card-title">
                                                <i class="fas fa-user-circle"></i> ${customer.name}
                                            </h6>
                                            <p class="card-text">
                                                <strong><i class="fas fa-envelope"></i> Email:</strong> ${customer.email}<br>
                                                <strong><i class="fas fa-phone"></i> SĐT:</strong> ${customer.phone}<br>
                                                <c:if test="${not empty customer.addressCustomer}">
                                                    <strong><i class="fas fa-map-marker-alt"></i> Địa chỉ:</strong> ${customer.addressCustomer}<br>
                                                </c:if>
                                                <c:if test="${not empty customer.googleId}">
                                                    <strong><i class="fab fa-google"></i> Google ID:</strong> ${customer.googleId}<br>
                                                </c:if>
                                            </p>
                                        </div>
                                        <div class="card-footer">
                                            <div class="btn-group w-100" role="group">
                                                <a href="${pageContext.request.contextPath}/staff/customers?action=view&id=${customer.customerId}" 
                                                   class="btn btn-outline-primary btn-sm">
                                                    <i class="fas fa-eye"></i> Xem chi tiết
                                                </a>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </c:forEach>
                        </c:when>
                        <c:otherwise>
                            <div class="col-12">
                                <div class="text-center py-5">
                                    <i class="fas fa-users fa-3x text-muted mb-3"></i>
                                    <h4 class="text-muted">Không có khách hàng nào</h4>
                                    <p class="text-muted">Chưa có khách hàng nào được tìm thấy.</p>
                                </div>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>

                <!-- Pagination -->
                <c:if test="${totalPages > 1}">
                    <nav aria-label="Page navigation">
                        <ul class="pagination justify-content-center">
                            <c:if test="${currentPage > 1}">
                                <li class="page-item">
                                    <a class="page-link" href="?page=${currentPage - 1}<c:if test='${not empty keyword}'>&action=search&keyword=${keyword}</c:if>">Trước</a>
                                </li>
                            </c:if>
                            
                            <c:forEach begin="1" end="${totalPages}" var="i">
                                <li class="page-item ${i == currentPage ? 'active' : ''}">
                                    <a class="page-link" href="?page=${i}<c:if test='${not empty keyword}'>&action=search&keyword=${keyword}</c:if>">${i}</a>
                                </li>
                            </c:forEach>
                            
                            <c:if test="${currentPage < totalPages}">
                                <li class="page-item">
                                    <a class="page-link" href="?page=${currentPage + 1}<c:if test='${not empty keyword}'>&action=search&keyword=${keyword}</c:if>">Sau</a>
                                </li>
                            </c:if>
                        </ul>
                    </nav>
                </c:if>
            </main>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
