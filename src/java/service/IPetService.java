package service;

import model.Pet;
import java.util.List;
import java.util.Map;

/**
 * Interface cho PetService
 * @author ASUS
 */
public interface IPetService {
    
    /**
     * Lấy thông tin pet theo customer ID
     * @param customerId ID của customer
     * @return Pet object hoặc null nếu không tìm thấy
     */
    Pet getPetByCustomerId(int customerId);
    
    /**
     * Lưu thông tin pet mới
     * @param pet Pet object cần lưu
     * @return true nếu thành công, false nếu thất bại
     */
    boolean savePet(Pet pet);
    
    /**
     * Cập nhật thông tin pet
     * @param pet Pet object cần cập nhật
     * @return true nếu thành công, false nếu thất bại
     */
    boolean updatePet(Pet pet);
    
    /**
     * Xóa thông tin pet theo customer ID
     * @param customerId ID của customer
     * @return true nếu thành công, false nếu thất bại
     */
    boolean deletePetByCustomerId(int customerId);
    
    /**
     * Kiểm tra xem customer đã có thông tin pet chưa
     * @param customerId ID của customer
     * @return true nếu đã có, false nếu chưa có
     */
    boolean hasPetInfo(int customerId);
    
    /**
     * Lưu hoặc cập nhật thông tin pet (business logic)
     * @param pet Pet object
     * @return true nếu thành công, false nếu thất bại
     */
    boolean saveOrUpdatePet(Pet pet);
    
    /**
     * Lấy tất cả thông tin pet (cho admin)
     * @return List<Pet> danh sách tất cả pet
     */
    List<Pet> getAllPets();
    
    /**
     * Tìm kiếm pet theo tên
     * @param keyword từ khóa tìm kiếm
     * @return List<Pet> danh sách pet tìm được
     */
    List<Pet> searchPetsByName(String keyword);
    
    /**
     * Lấy danh sách pet theo loài
     * @param species loài thú cưng
     * @return List<Pet> danh sách pet theo loài
     */
    List<Pet> getPetsBySpecies(String species);
    
    /**
     * Đếm số lượng pet theo loài
     * @param species loài thú cưng
     * @return số lượng pet
     */
    int countPetsBySpecies(String species);
    
    /**
     * Lấy thống kê pet theo loài
     * @return Map<String, Integer> thống kê số lượng pet theo loài
     */
    Map<String, Integer> getPetStatistics();
    
    /**
     * Validate thông tin pet trước khi lưu
     * @param pet Pet object cần validate
     * @return true nếu hợp lệ, false nếu không hợp lệ
     */
    boolean validatePetInfo(Pet pet);
    
    /**
     * Lấy danh sách pet với phân trang
     * @param offset vị trí bắt đầu
     * @param limit số lượng record
     * @return List<Pet> danh sách pet
     */
    List<Pet> getPetsByPage(int offset, int limit);
    
    /**
     * Đếm tổng số pet
     * @return số lượng pet
     */
    int countAllPets();
}
