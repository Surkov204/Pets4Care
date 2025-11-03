<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>🐾 Staff Dashboard | Pet4Care</title>
        <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
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

            /* Clickable Cards */
            .dashboard-card {
                cursor: pointer;
                transition: transform 0.3s ease, box-shadow 0.3s ease;
            }

            .dashboard-card:hover {
                transform: translateY(-5px);
                box-shadow: 0 8px 25px rgba(0, 0, 0, 0.15);
            }
            .notification-icon {
                position: relative;
                display: inline-block;
                margin-right: 15px;
                cursor: pointer;
                color: #fff;
                font-size: 18px;
            }

            .notification-icon i:hover {
                color: #ffd369;
                transition: 0.3s;
            }

            .chat-badge {
                position: absolute;
                top: -5px;
                right: -5px;
                background: #ff5252;
                color: #fff;
                border-radius: 50%;
                font-size: 11px;
                width: 18px;
                height: 18px;
                display: flex;
                align-items: center;
                justify-content: center;
            }
            #notifyPopup {
                position: absolute;
                top: 60px;           /* 👈 canh ngay dưới header */
                right: 80px;         /* 👈 nằm ngay dưới chuông */
                background: #fff;
                border-radius: 12px;
                box-shadow: 0 4px 16px rgba(0, 0, 0, 0.2);
                min-width: 320px;
                z-index: 2000;
                padding: 0;
                display: none;
            }

            #notifyPopup.show {
                display: block !important;
                animation: fadeIn 0.2s ease-in-out;
            }

            /* hiệu ứng mở popup */
            @keyframes fadeIn {
                from {
                    opacity: 0;
                    transform: translateY(-10px);
                }
                to {
                    opacity: 1;
                    transform: translateY(0);
                }
            }

            /* từng thông báo */
            #notifyList > div {
                background: #fff;
                border-bottom: 1px solid #eee;
                padding: 10px 14px;
                font-size: 14px;
                transition: background 0.2s;
            }

            #notifyList > div:hover {
                background: #f9fafb;
            }

            #notifyList {
                color: #222; /* 👈 Chữ đậm, dễ đọc trên nền trắng */
            }
            .attendance-section {
                display: flex;
                flex-wrap: wrap;
                gap: 24px;
                margin-top: 25px;
            }

            .attendance-card, .salary-card {
                flex: 1;
                background: #fff;
                border-radius: 16px;
                box-shadow: 0 4px 16px rgba(0, 0, 0, 0.05);
                padding: 20px 25px;
                transition: all 0.3s ease;
            }

            .attendance-card:hover, .salary-card:hover {
                transform: translateY(-3px);
                box-shadow: 0 6px 18px rgba(0, 0, 0, 0.08);
            }

            .attendance-card h3, .salary-card h3 {
                color: #334155;
                font-weight: 600;
                margin-bottom: 10px;
            }

            .attendance-subtext {
                color: #64748b;
                font-size: 13px;
                margin-bottom: 15px;
            }

            .attendance-actions {
                margin-bottom: 10px;
            }

            .btn-checkin, .btn-checkout, .btn-calc-salary {
                border: none;
                border-radius: 8px;
                font-weight: 600;
                cursor: pointer;
                padding: 10px 20px;
                transition: all 0.3s ease;
            }

            .btn-checkin {
                background: #22c55e;
                color: #fff;
            }

            .btn-checkin:hover {
                background: #16a34a;
            }

            .btn-checkout {
                background: #ef4444;
                color: #fff;
            }

            .btn-checkout:hover {
                background: #dc2626;
            }

            .salary-header {
                display: flex;
                align-items: center;
                justify-content: space-between;
                margin-bottom: 15px;
            }

            .btn-calc-salary {
                background: #3b82f6;
                color: #fff;
                font-size: 13px;
            }

            .btn-calc-salary:hover {
                background: #2563eb;
            }

            .salary-table {
                width: 100%;
                border-collapse: collapse;
                text-align: center;
            }

            .salary-table th {
                background: #f1f5f9;
                color: #475569;
                padding: 10px;
                font-weight: 600;
            }

            .salary-table td {
                padding: 10px;
                border-top: 1px solid #e2e8f0;
                color: #334155;
                font-size: 14px;
            }

            .salary-table .empty-msg {
                color: #94a3b8;
                font-style: italic;
                text-align: center;
            }

            .attendance-toast {
                margin-top: 15px;
                background: #dcfce7;
                color: #166534;
                padding: 10px 14px;
                border-radius: 10px;
                text-align: center;
                font-weight: 500;
            }

            /* ============ SMART TOGGLE ATTENDANCE BUTTON ============ */
            .btn-toggle {
                width: 80%;
                font-size: 20px;
                padding: 16px 0;
                border: none;
                border-radius: 50px;
                cursor: pointer;
                font-weight: 700;
                transition: all 0.3s ease;
                color: #fff;
                background: linear-gradient(135deg, #22c55e, #16a34a);
                box-shadow: 0 6px 15px rgba(34,197,94,0.4);
            }

            .btn-toggle:hover {
                transform: scale(1.03);
            }

            .attendance-card form[action$="toggle"] .btn-toggle:has(+ input[value="checkout"]),
            .btn-toggle.checkout {
                background: linear-gradient(135deg, #ef4444, #dc2626);
                box-shadow: 0 6px 15px rgba(239,68,68,0.4);
            }

            /* Card styling giữ nguyên */
            .attendance-card {
                flex: 1;
                background: #fff;
                border-radius: 16px;
                box-shadow: 0 4px 16px rgba(0, 0, 0, 0.05);
                padding: 30px 25px;
                text-align: center;
                transition: all 0.3s ease;
            }

            .attendance-card:hover {
                transform: translateY(-3px);
            }

            .attendance-card h3 {
                color: #334155;
                font-weight: 600;
                margin-bottom: 10px;
            }

            .attendance-subtext {
                color: #64748b;
                font-size: 14px;
                margin-bottom: 20px;
            }
            .btn-checkin {
                background: linear-gradient(135deg, #22c55e, #16a34a);
                color: #fff;
                font-size: 18px;
                padding: 14px 40px;
                border: none;
                border-radius: 40px;
                cursor: pointer;
                transition: 0.3s ease;
                box-shadow: 0 5px 12px rgba(34,197,94,0.4);
            }
            .btn-checkin:hover {
                background: linear-gradient(135deg, #16a34a, #15803d);
                transform: scale(1.03);
            }

            .btn-checkout {
                background: linear-gradient(135deg, #facc15, #eab308);
                color: #333;
                font-size: 18px;
                padding: 14px 40px;
                border: none;
                border-radius: 40px;
                cursor: pointer;
                transition: 0.3s ease;
                box-shadow: 0 5px 12px rgba(250,204,21,0.4);
            }
            .btn-checkout:hover {
                background: linear-gradient(135deg, #eab308, #ca8a04);
                transform: scale(1.03);
            }
        </style>
    </head>
    <body>
        <% System.out.println("[JSP DEBUG] sessionScope.isCheckedIn = " + session.getAttribute("isCheckedIn"));%>
        <header class="staff-header">
            <c:if test="${not empty sessionScope.swapSuccess}">
                <div style="background:#d1fae5;color:#065f46;padding:10px;border-radius:10px;margin:10px 0;">
                    ${sessionScope.swapSuccess}
                </div>
                <c:remove var="swapSuccess" scope="session"/>
            </c:if>
            <div class="user-section">
                <!-- 🔔 Notification Bell -->
                <div class="notification-icon" onclick="toggleNotifications()">
                    <i class="fas fa-bell"></i>
                    <span id="notifyBadge" class="chat-badge" style="display:none;">0</span>
                </div>

                <!-- Dropdown thông báo -->
                <div id="notifyPopup" class="dropdown-menu" style="right: 60px;">
                    <div id="notifyList" style="max-height:300px;overflow-y:auto;padding:10px;">
                        <p style="color:#666;text-align:center;">Chưa có thông báo</p>
                    </div>
                </div>
                <div class="avatar-dropdown">
                    <div class="avatar" onclick="toggleDropdown()">
                        <img src="${pageContext.request.contextPath}/${sessionScope.staff.avatar != null ? sessionScope.staff.avatar : 'images/staff-avatar.png'}" 
                             alt="Staff"
                             style="width:32px; height:32px; border-radius:50%; object-fit:cover;">
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
                    <li><a href="${pageContext.request.contextPath}/staff/mySchedule"><i class="fas fa-calendar-alt"></i> My Work Schedule</a></li>
                    <li><a href="${pageContext.request.contextPath}/staff/customer-list"><i class="fas fa-users"></i> Customer Profile</a></li>
                    <li><a href="${pageContext.request.contextPath}/staff/services-booking"><i class="fas fa-list"></i> Services Booking</a></li>
                    <li class="chat-item">
                        <a href="${pageContext.request.contextPath}/staff/chatCustomer" id="chatMenuItem">
                            <i class="fas fa-comments"></i> Chat with Customer
                            <span id="chatBadge" class="chat-badge">3</span>
                        </a>
                    </li>

                    <li><a href="${pageContext.request.contextPath}/staff/products"><i class="fas fa-box"></i> View Product</a></li>
            </aside>

            <!-- Content -->
            <main class="staff-content">
                <section class="welcome-card">
                    <h2>Chào mừng trở lại, ${sessionScope.staff.name} 🐾</h2>
                    <p>Chúc bạn một ngày làm việc vui vẻ cùng thú cưng nhé!</p>
                </section>
                <!-- Attendance & Payroll Section -->
                <section class="attendance-section">
                    <!-- Card bên trái: Check-in / Check-out -->
                    <div class="attendance-card">
                        <h3><i class="fas fa-clock"></i> Chấm công</h3>

                        <form id="attendanceForm">
                            <c:choose>
                                <c:when test="${isCheckedIn}">
                                    <button type="button" id="attendanceButton" class="btn-checkout">Check-out</button>
                                    <p id="attendanceStatus" class="attendance-subtext">Bạn đang trong ca làm.</p>
                                </c:when>
                                <c:otherwise>
                                    <button type="button" id="attendanceButton" class="btn-checkin">Check-in</button>
                                    <p id="attendanceStatus" class="attendance-subtext">Bạn chưa bắt đầu ca làm.</p>
                                </c:otherwise>
                            </c:choose>
                        </form>
                    </div>

                    <!-- Card bên phải: Bảng lương -->
                    <div class="salary-card">
                        <div class="salary-header">
                            <h3><i class="fas fa-coins"></i> Lương hiện tại</h3>
                            <button type="button" id="generatePayrollBtn" class="btn-calc-salary">
                                <i class="fas fa-calculator"></i> Tính lương tháng này
                            </button>
                        </div>

                        <table class="salary-table">
                            <thead>
                                <tr>
                                    <th>Tháng</th>
                                    <th>Tổng giờ</th>
                                    <th>Lương/Giờ (₫)</th>
                                    <th>Tổng Lương (₫)</th>
                                    <th>Ngày Tạo</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:if test="${not empty sessionScope.latestPayroll}">
                                    <tr>
                                        <td>${sessionScope.latestPayroll.periodStart} → ${sessionScope.latestPayroll.periodEnd}</td>
                                        <td>${sessionScope.latestPayroll.totalHours}</td>
                                        <td>${sessionScope.latestPayroll.hourlyRate}</td>
                                        <td><b>${sessionScope.latestPayroll.totalSalary}</b></td>
                                        <td>${sessionScope.latestPayroll.createdAt}</td>
                                    </tr>
                                </c:if>
                                <c:if test="${empty sessionScope.latestPayroll}">
                                    <tr><td colspan="5" class="empty-msg">Chưa có dữ liệu lương.</td></tr>
                                </c:if>
                            </tbody>
                        </table>
                    </div>
                </section>

                <c:if test="${not empty sessionScope.attendanceMsg}">
                    <div class="attendance-toast">${sessionScope.attendanceMsg}</div>
                    <c:remove var="attendanceMsg" scope="session"/>
                </c:if>

                <section class="cards-grid">
                    <div class="dashboard-card" onclick="window.location.href = '${pageContext.request.contextPath}/staff/viewOrder'">
                        <i class="fas fa-receipt"></i>
                        <h3>Orders</h3>
                        <p>${orderCount} đơn hàng đang xử lý</p>
                    </div>
                    <div class="dashboard-card" onclick="window.location.href = '${pageContext.request.contextPath}/staff/services-booking'">
                        <i class="fas fa-list"></i>
                        <h3>Bookings</h3>
                        <p>${bookingCount} dịch vụ đặt lịch</p>
                    </div>
                    <div class="dashboard-card">
                        <i class="fas fa-calendar-alt"></i>
                        <h3>Work Schedule</h3>
                        <p>${todayShift}</p>
                    </div>
                    <div class="dashboard-card" onclick="window.location.href = '${pageContext.request.contextPath}/staff/customer-list'">
                        <i class="fas fa-user"></i>
                        <h3>Customers</h3>
                        <p>${customerCount} khách đang hoạt động</p>
                    </div>
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
            document.addEventListener('click', function (event) {
                const dropdown = document.getElementById('dropdownMenu');
                const avatar = document.querySelector('.avatar');
                if (!avatar.contains(event.target)) {
                    dropdown.classList.remove('show');
                }
            });
            function updateChatBadge() {
                fetch("${pageContext.request.contextPath}/chat?action=getUnread")
                        .then(res => {
                            if (!res.ok)
                                throw new Error('Network response was not ok');
                            return res.json();
                        })
                        .then(data => {
                            const badge = document.getElementById("chatBadge");
                            if (!badge)
                                return;
                            const count = data.unread || 0;
                            badge.textContent = count > 9 ? "9+" : count;
                            badge.style.display = count > 0 ? "flex" : "none";
                        })
                        .catch(err => {
                            console.error("⚠️ Lỗi load badge:", err);
                            const badge = document.getElementById("chatBadge");
                            if (badge)
                                badge.style.display = "none";
                        });
            }

            function updateNotifyBadge() {
                fetch("${pageContext.request.contextPath}/notification?action=count")
                        .then(res => res.json())
                        .then(data => {
                            const badge = document.getElementById("notifyBadge");
                            const count = data.count || 0;
                            badge.textContent = count > 9 ? "9+" : count;
                            badge.style.display = count > 0 ? "flex" : "none";
                        })
                        .catch(console.error);
            }
            function toggleNotifications() {
                const popup = document.getElementById("notifyPopup");
                popup.classList.toggle("show");

                if (popup.classList.contains("show")) {
                    // Gọi API lấy danh sách thông báo
                    fetch("${pageContext.request.contextPath}/notification?action=list")
                            .then(res => res.json())
                            .then(list => {
                                const container = document.getElementById("notifyList");
                                if (!list || list.length === 0) {
                                    container.innerHTML = "<p style='text-align:center;color:#888;'>Không có thông báo mới.</p>";
                                    // Cập nhật lại badge (nếu cần)
                                    updateNotifyBadge();
                                    return;
                                }

                                container.innerHTML = list.map(function (n) {
                                    // Định dạng thời gian cho dễ đọc
                                    const time = n.createdAt ? new Date(n.createdAt).toLocaleString('vi-VN', {
                                        day: '2-digit', month: '2-digit', year: 'numeric',
                                        hour: '2-digit', minute: '2-digit'
                                    }) : "";

                                    let actionButtons = '';

                                    // 👉 LOGIC HIỂN THỊ NÚT CHẤP NHẬN/TỪ CHỐI
                                    // Dựa trên hình ảnh, ta dùng tiêu đề "Yêu cầu đổi ca mới" để nhận diện
                                    // (Tốt nhất là dùng một trường 'type' hoặc 'status' từ API, nhưng ta tạm dùng 'title')

                                    if (n.title === 'Yêu cầu đổi ca mới' || n.title === 'Yêu cầu làm thay') {
                                        actionButtons = `
                                                <div style="display:flex; gap:10px; margin-top:10px;">
                                                    <form action="${pageContext.request.contextPath}/staff/acceptShiftRequest" method="post" style="margin:0;">
                                                        <input type="hidden" name="requestId" value="${'$'}{n.id}">
                                                        <input type="hidden" name="notificationId" value="${n.notificationID}">
                                                        <button type="submit" style="background:#28a745; color:#fff; border:none; padding:5px 10px; border-radius:5px; cursor:pointer; font-size:12px;">
                                                            Chấp nhận
                                                        </button>
                                                    </form>
                                                    <form action="${pageContext.request.contextPath}/staff/rejectShiftRequest" method="post" style="margin:0;">
                                                        <input type="hidden" name="requestId" value="${'$'}{n.id}">
                                                        <button type="submit" style="background:#dc3545; color:#fff; border:none; padding:5px 10px; border-radius:5px; cursor:pointer; font-size:12px;">
                                                            Từ chối
                                                        </button>
                                                    </form>
                                                </div>
                                            `;
                                    }

                                    return ''
                                            + '<div style="padding:10px 14px;border-bottom:1px solid #eee;">'
                                            + '<strong>' + (n.title || 'Thông báo') + '</strong><br>'
                                            + '<small>' + (n.message || '') + '</small><br>'
                                            + '<span style="color:#999;font-size:0.8em;">' + time + '</span>'
                                            + actionButtons // THÊM NÚT HÀNH ĐỘNG VÀO ĐÂY
                                            + '</div>';
                                }).join('');

                                // Sau khi hiển thị, hãy gọi API để đánh dấu tất cả thông báo là đã đọc
                                fetch("${pageContext.request.contextPath}/notification?action=markAllRead").then(updateNotifyBadge);

                            })
                            .catch(err => {
                                console.error("Lỗi khi tải thông báo:", err);
                                document.getElementById("notifyList").innerHTML = "<p style='text-align:center;color:#dc3545;'>Lỗi tải thông báo.</p>";
                            });
                }
            }
            document.addEventListener("submit", function (e) {
                const form = e.target;
                if (form.action.includes("acceptShiftRequest") || form.action.includes("rejectShiftRequest")) {
                    e.preventDefault();
                    const formData = new FormData(form);
                    const parentDiv = form.closest("div");

                    fetch(form.action, {method: "POST", body: formData})
                            .then(res => {
                                if (!res.ok)
                                    throw new Error("Network error");
                                parentDiv.innerHTML = `<p style="color:#28a745;font-size:13px;">✅ Cảm ơn bạn! Phản hồi đã được gửi.</p>`;
                                updateNotifyBadge();
                            })
                            .catch(err => console.error("❌ Lỗi gửi phản hồi:", err));
                }
            });
            document.addEventListener("DOMContentLoaded", () => {
                const btn = document.getElementById("attendanceButton");
                const generateBtn = document.getElementById("generatePayrollBtn");
                
                async function verifyCompanyNetwork() {
                    try {
                        const res = await fetch("${pageContext.request.contextPath}/staff/verifyNetwork");
                        const data = await res.json();

                        if (data.isCompanyNetwork)
                            return true;

                        Swal.fire({
                            icon: "warning",
                            title: "Sai Wi-Fi!",
                            text: "Vui lòng kết nối với Wi-Fi công ty 'Dung' trước khi check-in/check-out.",
                            confirmButtonText: "OK"
                        });
                        return false;
                    } catch (err) {
                        Swal.fire({
                            icon: "error",
                            title: "Không xác định được mạng!",
                            text: "Hãy thử lại khi có kết nối Internet ổn định.",
                            confirmButtonText: "OK"
                        });
                        return false;
                    }
                }

                btn.addEventListener("click", async () => {
                        const inCompanyWifi = await verifyCompanyNetwork();
                        if (!inCompanyWifi) return; // ❌ dừng nếu sai Wi-Fi{
                        
                    try {
                        const formData = new URLSearchParams();
                        formData.append("action", "toggle");

                        const res = await fetch("${pageContext.request.contextPath}/staff/attendance", {
                            method: "POST",
                            headers: {"Content-Type": "application/x-www-form-urlencoded"},
                            body: formData.toString()
                        });

                        const data = await res.json();

                        if (data.status === "error") {
                            Swal.fire({
                                icon: "warning",
                                title: "Thông báo",
                                text: data.message,
                                confirmButtonText: "OK"
                            });
                        } else {
                            Swal.fire({
                                icon: "success",
                                title: "Thành công!",
                                text: data.message,
                                confirmButtonText: "OK"
                            }).then(() => {
                                const btn = document.getElementById("attendanceButton");
                                const status = document.getElementById("attendanceStatus");

                                if (btn.classList.contains("btn-checkin")) {
                                    // Đổi từ check-in sang check-out (xanh → vàng)
                                    btn.classList.remove("btn-checkin");
                                    btn.classList.add("btn-checkout");
                                    btn.textContent = "Check-out";
                                    status.textContent = "Bạn đang trong ca làm.";
                                } else {
                                    // Đổi từ check-out sang check-in (vàng → xanh)
                                    btn.classList.remove("btn-checkout");
                                    btn.classList.add("btn-checkin");
                                    btn.textContent = "Check-in";
                                    status.textContent = "Bạn chưa bắt đầu ca làm.";
                                }
                            });
                        }
                    } catch (err) {
                        Swal.fire({
                            icon: "error",
                            title: "Lỗi hệ thống",
                            text: "Không thể kết nối máy chủ. Hãy thử lại sau.",
                            confirmButtonText: "OK"
                        });
                    }
                });

                generateBtn.addEventListener("click", async () => {
                    try {
                        const formData = new URLSearchParams();
                        formData.append("action", "generate");

                        const res = await fetch("${pageContext.request.contextPath}/staff/attendance", {
                            method: "POST",
                            headers: {"Content-Type": "application/x-www-form-urlencoded"},
                            body: formData.toString()
                        });

                        const data = await res.json();
                        if (data.status === "success") {
                            Swal.fire({
                                icon: "success",
                                title: "Thành công!",
                                text: data.message,
                                confirmButtonText: "OK"
                            }).then(() => window.location.reload());
                        } else {
                            Swal.fire({
                                icon: "warning",
                                title: "Không thành công",
                                text: data.message,
                                confirmButtonText: "OK"
                            });
                        }
                    } catch (err) {
                        Swal.fire({
                            icon: "error",
                            title: "Lỗi hệ thống",
                            text: "Không thể kết nối máy chủ.",
                            confirmButtonText: "OK"
                        });
                    }
                });
            });
            updateNotifyBadge();
            updateChatBadge();
            setInterval(updateChatBadge, 5000);
        </script>
    </body>
</html>
