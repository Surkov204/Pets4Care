package model;

import java.sql.Timestamp;

public class Notification {
    private int notificationID;
    private Integer staffID; // có thể null nếu là gửi cho admin
    private String title;
    private String message;
    private Timestamp createdAt;
    private boolean isRead;
    private boolean isHandled;
    private Integer relatedRequestID; // 🔗 liên kết với ShiftRequests

    // ===== Constructors =====
    public Notification() {}

    public Notification(int notificationID, Integer staffID, String title, String message,
                        Timestamp createdAt, boolean isRead, boolean isHandled) {
        this.notificationID = notificationID;
        this.staffID = staffID;
        this.title = title;
        this.message = message;
        this.createdAt = createdAt;
        this.isRead = isRead;
        this.isHandled = isHandled;
    }

    // ===== Getter & Setter =====
    public int getNotificationID() {
        return notificationID;
    }

    public void setNotificationID(int notificationID) {
        this.notificationID = notificationID;
    }

    public Integer getStaffID() {
        return staffID;
    }

    public void setStaffID(Integer staffID) {
        this.staffID = staffID;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public boolean isRead() {
        return isRead;
    }

    public void setRead(boolean isRead) {
        this.isRead = isRead;
    }

    public boolean isHandled() {
        return isHandled;
    }

    public void setHandled(boolean isHandled) {
        this.isHandled = isHandled;
    }

    public Integer getRelatedRequestID() {
        return relatedRequestID;
    }

    public void setRelatedRequestID(Integer relatedRequestID) {
        this.relatedRequestID = relatedRequestID;
    }
}