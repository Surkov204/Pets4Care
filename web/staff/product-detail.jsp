<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Chi tiết sản phẩm - Staff</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <style>
        .product-detail-card {
            border-left: 4px solid #007bff;
        }
        
        .product-image-large {
            width: 100%;
            height: 400px;
            object-fit: cover;
            border-radius: 8px;
        }
        
        .stock-badge {
            font-size: 0.8em;
            padding: 0.4em 0.8em;
        }
        
        .stock-high { background-color: #28a745; color: #fff; }
        .stock-medium { background-color: #ffc107; color: #000; }
        .stock-low { background-color: #dc3545; color: #fff; }
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
                            <a class="nav-link" href="${pageContext.request.contextPath}/staff/customers">
                                <i class="fas fa-users"></i> Xem thông tin khách hàng
                            </a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link active" href="${pageContext.request.contextPath}/staff/products">
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
                        <i class="fas fa-box"></i> Chi tiết sản phẩm
                    </h1>
                    <div class="btn-toolbar mb-2 mb-md-0">
                        <a href="${pageContext.request.contextPath}/staff/products" class="btn btn-outline-secondary">
                            <i class="fas fa-arrow-left"></i> Quay lại
                        </a>
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

                <!-- Product Information -->
                <div class="row mb-4">
                    <div class="col-md-6">
                        <div class="card">
                            <div class="card-body">
                                <c:choose>
                                    <c:when test="${not empty product.imageUrl}">
                                        <img src="${pageContext.request.contextPath}/images/${product.imageUrl}" 
                                             class="product-image-large" alt="${product.name}">
                                    </c:when>
                                    <c:otherwise>
                                        <img src="${pageContext.request.contextPath}/images/toy_1.jpg" 
                                             class="product-image-large" alt="${product.name}">
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-6">
                        <div class="card product-detail-card">
                            <div class="card-header">
                                <h5 class="mb-0">
                                    <i class="fas fa-box"></i> Thông tin sản phẩm
                                </h5>
                            </div>
                            <div class="card-body">
                                <h4 class="card-title">${product.name}</h4>
                                <p class="card-text">
                                    <strong><i class="fas fa-id-card"></i> ID:</strong> ${product.productId}<br>
                                    <strong><i class="fas fa-box-open"></i> Loại sản phẩm:</strong> ${product.productType}<br>
                                    <strong><i class="fas fa-dollar-sign"></i> Giá:</strong> 
                                    <span class="text-primary fs-5">
                                        <fmt:formatNumber value="${product.price}" type="currency" currencyCode="VND"/>
                                    </span><br>
                                    <strong><i class="fas fa-cubes"></i> Số lượng tồn kho:</strong> 
                                    <span class="badge stock-badge ${product.stockQuantity > 50 ? 'stock-high' : product.stockQuantity > 10 ? 'stock-medium' : 'stock-low'}">
                                        ${product.stockQuantity} sản phẩm
                                    </span><br>
                                    <c:if test="${not empty product.expiryDate}">
                                        <strong><i class="fas fa-calendar-alt"></i> Ngày hết hạn:</strong> 
                                        <fmt:formatDate value="${product.expiryDate}" pattern="dd/MM/yyyy"/><br>
                                    </c:if>
                                    <strong><i class="fas fa-tags"></i> Danh mục:</strong> 
                                    ${product.categoryName != null ? product.categoryName : 'Chưa phân loại'}<br>
                                    <strong><i class="fas fa-building"></i> Nhà cung cấp:</strong> 
                                    ${product.supplierName != null ? product.supplierName : 'Chưa xác định'}<br>
                                    <c:if test="${not empty product.material}">
                                        <strong><i class="fas fa-cube"></i> Chất liệu:</strong> ${product.material}<br>
                                    </c:if>
                                    <c:if test="${not empty product.usage}">
                                        <strong><i class="fas fa-hand-holding"></i> Cách sử dụng:</strong> ${product.usage}<br>
                                    </c:if>
                                    <c:if test="${not empty product.size}">
                                        <strong><i class="fas fa-ruler"></i> Kích thước:</strong> ${product.size}<br>
                                    </c:if>
                                </p>
                                <c:if test="${not empty product.description}">
                                    <div class="mt-3">
                                        <h6><i class="fas fa-info-circle"></i> Mô tả:</h6>
                                        <p class="text-muted">${product.description}</p>
                                    </div>
                                </c:if>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Product Reviews -->
                <div class="row">
                    <div class="col-12">
                        <div class="card">
                            <div class="card-header">
                                <h5 class="mb-0">
                                    <i class="fas fa-star"></i> Đánh giá sản phẩm
                                </h5>
                            </div>
                            <div class="card-body">
                                <c:choose>
                                    <c:when test="${not empty productReviews}">
                                        <div class="row">
                                            <c:forEach var="review" items="${productReviews}">
                                                <div class="col-md-6 mb-3">
                                                    <div class="card">
                                                        <div class="card-body">
                                                            <div class="d-flex justify-content-between align-items-start mb-2">
                                                                <h6 class="card-title mb-0">${review.customerName}</h6>
                                                                <div class="text-warning">
                                                                    <c:forEach begin="1" end="5" var="i">
                                                                        <i class="fas fa-star ${i <= review.rating ? '' : 'text-muted'}"></i>
                                                                    </c:forEach>
                                                                </div>
                                                            </div>
                                                            <p class="card-text">${review.comment}</p>
                                                            <small class="text-muted">
                                                                <i class="fas fa-clock"></i> 
                                                                <fmt:formatDate value="${review.createdAt}" pattern="dd/MM/yyyy HH:mm"/>
                                                            </small>
                                                        </div>
                                                    </div>
                                                </div>
                                            </c:forEach>
                                        </div>
                                    </c:when>
                                    <c:otherwise>
                                        <div class="text-center py-4">
                                            <i class="fas fa-star fa-3x text-muted mb-3"></i>
                                            <h5 class="text-muted">Sản phẩm chưa có đánh giá nào</h5>
                                            <p class="text-muted">Khách hàng chưa đánh giá sản phẩm này.</p>
                                        </div>
                                    </c:otherwise>
                                </c:choose>
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

