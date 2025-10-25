package model;

import java.sql.Timestamp;

public class AttendanceRecord {
    private int attendanceID;
    private int staffID;
    private Timestamp checkIn;
    private Timestamp checkOut;
    private double totalHours;
    private String status;
    private Timestamp createdAt;

    public AttendanceRecord() {}

    public AttendanceRecord(int attendanceID, int staffID, Timestamp checkIn, Timestamp checkOut,
                            double totalHours, String status, Timestamp createdAt) {
        this.attendanceID = attendanceID;
        this.staffID = staffID;
        this.checkIn = checkIn;
        this.checkOut = checkOut;
        this.totalHours = totalHours;
        this.status = status;
        this.createdAt = createdAt;
    }

    // Getters & Setters
    public int getAttendanceID() { return attendanceID; }
    public void setAttendanceID(int attendanceID) { this.attendanceID = attendanceID; }

    public int getStaffID() { return staffID; }
    public void setStaffID(int staffID) { this.staffID = staffID; }

    public Timestamp getCheckIn() { return checkIn; }
    public void setCheckIn(Timestamp checkIn) { this.checkIn = checkIn; }

    public Timestamp getCheckOut() { return checkOut; }
    public void setCheckOut(Timestamp checkOut) { this.checkOut = checkOut; }

    public double getTotalHours() { return totalHours; }
    public void setTotalHours(double totalHours) { this.totalHours = totalHours; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
}
