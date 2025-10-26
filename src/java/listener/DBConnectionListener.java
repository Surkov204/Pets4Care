package listener;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebListener;
import java.sql.*;

// @WebListener // Disabled to avoid auto-connecting DB at server startup
public class DBConnectionListener implements ServletContextListener {
    private Connection conn;

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        try {
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
            conn = DriverManager.getConnection(
                "jdbc:sqlserver://localhost:1433;databaseName=Pets4Care;encrypt=false;",
                "sa", "your_password"
            );
            sce.getServletContext().setAttribute("DBConnection", conn);
            System.out.println("✅ Database connected successfully!");
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        try {
            if (conn != null) conn.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}