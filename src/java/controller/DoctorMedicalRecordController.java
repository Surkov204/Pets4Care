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
                    logger.info("Medical record found for booking ID: " + record.getBookingId());
                }
            }
            logger.info("Total medical records: " + medicalRecords.size() + ", Bookings with records: " + bookingsWithRecords.size());

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
                    logger.info("Skipping booking ID " + appointment.getBookingId() + " - already has medical record");
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
                return;
            } else if ("update".equals(action)) {
                updateMedicalRecord(request, doctor);
                response.sendRedirect(request.getContextPath() + "/doctor/medical-records?success=updated");
                return;
            } else {
                response.sendRedirect(request.getContextPath() + "/doctor/medical-records");
                return;
            }
            
        } catch (NumberFormatException e) {
            logger.severe("Invalid parameter format: " + e.getMessage());
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/doctor/medical-records?error=invalid_parameter");
            return;
        } catch (IllegalArgumentException e) {
            logger.severe("Validation error: " + e.getMessage());
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/doctor/medical-records?error=" + java.net.URLEncoder.encode(e.getMessage(), "UTF-8"));
            return;
        } catch (IllegalAccessException e) {
            logger.severe("Authorization error: " + e.getMessage());
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/doctor/medical-records?error=unauthorized");
            return;
        } catch (java.sql.SQLException e) {
            logger.severe("Database error: " + e.getMessage());
            logger.severe("SQL State: " + e.getSQLState() + ", Error Code: " + e.getErrorCode());
            e.printStackTrace();
            String errorMsg = "Database error occurred";
            if (e.getErrorCode() == 547) {
                errorMsg = "Foreign key constraint violation - please check booking, pet, customer, or doctor exists";
            }
            response.sendRedirect(request.getContextPath() + "/doctor/medical-records?error=" + java.net.URLEncoder.encode(errorMsg, "UTF-8"));
            return;
        } catch (Exception e) {
            logger.severe("Error processing medical record: " + e.getMessage());
            logger.severe("Exception type: " + e.getClass().getName());
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/doctor/medical-records?error=" + java.net.URLEncoder.encode(e.getMessage() != null ? e.getMessage() : "Unknown error", "UTF-8"));
            return;
        }
    }
    
    private void createMedicalRecord(HttpServletRequest request, Doctor doctor) throws Exception {
        MedicalRecord record = new MedicalRecord();

        String bookingIdStr = request.getParameter("bookingId");
        if (bookingIdStr == null || bookingIdStr.isEmpty()) {
            logger.severe("Cannot create medical record: bookingId parameter is missing");
            throw new IllegalArgumentException("Booking ID is required to create medical record");
        }
        
        try {
            int bookingId = Integer.parseInt(bookingIdStr);
            logger.info("Creating medical record for booking ID: " + bookingId);
            
            Booking booking = bookingDAO.getBookingById(bookingId);
            if (booking == null) {
                logger.severe("Booking not found: " + bookingId);
                throw new IllegalArgumentException("Booking not found: " + bookingId);
            }
            
            if (booking.getDoctorId() != doctor.getDoctorId()) {
                logger.severe("Unauthorized: Doctor " + doctor.getDoctorId() + " trying to access booking " + bookingId + " (belongs to doctor " + booking.getDoctorId() + ")");
                throw new IllegalAccessException("Unauthorized access to booking");
            }

            record.setBookingId(bookingId);
            record.setPetId(booking.getPetId());
            record.setCustomerId(booking.getCustomerId());
            
            logger.info("Medical record setup - Booking ID: " + bookingId + ", Pet ID: " + booking.getPetId() + ", Customer ID: " + booking.getCustomerId());

            // Update booking status to completed if not already
            if (!"Hoàn thành".equals(booking.getStatus()) && !"completed".equals(booking.getStatus())) {
                boolean statusUpdated = bookingDAO.updateBookingStatus(bookingId, "Hoàn thành");
                logger.info("Updated booking " + bookingId + " status to 'Hoàn thành': " + statusUpdated);
            } else {
                logger.info("Booking " + bookingId + " already has status: " + booking.getStatus());
            }
        } catch (NumberFormatException e) {
            logger.severe("Invalid booking ID format: " + bookingIdStr);
            throw new IllegalArgumentException("Invalid booking ID format: " + bookingIdStr);
        }

        record.setDoctorId(doctor.getDoctorId());
        record.setExaminationDate(new Timestamp(System.currentTimeMillis()));
        
        logger.info("Medical record before setting fields - Doctor ID: " + doctor.getDoctorId() + ", Examination Date: " + record.getExaminationDate());

        setMedicalRecordFields(request, record);
        
        logger.info("Medical record fields set. Attempting to create in database...");

        try {
            if (!medicalRecordDAO.createMedicalRecord(record)) {
                logger.severe("Failed to create medical record - createMedicalRecord returned false");
                throw new Exception("Failed to create medical record - database operation returned false");
            }
            logger.info("Successfully created medical record ID: " + record.getRecordId() + " for booking ID: " + record.getBookingId());
        } catch (Exception e) {
            logger.severe("Exception during medical record creation: " + e.getMessage());
            logger.severe("Exception type: " + e.getClass().getName());
            e.printStackTrace();
            throw e;
        }
    }
    
    private void updateMedicalRecord(HttpServletRequest request, Doctor doctor) throws Exception {
        String recordIdStr = request.getParameter("recordId");
        if (recordIdStr == null || recordIdStr.trim().isEmpty()) {
            throw new IllegalArgumentException("Record ID is required");
        }
        
        int recordId;
        try {
            recordId = Integer.parseInt(recordIdStr);
        } catch (NumberFormatException e) {
            throw new IllegalArgumentException("Invalid record ID format: " + recordIdStr);
        }
        
        MedicalRecord record = getMedicalRecordById(recordId);
        if (record == null) {
            throw new IllegalArgumentException("Medical record not found: " + recordId);
        }
        
        if (record.getDoctorId() != doctor.getDoctorId()) {
            throw new IllegalAccessException("Unauthorized access to medical record");
        }
        
        setMedicalRecordFields(request, record);
        
        if (!medicalRecordDAO.updateMedicalRecord(record)) {
            throw new Exception("Failed to update medical record - database operation returned false");
        }
        
        logger.info("Successfully updated medical record ID: " + recordId);
    }
    
    private void setMedicalRecordFields(HttpServletRequest request, MedicalRecord record) {
        record.setSymptoms(request.getParameter("symptoms"));
        record.setDiagnosis(request.getParameter("diagnosis"));
        record.setTreatment(request.getParameter("treatment"));
        record.setPrescription(request.getParameter("prescription"));
        record.setNotes(request.getParameter("notes"));
        
        String weightStr = request.getParameter("weight");
        if (weightStr != null && !weightStr.trim().isEmpty()) {
            try {
                record.setWeight(new BigDecimal(weightStr));
            } catch (NumberFormatException e) {
                record.setWeight(null);
            }
        } else {
            record.setWeight(null);
        }
        
        String tempStr = request.getParameter("temperature");
        if (tempStr != null && !tempStr.trim().isEmpty()) {
            try {
                record.setTemperature(new BigDecimal(tempStr));
            } catch (NumberFormatException e) {
                record.setTemperature(null);
            }
        } else {
            record.setTemperature(null);
        }
        
        String heartRateStr = request.getParameter("heartRate");
        if (heartRateStr != null && !heartRateStr.trim().isEmpty()) {
            try {
                record.setHeartRate(Integer.parseInt(heartRateStr));
            } catch (NumberFormatException e) {
                record.setHeartRate(null);
            }
        } else {
            record.setHeartRate(null);
        }
        
        String bloodPressure = request.getParameter("bloodPressure");
        record.setBloodPressure(bloodPressure != null && !bloodPressure.trim().isEmpty() ? bloodPressure : null);
        
        String followUpDateStr = request.getParameter("followUpDate");
        if (followUpDateStr != null && !followUpDateStr.trim().isEmpty()) {
            try {
                record.setFollowUpDate(LocalDate.parse(followUpDateStr));
            } catch (Exception e) {
                record.setFollowUpDate(null);
            }
        } else {
            record.setFollowUpDate(null);
        }
        
        String followUpNotes = request.getParameter("followUpNotes");
        record.setFollowUpNotes(followUpNotes != null && !followUpNotes.trim().isEmpty() ? followUpNotes : null);
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
