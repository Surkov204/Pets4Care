<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ page import="model.Customer" %>
<%
    Customer customer = (Customer) session.getAttribute("customer");
    if (customer == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Lịch sử đặt lịch | Pet4Care</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/staff.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <style>
        .booking-history {
            background: white;
            border-radius: 10px;
            overflow: hidden;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }

        .booking-history table {
            width: 100%;
            border-collapse: collapse;
        }

        .booking-history th, .booking-history td {
            padding: 15px;
            text-align: left;
            border-bottom: 1px solid #dee2e6;
        }

        .booking-history th {
            background: #f8f9fa;
            font-weight: 600;
        }

        .status {
            padding: 4px 8px;
            border-radius: 4px;
            font-size: 12px;
            font-weight: bold;
        }

        .status-confirmed { background: #e8f5e8; color: #2e7d32; }
        .status-pending { background: #fff3e0; color: #f57c00; }
        .status-completed { background: #e3f2fd; color: #1565c0; }
        .status-cancelled { background: #ffebee; color: #c62828; }

        .btn-pay {
            background: #4CAF50;
            color: white;
            padding: 6px 12px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            text-decoration: none;
            font-size: 12px;
        }

        .btn-pay:hover {
            background: #45a049;
        }

        .alert {
            padding: 15px;
            border-radius: 5px;
            margin-bottom: 20px;
        }

        .alert-success {
            background: #e8f5e8;
            color: #2e7d32;
            border: 1px solid #c8e6c9;
        }

        .alert-error {
            background: #ffebee;
            color: #c62828;
            border: 1px solid #ffcdd2;
        }
    </style>
</head>
<body>

<header class="staff-header">
    <div class="user-section">
        <div class="avatar-dropdown">
            <div class="avatar" onclick="toggleDropdown()">
                <img src="${pageContext.request.contextPath}/images/user-avatar.png" alt="User">
                <span>${sessionScope.customer.name}</span>
                <i class="fas fa-chevron-down"></i>
            </div>
            <div class="dropdown-menu" id="dropdownMenu">
                <a href="${pageContext.request.contextPath}/home.jsp">
                    <i class="fas fa-home"></i> Trang chủ
                </a>
                <a href="${pageContext.request.contextPath}/user/profile">
                    <i class="fas fa-user-edit"></i> Chỉnh sửa thông tin
                </a>
                <a href="${pageContext.request.contextPath}/logout">
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
            <li><a href="${pageContext.request.contextPath}/home.jsp"><i class="fas fa-home"></i> Trang chủ</a></li>
            <li><a href="${pageContext.request.contextPath}/customer/booking" class="active"><i class="fas fa-calendar-plus"></i> Đặt lịch</a></li>
            <li><a href="${pageContext.request.contextPath}/customer/booking?action=history"><i class="fas fa-history"></i> Lịch sử</a></li>
            <li><a href="${pageContext.request.contextPath}/user/pet-info.jsp"><i class="fas fa-paw"></i> Thú cưng</a></li>
        </ul>
    </aside>

    <!-- Main Content -->
    <main class="staff-content">
        <section class="welcome-card">
            <h2><i class="fas fa-history"></i> Lịch sử đặt lịch</h2>
            <p>Xem và quản lý các lịch hẹn của bạn</p>
        </section>

        <!-- Success/Error Messages -->
        <c:if test="${not empty success}">
            <div class="alert alert-success">
                <i class="fas fa-check-circle"></i> ${success}
            </div>
        </c:if>
        <c:if test="${not empty error}">
            <div class="alert alert-error">
                <i class="fas fa-exclamation-circle"></i> ${error}
            </div>
        </c:if>

        <!-- Booking History -->
        <div class="booking-history">
            <c:choose>
                <c:when test="${not empty bookings}">
                    <table>
                        <thead>
                            <tr>
                                <th>Ngày giờ</th>
                                <th>Dịch vụ</th>
                                <th>Trạng thái</th>
                                <th>Thao tác</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="booking" items="${bookings}">
                                <tr>
                                    <td>
                                        <fmt:formatDate value="${booking.appointmentStart}" pattern="dd/MM/yyyy HH:mm"/>
                                    </td>
                                    <td>${booking.serviceNames}</td>
                                    <td>
                                        <span class="status <c:choose>
                                            <c:when test="${booking.status == 'Hoàn thành' || booking.status == 'completed'}">status-completed</c:when>
                                            <c:when test="${booking.status == 'pending'}">status-pending</c:when>
                                            <c:otherwise>status-cancelled</c:otherwise>
                                        </c:choose>">${booking.status}</span>
                                    </td>
                                    <td>
                                        <a href="${pageContext.request.contextPath}/customer/booking?action=detail&id=${booking.bookingId}"
                                           class="btn-pay">
                                            <i class="fas fa-eye"></i> Chi tiết
                                        </a>
                                        <c:if test="${booking.status == 'pending'}">
                                            <a href="${pageContext.request.contextPath}/customer/booking?action=form&serviceIds=${booking.bookingId}"
                                               class="btn-pay" style="margin-left: 5px;">
                                                <i class="fas fa-credit-card"></i> Thanh toán lại
                                            </a>
                                        </c:if>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </c:when>
                <c:otherwise>
                    <div style="text-align: center; padding: 40px; color: #666;">
                        <i class="fas fa-calendar-times" style="font-size: 48px; opacity: 0.5;"></i>
                        <h3 style="margin-top: 20px;">Chưa có lịch hẹn nào</h3>
                        <p>Bạn chưa đặt lịch hẹn nào. <a href="${pageContext.request.contextPath}/customer/booking">Đặt lịch ngay</a></p>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </main>
</div>

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