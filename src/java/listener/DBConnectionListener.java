package listener;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebListener;
import java.sql.*;

@WebListener
public class DBConnectionListener implements ServletContextListener {
    private Connection conn;

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        try {
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
            conn = DriverManager.getConnection(
                "jdbc:sqlserver://localhost:1433;databaseName=SHOP_PET_Database;encrypt=false;trustServerCertificate=true",
                "sa", "12345"
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