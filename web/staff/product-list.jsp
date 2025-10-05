<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản lý sản phẩm - Staff</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <style>
        .product-card {
            border-left: 4px solid #007bff;
            transition: all 0.3s ease;
        }
        
        .product-card:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 15px rgba(0,0,0,0.1);
        }
        
        .filter-section {
            background-color: #f8f9fa;
            border-radius: 10px;
            padding: 1.5rem;
            margin-bottom: 2rem;
        }
        
        .product-image {
            width: 100%;
            height: 200px;
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
                        <i class="fas fa-box"></i> Quản lý sản phẩm
                    </h1>
                    <div class="btn-toolbar mb-2 mb-md-0">
                        <span class="badge bg-primary fs-6">
                            Tổng: ${totalProducts} sản phẩm
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

                <!-- Search and Filter -->
                <div class="filter-section">
                    <form method="GET" action="${pageContext.request.contextPath}/staff/products">
                        <input type="hidden" name="action" value="search">
                        <div class="row">
                            <div class="col-md-6">
                                <div class="input-group">
                                    <input type="text" class="form-control" name="keyword" 
                                           placeholder="Tìm kiếm theo tên sản phẩm, mô tả..." 
                                           value="${keyword}">
                                    <button class="btn btn-outline-primary" type="submit">
                                        <i class="fas fa-search"></i> Tìm kiếm
                                    </button>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="btn-group" role="group">
                                    <a href="${pageContext.request.contextPath}/staff/products" class="btn btn-outline-secondary">
                                        <i class="fas fa-list"></i> Xem tất cả
                                    </a>
                                    <button type="button" class="btn btn-outline-info" data-bs-toggle="modal" data-bs-target="#filterModal">
                                        <i class="fas fa-filter"></i> Lọc
                                    </button>
                                </div>
                            </div>
                        </div>
                    </form>
                </div>

                <!-- Products List -->
                <div class="row">
                    <c:choose>
                        <c:when test="${not empty products}">
                            <c:forEach var="product" items="${products}">
                                <div class="col-md-6 col-lg-4 mb-4">
                                    <div class="card product-card h-100">
                                        <div class="card-img-top">
                                            <c:choose>
                                                <c:when test="${not empty product.imageUrl}">
                                                    <img src="${pageContext.request.contextPath}/images/${product.imageUrl}" 
                                                         class="product-image" alt="${product.name}">
                                                </c:when>
                                                <c:otherwise>
                                                    <img src="${pageContext.request.contextPath}/images/toy_1.jpg" 
                                                         class="product-image" alt="${product.name}">
                                                </c:otherwise>
                                            </c:choose>
                                        </div>
                                        <div class="card-header d-flex justify-content-between align-items-center">
                                            <h6 class="mb-0">
                                                <i class="fas fa-box"></i> #${product.productId}
                                            </h6>
                                            <span class="badge stock-badge ${product.stockQuantity > 50 ? 'stock-high' : product.stockQuantity > 10 ? 'stock-medium' : 'stock-low'}">
                                                ${product.stockQuantity} sản phẩm
                                            </span>
                                        </div>
                                        <div class="card-body">
                                            <h6 class="card-title">${product.name}</h6>
                                            <p class="card-text">
                                                <strong><i class="fas fa-box-open"></i> Loại:</strong> ${product.productType}<br>
                                                <strong><i class="fas fa-dollar-sign"></i> Giá:</strong> 
                                                <fmt:formatNumber value="${product.price}" type="currency" currencyCode="VND"/><br>
                                                <strong><i class="fas fa-tags"></i> Danh mục:</strong> 
                                                ${product.categoryName != null ? product.categoryName : 'Chưa phân loại'}<br>
                                                <strong><i class="fas fa-building"></i> Nhà cung cấp:</strong> 
                                                ${product.supplierName != null ? product.supplierName : 'Chưa xác định'}<br>
                                                <c:if test="${not empty product.material}">
                                                    <strong><i class="fas fa-cube"></i> Chất liệu:</strong> ${product.material}<br>
                                                </c:if>
                                                <c:if test="${not empty product.size}">
                                                    <strong><i class="fas fa-ruler"></i> Kích thước:</strong> ${product.size}<br>
                                                </c:if>
                                                <c:if test="${not empty product.description}">
                                                    <strong><i class="fas fa-info-circle"></i> Mô tả:</strong> 
                                                    <c:choose>
                                                        <c:when test="${fn:length(product.description) > 60}">
                                                            ${fn:substring(product.description, 0, 60)}...
                                                        </c:when>
                                                        <c:otherwise>
                                                            ${product.description}
                                                        </c:otherwise>
                                                    </c:choose>
                                                </c:if>
                                            </p>
                                        </div>
                                        <div class="card-footer">
                                            <div class="btn-group w-100" role="group">
                                                <a href="${pageContext.request.contextPath}/staff/products?action=view&id=${product.productId}" 
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
                                    <i class="fas fa-box fa-3x text-muted mb-3"></i>
                                    <h4 class="text-muted">Không có sản phẩm nào</h4>
                                    <p class="text-muted">Chưa có sản phẩm nào được tìm thấy.</p>
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

    <!-- Filter Modal -->
    <div class="modal fade" id="filterModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">Lọc sản phẩm</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <form method="GET" action="${pageContext.request.contextPath}/staff/products">
                    <input type="hidden" name="action" value="filter">
                    <div class="modal-body">
                        <div class="mb-3">
                            <label class="form-label">Danh mục</label>
                            <select class="form-select" name="categoryId">
                                <option value="">Tất cả danh mục</option>
                                <option value="1" ${selectedCategoryId == '1' ? 'selected' : ''}>Đồ chơi cho chó</option>
                                <option value="2" ${selectedCategoryId == '2' ? 'selected' : ''}>Đồ chơi cho mèo</option>
                                <option value="3" ${selectedCategoryId == '3' ? 'selected' : ''}>Thức ăn</option>
                                <option value="4" ${selectedCategoryId == '4' ? 'selected' : ''}>Phụ kiện</option>
                            </select>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Giá từ</label>
                            <input type="number" class="form-control" name="minPrice" value="${selectedMinPrice}" placeholder="0">
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Giá đến</label>
                            <input type="number" class="form-control" name="maxPrice" value="${selectedMaxPrice}" placeholder="1000000">
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Hủy</button>
                        <button type="submit" class="btn btn-primary">Lọc</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
