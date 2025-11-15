package model;

import java.sql.Timestamp;
import java.sql.Date;

public class PayrollRecord {
    private int payrollID;
    private int staffID;
    private Date periodStart;
    private Date periodEnd;

    private Integer actualShifts;     // NEW
    private Double baseSalary;        // NEW

    private Double totalSalary;
    private Timestamp createdAt;

    public PayrollRecord() {}

    public PayrollRecord(int payrollID, int staffID, Date periodStart, Date periodEnd,
                         Integer actualShifts, Double baseSalary, Double totalSalary, Timestamp createdAt) {

        this.payrollID = payrollID;
        this.staffID = staffID;
        this.periodStart = periodStart;
        this.periodEnd = periodEnd;

        this.actualShifts = actualShifts;   // FIX
        this.baseSalary = baseSalary;       // FIX

        this.totalSalary = totalSalary;
        this.createdAt = createdAt;
    }

    public int getPayrollID() { return payrollID; }
    public void setPayrollID(int payrollID) { this.payrollID = payrollID; }

    public int getStaffID() { return staffID; }
    public void setStaffID(int staffID) { this.staffID = staffID; }

    public Date getPeriodStart() { return periodStart; }
    public void setPeriodStart(Date periodStart) { this.periodStart = periodStart; }

    public Date getPeriodEnd() { return periodEnd; }
    public void setPeriodEnd(Date periodEnd) { this.periodEnd = periodEnd; }

    public Integer getActualShifts() { return actualShifts; }
    public void setActualShifts(Integer actualShifts) { this.actualShifts = actualShifts; }

    public Double getBaseSalary() { return baseSalary; }
    public void setBaseSalary(Double baseSalary) { this.baseSalary = baseSalary; }

    public Double getTotalSalary() { return totalSalary; }
    public void setTotalSalary(Double totalSalary) { this.totalSalary = totalSalary; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
}