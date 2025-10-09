package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Customer;
import model.Pet;
import service.PetService;
import java.io.IOException;

/**
 * Servlet để hiển thị thông tin pet của customer
 * @author ASUS
 */
@WebServlet("/petinfoservlet")
public class PetInfoServlet extends HttpServlet {
    
    private PetService petService = new PetService();
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        try {
            // Lấy customer từ session
            Customer customer = (Customer) request.getSession().getAttribute("currentUser");
            if (customer == null) {
                response.sendRedirect(request.getContextPath() + "/login.jsp");
                return;
            }
            
            // Lấy thông tin pet của customer
            System.out.println("=== DEBUG PET INFO SERVLET ===");
            System.out.println("Customer ID: " + customer.getCustomerId());
            Pet pet = petService.getPetByCustomerId(customer.getCustomerId());
            System.out.println("Pet loaded: " + (pet != null ? pet.getPetName() : "null"));
            
            // Set pet vào request để JSP có thể hiển thị
            request.setAttribute("pet", pet);
            request.setAttribute("hasPet", pet != null);
            
            // Lấy message từ session (nếu có)
            String successMessage = (String) request.getSession().getAttribute("successMessage");
            String errorMessage = (String) request.getSession().getAttribute("errorMessage");
            
            if (successMessage != null) {
                request.setAttribute("message", successMessage);
                request.getSession().removeAttribute("successMessage"); // Xóa sau khi hiển thị
            }
            
            if (errorMessage != null) {
                request.setAttribute("error", errorMessage);
                request.getSession().removeAttribute("errorMessage"); // Xóa sau khi hiển thị
            }
            
            // Forward đến pet-info.jsp
            request.getRequestDispatcher("user/pet-info.jsp").forward(request, response);
            
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Có lỗi xảy ra khi tải thông tin thú cưng!");
            request.getRequestDispatcher("user/pet-info.jsp").forward(request, response);
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Redirect POST requests to GET
        doGet(request, response);
    }
}
