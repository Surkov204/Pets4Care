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

@WebServlet("/update-appointment-status")
public class UpdateAppointmentStatusServlet extends HttpServlet {
    private BookingDAO bookingDAO = new BookingDAO();
    private static final Logger logger = Logger.getLogger(UpdateAppointmentStatusServlet.class.getName());

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Kiểm tra đăng nhập doctor
        Doctor doctor = (Doctor) request.getSession().getAttribute("doctor");
        if (doctor == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }
        
        String bookingIdStr = request.getParameter("bookingId");
        String status = request.getParameter("status");
        
        if (bookingIdStr == null || status == null) {
            response.sendRedirect(request.getContextPath() + "/doctor/appointments.jsp?error=missing_parameters");
            return;
        }
        
        try {
            int bookingId = Integer.parseInt(bookingIdStr);
            
            // Cập nhật trạng thái
            boolean success = bookingDAO.updateBookingStatus(bookingId, status);
            
            if (success) {
                logger.info("Doctor " + doctor.getName() + " updated booking " + bookingId + " status to " + status);
                response.sendRedirect(request.getContextPath() + "/doctor/appointments.jsp?success=status_updated");
            } else {
                response.sendRedirect(request.getContextPath() + "/doctor/appointments.jsp?error=update_failed");
            }
            
        } catch (NumberFormatException e) {
            logger.warning("Invalid booking ID: " + bookingIdStr);
            response.sendRedirect(request.getContextPath() + "/doctor/appointments.jsp?error=invalid_booking_id");
        } catch (Exception e) {
            logger.severe("Error updating appointment status: " + e.getMessage());
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/doctor/appointments.jsp?error=system_error");
        }
    }
}
