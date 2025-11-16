package controller;

import java.sql.*;
import java.util.*;
import dao.WorkScheduleDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.Date;
import java.sql.Time;
import java.util.ArrayList;
import java.util.List;
import model.Staff;
import model.WorkSchedule;
import utils.DBConnection;

@WebServlet("/schedule")
public class WorkScheduleController extends HttpServlet {

    private WorkScheduleDAO dao = new WorkScheduleDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");

        if (action == null || action.equals("list")) {
            // ✅ Lấy danh sách lịch làm việc
            List<WorkSchedule> list = dao.getAllSchedules();
            request.setAttribute("scheduleList", list);

            // 🔧 Forward đúng đường dẫn thật trong thư mục admin
            request.getRequestDispatcher("/admin/manageSchedule.jsp").forward(request, response);
        } else if (action.equals("delete")) {
            // ✅ Xóa lịch làm việc
            int id = Integer.parseInt(request.getParameter("id"));
            dao.deleteSchedule(id);

            // 🔁 Redirect về danh sách sau khi xóa
               response.sendRedirect(request.getContextPath() + "/admin/manage-staff");
        } else if (action.equals("new")) {
            // ✅ Chuyển tới form thêm mới lịch làm việc
            request.getRequestDispatcher("/admin/scheduleForm.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        WorkSchedule ws = new WorkSchedule();
        String idRaw = request.getParameter("scheduleId");

        // ✅ Gán dữ liệu form
        String doctorIdRaw = request.getParameter("doctorId");
        String staffIdRaw = request.getParameter("staffId");

        ws.setDoctorId((doctorIdRaw == null || doctorIdRaw.isEmpty()) ? null : Integer.parseInt(doctorIdRaw));
        ws.setStaffId((staffIdRaw == null || staffIdRaw.isEmpty()) ? null : Integer.parseInt(staffIdRaw));
        ws.setWorkDate(Date.valueOf(request.getParameter("workDate")));
        ws.setStartTime(Time.valueOf(request.getParameter("startTime") + ":00"));
        ws.setEndTime(Time.valueOf(request.getParameter("endTime") + ":00"));
        ws.setStatus(request.getParameter("status"));
        ws.setNote(request.getParameter("note"));

        // ✅ Thêm hoặc cập nhật
        if (idRaw == null || idRaw.isEmpty()) {
            dao.addSchedule(ws);
        } else {
            ws.setScheduleId(Integer.parseInt(idRaw));
            dao.updateSchedule(ws);
        }

        // 🔁 Quay lại danh sách
        response.sendRedirect(request.getContextPath() + "/schedule?action=list");
    }
}
