package controller;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import dao.OrderDAO;
import model.Order;


@WebServlet(name = "UpdateOrderStatusServlet", urlPatterns = {"/admin/update-order-status"})
public class UpdateOrderStatusServlet extends HttpServlet {

    private OrderDAO orderDAO;

    @Override
    public void init() throws ServletException {
        super.init();
        orderDAO = new OrderDAO();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        String orderIdParam = request.getParameter("orderId");
        String newStatus = request.getParameter("newStatus");

        try {
            if (orderIdParam == null || orderIdParam.isEmpty() || newStatus == null || newStatus.isEmpty()) {
                session.setAttribute("error", "Thông tin cập nhật không hợp lệ");
                response.sendRedirect("manage-order");
                return;
            }

            int orderId;
            try {
                orderId = Integer.parseInt(orderIdParam);
            } catch (NumberFormatException e) {
                session.setAttribute("error", "Mã đơn hàng không hợp lệ");
                response.sendRedirect("manage-order");
                return;
            }

            Order currentOrder = orderDAO.getOrderById(orderId);
            if (currentOrder == null) {
                session.setAttribute("error", "Không tìm thấy đơn hàng #" + orderId);
                response.sendRedirect("manage-order");
                return;
            }

            if (!isValidStatusTransition(currentOrder.getStatus(), newStatus)) {
                session.setAttribute("error", "Không thể chuyển trạng thái từ " 
                        + currentOrder.getStatus() + " sang " + newStatus);
                response.sendRedirect("manage-order");
                return;
            }

            if (currentOrder.getStatus().equals(newStatus)) {
                session.setAttribute("error", "Đơn hàng đã ở trạng thái này");
                response.sendRedirect("manage-order");
                return;
            }

            boolean success = orderDAO.updateOrderStatus(orderId, newStatus); // Đã bỏ phần ghi log

            if (success) {
                session.setAttribute("success", "Đã cập nhật trạng thái đơn hàng #" + orderId + " thành " + newStatus);
            } else {
                session.setAttribute("error", "Cập nhật trạng thái đơn hàng #" + orderId + " thất bại. Vui lòng thử lại");
            }

        } catch (Exception e) {
            session.setAttribute("error", "Lỗi hệ thống: " + e.getMessage());
            log("Error updating order status", e);
        }

        response.sendRedirect("manage-order");
    }

    private boolean isValidStatusTransition(String currentStatus, String newStatus) {
        if (currentStatus.equals(newStatus)) {
            return false;
        }

        switch (currentStatus) {
            case "Đang xử lý":
                return "Hoàn tất".equals(newStatus) || "Đã hủy".equals(newStatus);
            case "Hoàn tất":
                return false;
            case "Đã hủy":
                return false;
            default:
                return false;
        }
    }
}
