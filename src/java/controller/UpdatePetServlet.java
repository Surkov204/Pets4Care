package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;
import model.Customer;
import model.Pet;
import service.PetService;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.logging.Logger;
import jakarta.servlet.annotation.MultipartConfig;

@MultipartConfig(
        fileSizeThreshold = 1024 * 1024, // 1MB (tùy chỉnh)
        maxFileSize = 10L * 1024 * 1024, // 10MB
        maxRequestSize = 20L * 1024 * 1024 // 20MB
)
@WebServlet("/updatepetservlet")
public class UpdatePetServlet extends HttpServlet {

    private static final Logger logger = Logger.getLogger(UpdatePetServlet.class.getName());
    private PetService petService = new PetService();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        try {
            // Lấy customer từ session
            Customer customer = (Customer) request.getSession().getAttribute("currentUser");
            if (customer == null) {
                response.sendRedirect(request.getContextPath() + "/login.jsp");
                return;
            }

            // Lấy thông tin từ form
            String petName = request.getParameter("petName");
            String species = request.getParameter("species");
            String breed = request.getParameter("breed");
            String ageStr = request.getParameter("age");
            String gender = request.getParameter("gender");
            String healthStatus = request.getParameter("healthStatus");
            String description = request.getParameter("description");
            String petIdStr = request.getParameter("petId");

            // Debug logging
            logger.info("=== DEBUG UPDATE PET SERVLET ===");
            logger.info("Pet Name: '" + petName + "'");
            logger.info("Species: '" + species + "'");
            logger.info("Breed: '" + breed + "'");
            logger.info("Age: '" + ageStr + "'");
            logger.info("Gender: '" + gender + "'");
            logger.info("Health Status: '" + healthStatus + "'");
            logger.info("Description: '" + description + "'");
            logger.info("Pet ID: '" + petIdStr + "'");

            // Validate required fields with better error handling
            if (petName == null || petName.trim().isEmpty()) {
                logger.warning("Pet name validation failed - petName is null or empty");
                request.getSession().setAttribute("errorMessage", "Tên thú cưng không được để trống!");
                response.sendRedirect(request.getContextPath() + "/petinfoservlet");
                return;
            }

            // Pet name validation passed - no additional length check needed
            if (species == null || species.trim().isEmpty()) {
                request.getSession().setAttribute("errorMessage", "Loài thú cưng không được để trống!");
                response.sendRedirect(request.getContextPath() + "/petinfoservlet");
                return;
            }

            // Parse numeric values
            int age = 0;
            if (ageStr != null && !ageStr.trim().isEmpty()) {
                try {
                    age = Integer.parseInt(ageStr);
                } catch (NumberFormatException e) {
                    request.getSession().setAttribute("errorMessage", "Tuổi phải là số hợp lệ!");
                    response.sendRedirect(request.getContextPath() + "/petinfoservlet");
                    return;
                }
            }


            // Handle file upload
            String imagePath = null;
            Part filePart = request.getPart("petImage");
            if (filePart != null && filePart.getSize() > 0) {
                String fileName = getFileName(filePart);
                if (fileName != null && !fileName.isEmpty()) {
                    // Create upload directory if it doesn't exist
                    String uploadDir = getServletContext().getRealPath("/images/pets");
                    Path uploadPath = Paths.get(uploadDir);
                    if (!Files.exists(uploadPath)) {
                        Files.createDirectories(uploadPath);
                    }

                    // Generate unique filename
                    String fileExtension = "";
                    int lastDotIndex = fileName.lastIndexOf('.');
                    if (lastDotIndex > 0) {
                        fileExtension = fileName.substring(lastDotIndex);
                    }
                    String uniqueFileName = "pet_" + customer.getCustomerId() + "_" + System.currentTimeMillis() + fileExtension;

                    // Save file
                    Path filePath = uploadPath.resolve(uniqueFileName);
                    try (InputStream fileContent = filePart.getInputStream()) {
                        Files.copy(fileContent, filePath, StandardCopyOption.REPLACE_EXISTING);
                        // Set full path for database
                        imagePath = "images/pets/" + uniqueFileName;
                        logger.info("Image saved to: " + imagePath);
                    }
                }
            }

            // Create Pet object
            Pet pet = new Pet();
            pet.setCustomerId(customer.getCustomerId());
            pet.setPetName(petName.trim());
            pet.setSpecies(species.trim());
            pet.setBreed(breed != null ? breed.trim() : "");
            pet.setAge(age);
            pet.setGender(gender != null ? gender.trim() : "");
            pet.setHealthStatus(healthStatus != null ? healthStatus.trim() : "");
            pet.setDescription(description != null ? description.trim() : "");

            // Set pet ID if provided
            if (petIdStr != null && !petIdStr.trim().isEmpty()) {
                try {
                    int petId = Integer.parseInt(petIdStr);
                    pet.setId(petId);
                } catch (NumberFormatException e) {
                    logger.warning("Invalid pet ID: " + petIdStr);
                }
            }

            // Set image path if uploaded
            if (imagePath != null) {
                pet.setImagePath(imagePath);
                logger.info("Setting new image path: " + imagePath);
            } else {
                // Keep existing image if no new image uploaded
                Pet existingPet = petService.getPetByCustomerId(customer.getCustomerId());
                if (existingPet != null && existingPet.getImagePath() != null) {
                    pet.setImagePath(existingPet.getImagePath());
                    logger.info("Keeping existing image path: " + existingPet.getImagePath());
                } else {
                    logger.info("No image path set");
                }
            }

            // Save or update pet
            boolean success;
            if (pet.getId() > 0) {
                // Update existing pet
                success = petService.updatePet(pet);
            } else {
                // Add new pet
                success = petService.savePet(pet);
            }

            if (success) {
                if (pet.getId() > 0) {
                    request.getSession().setAttribute("successMessage", "Cập nhật thông tin thú cưng thành công!");
                } else {
                    request.getSession().setAttribute("successMessage", "Thêm thú cưng mới thành công!");
                }
                logger.info("Pet " + (pet.getId() > 0 ? "updated" : "added") + " successfully for customer ID: " + customer.getCustomerId());
            } else {
                request.getSession().setAttribute("errorMessage", "Có lỗi xảy ra khi " + (pet.getId() > 0 ? "cập nhật" : "thêm") + " thông tin thú cưng!");
                logger.warning("Failed to " + (pet.getId() > 0 ? "update" : "add") + " pet for customer ID: " + customer.getCustomerId());
            }

            // Redirect back to pet info page
            response.sendRedirect(request.getContextPath() + "/petinfoservlet");

        } catch (Exception e) {
            e.printStackTrace();
            logger.severe("Error updating pet: " + e.getMessage());
            request.getSession().setAttribute("errorMessage", "Có lỗi xảy ra khi cập nhật thông tin thú cưng!");
            response.sendRedirect(request.getContextPath() + "/petinfoservlet");
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Redirect GET requests to pet info page
        response.sendRedirect(request.getContextPath() + "/petinfoservlet");
    }

    /**
     * Extract filename from Part
     */
    private String getFileName(Part part) {
        String contentDisposition = part.getHeader("content-disposition");
        if (contentDisposition != null) {
            String[] tokens = contentDisposition.split(";");
            for (String token : tokens) {
                if (token.trim().startsWith("filename")) {
                    return token.substring(token.indexOf("=") + 2, token.length() - 1);
                }
            }
        }
        return null;
    }
}
