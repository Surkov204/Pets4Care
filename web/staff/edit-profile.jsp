<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>🐾 Chỉnh sửa thông tin | Pet4Care</title>
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
                    <li><a href="${pageContext.request.contextPath}/staff/mySchedule"><i class="fas fa-calendar-alt"></i> My Work Schedule</a></li>
                    <li><a href="${pageContext.request.contextPath}/staff/customer-list"><i class="fas fa-users"></i> Customer Profile</a></li>
                    <li><a href="${pageContext.request.contextPath}/staff/services-booking"><i class="fas fa-list"></i> Services Booking</a></li>
                    <li><a href="${pageContext.request.contextPath}/staff/requestShift.jsp"><i class="fas fa-exchange-alt"></i> Request Shift</a></li>
                    <li><a href="${pageContext.request.contextPath}/staff/chatCustomer.jsp"><i class="fas fa-comments"></i> Chat with Customer</a></li>
                    <li><a href="${pageContext.request.contextPath}/staff/products"><i class="fas fa-box"></i> View Product</a></li>
                </ul>
            </aside>

            <!-- Main Content -->
            <main class="staff-content">
                <section class="recent-section">
                    <h2><i class="fas fa-user-edit"></i> Chỉnh sửa thông tin cá nhân</h2>
                    <p style="color: var(--text-light); margin-bottom: 1rem;">Cập nhật thông tin cá nhân của bạn 🐾</p>

                    <c:if test="${not empty successMessage}">
                        <div class="alert alert-success" style="background-color: #d4edda; color: #155724; border: 1px solid #c3e6cb; padding: 12px 16px; border-radius: 8px; margin-bottom: 20px;">
                            <i class="fas fa-check-circle"></i> ${successMessage}
                        </div>
                    </c:if>

                    <c:if test="${not empty errorMessage}">
                        <div class="alert alert-danger" style="background-color: #f8d7da; color: #721c24; border: 1px solid #f5c6cb; padding: 12px 16px; border-radius: 8px; margin-bottom: 20px;">
                            <i class="fas fa-exclamation-circle"></i> ${errorMessage}
                        </div>
                    </c:if>

                    <!-- Form chỉnh sửa thông tin -->
                    <div class="search-section" style="background-color: #f8f9fa; border-radius: 10px; padding: 1.5rem; margin-bottom: 2rem;">
                        <h3 style="margin-bottom: 1rem; color: #17a2b8;">
                            <i class="fas fa-user"></i> Thông tin cá nhân
                        </h3>

                        <form action="${pageContext.request.contextPath}/staff/update-profile" method="post" style="display: flex; flex-direction: column; gap: 1rem;">
                            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 1rem;">
                                <div>
                                    <label for="name" style="display: block; margin-bottom: 0.5rem; font-weight: 500;">Họ và tên *:</label>
                                    <input type="text" id="name" name="name" value="${sessionScope.staff.name}" required
                                           style="width: calc(100% - 10px); padding: 0.5rem; border: 1px solid #ddd; border-radius: 5px;">
                                </div>

                                <div>
                                    <label for="email" style="display: block; margin-bottom: 0.5rem; font-weight: 500;">Email *:</label>
                                    <input type="email" id="email" name="email" value="${sessionScope.staff.email}" required
                                           style="width: calc(100% - 10px); padding: 0.5rem; border: 1px solid #ddd; border-radius: 5px;">
                                </div>
                            </div>

                            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 1rem;">
                                <div>
                                    <label for="phone" style="display: block; margin-bottom: 0.5rem; font-weight: 500;">Số điện thoại *:</label>
                                    <input type="tel" id="phone" name="phone" value="${sessionScope.staff.phone}" required
                                           style="width: calc(100% - 10px); padding: 0.5rem; border: 1px solid #ddd; border-radius: 5px;">
                                </div>

                                <div>
                                    <label for="password" style="display: block; margin-bottom: 0.5rem; font-weight: 500;">Mật khẩu *:</label>
                                    <div style="position: relative;">
                                        <input type="password" id="password" name="password" value="${sessionScope.staff.password}" required
                                               style="width: calc(100% - 10px); padding: 0.5rem; border: 1px solid #ddd; border-radius: 5px;">
                                        <button type="button" id="togglePassword" 
                                                style="position: absolute; right: 0.5rem; top: 50%; transform: translateY(-50%); background: none; border: none; cursor: pointer; font-size: 0.8rem; color: #666; width: 1rem; height: 1rem; display: flex; align-items: center; justify-content: center;">
                                            <i class="fas fa-eye" id="passwordIcon"></i>
                                        </button>
                                    </div>
                                </div>
                            </div>

                            <div>
                                <label for="schedule_note" style="display: block; margin-bottom: 0.5rem; font-weight: 500;">Ghi chú lịch làm việc:</label>
                                <textarea id="schedule_note" name="schedule_note" placeholder="Ví dụ: Làm các ngày: 2 - 3 - 5 (08:00-17:00)"
                                          style="width: 100%; padding: 0.5rem; border: 1px solid #ddd; border-radius: 5px; min-height: 80px; resize: vertical;">${sessionScope.staff.scheduleNote}</textarea>
                            </div>

                            <div style="display: flex; gap: 1rem; justify-content: flex-end; margin-top: 1rem;">
                                <a href="${pageContext.request.contextPath}/staff/viewOrder" 
                                   style="background-color: #6c757d; color: white; padding: 0.5rem 1rem; border: none; border-radius: 5px; cursor: pointer; text-decoration: none; display: inline-block;">
                                    <i class="fas fa-arrow-left"></i> Quay lại
                                </a>
                                <button type="button" onclick="showConfirmModal()" 
                                        style="background-color: #17a2b8; color: white; padding: 0.5rem 1rem; border: none; border-radius: 5px; cursor: pointer;">
                                    <i class="fas fa-save"></i> Lưu thay đổi
                                </button>
                            </div>
                        </form>
                    </div>
                </section>
            </main>
        </div>

        <!-- Modal xác nhận -->
        <div id="confirmModal" style="display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%; background-color: rgba(0, 0, 0, 0.5); z-index: 10000;">
            <div style="position: absolute; top: 50%; left: 50%; transform: translate(-50%, -50%); background: white; border-radius: 10px; padding: 2rem; min-width: 400px; box-shadow: 0 4px 20px rgba(0, 0, 0, 0.3);">
                <div style="text-align: center; margin-bottom: 1.5rem;">
                    <i class="fas fa-question-circle" style="font-size: 3rem; color: #17a2b8; margin-bottom: 1rem;"></i>
                    <h3 style="margin: 0; color: #333;">Xác nhận lưu thay đổi</h3>
                </div>
                <p style="text-align: center; color: #666; margin-bottom: 2rem;">
                    Bạn có chắc chắn muốn lưu những thay đổi này không?<br>
                    Thông tin sẽ được cập nhật vào hệ thống.
                </p>
                <div style="display: flex; gap: 1rem; justify-content: center;">
                    <button onclick="hideConfirmModal()" 
                            style="background-color: #6c757d; color: white; padding: 0.75rem 1.5rem; border: none; border-radius: 5px; cursor: pointer;">
                        <i class="fas fa-times"></i> Hủy bỏ
                    </button>
                    <button onclick="confirmSave()" 
                            style="background-color: #28a745; color: white; padding: 0.75rem 1.5rem; border: none; border-radius: 5px; cursor: pointer;">
                        <i class="fas fa-check"></i> Xác nhận lưu
                    </button>
                </div>
            </div>
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

        // Email validation function
            function validateEmail(email) {
                const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
                return emailRegex.test(email);
            }

        // Modal confirmation functions
            function showConfirmModal() {
                // Validate form first
                const form = document.querySelector('form');
                const requiredFields = form.querySelectorAll('[required]');
                let isValid = true;
                let errorMessage = '';

                requiredFields.forEach(field => {
                    if (!field.value.trim()) {
                        isValid = false;
                        field.style.borderColor = '#dc3545';
                        errorMessage = 'Vui lòng điền đầy đủ thông tin bắt buộc!';
                    } else {
                        field.style.borderColor = '#ddd';
                    }
                });

                // Validate email format
                const emailField = document.getElementById('email');
                if (emailField.value.trim() && !validateEmail(emailField.value.trim())) {
                    isValid = false;
                    emailField.style.borderColor = '#dc3545';
                    errorMessage = 'Vui lòng nhập đúng định dạng email (ví dụ: user@example.com)!';
                }

                if (!isValid) {
                    alert(errorMessage);
                    return;
                }

                // Show modal
                document.getElementById('confirmModal').style.display = 'block';
            }

            function hideConfirmModal() {
                document.getElementById('confirmModal').style.display = 'none';
            }

            function confirmSave() {
                // Hide modal
                hideConfirmModal();

                // Submit form
                document.querySelector('form').submit();
            }

        // Close modal when clicking outside
            document.getElementById('confirmModal').addEventListener('click', function (event) {
                if (event.target === this) {
                    hideConfirmModal();
                }
            });

        // Close modal with Escape key
            document.addEventListener('keydown', function (event) {
                if (event.key === 'Escape') {
                    hideConfirmModal();
                }
            });

        // Toggle password visibility
            document.getElementById('togglePassword').addEventListener('click', function () {
                const passwordInput = document.getElementById('password');
                const passwordIcon = document.getElementById('passwordIcon');

                if (passwordInput.type === 'password') {
                    passwordInput.type = 'text';
                    passwordIcon.classList.remove('fa-eye');
                    passwordIcon.classList.add('fa-eye-slash');
                } else {
                    passwordInput.type = 'password';
                    passwordIcon.classList.remove('fa-eye-slash');
                    passwordIcon.classList.add('fa-eye');
                }
            });
        </script>

    </body>
</html>
