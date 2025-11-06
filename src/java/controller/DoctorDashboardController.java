package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import dao.BookingDAO;
import dao.DoctorDAO;
import dao.DoctorAttendanceDAO;
import dao.DoctorPayrollDAO;
import model.Doctor;
import model.Booking;
import model.AttendanceRecord;
import model.PayrollRecord;

import java.io.IOException;
import java.time.LocalDate;
import java.util.List;
import java.util.logging.Logger;

/**
 * Controller cho Doctor Dashboard
 * Hiển thị thống kê và appointments cho bác sĩ
 */
@WebServlet("/doctor/dashboard")
public class DoctorDashboardController extends HttpServlet {
    private static final Logger logger = Logger.getLogger(DoctorDashboardController.class.getName());
    private BookingDAO bookingDAO = new BookingDAO();
    private DoctorDAO doctorDAO = new DoctorDAO();
    private DoctorAttendanceDAO attendanceDAO = new DoctorAttendanceDAO();
    private DoctorPayrollDAO payrollDAO = new DoctorPayrollDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        Doctor doctor = (Doctor) session.getAttribute("doctor");

        // Kiểm tra đăng nhập
        if (doctor == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        try {
            int doctorId = doctor.getDoctorId();
            
            // Lấy thông tin doctor đầy đủ
            Doctor fullDoctorInfo = doctorDAO.findById(doctorId);
            if (fullDoctorInfo != null) {
                session.setAttribute("doctor", fullDoctorInfo);
            }
            
            // Lấy lịch hẹn hôm nay
            LocalDate today = LocalDate.now();
            List<Booking> todayAppointments = bookingDAO.getBookingsByDoctorAndDate(doctorId, today);
            
            // Lấy lịch hẹn sắp tới (7 ngày tới)
            LocalDate nextWeek = today.plusDays(7);
            List<Booking> upcomingAppointments = bookingDAO.getBookingsByDoctorAndDateRange(
                doctorId, 
                today.plusDays(1), 
                nextWeek
            );
            
            // Lấy lịch hẹn trong tháng này
            LocalDate startOfMonth = today.withDayOfMonth(1);
            LocalDate endOfMonth = today.withDayOfMonth(today.lengthOfMonth());
            List<Booking> monthlyAppointments = bookingDAO.getBookingsByDoctorAndDateRange(
                doctorId, 
                startOfMonth, 
                endOfMonth
            );
            
            // Thống kê
            int todayCount = todayAppointments.size();
            int upcomingCount = upcomingAppointments.size();
            int monthlyCount = monthlyAppointments.size();
            
            // Đếm theo trạng thái
            long completedCount = monthlyAppointments.stream()
                .filter(b -> "completed".equalsIgnoreCase(b.getStatus()))
                .count();
            
            long pendingCount = monthlyAppointments.stream()
                .filter(b -> "pending".equalsIgnoreCase(b.getStatus()) || 
                            "confirmed".equalsIgnoreCase(b.getStatus()))
                .count();
            
            long inProgressCount = monthlyAppointments.stream()
                .filter(b -> "in_progress".equalsIgnoreCase(b.getStatus()))
                .count();

            // Kiểm tra trạng thái check-in
            boolean isCheckedIn = false;
            var latestAttendance = attendanceDAO.getLatestRecord(doctorId);
            if (latestAttendance != null && latestAttendance.getCheckOut() == null) {
                isCheckedIn = true;
            }
            session.setAttribute("isCheckedIn", isCheckedIn);

            // Lấy phiếu lương mới nhất
            var latestPayroll = payrollDAO.getLatestPayroll(doctorId);
            if (latestPayroll != null) {
                session.setAttribute("latestPayroll", latestPayroll);
            }

            // Set attributes
            request.setAttribute("fullDoctorInfo", fullDoctorInfo);
            request.setAttribute("todayAppointments", todayAppointments);
            request.setAttribute("upcomingAppointments", upcomingAppointments);
            request.setAttribute("todayCount", todayCount);
            request.setAttribute("upcomingCount", upcomingCount);
            request.setAttribute("monthlyCount", monthlyCount);
            request.setAttribute("completedCount", completedCount);
            request.setAttribute("pendingCount", pendingCount);
            request.setAttribute("inProgressCount", inProgressCount);
            request.setAttribute("isCheckedIn", isCheckedIn);

            logger.info("Doctor " + doctor.getName() + " accessed dashboard. Today: " + todayCount +
                       ", Upcoming: " + upcomingCount + ", Monthly: " + monthlyCount);
            
            // Forward to dashboard JSP
            request.getRequestDispatcher("/doctor/doctor-dashboard.jsp").forward(request, response);
            
        } catch (Exception e) {
            logger.severe("Error loading doctor dashboard: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("error", "Có lỗi xảy ra khi tải dashboard: " + e.getMessage());
            request.getRequestDispatcher("/doctor/doctor-dashboard.jsp").forward(request, response);
        }
    }
}

