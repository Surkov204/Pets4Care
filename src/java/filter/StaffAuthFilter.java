package filter;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Staff;

import java.io.IOException;
import java.util.logging.Logger;

@WebFilter("/staff/*")
public class StaffAuthFilter implements Filter {
    private static final Logger logger = Logger.getLogger(StaffAuthFilter.class.getName());

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        logger.info("StaffAuthFilter initialized");
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        
        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;
        
        String requestURI = httpRequest.getRequestURI();
        String contextPath = httpRequest.getContextPath();
        String path = requestURI.substring(contextPath.length());
        
        // Cho phép truy cập trang login mà không cần xác thực
        if (path.equals("/staff/login") || path.equals("/staff/login.jsp")) {
            chain.doFilter(request, response);
            return;
        }
        
        // Kiểm tra session
        HttpSession session = httpRequest.getSession(false);
        if (session == null) {
            logger.warning("No session found for staff access to: " + path);
            httpResponse.sendRedirect(contextPath + "/login.jsp?error=session_required");
            return;
        }
        
        // Kiểm tra staff trong session
        Staff staff = (Staff) session.getAttribute("staff");
        if (staff == null) {
            logger.warning("No staff found in session for access to: " + path);
            httpResponse.sendRedirect(contextPath + "/login.jsp?error=staff_required");
            return;
        }
        
        // Kiểm tra quyền truy cập (nếu cần)
        if (path.startsWith("/staff/admin") && !"admin".equalsIgnoreCase(staff.getPosition()) && !"quản lý".equalsIgnoreCase(staff.getPosition())) {
            logger.warning("Non-admin staff trying to access admin area: " + path + " - Staff: " + staff.getName());
            httpResponse.sendRedirect(contextPath + "/staff/bookings?error=access_denied");
            return;
        }
        
        logger.info("Staff access granted: " + staff.getName() + " (" + staff.getPosition() + ") to " + path);
        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {
        logger.info("StaffAuthFilter destroyed");
    }
}
