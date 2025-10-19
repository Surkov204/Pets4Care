package controller;

import dao.ShiftDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;
import model.Shift;

@WebServlet("/shift")
public class ShiftController extends HttpServlet {

    private ShiftDAO dao = new ShiftDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");

        if (action == null || action.equals("list")) {
            // ✅ Lấy toàn bộ danh sách ca làm việc
            List<Shift> list = dao.getAllShifts();
            request.setAttribute("shiftList", list);

            // 🔧 Sửa đúng đường dẫn thực tế của JSP
            request.getRequestDispatcher("/admin/manageShift.jsp").forward(request, response);
        }

        else if (action.equals("delete")) {
            // ✅ Xóa ca làm
            int id = Integer.parseInt(request.getParameter("id"));
            dao.deleteShift(id);

            // 🔁 Redirect về danh sách
            response.sendRedirect(request.getContextPath() + "/shift?action=list");
        }

        else if (action.equals("edit")) {
            // ✅ Lấy thông tin ca làm để chỉnh sửa
            int id = Integer.parseInt(request.getParameter("id"));
            Shift s = dao.getShiftById(id);
            request.setAttribute("shift", s);

            // 🔧 Chuyển đến form sửa
            request.getRequestDispatcher("/admin/shiftForm.jsp").forward(request, response);
        }

        else if (action.equals("new")) {
            // ✅ Chuyển đến form thêm mới
            request.getRequestDispatcher("/admin/shiftForm.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String idRaw = request.getParameter("shiftID");
        Shift s = new Shift();

        // ✅ Lấy dữ liệu từ form
        s.setShiftCode(request.getParameter("shiftCode"));
        s.setShiftName(request.getParameter("shiftName"));
        s.setStartTime(request.getParameter("startTime"));
        s.setEndTime(request.getParameter("endTime"));
        s.setBreakMinutes(Integer.parseInt(request.getParameter("breakMinutes")));
        s.setLocation(request.getParameter("location"));

        // ✅ Thêm mới hoặc cập nhật
        if (idRaw == null || idRaw.isEmpty()) {
            dao.addShift(s);
        } else {
            s.setShiftID(Integer.parseInt(idRaw));
            dao.updateShift(s);
        }

        // 🔁 Quay lại danh sách sau khi lưu
        response.sendRedirect(request.getContextPath() + "/shift?action=list");
    }
}