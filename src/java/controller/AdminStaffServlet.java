package controller;

import dao.StaffDAO;
import model.Admin;
import model.Staff;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

@WebServlet("/admin/manage-staff")
public class AdminStaffServlet extends HttpServlet {

    private StaffDAO staffDAO = new StaffDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Kiểm tra đăng nhập admin
        HttpSession session = request.getSession();
        Admin admin = (Admin) session.getAttribute("admin");
        if (admin == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String keyword = request.getParameter("keyword");
        String positionFilter = request.getParameter("position");

        List<Staff> staffList;

        // Lọc theo điều kiện
        if (keyword != null && !keyword.trim().isEmpty()) {
            staffList = staffDAO.searchStaff(keyword.trim());
        } else if (positionFilter != null && !"all".equals(positionFilter)) {
            staffList = staffDAO.getStaffByPosition(positionFilter);
        } else {
            staffList = staffDAO.getAllStaff();
        }

        // Đếm số nhân viên theo vị trí
        int adminCount = staffDAO.getStaffByPosition("admin").size();
        int managerCount = staffDAO.getStaffByPosition("quản lý").size();
        int staffCount = staffDAO.getStaffByPosition("nhân viên").size();

        request.setAttribute("staffList", staffList);
        request.setAttribute("adminCount", adminCount);
        request.setAttribute("managerCount", managerCount);
        request.setAttribute("staffCount", staffCount);
        request.setAttribute("keyword", keyword);
        request.setAttribute("positionFilter", positionFilter);

        request.getRequestDispatcher("/admin/manage-staff.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Kiểm tra đăng nhập admin
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

        // Redirect về trang quản lý
        response.sendRedirect("manage-staff");
    }
}

