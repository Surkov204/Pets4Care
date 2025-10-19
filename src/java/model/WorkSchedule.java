package model;

import java.sql.Date;
import java.sql.Time;

public class WorkSchedule {
    private int scheduleId;
    private Integer doctorId;
    private Integer staffId;
    private Date workDate;
    private Time startTime;
    private Time endTime;
    private String status;
    private String note;

    public WorkSchedule() {}

    public WorkSchedule(int scheduleId, Integer doctorId, Integer staffId, Date workDate, Time startTime, Time endTime, String status, String note) {
        this.scheduleId = scheduleId;
        this.doctorId = doctorId;
        this.staffId = staffId;
        this.workDate = workDate;
        this.startTime = startTime;
        this.endTime = endTime;
        this.status = status;
        this.note = note;
    }

    public int getScheduleId() { return scheduleId; }
    public void setScheduleId(int scheduleId) { this.scheduleId = scheduleId; }

    public Integer getDoctorId() { return doctorId; }
    public void setDoctorId(Integer doctorId) { this.doctorId = doctorId; }

    public Integer getStaffId() { return staffId; }
    public void setStaffId(Integer staffId) { this.staffId = staffId; }

    public Date getWorkDate() { return workDate; }
    public void setWorkDate(Date workDate) { this.workDate = workDate; }

    public Time getStartTime() { return startTime; }
    public void setStartTime(Time startTime) { this.startTime = startTime; }

    public Time getEndTime() { return endTime; }
    public void setEndTime(Time endTime) { this.endTime = endTime; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getNote() { return note; }
    public void setNote(String note) { this.note = note; }
}
