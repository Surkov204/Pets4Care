<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>🐾 View Orders | Pet4Care</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/staff.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <style>
        .status {
            padding: 0.25rem 0.5rem;
            border-radius: 4px;
            font-size: 0.8rem;
            font-weight: 500;
        }
        .status-completed, .status-đã-hoàn-tất {
            background-color: #d4edda;
            color: #155724;
        }
        .status-processing, .status-đang-xử-lý {
            background-color: #fff3cd;
            color: #856404;
        }
        .status-cancelled, .status-đã-hủy {
            background-color: #f8d7da;
            color: #721c24;
        }
        .payment-status {
            padding: 0.25rem 0.5rem;
            border-radius: 4px;
            font-size: 0.8rem;
            font-weight: 500;
        }
        .payment-paid, .payment-PAID {
            background-color: #d4edda;
            color: #155724;
        }
        .payment-unpaid, .payment-UNPAID {
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
        .btn-action:hover {
            opacity: 0.8;
        }
        
        /* Dropdown Menu Styles */
        .avatar-dropdown {
            position: relative;
            display: inline-block;
        }
        
        .avatar {
            cursor: pointer;
            display: flex;
            align-items: center;
            gap: 8px;
            padding: 8px 12px;
            border-radius: 8px;
            transition: background-color 0.3s;
        }
        
        .avatar:hover {
            background-color: rgba(255, 255, 255, 0.1);
        }
        
        .avatar i {
            font-size: 12px;
            transition: transform 0.3s;
        }
        
        .dropdown-menu {
            position: absolute;
            top: 100%;
            right: 0;
            background: white;
            border-radius: 8px;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
            min-width: 200px;
            z-index: 1000;
            display: none;
            overflow: hidden;
        }
        
        .dropdown-menu.show {
            display: block;
        }
        
        .dropdown-menu a {
            display: flex;
            align-items: center;
            gap: 10px;
            padding: 12px 16px;
            color: #333;
            text-decoration: none;
            transition: background-color 0.3s;
        }
        
        .dropdown-menu a:hover {
            background-color: #f8f9fa;
        }
        
        .dropdown-menu a i {
            color: #6c757d;
            width: 16px;
        }
    </style>
</head>
<body>

<header class="staff-header">
    <div class="user-section">
        <div class="avatar-dropdown">
            <div class="avatar" onclick="toggleDropdown()">
                <img src="${pageContext.request.contextPath}/images/staff-avatar.png" alt="Staff">
                <span>${sessionScope.staff.name}</span>
                <i class="fas fa-chevron-down"></i>
            </div>
            <div class="dropdown-menu" id="dropdownMenu">
                <a href="${pageContext.request.contextPath}/home.jsp">
                    <i class="fas fa-home"></i> Trang chủ
                </a>
                <a href="${pageContext.request.contextPath}/staff/edit-profile">
                    <i class="fas fa-user-edit"></i> Chỉnh sửa thông tin
                </a>
                <a href="${pageContext.request.contextPath}/staff/logout">
                    <i class="fas fa-sign-out-alt"></i> Đăng xuất
                </a>
            </div>
        </div>
    </div>
</header>

<div class="staff-wrapper">
    <!-- Sidebar -->
    <aside class="staff-sidebar">
        <ul>
            <li><a href="${pageContext.request.contextPath}/staff/viewOrder" class="active"><i class="fas fa-receipt"></i> View Orders</a></li>
            <li><a href="${pageContext.request.contextPath}/staff/work-schedule"><i class="fas fa-calendar-alt"></i> Work Schedule</a></li>
            <li><a href="${pageContext.request.contextPath}/staff/customer-list"><i class="fas fa-user"></i> Customer Profile</a></li>
            <li><a href="${pageContext.request.contextPath}/staff/services-booking"><i class="fas fa-list"></i> Services Booking</a></li>
            <li><a href="${pageContext.request.contextPath}/staff/chatCustomer"><i class="fas fa-comments"></i> Chat with Customer</a></li>
            <li><a href="${pageContext.request.contextPath}/staff/products"><i class="fas fa-box"></i> View Product</a></li>
        </ul>
    </aside>

    <!-- Main Content -->
    <main class="staff-content">
        <section class="recent-section">
            <h2><i class="fas fa-receipt"></i> Orders List</h2>
            <p style="color: var(--text-light); margin-bottom: 1rem;">Danh sách đơn hàng của khách hàng gần đây 🐾</p>

            <!-- Bộ lọc đơn hàng -->
            <div class="search-section" style="background-color: #f8f9fa; border-radius: 10px; padding: 1.5rem; margin-bottom: 2rem;">
                <h3 style="margin-bottom: 1rem; color: var(--primary-color);">
                    <i class="fas fa-filter"></i> Bộ lọc đơn hàng
                </h3>
                <form method="GET" action="${pageContext.request.contextPath}/staff/viewOrder" style="display: flex; gap: 1rem; align-items: end; flex-wrap: wrap;">
                    <div style="flex: 1; min-width: 200px;">
                        <label for="customerName" style="display: block; margin-bottom: 0.5rem; font-weight: 500;">Tên khách hàng:</label>
                        <input type="text" id="customerName" name="customerName" placeholder="Nhập tên khách hàng..."
                               value="${param.customerName}" style="width: 100%; padding: 0.5rem; border: 1px solid #ddd; border-radius: 5px;">
                    </div>
                    <div style="flex: 1; min-width: 200px;">
                        <label for="paymentStatus" style="display: block; margin-bottom: 0.5rem; font-weight: 500;">Trạng thái thanh toán:</label>
                        <select id="paymentStatus" name="paymentStatus" style="width: 100%; padding: 0.5rem; border: 1px solid #ddd; border-radius: 5px;">
                            <option value="">Tất cả trạng thái thanh toán</option>
                            <option value="PAID" ${param.paymentStatus == 'PAID' ? 'selected' : ''}>Đã thanh toán</option>
                            <option value="UNPAID" ${param.paymentStatus == 'UNPAID' ? 'selected' : ''}>Chưa thanh toán</option>
                        </select>
                    </div>
                    <div>
                        <button type="submit" style="background-color: var(--primary-color); color: white; padding: 0.5rem 1rem; border: none; border-radius: 5px; cursor: pointer;">
                            <i class="fas fa-filter"></i> Lọc
                        </button>
                        <a href="${pageContext.request.contextPath}/staff/viewOrder"
                           style="background-color: #6c757d; color: white; padding: 0.5rem 1rem; border: none; border-radius: 5px; cursor: pointer; text-decoration: none; margin-left: 0.5rem;">
                            <i class="fas fa-refresh"></i> Reset
                        </a>
                    </div>
                </form>
            </div>

            <table>
                <thead>
                    <tr>
                        <th>Order ID</th>
                        <th>Customer</th>
                        <th>Order Date</th>
                        <th>Total Amount</th>
                        <th>Status</th>
                        <th>Payment Status</th>
                        <th>Ngày thanh toán</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="order" items="${orders}">
                        <tr>
                            <td>#${order.orderId}</td>
                            <td>${order.customerName}</td>
                            <td>
                                <fmt:formatDate value="${order.orderDate}" pattern="dd/MM/yyyy HH:mm"/>
                            </td>
                            <td>
                                <fmt:formatNumber value="${order.totalAmount}" type="currency" currencySymbol="₫"/>
                            </td>
                            <td>
                                <span class="status status-${order.status.toLowerCase()}">
                                    ${order.status}
                                </span>
                            </td>
                            <td>
                                <span class="payment-status payment-${order.paymentStatus}">
                                    ${order.paymentStatus}
                                </span>
                            </td>
                            <td>
                                <c:choose>
                                    <c:when test="${order.paidAt != null}">
                                        <fmt:formatDate value="${order.paidAt}" pattern="dd/MM/yyyy HH:mm"/>
                                    </c:when>
                                    <c:otherwise>
                                        <span style="color: #6c757d; font-style: italic;">Chưa thanh toán</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                        </tr>
                    </c:forEach>

                    <c:if test="${empty orders}">
                        <tr>
                            <td colspan="7" style="text-align:center; color:var(--text-light); padding:1rem;">
                                Không có đơn hàng nào được tìm thấy 🐶
                            </td>
                        </tr>
                    </c:if>
                </tbody>
            </table>

            <!-- Phân trang -->
            <c:if test="${totalPages > 1}">
                <div class="pagination" style="display: flex; justify-content: center; align-items: center; margin-top: 2rem; gap: 0.5rem;">
                    <!-- Nút Previous -->
                    <c:if test="${currentPage > 1}">
                        <a href="${pageContext.request.contextPath}/staff/viewOrder?page=${currentPage - 1}&customerName=${param.customerName}&paymentStatus=${param.paymentStatus}"
                           style="padding: 0.5rem 1rem; background-color: var(--primary-color); color: white; text-decoration: none; border-radius: 5px;">
                            <i class="fas fa-chevron-left"></i> Trước
                        </a>
                    </c:if>
                    
                    <!-- Các số trang -->
                    <c:forEach begin="1" end="${totalPages}" var="pageNum">
                        <c:choose>
                            <c:when test="${pageNum == currentPage}">
                                <span style="padding: 0.5rem 1rem; background-color: #6c757d; color: white; border-radius: 5px; font-weight: bold;">
                                    ${pageNum}
                                </span>
                            </c:when>
                            <c:otherwise>
                                <a href="${pageContext.request.contextPath}/staff/viewOrder?page=${pageNum}&customerName=${param.customerName}&paymentStatus=${param.paymentStatus}"
                                   style="padding: 0.5rem 1rem; background-color: #f8f9fa; color: var(--primary-color); text-decoration: none; border-radius: 5px; border: 1px solid #ddd;">
                                    ${pageNum}
                                </a>
                            </c:otherwise>
                        </c:choose>
                    </c:forEach>
                    
                    <!-- Nút Next -->
                    <c:if test="${currentPage < totalPages}">
                        <a href="${pageContext.request.contextPath}/staff/viewOrder?page=${currentPage + 1}&customerName=${param.customerName}&paymentStatus=${param.paymentStatus}"
                           style="padding: 0.5rem 1rem; background-color: var(--primary-color); color: white; text-decoration: none; border-radius: 5px;">
                            Sau <i class="fas fa-chevron-right"></i>
                        </a>
                    </c:if>
                </div>
                
                <!-- Thông tin phân trang -->
                <div style="text-align: center; margin-top: 1rem; color: var(--text-light);">
                    Trang ${currentPage} / ${totalPages} - Tổng ${totalOrders} đơn hàng
                </div>
            </c:if>
        </section>
    </main>
</div>

<footer class="staff-footer">
    <p>© 2025 Pet4Care — Where Pets Feel Loved 🐶🐱</p>
</footer>

<script>
function toggleDropdown() {
    const dropdown = document.getElementById('dropdownMenu');
    dropdown.classList.toggle('show');
}

// Close dropdown when clicking outside
document.addEventListener('click', function(event) {
    const dropdown = document.getElementById('dropdownMenu');
    const avatar = document.querySelector('.avatar');
    
    if (!avatar.contains(event.target)) {
        dropdown.classList.remove('show');
    }
});
</script>

</body>
</html>