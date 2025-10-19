package model;

import java.sql.Date;
import java.sql.Timestamp;

public class ShiftRequest {
    private int requestID;
    private int employeeID;
    private String type;
    private Date targetDate;
    private int fromShiftID;
    private int toShiftID;
    private String reason;
    private String status;
    private Integer approvedBy;
    private Timestamp createdAt;

    public ShiftRequest() {}

    public ShiftRequest(int requestID, int employeeID, String type, Date targetDate, int fromShiftID, int toShiftID, String reason, String status, Integer approvedBy, Timestamp createdAt) {
        this.requestID = requestID;
        this.employeeID = employeeID;
        this.type = type;
        this.targetDate = targetDate;
        this.fromShiftID = fromShiftID;
        this.toShiftID = toShiftID;
        this.reason = reason;
        this.status = status;
        this.approvedBy = approvedBy;
        this.createdAt = createdAt;
    }

    public int getRequestID() { return requestID; }
    public void setRequestID(int requestID) { this.requestID = requestID; }

    public int getEmployeeID() { return employeeID; }
    public void setEmployeeID(int employeeID) { this.employeeID = employeeID; }

    public String getType() { return type; }
    public void setType(String type) { this.type = type; }

    public Date getTargetDate() { return targetDate; }
    public void setTargetDate(Date targetDate) { this.targetDate = targetDate; }

    public int getFromShiftID() { return fromShiftID; }
    public void setFromShiftID(int fromShiftID) { this.fromShiftID = fromShiftID; }

    public int getToShiftID() { return toShiftID; }
    public void setToShiftID(int toShiftID) { this.toShiftID = toShiftID; }

    public String getReason() { return reason; }
    public void setReason(String reason) { this.reason = reason; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public Integer getApprovedBy() { return approvedBy; }
    public void setApprovedBy(Integer approvedBy) { this.approvedBy = approvedBy; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
}
