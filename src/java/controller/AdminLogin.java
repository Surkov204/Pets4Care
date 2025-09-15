package controller;

import dao.AdminDao;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Admin;
import java.io.IOException;


@WebServlet("/login")
public class AdminLogin extends HttpServlet {
    private AdminDao adminDao = new AdminDao();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        
        String username = req.getParameter("username");
        String password = req.getParameter("password");
        
        Admin admin = adminDao.login(username, password);
        if (admin != null) {
            HttpSession session = req.getSession();
            session.setAttribute("admin", admin);
            resp.sendRedirect("home.jsp"); // chuyển tới trang chính
        } else {
            req.setAttribute("error", "Sai username hoặc password!");
            req.getRequestDispatcher("login.jsp").forward(req, resp);
        }
    }
}