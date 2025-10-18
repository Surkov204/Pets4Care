<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>🐾 Order Detail | Pet4Care</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/staff.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <style>
        .order-detail-card {
            background: white;
            border-radius: 12px;
            padding: 2rem;
            margin-bottom: 2rem;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        
        .order-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 2rem;
            padding-bottom: 1rem;
            border-bottom: 2px solid #e9ecef;
        }
        
        .order-info {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 1rem;
            margin-bottom: 2rem;
        }
        
        .info-item {
            display: flex;
            flex-direction: column;
        }
        
        .info-label {
            font-weight: 600;
            color: #666;
            margin-bottom: 0.5rem;
        }
        
        .info-value {
            font-size: 1.1rem;
            color: #333;
        }
        
        .status-badge {
            padding: 0.5rem 1rem;
            border-radius: 20px;
            font-weight: 600;
            text-transform: uppercase;
            font-size: 0.9rem;
        }
        
        .status-completed {
            background-color: #d4edda;
            color: #155724;
        }
        
        .status-processing {
            background-color: #fff3cd;
            color: #856404;
        }
        
        .status-cancelled {
            background-color: #f8d7da;
            color: #721c24;
        }
        
        .payment-status {
            padding: 0.25rem 0.5rem;
            border-radius: 4px;
            font-size: 0.8rem;
            font-weight: 500;
        }
        
        .payment-paid {
            background-color: #d4edda;
            color: #155724;
        }
        
        .payment-unpaid {
            background-color: #f8d7da;
            color: #721c24;
        }
        
        .order-items {
            margin-top: 2rem;
        }
        
        .item-card {
            background: #f8f9fa;
            border-radius: 8px;
            padding: 1rem;
            margin-bottom: 1rem;
            border-left: 4px solid #007bff;
        }
        
        .item-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 0.5rem;
        }
        
        .item-name {
            font-weight: 600;
            color: #333;
        }
        
        .item-price {
            font-weight: 600;
            color: #e74c3c;
        }
        
        .item-details {
            color: #666;
            font-size: 0.9rem;
        }
        
        .total-section {
            background: #e9ecef;
            border-radius: 8px;
            padding: 1.5rem;
            margin-top: 2rem;
            text-align: right;
        }
        
        .total-amount {
            font-size: 1.5rem;
            font-weight: 700;
            color: #e74c3c;
        }
        
        .back-btn {
            background-color: #6c757d;
            color: white;
            padding: 0.75rem 1.5rem;
            border: none;
            border-radius: 8px;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
            margin-bottom: 2rem;
            transition: background-color 0.3s ease;
        }
        
        .back-btn:hover {
            background-color: #5a6268;
            color: white;
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
            <li><a href="${pageContext.request.contextPath}/staff/work-schedule.jsp"><i class="fas fa-calendar-alt"></i> Work Schedule</a></li>
            <li><a href="${pageContext.request.contextPath}/staff/customer-list"><i class="fas fa-users"></i> Customer Profile</a></li>
            <li><a href="${pageContext.request.contextPath}/staff/services-booking"><i class="fas fa-list"></i> Services Booking</a></li>
            <li><a href="${pageContext.request.contextPath}/staff/chatCustomer.jsp"><i class="fas fa-comments"></i> Chat with Customer</a></li>
            <li><a href="${pageContext.request.contextPath}/staff/products"><i class="fas fa-box"></i> View Product</a></li>
        </ul>
    </aside>

    <!-- Main Content -->
    <main class="staff-content">
        <section class="recent-section">
            <a href="${pageContext.request.contextPath}/staff/viewOrder" class="back-btn">
                <i class="fas fa-arrow-left"></i> Quay lại danh sách đơn hàng
            </a>
            
            <h2><i class="fas fa-receipt"></i> Chi tiết đơn hàng</h2>
            <p style="color: var(--text-light); margin-bottom: 1rem;">Thông tin chi tiết đơn hàng và dịch vụ 🐾</p>

            <c:if test="${not empty order}">
                <div class="order-detail-card">
                    <div class="order-header">
                        <h3>Đơn hàng #${order.orderId}</h3>
                        <span class="status-badge status-${order.status.toLowerCase()}">
                            ${order.status}
                        </span>
                    </div>
                    
                    <div class="order-info">
                        <div class="info-item">
                            <span class="info-label">Khách hàng</span>
                            <span class="info-value">${order.customerName}</span>
                        </div>
                        <div class="info-item">
                            <span class="info-label">Ngày đặt hàng</span>
                            <span class="info-value">
                                <fmt:formatDate value="${order.orderDate}" pattern="dd/MM/yyyy HH:mm"/>
                            </span>
                        </div>
                        <div class="info-item">
                            <span class="info-label">Trạng thái thanh toán</span>
                            <span class="payment-status payment-${order.paymentStatus.toLowerCase()}">
                                ${order.paymentStatus}
                            </span>
                        </div>
                        <div class="info-item">
                            <span class="info-label">Phương thức thanh toán</span>
                            <span class="info-value">${order.paymentMethod}</span>
                        </div>
                        <c:if test="${not empty order.paidAt}">
                            <div class="info-item">
                                <span class="info-label">Ngày thanh toán</span>
                                <span class="info-value">
                                    <fmt:formatDate value="${order.paidAt}" pattern="dd/MM/yyyy HH:mm"/>
                                </span>
                            </div>
                        </c:if>
                    </div>
                    
                    <div class="order-items">
                        <h4><i class="fas fa-list"></i> Chi tiết đơn hàng</h4>
                        
                        <c:forEach var="detail" items="${orderDetails}">
                            <div class="item-card">
                                <div class="item-header">
                                    <span class="item-name">
                                        <c:choose>
                                            <c:when test="${not empty detail.productName}">
                                                <i class="fas fa-box"></i> ${detail.productName}
                                            </c:when>
                                            <c:when test="${not empty detail.serviceName}">
                                                <i class="fas fa-concierge-bell"></i> ${detail.serviceName}
                                            </c:when>
                                            <c:otherwise>
                                                <i class="fas fa-question-circle"></i> Sản phẩm/Dịch vụ không xác định
                                            </c:otherwise>
                                        </c:choose>
                                    </span>
                                    <span class="item-price">
                                        <fmt:formatNumber value="${detail.unitPrice}" type="currency" currencySymbol="₫"/>
                                    </span>
                                </div>
                                <div class="item-details">
                                    <strong>Số lượng:</strong> ${detail.quantity} |
                                    <strong>Thành tiền:</strong> 
                                    <fmt:formatNumber value="${detail.unitPrice * detail.quantity}" type="currency" currencySymbol="₫"/>
                                </div>
                            </div>
                        </c:forEach>
                        
                        <div class="total-section">
                            <div class="total-amount">
                                Tổng cộng: <fmt:formatNumber value="${order.totalAmount}" type="currency" currencySymbol="₫"/>
                            </div>
                        </div>
                    </div>
                </div>
            </c:if>
            
            <c:if test="${empty order}">
                <div style="text-align: center; padding: 3rem; color: #666;">
                    <i class="fas fa-exclamation-triangle" style="font-size: 3rem; margin-bottom: 1rem; opacity: 0.5;"></i>
                    <p>Không tìm thấy đơn hàng 🐶</p>
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
