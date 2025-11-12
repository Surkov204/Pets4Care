package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import dao.MedicalRecordDAO;
import dao.PetDAO;
import dao.BookingDAO;
import model.Customer;
import model.Pet;
import model.MedicalRecord;
import model.Booking;

import java.io.IOException;
import java.util.List;
import java.util.logging.Logger;

/**
 * Servlet cho customer xem medical records của pet
 */
@WebServlet("/customer/pet-medical-records")
public class CustomerPetMedicalRecordServlet extends HttpServlet {
    private static final Logger logger = Logger.getLogger(CustomerPetMedicalRecordServlet.class.getName());
    private MedicalRecordDAO medicalRecordDAO = new MedicalRecordDAO();
    private PetDAO petDAO = new PetDAO();
    private BookingDAO bookingDAO = new BookingDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        Customer customer = (Customer) session.getAttribute("customer");

        // Kiểm tra đăng nhập
        if (customer == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        try {
            String petIdStr = request.getParameter("petId");
            
            if (petIdStr == null || petIdStr.trim().isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/petinfoservlet?error=missing_pet_id");
                return;
            }
            
            int petId = Integer.parseInt(petIdStr);
            
            // Lấy thông tin pet
            Pet pet = petDAO.getPetById(petId);
            
            if (pet == null) {
                response.sendRedirect(request.getContextPath() + "/petinfoservlet?error=pet_not_found");
                return;
            }
            
            // Kiểm tra pet có thuộc về customer này không
            if (pet.getCustomerId() != customer.getCustomerId()) {
                response.sendRedirect(request.getContextPath() + "/petinfoservlet?error=unauthorized");
                return;
            }
            
            // Lấy tất cả medical records của pet
            List<MedicalRecord> medicalRecords = medicalRecordDAO.getByPetId(petId);
            
            // Lấy tất cả bookings của pet để hiển thị lịch hẹn
            List<Booking> upcomingAppointments = bookingDAO.getBookingsByPetId(petId);
            
            // Lọc chỉ lấy các appointment sắp tới (chưa completed hoặc cancelled)
            upcomingAppointments.removeIf(b -> 
                "completed".equalsIgnoreCase(b.getStatus()) || 
                "cancelled".equalsIgnoreCase(b.getStatus())
            );
            
            // Set attributes
            request.setAttribute("pet", pet);
            request.setAttribute("medicalRecords", medicalRecords);
            request.setAttribute("upcomingAppointments", upcomingAppointments);
            
            logger.info("Customer " + customer.getName() + " viewed medical records for pet ID: " + petId);
            
            // Forward to JSP
            request.getRequestDispatcher("/user/pet-medical-records.jsp").forward(request, response);
            
        } catch (NumberFormatException e) {
            logger.warning("Invalid pet ID format: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/petinfoservlet?error=invalid_pet_id");
        } catch (Exception e) {
            logger.severe("Error loading pet medical records: " + e.getMessage());
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/petinfoservlet?error=system_error");
        }
    }
}

