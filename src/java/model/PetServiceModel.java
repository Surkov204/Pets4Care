package model;

import java.math.BigDecimal;
import java.sql.Timestamp;

/**
 * Model cho dịch vụ thú cưng (Spa & Khám sức khỏe)
 * Tương ứng với bảng PetService trong database
 * @author ASUS
 */
public class PetServiceModel {
    private int serviceId;
    private String name;
    private String serviceType; // "spa" hoặc "health_check"
    private String description;
    private BigDecimal price;
    private int duration; // thời gian thực hiện (phút)
    private String status; // "active", "inactive"
    private String imagePath;
    private Timestamp createdAt;
    private Timestamp updatedAt;

    // Constructor mặc định
    public PetServiceModel() {}

    // Constructor đầy đủ
    public PetServiceModel(int serviceId, String name, String serviceType, 
                     String description, BigDecimal price, int duration, 
                     String status, String imagePath, Timestamp createdAt, Timestamp updatedAt) {
        this.serviceId = serviceId;
        this.name = name;
        this.serviceType = serviceType;
        this.description = description;
        this.price = price;
        this.duration = duration;
        this.status = status;
        this.imagePath = imagePath;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
    }

    // Constructor không có ID (cho insert)
    public PetServiceModel (String name, String serviceType, String description, 
                     BigDecimal price, int duration, String status, String imagePath) {
        this.name = name;
        this.serviceType = serviceType;
        this.description = description;
        this.price = price;
        this.duration = duration;
        this.status = status;
        this.imagePath = imagePath;
    }

    // Getters & Setters
    public int getServiceId() {
        return serviceId;
    }

    public void setServiceId(int serviceId) {
        this.serviceId = serviceId;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getServiceType() {
        return serviceType;
    }

    public void setServiceType(String serviceType) {
        this.serviceType = serviceType;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public BigDecimal getPrice() {
        return price;
    }

    public void setPrice(BigDecimal price) {
        this.price = price;
    }

    public int getDuration() {
        return duration;
    }

    public void setDuration(int duration) {
        this.duration = duration;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getImagePath() {
        return imagePath;
    }

    public void setImagePath(String imagePath) {
        this.imagePath = imagePath;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public Timestamp getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(Timestamp updatedAt) {
        this.updatedAt = updatedAt;
    }

    // Helper methods
    public boolean isSpaService() {
        return "spa".equalsIgnoreCase(serviceType);
    }

    public boolean isHealthCheckService() {
        return "health_check".equalsIgnoreCase(serviceType);
    }

    public boolean isActive() {
        return "active".equalsIgnoreCase(status);
    }

    public String getServiceTypeDisplayName() {
        switch (serviceType != null ? serviceType.toLowerCase() : "") {
            case "spa": return "Dịch vụ Spa";
            case "health_check": return "Khám sức khỏe";
            default: return "Chưa xác định";
        }
    }

    @Override
    public String toString() {
        return "PetService{" +
                "serviceId=" + serviceId +
                ", name='" + name + '\'' +
                ", serviceType='" + serviceType + '\'' +
                ", price=" + price +
                ", duration=" + duration +
                ", status='" + status + '\'' +
                '}';
    }
}
