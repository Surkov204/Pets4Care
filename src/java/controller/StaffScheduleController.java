package controller;

import dao.WorkScheduleDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;
import model.Staff; // nhớ đã có Staff model trong project
import model.WorkSchedule;

@WebServlet("/staff/mySchedule")
public class StaffScheduleController extends HttpServlet {
    private WorkScheduleDAO dao = new WorkScheduleDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        Staff staff = (Staff) session.getAttribute("staff");

        if (staff == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        List<WorkSchedule> scheduleList = dao.getScheduleByStaff(staff.getStaffId());
        request.setAttribute("scheduleList", scheduleList);
        request.getRequestDispatcher("/staff/mySchedule.jsp").forward(request, response);
    }
}
