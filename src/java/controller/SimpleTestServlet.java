package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebServlet("/simple-test")
public class SimpleTestServlet extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        request.setAttribute("currentPage", 1);
        request.setAttribute("totalProducts", 24);
        request.setAttribute("totalPages", 2);
        
        request.getRequestDispatcher("/simple-test.jsp").forward(request, response);
    }
}