<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản lý đặt lịch dịch vụ - Staff</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <style>
        .status-badge {
            font-size: 0.8em;
            padding: 0.4em 0.8em;
        }
        .status-scheduled { background-color: #17a2b8; color: #fff; }
        .status-completed { background-color: #28a745; color: #fff; }
        .status-cancelled { background-color: #dc3545; color: #fff; }
        
        
        .booking-card {
            border-left: 4px solid #007bff;
            transition: all 0.3s ease;
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
                            <a class="nav-link active" href="${pageContext.request.contextPath}/staff/bookings">
                                <i class="fas fa-calendar-check"></i> Xem đặt lịch dịch vụ
                            </a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link" href="${pageContext.request.contextPath}/staff/customers">
                                <i class="fas fa-users"></i> Xem thông tin khách hàng
                            </a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link" href="${pageContext.request.contextPath}/staff/products">
                                <i class="fas fa-box"></i> Xem tất cả sản phẩm
                            </a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link" href="${pageContext.request.contextPath}/home">
                                <i class="fas fa-home"></i> Quay lại trang home
                            </a>
                        </li>
                    </ul>
                </div>
            </nav>

            <!-- Main content -->
            <main class="col-md-9 ms-sm-auto col-lg-10 px-md-4">
                <div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pt-3 pb-2 mb-3 border-bottom">
                    <h1 class="h2">
                        <i class="fas fa-calendar-check"></i> Quản lý đặt lịch dịch vụ
                    </h1>
                    <div class="btn-toolbar mb-2 mb-md-0">
                        <button type="button" class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#filterModal">
                            <i class="fas fa-filter"></i> Lọc
                        </button>
                    </div>
                </div>

                <!-- Alerts -->
                <c:if test="${not empty success}">
                    <div class="alert alert-success alert-dismissible fade show" role="alert">
                        <i class="fas fa-check-circle"></i> ${success}
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                </c:if>
                
                <c:if test="${not empty error}">
                    <div class="alert alert-danger alert-dismissible fade show" role="alert">
                        <i class="fas fa-exclamation-circle"></i> ${error}
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                </c:if>


                <!-- Search and Filter -->
                <div class="filter-section">
                    <form method="GET" action="${pageContext.request.contextPath}/staff/bookings">
                        <input type="hidden" name="action" value="search">
                        <div class="row">
                            <div class="col-md-6">
                                <div class="input-group">
                                    <input type="text" class="form-control" name="keyword" 
                                           placeholder="Tìm kiếm theo tên, SĐT, email, loại dịch vụ..." 
                                           value="${keyword}">
                                    <button class="btn btn-outline-primary" type="submit">
                                        <i class="fas fa-search"></i>
                                    </button>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="btn-group" role="group">
                                    <a href="${pageContext.request.contextPath}/staff/bookings" class="btn btn-outline-secondary">
                                        <i class="fas fa-list"></i> Tất cả
                                    </a>
                                    <a href="${pageContext.request.contextPath}/staff/bookings?action=filter&status=pending" class="btn btn-outline-warning">
                                        <i class="fas fa-clock"></i> Chờ xử lý
                                    </a>
                                    <a href="${pageContext.request.contextPath}/staff/bookings?action=filter&status=confirmed" class="btn btn-outline-info">
                                        <i class="fas fa-check"></i> Đã xác nhận
                                    </a>
                                    <a href="${pageContext.request.contextPath}/staff/bookings?action=filter&status=completed" class="btn btn-outline-success">
                                        <i class="fas fa-check-circle"></i> Hoàn thành
                                    </a>
                                </div>
                            </div>
                        </div>
                    </form>
                </div>

                <!-- Bookings List -->
                <div class="row">
                    <c:choose>
                        <c:when test="${not empty bookings}">
                            <c:forEach var="booking" items="${bookings}">
                                <div class="col-md-6 col-lg-4 mb-4">
                                    <div class="card booking-card h-100">
                                        <div class="card-header d-flex justify-content-between align-items-center">
                                            <h6 class="mb-0">
                                                <i class="fas fa-calendar"></i> #${booking.bookingId}
                                            </h6>
                                            <span class="badge status-badge status-${booking.status}">
                                                ${booking.status}
                                            </span>
                                        </div>
                                        <div class="card-body">
                                            <h6 class="card-title">
                                                <i class="fas fa-user"></i> ${booking.customerName}
                                            </h6>
                                            <p class="card-text">
                                                <c:if test="${not empty booking.note}">
                                                    <strong><i class="fas fa-concierge-bell"></i> Dịch vụ:</strong> 
                                                    <span class="text-primary">${booking.note}</span><br>
                                                </c:if>
                                                <c:if test="${not empty booking.serviceNames}">
                                                    <strong><i class="fas fa-list"></i> Dịch vụ:</strong> 
                                                    <span class="text-info">${booking.serviceNames}</span><br>
                                                </c:if>
                                                <strong><i class="fas fa-pet"></i> Thú cưng:</strong> ${booking.petName} (${booking.petType})<br>
                                                <strong><i class="fas fa-calendar-day"></i> Bắt đầu:</strong> 
                                                <fmt:formatDate value="${booking.appointmentStart}" pattern="dd/MM/yyyy HH:mm"/><br>
                                                <strong><i class="fas fa-calendar-day"></i> Kết thúc:</strong> 
                                                <fmt:formatDate value="${booking.appointmentEnd}" pattern="dd/MM/yyyy HH:mm"/><br>
                                                <strong><i class="fas fa-user-md"></i> Nhân viên:</strong> 
                                                ${booking.staffName != null ? booking.staffName : 'Chưa phân công'}
                                            </p>
                                        </div>
                                        <div class="card-footer">
                                            <div class="btn-group w-100" role="group">
                                                <a href="${pageContext.request.contextPath}/staff/bookings?action=view&id=${booking.bookingId}" 
                                                   class="btn btn-outline-primary btn-sm">
                                                    <i class="fas fa-eye"></i> Xem
                                                </a>
                                                <c:if test="${booking.status == 'pending'}">
                                                    <button type="button" class="btn btn-outline-success btn-sm" 
                                                            onclick="updateStatus(${booking.bookingId}, 'confirmed')">
                                                        <i class="fas fa-check"></i> Xác nhận
                                                    </button>
                                                </c:if>
                                                <c:if test="${booking.status == 'confirmed'}">
                                                    <button type="button" class="btn btn-outline-info btn-sm" 
                                                            onclick="updateStatus(${booking.bookingId}, 'in_progress')">
                                                        <i class="fas fa-play"></i> Bắt đầu
                                                    </button>
                                                </c:if>
                                                <c:if test="${booking.status == 'in_progress'}">
                                                    <button type="button" class="btn btn-outline-success btn-sm" 
                                                            onclick="updateStatus(${booking.bookingId}, 'completed')">
                                                        <i class="fas fa-check-circle"></i> Hoàn thành
                                                    </button>
                                                </c:if>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </c:forEach>
                        </c:when>
                        <c:otherwise>
                            <div class="col-12">
                                <div class="text-center py-5">
                                    <i class="fas fa-calendar-times fa-3x text-muted mb-3"></i>
                                    <h4 class="text-muted">Không có đặt lịch nào</h4>
                                    <p class="text-muted">Chưa có đặt lịch dịch vụ nào được tìm thấy.</p>
                                </div>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>

                <!-- Pagination -->
                <c:if test="${totalPages > 1}">
                    <nav aria-label="Page navigation">
                        <ul class="pagination justify-content-center">
                            <c:if test="${currentPage > 1}">
                                <li class="page-item">
                                    <a class="page-link" href="?page=${currentPage - 1}">Trước</a>
                                </li>
                            </c:if>
                            
                            <c:forEach begin="1" end="${totalPages}" var="i">
                                <li class="page-item ${i == currentPage ? 'active' : ''}">
                                    <a class="page-link" href="?page=${i}">${i}</a>
                                </li>
                            </c:forEach>
                            
                            <c:if test="${currentPage < totalPages}">
                                <li class="page-item">
                                    <a class="page-link" href="?page=${currentPage + 1}">Sau</a>
                                </li>
                            </c:if>
                        </ul>
                    </nav>
                </c:if>
            </main>
        </div>
    </div>

    <!-- Filter Modal -->
    <div class="modal fade" id="filterModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">Lọc đặt lịch</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <form method="GET" action="${pageContext.request.contextPath}/staff/bookings">
                    <input type="hidden" name="action" value="filter">
                    <div class="modal-body">
                        <div class="mb-3">
                            <label class="form-label">Trạng thái</label>
                            <select class="form-select" name="status">
                                <option value="">Tất cả trạng thái</option>
                                <option value="pending" ${selectedStatus == 'pending' ? 'selected' : ''}>Chờ xử lý</option>
                                <option value="confirmed" ${selectedStatus == 'confirmed' ? 'selected' : ''}>Đã xác nhận</option>
                                <option value="in_progress" ${selectedStatus == 'in_progress' ? 'selected' : ''}>Đang thực hiện</option>
                                <option value="completed" ${selectedStatus == 'completed' ? 'selected' : ''}>Hoàn thành</option>
                                <option value="cancelled" ${selectedStatus == 'cancelled' ? 'selected' : ''}>Đã hủy</option>
                            </select>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Từ ngày</label>
                            <input type="date" class="form-control" name="dateFrom" value="${selectedDateFrom}">
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Đến ngày</label>
                            <input type="date" class="form-control" name="dateTo" value="${selectedDateTo}">
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Hủy</button>
                        <button type="submit" class="btn btn-primary">Lọc</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
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
    </script>
</body>
</html>
