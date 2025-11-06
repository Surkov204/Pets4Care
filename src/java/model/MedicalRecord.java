package model;

import java.math.BigDecimal;
import java.sql.Timestamp;
import java.time.LocalDate;

/**
 * Model class cho Medical Record
 * Lưu thông tin chi tiết về hồ sơ y tế của thú cưng
 */
public class MedicalRecord {
    private int recordId;
    private int bookingId;
    private int petId;
    private int doctorId;
    private int customerId;
    
    // Thông tin khám bệnh
    private Timestamp examinationDate;
    private String symptoms;
    private String diagnosis;
    private String treatment;
    private String prescription;
    
    // Thông tin sức khỏe
    private BigDecimal weight;
    private BigDecimal temperature;
    private Integer heartRate;
    private String bloodPressure;
    
    // Ghi chú và theo dõi
    private String notes;
    private LocalDate followUpDate;
    private String followUpNotes;
    
    // Metadata
    private Timestamp createdAt;
    private Timestamp updatedAt;
    
    // Thông tin bổ sung từ JOIN
    private String petName;
    private String petSpecies;
    private String doctorName;
    private String customerName;
    
    // Constructors
    public MedicalRecord() {}
    
    public MedicalRecord(int bookingId, int petId, int doctorId, int customerId) {
        this.bookingId = bookingId;
        this.petId = petId;
        this.doctorId = doctorId;
        this.customerId = customerId;
        this.examinationDate = new Timestamp(System.currentTimeMillis());
    }
    
    // Getters and Setters
    public int getRecordId() {
        return recordId;
    }
    
    public void setRecordId(int recordId) {
        this.recordId = recordId;
    }
    
    public int getBookingId() {
        return bookingId;
    }
    
    public void setBookingId(int bookingId) {
        this.bookingId = bookingId;
    }
    
    public int getPetId() {
        return petId;
    }
    
    public void setPetId(int petId) {
        this.petId = petId;
    }
    
    public int getDoctorId() {
        return doctorId;
    }
    
    public void setDoctorId(int doctorId) {
        this.doctorId = doctorId;
    }
    
    public int getCustomerId() {
        return customerId;
    }
    
    public void setCustomerId(int customerId) {
        this.customerId = customerId;
    }
    
    public Timestamp getExaminationDate() {
        return examinationDate;
    }
    
    public void setExaminationDate(Timestamp examinationDate) {
        this.examinationDate = examinationDate;
    }
    
    public String getSymptoms() {
        return symptoms;
    }
    
    public void setSymptoms(String symptoms) {
        this.symptoms = symptoms;
    }
    
    public String getDiagnosis() {
        return diagnosis;
    }
    
    public void setDiagnosis(String diagnosis) {
        this.diagnosis = diagnosis;
    }
    
    public String getTreatment() {
        return treatment;
    }
    
    public void setTreatment(String treatment) {
        this.treatment = treatment;
    }
    
    public String getPrescription() {
        return prescription;
    }
    
    public void setPrescription(String prescription) {
        this.prescription = prescription;
    }
    
    public BigDecimal getWeight() {
        return weight;
    }
    
    public void setWeight(BigDecimal weight) {
        this.weight = weight;
    }
    
    public BigDecimal getTemperature() {
        return temperature;
    }
    
    public void setTemperature(BigDecimal temperature) {
        this.temperature = temperature;
    }
    
    public Integer getHeartRate() {
        return heartRate;
    }
    
    public void setHeartRate(Integer heartRate) {
        this.heartRate = heartRate;
    }
    
    public String getBloodPressure() {
        return bloodPressure;
    }
    
    public void setBloodPressure(String bloodPressure) {
        this.bloodPressure = bloodPressure;
    }
    
    public String getNotes() {
        return notes;
    }
    
    public void setNotes(String notes) {
        this.notes = notes;
    }
    
    public LocalDate getFollowUpDate() {
        return followUpDate;
    }
    
    public void setFollowUpDate(LocalDate followUpDate) {
        this.followUpDate = followUpDate;
    }
    
    public String getFollowUpNotes() {
        return followUpNotes;
    }
    
    public void setFollowUpNotes(String followUpNotes) {
        this.followUpNotes = followUpNotes;
    }
    
    public Timestamp getCreatedAt() {
        return createdAt;
    }
    
    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }
    
    public Timestamp getUpdatedAt() {
        return updatedAt;
    }
    
    public void setUpdatedAt(Timestamp updatedAt) {
        this.updatedAt = updatedAt;
    }
    
    public String getPetName() {
        return petName;
    }
    
    public void setPetName(String petName) {
        this.petName = petName;
    }
    
    public String getPetSpecies() {
        return petSpecies;
    }
    
    public void setPetSpecies(String petSpecies) {
        this.petSpecies = petSpecies;
    }
    
    public String getDoctorName() {
        return doctorName;
    }
    
    public void setDoctorName(String doctorName) {
        this.doctorName = doctorName;
    }
    
    public String getCustomerName() {
        return customerName;
    }
    
    public void setCustomerName(String customerName) {
        this.customerName = customerName;
    }
    
    @Override
    public String toString() {
        return "MedicalRecord{" +
                "recordId=" + recordId +
                ", bookingId=" + bookingId +
                ", petName='" + petName + '\'' +
                ", doctorName='" + doctorName + '\'' +
                ", examinationDate=" + examinationDate +
                ", diagnosis='" + diagnosis + '\'' +
                '}';
    }
}

