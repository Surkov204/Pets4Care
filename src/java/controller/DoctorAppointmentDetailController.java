package controller;

import dao.BookingDAO;
import dao.PetDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.logging.Logger;
import model.Booking;
import model.Doctor;
import model.Pet;

@WebServlet("/doctor/appointment-detail")
public class DoctorAppointmentDetailController extends HttpServlet {
    private static final Logger logger = Logger.getLogger(DoctorAppointmentDetailController.class.getName());
    private final BookingDAO bookingDAO = new BookingDAO();
    private final PetDAO petDAO = new PetDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        Doctor doctor = (Doctor) session.getAttribute("doctor");

        if (doctor == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String bookingIdStr = request.getParameter("id");
        if (bookingIdStr == null || bookingIdStr.isBlank()) {
            response.sendRedirect(request.getContextPath() + "/doctor/appointments?error=missing_id");
            return;
        }

        try {
            int bookingId = Integer.parseInt(bookingIdStr);
            Booking booking = bookingDAO.getBookingById(bookingId);

            if (booking == null) {
                response.sendRedirect(request.getContextPath() + "/doctor/appointments?error=booking_not_found");
                return;
            }

            if (booking.getDoctorId() != doctor.getDoctorId()) {
                response.sendRedirect(request.getContextPath() + "/doctor/appointments?error=unauthorized");
                return;
            }

            Pet pet = null;
            if (booking.getPetId() > 0) {
                pet = petDAO.getPetById(booking.getPetId());
            }

            request.setAttribute("booking", booking);
            request.setAttribute("pet", pet);

            request.getRequestDispatcher("/doctor/appointment-detail.jsp").forward(request, response);

        } catch (NumberFormatException ex) {
            logger.warning("Invalid appointment id parameter: " + bookingIdStr);
            response.sendRedirect(request.getContextPath() + "/doctor/appointments?error=invalid_id");
        }
    }
}
