package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import dao.DoctorDAO;
import model.Doctor;

import java.io.IOException;
import java.util.logging.Logger;

@WebServlet("/doctor/update-profile")
public class UpdateDoctorProfileServlet extends HttpServlet {
    private DoctorDAO doctorDAO = new DoctorDAO();
    private static final Logger logger = Logger.getLogger(UpdateDoctorProfileServlet.class.getName());

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Kiểm tra đăng nhập doctor
        HttpSession session = request.getSession();
        Doctor doctor = (Doctor) session.getAttribute("doctor");
        if (doctor == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }
        
        // Forward to edit page
        request.getRequestDispatcher("/doctor/edit-doctor-profile.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Kiểm tra đăng nhập doctor
        HttpSession session = request.getSession();
        Doctor doctor = (Doctor) session.getAttribute("doctor");
        if (doctor == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }
        
        try {
            // Lấy action (update thông tin hoặc đổi mật khẩu)
            String action = request.getParameter("action");
            
            if ("updateInfo".equals(action)) {
                updateDoctorInfo(request, response, doctor, session);
            } else if ("changePassword".equals(action)) {
                changeDoctorPassword(request, response, doctor, session);
            } else {
                response.sendRedirect(request.getContextPath() + "/doctor/doctor-profile.jsp?error=invalid_action");
            }
            
        } catch (Exception e) {
            logger.severe("Error updating doctor profile: " + e.getMessage());
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/doctor/edit-doctor-profile.jsp?error=system_error");
        }
    }
    
    private void updateDoctorInfo(HttpServletRequest request, HttpServletResponse response, 
                                   Doctor currentDoctor, HttpSession session) throws IOException {
        
        String name = request.getParameter("name");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String specialization = request.getParameter("specialization");
        String scheduleNote = request.getParameter("scheduleNote");
        
        // Validation
        if (name == null || name.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/doctor/edit-doctor-profile.jsp?error=name_required");
            return;
        }
        
        if (email == null || email.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/doctor/edit-doctor-profile.jsp?error=email_required");
            return;
        }
        
        // Cập nhật thông tin
        Doctor updatedDoctor = new Doctor();
        updatedDoctor.setDoctorId(currentDoctor.getDoctorId());
        updatedDoctor.setName(name.trim());
        updatedDoctor.setEmail(email.trim());
        updatedDoctor.setPhone(phone != null ? phone.trim() : "");
        updatedDoctor.setSpecialization(specialization != null ? specialization.trim() : "");
        updatedDoctor.setScheduleNote(scheduleNote != null ? scheduleNote.trim() : "");
        
        boolean success = doctorDAO.updateProfile(updatedDoctor);
        
        if (success) {
            // Cập nhật session
            Doctor refreshedDoctor = doctorDAO.findById(currentDoctor.getDoctorId());
            session.setAttribute("doctor", refreshedDoctor);
            session.setAttribute("doctorName", refreshedDoctor.getName());
            session.setAttribute("doctorEmail", refreshedDoctor.getEmail());
            session.setAttribute("doctorSpecialization", refreshedDoctor.getSpecialization());
            
            logger.info("Doctor profile updated successfully: " + refreshedDoctor.getName());
            response.sendRedirect(request.getContextPath() + "/doctor/doctor-profile.jsp?success=profile_updated");
        } else {
            response.sendRedirect(request.getContextPath() + "/doctor/edit-doctor-profile.jsp?error=update_failed");
        }
    }
    
    private void changeDoctorPassword(HttpServletRequest request, HttpServletResponse response,
                                      Doctor currentDoctor, HttpSession session) throws IOException {
        
        String currentPassword = request.getParameter("currentPassword");
        String newPassword = request.getParameter("newPassword");
        String confirmPassword = request.getParameter("confirmPassword");
        
        // Validation
        if (currentPassword == null || newPassword == null || confirmPassword == null) {
            response.sendRedirect(request.getContextPath() + "/doctor/edit-doctor-profile.jsp?error=password_required&tab=password");
            return;
        }
        
        // Kiểm tra mật khẩu hiện tại
        Doctor dbDoctor = doctorDAO.findById(currentDoctor.getDoctorId());
        if (!currentPassword.equals(dbDoctor.getPassword())) {
            response.sendRedirect(request.getContextPath() + "/doctor/edit-doctor-profile.jsp?error=wrong_password&tab=password");
            return;
        }
        
        // Kiểm tra mật khẩu mới khớp
        if (!newPassword.equals(confirmPassword)) {
            response.sendRedirect(request.getContextPath() + "/doctor/edit-doctor-profile.jsp?error=password_mismatch&tab=password");
            return;
        }
        
        // Cập nhật mật khẩu
        boolean success = doctorDAO.updatePassword(currentDoctor.getDoctorId(), newPassword);
        
        if (success) {
            logger.info("Doctor password changed successfully: " + currentDoctor.getDoctorId());
            response.sendRedirect(request.getContextPath() + "/doctor/doctor-profile.jsp?success=password_changed");
        } else {
            response.sendRedirect(request.getContextPath() + "/doctor/edit-doctor-profile.jsp?error=password_update_failed&tab=password");
        }
    }
}

