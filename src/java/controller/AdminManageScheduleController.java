package controller;

import dao.WorkScheduleDAO;
import java.io.IOException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/admin/manageSchedule")
public class AdminManageScheduleController extends HttpServlet {

    private final WorkScheduleDAO dao = new WorkScheduleDAO();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        String action = req.getParameter("action");
        String weekOffset = req.getParameter("weekOffset"); // ✅ giữ lại tuần hiện tại

        switch (action) {
            case "assign" -> {
                int staffId = Integer.parseInt(req.getParameter("staffId"));
                String date = req.getParameter("date");
                int shiftId = Integer.parseInt(req.getParameter("shiftType"));
                dao.assignShift(staffId, date, shiftId);
            }
            case "unassign" -> {
                int scheduleId = Integer.parseInt(req.getParameter("scheduleId"));
                dao.deleteSchedule(scheduleId);
            }
        }

        // ✅ Redirect về đúng tab và đúng tuần
        String redirectUrl = req.getContextPath() + "/admin/manage-staff?tab=worktable";
        if (weekOffset != null && !weekOffset.isEmpty()) {
            redirectUrl += "&weekOffset=" + weekOffset;
        }
        resp.sendRedirect(redirectUrl);
    }
}
