<%@ page contentType="text/html;charset=UTF-8" %>
<!-- Header Admin -->
<nav class="bg-blue-600 text-white px-6 py-3 shadow-md flex justify-between items-center">
    <div class="flex items-center space-x-3">
        <i class="fas fa-paw text-2xl"></i>
        <span class="font-bold text-lg">🐾 Pets4Care Admin</span>
    </div>

    <div class="flex items-center space-x-6">
        <a href="<%= request.getContextPath() %>/admin/staff-profile.jsp" class="hover:text-gray-200">Hồ sơ</a>
        <a href="<%= request.getContextPath() %>/admin/manage-staff.jsp" class="hover:text-gray-200">Nhân viên</a>
        <a href="<%= request.getContextPath() %>/admin/manage-pet.jsp" class="hover:text-gray-200">Thú cưng</a>
        <a href="<%= request.getContextPath() %>/admin/logout.jsp" class="hover:text-gray-200 flex items-center gap-1">
            <i class="fas fa-sign-out-alt"></i> Đăng xuất
        </a>
    </div>
</nav>
