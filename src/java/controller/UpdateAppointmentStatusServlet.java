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
import java.sql.Timestamp;
import java.util.logging.Logger;

@WebServlet("/update-appointment-status")
public class UpdateAppointmentStatusServlet extends HttpServlet {
    private BookingDAO bookingDAO = new BookingDAO();
    private MedicalRecordDAO medicalRecordDAO = new MedicalRecordDAO();
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
            response.sendRedirect(request.getContextPath() + "/doctor/appointments?error=missing_parameters");
            return;
        }
        
        try {
            int bookingId = Integer.parseInt(bookingIdStr);

            // Lấy thông tin booking trước khi cập nhật
            Booking booking = bookingDAO.getBookingById(bookingId);
            if (booking == null) {
                response.sendRedirect(request.getContextPath() + "/doctor/appointments?error=booking_not_found");
                return;
            }

            // Kiểm tra quyền sở hữu
            if (booking.getDoctorId() != doctor.getDoctorId()) {
                response.sendRedirect(request.getContextPath() + "/doctor/appointments?error=unauthorized");
                return;
            }

            // Cập nhật trạng thái
            boolean success = bookingDAO.updateBookingStatus(bookingId, status);

            if (success) {
                logger.info("Doctor " + doctor.getName() + " updated booking " + bookingId + " status to " + status);

                // Nếu trạng thái được cập nhật thành "completed", tự động tạo medical record
                if ("completed".equals(status)) {
                    createMedicalRecordForCompletedAppointment(booking, doctor);
                }

                response.sendRedirect(request.getContextPath() + "/doctor/appointments?success=status_updated");
            } else {
                response.sendRedirect(request.getContextPath() + "/doctor/appointments?error=update_failed");
            }
            
        } catch (NumberFormatException e) {
            logger.warning("Invalid booking ID: " + bookingIdStr);
            response.sendRedirect(request.getContextPath() + "/doctor/appointments?error=invalid_booking_id");
        } catch (Exception e) {
            logger.severe("Error updating appointment status: " + e.getMessage());
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/doctor/appointments?error=system_error");
        }
    }

    /**
     * Tự động tạo medical record khi appointment được đánh dấu hoàn thành
     */
    private void createMedicalRecordForCompletedAppointment(Booking booking, Doctor doctor) {
        try {
            // Kiểm tra xem đã có medical record cho booking này chưa
            MedicalRecord existingRecord = medicalRecordDAO.getByBookingId(booking.getBookingId());
            if (existingRecord != null) {
                logger.info("Medical record already exists for booking " + booking.getBookingId());
                return;
            }

            // Tạo medical record mới
            MedicalRecord record = new MedicalRecord();
            record.setBookingId(booking.getBookingId());
            record.setPetId(booking.getPetId());
            record.setDoctorId(doctor.getDoctorId());
            record.setCustomerId(booking.getCustomerId());
            record.setExaminationDate(new Timestamp(System.currentTimeMillis()));

            // Thiết lập thông tin cơ bản từ booking note nếu có
            if (booking.getNote() != null && !booking.getNote().trim().isEmpty()) {
                record.setNotes("Ghi chú từ lịch hẹn: " + booking.getNote().trim());
            } else {
                record.setNotes("Khám định kỳ - hoàn thành theo lịch hẹn");
            }

            // Các trường khác để trống, bác sĩ có thể cập nhật sau
            record.setSymptoms("");
            record.setDiagnosis("");
            record.setTreatment("");
            record.setPrescription("");

            boolean success = medicalRecordDAO.createMedicalRecord(record);

            if (success) {
                logger.info("Automatically created medical record for completed booking " + booking.getBookingId());
            } else {
                logger.severe("Failed to create medical record for booking " + booking.getBookingId());
            }

        } catch (Exception e) {
            logger.severe("Error creating medical record for completed appointment: " + e.getMessage());
            e.printStackTrace();
        }
    }
}
