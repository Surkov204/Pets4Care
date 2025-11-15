package controller;

import dao.DoctorDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.logging.Logger;
import model.Doctor;

public class DoctorProfileController extends HttpServlet {
    private static final Logger logger = Logger.getLogger(DoctorProfileController.class.getName());
    private final DoctorDAO doctorDAO = new DoctorDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        Doctor doctor = (Doctor) session.getAttribute("doctor");

        if (doctor == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        try {
            Doctor fullDoctorInfo = doctorDAO.findById(doctor.getDoctorId());
            if (fullDoctorInfo == null) {
                fullDoctorInfo = doctor;
            }
            request.setAttribute("fullDoctorInfo", fullDoctorInfo);
            request.getRequestDispatcher("/doctor/doctor-profile.jsp").forward(request, response);
        } catch (Exception ex) {
            logger.severe("Failed to load doctor profile: " + ex.getMessage());
            response.sendRedirect(request.getContextPath() + "/doctor/dashboard");
        }
    }
}
