package controller;

import dao.DoctorAttendanceDAO;
import dao.DoctorPayrollDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Date;
import java.time.LocalDate;

import model.AttendanceRecord;
import model.Doctor;
import model.DoctorPayrollRecord;   // 🔥 dùng model mới

@WebServlet("/doctor/attendance")
public class DoctorAttendanceController extends HttpServlet {

    private final DoctorAttendanceDAO attendanceDAO = new DoctorAttendanceDAO();
    private final DoctorPayrollDAO payrollDAO = new DoctorPayrollDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json;charset=UTF-8");
        PrintWriter out = response.getWriter();

        HttpSession session = request.getSession();
        Doctor doctor = (Doctor) session.getAttribute("doctor");

        if (doctor == null) {
            out.write("{\"status\":\"error\",\"message\":\"⚠️ Vui lòng đăng nhập.\"}");
            return;
        }

        int doctorId = doctor.getDoctorId();
        String action = request.getParameter("action");
        boolean success = false;

        if ("toggle".equals(action)) {
            // Check-in / Check-out
            AttendanceRecord last = attendanceDAO.getLatestRecord(doctorId);

            if (last != null && last.getCheckOut() == null) {
                success = attendanceDAO.doctorCheckOut(doctorId);
                if (success) session.setAttribute("isCheckedIn", false);

                out.write(success
                        ? "{\"status\":\"success\",\"message\":\"✅ Check-out thành công! Nghỉ ngơi nhé.\"}"
                        : "{\"status\":\"error\",\"message\":\"❌ Lỗi khi check-out.\"}");
            } 
            else {
                success = attendanceDAO.doctorCheckIn(doctorId);
                if (success) session.setAttribute("isCheckedIn", true);

                out.write(success
                        ? "{\"status\":\"success\",\"message\":\"✅ Check-in thành công!\"}"
                        : "{\"status\":\"error\",\"message\":\"❌ Lỗi khi check-in.\"}");
            }

        } else if ("generate".equals(action)) {

            LocalDate today = LocalDate.now();
            LocalDate firstDay = today.withDayOfMonth(1);
            LocalDate lastDay = today.withDayOfMonth(today.lengthOfMonth());

            success = payrollDAO.generatePayroll(
                    doctorId,
                    Date.valueOf(firstDay),
                    Date.valueOf(lastDay)
            );

            if (success) {
                DoctorPayrollRecord latest = payrollDAO.getLatestPayroll(doctorId);
                session.setAttribute("latestPayroll", latest);

                out.write("{\"status\":\"success\",\"message\":\"💰 Lương tháng này đã được tính thành công!\"}");
            } else {
                out.write("{\"status\":\"error\",\"message\":\"⚠️ Có lỗi khi tính lương.\"}");
            }
        }
    }
}