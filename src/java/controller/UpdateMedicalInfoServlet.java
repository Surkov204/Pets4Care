package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import dao.BookingDAO;
import model.Doctor;

import java.io.IOException;
import java.util.logging.Logger;

@WebServlet("/update-medical-info")
public class UpdateMedicalInfoServlet extends HttpServlet {
    private BookingDAO bookingDAO = new BookingDAO();
    private static final Logger logger = Logger.getLogger(UpdateMedicalInfoServlet.class.getName());

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        
        // Kiểm tra đăng nhập doctor
        Doctor doctor = (Doctor) request.getSession().getAttribute("doctor");
        if (doctor == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }
        
        String bookingIdStr = request.getParameter("bookingId");
        String medicalNote = request.getParameter("medicalNote");
        
        if (bookingIdStr == null || bookingIdStr.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/doctor/appointments.jsp?error=missing_booking_id");
            return;
        }
        
        try {
            int bookingId = Integer.parseInt(bookingIdStr);
            
            // Kiểm tra booking có thuộc về doctor này không
            var booking = bookingDAO.getBookingById(bookingId);
            if (booking == null) {
                response.sendRedirect(request.getContextPath() + "/doctor/appointments.jsp?error=booking_not_found");
                return;
            }
            
            if (booking.getDoctorId() != doctor.getDoctorId()) {
                response.sendRedirect(request.getContextPath() + "/doctor/appointments.jsp?error=unauthorized");
                return;
            }
            
            // Cập nhật ghi chú y tế
            // Nếu medicalNote là null hoặc rỗng, giữ nguyên note cũ
            String noteToUpdate = (medicalNote != null && !medicalNote.trim().isEmpty()) 
                ? medicalNote.trim() 
                : booking.getNote();
            
            boolean success = bookingDAO.updateBookingNote(bookingId, noteToUpdate);
            
            if (success) {
                logger.info("Doctor " + doctor.getName() + " updated medical info for booking " + bookingId);
                response.sendRedirect(request.getContextPath() + "/doctor/appointment-detail.jsp?id=" + bookingId + "&success=updated");
            } else {
                response.sendRedirect(request.getContextPath() + "/doctor/appointment-detail.jsp?id=" + bookingId + "&error=update_failed");
            }
            
        } catch (NumberFormatException e) {
            logger.warning("Invalid booking ID: " + bookingIdStr);
            response.sendRedirect(request.getContextPath() + "/doctor/appointments.jsp?error=invalid_booking_id");
        } catch (Exception e) {
            logger.severe("Error updating medical info: " + e.getMessage());
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/doctor/appointments.jsp?error=system_error");
        }
    }
}
