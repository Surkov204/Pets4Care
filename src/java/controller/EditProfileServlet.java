package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Staff;

import java.io.IOException;

@WebServlet("/staff/edit-profile")
public class EditProfileServlet extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        Staff currentStaff = (Staff) session.getAttribute("staff");
        
        if (currentStaff == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }
        
        // Forward to edit-profile.jsp
        request.getRequestDispatcher("/staff/edit-profile.jsp").forward(request, response);
    }
}
