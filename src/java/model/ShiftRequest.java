package model;

import java.sql.Date;
import java.sql.Timestamp;

public class ShiftRequest {

    private int requestID;
    private int employeeID;     // Người gửi yêu cầu đổi ca
    private int toStaffID;      // Người được chọn để đổi cùng
    private String type;        // Loại yêu cầu: "Swap", "Register", ...
    private Date fromDate;      // Ngày làm hiện tại của người gửi
    private Date toDate;        // Ngày muốn đổi (của người kia)
    private int fromShiftID;    // Ca hiện tại của người gửi
    private int toShiftID;      // Ca muốn đổi sang (của người kia)
    private String reason;      // Lý do đổi ca
    private String status;      // Trạng thái: Pending / Approved / Rejected
    private Integer approvedBy; // ID Admin duyệt
    private Timestamp createdAt; // Ngày tạo yêu cầu

    // ===== Constructors =====
    public ShiftRequest() {
    }

    public ShiftRequest(int requestID, int employeeID, int toStaffID, String type,
            Date fromDate, Date toDate, int fromShiftID, int toShiftID,
            String reason, String status, Integer approvedBy, Timestamp createdAt) {
        this.requestID = requestID;
        this.employeeID = employeeID;
        this.toStaffID = toStaffID;
        this.type = type;
        this.fromDate = fromDate;
        this.toDate = toDate;
        this.fromShiftID = fromShiftID;
        this.toShiftID = toShiftID;
        this.reason = reason;
        this.status = status;
        this.approvedBy = approvedBy;
        this.createdAt = createdAt;
    }

    // ===== Getters & Setters =====
    public int getRequestID() {
        return requestID;
    }

    public void setRequestID(int requestID) {
        this.requestID = requestID;
    }

    public int getEmployeeID() {
        return employeeID;
    }

    public void setEmployeeID(int employeeID) {
        this.employeeID = employeeID;
    }

    public int getToStaffID() {
        return toStaffID;
    }

    public void setToStaffID(int toStaffID) {
        this.toStaffID = toStaffID;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public Date getFromDate() {
        return fromDate;
    }

    public void setFromDate(Date fromDate) {
        this.fromDate = fromDate;
    }

    public Date getToDate() {
        return toDate;
    }

    public void setToDate(Date toDate) {
        this.toDate = toDate;
    }

    public int getFromShiftID() {
        return fromShiftID;
    }

    public void setFromShiftID(int fromShiftID) {
        this.fromShiftID = fromShiftID;
    }

    public int getToShiftID() {
        return toShiftID;
    }

    public void setToShiftID(int toShiftID) {
        this.toShiftID = toShiftID;
    }

    public String getReason() {
        return reason;
    }

    public void setReason(String reason) {
        this.reason = reason;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public Integer getApprovedBy() {
        return approvedBy;
    }

    public void setApprovedBy(Integer approvedBy) {
        this.approvedBy = approvedBy;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public Date getTargetDate() {
        // Nếu type là "Swap" → ưu tiên fromDate
        // Nếu type là "Register" → có thể là toDate
        return (fromDate != null) ? fromDate : toDate;
    }
    private boolean toNotified;
    private boolean adminNotified;

    public boolean isToNotified() {
        return toNotified;
    }

    public void setToNotified(boolean toNotified) {
        this.toNotified = toNotified;
    }

    public boolean isAdminNotified() {
        return adminNotified;
    }

    public void setAdminNotified(boolean adminNotified) {
        this.adminNotified = adminNotified;
    }
}
