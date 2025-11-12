package model;

import java.math.BigDecimal;
import java.sql.Timestamp;

/**
 * Model cho Boarding Booking
 * Lưu trữ thông tin đặt phòng lưu trú thú cưng
 * @author ASUS
 */
public class BoardingBooking {
    
    private int bookingId;
    private int customerId;
    private String roomType;
    private BigDecimal pricePerDay;
    private int boardingDays;
    private Timestamp checkInDate;
    private Timestamp checkOutDate;
    private String checkInTime;
    private String checkOutTime;
    private String petInfo;
    private String specialNotes;
    private String emergencyPhone1;
    private String emergencyPhone2;
    private String status; // pending, confirmed, cancelled, completed
    private BigDecimal totalPrice; // Tổng giá đã tính theo logic 12h
    private Timestamp createdAt;
    private Timestamp updatedAt;
    
    // Constructors
    public BoardingBooking() {}
    
    public BoardingBooking(int customerId, String roomType, BigDecimal pricePerDay, 
                          int boardingDays, Timestamp checkInDate, Timestamp checkOutDate,
                          String checkInTime, String checkOutTime, String petInfo,
                          String specialNotes, String emergencyPhone1, String emergencyPhone2) {
        this.customerId = customerId;
        this.roomType = roomType;
        this.pricePerDay = pricePerDay;
        this.boardingDays = boardingDays;
        this.checkInDate = checkInDate;
        this.checkOutDate = checkOutDate;
        this.checkInTime = checkInTime;
        this.checkOutTime = checkOutTime;
        this.petInfo = petInfo;
        this.specialNotes = specialNotes;
        this.emergencyPhone1 = emergencyPhone1;
        this.emergencyPhone2 = emergencyPhone2;
        this.status = "Chờ xác nhận";
        this.createdAt = new Timestamp(System.currentTimeMillis());
        this.updatedAt = new Timestamp(System.currentTimeMillis());
    }
    
    // Getters and Setters
    public int getBookingId() {
        return bookingId;
    }
    
    public void setBookingId(int bookingId) {
        this.bookingId = bookingId;
    }
    
    public int getCustomerId() {
        return customerId;
    }
    
    public void setCustomerId(int customerId) {
        this.customerId = customerId;
    }
    
    public String getRoomType() {
        return roomType;
    }
    
    public void setRoomType(String roomType) {
        this.roomType = roomType;
    }
    
    public BigDecimal getPricePerDay() {
        return pricePerDay;
    }
    
    public void setPricePerDay(BigDecimal pricePerDay) {
        this.pricePerDay = pricePerDay;
    }
    
    public int getBoardingDays() {
        return boardingDays;
    }
    
    public void setBoardingDays(int boardingDays) {
        this.boardingDays = boardingDays;
    }
    
    public Timestamp getCheckInDate() {
        return checkInDate;
    }
    
    public void setCheckInDate(Timestamp checkInDate) {
        this.checkInDate = checkInDate;
    }
    
    public Timestamp getCheckOutDate() {
        return checkOutDate;
    }
    
    public void setCheckOutDate(Timestamp checkOutDate) {
        this.checkOutDate = checkOutDate;
    }
    
    public String getCheckInTime() {
        return checkInTime;
    }
    
    public void setCheckInTime(String checkInTime) {
        this.checkInTime = checkInTime;
    }
    
    public String getCheckOutTime() {
        return checkOutTime;
    }
    
    public void setCheckOutTime(String checkOutTime) {
        this.checkOutTime = checkOutTime;
    }
    
    public String getPetInfo() {
        return petInfo;
    }
    
    public void setPetInfo(String petInfo) {
        this.petInfo = petInfo;
    }
    
    public String getSpecialNotes() {
        return specialNotes;
    }
    
    public void setSpecialNotes(String specialNotes) {
        this.specialNotes = specialNotes;
    }
    
    public String getEmergencyPhone1() {
        return emergencyPhone1;
    }
    
    public void setEmergencyPhone1(String emergencyPhone1) {
        this.emergencyPhone1 = emergencyPhone1;
    }
    
    public String getEmergencyPhone2() {
        return emergencyPhone2;
    }
    
    public void setEmergencyPhone2(String emergencyPhone2) {
        this.emergencyPhone2 = emergencyPhone2;
    }
    
    public String getStatus() {
        return status;
    }
    
    public void setStatus(String status) {
        this.status = status;
    }
    
    public BigDecimal getTotalPrice() {
        return totalPrice;
    }
    
    public void setTotalPrice(BigDecimal totalPrice) {
        this.totalPrice = totalPrice;
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
    public BigDecimal getCalculatedTotalPrice() {
        if (pricePerDay != null && boardingDays > 0) {
            return pricePerDay.multiply(BigDecimal.valueOf(boardingDays));
        }
        return BigDecimal.ZERO;
    }
    
    public String getServiceName() {
        return "🏠 Lưu trú " + roomType;
    }
    
    @Override
    public String toString() {
        return "BoardingBooking{" +
                "bookingId=" + bookingId +
                ", customerId=" + customerId +
                ", roomType='" + roomType + '\'' +
                ", pricePerDay=" + pricePerDay +
                ", boardingDays=" + boardingDays +
                ", checkInDate=" + checkInDate +
                ", checkOutDate=" + checkOutDate +
                ", status='" + status + '\'' +
                ", totalPrice=" + totalPrice +
                '}';
    }
}