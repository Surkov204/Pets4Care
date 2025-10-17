package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import dao.ICustomerDAO;
import dao.CustomerDAO;
import model.Customer;
import model.Staff;

import java.io.IOException;
import java.util.List;

@WebServlet("/staff/customer-list")
public class CustomerListServlet extends HttpServlet {
    
    private ICustomerDAO customerDAO = new CustomerDAO();
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        Staff staff = (Staff) session.getAttribute("staff");
        
        if (staff == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }
        
        try {
            String action = request.getParameter("action");
            String keyword = request.getParameter("keyword");
            String status = request.getParameter("status");
            String pageStr = request.getParameter("page");
            
            int page = 1;
            int limit = 10;
            int offset = 0;
            
            if (pageStr != null && !pageStr.trim().isEmpty()) {
                try {
                    page = Integer.parseInt(pageStr);
                    offset = (page - 1) * limit;
                } catch (NumberFormatException e) {
                    page = 1;
                    offset = 0;
                }
            }
            
            List<Customer> customers = null;
            int totalCustomers = 0;
            
            if (action != null && action.equals("view")) {
                // Xem chi tiết customer
                String customerIdStr = request.getParameter("id");
                if (customerIdStr != null) {
                    int customerId = Integer.parseInt(customerIdStr);
                    Customer customer = customerDAO.getCustomerById(customerId);
                    if (customer != null) {
                        request.setAttribute("customer", customer);
                        request.getRequestDispatcher("/staff/customer-detail.jsp").forward(request, response);
                        return;
                    }
                }
            }
            
            // Lấy danh sách customers theo điều kiện
            if (keyword != null && !keyword.trim().isEmpty()) {
                customers = customerDAO.searchCustomers(keyword.trim());
                totalCustomers = customers.size();
            } else if (status != null && !status.trim().isEmpty()) {
                customers = customerDAO.getCustomersByStatus(status.trim());
                totalCustomers = customers.size();
            } else {
                // Lấy tất cả customers với phân trang
                customers = customerDAO.getAllCustomers();
                totalCustomers = customers.size();
                
                // Phân trang thủ công
                int start = offset;
                int end = Math.min(offset + limit, customers.size());
                if (start < customers.size()) {
                    customers = customers.subList(start, end);
                }
            }
            
            request.setAttribute("customers", customers);
            request.setAttribute("keyword", keyword);
            request.setAttribute("status", status);
            request.setAttribute("currentPage", page);
            request.setAttribute("totalCustomers", totalCustomers);
            request.setAttribute("totalPages", (int) Math.ceil((double) totalCustomers / limit));
            
            request.getRequestDispatcher("/staff/customer-list.jsp").forward(request, response);
            
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Có lỗi xảy ra khi tải dữ liệu: " + e.getMessage());
            request.getRequestDispatcher("/staff/customer-list.jsp").forward(request, response);
        }
    }
    
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
            String action = request.getParameter("action");
            
            if (action != null && action.equals("update_status")) {
                String customerIdStr = request.getParameter("customerId");
                String newStatus = request.getParameter("status");
                
                if (customerIdStr != null && newStatus != null) {
                    int customerId = Integer.parseInt(customerIdStr);
                    Customer customer = customerDAO.getCustomerById(customerId);
                    if (customer != null) {
                        customer.setStatus(newStatus);
                        boolean success = customerDAO.updateCustomer(customer);
                        
                        if (success) {
                            request.setAttribute("success", "Cập nhật trạng thái khách hàng thành công!");
                        } else {
                            request.setAttribute("error", "Cập nhật trạng thái khách hàng thất bại!");
                        }
                    }
                }
            }
            
            // Redirect về GET để refresh trang
            response.sendRedirect(request.getContextPath() + "/staff/customer-list");
            
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Có lỗi xảy ra: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/staff/customer-list");
        }
    }
}
