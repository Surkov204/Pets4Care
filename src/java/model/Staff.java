package model;

public class Staff {
    private int staffId;
    private String name;
    private String email;
    private String phone;
    private String password;
    private String position; // vị trí công việc
    private String scheduleNote; // ghi chú lịch làm việc

    // Constructors
    public Staff() {}

    public Staff(int staffId, String name, String email, String phone, String password, String position) {
        this.staffId = staffId;
        this.name = name;
        this.email = email;
        this.phone = phone;
        this.password = password;
        this.position = position;
    }

    // Getters and Setters
    public int getStaffId() {
        return staffId;
    }

    public void setStaffId(int staffId) {
        this.staffId = staffId;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public String getPosition() {
        return position;
    }

    public void setPosition(String position) {
        this.position = position;
    }
    
    public String getScheduleNote() {
        return scheduleNote;
    }
    
    public void setScheduleNote(String scheduleNote) {
        this.scheduleNote = scheduleNote;
    }

    @Override
    public String toString() {
        return "Staff{" +
                "staffId=" + staffId +
                ", name='" + name + '\'' +
                ", email='" + email + '\'' +
                ", position='" + position + '\'' +
                '}';
    }
}
