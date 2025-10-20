package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import dao.PetServiceDAO;
import model.Customer;
import model.PetServiceModel;

import java.io.IOException;
import java.util.List;
import java.util.logging.Logger;

/**
 * Servlet để hiển thị danh sách dịch vụ Spa
 * @author ASUS
 */
@WebServlet("/spa-service")
public class SpaServiceServlet extends HttpServlet {
    
    private static final Logger logger = Logger.getLogger(SpaServiceServlet.class.getName());
    private PetServiceDAO petServiceDAO = new PetServiceDAO();
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        Customer customer = (Customer) session.getAttribute("currentUser");
        
        if (customer == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }
        
        try {
            // Lấy danh sách dịch vụ Spa đang hoạt động
            List<PetServiceModel> spaServices = petServiceDAO.getActiveServicesByType("spa");
            
            logger.info("Loaded " + (spaServices != null ? spaServices.size() : 0) + " spa services");
            
            if (spaServices != null && !spaServices.isEmpty()) {
                for (PetServiceModel service : spaServices) {
                    logger.info("Service: " + service.getName() + " - " + service.getPrice());
                }
            } else {
                logger.warning("No spa services found!");
            }
            
            request.setAttribute("spaServices", spaServices);
            
            request.getRequestDispatcher("/spa-service.jsp").forward(request, response);
            
        } catch (Exception e) {
            logger.severe("Error loading spa services: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("error", "Có lỗi xảy ra khi tải danh sách dịch vụ: " + e.getMessage());
            request.getRequestDispatcher("/error.jsp").forward(request, response);
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        // Redirect POST requests to GET
        doGet(request, response);
    }
}
