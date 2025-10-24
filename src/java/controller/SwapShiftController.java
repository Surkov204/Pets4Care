package controller;

import dao.NotificationDAO;
import dao.ShiftRequestDAO;
import dao.WorkScheduleDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.Date;
import model.ShiftRequest;
import model.Staff;

@WebServlet("/staff/swapShift")
public class SwapShiftController extends HttpServlet {

    private final ShiftRequestDAO shiftDAO = new ShiftRequestDAO();
    private final WorkScheduleDAO workDAO = new WorkScheduleDAO();
    private final NotificationDAO notiDAO = new NotificationDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        Staff staff = (Staff) session.getAttribute("staff");

        if (staff == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        try {
            int staffId = staff.getStaffId();
            Date fromDate = Date.valueOf(request.getParameter("fromDate"));
            Date toDate = Date.valueOf(request.getParameter("toDate"));
            int fromShiftId = Integer.parseInt(request.getParameter("fromShiftId"));
            int toShiftId = Integer.parseInt(request.getParameter("toShiftId"));
            int toStaffId = Integer.parseInt(request.getParameter("toStaffId"));
            String reason = request.getParameter("reason");
            
            boolean hasShiftA = workDAO.hasShift(staffId, fromDate, fromShiftId);

            // 🧩 2️⃣ Kiểm tra người nhận có ca kia không
            boolean hasShiftB = workDAO.hasShift(toStaffId, toDate, toShiftId);

            if (!hasShiftA) {
                session.setAttribute("errorMessage",
                        "⚠️ Bạn không có ca " + fromShiftId + " vào ngày " + fromDate + " để đổi!");
                response.sendRedirect(request.getContextPath() + "/staff/mySchedule");
                return;
            }

            if (!hasShiftB) {
                session.setAttribute("errorMessage",
                        "⚠️ Nhân viên được chọn không có ca " + toShiftId + " vào ngày " + toDate + "!");
                response.sendRedirect(request.getContextPath() + "/staff/mySchedule");
                return;
            }
            
            // 🧩 1️⃣ Kiểm tra trùng ca / conflict trước khi cho phép gửi yêu cầu
            boolean valid = workDAO.canSwapShift(staffId, toStaffId, fromDate, toDate, fromShiftId, toShiftId);

            if (!valid) {
                session.setAttribute("errorMessage",
                        "⚠️ Không thể đổi ca — Ca làm bị trùng hoặc không hợp lệ.");
                response.sendRedirect(request.getContextPath() + "/staff/mySchedule");
                return;
            }

            // 🧱 2️⃣ Tạo yêu cầu đổi ca
            ShiftRequest req = new ShiftRequest();
            req.setEmployeeID(staffId);
            req.setToStaffID(toStaffId);
            req.setType("Swap");
            req.setFromDate(fromDate);
            req.setToDate(toDate);
            req.setFromShiftID(fromShiftId);
            req.setToShiftID(toShiftId);
            req.setReason(reason);
            req.setStatus("Pending");

            // 💾 3️⃣ Lưu vào DB
            shiftDAO.addRequest(req);
            System.out.println("[SwapShiftController] ✅ Insert ShiftRequest thành công cho StaffID=" + staffId);

            // 🔔 4️⃣ Gửi thông báo cho người được đổi
            notiDAO.createNotification(
                    toStaffId,
                    "Yêu cầu đổi ca mới",
                    "Nhân viên " + staff.getName() + " đã gửi yêu cầu đổi ca với bạn."
            );

            // 🎉 5️⃣ Gửi feedback toast cho nhân viên
            session.setAttribute("successMessage", "🔁 Gửi yêu cầu đổi ca thành công!");
            response.sendRedirect(request.getContextPath() + "/staff/mySchedule");

        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("errorMessage", "❌ Lỗi hệ thống khi gửi yêu cầu đổi ca.");
            response.sendRedirect(request.getContextPath() + "/staff/mySchedule");
        }
    }
}
