package dao;

import model.Payment;
import utils.DBConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Logger;

public class PaymentDAO {
    private static final Logger logger = Logger.getLogger(PaymentDAO.class.getName());
    
    /**
     * Lấy tất cả payment của một customer
     */
    public List<Payment> getPaymentsByCustomerId(int customerId) {
        List<Payment> payments = new ArrayList<>();
        String sql = "SELECT * FROM dbo.Payment WHERE customer_id = ? ORDER BY created_at DESC";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, customerId);
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Payment payment = mapPaymentFromResultSet(rs);
                    payments.add(payment);
                }
            }
            
        } catch (SQLException e) {
            logger.severe("Error getting payments by customer ID: " + e.getMessage());
            e.printStackTrace();
        }
        
        return payments;
    }
    
    /**
     * Lấy payment với thông tin chi tiết (join với các bảng liên quan để lấy tên dịch vụ)
     */
    public List<Payment> getPaymentHistoryWithDetails(int customerId) {
        List<Payment> payments = new ArrayList<>();
        String sql = 
            "SELECT p.*, " +
            "       CASE " +
            "           WHEN p.payment_type = 'health_check' THEN ps.name " +
            "           WHEN p.payment_type = 'spa' THEN ps.name " +
            "           WHEN p.payment_type = 'boarding' THEN br.room_type " +
            "           WHEN p.payment_type = 'order' THEN 'Đơn hàng #' + CAST(o.order_id AS VARCHAR) " +
            "           ELSE 'N/A' " +
            "       END AS service_name, " +
            "       CASE " +
            "           WHEN p.payment_type = 'order' THEN CAST(o.order_id AS VARCHAR) " +
            "           WHEN p.payment_type = 'health_check' AND b.booking_id IS NOT NULL THEN CAST(b.booking_id AS VARCHAR) " +
            "           WHEN p.payment_type = 'health_check' THEN 'HC-' + CAST(p.reference_id AS VARCHAR) " +
            "           WHEN p.payment_type = 'spa' AND b.booking_id IS NOT NULL THEN CAST(b.booking_id AS VARCHAR) " +
            "           WHEN p.payment_type = 'spa' THEN 'SPA-' + CAST(p.reference_id AS VARCHAR) " +
            "           WHEN p.payment_type = 'boarding' THEN CAST(bb.booking_id AS VARCHAR) " +
            "           ELSE CAST(p.reference_id AS VARCHAR) " +
            "       END AS order_code " +
            "FROM dbo.Payment p " +
            "LEFT JOIN dbo.PetService ps ON p.payment_type IN ('health_check', 'spa') AND p.reference_id = ps.service_id " +
            "LEFT JOIN dbo.BoardingRoom br ON p.payment_type = 'boarding' AND p.reference_id = br.room_id " +
            "LEFT JOIN dbo.[Order] o ON p.payment_type = 'order' AND p.reference_id = o.order_id " +
            "LEFT JOIN dbo.Booking b ON p.payment_type IN ('health_check', 'spa') AND b.customer_id = p.customer_id " +
                "AND CAST(b.appointment_start AS DATE) = CAST(p.created_at AS DATE) " +
            "LEFT JOIN dbo.boarding_bookings bb ON p.payment_type = 'boarding' AND p.reference_id = bb.booking_id " +
            "WHERE p.customer_id = ? " +
            "ORDER BY p.created_at DESC, p.payment_id DESC";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, customerId);
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Payment payment = mapPaymentFromResultSet(rs);
                    payment.setServiceName(rs.getString("service_name"));
                    payment.setOrderCode(rs.getString("order_code"));
                    payments.add(payment);
                }
            }
            
        } catch (SQLException e) {
            logger.severe("Error getting payment history with details: " + e.getMessage());
            e.printStackTrace();
        }
        
        return payments;
    }
    
    /**
     * Map ResultSet to Payment object
     */
    private Payment mapPaymentFromResultSet(ResultSet rs) throws SQLException {
        Payment payment = new Payment();
        payment.setPaymentId(rs.getInt("payment_id"));
        payment.setPaymentType(rs.getString("payment_type"));
        
        Integer refId = rs.getObject("reference_id") != null ? rs.getInt("reference_id") : null;
        payment.setReferenceId(refId);
        
        payment.setCustomerId(rs.getInt("customer_id"));
        payment.setAmount(rs.getBigDecimal("amount"));
        payment.setPaymentMethod(rs.getString("payment_method"));
        payment.setPaymentStatus(rs.getString("payment_status"));
        
        Integer payosCode = rs.getObject("payos_order_code") != null ? rs.getInt("payos_order_code") : null;
        payment.setPayosOrderCode(payosCode);
        
        payment.setTransactionCode(rs.getString("transaction_code"));
        payment.setTransactionRef(rs.getString("transaction_ref"));
        payment.setCreatedAt(rs.getTimestamp("created_at"));
        payment.setPaidAt(rs.getTimestamp("paid_at"));
        payment.setNote(rs.getString("note"));
        
        return payment;
    }
    
    /**
     * Lấy payment by ID
     */
    public Payment getPaymentById(int paymentId) {
        String sql = "SELECT * FROM dbo.Payment WHERE payment_id = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, paymentId);
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapPaymentFromResultSet(rs);
                }
            }
            
        } catch (SQLException e) {
            logger.severe("Error getting payment by ID: " + e.getMessage());
            e.printStackTrace();
        }
        
        return null;
    }
}

