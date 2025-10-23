package model;

import java.sql.Timestamp;

public class Notification {
    private int id;
    private int staffId;
    private String title;
    private String message;
    private Timestamp createdAt;
    private boolean isRead;

    public Notification() {}
    public Notification(int id, int staffId, String title, String message, Timestamp createdAt, boolean isRead) {
        this.id = id;
        this.staffId = staffId;
        this.title = title;
        this.message = message;
        this.createdAt = createdAt;
        this.isRead = isRead;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getStaffId() { return staffId; }
    public void setStaffId(int staffId) { this.staffId = staffId; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getMessage() { return message; }
    public void setMessage(String message) { this.message = message; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public boolean isRead() { return isRead; }
    public void setRead(boolean isRead) { this.isRead = isRead; }
}
