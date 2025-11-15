package controller;

import dao.StaffDAO;
import model.Admin;
import model.Staff;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;
import java.io.File;

import java.io.IOException;

@WebServlet("/admin/edit-staff")
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024, // 1MB
        maxFileSize = 1024 * 1024 * 5, // 5MB
        maxRequestSize = 1024 * 1024 * 10 // 10MB
)
public class EditStaffServlet extends HttpServlet {

    private StaffDAO staffDAO = new StaffDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Kiểm tra đăng nhập admin
        HttpSession session = request.getSession();
        Admin admin = (Admin) session.getAttribute("admin");
        if (admin == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        try {
            // Lấy ID nhân viên từ parameter
            String idParam = request.getParameter("id");
            if (idParam == null || idParam.trim().isEmpty()) {
                response.sendRedirect("manage-staff");
                return;
            }

            int staffId = Integer.parseInt(idParam);

            // Lấy thông tin nhân viên
            Staff staff = staffDAO.findById(staffId);
            if (staff == null) {
                request.setAttribute("error", "Không tìm thấy nhân viên");
                response.sendRedirect("manage-staff");
                return;
            }

            // Set attributes
            request.setAttribute("staff", staff);

            // Forward đến trang edit-staff.jsp
            request.getRequestDispatcher("/admin/edit-staff.jsp").forward(request, response);

        } catch (NumberFormatException e) {
            response.sendRedirect("manage-staff");
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Có lỗi xảy ra: " + e.getMessage());
            response.sendRedirect("manage-staff");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        Admin admin = (Admin) session.getAttribute("admin");
        if (admin == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        try {
            int staffId = Integer.parseInt(request.getParameter("staffId"));
            String name = request.getParameter("name");
            String email = request.getParameter("email");
            String phone = request.getParameter("phone");
            String password = request.getParameter("password");
            String scheduleNote = request.getParameter("scheduleNote");

            // ✅ Lấy file ảnh upload
            Part avatarPart = request.getPart("avatarFile");
            String avatarPath = null;

            if (avatarPart != null && avatarPart.getSize() > 0) {
                String fileName = System.currentTimeMillis() + "_" + avatarPart.getSubmittedFileName();
                String uploadPath = getServletContext().getRealPath("/images/avatars/");
                File uploadDir = new File(uploadPath);
                if (!uploadDir.exists()) {
                    uploadDir.mkdirs();
                }
                avatarPart.write(uploadPath + File.separator + fileName);
                avatarPath = "images/avatars/" + fileName;
            }

            // ✅ Validate cơ bản
            if (name == null || name.trim().isEmpty()) {
                request.setAttribute("error", "Tên nhân viên không được để trống");
                doGet(request, response);
                return;
            }
            if (email == null || email.trim().isEmpty()) {
                request.setAttribute("error", "Email không được để trống");
                doGet(request, response);
                return;
            }

            Staff staff = staffDAO.findById(staffId);
            if (staff == null) {
                response.sendRedirect("manage-staff");
                return;
            }

            // ✅ Cập nhật thông tin nhân viên
            staff.setName(name.trim());
            staff.setEmail(email.trim());
            staff.setPhone(phone.trim());
            staff.setScheduleNote(scheduleNote != null ? scheduleNote.trim() : "");
            if (password != null && !password.trim().isEmpty()) {
                staff.setPassword(password.trim());
            }

            // ✅ Gắn avatar mới (nếu có upload)
            if (avatarPath != null) {
                staff.setAvatar(avatarPath);
            }

            boolean success = staffDAO.updateStaff(staff);

            if (success) {
                response.sendRedirect("view-staff?id=" + staffId + "&success=true");
            } else {
                request.setAttribute("error", "Không thể cập nhật thông tin nhân viên");
                request.setAttribute("staff", staff);
                request.getRequestDispatcher("/admin/edit-staff.jsp").forward(request, response);
            }

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Có lỗi xảy ra: " + e.getMessage());
            doGet(request, response);
        }
    }
}
