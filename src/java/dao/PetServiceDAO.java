package dao;

import utils.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class PetServiceDAO {
    
    public String getServiceNameById(int serviceId) throws SQLException {
        String sql = "SELECT name FROM PetService WHERE service_id = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, serviceId);
            
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getString("name");
                }
            }
        }
        
        return null;
    }
    
    public double getServicePriceById(int serviceId) throws SQLException {
        String sql = "SELECT price FROM PetService WHERE service_id = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, serviceId);
            
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getDouble("price");
                }
            }
        }
        
        return 0.0;
    }
}
