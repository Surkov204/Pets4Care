package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import dao.BookingDAO;
import dao.MedicalRecordDAO;
import model.Doctor;
import model.Booking;
import model.MedicalRecord;

import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Timestamp;
import java.time.LocalDate;
import java.util.logging.Logger;

/**
 * Servlet để cập nhật medical record
 * Cho phép doctor cập nhật thông tin khám bệnh chi tiết
 */
@WebServlet("/doctor/update-medical-record")
public class UpdateMedicalRecordServlet extends HttpServlet {
    private static final Logger logger = Logger.getLogger(UpdateMedicalRecordServlet.class.getName());
    private BookingDAO bookingDAO = new BookingDAO();
    private MedicalRecordDAO medicalRecordDAO = new MedicalRecordDAO();

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
        
        try {
            // Lấy parameters
            String bookingIdStr = request.getParameter("bookingId");
            String symptoms = request.getParameter("symptoms");
            String diagnosis = request.getParameter("diagnosis");
            String treatment = request.getParameter("treatment");
            String prescription = request.getParameter("prescription");
            String weightStr = request.getParameter("weight");
            String temperatureStr = request.getParameter("temperature");
            String heartRateStr = request.getParameter("heartRate");
            String bloodPressure = request.getParameter("bloodPressure");
            String notes = request.getParameter("notes");
            String followUpDateStr = request.getParameter("followUpDate");
            String followUpNotes = request.getParameter("followUpNotes");
            String newStatus = request.getParameter("status");
            
            if (bookingIdStr == null || bookingIdStr.trim().isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/doctor/medical-record.jsp?error=missing_booking_id");
                return;
            }
            
            int bookingId = Integer.parseInt(bookingIdStr);
            
            // Kiểm tra booking có thuộc về doctor này không
            Booking booking = bookingDAO.getBookingById(bookingId);
            if (booking == null) {
                response.sendRedirect(request.getContextPath() + "/doctor/medical-record.jsp?error=booking_not_found");
                return;
            }
            
            if (booking.getDoctorId() != doctor.getDoctorId()) {
                response.sendRedirect(request.getContextPath() + "/doctor/medical-record.jsp?error=unauthorized");
                return;
            }
            
            // Kiểm tra xem đã có medical record chưa
            MedicalRecord existingRecord = medicalRecordDAO.getByBookingId(bookingId);
            
            MedicalRecord record;
            boolean isUpdate = false;
            
            if (existingRecord != null) {
                // Cập nhật record hiện có
                record = existingRecord;
                isUpdate = true;
            } else {
                // Tạo record mới
                record = new MedicalRecord(bookingId, booking.getPetId(), doctor.getDoctorId(), booking.getCustomerId());
                record.setExaminationDate(new Timestamp(System.currentTimeMillis()));
            }
            
            // Set các thông tin
            record.setSymptoms(symptoms);
            record.setDiagnosis(diagnosis);
            record.setTreatment(treatment);
            record.setPrescription(prescription);
            
            // Parse và set weight
            if (weightStr != null && !weightStr.trim().isEmpty()) {
                try {
                    record.setWeight(new BigDecimal(weightStr));
                } catch (NumberFormatException e) {
                    logger.warning("Invalid weight format: " + weightStr);
                }
            }
            
            // Parse và set temperature
            if (temperatureStr != null && !temperatureStr.trim().isEmpty()) {
                try {
                    record.setTemperature(new BigDecimal(temperatureStr));
                } catch (NumberFormatException e) {
                    logger.warning("Invalid temperature format: " + temperatureStr);
                }
            }
            
            // Parse và set heart rate
            if (heartRateStr != null && !heartRateStr.trim().isEmpty()) {
                try {
                    record.setHeartRate(Integer.parseInt(heartRateStr));
                } catch (NumberFormatException e) {
                    logger.warning("Invalid heart rate format: " + heartRateStr);
                }
            }
            
            record.setBloodPressure(bloodPressure);
            record.setNotes(notes);
            
            // Parse và set follow-up date
            if (followUpDateStr != null && !followUpDateStr.trim().isEmpty()) {
                try {
                    record.setFollowUpDate(LocalDate.parse(followUpDateStr));
                } catch (Exception e) {
                    logger.warning("Invalid follow-up date format: " + followUpDateStr);
                }
            }
            
            record.setFollowUpNotes(followUpNotes);
            
            // Lưu medical record
            boolean recordSuccess;
            if (isUpdate) {
                recordSuccess = medicalRecordDAO.updateMedicalRecord(record);
            } else {
                recordSuccess = medicalRecordDAO.createMedicalRecord(record);
            }
            
            // Cập nhật status của booking nếu có
            boolean statusSuccess = true;
            if (newStatus != null && !newStatus.trim().isEmpty() && !newStatus.equals(booking.getStatus())) {
                statusSuccess = bookingDAO.updateBookingStatus(bookingId, newStatus);
            }
            
            if (recordSuccess && statusSuccess) {
                logger.info("Doctor " + doctor.getName() + " " + (isUpdate ? "updated" : "created") + 
                           " medical record for booking " + bookingId);
                response.sendRedirect(request.getContextPath() + "/doctor/medical-record.jsp?success=updated");
            } else {
                response.sendRedirect(request.getContextPath() + "/doctor/medical-record.jsp?error=update_failed");
            }
            
        } catch (NumberFormatException e) {
            logger.warning("Invalid number format: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/doctor/medical-record.jsp?error=invalid_format");
        } catch (Exception e) {
            logger.severe("Error updating medical record: " + e.getMessage());
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/doctor/medical-record.jsp?error=system_error");
        }
    }
}

