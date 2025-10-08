<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Thống kê đặt lịch - Staff</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        .stats-card {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border-radius: 15px;
            padding: 1.5rem;
            margin-bottom: 1rem;
            transition: transform 0.3s ease;
        }
        
        .stats-card:hover {
            transform: translateY(-5px);
        }
        
        .chart-container {
            background: white;
            border-radius: 15px;
            padding: 1.5rem;
            box-shadow: 0 4px 15px rgba(0,0,0,0.1);
            margin-bottom: 2rem;
        }
        
        .recent-booking {
            border-left: 4px solid #007bff;
            transition: all 0.3s ease;
        }
        
        .recent-booking:hover {
            transform: translateX(5px);
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
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
                                <i class="fas fa-calendar-check"></i> Đặt lịch dịch vụ
                            </a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link active" href="${pageContext.request.contextPath}/staff/bookings?action=stats">
                                <i class="fas fa-chart-bar"></i> Thống kê
                            </a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link" href="${pageContext.request.contextPath}/logout">
                                <i class="fas fa-sign-out-alt"></i> Đăng xuất
                            </a>
                        </li>
                    </ul>
                </div>
            </nav>

            <!-- Main content -->
            <main class="col-md-9 ms-sm-auto col-lg-10 px-md-4">
                <div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pt-3 pb-2 mb-3 border-bottom">
                    <h1 class="h2">
                        <i class="fas fa-chart-bar"></i> Thống kê đặt lịch dịch vụ
                    </h1>
                    <div class="btn-toolbar mb-2 mb-md-0">
                        <a href="${pageContext.request.contextPath}/staff/bookings" class="btn btn-outline-primary">
                            <i class="fas fa-arrow-left"></i> Quay lại danh sách
                        </a>
                    </div>
                </div>

                <!-- Stats Overview -->
                <div class="row mb-4">
                    <c:forEach var="stat" items="${stats}">
                        <div class="col-md-3">
                            <div class="stats-card">
                                <div class="d-flex justify-content-between">
                                    <div>
                                        <h6 class="mb-0">
                                            <c:choose>
                                                <c:when test="${stat.key == 'pending'}">Chờ xử lý</c:when>
                                                <c:when test="${stat.key == 'confirmed'}">Đã xác nhận</c:when>
                                                <c:when test="${stat.key == 'in_progress'}">Đang thực hiện</c:when>
                                                <c:when test="${stat.key == 'completed'}">Hoàn thành</c:when>
                                                <c:when test="${stat.key == 'cancelled'}">Đã hủy</c:when>
                                                <c:otherwise>${stat.key}</c:otherwise>
                                            </c:choose>
                                        </h6>
                                        <h3 class="mb-0">${stat.value}</h3>
                                    </div>
                                    <div class="align-self-center">
                                        <c:choose>
                                            <c:when test="${stat.key == 'pending'}">
                                                <i class="fas fa-clock fa-2x"></i>
                                            </c:when>
                                            <c:when test="${stat.key == 'confirmed'}">
                                                <i class="fas fa-check fa-2x"></i>
                                            </c:when>
                                            <c:when test="${stat.key == 'in_progress'}">
                                                <i class="fas fa-play fa-2x"></i>
                                            </c:when>
                                            <c:when test="${stat.key == 'completed'}">
                                                <i class="fas fa-check-circle fa-2x"></i>
                                            </c:when>
                                            <c:when test="${stat.key == 'cancelled'}">
                                                <i class="fas fa-times-circle fa-2x"></i>
                                            </c:when>
                                            <c:otherwise>
                                                <i class="fas fa-calendar fa-2x"></i>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </c:forEach>
                </div>

                <div class="row">
                    <!-- Chart Section -->
                    <div class="col-md-8">
                        <div class="chart-container">
                            <h5 class="mb-3">
                                <i class="fas fa-chart-pie"></i> Phân bố trạng thái đặt lịch
                            </h5>
                            <canvas id="statusChart" width="400" height="200"></canvas>
                        </div>
                    </div>

                    <!-- Quick Actions -->
                    <div class="col-md-4">
                        <div class="card">
                            <div class="card-header">
                                <h5 class="mb-0">
                                    <i class="fas fa-bolt"></i> Hành động nhanh
                                </h5>
                            </div>
                            <div class="card-body">
                                <div class="d-grid gap-2">
                                    <a href="${pageContext.request.contextPath}/staff/bookings?action=filter&status=pending" 
                                       class="btn btn-warning">
                                        <i class="fas fa-clock"></i> Xem đặt lịch chờ xử lý
                                    </a>
                                    <a href="${pageContext.request.contextPath}/staff/bookings?action=filter&status=in_progress" 
                                       class="btn btn-info">
                                        <i class="fas fa-play"></i> Xem đặt lịch đang thực hiện
                                    </a>
                                    <a href="${pageContext.request.contextPath}/staff/bookings?action=filter&status=completed" 
                                       class="btn btn-success">
                                        <i class="fas fa-check-circle"></i> Xem đặt lịch hoàn thành
                                    </a>
                                    <a href="${pageContext.request.contextPath}/staff/bookings" 
                                       class="btn btn-primary">
                                        <i class="fas fa-list"></i> Xem tất cả đặt lịch
                                    </a>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Recent Bookings -->
                <c:if test="${not empty recentBookings}">
                    <div class="row mt-4">
                        <div class="col-12">
                            <div class="card">
                                <div class="card-header">
                                    <h5 class="mb-0">
                                        <i class="fas fa-history"></i> Đặt lịch gần đây
                                    </h5>
                                </div>
                                <div class="card-body">
                                    <div class="row">
                                        <c:forEach var="booking" items="${recentBookings}">
                                            <div class="col-md-6 col-lg-4 mb-3">
                                                <div class="card recent-booking">
                                                    <div class="card-body">
                                                        <div class="d-flex justify-content-between align-items-start mb-2">
                                                            <h6 class="card-title mb-0">#${booking.bookingId}</h6>
                                                            <span class="badge bg-${booking.status == 'pending' ? 'warning' : 
                                                                                booking.status == 'confirmed' ? 'info' : 
                                                                                booking.status == 'in_progress' ? 'primary' : 
                                                                                booking.status == 'completed' ? 'success' : 'danger'}">
                                                                ${booking.status}
                                                            </span>
                                                        </div>
                                                        <p class="card-text">
                                                            <strong>${booking.customerName}</strong><br>
                                                            <small class="text-muted">
                                                                <i class="fas fa-paw"></i> ${booking.serviceType}<br>
                                                                <i class="fas fa-calendar"></i> 
                                                                <fmt:formatDate value="${booking.serviceDate}" pattern="dd/MM/yyyy"/>
                                                            </small>
                                                        </p>
                                                        <a href="${pageContext.request.contextPath}/staff/bookings?action=view&id=${booking.bookingId}" 
                                                           class="btn btn-outline-primary btn-sm">
                                                            <i class="fas fa-eye"></i> Xem chi tiết
                                                        </a>
                                                    </div>
                                                </div>
                                            </div>
                                        </c:forEach>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </c:if>
            </main>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Status Chart
        const ctx = document.getElementById('statusChart').getContext('2d');
        const statusData = {
            <c:forEach var="stat" items="${stats}" varStatus="loop">
                '<c:choose>
                    <c:when test="${stat.key == 'pending'}">Chờ xử lý</c:when>
                    <c:when test="${stat.key == 'confirmed'}">Đã xác nhận</c:when>
                    <c:when test="${stat.key == 'in_progress'}">Đang thực hiện</c:when>
                    <c:when test="${stat.key == 'completed'}">Hoàn thành</c:when>
                    <c:when test="${stat.key == 'cancelled'}">Đã hủy</c:when>
                    <c:otherwise>${stat.key}</c:otherwise>
                </c:choose>': ${stat.value}<c:if test="${!loop.last}">,</c:if>
            </c:forEach>
        };

        const statusChart = new Chart(ctx, {
            type: 'doughnut',
            data: {
                labels: Object.keys(statusData),
                datasets: [{
                    data: Object.values(statusData),
                    backgroundColor: [
                        '#ffc107', // pending - warning
                        '#17a2b8', // confirmed - info
                        '#007bff', // in_progress - primary
                        '#28a745', // completed - success
                        '#dc3545'  // cancelled - danger
                    ],
                    borderWidth: 2,
                    borderColor: '#fff'
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: {
                        position: 'bottom',
                        labels: {
                            padding: 20,
                            usePointStyle: true
                        }
                    },
                    tooltip: {
                        callbacks: {
                            label: function(context) {
                                const total = Object.values(statusData).reduce((a, b) => a + b, 0);
                                const percentage = ((context.parsed / total) * 100).toFixed(1);
                                return context.label + ': ' + context.parsed + ' (' + percentage + '%)';
                            }
                        }
                    }
                }
            }
        });
    </script>
</body>
</html>
