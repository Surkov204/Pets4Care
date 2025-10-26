
package utils;


import java.util.logging.Level;
import java.util.logging.Logger;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBConnection {
    public static String driverName = "com.microsoft.sqlserver.jdbc.SQLServerDriver";
    public static String dbURL = "jdbc:sqlserver://localhost:1433;databaseName=SHOP_PET_Database;encrypt=false;trustServerCertificate=true";
    public static String userDB = "sa";
    public static String passDB = "12345";
    
    public static Connection getConnection(){
        Connection con = null;
        try{
            System.out.println("=== BẮT ĐẦU KẾT NỐI DATABASE ===");
            System.out.println("Driver: " + driverName);
            System.out.println("URL: " + dbURL);
            System.out.println("User: " + userDB);
            System.out.println("Password length: " + (passDB != null ? passDB.length() : "null") + " chars");
            System.out.println("Password starts with: " + (passDB != null && passDB.length() > 0 ? passDB.substring(0, 1) : "null"));
            
            Class.forName(driverName);
            System.out.println("✅ Driver loaded successfully");
            
            System.out.println("⏳ Attempting to connect to database...");
            con = DriverManager.getConnection(dbURL, userDB, passDB);
            System.out.println("✅ Database connection successful");
            return con;
        }
         catch(SQLException sqlEx){
             System.err.println("=== LỖI SQL DATABASE ===");
             System.err.println("SQL Error Code: " + sqlEx.getErrorCode());
             System.err.println("SQL State: " + sqlEx.getSQLState());
             System.err.println("Error message: " + sqlEx.getMessage());
             System.err.println("Error type: " + sqlEx.getClass().getSimpleName());
             
             // Chi tiết lỗi xác thực
             if (sqlEx.getMessage().contains("Login failed")) {
                 System.err.println("⚠️ AUTHENTICATION FAILED");
                 System.err.println("  - Username: " + userDB);
                 System.err.println("  - Password length: " + (passDB != null ? passDB.length() : "null"));
                 System.err.println("  - Please check:");
                 System.err.println("    1. SQL Server Authentication mode is enabled (not just Windows Auth)");
                 System.err.println("    2. sa account is enabled");
                 System.err.println("    3. Password is correct");
                 System.err.println("    4. SQL Server service is running");
             }
             
             Logger.getLogger(DBConnection.class.getName()).log(Level.SEVERE,null,sqlEx);
             sqlEx.printStackTrace();
         }
         catch(Exception ex){
             System.err.println("=== LỖI CHUNG ===");
             System.err.println("Error message: " + ex.getMessage());
             System.err.println("Error type: " + ex.getClass().getSimpleName());
             Logger.getLogger(DBConnection.class.getName()).log(Level.SEVERE,null,ex);
             ex.printStackTrace();
         }
        System.err.println("❌ Returning null connection");
        return null;
    }
    
    public static void main(String[] args) {
        try (Connection con = getConnection()){
            if(con!=null) {
                System.out.println("Connect to petweb Successfully");
            }
        } catch (SQLException ex) {
            Logger.getLogger(DBConnection.class.getName()).log(Level.SEVERE,null, ex);
        }
    }
}
