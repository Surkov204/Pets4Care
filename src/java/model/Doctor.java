package model;

public class Doctor {
    private int doctorId;
    private String name;
    private String email;
    private String phone;
    private String password;
    private String specialization;

    // Constructors
    public Doctor() {}

    public Doctor(int doctorId, String name, String email, String phone, String password, String specialization) {
        this.doctorId = doctorId;
        this.name = name;
        this.email = email;
        this.phone = phone;
        this.password = password;
        this.specialization = specialization;
    }

    // Getters and Setters
    public int getDoctorId() {
        return doctorId;
    }

    public void setDoctorId(int doctorId) {
        this.doctorId = doctorId;
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

    public String getSpecialization() {
        return specialization;
    }

    public void setSpecialization(String specialization) {
        this.specialization = specialization;
    }

    @Override
    public String toString() {
        return "Doctor{" +
                "doctorId=" + doctorId +
                ", name='" + name + '\'' +
                ", email='" + email + '\'' +
                ", phone='" + phone + '\'' +
                ", specialization='" + specialization + '\'' +
                '}';
    }
}
