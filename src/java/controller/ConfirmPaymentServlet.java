
package controller;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;


public class ConfirmPaymentServlet extends HttpServlet {


   @Override
protected void doPost(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {
    try {
        int orderId = Integer.parseInt(request.getParameter("orderId"));
        String type = request.getParameter("type"); // product | service | boarding
        java.sql.Timestamp paidAt = new java.sql.Timestamp(System.currentTimeMillis());

        // Nếu là service booking, cập nhật status trong bảng Booking
        if ("service".equalsIgnoreCase(type)) {
            try (java.sql.Connection conn = utils.DBConnection.getConnection();
                 java.sql.PreparedStatement ps = conn.prepareStatement(
                     "UPDATE dbo.Booking SET status = N'Đã thanh toán', updated_at = GETDATE() " +
                     "WHERE order_id = ? OR booking_id = ?")) {
                
                ps.setInt(1, orderId);
                ps.setInt(2, orderId);
                int rows = ps.executeUpdate();
                if (rows > 0) {
                    System.out.println("✅ Đã cập nhật booking status thành 'Đã thanh toán' cho orderId: " + orderId);
                }
            } catch (Exception e) {
                System.err.println("❌ Lỗi khi cập nhật booking status: " + e.getMessage());
                e.printStackTrace();
            }
        } else {
            // Xử lý Order (product)
            try (java.sql.Connection conn = utils.DBConnection.getConnection();
                 java.sql.CallableStatement cs = conn.prepareCall("{call ConfirmAndPayOrder(?, ?, ?)}")) {

                cs.setInt(1, orderId);
                cs.setString(2, "Đã thanh toán");
                cs.setTimestamp(3, paidAt);

                cs.execute();
            }
        }

        // ✅ Redirect đến trang xác nhận thành công
        response.sendRedirect("order/confirm-success.jsp");

    } catch (Exception e) {
        e.printStackTrace();
        response.sendRedirect("order/confirm-failed.jsp");
    }
}

}
