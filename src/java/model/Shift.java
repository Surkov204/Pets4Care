package model;

public class Shift {
    private int shiftID;
    private String shiftCode;
    private String shiftName;
    private String startTime;
    private String endTime;
    private int breakMinutes;
    private String location;

    public boolean isRegistered() {
        return registered;
    }

    public void setRegistered(boolean registered) {
        this.registered = registered;
    }
    private boolean registered;

    public Shift() {}

    public Shift(int shiftID, String shiftCode, String shiftName, String startTime, String endTime, int breakMinutes, String location) {
        this.shiftID = shiftID;
        this.shiftCode = shiftCode;
        this.shiftName = shiftName;
        this.startTime = startTime;
        this.endTime = endTime;
        this.breakMinutes = breakMinutes;
        this.location = location;
        this.registered = false;
    }

    public int getShiftID() { return shiftID; }
    public void setShiftID(int shiftID) { this.shiftID = shiftID; }

    public String getShiftCode() { return shiftCode; }
    public void setShiftCode(String shiftCode) { this.shiftCode = shiftCode; }

    public String getShiftName() { return shiftName; }
    public void setShiftName(String shiftName) { this.shiftName = shiftName; }

    public String getStartTime() { return startTime; }
    public void setStartTime(String startTime) { this.startTime = startTime; }

    public String getEndTime() { return endTime; }
    public void setEndTime(String endTime) { this.endTime = endTime; }

    public int getBreakMinutes() { return breakMinutes; }
    public void setBreakMinutes(int breakMinutes) { this.breakMinutes = breakMinutes; }

    public String getLocation() { return location; }
    public void setLocation(String location) { this.location = location; }
}
