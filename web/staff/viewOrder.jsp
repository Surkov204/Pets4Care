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
    </style>
</head>
<body>

<header class="staff-header">
    <div class="logo-section">
        <img src="${pageContext.request.contextPath}/images/logo.png" alt="Pet4Care">
        <div>
            <h1>Pet4Care</h1>
            <p>Staff Dashboard</p>
        </div>
    </div>
    <div class="user-section">
        <div class="notif"><i class="fas fa-bell"></i></div>
        <div class="chat"><i class="fas fa-comments"></i></div>
        <div class="avatar">
            <img src="${pageContext.request.contextPath}/images/staff-avatar.png" alt="Staff">
            <span>${sessionScope.staff.name}</span>
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
            <li><a href="${pageContext.request.contextPath}/staff/viewOrder" class="active"><i class="fas fa-receipt"></i> View Orders</a></li>
            <li><a href="${pageContext.request.contextPath}/staff/work-schedule"><i class="fas fa-calendar-alt"></i> Work Schedule</a></li>
            <li><a href="${pageContext.request.contextPath}/staff/staff-profile"><i class="fas fa-user-circle"></i> Staff Profile</a></li>
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

            <!-- Tìm kiếm đơn hàng -->
            <div class="search-section" style="background-color: #f8f9fa; border-radius: 10px; padding: 1.5rem; margin-bottom: 2rem;">
                <h3 style="margin-bottom: 1rem; color: var(--primary-color);">
                    <i class="fas fa-search"></i> Tìm kiếm đơn hàng
                </h3>
                <form method="GET" action="${pageContext.request.contextPath}/staff/viewOrder" style="display: flex; gap: 1rem; align-items: end; flex-wrap: wrap;">
                    <div style="flex: 1; min-width: 200px;">
                        <label for="orderId" style="display: block; margin-bottom: 0.5rem; font-weight: 500;">Order ID:</label>
                        <input type="text" id="orderId" name="orderId" placeholder="Nhập Order ID..."
                               value="${param.orderId}" style="width: 100%; padding: 0.5rem; border: 1px solid #ddd; border-radius: 5px;">
                    </div>
                    <div style="flex: 1; min-width: 200px;">
                        <label for="customerName" style="display: block; margin-bottom: 0.5rem; font-weight: 500;">Tên khách hàng:</label>
                        <input type="text" id="customerName" name="customerName" placeholder="Nhập tên khách hàng..."
                               value="${param.customerName}" style="width: 100%; padding: 0.5rem; border: 1px solid #ddd; border-radius: 5px;">
                    </div>
                    <div style="flex: 1; min-width: 200px;">
                        <label for="status" style="display: block; margin-bottom: 0.5rem; font-weight: 500;">Trạng thái:</label>
                        <select id="status" name="status" style="width: 100%; padding: 0.5rem; border: 1px solid #ddd; border-radius: 5px;">
                            <option value="">Tất cả trạng thái</option>
                            <option value="pending" ${param.status == 'pending' ? 'selected' : ''}>Đang chờ</option>
                            <option value="confirmed" ${param.status == 'confirmed' ? 'selected' : ''}>Đã xác nhận</option>
                            <option value="processing" ${param.status == 'processing' ? 'selected' : ''}>Đang xử lý</option>
                            <option value="shipped" ${param.status == 'shipped' ? 'selected' : ''}>Đã giao</option>
                            <option value="delivered" ${param.status == 'delivered' ? 'selected' : ''}>Đã nhận</option>
                            <option value="cancelled" ${param.status == 'cancelled' ? 'selected' : ''}>Đã hủy</option>
                        </select>
                    </div>
                    <div>
                        <button type="submit" style="background-color: var(--primary-color); color: white; padding: 0.5rem 1rem; border: none; border-radius: 5px; cursor: pointer;">
                            <i class="fas fa-search"></i> Tìm kiếm
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
                        <th>Actions</th>
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
                                <a href="${pageContext.request.contextPath}/staff/orderDetail?id=${order.orderId}" 
                                   class="btn-action view">
                                   <i class="fas fa-eye"></i> View
                                </a>
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
        </section>
    </main>
</div>

<footer class="staff-footer">
    <p>© 2025 Pet4Care — Where Pets Feel Loved 🐶🐱</p>
</footer>

</body>
</html>