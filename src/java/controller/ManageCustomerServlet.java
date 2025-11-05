/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller;

import dao.UserDAO;
import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import model.Customer;
import model.OrderStats;
import service.CustomerService;
import service.ICustomerService;
import service.IOrderService;
import service.OrderService;

@WebServlet("/admin/customer")
public class ManageCustomerServlet extends HttpServlet {
    private UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        int page = 1;
        int limit = 20;
        if (req.getParameter("page") != null) {
            page = Integer.parseInt(req.getParameter("page"));
        }
        int offset = (page - 1) * limit;

        // ✅ Lấy danh sách khách hàng có phân trang
        List<Customer> customers = userDAO.getAllCustomers(offset, limit);
        int totalCustomers = userDAO.countAllCustomers();

        // ✅ Tính tổng số trang
        int totalPages = (int) Math.ceil(totalCustomers * 1.0 / limit);

        // ✅ Gán vào request để JSP hiển thị
        req.setAttribute("customers", customers);
        req.setAttribute("currentPage", page);
        req.setAttribute("totalPages", totalPages);

        // ✅ Hiển thị flash message nếu có
        String flash = (String) req.getSession().getAttribute("flashMessage");
        if (flash != null) {
            req.setAttribute("flashMessage", flash);
            req.getSession().removeAttribute("flashMessage");
        }
        Map<Integer, OrderStats> orderStats = new HashMap<>();
        req.setAttribute("orderStats", orderStats);
        req.getRequestDispatcher("/admin/manage-customer.jsp").forward(req, resp);
    }
}