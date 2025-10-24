package controller;

import dao.ShiftRegistrationDAO;
import dao.ShiftDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.Date;
import java.time.LocalDate;
import java.util.List;
import model.Shift;
import model.WorkSchedule;
import model.Staff;

@WebServlet("/staff/register-shift")
public class ShiftRegistrationController extends HttpServlet {

    private ShiftRegistrationDAO regDAO = new ShiftRegistrationDAO();
    private ShiftDAO shiftDAO = new ShiftDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        Staff staff = (Staff) session.getAttribute("staff");

        if (staff == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        // Lấy ngày hiện tại hoặc ngày được chọn
        String dateParam = request.getParameter("date");
        session.setAttribute("successMessage", "✅ Đăng ký ca thành công!");
        
        LocalDate baseDate = (dateParam == null)
                ? LocalDate.now()
                : LocalDate.parse(dateParam);

        // Lấy danh sách 7 ngày trong tuần hiện tại
        LocalDate startOfWeek = baseDate.minusDays(baseDate.getDayOfWeek().getValue() - 1);
        LocalDate endOfWeek = startOfWeek.plusDays(6);

        List<Shift> shiftList = shiftDAO.getAllShifts();
        List<WorkSchedule> registered = regDAO.getRegisteredShifts(staff.getStaffId(), Date.valueOf(startOfWeek), Date.valueOf(endOfWeek));

        request.setAttribute("shiftList", shiftList);
        request.setAttribute("registeredList", registered);
        request.setAttribute("startOfWeek", startOfWeek);
        request.setAttribute("endOfWeek", endOfWeek);
        request.setAttribute("today", LocalDate.now());

        request.getRequestDispatcher("/staff/registerShift.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession();
        Staff staff = (Staff) session.getAttribute("staff");

        if (staff == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String action = request.getParameter("action");
        int shiftId = Integer.parseInt(request.getParameter("shiftId"));
        Date workDate = Date.valueOf(request.getParameter("workDate"));

        if ("register".equals(action)) {
            regDAO.registerShift(staff.getStaffId(), shiftId, workDate);
        } else if ("cancel".equals(action)) {
            regDAO.cancelShift(staff.getStaffId(), shiftId, workDate);
        }

        response.sendRedirect(request.getContextPath() + "/staff/register-shift?date=" + workDate);
    }
}
