
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
        java.sql.Timestamp paidAt = new java.sql.Timestamp(System.currentTimeMillis());

        try (java.sql.Connection conn = utils.DBConnection.getConnection();
             java.sql.CallableStatement cs = conn.prepareCall("{call ConfirmAndPayOrder(?, ?, ?)}")) {

            cs.setInt(1, orderId);
            cs.setString(2, "Đã thanh toán");
            cs.setTimestamp(3, paidAt);

            cs.execute();

            // ✅ Redirect đến trang xác nhận thành công
            response.sendRedirect("order/confirm-success.jsp");

        }
    } catch (Exception e) {
        e.printStackTrace();
        response.sendRedirect("order/confirm-failed.jsp");
    }
}

}
