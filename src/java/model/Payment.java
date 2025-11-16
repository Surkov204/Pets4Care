package model;

import java.math.BigDecimal;
import java.sql.Timestamp;

public class Payment {
    private int paymentId;
    private String paymentType; // 'health_check', 'spa', 'boarding', 'order'
    private Integer referenceId; // order_id, booking_id, hoặc service_id
    private int customerId;
    private BigDecimal amount;
    private String paymentMethod; // 'PayOS', 'CASH', 'BANK_TRANSFER'
    private String paymentStatus; // 'pending', 'paid', 'cancelled', 'failed', 'refunded'
    private Integer payosOrderCode;
    private String transactionCode;
    private String transactionRef;
    private Timestamp createdAt;
    private Timestamp paidAt;
    private String note;
    
    // Additional fields for display
    private String serviceName;
    private String orderCode;
    
    public Payment() {}
    
    public Payment(int paymentId, String paymentType, Integer referenceId, int customerId, 
                   BigDecimal amount, String paymentMethod, String paymentStatus) {
        this.paymentId = paymentId;
        this.paymentType = paymentType;
        this.referenceId = referenceId;
        this.customerId = customerId;
        this.amount = amount;
        this.paymentMethod = paymentMethod;
        this.paymentStatus = paymentStatus;
    }
    
    // Getters and Setters
    public int getPaymentId() {
        return paymentId;
    }
    
    public void setPaymentId(int paymentId) {
        this.paymentId = paymentId;
    }
    
    public String getPaymentType() {
        return paymentType;
    }
    
    public void setPaymentType(String paymentType) {
        this.paymentType = paymentType;
    }
    
    public Integer getReferenceId() {
        return referenceId;
    }
    
    public void setReferenceId(Integer referenceId) {
        this.referenceId = referenceId;
    }
    
    public int getCustomerId() {
        return customerId;
    }
    
    public void setCustomerId(int customerId) {
        this.customerId = customerId;
    }
    
    public BigDecimal getAmount() {
        return amount;
    }
    
    public void setAmount(BigDecimal amount) {
        this.amount = amount;
    }
    
    public String getPaymentMethod() {
        return paymentMethod;
    }
    
    public void setPaymentMethod(String paymentMethod) {
        this.paymentMethod = paymentMethod;
    }
    
    public String getPaymentStatus() {
        return paymentStatus;
    }
    
    public void setPaymentStatus(String paymentStatus) {
        this.paymentStatus = paymentStatus;
    }
    
    public Integer getPayosOrderCode() {
        return payosOrderCode;
    }
    
    public void setPayosOrderCode(Integer payosOrderCode) {
        this.payosOrderCode = payosOrderCode;
    }
    
    public String getTransactionCode() {
        return transactionCode;
    }
    
    public void setTransactionCode(String transactionCode) {
        this.transactionCode = transactionCode;
    }
    
    public String getTransactionRef() {
        return transactionRef;
    }
    
    public void setTransactionRef(String transactionRef) {
        this.transactionRef = transactionRef;
    }
    
    public Timestamp getCreatedAt() {
        return createdAt;
    }
    
    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }
    
    public Timestamp getPaidAt() {
        return paidAt;
    }
    
    public void setPaidAt(Timestamp paidAt) {
        this.paidAt = paidAt;
    }
    
    public String getNote() {
        return note;
    }
    
    public void setNote(String note) {
        this.note = note;
    }
    
    public String getServiceName() {
        return serviceName;
    }
    
    public void setServiceName(String serviceName) {
        this.serviceName = serviceName;
    }
    
    public String getOrderCode() {
        return orderCode;
    }
    
    public void setOrderCode(String orderCode) {
        this.orderCode = orderCode;
    }
    
    // Helper methods
    public String getPaymentTypeDisplay() {
        switch (paymentType) {
            case "health_check":
                return "Khám sức khỏe";
            case "spa":
                return "Dịch vụ Spa";
            case "boarding":
                return "Lưu trú thú cưng";
            case "order":
                return "Đơn hàng sản phẩm";
            default:
                return paymentType;
        }
    }
    
    public String getPaymentStatusDisplay() {
        switch (paymentStatus) {
            case "paid":
                return "Đã thanh toán";
            case "pending":
                return "Chờ thanh toán";
            case "cancelled":
                return "Đã hủy";
            case "failed":
                return "Thất bại";
            case "refunded":
                return "Đã hoàn tiền";
            default:
                return paymentStatus;
        }
    }
    
    public String getPaymentMethodDisplay() {
        if (paymentMethod == null) {
            return "Chưa xác định";
        }
        return paymentMethod;
    }
}

