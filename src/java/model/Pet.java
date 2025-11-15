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
    private Double weightKg;
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
    
    public Double getWeightKg() {
        return weightKg;
    }
    
    public void setWeightKg(Double weightKg) {
        this.weightKg = weightKg;
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
    
    public String getSpeciesDisplayName() {
        if (species == null) return "Không xác định";
        switch (species.toLowerCase()) {
            case "dog":
            case "chó":
                return "Chó";
            case "cat":
            case "mèo":
                return "Mèo";
            case "bird":
            case "chim":
                return "Chim";
            case "rabbit":
            case "thỏ":
                return "Thỏ";
            case "hamster":
                return "Hamster";
            case "fish":
            case "cá":
                return "Cá";
            case "other":
            case "khác":
                return "Khác";
            default:
                return species; // Nếu không khớp, trả về giá trị gốc
        }
    }
    
    public String getAgeText() {
        if (age == 1) {
            return "1 tuổi";
        } else {
            return age + " tuổi";
        }
    }

    public String getWeightDisplay() {
        if (weightKg == null) {
            return "Chưa cập nhật";
        }
        if (weightKg % 1 == 0) {
            return String.format(java.util.Locale.US, "%.0f kg", weightKg);
        }
        return String.format(java.util.Locale.US, "%.1f kg", weightKg);
    }

    public String getSizeGroupDisplay() {
        if (weightKg == null) {
            return "Chưa phân loại";
        }

        String normalizedSpecies = species != null ? species.toLowerCase() : "";
        double weight = weightKg.doubleValue();

        if ("dog".equals(normalizedSpecies) || "chó".equals(normalizedSpecies)) {
            if (weight < 7.0) {
                return "Small (<7kg)";
            } else if (weight < 16.0) {
                return "Medium (8–15kg)";
            } else if (weight <= 30.0) {
                return "Large (16–30kg)";
            } else {
                return "Giant (31kg+)";
            }
        }

        if ("cat".equals(normalizedSpecies) || "mèo".equals(normalizedSpecies)) {
            if (weight < 4.0) {
                return "Small (<4kg)";
            } else if (weight < 6.0) {
                return "Medium (4–6kg)";
            } else if (weight < 8.0) {
                return "Large (6–8kg)";
            } else {
                return "Giant (8kg+)";
            }
        }

        if (weight < 2.0) {
            return "Nhỏ (<2kg)";
        } else if (weight < 10.0) {
            return "Vừa (2–9kg)";
        } else if (weight < 25.0) {
            return "Lớn (10–24kg)";
        } else {
            return "Siêu lớn (25kg+)";
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
                ", weightKg=" + weightKg +
                ", healthStatus='" + healthStatus + '\'' +
                '}';
    }
}