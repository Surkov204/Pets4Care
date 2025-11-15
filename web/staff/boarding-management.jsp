<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>🏨 Boarding Management | Pet4Care</title>
    <link rel="stylesheet" href="/Pets4Care/css/staff.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">

    <style>
        /* ====== GIỐNG VIEW PRODUCT ====== */
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

        table {
            width: 100%;
            border-collapse: collapse;
            background: white;
            border-radius: 10px;
            overflow: hidden;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.05);
        }

        th, td {
            padding: 0.9rem 1rem;
            text-align: center;
            border-bottom: 1px solid #e9ecef;
        }

        th {
            background-color: #007bff;
            color: white;
            font-weight: 600;
        }

        tr:hover {
            background-color: #f8fafc;
        }

        .status {
            padding: 0.35rem 0.6rem;
            border-radius: 6px;
            font-size: 0.85rem;
            font-weight: 600;
        }

        .pending { background:#fff3cd; color:#856404; }
        .waiting { background:#cce5ff; color:#004085; }
        .using { background:#d1ecf1; color:#0c5460; }
        .paid { background:#d4edda; color:#155724; }
        .cancel { background:#f8d7da; color:#721c24; }

        .action-btn {
            padding: 0.4rem 0.8rem;
            border: none;
            border-radius: 6px;
            color: #fff;
            font-weight: 600;
            cursor: pointer;
            transition: 0.2s;
            margin: 2px;
        }

        .accept { background: #28a745; }
        .cancel-btn { background: #dc3545; }
        .checkin { background: #17a2b8; }
        .checkout { background: #ffc107; color:#333; }

        /* ===== DROPDOWN CHUẨN NHƯ PRODUCT ===== */
        .avatar-dropdown { position: relative; display: inline-block; }
        .avatar {
            cursor: pointer;
            display: flex;
            align-items: center;
            gap: 8px;
            padding: 8px 12px;
            border-radius: 8px;
            transition: background-color 0.3s;
        }
        .avatar:hover { background-color: rgba(255,255,255,0.1); }

        .dropdown-menu {
            position: absolute;
            top: 100%; 
            right: 0;
            background: white;
            border-radius: 8px;
            min-width: 200px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.15);
            display: none;
            overflow: hidden;
            z-index: 99999;
        }

        .dropdown-menu.show { display: block; }

        .dropdown-menu a {
            display: flex;
            gap: 10px;
            align-items: center;
            padding: 12px 16px;
            text-decoration: none;
            color: #333;
            transition: background-color 0.3s;
        }

        .dropdown-menu a:hover {
            background-color: #f1f1f1;
        }
    </style>
</head>

<body>

<!-- HEADER -->
<header class="staff-header">
    <div class="user-section">
        <div class="avatar-dropdown">
            <div class="avatar" id="avatarBtn">
                <img src="${pageContext.request.contextPath}/${sessionScope.staff.avatar != null ? sessionScope.staff.avatar : 'images/staff-avatar.png'}"
                     style="width:32px;height:32px;border-radius:50%;object-fit:cover;">
                <span>${sessionScope.staff.name}</span>
                <i class="fas fa-chevron-down"></i>
            </div>

            <div class="dropdown-menu" id="dropdownMenu">
                <a href="${pageContext.request.contextPath}/home.jsp"><i class="fas fa-home"></i> Trang chủ</a>
                <a href="${pageContext.request.contextPath}/staff/edit-profile"><i class="fas fa-user-edit"></i> Chỉnh sửa thông tin</a>
                <a href="${pageContext.request.contextPath}/staff/logout"><i class="fas fa-sign-out-alt"></i> Đăng xuất</a>
            </div>
        </div>
    </div>
</header>

<div class="staff-wrapper">

    <!-- SIDEBAR -->
    <aside class="staff-sidebar">
        <ul>
            <li><a href="${pageContext.request.contextPath}/staff/dashboard.jsp"><i class="fas fa-home"></i> Dashboard</a></li>
            <li><a href="${pageContext.request.contextPath}/staff/viewOrder"><i class="fas fa-receipt"></i> View Orders</a></li>
            <li><a href="${pageContext.request.contextPath}/staff/mySchedule"><i class="fas fa-calendar-alt"></i> My Schedule</a></li>
            <li><a href="${pageContext.request.contextPath}/staff/customer-list"><i class="fas fa-users"></i> Customers</a></li>
            <li><a href="${pageContext.request.contextPath}/staff/services-booking"><i class="fas fa-list"></i> Service Booking</a></li>
            <li><a href="${pageContext.request.contextPath}/staff/products"><i class="fas fa-box"></i> Products</a></li>
            <li><a class="active" href="${pageContext.request.contextPath}/staff/boarding-management.jsp"><i class="fas fa-hotel"></i> Boarding</a></li>
        </ul>
    </aside>

    <!-- MAIN CONTENT -->
    <main class="staff-content">
        <section class="recent-section">
            <h2><i class="fas fa-hotel"></i> Boarding Room Management</h2>
            <p style="color:#666;margin-bottom:1rem;">Quản lý các đơn lưu trú thú cưng 🐾</p>

            <!-- Search -->
            <div class="filter-section">
                <form method="GET">
                    <div class="search-form">
                        <input type="text" name="keyword" class="search-input"
                               placeholder="Tìm theo khách hàng, mã booking..." value="${param.keyword}">
                        <button class="search-btn"><i class="fas fa-search"></i> Tìm kiếm</button>
                    </div>
                </form>
            </div>

            <!-- TABLE -->
            <table>
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Khách hàng</th>
                        <th>Phòng</th>
                        <th>Ngày nhận</th>
                        <th>Ngày trả</th>
                        <th>Tổng tiền</th>
                        <th>Trạng thái</th>
                        <th>Hành động</th>
                    </tr>
                </thead>

                <tbody>
                <c:forEach var="b" items="${bookings}">
                    <tr>
                        <td>#${b.bookingId}</td>
                        <td>${b.customerName}</td>
                        <td>${b.roomType}</td>
                        <td>${b.checkInDate}</td>
                        <td>${b.checkOutDate}</td>
                        <td><fmt:formatNumber value="${b.totalPrice}" type="number" groupingUsed="true"/> ₫</td>

                        <td>
                            <span class="status 
                                ${b.status == 'Chờ xác nhận' ? 'pending' :
                                  b.status == 'Chờ nhận' ? 'waiting' :
                                  b.status == 'Đang sử dụng' ? 'using' :
                                  b.status == 'Đã thanh toán' ? 'paid' : 'cancel'}">
                                ${b.status}
                            </span>
                        </td>

                        <td>
                            <form action="${pageContext.request.contextPath}/boarding-action" method="post">
                                <input type="hidden" name="bookingId" value="${b.bookingId}">

                                <c:choose>

                                    <c:when test="${b.status == 'Chờ xác nhận'}">
                                        <button class="action-btn accept" name="action" value="accept">Chấp nhận</button>
                                        <button class="action-btn cancel-btn" name="action" value="cancel">Hủy</button>
                                    </c:when>

                                    <c:when test="${b.status == 'Chờ nhận'}">
                                        <button class="action-btn checkin" name="action" value="checkin">Check-in</button>
                                    </c:when>

                                    <c:when test="${b.status == 'Đang sử dụng'}">
                                        <button class="action-btn checkout" name="action" value="checkout">Thanh toán</button>
                                    </c:when>

                                    <c:otherwise>
                                        <span style="color:#aaa;">—</span>
                                    </c:otherwise>

                                </c:choose>
                            </form>
                        </td>
                    </tr>
                </c:forEach>

                <c:if test="${empty bookings}">
                    <tr>
                        <td colspan="8" style="padding:1rem;color:#999;">Không có đơn lưu trú nào 🐶</td>
                    </tr>
                </c:if>
                </tbody>
            </table>

        </section>
    </main>
</div>

<!-- DROPDOWN SCRIPT (CHUẨN NHƯ PRODUCT) -->
<script>
document.addEventListener("DOMContentLoaded", function() {
    const avatarBtn = document.getElementById("avatarBtn");
    const dropdownMenu = document.getElementById("dropdownMenu");

    avatarBtn.addEventListener("click", function(event) {
        dropdownMenu.classList.toggle("show");
        event.stopPropagation();
    });

    document.addEventListener("click", function() {
        dropdownMenu.classList.remove("show");
    });
});
</script>

</body>
</html>
