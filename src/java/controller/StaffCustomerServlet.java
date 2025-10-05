package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import dao.UserDAO;
import model.Customer;
import model.Staff;

import java.io.IOException;
import java.util.List;
import java.util.logging.Logger;

@WebServlet("/staff/customers")
public class StaffCustomerServlet extends HttpServlet {
    private UserDAO userDAO = new UserDAO();
    private static final Logger logger = Logger.getLogger(StaffCustomerServlet.class.getName());

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Kiểm tra xác thực staff
        if (!isStaffAuthenticated(request)) {
            response.sendRedirect(request.getContextPath() + "/login.jsp?error=staff_required");
            return;
        }

        try {
            String action = request.getParameter("action");
            if (action == null) {
                action = "list";
            }

            switch (action) {
                case "list":
                    handleListCustomers(request, response);
                    break;
                case "view":
                    handleViewCustomer(request, response);
                    break;
                case "search":
                    handleSearchCustomers(request, response);
                    break;
                default:
                    handleListCustomers(request, response);
                    break;
            }
        } catch (Exception e) {
            logger.severe("Error in StaffCustomerServlet: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("error", "Có lỗi xảy ra: " + e.getMessage());
            request.getRequestDispatcher("/staff/customer-list.jsp").forward(request, response);
        }
    }

    private boolean isStaffAuthenticated(HttpServletRequest request) {
        HttpSession session = request.getSession();
        Staff staff = (Staff) session.getAttribute("staff");
        return staff != null;
    }

    private void handleListCustomers(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Xử lý phân trang
        int page = 1;
        String pageRaw = request.getParameter("page");
        if (pageRaw != null) {
            try {
                page = Integer.parseInt(pageRaw);
                if (page < 1) page = 1;
            } catch (NumberFormatException e) {
                page = 1;
            }
        }

        int pageSize = 10;
        int offset = (page - 1) * pageSize;
        
        List<Customer> customers = userDAO.getAllCustomers(offset, pageSize);
        int totalCustomers = userDAO.countAllCustomers();
        int totalPages = (int) Math.ceil((double) totalCustomers / pageSize);

        request.setAttribute("customers", customers);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalCustomers", totalCustomers);

        request.getRequestDispatcher("/staff/customer-list.jsp").forward(request, response);
    }

    private void handleViewCustomer(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String customerIdRaw = request.getParameter("id");
        if (customerIdRaw == null) {
            response.sendRedirect(request.getContextPath() + "/staff/customers");
            return;
        }

        try {
            int customerId = Integer.parseInt(customerIdRaw);
            Customer customer = userDAO.findById(customerId);
            
            if (customer != null) {
                request.setAttribute("customer", customer);
                request.getRequestDispatcher("/staff/customer-detail.jsp").forward(request, response);
            } else {
                request.setAttribute("error", "Không tìm thấy khách hàng");
                response.sendRedirect(request.getContextPath() + "/staff/customers");
            }
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/staff/customers");
        }
    }

    private void handleSearchCustomers(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String keyword = request.getParameter("keyword");
        if (keyword == null || keyword.trim().isEmpty()) {
            handleListCustomers(request, response);
            return;
        }

        // Xử lý phân trang cho kết quả tìm kiếm
        int page = 1;
        String pageRaw = request.getParameter("page");
        if (pageRaw != null) {
            try {
                page = Integer.parseInt(pageRaw);
                if (page < 1) page = 1;
            } catch (NumberFormatException e) {
                page = 1;
            }
        }

        int pageSize = 10;
        int offset = (page - 1) * pageSize;
        
        List<Customer> customers = userDAO.searchCustomers(keyword.trim(), offset, pageSize);
        int totalCustomers = userDAO.countSearchCustomers(keyword.trim());
        int totalPages = (int) Math.ceil((double) totalCustomers / pageSize);

        request.setAttribute("customers", customers);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalCustomers", totalCustomers);
        request.setAttribute("keyword", keyword);

        request.getRequestDispatcher("/staff/customer-list.jsp").forward(request, response);
    }
}
