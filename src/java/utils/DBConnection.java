
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
            
            Class.forName(driverName);
            System.out.println("Driver loaded successfully");
            
            con = DriverManager.getConnection(dbURL,userDB,passDB);
            System.out.println("Database connection successful");
            return con;
        }
         catch(Exception ex){
             System.err.println("=== LỖI KẾT NỐI DATABASE ===");
             System.err.println("Error message: " + ex.getMessage());
             System.err.println("Error type: " + ex.getClass().getSimpleName());
             Logger.getLogger(DBConnection.class.getName()).log(Level.SEVERE,null,ex);
             ex.printStackTrace();
         }
        System.err.println("Returning null connection");
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
