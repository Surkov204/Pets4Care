package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Cookie;
import model.Customer;
import service.UserService;

import java.io.IOException;

@WebServlet("/autologin")
public class AutoLoginServlet extends HttpServlet {

    private UserService userService = new UserService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        

        HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute("currentUser") != null) {

            response.sendRedirect("home");
            return;
        }


        Cookie[] cookies = request.getCookies();
        String rememberedEmail = null;
        String rememberedPassword = null;

        if (cookies != null) {
            for (Cookie cookie : cookies) {
                if ("remembered_email".equals(cookie.getName())) {
                    rememberedEmail = cookie.getValue();
                }
                if ("remembered_password".equals(cookie.getName())) {
                    rememberedPassword = cookie.getValue();
                }
            }
        }

  
        if (rememberedEmail != null && rememberedPassword != null && !rememberedEmail.isEmpty() && !rememberedPassword.isEmpty()) {
            Customer customer = userService.loginCustomer(rememberedEmail, rememberedPassword);
            
            if (customer != null) {
        
                session = request.getSession(true);
                session.setAttribute("currentUser", customer);
                session.setAttribute("role", "customer");
                
                response.sendRedirect("home");
                return;
            } else {
         
                Cookie emailCookie = new Cookie("remembered_email", "");
                Cookie passwordCookie = new Cookie("remembered_password", "");
                
                emailCookie.setMaxAge(0);
                passwordCookie.setMaxAge(0);
                
                emailCookie.setPath("/");
                passwordCookie.setPath("/");
                
                response.addCookie(emailCookie);
                response.addCookie(passwordCookie);
            }
        }


        response.sendRedirect("login.jsp");
    }
} 