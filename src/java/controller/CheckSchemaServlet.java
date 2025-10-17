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
import java.sql.DatabaseMetaData;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;

@WebServlet("/check-schema")
public class CheckSchemaServlet extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("text/html;charset=UTF-8");
        PrintWriter out = response.getWriter();
        
        out.println("<html><head><title>Check Schema</title></head><body>");
        out.println("<h1>Database Schema Check</h1>");
        
        try {
            Connection con = DBConnection.getConnection();
            
            // Check Products table structure
            out.println("<h2>Products Table Structure</h2>");
            PreparedStatement ps = con.prepareStatement("SELECT TOP 1 * FROM Products");
            ResultSet rs = ps.executeQuery();
            ResultSetMetaData metaData = rs.getMetaData();
            
            out.println("<table border='1'><tr><th>Column</th><th>Type</th><th>Size</th></tr>");
            for (int i = 1; i <= metaData.getColumnCount(); i++) {
                out.println("<tr>");
                out.println("<td>" + metaData.getColumnName(i) + "</td>");
                out.println("<td>" + metaData.getColumnTypeName(i) + "</td>");
                out.println("<td>" + metaData.getColumnDisplaySize(i) + "</td>");
                out.println("</tr>");
            }
            out.println("</table>");
            
            // Check ProductCategory table structure
            out.println("<h2>ProductCategory Table Structure</h2>");
            ps = con.prepareStatement("SELECT TOP 1 * FROM ProductCategory");
            rs = ps.executeQuery();
            metaData = rs.getMetaData();
            
            out.println("<table border='1'><tr><th>Column</th><th>Type</th><th>Size</th></tr>");
            for (int i = 1; i <= metaData.getColumnCount(); i++) {
                out.println("<tr>");
                out.println("<td>" + metaData.getColumnName(i) + "</td>");
                out.println("<td>" + metaData.getColumnTypeName(i) + "</td>");
                out.println("<td>" + metaData.getColumnDisplaySize(i) + "</td>");
                out.println("</tr>");
            }
            out.println("</table>");
            
            // Check Supplier table structure
            out.println("<h2>Supplier Table Structure</h2>");
            ps = con.prepareStatement("SELECT TOP 1 * FROM Supplier");
            rs = ps.executeQuery();
            metaData = rs.getMetaData();
            
            out.println("<table border='1'><tr><th>Column</th><th>Type</th><th>Size</th></tr>");
            for (int i = 1; i <= metaData.getColumnCount(); i++) {
                out.println("<tr>");
                out.println("<td>" + metaData.getColumnName(i) + "</td>");
                out.println("<td>" + metaData.getColumnTypeName(i) + "</td>");
                out.println("<td>" + metaData.getColumnDisplaySize(i) + "</td>");
                out.println("</tr>");
            }
            out.println("</table>");
            
            rs.close();
            ps.close();
            con.close();
            
        } catch (Exception e) {
            out.println("<p style='color: red;'>❌ Error: " + e.getMessage() + "</p>");
            e.printStackTrace();
        }
        
        out.println("</body></html>");
    }
}
