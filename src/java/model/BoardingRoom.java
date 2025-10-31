package model;

import java.sql.Timestamp;

/**
 * Model cho BoardingRoom
 * Đại diện cho phòng lưu trú thú cưng
 * @author ASUS
 */
public class BoardingRoom {
    
    private int roomId;
    private String roomName;
    private String roomType;
    private int capacity;
    private double pricePerDay;
    private String description;
    private String status;
    private String amenities;
    private String roomImageUrl;
    private boolean isActive;
    private Timestamp createdAt;
    private Timestamp updatedAt;
    
    // Constructors
    public BoardingRoom() {
    }
    
    public BoardingRoom(String roomName, String roomType, int capacity, double pricePerDay) {
        this.roomName = roomName;
        this.roomType = roomType;
        this.capacity = capacity;
        this.pricePerDay = pricePerDay;
        this.status = "available";
        this.isActive = true;
    }
    
    // Getters and Setters
    public int getRoomId() {
        return roomId;
    }
    
    public void setRoomId(int roomId) {
        this.roomId = roomId;
    }
    
    public String getRoomName() {
        return roomName;
    }
    
    public void setRoomName(String roomName) {
        this.roomName = roomName;
    }
    
    public String getRoomType() {
        return roomType;
    }
    
    public void setRoomType(String roomType) {
        this.roomType = roomType;
    }
    
    public int getCapacity() {
        return capacity;
    }
    
    public void setCapacity(int capacity) {
        this.capacity = capacity;
    }
    
    public double getPricePerDay() {
        return pricePerDay;
    }
    
    public void setPricePerDay(double pricePerDay) {
        this.pricePerDay = pricePerDay;
    }
    
    public String getDescription() {
        return description;
    }
    
    public void setDescription(String description) {
        this.description = description;
    }
    
    public String getStatus() {
        return status;
    }
    
    public void setStatus(String status) {
        this.status = status;
    }
    
    public String getAmenities() {
        return amenities;
    }
    
    public void setAmenities(String amenities) {
        this.amenities = amenities;
    }
    
    public String getRoomImageUrl() {
        return roomImageUrl;
    }
    
    public void setRoomImageUrl(String roomImageUrl) {
        this.roomImageUrl = roomImageUrl;
    }
    
    public boolean isActive() {
        return isActive;
    }
    
    public void setActive(boolean active) {
        isActive = active;
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
    public String getRoomTypeDisplayName() {
        switch (roomType) {
            case "dog_large":
                return "Phòng Chó Lớn";
            case "dog_small":
                return "Phòng Chó Nhỏ";
            case "cat_standard":
                return "Phòng Mèo Tiêu Chuẩn";
            case "cat_vip":
                return "Phòng Mèo VIP";
            case "mixed":
                return "Phòng Hỗn Hợp";
            default:
                return roomType;
        }
    }
    
    public String getStatusDisplayName() {
        switch (status) {
            case "available":
                return "Có sẵn";
            case "occupied":
                return "Đã thuê";
            case "maintenance":
                return "Bảo trì";
            case "reserved":
                return "Đã đặt trước";
            default:
                return status;
        }
    }
    
    public String getStatusColor() {
        switch (status) {
            case "available":
                return "text-green-600 bg-green-100";
            case "occupied":
                return "text-red-600 bg-red-100";
            case "maintenance":
                return "text-yellow-600 bg-yellow-100";
            case "reserved":
                return "text-blue-600 bg-blue-100";
            default:
                return "text-gray-600 bg-gray-100";
        }
    }
    
    public String getRoomEmoji() {
        switch (roomType) {
            case "dog_large":
            case "dog_small":
                return "🐕";
            case "cat_standard":
            case "cat_vip":
                return "🐱";
            case "mixed":
                return "🐾";
            default:
                return "🏠";
        }
    }
    
    public String getFormattedPrice() {
        return String.format("%.0f₫", pricePerDay);
    }
    
    public String getCapacityText() {
        if (capacity == 1) {
            return "1 thú cưng";
        } else {
            return capacity + " thú cưng";
        }
    }
    
    public boolean isAvailable() {
        return "available".equals(status);
    }
    
    @Override
    public String toString() {
        return "BoardingRoom{" +
                "roomId=" + roomId +
                ", roomName='" + roomName + '\'' +
                ", roomType='" + roomType + '\'' +
                ", capacity=" + capacity +
                ", pricePerDay=" + pricePerDay +
                ", status='" + status + '\'' +
                ", isActive=" + isActive +
                '}';
    }
}
