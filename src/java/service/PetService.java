package service;

import dao.IPetDAO;
import dao.PetDAO;
import model.Pet;
import java.util.List;
import java.util.Map;

/**
 * PetService implementation
 * @author ASUS
 */
public class PetService implements IPetService {
    
    private IPetDAO petDAO = new PetDAO();
    
    @Override
    public Pet getPetByCustomerId(int customerId) {
        return petDAO.getPetByCustomerId(customerId);
    }
    
    @Override
    public boolean savePet(Pet pet) {
        // Validate trước khi lưu
        System.out.println("=== DEBUG PET SERVICE SAVE ===");
        System.out.println("Customer ID: " + pet.getCustomerId());
        System.out.println("Pet Name: " + pet.getPetName());
        System.out.println("Species: " + pet.getSpecies());
        System.out.println("Breed: " + pet.getBreed());
        System.out.println("Age: " + pet.getAge());
        System.out.println("Gender: " + pet.getGender());
        
        if (!validatePetInfo(pet)) {
            System.out.println("Validation failed for pet save");
            return false;
        }
        System.out.println("Validation passed, calling DAO save");
        return petDAO.savePet(pet);
    }
    
    @Override
    public boolean updatePet(Pet pet) {
        // Validate trước khi cập nhật
        System.out.println("=== DEBUG PET SERVICE UPDATE ===");
        System.out.println("Pet ID: " + pet.getId());
        System.out.println("Customer ID: " + pet.getCustomerId());
        System.out.println("Pet Name: " + pet.getPetName());
        System.out.println("Species: " + pet.getSpecies());
        System.out.println("Breed: " + pet.getBreed());
        System.out.println("Age: " + pet.getAge());
        System.out.println("Gender: " + pet.getGender());
        
        if (!validatePetInfo(pet)) {
            System.out.println("Validation failed for pet update");
            return false;
        }
        System.out.println("Validation passed, calling DAO update");
        return petDAO.updatePet(pet);
    }
    
    @Override
    public boolean deletePetByCustomerId(int customerId) {
        return petDAO.deletePetByCustomerId(customerId);
    }
    
    @Override
    public boolean hasPetInfo(int customerId) {
        return petDAO.hasPetInfo(customerId);
    }
    
    @Override
    public boolean saveOrUpdatePet(Pet pet) {
        // Business logic: Kiểm tra đã có pet chưa
        if (hasPetInfo(pet.getCustomerId())) {
            return updatePet(pet);
        } else {
            return savePet(pet);
        }
    }
    
    @Override
    public List<Pet> getAllPets() {
        return petDAO.getAllPets();
    }
    
    @Override
    public List<Pet> searchPetsByName(String keyword) {
        // Validate keyword
        if (keyword == null || keyword.trim().isEmpty()) {
            return getAllPets();
        }
        return petDAO.searchPetsByName(keyword.trim());
    }
    
    @Override
    public List<Pet> getPetsBySpecies(String species) {
        // Validate species
        if (species == null || species.trim().isEmpty()) {
            return getAllPets();
        }
        return petDAO.getPetsBySpecies(species.trim());
    }
    
    @Override
    public int countPetsBySpecies(String species) {
        if (species == null || species.trim().isEmpty()) {
            return countAllPets();
        }
        return petDAO.countPetsBySpecies(species.trim());
    }
    
    @Override
    public Map<String, Integer> getPetStatistics() {
        return petDAO.getPetStatistics();
    }
    
    @Override
    public boolean validatePetInfo(Pet pet) {
        System.out.println("=== DEBUG VALIDATION ===");
        if (pet == null) {
            System.out.println("Pet is null");
            return false;
        }
        
        // Validate pet name
        if (pet.getPetName() == null || pet.getPetName().trim().length() < 2) {
            System.out.println("Invalid pet name: " + pet.getPetName());
            return false;
        }
        
        // Validate species
        if (pet.getSpecies() == null || pet.getSpecies().trim().isEmpty()) {
            System.out.println("Invalid species: " + pet.getSpecies());
            return false;
        }
        
        // Validate breed
        if (pet.getBreed() == null || pet.getBreed().trim().length() < 2) {
            System.out.println("Invalid breed: " + pet.getBreed());
            return false;
        }
        
        // Validate age
        if (pet.getAge() < 0 || pet.getAge() > 30) {
            System.out.println("Invalid age: " + pet.getAge());
            return false;
        }
        
        // Validate gender
        if (pet.getGender() == null || (!pet.getGender().equals("male") && !pet.getGender().equals("female"))) {
            System.out.println("Invalid gender: " + pet.getGender());
            return false;
        }
        
        // Validate customer ID
        if (pet.getCustomerId() <= 0) {
            System.out.println("Invalid customer ID: " + pet.getCustomerId());
            return false;
        }
        
        System.out.println("All validations passed");
        return true;
    }
    
    @Override
    public List<Pet> getPetsByPage(int offset, int limit) {
        // Validate parameters
        if (offset < 0 || limit <= 0) {
            return getAllPets();
        }
        
        // Business logic: Có thể thêm logic phân trang phức tạp ở đây
        List<Pet> allPets = getAllPets();
        int start = Math.min(offset, allPets.size());
        int end = Math.min(start + limit, allPets.size());
        
        return allPets.subList(start, end);
    }
    
    @Override
    public int countAllPets() {
        return getAllPets().size();
    }
}
