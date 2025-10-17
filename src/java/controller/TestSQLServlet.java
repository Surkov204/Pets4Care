package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import utils.DBConnection;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

@WebServlet("/staff/test-sql")
public class TestSQLServlet extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("text/html;charset=UTF-8");
        PrintWriter out = response.getWriter();
        
        try {
            out.println("<html><head><title>Test SQL</title></head><body>");
            out.println("<h1>Test SQL Queries</h1>");
            
            // Test 1: Count Orders
            String sql1 = "SELECT COUNT(*) as count FROM Orders";
            try (Connection conn = DBConnection.getConnection();
                 PreparedStatement ps = conn.prepareStatement(sql1);
                 ResultSet rs = ps.executeQuery()) {
                
                if (rs.next()) {
                    int count = rs.getInt("count");
                    out.println("<h2>Total Orders: " + count + "</h2>");
                }
            }
            
            // Test 2: Count Customers
            String sql2 = "SELECT COUNT(*) as count FROM Customer";
            try (Connection conn = DBConnection.getConnection();
                 PreparedStatement ps = conn.prepareStatement(sql2);
                 ResultSet rs = ps.executeQuery()) {
                
                if (rs.next()) {
                    int count = rs.getInt("count");
                    out.println("<h2>Total Customers: " + count + "</h2>");
                }
            }
            
            // Test 3: Simple Orders query
            String sql3 = "SELECT TOP 5 order_id, customer_id, status, total_amount FROM Orders";
            out.println("<h2>First 5 Orders:</h2>");
            out.println("<table border='1' style='border-collapse: collapse;'>");
            out.println("<tr><th>Order ID</th><th>Customer ID</th><th>Status</th><th>Total</th></tr>");
            
            try (Connection conn = DBConnection.getConnection();
                 PreparedStatement ps = conn.prepareStatement(sql3);
                 ResultSet rs = ps.executeQuery()) {
                
                while (rs.next()) {
                    out.println("<tr>");
                    out.println("<td>" + rs.getInt("order_id") + "</td>");
                    out.println("<td>" + rs.getInt("customer_id") + "</td>");
                    out.println("<td>" + rs.getString("status") + "</td>");
                    out.println("<td>" + rs.getDouble("total_amount") + "</td>");
                    out.println("</tr>");
                }
            }
            out.println("</table>");
            
            // Test 4: JOIN query
            String sql4 = "SELECT TOP 5 o.order_id, o.customer_id, c.name as customer_name, o.status FROM Orders o JOIN Customer c ON o.customer_id = c.customer_id";
            out.println("<h2>First 5 Orders with Customer Names:</h2>");
            out.println("<table border='1' style='border-collapse: collapse;'>");
            out.println("<tr><th>Order ID</th><th>Customer ID</th><th>Customer Name</th><th>Status</th></tr>");
            
            try (Connection conn = DBConnection.getConnection();
                 PreparedStatement ps = conn.prepareStatement(sql4);
                 ResultSet rs = ps.executeQuery()) {
                
                while (rs.next()) {
                    out.println("<tr>");
                    out.println("<td>" + rs.getInt("order_id") + "</td>");
                    out.println("<td>" + rs.getInt("customer_id") + "</td>");
                    out.println("<td>" + rs.getString("customer_name") + "</td>");
                    out.println("<td>" + rs.getString("status") + "</td>");
                    out.println("</tr>");
                }
            }
            out.println("</table>");
            
            out.println("</body></html>");
            
        } catch (Exception e) {
            out.println("<html><head><title>Error</title></head><body>");
            out.println("<h1>Error: " + e.getMessage() + "</h1>");
            out.println("<pre>");
            e.printStackTrace(out);
            out.println("</pre>");
            out.println("</body></html>");
        }
    }
}
