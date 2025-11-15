package controller;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import jakarta.servlet.ServletException;
import utils.DBConnection;

import java.io.IOException;
import java.sql.CallableStatement;
import java.sql.Connection;

@WebServlet("/cancelorder")
public class CancelOrderServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String orderIdRaw = request.getParameter("id");
        if (orderIdRaw == null) {
            response.sendRedirect("order/order-history.jsp");
            return;
        }

        int orderId = Integer.parseInt(orderIdRaw);

        try (Connection con = DBConnection.getConnection()) {
            CallableStatement cs = con.prepareCall("{call CancelOrder(?)}");
            cs.setInt(1, orderId);
            cs.execute();
        } catch (Exception e) {
            e.printStackTrace();
        }

        response.sendRedirect("order/order-history.jsp?msg=cancel_success");
    }
}
