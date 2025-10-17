package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import dao.StaffDAO;
import dao.AdminDAO;
import service.UserService;
import model.Customer;

import java.io.IOException;
import java.io.PrintWriter;

@WebServlet("/test-login")
public class TestLoginServlet extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("text/html;charset=UTF-8");
        PrintWriter out = response.getWriter();
        
        out.println("<html><head><title>Test Login</title></head><body>");
        out.println("<h1>Test Login System</h1>");
        
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        
        if (email == null || password == null) {
            out.println("<form method='GET'>");
            out.println("Email: <input type='text' name='email'><br>");
            out.println("Password: <input type='password' name='password'><br>");
            out.println("<input type='submit' value='Test Login'>");
            out.println("</form>");
        } else {
            out.println("<h2>Testing login for: " + email + "</h2>");
            
            try {
                // Test Staff login
                StaffDAO staffDAO = new StaffDAO();
                boolean isStaff = staffDAO.authenticateStaff(email, password);
                out.println("<p>Staff authentication: " + (isStaff ? "SUCCESS" : "FAILED") + "</p>");
                
                // Test Admin login
                AdminDAO adminDAO = new AdminDAO();
                boolean isAdmin = adminDAO.loginByEmail(email, password) != null;
                out.println("<p>Admin authentication: " + (isAdmin ? "SUCCESS" : "FAILED") + "</p>");
                
                // Test Customer login
                UserService userService = new UserService();
                Customer customer = userService.loginCustomer(email, password);
                out.println("<p>Customer authentication: " + (customer != null ? "SUCCESS" : "FAILED") + "</p>");
                
                if (customer != null) {
                    out.println("<p>Customer name: " + customer.getName() + "</p>");
                }
                
            } catch (Exception e) {
                out.println("<p style='color: red;'>Error: " + e.getMessage() + "</p>");
                e.printStackTrace(out);
            }
        }
        
        out.println("</body></html>");
    }
}
