/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller;

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

/**
 *
 * @author ASUS
 */
@WebServlet(name = "ManageCustomerServlet", urlPatterns = {"/admin/manage-customer"})
public class ManageCustomerServlet extends HttpServlet {
    private ICustomerService customerService = new CustomerService();
    /**
     * Processes requests for both HTTP <code>GET</code> and <code>POST</code>
     * methods.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        try (PrintWriter out = response.getWriter()) {
            /* TODO output your page here. You may use following sample code. */
            out.println("<!DOCTYPE html>");
            out.println("<html>");
            out.println("<head>");
            out.println("<title>Servlet ManageCustomerServlet</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet ManageCustomerServlet at " + request.getContextPath() + "</h1>");
            out.println("</body>");
            out.println("</html>");
        }
    }

    // <editor-fold defaultstate="collapsed" desc="HttpServlet methods. Click on the + sign on the left to edit the code.">
    /**
     * Handles the HTTP <code>GET</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String keyword = request.getParameter("keyword");
    String statusFilter = request.getParameter("status");

    List<Customer> customers;

    if (keyword != null && !keyword.trim().isEmpty()) {
        customers = customerService.searchCustomers(keyword); // dùng cả khi filter
    } else {
        customers = customerService.getAllCustomers();
    }

    // Lọc theo status nếu có
    if (statusFilter != null && !statusFilter.equals("all")) {
        customers.removeIf(c -> !statusFilter.equalsIgnoreCase(c.getStatus()));
    }
    
    IOrderService orderService = new OrderService();
    Map<Integer, OrderStats> statsMap = new HashMap<>();

    for (Customer c : customers) {
        statsMap.put(c.getCustomerId(), orderService.getOrderStatsByCustomerId(c.getCustomerId()));
    }

    // Đếm thống kê
    long activeCount = customers.stream().filter(c -> "active".equalsIgnoreCase(c.getStatus())).count();
    long inactiveCount = customers.stream().filter(c -> "inactive".equalsIgnoreCase(c.getStatus())).count();
    
    request.setAttribute("orderStats", statsMap);

    request.setAttribute("customers", customers);
    request.setAttribute("keyword", keyword);
    request.setAttribute("statusFilter", statusFilter);
    request.setAttribute("activeCount", activeCount);
    request.setAttribute("inactiveCount", inactiveCount);

    request.getRequestDispatcher("/admin/manage-customer.jsp").forward(request, response);
    }

    /**
     * Handles the HTTP <code>POST</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
    if ("toggle-status".equals(action)) {
        int customerId = Integer.parseInt(request.getParameter("customerId"));
        String currentStatus = request.getParameter("currentStatus");

        String newStatus = currentStatus.equals("active") ? "inactive" : "active";
        customerService.updateCustomerStatus(customerId, newStatus);

        response.sendRedirect("manage-customer");
    }
    }

    /**
     * Returns a short description of the servlet.
     *
     * @return a String containing servlet description
     */
    @Override
    public String getServletInfo() {
        return "Short description";
    }// </editor-fold>

}
