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
import java.sql.SQLException;

@WebServlet("/test-db")
public class TestDBServlet extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("text/html;charset=UTF-8");
        PrintWriter out = response.getWriter();
        
        out.println("<html><head><title>Test Database</title></head><body>");
        out.println("<h1>Test Database Connection</h1>");
        
        try {
            Connection conn = DBConnection.getConnection();
            if (conn != null) {
                out.println("<p style='color: green;'>✅ Database connection successful!</p>");
                out.println("<p>Connection URL: " + DBConnection.dbURL + "</p>");
                out.println("<p>User: " + DBConnection.userDB + "</p>");
                
                // Test query
                try {
                    var stmt = conn.createStatement();
                    var rs = stmt.executeQuery("SELECT COUNT(*) as count FROM Staff");
                    if (rs.next()) {
                        out.println("<p>Staff table has " + rs.getInt("count") + " records</p>");
                    }
                    rs.close();
                    stmt.close();
                } catch (SQLException e) {
                    out.println("<p style='color: orange;'>⚠️ Query test failed: " + e.getMessage() + "</p>");
                }
                
                conn.close();
            } else {
                out.println("<p style='color: red;'>❌ Database connection failed!</p>");
                out.println("<p>Connection returned null</p>");
            }
        } catch (Exception e) {
            out.println("<p style='color: red;'>❌ Database connection error:</p>");
            out.println("<pre>" + e.getMessage() + "</pre>");
            e.printStackTrace(out);
        }
        
        out.println("</body></html>");
    }
}
