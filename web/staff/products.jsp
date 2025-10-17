<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>🐾 View Product | Pet4Care</title>
    <link rel="stylesheet" href="/Pets4Care/css/staff.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <style>
        .filter-section {
            background-color: #f8f9fa;
            border-radius: 10px;
            padding: 1.5rem;
            margin-bottom: 2rem;
            border: 1px solid #e9ecef;
        }

        .search-form {
            display: flex;
            gap: 1rem;
            margin-bottom: 1.5rem;
            align-items: center;
        }

        .search-input {
            flex: 1;
            padding: 0.75rem;
            border: 1px solid #ddd;
            border-radius: 8px;
            font-size: 0.9rem;
            transition: border-color 0.3s ease;
        }

        .search-input:focus {
            outline: none;
            border-color: #007bff;
            box-shadow: 0 0 0 2px rgba(0, 123, 255, 0.25);
        }

        .search-btn {
            padding: 0.75rem 1.5rem;
            background-color: #007bff;
            color: white;
            border: none;
            border-radius: 8px;
            cursor: pointer;
            font-size: 0.9rem;
            transition: background-color 0.3s ease;
        }

        .search-btn:hover {
            background-color: #0056b3;
        }

        .filter-buttons {
            display: flex;
            gap: 0.5rem;
            flex-wrap: wrap;
        }

        .filter-btn {
            padding: 0.5rem 1rem;
            border: 1px solid #ddd;
            background: white;
            border-radius: 6px;
            text-decoration: none;
            color: #666;
            font-size: 0.85rem;
            transition: all 0.3s ease;
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
        }

        .filter-btn:hover {
            background-color: #f8f9fa;
            color: #333;
            border-color: #007bff;
        }

        .filter-btn.active {
            background-color: #007bff;
            color: white;
            border-color: #007bff;
        }

        .filter-btn i {
            font-size: 0.8rem;
        }

        .pagination {
            display: flex;
            justify-content: center;
            gap: 0.5rem;
            margin-top: 2rem;
            margin-bottom: 1rem;
            flex-wrap: wrap;
        }

        .pagination a {
            padding: 0.5rem 0.75rem;
            border: 1px solid #ddd;
            text-decoration: none;
            color: #666;
            border-radius: 4px;
            transition: all 0.3s ease;
            display: inline-flex;
            align-items: center;
            gap: 0.25rem;
        }

        .pagination a:hover {
            background-color: #f8f9fa;
            color: #333;
        }

        .pagination .active a {
            background-color: #007bff;
            color: white;
            border-color: #007bff;
        }

        .pagination .active a:hover {
            background-color: #0056b3;
        }
        
        .status {
            padding: 0.25rem 0.5rem;
            border-radius: 4px;
            font-size: 0.8rem;
            font-weight: 500;
        }
        
        .status.active {
            background-color: #d4edda;
            color: #155724;
        }
        
        .status.warning {
            background-color: #fff3cd;
            color: #856404;
        }
        
        .status.danger {
            background-color: #f8d7da;
            color: #721c24;
        }

        .btn-action {
            padding: 0.25rem 0.5rem;
            margin: 0.1rem;
            border-radius: 4px;
            text-decoration: none;
            font-size: 0.875rem;
            display: inline-block;
            transition: opacity 0.3s ease;
        }

        .btn-action.view {
            background-color: #17a2b8;
            color: white;
        }

        .btn-action.edit {
            background-color: #28a745;
            color: white;
        }

        .btn-action:hover {
            opacity: 0.8;
        }

        .pagination-info {
            text-align: center;
            margin-top: 1rem;
            color: #666;
            font-size: 0.9rem;
        }

        /* Responsive */
        @media (max-width: 768px) {
            .search-form {
                flex-direction: column;
                gap: 0.5rem;
            }
            
            .filter-buttons {
                justify-content: center;
            }
            
            .pagination {
                gap: 0.25rem;
            }
            
            .pagination a {
                padding: 0.4rem 0.6rem;
                font-size: 0.8rem;
            }
        }
    </style>
</head>
<body>

<header class="staff-header">
    <div class="logo-section">
        <img src="/Pets4Care/images/logo.png" alt="Pet4Care">
        <div>
            <h1>Pet4Care</h1>
            <p>Staff Dashboard</p>
        </div>
    </div>
    <div class="user-section">
        <div class="notif"><i class="fas fa-bell"></i></div>
        <div class="chat"><i class="fas fa-comments"></i></div>
        <div class="avatar">
            <img src="/Pets4Care/images/staff-avatar.png" alt="Staff">
            <span>Staff</span>
        </div>
        <form action="logout" method="post">
            <button class="logout-btn"><i class="fas fa-sign-out-alt"></i></button>
        </form>
    </div>
</header>

<div class="staff-wrapper">
    <!-- Sidebar -->
    <aside class="staff-sidebar">
        <ul>
            <li><a href="${pageContext.request.contextPath}/staff/viewOrder"><i class="fas fa-receipt"></i> View Orders</a></li>
            <li><a href="${pageContext.request.contextPath}/staff/work-schedule"><i class="fas fa-calendar-alt"></i> Work Schedule</a></li>
            <li><a href="${pageContext.request.contextPath}/staff/staff-profile"><i class="fas fa-user-circle"></i> Staff Profile</a></li>
            <li><a href="${pageContext.request.contextPath}/staff/customer-list"><i class="fas fa-user"></i> Customer Profile</a></li>
            <li><a href="${pageContext.request.contextPath}/staff/services-booking"><i class="fas fa-list"></i> Services Booking</a></li>
            <li><a href="${pageContext.request.contextPath}/staff/chatCustomer"><i class="fas fa-comments"></i> Chat with Customer</a></li>
            <li><a href="${pageContext.request.contextPath}/staff/products" class="active"><i class="fas fa-box"></i> View Product</a></li>
        </ul>
    </aside>

    <!-- Main Content -->
    <main class="staff-content">
        <section class="recent-section">
            <h2><i class="fas fa-box"></i> View Product</h2>
            <p style="color: var(--text-light); margin-bottom: 1rem;">Quản lý sản phẩm thú cưng 🐾</p>

            <!-- Search and Filter -->
            <div class="filter-section">
                <form method="GET" action="/Pets4Care/staff/products">
                    <input type="hidden" name="action" value="search">
                    <div class="search-form">
                        <input type="text" class="search-input" name="keyword"  
                               placeholder="Tìm kiếm theo tên sản phẩm, mô tả..."
                               value="${param.keyword}">
                        <button class="search-btn" type="submit">
                            <i class="fas fa-search"></i> Tìm kiếm
                        </button>
                    </div>
                    <div class="filter-buttons">
                        <a href="/Pets4Care/staff/products" class="filter-btn ${empty param.action ? 'active' : ''}">
                            <i class="fas fa-list"></i> Tất cả
                        </a>
                        <a href="/Pets4Care/staff/products?action=filter&stock=high" class="filter-btn ${param.stock == 'high' ? 'active' : ''}">
                            <i class="fas fa-check-circle"></i> Còn hàng
                        </a>
                        <a href="/Pets4Care/staff/products?action=filter&stock=low" class="filter-btn ${param.stock == 'low' ? 'active' : ''}">
                            <i class="fas fa-exclamation-triangle"></i> Sắp hết hàng
                        </a>
                        <a href="/Pets4Care/staff/products?action=filter&stock=out" class="filter-btn ${param.stock == 'out' ? 'active' : ''}">
                            <i class="fas fa-times-circle"></i> Hết hàng
                        </a>
                    </div>
                </form>
            </div>

            <table>
                <thead>
                    <tr>
                        <th>Product ID</th>
                        <th>Name</th>
                        <th>Category</th>
                        <th>Price</th>
                        <th>Stock</th>
                        <th>Supplier</th>
                        <th>Status</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="product" items="${products}">
                        <tr>
                            <td>#${product.productId}</td>
                            <td>${product.name}</td>
                            <td>${product.categoryName}</td>
                            <td>${product.price}</td>
                            <td>${product.stockQuantity}</td>
                            <td>${product.supplierName}</td>
                            <td>
                                <c:choose>
                                    <c:when test="${product.stockQuantity > 50}">
                                        <span class="status active">Còn hàng</span>
                                    </c:when>
                                    <c:when test="${product.stockQuantity > 0}">
                                        <span class="status warning">Sắp hết hàng</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="status danger">Hết hàng</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td>
                                <a href="/Pets4Care/staff/products?action=view&id=${product.productId}"
                                   class="btn-action view">
                                   <i class="fas fa-eye"></i> View
                                </a>
                                <a href="/Pets4Care/staff/products?action=edit&id=${product.productId}"
                                   class="btn-action edit">
                                   <i class="fas fa-edit"></i> Edit
                                </a>
                            </td>
                        </tr>
                    </c:forEach>
                    
                    <c:if test="${empty products}">
                        <tr>
                            <td colspan="8" style="text-align:center; color:var(--text-light); padding:1rem;">
                                Không có sản phẩm nào được tìm thấy 🐶
                            </td>
                        </tr>
                    </c:if>
                </tbody>
            </table>
            
            <!-- Pagination -->
            <c:if test="${totalPages > 1}">
                <div class="pagination">
                    <!-- Previous button -->
                    <c:if test="${currentPage > 1}">
                        <a href="/Pets4Care/staff/products?page=${currentPage - 1}&action=${param.action}&stock=${param.stock}&keyword=${param.keyword}">
                            <i class="fas fa-chevron-left"></i> Trước
                        </a>
                    </c:if>
                    
                    <!-- Page numbers -->
                    <c:choose>
                        <c:when test="${totalPages <= 10}">
                            <!-- Show all pages if <= 10 -->
                            <c:forEach begin="1" end="${totalPages}" var="pageNum">
                                <c:choose>
                                    <c:when test="${pageNum == currentPage}">
                                        <span class="active">
                                            <a href="#">${pageNum}</a>
                                        </span>
                                    </c:when>
                                    <c:otherwise>
                                        <a href="/Pets4Care/staff/products?page=${pageNum}&action=${param.action}&stock=${param.stock}&keyword=${param.keyword}">
                                            ${pageNum}
                                        </a>
                                    </c:otherwise>
                                </c:choose>
                            </c:forEach>
                        </c:when>
                        <c:otherwise>
                            <!-- Show pagination with ellipsis for > 10 pages -->
                            <c:choose>
                                <c:when test="${currentPage <= 5}">
                                    <!-- Show first 7 pages -->
                                    <c:forEach begin="1" end="7" var="pageNum">
                                        <c:choose>
                                            <c:when test="${pageNum == currentPage}">
                                                <span class="active">
                                                    <a href="#">${pageNum}</a>
                                                </span>
                                            </c:when>
                                            <c:otherwise>
                                                <a href="/Pets4Care/staff/products?page=${pageNum}&action=${param.action}&stock=${param.stock}&keyword=${param.keyword}">
                                                    ${pageNum}
                                                </a>
                                            </c:otherwise>
                                        </c:choose>
                                    </c:forEach>
                                    <span>...</span>
                                    <a href="/Pets4Care/staff/products?page=${totalPages}&action=${param.action}&stock=${param.stock}&keyword=${param.keyword}">
                                        ${totalPages}
                                    </a>
                                </c:when>
                                <c:when test="${currentPage >= totalPages - 4}">
                                    <!-- Show last 7 pages -->
                                    <a href="/Pets4Care/staff/products?page=1&action=${param.action}&stock=${param.stock}&keyword=${param.keyword}">
                                        1
                                    </a>
                                    <span>...</span>
                                    <c:forEach begin="${totalPages - 6}" end="${totalPages}" var="pageNum">
                                        <c:choose>
                                            <c:when test="${pageNum == currentPage}">
                                                <span class="active">
                                                    <a href="#">${pageNum}</a>
                                                </span>
                                            </c:when>
                                            <c:otherwise>
                                                <a href="/Pets4Care/staff/products?page=${pageNum}&action=${param.action}&stock=${param.stock}&keyword=${param.keyword}">
                                                    ${pageNum}
                                                </a>
                                            </c:otherwise>
                                        </c:choose>
                                    </c:forEach>
                                </c:when>
                                <c:otherwise>
                                    <!-- Show middle pages -->
                                    <a href="/Pets4Care/staff/products?page=1&action=${param.action}&stock=${param.stock}&keyword=${param.keyword}">
                                        1
                                    </a>
                                    <span>...</span>
                                    <c:forEach begin="${currentPage - 2}" end="${currentPage + 2}" var="pageNum">
                                        <c:choose>
                                            <c:when test="${pageNum == currentPage}">
                                                <span class="active">
                                                    <a href="#">${pageNum}</a>
                                                </span>
                                            </c:when>
                                            <c:otherwise>
                                                <a href="/Pets4Care/staff/products?page=${pageNum}&action=${param.action}&stock=${param.stock}&keyword=${param.keyword}">
                                                    ${pageNum}
                                                </a>
                                            </c:otherwise>
                                        </c:choose>
                                    </c:forEach>
                                    <span>...</span>
                                    <a href="/Pets4Care/staff/products?page=${totalPages}&action=${param.action}&stock=${param.stock}&keyword=${param.keyword}">
                                        ${totalPages}
                                    </a>
                                </c:otherwise>
                            </c:choose>
                        </c:otherwise>
                    </c:choose>
                    
                    <!-- Next button -->
                    <c:if test="${currentPage < totalPages}">
                        <a href="/Pets4Care/staff/products?page=${currentPage + 1}&action=${param.action}&stock=${param.stock}&keyword=${param.keyword}">
                            Sau <i class="fas fa-chevron-right"></i>
                        </a>
                    </c:if>
                </div>
                
                <!-- Pagination info -->
                <div class="pagination-info">
                    Trang ${currentPage} / ${totalPages} | Tổng cộng: ${totalProducts} sản phẩm
                </div>
            </c:if>
            
            <!-- Show pagination info even for single page -->
            <c:if test="${totalPages == 1}">
                <div class="pagination-info">
                    Trang 1 / 1 | Tổng cộng: ${totalProducts} sản phẩm
                </div>
            </c:if>
        </section>
    </main>
</div>

<footer class="staff-footer">
    <p>© 2025 Pet4Care — Where Pets Feel Loved 🐶🐱</p>
</footer>

</body>
</html>