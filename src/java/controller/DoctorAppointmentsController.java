package controller;

import dao.BookingDAO;
import dao.MedicalRecordDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.text.Normalizer;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.logging.Logger;
import java.util.regex.Pattern;
import java.util.stream.Collectors;
import model.Booking;
import model.Doctor;
import model.MedicalRecord;

@WebServlet("/doctor/appointments")
public class DoctorAppointmentsController extends HttpServlet {
    private static final Logger logger = Logger.getLogger(DoctorAppointmentsController.class.getName());
    private final BookingDAO bookingDAO = new BookingDAO();
    private final MedicalRecordDAO medicalRecordDAO = new MedicalRecordDAO();
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

        // Debug: Check status encoding issues
        for (Booking apt : appointments) {
            String status = apt.getStatus();
            if (status != null) {
                logger.info("Appointment " + apt.getBookingId() + " status: '" + status + "' (length: " + status.length() + ")");
                String normalized = removeDiacritics(status).toLowerCase();
                logger.info("Normalized: '" + normalized + "'");
                logger.info("Contains 'hoan thanh': " + normalized.contains("hoan thanh"));
            }
        }

        // Load all medical records for this doctor to filter out completed appointments
        List<MedicalRecord> allMedicalRecords = medicalRecordDAO.getByDoctorId(doctorId);
        Set<Integer> bookingsWithRecords = allMedicalRecords.stream()
                .map(MedicalRecord::getBookingId)
                .collect(Collectors.toSet());

        // Filter out appointments that already have medical records
        appointments = appointments.stream()
                .filter(appointment -> !bookingsWithRecords.contains(appointment.getBookingId()))
                .collect(Collectors.toList());

        upcomingAppointments = upcomingAppointments.stream()
                .filter(appointment -> !bookingsWithRecords.contains(appointment.getBookingId()))
                .collect(Collectors.toList());

        // Check for existing medical records for each appointment (should be none after filtering)
        Map<Integer, MedicalRecord> medicalRecordsMap = new HashMap<>();
        for (Booking appointment : appointments) {
            MedicalRecord record = medicalRecordDAO.getByBookingId(appointment.getBookingId());
            medicalRecordsMap.put(appointment.getBookingId(), record);
        }

        // Check for upcoming appointments too
        for (Booking appointment : upcomingAppointments) {
            MedicalRecord record = medicalRecordDAO.getByBookingId(appointment.getBookingId());
            medicalRecordsMap.put(appointment.getBookingId(), record);
        }

        request.setAttribute("appointments", appointments);
        request.setAttribute("upcomingAppointments", upcomingAppointments);
        request.setAttribute("medicalRecordsMap", medicalRecordsMap);
        request.setAttribute("selectedDate", selectedDate);
        request.setAttribute("selectedDateIso", selectedDate.toString());
        request.setAttribute("selectedDateDisplay", selectedDate.format(displayFormatter));

        request.getRequestDispatcher("/doctor/appointments.jsp").forward(request, response);
    }

    /**
     * Remove diacritics from Vietnamese text to avoid encoding issues
     */
    private String removeDiacritics(String text) {
        if (text == null) return null;
        String normalized = Normalizer.normalize(text, Normalizer.Form.NFD);
        Pattern pattern = Pattern.compile("\\p{InCombiningDiacriticalMarks}+");
        return pattern.matcher(normalized).replaceAll("");
    }
}
