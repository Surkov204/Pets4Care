package model;

import java.math.BigDecimal;
import java.sql.Timestamp;

public class BookingServiceItem {
    private int bookingServiceId;
    private int bookingId;
    private int serviceId;
    private int quantity;
    private BigDecimal price;
    private String note;
    private Timestamp createdAt;
    private String serviceName;
    private String serviceType;
    private int serviceDuration;

    public BookingServiceItem(){}

    // Constructor đầy đủ
    public BookingServiceItem (int bookingServiceId, int bookingId, int serviceId, 
                         int quantity, BigDecimal price, String note, Timestamp createdAt) {
        this.bookingServiceId = bookingServiceId;
        this.bookingId = bookingId;
        this.serviceId = serviceId;
        this.quantity = quantity;
        this.price = price;
        this.note = note;
        this.createdAt = createdAt;
    }

    // Constructor không có ID (cho insert)
    public BookingServiceItem (int bookingId, int serviceId, int quantity, 
                         BigDecimal price, String note) {
        this.bookingId = bookingId;
        this.serviceId = serviceId;
        this.quantity = quantity;
        this.price = price;
        this.note = note;
    }

    // Getters & Setters
    public int getBookingServiceId() {
        return bookingServiceId;
    }

    public void setBookingServiceId(int bookingServiceId) {
        this.bookingServiceId = bookingServiceId;
    }

    public int getBookingId() {
        return bookingId;
    }

    public void setBookingId(int bookingId) {
        this.bookingId = bookingId;
    }

    public int getServiceId() {
        return serviceId;
    }

    public void setServiceId(int serviceId) {
        this.serviceId = serviceId;
    }

    public int getQuantity() {
        return quantity;
    }

    public void setQuantity(int quantity) {
        this.quantity = quantity;
    }

    public BigDecimal getPrice() {
        return price;
    }

    public void setPrice(BigDecimal price) {
        this.price = price;
    }

    public String getNote() {
        return note;
    }

    public void setNote(String note) {
        this.note = note;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public String getServiceName() {
        return serviceName;
    }

    public void setServiceName(String serviceName) {
        this.serviceName = serviceName;
    }

    public String getServiceType() {
        return serviceType;
    }

    public void setServiceType(String serviceType) {
        this.serviceType = serviceType;
    }

    public int getServiceDuration() {
        return serviceDuration;
    }

    public void setServiceDuration(int serviceDuration) {
        this.serviceDuration = serviceDuration;
    }

    // Helper methods
    public BigDecimal getTotalPrice() {
        if (price != null && quantity > 0) {
            return price.multiply(BigDecimal.valueOf(quantity));
        }
        return BigDecimal.ZERO;
    }

    public boolean isSpaService() {
        return "spa".equalsIgnoreCase(serviceType);
    }

    public boolean isHealthCheckService() {
        return "health_check".equalsIgnoreCase(serviceType);
    }

    @Override
    public String toString() {
        return "BookingService{" +
                "bookingServiceId=" + bookingServiceId +
                ", bookingId=" + bookingId +
                ", serviceId=" + serviceId +
                ", serviceName='" + serviceName + '\'' +
                ", quantity=" + quantity +
                ", price=" + price +
                ", totalPrice=" + getTotalPrice() +
                '}';
    }
}
