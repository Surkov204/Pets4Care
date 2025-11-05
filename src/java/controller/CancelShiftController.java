package controller;

import dao.ShiftRequestDAO;
import dao.NotificationDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.Date;
import model.ShiftRequest;
import model.Staff;

@WebServlet("/staff/cancelShift")
public class CancelShiftController extends HttpServlet {
    private final ShiftRequestDAO shiftDAO = new ShiftRequestDAO();
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
            String[] cancelItems = request.getParameterValues("cancelItems");
            if (cancelItems == null || cancelItems.length == 0) {
                session.setAttribute("errorMessage", "⚠️ Vui lòng chọn ít nhất một ca để hủy!");
                response.sendRedirect(request.getContextPath() + "/staff/mySchedule");
                return;
            }

            int count = 0;
            for (String item : cancelItems) {
                // Dữ liệu truyền từ JSP: "yyyy-MM-dd|shiftId"
                String[] parts = item.split("\\|");
                Date workDate = Date.valueOf(parts[0]);
                int shiftId = Integer.parseInt(parts[1]);

                // 🧱 Tạo yêu cầu hủy ca
                ShiftRequest req = new ShiftRequest();
                req.setEmployeeID(staffId);
                req.setType("Cancel");
                req.setFromDate(workDate);
                req.setFromShiftID(shiftId);
                req.setReason("Nhân viên yêu cầu hủy ca");
                req.setStatus("Pending");

                // 💾 Lưu yêu cầu hủy ca
                shiftDAO.addPassRequest(req);
                count++;
            }

            // 🔔 Thông báo cho admin
            notiDAO.createNotification(
                    1, // giả sử adminID = 1, bạn có thể đổi thành ID quản lý
                    "Yêu cầu hủy ca",
                    "Nhân viên " + staff.getName() + " đã gửi " + count + " yêu cầu hủy ca."
            );

            session.setAttribute("successMessage", "🗑 Đã gửi " + count + " yêu cầu hủy ca, chờ duyệt!");
            response.sendRedirect(request.getContextPath() + "/staff/mySchedule");

        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("errorMessage", "❌ Lỗi hệ thống khi gửi yêu cầu hủy ca.");
            response.sendRedirect(request.getContextPath() + "/staff/mySchedule");
        }
    }
}