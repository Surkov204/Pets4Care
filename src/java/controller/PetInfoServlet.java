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
            
            String action = request.getParameter("action");
            String petIdParam = request.getParameter("petId");
            
            // Nếu có action=edit và petId, load pet để edit
            if ("edit".equals(action) && petIdParam != null && !petIdParam.trim().isEmpty()) {
                try {
                    int petId = Integer.parseInt(petIdParam);
                    dao.PetDAO petDAO = new dao.PetDAO();
                    Pet petToEdit = petDAO.getPetByIdAndCustomerId(petId, customer.getCustomerId());
                    
                    if (petToEdit != null) {
                        request.setAttribute("petToEdit", petToEdit);
                    } else {
                        request.getSession().setAttribute("errorMessage", "Không tìm thấy thú cưng để chỉnh sửa!");
                    }
                } catch (NumberFormatException e) {
                    request.getSession().setAttribute("errorMessage", "ID thú cưng không hợp lệ!");
                }
            }
            
            // Lấy danh sách pets của customer (1 customer có thể có nhiều pets)
            System.out.println("=== DEBUG PET INFO SERVLET ===");
            System.out.println("Customer ID: " + customer.getCustomerId());
            dao.PetDAO petDAO = new dao.PetDAO();
            java.util.List<Pet> pets = petDAO.getPetsByCustomerId(customer.getCustomerId());
            System.out.println("Pets loaded: " + (pets != null ? pets.size() : 0));
            
            // Set danh sách pets vào request để JSP có thể hiển thị
            request.setAttribute("pets", pets != null ? pets : new java.util.ArrayList<>());
            request.setAttribute("petsCount", pets != null ? pets.size() : 0);
            
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
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        
        try {
            // Lấy customer từ session
            Customer customer = (Customer) request.getSession().getAttribute("currentUser");
            if (customer == null) {
                response.sendRedirect(request.getContextPath() + "/login.jsp");
                return;
            }
            
            String action = request.getParameter("action");
            
            if ("delete".equals(action)) {
                // Xóa pet
                String petIdStr = request.getParameter("petId");
                if (petIdStr != null && !petIdStr.trim().isEmpty()) {
                    try {
                        int petId = Integer.parseInt(petIdStr);
                        dao.PetDAO petDAO = new dao.PetDAO();
                        boolean success = petDAO.deletePetById(petId, customer.getCustomerId());
                        
                        if (success) {
                            request.getSession().setAttribute("successMessage", "Xóa thú cưng thành công!");
                        } else {
                            request.getSession().setAttribute("errorMessage", "Không thể xóa thú cưng. Có thể thú cưng không tồn tại hoặc không thuộc về bạn.");
                        }
                    } catch (NumberFormatException e) {
                        request.getSession().setAttribute("errorMessage", "ID thú cưng không hợp lệ!");
                    }
                } else {
                    request.getSession().setAttribute("errorMessage", "ID thú cưng không được để trống!");
                }
            }
            
            // Redirect về GET để hiển thị lại danh sách
            response.sendRedirect(request.getContextPath() + "/petinfoservlet");
            
        } catch (Exception e) {
            e.printStackTrace();
            request.getSession().setAttribute("errorMessage", "Có lỗi xảy ra khi xóa thú cưng!");
            response.sendRedirect(request.getContextPath() + "/petinfoservlet");
        }
    }
}
