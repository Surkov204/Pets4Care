<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>🐾 Services Booking | Pet4Care</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/staff.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <style>
        .status-badge {
            font-size: 0.8em;
            padding: 0.4em 0.8em;
            border-radius: 20px;
        }
        .status-pending { background-color: #ffc107; color: #000; }
        .status-confirmed { background-color: #17a2b8; color: #fff; }
        .status-in_progress { background-color: #007bff; color: #fff; }
        .status-completed { background-color: #28a745; color: #fff; }
        .status-cancelled { background-color: #dc3545; color: #fff; }
        
        .booking-card {
            border-left: 4px solid #007bff;
            transition: all 0.3s ease;
            margin-bottom: 1rem;
        }
        
        .booking-card:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 15px rgba(0,0,0,0.1);
        }
        
        .filter-section {
            background-color: #f8f9fa;
            border-radius: 10px;
            padding: 1.5rem;
            margin-bottom: 2rem;
        }

        .btn-action {
            padding: 0.25rem 0.5rem;
            margin: 0.1rem;
            border-radius: 4px;
            text-decoration: none;
            font-size: 0.875rem;
            display: inline-block;
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

        .cards-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 1.5rem;
            margin-bottom: 2rem;
        }

        .booking-card {
            background: white;
            border-radius: 12px;
            padding: 1.5rem;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            border-left: 4px solid #007bff;
            transition: all 0.3s ease;
        }

        .booking-card:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 20px rgba(0,0,0,0.15);
        }

        .booking-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 1rem;
            padding-bottom: 0.5rem;
            border-bottom: 1px solid #eee;
        }

        .booking-title {
            font-size: 1.1rem;
            font-weight: 600;
            color: #333;
            margin: 0;
        }

        .booking-info {
            color: #666;
            line-height: 1.6;
        }

        .booking-info strong {
            color: #333;
        }

        .booking-actions {
            display: flex;
            gap: 0.5rem;
            margin-top: 1rem;
            flex-wrap: wrap;
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
        }

        .search-btn {
            padding: 0.75rem 1.5rem;
            background-color: #007bff;
            color: white;
            border: none;
            border-radius: 8px;
            cursor: pointer;
            font-size: 0.9rem;
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
        }

        .filter-btn:hover {
            background-color: #f8f9fa;
            color: #333;
        }

        .filter-btn.active {
            background-color: #007bff;
            color: white;
            border-color: #007bff;
        }

        .empty-state {
            text-align: center;
            padding: 3rem 1rem;
            color: #666;
        }

        .empty-state i {
            font-size: 3rem;
            margin-bottom: 1rem;
            opacity: 0.5;
        }

        .pagination {
            display: flex;
            justify-content: center;
            gap: 0.5rem;
            margin-top: 2rem;
        }

        .pagination a {
            padding: 0.5rem 0.75rem;
            border: 1px solid #ddd;
            text-decoration: none;
            color: #666;
            border-radius: 4px;
        }

        .pagination a:hover {
            background-color: #f8f9fa;
        }

        .pagination .active a {
            background-color: #007bff;
            color: white;
            border-color: #007bff;
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
            <li><a href="${pageContext.request.contextPath}/staff/viewOrder"><i class="fas fa-receipt"></i> View Orders</a></li>
            <li><a href="${pageContext.request.contextPath}/staff/work-schedule"><i class="fas fa-calendar-alt"></i> Work Schedule</a></li>
            <li><a href="${pageContext.request.contextPath}/staff/customer-list"><i class="fas fa-user"></i> Customer Profile</a></li>
            <li><a href="${pageContext.request.contextPath}/staff/bookings" class="active"><i class="fas fa-list"></i> Services Booking</a></li>
            <li><a href="${pageContext.request.contextPath}/staff/chatCustomer"><i class="fas fa-comments"></i> Chat with Customer</a></li>
            <li><a href="${pageContext.request.contextPath}/staff/products"><i class="fas fa-box"></i> View Product</a></li>
        </ul>
    </aside>

    <!-- Main Content -->
    <main class="staff-content">
        <section class="recent-section">
            <h2><i class="fas fa-calendar-check"></i> Services Booking</h2>
            <p style="color: var(--text-light); margin-bottom: 1rem;">Quản lý đặt lịch dịch vụ cho thú cưng 🐾</p>

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

            <!-- Search and Filter -->
            <div class="filter-section">
                <form method="GET" action="${pageContext.request.contextPath}/staff/bookings">
                    <input type="hidden" name="action" value="search">
                    <div class="search-form">
                        <input type="text" class="search-input" name="keyword" 
                               placeholder="Tìm kiếm theo tên, SĐT, email, loại dịch vụ..." 
                               value="${keyword}">
                        <button class="search-btn" type="submit">
                            <i class="fas fa-search"></i> Tìm kiếm
                        </button>
                    </div>
                    <div class="filter-buttons">
                        <a href="${pageContext.request.contextPath}/staff/bookings" class="filter-btn">
                            <i class="fas fa-list"></i> Tất cả
                        </a>
                        <a href="${pageContext.request.contextPath}/staff/bookings?action=filter&status=pending" class="filter-btn">
                            <i class="fas fa-clock"></i> Chờ xử lý
                        </a>
                        <a href="${pageContext.request.contextPath}/staff/bookings?action=filter&status=confirmed" class="filter-btn">
                            <i class="fas fa-check"></i> Đã xác nhận
                        </a>
                        <a href="${pageContext.request.contextPath}/staff/bookings?action=filter&status=completed" class="filter-btn">
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
                                <a href="${pageContext.request.contextPath}/staff/bookings?action=view&id=${booking.bookingId}" 
                                   class="btn-action view">
                                   <i class="fas fa-eye"></i> View
                                </a>
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
            form.action = '${pageContext.request.contextPath}/staff/bookings';
            
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
