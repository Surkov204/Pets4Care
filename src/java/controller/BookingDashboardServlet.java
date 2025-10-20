package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import service.BookingWorkflowService;
import model.Customer;
import model.Booking;

import java.io.IOException;
import java.util.List;
import java.util.Map;
import java.util.logging.Logger;

/**
 * Controller cho Dashboard đặt lịch tổng hợp
 * Quản lý luồng đặt lịch logic và minh bạch
 * @author ASUS
 */
@WebServlet("/booking-dashboard")
public class BookingDashboardServlet extends HttpServlet {
    
    private static final Logger logger = Logger.getLogger(BookingDashboardServlet.class.getName());
    
    private BookingWorkflowService bookingWorkflowService;
    
    @Override
    public void init() throws ServletException {
        super.init();
        this.bookingWorkflowService = new BookingWorkflowService();
    }
    
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
            String action = request.getParameter("action");
            
            if (action == null || action.equals("dashboard")) {
                // Hiển thị dashboard tổng hợp
                showBookingDashboard(request, response, customer);
            } else if (action.equals("history")) {
                // Hiển thị lịch sử đặt lịch
                showBookingHistory(request, response, customer);
            } else if (action.equals("stats")) {
                // Hiển thị thống kê
                showBookingStats(request, response, customer);
            } else if (action.equals("report")) {
                // Hiển thị báo cáo
                showBookingReport(request, response, customer);
            }
            
        } catch (Exception e) {
            logger.severe("Error in BookingDashboardServlet doGet: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("error", "Có lỗi xảy ra: " + e.getMessage());
            request.getRequestDispatcher("/error.jsp").forward(request, response);
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        Customer customer = (Customer) session.getAttribute("currentUser");
        
        if (customer == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }
        
        try {
            String action = request.getParameter("action");
            
            if (action != null && action.equals("generate-report")) {
                // Tạo báo cáo
                generateBookingReport(request, response, customer);
            }
            
        } catch (Exception e) {
            logger.severe("Error in BookingDashboardServlet doPost: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("error", "Có lỗi xảy ra: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/booking-dashboard");
        }
    }
    
    /**
     * Hiển thị dashboard tổng hợp
     */
    private void showBookingDashboard(HttpServletRequest request, HttpServletResponse response, Customer customer) 
            throws ServletException, IOException {
        
        try {
            // Lấy dữ liệu dashboard
            Map<String, Object> dashboardData = bookingWorkflowService.getCustomerDashboard(customer.getCustomerId());
            
            // Kiểm tra khả năng đặt lịch
            Map<String, Object> eligibility = bookingWorkflowService.validateBookingEligibility(customer.getCustomerId());
            
            request.setAttribute("dashboardData", dashboardData);
            request.setAttribute("eligibility", eligibility);
            
            request.getRequestDispatcher("/booking-dashboard.jsp").forward(request, response);
            
        } catch (Exception e) {
            logger.severe("Error showing booking dashboard: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("error", "Có lỗi xảy ra khi tải dashboard: " + e.getMessage());
            request.getRequestDispatcher("/error.jsp").forward(request, response);
        }
    }
    
    /**
     * Hiển thị lịch sử đặt lịch
     */
    private void showBookingHistory(HttpServletRequest request, HttpServletResponse response, Customer customer) 
            throws ServletException, IOException {
        
        try {
            // Lấy lịch sử chi tiết
            List<Map<String, Object>> detailedHistory = bookingWorkflowService.getDetailedBookingHistory(customer.getCustomerId());
            
            request.setAttribute("detailedHistory", detailedHistory);
            
            request.getRequestDispatcher("/booking-history.jsp").forward(request, response);
            
        } catch (Exception e) {
            logger.severe("Error showing booking history: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("error", "Có lỗi xảy ra khi tải lịch sử: " + e.getMessage());
            request.getRequestDispatcher("/error.jsp").forward(request, response);
        }
    }
    
    /**
     * Hiển thị thống kê
     */
    private void showBookingStats(HttpServletRequest request, HttpServletResponse response, Customer customer) 
            throws ServletException, IOException {
        
        try {
            // Lấy thống kê
            Map<String, Object> stats = bookingWorkflowService.getBookingStats(customer.getCustomerId());
            
            request.setAttribute("stats", stats);
            
            request.getRequestDispatcher("/booking-stats.jsp").forward(request, response);
            
        } catch (Exception e) {
            logger.severe("Error showing booking stats: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("error", "Có lỗi xảy ra khi tải thống kê: " + e.getMessage());
            request.getRequestDispatcher("/error.jsp").forward(request, response);
        }
    }
    
    /**
     * Hiển thị báo cáo
     */
    private void showBookingReport(HttpServletRequest request, HttpServletResponse response, Customer customer) 
            throws ServletException, IOException {
        
        try {
            // Lấy tham số ngày
            String startDate = request.getParameter("startDate");
            String endDate = request.getParameter("endDate");
            
            if (startDate == null || endDate == null) {
                // Mặc định là 30 ngày gần đây
                java.time.LocalDate today = java.time.LocalDate.now();
                java.time.LocalDate thirtyDaysAgo = today.minusDays(30);
                
                startDate = thirtyDaysAgo.toString();
                endDate = today.toString();
            }
            
            // Tạo báo cáo
            Map<String, Object> report = bookingWorkflowService.generateBookingReport(
                    customer.getCustomerId(), startDate, endDate);
            
            request.setAttribute("report", report);
            request.setAttribute("startDate", startDate);
            request.setAttribute("endDate", endDate);
            
            request.getRequestDispatcher("/booking-report.jsp").forward(request, response);
            
        } catch (Exception e) {
            logger.severe("Error showing booking report: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("error", "Có lỗi xảy ra khi tải báo cáo: " + e.getMessage());
            request.getRequestDispatcher("/error.jsp").forward(request, response);
        }
    }
    
    /**
     * Tạo báo cáo
     */
    private void generateBookingReport(HttpServletRequest request, HttpServletResponse response, Customer customer) 
            throws ServletException, IOException {
        
        try {
            String startDate = request.getParameter("startDate");
            String endDate = request.getParameter("endDate");
            
            if (startDate == null || endDate == null) {
                request.setAttribute("error", "Vui lòng chọn khoảng thời gian");
                response.sendRedirect(request.getContextPath() + "/booking-dashboard?action=report");
                return;
            }
            
            // Tạo báo cáo
            Map<String, Object> report = bookingWorkflowService.generateBookingReport(
                    customer.getCustomerId(), startDate, endDate);
            
            request.setAttribute("report", report);
            request.setAttribute("startDate", startDate);
            request.setAttribute("endDate", endDate);
            
            request.getRequestDispatcher("/booking-report.jsp").forward(request, response);
            
        } catch (Exception e) {
            logger.severe("Error generating booking report: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("error", "Có lỗi xảy ra khi tạo báo cáo: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/booking-dashboard?action=report");
        }
    }
}
