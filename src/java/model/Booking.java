package model;

import java.sql.Timestamp;

public class Booking {
    private int bookingId;
    private int customerId;
    private int petId;
    private Timestamp appointmentStart;
    private Timestamp appointmentEnd;
    private String status; // pending, confirmed, in_progress, completed, cancelled
    private String note;
    private Timestamp createdAt;
    private int doctorId;
    private int staffId;
    private int orderId;

    // Thông tin bổ sung từ JOIN
    private String customerName;
    private String customerPhone;
    private String customerEmail;
    private String petName;
    private String petType;
    private String staffName;
    private String doctorName;

    // 👉 Tên các dịch vụ của booking (nếu 1 booking có nhiều dịch vụ)
    // Lấy từ DAO bằng STRING_AGG(...) AS service_names
    // Booking.java
        private String serviceNames; // Thêm dòng này

    public Booking() {}

    public Booking(int bookingId, int customerId, int petId, Timestamp appointmentStart,
                   Timestamp appointmentEnd, String status, String note, Timestamp createdAt,
                   int doctorId, int staffId, int orderId) {
        this.bookingId = bookingId;
        this.customerId = customerId;
        this.petId = petId;
        this.appointmentStart = appointmentStart;
        this.appointmentEnd = appointmentEnd;
        this.status = status;
        this.note = note;
        this.createdAt = createdAt;
        this.doctorId = doctorId;
        this.staffId = staffId;
        this.orderId = orderId;
    }

    // Getters & Setters
    public int getBookingId() { return bookingId; }
    public void setBookingId(int bookingId) { this.bookingId = bookingId; }

    public int getCustomerId() { return customerId; }
    public void setCustomerId(int customerId) { this.customerId = customerId; }

    public int getPetId() { return petId; }
    public void setPetId(int petId) { this.petId = petId; }

    public Timestamp getAppointmentStart() { return appointmentStart; }
    public void setAppointmentStart(Timestamp appointmentStart) { this.appointmentStart = appointmentStart; }

    public Timestamp getAppointmentEnd() { return appointmentEnd; }
    public void setAppointmentEnd(Timestamp appointmentEnd) { this.appointmentEnd = appointmentEnd; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getNote() { return note; }
    public void setNote(String note) { this.note = note; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public int getDoctorId() { return doctorId; }
    public void setDoctorId(int doctorId) { this.doctorId = doctorId; }

    public int getStaffId() { return staffId; }
    public void setStaffId(int staffId) { this.staffId = staffId; }

    public int getOrderId() { return orderId; }
    public void setOrderId(int orderId) { this.orderId = orderId; }

    public String getCustomerName() { return customerName; }
    public void setCustomerName(String customerName) { this.customerName = customerName; }

    public String getCustomerPhone() { return customerPhone; }
    public void setCustomerPhone(String customerPhone) { this.customerPhone = customerPhone; }

    public String getCustomerEmail() { return customerEmail; }
    public void setCustomerEmail(String customerEmail) { this.customerEmail = customerEmail; }

    public String getPetName() { return petName; }
    public void setPetName(String petName) { this.petName = petName; }

    public String getPetType() { return petType; }
    public void setPetType(String petType) { this.petType = petType; }

    public String getStaffName() { return staffName; }
    public void setStaffName(String staffName) { this.staffName = staffName; }

    public String getDoctorName() { return doctorName; }
    public void setDoctorName(String doctorName) { this.doctorName = doctorName; }

    // ✅ serviceNames
    public String getServiceNames() { return serviceNames; }
    public void setServiceNames(String serviceNames) { this.serviceNames = serviceNames; }

    @Override
    public String toString() {
        return "Booking{" +
                "bookingId=" + bookingId +
                ", customerName='" + customerName + '\'' +
                ", petName='" + petName + '\'' +
                ", appointmentStart=" + appointmentStart +
                ", status='" + status + '\'' +
                ", serviceNames='" + serviceNames + '\'' +
                '}';
    }
}
