<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Chi tiết đặt lịch - Staff</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <style>
        .status-badge { font-size: 1em; padding: 0.5em 1em; }
        .status-pending { background-color: #ffc107; color: #000; }
        .status-confirmed { background-color: #17a2b8; color: #fff; }
        .status-in_progress { background-color: #007bff; color: #fff; }
        .status-completed { background-color: #28a745; color: #fff; }
        .status-cancelled { background-color: #dc3545; color: #fff; }
        .info-card { border-left: 4px solid #007bff; transition: all 0.3s ease; }
        .info-card:hover { transform: translateY(-2px); box-shadow: 0 4px 15px rgba(0,0,0,0.1); }
        .pet-info { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; border-radius: 15px; padding: 1.5rem; }
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
                            <a class="nav-link" href="${pageContext.request.contextPath}/staff-home">
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
                    <i class="fas fa-calendar-check"></i> Chi tiết đặt lịch #${booking.bookingId}
                </h1>
                <div class="btn-toolbar mb-2 mb-md-0">
                    <a href="${pageContext.request.contextPath}/staff/bookings" class="btn btn-outline-secondary">
                        <i class="fas fa-arrow-left"></i> Quay lại
                    </a>
                </div>
            </div>

            <c:if test="${not empty error}">
                <div class="alert alert-danger alert-dismissible fade show" role="alert">
                    <i class="fas fa-exclamation-circle"></i> ${error}
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            </c:if>

            <c:if test="${not empty booking}">
                <div class="row">
                    <!-- Thông tin cơ bản -->
                    <div class="col-md-8">
                        <div class="card info-card mb-4">
                            <div class="card-header d-flex justify-content-between align-items-center">
                                <h5 class="mb-0">
                                    <i class="fas fa-info-circle"></i> Thông tin đặt lịch
                                </h5>
                                <span class="badge status-badge status-${booking.status}">
                                    ${booking.status}
                                </span>
                            </div>
                            <div class="card-body">
                                <div class="row">
                                    <div class="col-md-6">
                                        <p><strong><i class="fas fa-calendar"></i> Ngày tạo:</strong>
                                            <c:choose>
                                                <c:when test="${not empty booking.createdAt}">
                                                    <fmt:formatDate value="${booking.createdAt}" pattern="dd/MM/yyyy HH:mm"/>
                                                </c:when>
                                                <c:otherwise>—</c:otherwise>
                                            </c:choose>
                                        </p>
                                        <p><strong><i class="fas fa-calendar-day"></i> Bắt đầu:</strong>
                                            <c:choose>
                                                <c:when test="${not empty booking.appointmentStart}">
                                                    <fmt:formatDate value="${booking.appointmentStart}" pattern="dd/MM/yyyy HH:mm"/>
                                                </c:when>
                                                <c:otherwise>—</c:otherwise>
                                            </c:choose>
                                        </p>
                                        <p><strong><i class="fas fa-calendar-day"></i> Kết thúc:</strong>
                                            <c:choose>
                                                <c:when test="${not empty booking.appointmentEnd}">
                                                    <fmt:formatDate value="${booking.appointmentEnd}" pattern="dd/MM/yyyy HH:mm"/>
                                                </c:when>
                                                <c:otherwise>—</c:otherwise>
                                            </c:choose>
                                        </p>
                                    </div>
                                    <div class="col-md-6">
                                        <p><strong><i class="fas fa-user-md"></i> Bác sĩ:</strong>
                                            <c:choose>
                                                <c:when test="${not empty booking.doctorName}">${booking.doctorName}</c:when>
                                                <c:otherwise>Chưa chỉ định</c:otherwise>
                                            </c:choose>
                                        </p>
                                        <p><strong><i class="fas fa-user-tie"></i> Nhân viên phụ trách:</strong>
                                            <c:choose>
                                                <c:when test="${not empty booking.staffName}">${booking.staffName}</c:when>
                                                <c:otherwise>Chưa phân công</c:otherwise>
                                            </c:choose>
                                        </p>

                                        <!-- ⭐ Dịch vụ của booking -->
                                        <p><strong><i class="fas fa-paw"></i> Dịch vụ:</strong>
                                            <c:choose>
                                                <c:when test="${not empty booking.serviceNames}">${booking.serviceNames}</c:when>
                                                <c:otherwise>—</c:otherwise>
                                            </c:choose>
                                        </p>
                                    </div>
                                </div>
                                 <c:if test="${not empty booking.serviceNames}">
  <small class="text-muted"><i class="fas fa-paw"></i> ${booking.serviceNames}</small>
</c:if>

                                <c:if test="${not empty booking.note}">
                                    <hr>
                                    <p><strong><i class="fas fa-sticky-note"></i> Ghi chú:</strong></p>
                                    <p class="text-muted">${booking.note}</p>
                                </c:if>
                            </div>
                        </div>

                        <!-- Thông tin khách hàng -->
                        <div class="card info-card mb-4">
                            <div class="card-header">
                                <h5 class="mb-0">
                                    <i class="fas fa-user"></i> Thông tin khách hàng
                                </h5>
                            </div>
                            <div class="card-body">
                                <div class="row">
                                    <div class="col-md-6">
                                        <p><strong><i class="fas fa-user"></i> Tên:</strong>
                                            <c:choose>
                                                <c:when test="${not empty booking.customerName}">${booking.customerName}</c:when>
                                                <c:otherwise>—</c:otherwise>
                                            </c:choose>
                                        </p>
                                        <p><strong><i class="fas fa-phone"></i> Số điện thoại:</strong>
                                            <c:choose>
                                                <c:when test="${not empty booking.customerPhone}">${booking.customerPhone}</c:when>
                                                <c:otherwise>—</c:otherwise>
                                            </c:choose>
                                        </p>
                                    </div>
                                    <div class="col-md-6">
                                        <p><strong><i class="fas fa-envelope"></i> Email:</strong>
                                            <c:choose>
                                                <c:when test="${not empty booking.customerEmail}">${booking.customerEmail}</c:when>
                                                <c:otherwise>—</c:otherwise>
                                            </c:choose>
                                        </p>
                                        <p><strong><i class="fas fa-id-card"></i> ID khách hàng:</strong>
                                            <c:choose>
                                                <c:when test="${booking.customerId > 0}">${booking.customerId}</c:when>
                                                <c:otherwise>—</c:otherwise>
                                            </c:choose>
                                        </p>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Thông tin thú cưng và hành động -->
                    <div class="col-md-4">
                        <!-- Thông tin thú cưng -->
                        <div class="pet-info mb-4">
                            <h5 class="mb-3"><i class="fas fa-paw"></i> Thông tin thú cưng</h5>
                            <p><strong><i class="fas fa-paw"></i> Tên:</strong>
                                <c:choose>
                                    <c:when test="${not empty booking.petName}">${booking.petName}</c:when>
                                    <c:otherwise>—</c:otherwise>
                                </c:choose>
                            </p>
                            <p><strong><i class="fas fa-tag"></i> Loài:</strong>
                                <c:choose>
                                    <c:when test="${not empty booking.petType}">${booking.petType}</c:when>
                                    <c:otherwise>—</c:otherwise>
                                </c:choose>
                            </p>
                        </div>

                        <!-- Hành động -->
                        <div class="card">
                            <div class="card-header">
                                <h5 class="mb-0"><i class="fas fa-cogs"></i> Hành động</h5>
                            </div>
                            <div class="card-body">
                                <c:choose>
                                    <c:when test="${booking.status == 'pending'}">
                                        <button type="button" class="btn btn-success w-100 mb-2"
                                                onclick="updateStatus('confirmed')">
                                            <i class="fas fa-check"></i> Xác nhận đặt lịch
                                        </button>
                                        <button type="button" class="btn btn-danger w-100"
                                                onclick="updateStatus('cancelled')">
                                            <i class="fas fa-times"></i> Hủy đặt lịch
                                        </button>
                                    </c:when>
                                    <c:when test="${booking.status == 'confirmed'}">
                                        <button type="button" class="btn btn-info w-100 mb-2"
                                                onclick="updateStatus('in_progress')">
                                            <i class="fas fa-play"></i> Bắt đầu dịch vụ
                                        </button>
                                        <button type="button" class="btn btn-danger w-100"
                                                onclick="updateStatus('cancelled')">
                                            <i class="fas fa-times"></i> Hủy đặt lịch
                                        </button>
                                    </c:when>
                                    <c:when test="${booking.status == 'in_progress'}">
                                        <button type="button" class="btn btn-success w-100 mb-2"
                                                onclick="updateStatus('completed')">
                                            <i class="fas fa-check-circle"></i> Hoàn thành
                                        </button>
                                    </c:when>
                                    <c:when test="${booking.status == 'completed'}">
                                        <div class="alert alert-success text-center">
                                            <i class="fas fa-check-circle fa-2x mb-2"></i>
                                            <p class="mb-0">Dịch vụ đã hoàn thành</p>
                                        </div>
                                    </c:when>
                                    <c:when test="${booking.status == 'cancelled'}">
                                        <div class="alert alert-danger text-center">
                                            <i class="fas fa-times-circle fa-2x mb-2"></i>
                                            <p class="mb-0">Đặt lịch đã bị hủy</p>
                                        </div>
                                    </c:when>
                                </c:choose>

                                <hr>

                                <button type="button" class="btn btn-outline-primary w-100 mb-2"
                                        data-bs-toggle="modal" data-bs-target="#assignStaffModal">
                                    <i class="fas fa-user-tie"></i> Phân công nhân viên
                                </button>

                                <button type="button" class="btn btn-outline-secondary w-100"
                                        data-bs-toggle="modal" data-bs-target="#addNoteModal">
                                    <i class="fas fa-sticky-note"></i> Thêm ghi chú
                                </button>
                            </div>
                        </div>
                    </div>
                </div>
            </c:if>
        </main>
    </div>
</div>

<!-- Assign Staff Modal -->
<div class="modal fade" id="assignStaffModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">Phân công nhân viên</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <form method="POST" action="${pageContext.request.contextPath}/staff/bookings">
                <input type="hidden" name="action" value="assign_staff">
                <input type="hidden" name="bookingId" value="${booking.bookingId}">
                <div class="modal-body">
                    <div class="mb-3">
                        <label class="form-label">Chọn nhân viên</label>
                        <select class="form-select" name="staffId" required>
                            <option value="">-- Chọn nhân viên --</option>
                            <!-- TODO: load từ DB -->
                            <option value="1">Nguyễn Văn A</option>
                            <option value="2">Trần Thị B</option>
                            <option value="3">Lê Văn C</option>
                        </select>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Hủy</button>
                    <button type="submit" class="btn btn-primary">Phân công</button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- Add Note Modal -->
<div class="modal fade" id="addNoteModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">Thêm ghi chú</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <form method="POST" action="${pageContext.request.contextPath}/staff/bookings">
                <input type="hidden" name="action" value="add_note">
                <input type="hidden" name="bookingId" value="${booking.bookingId}">
                <div class="modal-body">
                    <div class="mb-3">
                        <label class="form-label">Ghi chú</label>
                        <textarea class="form-control" name="note" rows="4"
                                  placeholder="Nhập ghi chú...">${booking.note}</textarea>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Hủy</button>
                    <button type="submit" class="btn btn-primary">Lưu ghi chú</button>
                </div>
            </form>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
    function updateStatus(status) {
        if (confirm('Bạn có chắc chắn muốn cập nhật trạng thái?')) {
            const form = document.createElement('form');
            form.method = 'POST';
            form.action = '${pageContext.request.contextPath}/staff/bookings';

            form.appendChild(Object.assign(document.createElement('input'), {type:'hidden', name:'action', value:'update_status'}));
            form.appendChild(Object.assign(document.createElement('input'), {type:'hidden', name:'bookingId', value:'${booking.bookingId}'}));
            form.appendChild(Object.assign(document.createElement('input'), {type:'hidden', name:'status', value: status}));

            document.body.appendChild(form);
            form.submit();
        }
    }
</script>
</body>
</html>
