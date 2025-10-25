package model;

import java.sql.Timestamp;
import java.sql.Date;

public class PayrollRecord {
    private int payrollID;
    private int staffID;
    private Date periodStart;
    private Date periodEnd;
    private double totalHours;
    private double hourlyRate;
    private double totalSalary;
    private Timestamp createdAt;

    public PayrollRecord() {}

    public PayrollRecord(int payrollID, int staffID, Date periodStart, Date periodEnd,
                         double totalHours, double hourlyRate, double totalSalary, Timestamp createdAt) {
        this.payrollID = payrollID;
        this.staffID = staffID;
        this.periodStart = periodStart;
        this.periodEnd = periodEnd;
        this.totalHours = totalHours;
        this.hourlyRate = hourlyRate;
        this.totalSalary = totalSalary;
        this.createdAt = createdAt;
    }

    // Getters & Setters
    public int getPayrollID() { return payrollID; }
    public void setPayrollID(int payrollID) { this.payrollID = payrollID; }

    public int getStaffID() { return staffID; }
    public void setStaffID(int staffID) { this.staffID = staffID; }

    public Date getPeriodStart() { return periodStart; }
    public void setPeriodStart(Date periodStart) { this.periodStart = periodStart; }

    public Date getPeriodEnd() { return periodEnd; }
    public void setPeriodEnd(Date periodEnd) { this.periodEnd = periodEnd; }

    public double getTotalHours() { return totalHours; }
    public void setTotalHours(double totalHours) { this.totalHours = totalHours; }

    public double getHourlyRate() { return hourlyRate; }
    public void setHourlyRate(double hourlyRate) { this.hourlyRate = hourlyRate; }

    public double getTotalSalary() { return totalSalary; }
    public void setTotalSalary(double totalSalary) { this.totalSalary = totalSalary; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
}
