package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;
import java.util.logging.Logger;
import model.PetServiceModel;
import service.SpaBookingService;

/**
 * Servlet để hiển thị danh sách dịch vụ Spa
 * @author ASUS
 */
public class SpaServiceServlet extends HttpServlet {
    
    private static final Logger logger = Logger.getLogger(SpaServiceServlet.class.getName());
    private SpaBookingService spaBookingService;
    
    @Override
    public void init() throws ServletException {
        super.init();
        this.spaBookingService = new SpaBookingService();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        try {
            logger.info("Loading spa services...");
            
            // Lấy danh sách dịch vụ spa từ database
            List<PetServiceModel> spaServices = spaBookingService.getActiveSpaServices();
            logger.info("Spa services loaded: " + (spaServices != null ? spaServices.size() : "null"));
            if (spaServices != null && !spaServices.isEmpty()) {
                for (PetServiceModel service : spaServices) {
                    logger.info("Service: " + service.getName() + " - " + service.getPrice());
                }
            } else {
                logger.warning("No spa services found!");
            }

            // Set attribute để JSP có thể sử dụng
            request.setAttribute("spaServices", spaServices);
            
            // Forward đến trang spa-service.jsp
            request.getRequestDispatcher("/spa-service.jsp").forward(request, response);
            
        } catch (Exception e) {
            logger.severe("Error loading spa services: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("errorMessage", "Có lỗi xảy ra khi tải danh sách dịch vụ spa: " + e.getMessage());
            request.getRequestDispatcher("/spa-service.jsp").forward(request, response);
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        doGet(request, response);
    }
}