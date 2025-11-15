package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import dao.MedicalRecordDAO;
import dao.BookingDAO;
import model.Doctor;
import model.MedicalRecord;
import model.Booking;

import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Timestamp;
import java.text.Normalizer;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Logger;
import java.util.regex.Pattern;

@WebServlet("/doctor/medical-records")
public class DoctorMedicalRecordController extends HttpServlet {
    private static final Logger logger = Logger.getLogger(DoctorMedicalRecordController.class.getName());
    private MedicalRecordDAO medicalRecordDAO = new MedicalRecordDAO();
    private BookingDAO bookingDAO = new BookingDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        Doctor doctor = (Doctor) session.getAttribute("doctor");

        if (doctor == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        try {
            int doctorId = doctor.getDoctorId();
            String action = request.getParameter("action");
            
            if ("view".equals(action)) {
                int recordId = Integer.parseInt(request.getParameter("id"));
                MedicalRecord record = getMedicalRecordById(recordId);
                if (record != null && record.getDoctorId() == doctorId) {
                    request.setAttribute("record", record);
                    request.getRequestDispatcher("/doctor/medical-record-detail.jsp").forward(request, response);
                } else {
                    response.sendRedirect(request.getContextPath() + "/doctor/medical-records");
                }
                return;
            } else if ("create".equals(action)) {
                String bookingIdStr = request.getParameter("bookingId");
                if (bookingIdStr != null && !bookingIdStr.isEmpty()) {
                    int bookingId = Integer.parseInt(bookingIdStr);
                    Booking booking = bookingDAO.getBookingById(bookingId);

                    if (booking == null || booking.getDoctorId() != doctorId) {
                        response.sendRedirect(request.getContextPath() + "/doctor/medical-records?error=unauthorized");
                        return;
                    }

                    // Check if medical record already exists
                    if (medicalRecordDAO.getByBookingId(bookingId) != null) {
                        response.sendRedirect(request.getContextPath() + "/doctor/medical-records?error=exists");
                        return;
                    }

                    request.setAttribute("booking", booking);
                    request.setAttribute("mode", "create");
                    request.getRequestDispatcher("/doctor/medical-record-form.jsp").forward(request, response);
                } else {
                    response.sendRedirect(request.getContextPath() + "/doctor/medical-records?error=missing_booking");
                }
                return;
            } else if ("edit".equals(action)) {
                int recordId = Integer.parseInt(request.getParameter("id"));
                MedicalRecord record = getMedicalRecordById(recordId);

                if (record == null || record.getDoctorId() != doctorId) {
                    response.sendRedirect(request.getContextPath() + "/doctor/medical-records?error=unauthorized");
                    return;
                }

                // Get the booking information for the form
                Booking booking = bookingDAO.getBookingById(record.getBookingId());
                if (booking == null) {
                    response.sendRedirect(request.getContextPath() + "/doctor/medical-records?error=booking_not_found");
                    return;
                }

                request.setAttribute("record", record);
                request.setAttribute("booking", booking);
                request.setAttribute("mode", "edit");
                request.getRequestDispatcher("/doctor/medical-record-form.jsp").forward(request, response);
                return;
            }
            
            List<MedicalRecord> medicalRecords = medicalRecordDAO.getByDoctorId(doctorId);

            // Create a set of booking IDs that already have medical records for quick lookup
            java.util.Set<Integer> bookingsWithRecords = new java.util.HashSet<>();
            for (MedicalRecord record : medicalRecords) {
                // Only include records that are linked to bookings (bookingId > 0)
                if (record.getBookingId() > 0) {
                    bookingsWithRecords.add(record.getBookingId());
                }
            }

            // Get all appointments for this doctor (both pending and completed)
            List<Booking> allAppointments = bookingDAO.getBookingsByDoctorAndDateRange(
                doctorId,
                LocalDate.now().minusMonths(6),
                LocalDate.now().plusMonths(3) // Include future appointments
            );

            // Separate completed and pending appointments
            List<Booking> completedAppointments = new ArrayList<>();
            List<Booking> pendingAppointments = new ArrayList<>();
            List<Booking> upcomingAppointments = new ArrayList<>();

            for (Booking appointment : allAppointments) {
                // First check if this booking already has a medical record
                if (bookingsWithRecords.contains(appointment.getBookingId())) {
                    // Skip bookings that already have medical records - they appear in the medical records table
                    continue;
                }

                // For bookings without medical records, categorize by status
                // Remove diacritics to avoid encoding issues
                String status = appointment.getStatus();
                if (status != null) {
                    status = removeDiacritics(status).toLowerCase();
                }

                if (status != null && (status.contains("hoan thanh") || status.contains("completed"))) {
                    completedAppointments.add(appointment);
                } else if (status != null && (status.contains("cho xac nhan") || status.contains("pending"))) {
                    pendingAppointments.add(appointment);
                } else if (status != null && (status.contains("da xac nhan") || status.contains("confirmed"))) {
                    upcomingAppointments.add(appointment);
                } else {
                    // If status doesn't match any known pattern, assume it needs medical record creation
                    completedAppointments.add(appointment);
                }
            }
            
            request.setAttribute("medicalRecords", medicalRecords);
            request.setAttribute("completedAppointments", completedAppointments);
            request.setAttribute("pendingAppointments", pendingAppointments);
            request.setAttribute("upcomingAppointments", upcomingAppointments);

            // Get all pets and customers for manual medical record creation
            // This would require additional DAOs - for now, we'll use a simple approach
            request.setAttribute("canCreateManual", true);
            
            request.getRequestDispatcher("/doctor/medical-record.jsp").forward(request, response);
            
        } catch (Exception e) {
            logger.severe("Error loading medical records: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("error", "Có lỗi xảy ra khi tải hồ sơ y tế: " + e.getMessage());
            request.getRequestDispatcher("/doctor/medical-record.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        Doctor doctor = (Doctor) session.getAttribute("doctor");

        if (doctor == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        try {
            String action = request.getParameter("action");
            
            if ("create".equals(action)) {
                createMedicalRecord(request, doctor);
                response.sendRedirect(request.getContextPath() + "/doctor/medical-records?success=created");
            } else if ("update".equals(action)) {
                updateMedicalRecord(request, doctor);
                response.sendRedirect(request.getContextPath() + "/doctor/medical-records?success=updated");
            } else {
                response.sendRedirect(request.getContextPath() + "/doctor/medical-records");
            }
            
        } catch (Exception e) {
            logger.severe("Error processing medical record: " + e.getMessage());
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/doctor/medical-records?error=" + e.getMessage());
        }
    }
    
    private void createMedicalRecord(HttpServletRequest request, Doctor doctor) throws Exception {
        MedicalRecord record = new MedicalRecord();

        String bookingIdStr = request.getParameter("bookingId");
        if (bookingIdStr != null && !bookingIdStr.isEmpty()) {
            // Create from existing booking
            int bookingId = Integer.parseInt(bookingIdStr);
            Booking booking = bookingDAO.getBookingById(bookingId);

            if (booking == null || booking.getDoctorId() != doctor.getDoctorId()) {
                throw new IllegalAccessException("Unauthorized access to booking");
            }

            record.setBookingId(bookingId);
            record.setPetId(booking.getPetId());
            record.setCustomerId(booking.getCustomerId());

            // Update booking status to completed if not already
            if (!"Hoàn thành".equals(booking.getStatus()) && !"completed".equals(booking.getStatus())) {
                bookingDAO.updateBookingStatus(bookingId, "Hoàn thành");
            }
        } else {
            // Manual creation - require petId and customerId
            String petIdStr = request.getParameter("petId");
            String customerIdStr = request.getParameter("customerId");

            if (petIdStr == null || petIdStr.isEmpty() || customerIdStr == null || customerIdStr.isEmpty()) {
                throw new IllegalArgumentException("Pet ID and Customer ID are required for manual medical record creation");
            }

            record.setPetId(Integer.parseInt(petIdStr));
            record.setCustomerId(Integer.parseInt(customerIdStr));
            // bookingId remains null for manual records
        }

        record.setDoctorId(doctor.getDoctorId());
        record.setExaminationDate(new Timestamp(System.currentTimeMillis()));

        setMedicalRecordFields(request, record);

        if (!medicalRecordDAO.createMedicalRecord(record)) {
            throw new Exception("Failed to create medical record");
        }
    }
    
    private void updateMedicalRecord(HttpServletRequest request, Doctor doctor) throws Exception {
        int recordId = Integer.parseInt(request.getParameter("recordId"));
        MedicalRecord record = getMedicalRecordById(recordId);
        
        if (record == null || record.getDoctorId() != doctor.getDoctorId()) {
            throw new IllegalAccessException("Unauthorized access to medical record");
        }
        
        setMedicalRecordFields(request, record);
        
        if (!medicalRecordDAO.updateMedicalRecord(record)) {
            throw new Exception("Failed to update medical record");
        }
    }
    
    private void setMedicalRecordFields(HttpServletRequest request, MedicalRecord record) {
        record.setSymptoms(request.getParameter("symptoms"));
        record.setDiagnosis(request.getParameter("diagnosis"));
        record.setTreatment(request.getParameter("treatment"));
        record.setPrescription(request.getParameter("prescription"));
        record.setNotes(request.getParameter("notes"));
        
        String weightStr = request.getParameter("weight");
        if (weightStr != null && !weightStr.isEmpty()) {
            record.setWeight(new BigDecimal(weightStr));
        }
        
        String tempStr = request.getParameter("temperature");
        if (tempStr != null && !tempStr.isEmpty()) {
            record.setTemperature(new BigDecimal(tempStr));
        }
        
        String heartRateStr = request.getParameter("heartRate");
        if (heartRateStr != null && !heartRateStr.isEmpty()) {
            record.setHeartRate(Integer.parseInt(heartRateStr));
        }
        
        record.setBloodPressure(request.getParameter("bloodPressure"));
        
        String followUpDateStr = request.getParameter("followUpDate");
        if (followUpDateStr != null && !followUpDateStr.isEmpty()) {
            record.setFollowUpDate(LocalDate.parse(followUpDateStr));
        }
        
        record.setFollowUpNotes(request.getParameter("followUpNotes"));
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

    private MedicalRecord getMedicalRecordById(int recordId) {
        return medicalRecordDAO.getByRecordId(recordId);
    }
}
