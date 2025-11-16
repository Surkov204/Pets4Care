package model;

import java.sql.Date;
import java.sql.Timestamp;

public class DoctorPayrollRecord {

    public int getPayrollId() {
        return payrollId;
    }

    public int getDoctorId() {
        return doctorId;
    }

    public Date getPeriodStart() {
        return periodStart;
    }

    public Date getPeriodEnd() {
        return periodEnd;
    }

    public int getDaysWorked() {
        return daysWorked;
    }

    public int getStandardWorkingDays() {
        return standardWorkingDays;
    }

    public double getMonthlyBaseSalary() {
        return monthlyBaseSalary;
    }

    public double getTotalSalary() {
        return totalSalary;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setPayrollId(int payrollId) {
        this.payrollId = payrollId;
    }

    public void setDoctorId(int doctorId) {
        this.doctorId = doctorId;
    }

    public void setPeriodStart(Date periodStart) {
        this.periodStart = periodStart;
    }

    public void setPeriodEnd(Date periodEnd) {
        this.periodEnd = periodEnd;
    }

    public void setDaysWorked(int daysWorked) {
        this.daysWorked = daysWorked;
    }

    public void setStandardWorkingDays(int standardWorkingDays) {
        this.standardWorkingDays = standardWorkingDays;
    }

    public void setMonthlyBaseSalary(double monthlyBaseSalary) {
        this.monthlyBaseSalary = monthlyBaseSalary;
    }

    public void setTotalSalary(double totalSalary) {
        this.totalSalary = totalSalary;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }
    private int payrollId;
    private int doctorId;
    private Date periodStart;
    private Date periodEnd;
    private int daysWorked;
    private int standardWorkingDays;
    private double monthlyBaseSalary;
    private double totalSalary;
    private Timestamp createdAt;

    public DoctorPayrollRecord(int payrollId, int doctorId, Date periodStart, Date periodEnd,
                               int daysWorked, int standardWorkingDays,
                               double monthlyBaseSalary, double totalSalary,
                               Timestamp createdAt) {
        this.payrollId = payrollId;
        this.doctorId = doctorId;
        this.periodStart = periodStart;
        this.periodEnd = periodEnd;
        this.daysWorked = daysWorked;
        this.standardWorkingDays = standardWorkingDays;
        this.monthlyBaseSalary = monthlyBaseSalary;
        this.totalSalary = totalSalary;
        this.createdAt = createdAt;
    }

    // Getter + Setter
}
