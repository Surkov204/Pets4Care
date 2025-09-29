package controller;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.sql.*;
import model.Customer;
import utils.DBConnection;

@WebServlet(name = "UpdateUserServlet", urlPatterns = {"/updateuserservlet"})
public class UpdateUserServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        Customer currentUser = (Customer) session.getAttribute("currentUser");

        if (currentUser == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        // Lấy dữ liệu từ form
        String name = request.getParameter("name");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String address = request.getParameter("address");

        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = DBConnection.getConnection();

            if (conn != null) {
                String sql = "UPDATE Customer SET name = ?, email = ?, phone = ?, address_Customer = ? WHERE customer_id = ?";
                ps = conn.prepareStatement(sql);
                ps.setString(1, name);
                ps.setString(2, email);
                ps.setString(3, phone);
                ps.setString(4, address);
                ps.setInt(5, currentUser.getCustomerId());

                int rows = ps.executeUpdate();

                if (rows > 0) {
                    currentUser.setName(name);
                    currentUser.setEmail(email);
                    currentUser.setPhone(phone);
                    currentUser.setAddressCustomer(address);
                    session.setAttribute("currentUser", currentUser);

                    request.setAttribute("message", "Cập nhật thành công!");
                } else {
                    request.setAttribute("message", "Cập nhật thất bại!");
                }
            } else {
                request.setAttribute("message", "Không thể kết nối Database!");
            }

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("message", "Có lỗi xảy ra: " + e.getMessage());
        } finally {
            try { if (ps != null) ps.close(); } catch (Exception ex) {}
            try { if (conn != null) conn.close(); } catch (Exception ex) {}
        }

        request.getRequestDispatcher("user/user-info.jsp").forward(request, response);
    }

    @Override
    public String getServletInfo() {
        return "Update user info servlet";
    }
}