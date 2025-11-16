package controller.admin;

import dao.SystemSettingDAO;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/admin/toggleShiftRegistration")
public class ToggleShiftRegistrationController extends HttpServlet {

    private final SystemSettingDAO dao = new SystemSettingDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        String status = request.getParameter("status"); // ON / OFF
        boolean enable = "ON".equalsIgnoreCase(status);
        dao.setShiftRegistration(enable);
        System.out.println("[DEBUG] Shift registration changed → " + status);
        response.sendRedirect(request.getContextPath() + "/admin/manage-staff?tab=info");   
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        response.sendRedirect(request.getContextPath() + "/admin/manage-staff?tab=info");
    }
}
