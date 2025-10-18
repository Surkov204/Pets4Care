<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>🐾 Services Booking | Pet4Care</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/staff.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <style>
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
            <li><a href="${pageContext.request.contextPath}/staff/viewOrder"><i class="fas fa-receipt"></i> View Orders</a></li>
            <li><a href="${pageContext.request.contextPath}/staff/work-schedule"><i class="fas fa-calendar-alt"></i> Work Schedule</a></li>
            <li><a href="${pageContext.request.contextPath}/staff/customer-list"><i class="fas fa-user"></i> Customer Profile</a></li>
            <li><a href="${pageContext.request.contextPath}/staff/services-booking" class="active"><i class="fas fa-list"></i> Services Booking</a></li>
            <li><a href="${pageContext.request.contextPath}/staff/chatCustomer"><i class="fas fa-comments"></i> Chat with Customer</a></li>
            <li><a href="${pageContext.request.contextPath}/staff/products"><i class="fas fa-box"></i> View Product</a></li>
        </ul>
    </aside>

    <!-- Main Content -->
    <main class="staff-content">
        <section class="recent-section">
            <h2><i class="fas fa-calendar-check"></i> Services Booking</h2>
            <p style="color: var(--text-light); margin-bottom: 1rem;">Danh sách đặt lịch dịch vụ cho thú cưng 🐾</p>

            <!-- Alerts -->
            <c:if test="${not empty success}">
                <div class="alert alert-success" style="background-color: #d4edda; color: #155724; padding: 1rem; border-radius: 8px; margin-bottom: 1rem; border: 1px solid #c3e6cb;">
                    <i class="fas fa-check-circle"></i> ${success}
                </div>
            </c:if>
            
            <c:if test="${not empty error}">
                <div class="alert alert-danger" style="background-color: #f8d7da; color: #721c24; padding: 1rem; border-radius: 8px; margin-bottom: 1rem; border: 1px solid #f5c6cb;">
                    <i class="fas fa-exclamation-circle"></i> ${error}
                </div>
            </c:if>
            
            <c:if test="${not empty info}">
                <div class="alert alert-info" style="background-color: #d1ecf1; color: #0c5460; padding: 1rem; border-radius: 8px; margin-bottom: 1rem; border: 1px solid #bee5eb;">
                    <i class="fas fa-info-circle"></i> ${info}
                </div>
            </c:if>

            <!-- Search and Filter -->
            <div class="filter-section" style="background-color: #f8f9fa; border-radius: 10px; padding: 1.5rem; margin-bottom: 2rem;">
                <form method="GET" action="${pageContext.request.contextPath}/staff/services-booking">
                    <div class="search-form" style="display: flex; gap: 1rem; margin-bottom: 1.5rem; align-items: center;">
                        <input type="text" class="search-input" name="keyword" 
                               placeholder="Tìm kiếm theo tên, SĐT, email, loại dịch vụ..." 
                               value="${keyword}" style="flex: 1; padding: 0.75rem; border: 1px solid #ddd; border-radius: 8px; font-size: 0.9rem;">
                        <button class="search-btn" type="submit" style="padding: 0.75rem 1.5rem; background-color: #007bff; color: white; border: none; border-radius: 8px; cursor: pointer; font-size: 0.9rem;">
                            <i class="fas fa-search"></i> Tìm kiếm
                        </button>
                    </div>
                    <div class="filter-buttons" style="display: flex; gap: 0.5rem; flex-wrap: wrap;">
                        <a href="${pageContext.request.contextPath}/staff/services-booking" class="filter-btn" style="padding: 0.5rem 1rem; border: 1px solid #ddd; background: white; border-radius: 6px; text-decoration: none; color: #666; font-size: 0.85rem;">
                            <i class="fas fa-list"></i> Tất cả
                        </a>
                        <a href="${pageContext.request.contextPath}/staff/services-booking?status=pending" class="filter-btn" style="padding: 0.5rem 1rem; border: 1px solid #ddd; background: white; border-radius: 6px; text-decoration: none; color: #666; font-size: 0.85rem;">
                            <i class="fas fa-clock"></i> Chờ xử lý
                        </a>
                        <a href="${pageContext.request.contextPath}/staff/services-booking?status=confirmed" class="filter-btn" style="padding: 0.5rem 1rem; border: 1px solid #ddd; background: white; border-radius: 6px; text-decoration: none; color: #666; font-size: 0.85rem;">
                            <i class="fas fa-check"></i> Đã xác nhận
                        </a>
                        <a href="${pageContext.request.contextPath}/staff/services-booking?status=completed" class="filter-btn" style="padding: 0.5rem 1rem; border: 1px solid #ddd; background: white; border-radius: 6px; text-decoration: none; color: #666; font-size: 0.85rem;">
                            <i class="fas fa-check-circle"></i> Hoàn thành
                        </a>
                    </div>
                </form>
            </div>

            <table>
                <thead>
                    <tr>
                        <th>Booking ID</th>
                        <th>Customer</th>
                        <th>Service</th>
                        <th>Pet</th>
                        <th>Appointment</th>
                        <th>Status</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="booking" items="${bookings}">
                        <tr>
                            <td>#${booking.bookingId}</td>
                            <td>${booking.customerName}</td>
                            <td>
                                <c:if test="${not empty booking.note}">
                                    ${booking.note}
                                </c:if>
                                <c:if test="${not empty booking.serviceNames}">
                                    ${booking.serviceNames}
                                </c:if>
                            </td>
                            <td>${booking.petName} (${booking.petType})</td>
                            <td>
                                <fmt:formatDate value="${booking.appointmentStart}" pattern="dd/MM/yyyy HH:mm"/>
                            </td>
                            <td>
                                <span class="status ${booking.status}">
                                    ${booking.status}
                                </span>
                            </td>
                            <td>
                                <c:if test="${booking.status == 'pending'}">
                                    <button type="button" class="btn-action edit" 
                                            onclick="updateStatus(${booking.bookingId}, 'confirmed')">
                                        <i class="fas fa-check"></i> Confirm
                                    </button>
                                </c:if>
                                <c:if test="${booking.status == 'confirmed'}">
                                    <button type="button" class="btn-action edit" 
                                            onclick="updateStatus(${booking.bookingId}, 'in_progress')">
                                        <i class="fas fa-play"></i> Start
                                    </button>
                                </c:if>
                                <c:if test="${booking.status == 'in_progress'}">
                                    <button type="button" class="btn-action edit" 
                                            onclick="updateStatus(${booking.bookingId}, 'completed')">
                                        <i class="fas fa-check-circle"></i> Complete
                                    </button>
                                </c:if>
                            </td>
                        </tr>
                    </c:forEach>

                    <c:if test="${empty bookings}">
                        <tr>
                            <td colspan="7" style="text-align:center; color:var(--text-light); padding:1rem;">
                                Không có đặt lịch nào được tìm thấy 🐶
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

<script>
    function updateStatus(bookingId, status) {
        if (confirm('Bạn có chắc chắn muốn cập nhật trạng thái?')) {
            const form = document.createElement('form');
            form.method = 'POST';
            form.action = '${pageContext.request.contextPath}/staff/services-booking';
            
            const actionInput = document.createElement('input');
            actionInput.type = 'hidden';
            actionInput.name = 'action';
            actionInput.value = 'update_status';
            form.appendChild(actionInput);
            
            const bookingIdInput = document.createElement('input');
            bookingIdInput.type = 'hidden';
            bookingIdInput.name = 'bookingId';
            bookingIdInput.value = bookingId;
            form.appendChild(bookingIdInput);
            
            const statusInput = document.createElement('input');
            statusInput.type = 'hidden';
            statusInput.name = 'status';
            statusInput.value = status;
            form.appendChild(statusInput);
            
            document.body.appendChild(form);
            form.submit();
        }
    }
</script>

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
