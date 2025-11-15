package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import dao.StaffDAO;
import model.Staff;
import java.io.File;
import java.io.IOException;

@WebServlet("/staff/update-profile")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024, // 1MB
    maxFileSize = 1024 * 1024 * 5,   // 5MB
    maxRequestSize = 1024 * 1024 * 10 // 10MB
)
public class UpdateStaffProfileServlet extends HttpServlet {

    private final StaffDAO staffDAO = new StaffDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        Staff currentStaff = (Staff) session.getAttribute("staff");

        if (currentStaff == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        try {
            request.setCharacterEncoding("UTF-8");

            // ✅ Lấy dữ liệu form
            String name = request.getParameter("name");
            String email = request.getParameter("email");
            String phone = request.getParameter("phone");
            String password = request.getParameter("password");
            String scheduleNote = request.getParameter("schedule_note");

            // ✅ Upload avatar (nếu có)
            Part avatarPart = request.getPart("avatarFile");
            String avatarPath = currentStaff.getAvatar();

            if (avatarPart != null && avatarPart.getSize() > 0) {
                String fileName = System.currentTimeMillis() + "_" + avatarPart.getSubmittedFileName();
                String uploadPath = getServletContext().getRealPath("/images/avatars/");
                File uploadDir = new File(uploadPath);
                if (!uploadDir.exists()) uploadDir.mkdirs();
                avatarPart.write(uploadPath + File.separator + fileName);
                avatarPath = "images/avatars/" + fileName;
            }

            // ✅ Kiểm tra dữ liệu bắt buộc
            if (name == null || name.isBlank() || email == null || email.isBlank()
                    || phone == null || phone.isBlank() || password == null || password.isBlank()) {
                request.setAttribute("errorMessage", "Vui lòng điền đầy đủ thông tin bắt buộc");
                request.getRequestDispatcher("/staff/edit-profile.jsp").forward(request, response);
                return;
            }

            // ✅ Kiểm tra email trùng
            Staff existingStaff = staffDAO.getStaffByEmail(email);
            if (existingStaff != null && existingStaff.getStaffId() != currentStaff.getStaffId()) {
                request.setAttribute("errorMessage", "Email này đã được sử dụng bởi nhân viên khác");
                request.getRequestDispatcher("/staff/edit-profile.jsp").forward(request, response);
                return;
            }

            // ✅ Cập nhật staff mới
            Staff updatedStaff = new Staff();
            updatedStaff.setStaffId(currentStaff.getStaffId());
            updatedStaff.setName(name.trim());
            updatedStaff.setEmail(email.trim());
            updatedStaff.setPhone(phone.trim());
            updatedStaff.setPassword(password.trim());
            updatedStaff.setScheduleNote(scheduleNote != null ? scheduleNote.trim() : null);
            updatedStaff.setAvatar(avatarPath);
            updatedStaff.setPosition(currentStaff.getPosition());

            boolean success = staffDAO.updateProfile(updatedStaff);

            if (success) {
                session.setAttribute("staff", updatedStaff);
                request.setAttribute("successMessage", "Cập nhật thông tin thành công!");
            } else {
                request.setAttribute("errorMessage", "Có lỗi xảy ra khi cập nhật thông tin. Vui lòng thử lại.");
            }

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "Lỗi: " + e.getMessage());
        }

        // ✅ Quay về trang edit-profile.jsp
        request.getRequestDispatcher("/staff/edit-profile.jsp").forward(request, response);
    }
}
