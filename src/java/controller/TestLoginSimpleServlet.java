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
import utils.DBConnection;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;

@WebServlet("/test-login-simple")
public class TestLoginSimpleServlet extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("text/html;charset=UTF-8");
        PrintWriter out = response.getWriter();
        
        out.println("<html><head><title>Test Login Simple</title></head><body>");
        out.println("<h1>🔍 Test Login System</h1>");
        
        // Test database connection first
        out.println("<h2>1. Database Connection Test</h2>");
        try {
            Connection conn = DBConnection.getConnection();
            if (conn != null) {
                out.println("<p style='color: green;'>✅ Database connection successful!</p>");
                conn.close();
            } else {
                out.println("<p style='color: red;'>❌ Database connection failed!</p>");
                out.println("</body></html>");
                return;
            }
        } catch (Exception e) {
            out.println("<p style='color: red;'>❌ Database connection error: " + e.getMessage() + "</p>");
            out.println("</body></html>");
            return;
        }
        
        // Test with sample credentials
        String[] testCredentials = {
            "admin@example.com:admin123",
            "staff@example.com:staff123", 
            "customer@example.com:customer123",
            "test@example.com:123456"
        };
        
        out.println("<h2>2. Login Test with Sample Credentials</h2>");
        
        for (String credential : testCredentials) {
            String[] parts = credential.split(":");
            String email = parts[0];
            String password = parts[1];
            
            out.println("<h3>Testing: " + email + "</h3>");
            
            try {
                // Test Staff login
                StaffDAO staffDAO = new StaffDAO();
                boolean isStaff = staffDAO.authenticateStaff(email, password);
                out.println("<p>Staff: " + (isStaff ? "✅ SUCCESS" : "❌ FAILED") + "</p>");
                
                // Test Admin login
                AdminDAO adminDAO = new AdminDAO();
                boolean isAdmin = adminDAO.loginByEmail(email, password) != null;
                out.println("<p>Admin: " + (isAdmin ? "✅ SUCCESS" : "❌ FAILED") + "</p>");
                
                // Test Customer login
                UserService userService = new UserService();
                Customer customer = userService.loginCustomer(email, password);
                out.println("<p>Customer: " + (customer != null ? "✅ SUCCESS" : "❌ FAILED") + "</p>");
                
                if (customer != null) {
                    out.println("<p>Customer name: " + customer.getName() + "</p>");
                }
                
            } catch (Exception e) {
                out.println("<p style='color: red;'>Error: " + e.getMessage() + "</p>");
            }
            
            out.println("<hr>");
        }
        
        out.println("<h2>3. Manual Test Form</h2>");
        out.println("<form method='GET'>");
        out.println("Email: <input type='text' name='email' placeholder='Enter email'><br><br>");
        out.println("Password: <input type='password' name='password' placeholder='Enter password'><br><br>");
        out.println("<input type='submit' value='Test Login'>");
        out.println("</form>");
        
        // Manual test
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        
        if (email != null && password != null) {
            out.println("<h3>Manual Test Result for: " + email + "</h3>");
            
            try {
                // Test Staff login
                StaffDAO staffDAO = new StaffDAO();
                boolean isStaff = staffDAO.authenticateStaff(email, password);
                out.println("<p>Staff: " + (isStaff ? "✅ SUCCESS" : "❌ FAILED") + "</p>");
                
                // Test Admin login
                AdminDAO adminDAO = new AdminDAO();
                boolean isAdmin = adminDAO.loginByEmail(email, password) != null;
                out.println("<p>Admin: " + (isAdmin ? "✅ SUCCESS" : "❌ FAILED") + "</p>");
                
                // Test Customer login
                UserService userService = new UserService();
                Customer customer = userService.loginCustomer(email, password);
                out.println("<p>Customer: " + (customer != null ? "✅ SUCCESS" : "❌ FAILED") + "</p>");
                
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
