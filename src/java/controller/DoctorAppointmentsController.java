package controller;

import dao.BookingDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import java.util.List;
import java.util.logging.Logger;
import model.Booking;
import model.Doctor;

@WebServlet("/doctor/appointments")
public class DoctorAppointmentsController extends HttpServlet {
    private static final Logger logger = Logger.getLogger(DoctorAppointmentsController.class.getName());
    private final BookingDAO bookingDAO = new BookingDAO();
    private final DateTimeFormatter displayFormatter = DateTimeFormatter.ofPattern("dd/MM/yyyy");

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        Doctor doctor = (Doctor) session.getAttribute("doctor");

        if (doctor == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        LocalDate selectedDate = LocalDate.now();
        String dateParam = request.getParameter("date");
        if (dateParam != null && !dateParam.isBlank()) {
            try {
                selectedDate = LocalDate.parse(dateParam);
            } catch (DateTimeParseException ex) {
                logger.warning("Invalid date parameter for doctor appointments: " + dateParam);
            }
        }

        int doctorId = doctor.getDoctorId();
        List<Booking> appointments = bookingDAO.getBookingsByDoctorAndDate(doctorId, selectedDate);
        List<Booking> upcomingAppointments = bookingDAO.getBookingsByDoctorAndDateRange(
                doctorId,
                LocalDate.now(),
                LocalDate.now().plusDays(14)
        );

        request.setAttribute("appointments", appointments);
        request.setAttribute("upcomingAppointments", upcomingAppointments);
        request.setAttribute("selectedDate", selectedDate);
        request.setAttribute("selectedDateIso", selectedDate.toString());
        request.setAttribute("selectedDateDisplay", selectedDate.format(displayFormatter));

        request.getRequestDispatcher("/doctor/appointments.jsp").forward(request, response);
    }
}
