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
        String weekOffset = req.getParameter("weekOffset");

        switch (action) {

            case "assign" -> {
                String person = req.getParameter("personId");  // nhận staff-5 hoặc doctor-2
                String date = req.getParameter("date");
                int shiftId = Integer.parseInt(req.getParameter("shiftType"));

                Integer staffId = null;
                Integer doctorId = null;

                // staff-12
                if (person.startsWith("staff-")) {
                    staffId = Integer.parseInt(person.substring(6));
                } // doctor-7
                else if (person.startsWith("doctor-")) {
                    doctorId = Integer.parseInt(person.substring(7));
                }

                // gọi DAO phù hợp
                dao.assignShift(staffId, doctorId, date, shiftId);
            }

            case "unassign" -> {
                int scheduleId = Integer.parseInt(req.getParameter("scheduleId"));
                dao.deleteSchedule(scheduleId);
            }
        }

        // redirect đúng tuần & tab
        String redirectUrl = req.getContextPath() + "/admin/manage-staff?tab=worktable";
        if (weekOffset != null) {
            redirectUrl += "&weekOffset=" + weekOffset;
        }
        resp.sendRedirect(redirectUrl);
    }
    
}
