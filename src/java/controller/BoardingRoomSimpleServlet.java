package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import utils.DBConnection;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Logger;

/**
 * Simple Boarding Room Servlet để test
 * @author ASUS
 */
public class BoardingRoomSimpleServlet extends HttpServlet {
    
    private static final Logger logger = Logger.getLogger(BoardingRoomSimpleServlet.class.getName());
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        try {
            // Forward to simple JSP page
            request.getRequestDispatcher("/boarding-room-simple.jsp").forward(request, response);
            
        } catch (Exception e) {
            logger.severe("Error in BoardingRoomSimpleServlet: " + e.getMessage());
            e.printStackTrace();
            response.getWriter().write("Error: " + e.getMessage());
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        doGet(request, response);
    }
}
