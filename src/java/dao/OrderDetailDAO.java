package dao;

import model.OrderDetail;
import utils.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class OrderDetailDAO {
    
    public List<OrderDetail> getOrderDetailsByOrderId(int orderId) throws SQLException {
        List<OrderDetail> orderDetails = new ArrayList<>();
        
        String sql = "SELECT * FROM Order_Detail WHERE order_id = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, orderId);
            
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    OrderDetail detail = new OrderDetail();
                    detail.setDetailId(rs.getInt("detail_id"));
                    detail.setOrderId(rs.getInt("order_id"));
                    
                    // Kiểm tra product_id
                    int productId = rs.getInt("product_id");
                    if (!rs.wasNull()) {
                        detail.setProductId(productId);
                    }
                    
                    // Kiểm tra service_id
                    int serviceId = rs.getInt("service_id");
                    if (!rs.wasNull()) {
                        detail.setServiceId(serviceId);
                    }
                    
                    detail.setQuantity(rs.getInt("quantity"));
                    detail.setUnitPrice(rs.getDouble("unit_price"));
                    
                    orderDetails.add(detail);
                }
            }
        }
        
        return orderDetails;
    }
    
    public OrderDetail getOrderDetailById(int detailId) throws SQLException {
        String sql = "SELECT * FROM Order_Detail WHERE detail_id = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, detailId);
            
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    OrderDetail detail = new OrderDetail();
                    detail.setDetailId(rs.getInt("detail_id"));
                    detail.setOrderId(rs.getInt("order_id"));
                    
                    // Kiểm tra product_id
                    int productId = rs.getInt("product_id");
                    if (!rs.wasNull()) {
                        detail.setProductId(productId);
                    }
                    
                    // Kiểm tra service_id
                    int serviceId = rs.getInt("service_id");
                    if (!rs.wasNull()) {
                        detail.setServiceId(serviceId);
                    }
                    
                    detail.setQuantity(rs.getInt("quantity"));
                    detail.setUnitPrice(rs.getDouble("unit_price"));
                    
                    return detail;
                }
            }
        }
        
        return null;
    }
}
