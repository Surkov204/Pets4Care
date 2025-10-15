<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>🐾 Staff Dashboard | Pet4Care</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/staff.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
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
<li><a href="${pageContext.request.contextPath}/staff/viewOrder.jsp"><i class="fas fa-receipt"></i> View Orders</a></li>
<li><a href="${pageContext.request.contextPath}/staff/booking-list.jsp"><i class="fas fa-edit"></i> Update Booking</a></li>
<li><a href="${pageContext.request.contextPath}/staff/booking-stats.jsp"><i class="fas fa-list"></i> Services Booking</a></li>
<li><a href="${pageContext.request.contextPath}/staff/chatCustomer.jsp"><i class="fas fa-comments"></i> Chat with Customer</a></li>
<li><a href="${pageContext.request.contextPath}/staff/customer-list.jsp"><i class="fas fa-user"></i> Customer Profile</a></li>
<li><a href="${pageContext.request.contextPath}/staff/index.jsp"><i class="fas fa-calendar-alt"></i> Work Schedule</a></li>
<li><a href="staff-profile.jsp"><i class="fas fa-id-card"></i> Staff Profile</a></li>
        </ul>
    </aside>

    <!-- Content -->
    <main class="staff-content">
        <section class="welcome-card">
            <h2>Chào mừng trở lại, ${sessionScope.staff.name} 🐾</h2>
            <p>Chúc bạn một ngày làm việc vui vẻ cùng thú cưng nhé!</p>
        </section>

        <section class="cards-grid">
            <div class="dashboard-card">
                <i class="fas fa-receipt"></i>
                <h3>Orders</h3>
                <p>${orderCount} đơn hàng đang xử lý</p>
            </div>
            <div class="dashboard-card">
                <i class="fas fa-list"></i>
                <h3>Bookings</h3>
                <p>${bookingCount} dịch vụ đặt lịch</p>
            </div>
            <div class="dashboard-card">
                <i class="fas fa-calendar-alt"></i>
                <h3>Work Schedule</h3>
                <p>${todayShift}</p>
            </div>
            <div class="dashboard-card">
                <i class="fas fa-user"></i>
                <h3>Customers</h3>
                <p>${customerCount} khách đang hoạt động</p>
            </div>
        </section>

        <section class="recent-section">
            <h2><i class="fas fa-clock"></i> Recent Orders</h2>
            <table>
                <thead>
                    <tr>
                        <th>Order ID</th>
                        <th>Customer</th>
                        <th>Service</th>
                        <th>Status</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="order" items="${orders}">
                        <tr>
                            <td>${order.id}</td>
                            <td>${order.customerName}</td>
                            <td>${order.serviceName}</td>
                            <td>
                                <span class="status ${order.status}">
                                    ${order.status}
                                </span>
                            </td>
                        </tr>
                    </c:forEach>
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
