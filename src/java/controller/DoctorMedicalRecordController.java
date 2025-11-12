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
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Logger;

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
            }
            
            List<MedicalRecord> medicalRecords = medicalRecordDAO.getByDoctorId(doctorId);

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
                if ("Hoàn thành".equals(appointment.getStatus()) || "completed".equals(appointment.getStatus())) {
                    completedAppointments.add(appointment);
                } else if ("pending".equals(appointment.getStatus()) || "Chờ xác nhận".equals(appointment.getStatus())) {
                    pendingAppointments.add(appointment);
                } else if ("confirmed".equals(appointment.getStatus()) || "Đã xác nhận".equals(appointment.getStatus())) {
                    upcomingAppointments.add(appointment);
                }
            }
            
            request.setAttribute("medicalRecords", medicalRecords);
            request.setAttribute("completedAppointments", completedAppointments);
            request.setAttribute("pendingAppointments", pendingAppointments);
            request.setAttribute("upcomingAppointments", upcomingAppointments);
            
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

        int bookingId = Integer.parseInt(request.getParameter("bookingId"));
        Booking booking = bookingDAO.getBookingById(bookingId);

        if (booking == null || booking.getDoctorId() != doctor.getDoctorId()) {
            throw new IllegalAccessException("Unauthorized access to booking");
        }

        record.setBookingId(bookingId);
        record.setPetId(booking.getPetId());
        record.setDoctorId(doctor.getDoctorId());
        record.setCustomerId(booking.getCustomerId());
        record.setExaminationDate(new Timestamp(System.currentTimeMillis()));

        setMedicalRecordFields(request, record);

        if (!medicalRecordDAO.createMedicalRecord(record)) {
            throw new Exception("Failed to create medical record");
        }

        // Update booking status to completed
        bookingDAO.updateBookingStatus(bookingId, "Hoàn thành");

        // Also save to medical history - this is already handled by the MedicalRecord table
        // which stores all completed appointments with medical records
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
    
    private MedicalRecord getMedicalRecordById(int recordId) {
        return medicalRecordDAO.getByRecordId(recordId);
    }
}
