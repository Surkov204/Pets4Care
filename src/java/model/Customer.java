package model;

import java.sql.Timestamp;

public class Customer {
    private int customerId;
    private String name;
    private String phone;
    private String email;
    private String password;
    private String googleId;
    private String addressCustomer;
    private String status;
    private String resetToken;  // Token reset mật khẩu
    private Timestamp resetTokenExpiry;

    // Constructor mặc định
    public Customer() {}

    // Constructor đầy đủ
    public Customer(int customerId, String name, String phone, String email, String password, String googleId, String addressCustomer, String status) {
        this.customerId = customerId;
        this.name = name;
        this.phone = phone;
        this.email = email;
        this.password = password;
        this.googleId = googleId;
        this.addressCustomer = addressCustomer;
        this.status = status;
    }

    // Getter & Setter
    public int getCustomerId() {
        return customerId;
    }

    public void setCustomerId(int customerId) {
        this.customerId = customerId;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public String getGoogleId() {
        return googleId;
    }

    public void setGoogleId(String googleId) {
        this.googleId = googleId;
    }

    public String getAddressCustomer() {
        return addressCustomer;
    }

    public void setAddressCustomer(String addressCustomer) {
        this.addressCustomer = addressCustomer;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getResetToken() {
        return resetToken;
    }

    public void setResetToken(String resetToken) {
        this.resetToken = resetToken;
    }

    public Timestamp getResetTokenExpiry() {
        return resetTokenExpiry;
    }

    public void setResetTokenExpiry(Timestamp resetTokenExpiry) {
        this.resetTokenExpiry = resetTokenExpiry;
    }
    
}
