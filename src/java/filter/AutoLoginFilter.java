package filter;

import jakarta.servlet.*;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Cookie;
import model.Customer;
import service.UserService;
import jakarta.servlet.annotation.WebFilter;

import java.io.IOException;

@WebFilter("/*")
public class AutoLoginFilter implements Filter {

    private UserService userService = new UserService();

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;

        // Bỏ qua các trang không cần auto-login
        String requestURI = httpRequest.getRequestURI();
        if (requestURI.contains("/login") || requestURI.contains("/register") || 
            requestURI.contains("/logingoogle") || requestURI.contains("/autologin") ||
            requestURI.contains("/css/") || requestURI.contains("/js/") || 
            requestURI.contains("/images/") || requestURI.contains("/lib/")) {
            chain.doFilter(request, response);
            return;
        }

        // Kiểm tra session hiện tại
        HttpSession session = httpRequest.getSession(false);
        if (session != null && session.getAttribute("currentUser") != null) {
            chain.doFilter(request, response);
            return;
        }

        Cookie[] cookies = httpRequest.getCookies();
        String rememberedEmail = null;
        String rememberedPassword = null;
        boolean justLoggedOut = false;

        if (cookies != null) {
            for (Cookie cookie : cookies) {
                if ("remembered_email".equals(cookie.getName())) {
                    rememberedEmail = cookie.getValue();
                }
                if ("remembered_password".equals(cookie.getName())) {
                    rememberedPassword = cookie.getValue();
                }
                if ("justLoggedOut".equals(cookie.getName()) && "true".equals(cookie.getValue())) {
                    justLoggedOut = true;
                }
            }
        }

        // Nếu vừa logout thì không auto-login, và xóa luôn cookie justLoggedOut
        if (justLoggedOut) {
            Cookie logoutCookie = new Cookie("justLoggedOut", "");
            logoutCookie.setMaxAge(0);
            logoutCookie.setPath("/");
            httpResponse.addCookie(logoutCookie);
            chain.doFilter(request, response);
            return;
        }

        if (rememberedEmail != null && rememberedPassword != null && 
            !rememberedEmail.isEmpty() && !rememberedPassword.isEmpty()) {
            try {
                Customer customer = userService.loginCustomer(rememberedEmail, rememberedPassword);
                if (customer != null) {
                    session = httpRequest.getSession(true);
                    session.setAttribute("currentUser", customer);
                    session.setAttribute("role", "customer");
                } else {
                    Cookie emailCookie = new Cookie("remembered_email", "");
                    Cookie passwordCookie = new Cookie("remembered_password", "");
                    emailCookie.setMaxAge(0);
                    passwordCookie.setMaxAge(0);
                    emailCookie.setPath("/");
                    passwordCookie.setPath("/");
                    httpResponse.addCookie(emailCookie);
                    httpResponse.addCookie(passwordCookie);
                }
            } catch (Exception e) {
                System.err.println("Auto-login error: " + e.getMessage());
            }
        }

        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {
    }
} 