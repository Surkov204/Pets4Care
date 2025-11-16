package controller;

import dao.*;
import model.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.*;

@WebServlet("/admin/manage-staff")
public class AdminStaffServlet extends HttpServlet {

    private StaffDAO staffDAO = new StaffDAO();
    private WorkScheduleDAO scheduleDAO = new WorkScheduleDAO();
    private DoctorDAO doctorDAO = new DoctorDAO();
    private ShiftDAO shiftDAO = new ShiftDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        Admin admin = (Admin) session.getAttribute("admin");

        if (admin == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        // TAB selection
        String tab = request.getParameter("tab");
        if (tab == null) tab = "info";

        // === TAB 1: STAFF LIST ===
        String keyword = request.getParameter("keyword");
        String positionFilter = request.getParameter("position");

        List<Staff> staffList;
        if (keyword != null && !keyword.trim().isEmpty()) {
            staffList = staffDAO.searchStaff(keyword.trim());
        } else if (positionFilter != null && !"all".equals(positionFilter)) {
            staffList = staffDAO.getStaffByPosition(positionFilter);
        } else {
            staffList = staffDAO.getAllStaff();
        }

        request.setAttribute("staffList", staffList);
        request.setAttribute("adminCount", staffDAO.getStaffByPosition("admin").size());
        request.setAttribute("managerCount", staffDAO.getStaffByPosition("quản lý").size());
        request.setAttribute("staffCount", staffDAO.getStaffByPosition("nhân viên").size());
        request.setAttribute("keyword", keyword);
        request.setAttribute("positionFilter", positionFilter);

        // === TAB 2–5 REQUIRE MORE DATA ===
        if (!tab.equals("info")) {

            // == LOAD DOCTOR LIST ==
            List<Doctor> doctorList = doctorDAO.getAllExcept(0);
            request.setAttribute("doctorList", doctorList);

            Map<Integer, String> doctorNameMap = new HashMap<>();
            for (Doctor d : doctorList) {
                doctorNameMap.put(d.getDoctorId(), d.getName());
            }
            request.setAttribute("doctorNameMap", doctorNameMap);

            // == LOAD STAFF NAME MAP ==
            Map<Integer, String> staffNameMap = new HashMap<>();
            for (Staff s : staffDAO.getAllStaff()) {
                staffNameMap.put(s.getStaffId(), s.getName());
            }
            request.setAttribute("staffNameMap", staffNameMap);

            // == LOAD SHIFTS ==
            List<Shift> shiftList = shiftDAO.getAllShifts();
            request.setAttribute("shiftList", shiftList);

            // == LOAD SCHEDULE ==
            List<WorkSchedule> scheduleList = scheduleDAO.getAllSchedules();
            request.setAttribute("scheduleList", scheduleList);
        }

        request.setAttribute("tab", tab);

        request.getRequestDispatcher("/admin/manage-staff.jsp")
                .forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        Admin admin = (Admin) session.getAttribute("admin");

        if (admin == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String action = request.getParameter("action");
        if ("delete".equals(action)) {
            try {
                int staffId = Integer.parseInt(request.getParameter("staffId"));
                boolean success = staffDAO.deleteStaff(staffId);

                if (success) {
                    session.setAttribute("successMessage", "Xóa nhân viên thành công!");
                } else {
                    session.setAttribute("errorMessage", "Không thể xóa nhân viên!");
                }
            } catch (Exception e) {
                session.setAttribute("errorMessage", "Có lỗi xảy ra: " + e.getMessage());
            }
        }

        response.sendRedirect("manage-staff?tab=info");
    }
}