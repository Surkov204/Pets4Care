package model;

import java.sql.Timestamp;

/**
 * Model cho Pet
 * Đại diện cho thú cưng của khách hàng
 * @author ASUS
 */
public class Pet {
    
    private int id;
    private int customerId;
    private String petName;
    private String species;
    private String breed;
    private int age;
    private String gender;
    private String description;
    private String healthStatus;
    private String imagePath;
    private Timestamp createdAt;
    private Timestamp updatedAt;
    
    // Constructors
    public Pet() {
    }
    
    public Pet(int customerId, String petName, String species, String breed, int age, String gender) {
        this.customerId = customerId;
        this.petName = petName;
        this.species = species;
        this.breed = breed;
        this.age = age;
        this.gender = gender;
    }
    
    // Getters and Setters
    public int getId() {
        return id;
    }
    
    public void setId(int id) {
        this.id = id;
    }
    
    public int getCustomerId() {
        return customerId;
    }
    
    public void setCustomerId(int customerId) {
        this.customerId = customerId;
    }
    
    public String getPetName() {
        return petName;
    }
    
    public void setPetName(String petName) {
        this.petName = petName;
    }
    
    public String getSpecies() {
        return species;
    }
    
    public void setSpecies(String species) {
        this.species = species;
    }
    
    public String getBreed() {
        return breed;
    }
    
    public void setBreed(String breed) {
        this.breed = breed;
    }
    
    public int getAge() {
        return age;
    }
    
    public void setAge(int age) {
        this.age = age;
    }
    
    public String getGender() {
        return gender;
    }
    
    public void setGender(String gender) {
        this.gender = gender;
    }
    
    public String getDescription() {
        return description;
    }
    
    public void setDescription(String description) {
        this.description = description;
    }
    
    public String getHealthStatus() {
        return healthStatus;
    }
    
    public void setHealthStatus(String healthStatus) {
        this.healthStatus = healthStatus;
    }
    
    public String getImagePath() {
        return imagePath;
    }
    
    public void setImagePath(String imagePath) {
        this.imagePath = imagePath;
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
    
    // Helper methods
    public String getGenderDisplayName() {
        switch (gender) {
            case "male":
                return "Đực";
            case "female":
                return "Cái";
            default:
                return gender;
        }
    }
    
    public String getSpeciesEmoji() {
        switch (species.toLowerCase()) {
            case "chó":
            case "dog":
                return "🐕";
            case "mèo":
            case "cat":
                return "🐱";
            case "chim":
            case "bird":
                return "🐦";
            case "cá":
            case "fish":
                return "🐠";
            default:
                return "🐾";
        }
    }
    
    public String getAgeText() {
        if (age == 1) {
            return "1 tuổi";
        } else {
            return age + " tuổi";
        }
    }
    
    @Override
    public String toString() {
        return "Pet{" +
                "id=" + id +
                ", customerId=" + customerId +
                ", petName='" + petName + '\'' +
                ", species='" + species + '\'' +
                ", breed='" + breed + '\'' +
                ", age=" + age +
                ", gender='" + gender + '\'' +
                ", healthStatus='" + healthStatus + '\'' +
                '}';
    }
}