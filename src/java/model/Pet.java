package model;

import java.sql.Timestamp;

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

    // Constructor mặc định
    public Pet() {}

    // Constructor đầy đủ
    public Pet(int id, int customerId, String petName, String species, String breed, 
               int age, String gender, String description, String healthStatus, 
               String imagePath, Timestamp createdAt, Timestamp updatedAt) {
        this.id = id;
        this.customerId = customerId;
        this.petName = petName;
        this.species = species;
        this.breed = breed;
        this.age = age;
        this.gender = gender;
        this.description = description;
        this.healthStatus = healthStatus;
        this.imagePath = imagePath;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
    }

    // Constructor không có id (cho insert)
    public Pet(int customerId, String petName, String species, String breed, 
               int age, String gender, String description, String healthStatus, String imagePath) {
        this.customerId = customerId;
        this.petName = petName;
        this.species = species;
        this.breed = breed;
        this.age = age;
        this.gender = gender;
        this.description = description;
        this.healthStatus = healthStatus;
        this.imagePath = imagePath;
    }

    // Getter & Setter
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
                ", description='" + description + '\'' +
                ", healthStatus='" + healthStatus + '\'' +
                ", imagePath='" + imagePath + '\'' +
                ", createdAt=" + createdAt +
                ", updatedAt=" + updatedAt +
                '}';
    }
}
