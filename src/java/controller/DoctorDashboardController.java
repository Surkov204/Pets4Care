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
import dao.WorkScheduleDAO;
import model.Doctor;
import model.Booking;
import model.AttendanceRecord;
import model.PayrollRecord;
import model.WorkSchedule;

import java.io.IOException;
import java.time.LocalDate;
import java.util.List;
import java.util.logging.Logger;

@WebServlet("/doctor/dashboard")
public class DoctorDashboardController extends HttpServlet {
    private static final Logger logger = Logger.getLogger(DoctorDashboardController.class.getName());
    private BookingDAO bookingDAO = new BookingDAO();
    private DoctorDAO doctorDAO = new DoctorDAO();
    private DoctorAttendanceDAO attendanceDAO = new DoctorAttendanceDAO();
    private DoctorPayrollDAO payrollDAO = new DoctorPayrollDAO();
    private WorkScheduleDAO workScheduleDAO = new WorkScheduleDAO();

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
            
            Doctor fullDoctorInfo = doctorDAO.findById(doctorId);
            if (fullDoctorInfo != null) {
                session.setAttribute("doctor", fullDoctorInfo);
            }
            
            LocalDate today = LocalDate.now();
            logger.info("Loading dashboard for doctor ID: " + doctorId + ", Today: " + today);
            
            // Debug: Check recent bookings for this doctor to see what dates they have
            LocalDate debugStart = today.minusDays(7);
            LocalDate debugEnd = today.plusDays(7);
            List<Booking> recentBookings = bookingDAO.getBookingsByDoctorAndDateRange(doctorId, debugStart, debugEnd);
            logger.info("Total bookings for doctor " + doctorId + " in range [" + debugStart + " to " + debugEnd + "]: " + recentBookings.size());
            for (Booking b : recentBookings) {
                if (b.getAppointmentStart() != null) {
                    LocalDate bookingDate = b.getAppointmentStart().toLocalDateTime().toLocalDate();
                    logger.info("Booking ID=" + b.getBookingId() + 
                               ", Appointment Date=" + bookingDate + 
                               ", Today=" + today + 
                               ", Match=" + bookingDate.equals(today) +
                               ", Status=" + b.getStatus());
                } else {
                    logger.warning("Booking ID=" + b.getBookingId() + " has NULL appointment_start");
                }
            }
            
            List<Booking> todayAppointments = bookingDAO.getBookingsByDoctorAndDate(doctorId, today);
            logger.info("Found " + todayAppointments.size() + " appointments for today");
            if (!todayAppointments.isEmpty()) {
                logger.info("First appointment: ID=" + todayAppointments.get(0).getBookingId() + 
                           ", Start=" + todayAppointments.get(0).getAppointmentStart() + 
                           ", Status=" + todayAppointments.get(0).getStatus());
            }
            
            LocalDate nextWeek = today.plusDays(7);
            List<Booking> upcomingAppointments = bookingDAO.getBookingsByDoctorAndDateRange(
                doctorId, 
                today.plusDays(1), 
                nextWeek
            );
            
            LocalDate startOfMonth = today.withDayOfMonth(1);
            LocalDate endOfMonth = today.withDayOfMonth(today.lengthOfMonth());
            List<Booking> monthlyAppointments = bookingDAO.getBookingsByDoctorAndDateRange(
                doctorId, 
                startOfMonth, 
                endOfMonth
            );
            
            int todayCount = todayAppointments.size();
            int upcomingCount = upcomingAppointments.size();
            int monthlyCount = monthlyAppointments.size();
            
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

            boolean isCheckedIn = false;
            var latestAttendance = attendanceDAO.getLatestRecord(doctorId);
            if (latestAttendance != null && latestAttendance.getCheckOut() == null) {
                isCheckedIn = true;
            }
            session.setAttribute("isCheckedIn", isCheckedIn);

            var latestPayroll = payrollDAO.getLatestPayroll(doctorId);
            if (latestPayroll != null) {
                session.setAttribute("latestPayroll", latestPayroll);
            }

            WorkSchedule todaySchedule = workScheduleDAO.getTodayScheduleForDoctor(doctorId);
            List<WorkSchedule> upcomingSchedules = workScheduleDAO.getUpcomingScheduleForDoctor(doctorId, 7);

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
            request.setAttribute("todaySchedule", todaySchedule);
            request.setAttribute("upcomingSchedules", upcomingSchedules);

            logger.info("Doctor " + doctor.getName() + " accessed dashboard. Today: " + todayCount +
                       ", Upcoming: " + upcomingCount + ", Monthly: " + monthlyCount);
            
            request.getRequestDispatcher("/doctor/doctor-dashboard.jsp").forward(request, response);
            
        } catch (Exception e) {
            logger.severe("Error loading doctor dashboard: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("error", "Có lỗi xảy ra khi tải dashboard: " + e.getMessage());
            request.getRequestDispatcher("/doctor/doctor-dashboard.jsp").forward(request, response);
        }
    }
}
