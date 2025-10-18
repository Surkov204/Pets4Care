package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import dao.StaffDAO;
import model.Staff;

import java.io.IOException;

@WebServlet("/staff/update-profile")
public class UpdateStaffProfileServlet extends HttpServlet {
    
    private StaffDAO staffDAO = new StaffDAO();
    
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
            // Lấy thông tin từ form
            String name = request.getParameter("name");
            String email = request.getParameter("email");
            String phone = request.getParameter("phone");
            String password = request.getParameter("password");
            String scheduleNote = request.getParameter("schedule_note");
            
            // Validate input
            if (name == null || name.trim().isEmpty() ||
                email == null || email.trim().isEmpty() ||
                phone == null || phone.trim().isEmpty() ||
                password == null || password.trim().isEmpty()) {
                
                request.setAttribute("errorMessage", "Vui lòng điền đầy đủ thông tin bắt buộc");
                request.getRequestDispatcher("/staff/edit-profile.jsp").forward(request, response);
                return;
            }
            
            // Kiểm tra email có trùng với staff khác không (trừ chính mình)
            Staff existingStaff = staffDAO.getStaffByEmail(email);
            if (existingStaff != null && existingStaff.getStaffId() != currentStaff.getStaffId()) {
                request.setAttribute("errorMessage", "Email này đã được sử dụng bởi nhân viên khác");
                request.getRequestDispatcher("/staff/edit-profile.jsp").forward(request, response);
                return;
            }
            
            // Cập nhật thông tin staff
            Staff updatedStaff = new Staff();
            updatedStaff.setStaffId(currentStaff.getStaffId());
            updatedStaff.setName(name.trim());
            updatedStaff.setEmail(email.trim());
            updatedStaff.setPhone(phone.trim());
            updatedStaff.setPosition(currentStaff.getPosition()); // Giữ nguyên position từ session
            updatedStaff.setPassword(password.trim()); // Cập nhật mật khẩu mới
            updatedStaff.setScheduleNote(scheduleNote != null ? scheduleNote.trim() : null);
            
            boolean success = staffDAO.updateStaff(updatedStaff);
            
            if (success) {
                // Cập nhật session với thông tin mới
                session.setAttribute("staff", updatedStaff);
                session.setAttribute("staffName", updatedStaff.getName());
                
                request.setAttribute("successMessage", "Cập nhật thông tin thành công!");
                request.getRequestDispatcher("/staff/edit-profile.jsp").forward(request, response);
            } else {
                request.setAttribute("errorMessage", "Có lỗi xảy ra khi cập nhật thông tin. Vui lòng thử lại.");
                request.getRequestDispatcher("/staff/edit-profile.jsp").forward(request, response);
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "Có lỗi xảy ra: " + e.getMessage());
            request.getRequestDispatcher("/staff/edit-profile.jsp").forward(request, response);
        }
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        // Redirect to edit profile page
        response.sendRedirect(request.getContextPath() + "/staff/edit-profile");
    }
}
