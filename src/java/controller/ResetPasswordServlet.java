package controller;

import dao.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet("/resetpasswordservlet")
public class ResetPasswordServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        HttpSession session = request.getSession(false); // Không tạo session mới
        
        if (session == null || session.getAttribute("verifiedEmail") == null) {
            response.sendRedirect("forgot-password.jsp?error=invalid_session");
            return;
        }
        
        String email = (String) session.getAttribute("verifiedEmail");
        String newPassword = request.getParameter("newPassword");
        String confirmPassword = request.getParameter("confirmPassword");
        
        // Kiểm tra session và mật khẩu
        if (!newPassword.equals(confirmPassword)) {
            request.setAttribute("message_resetpass", "Mật khẩu xác nhận không khớp!");
            request.setAttribute("messageType", "error");
            request.getRequestDispatcher("resetpassword.jsp").forward(request, response);
            return;
        }
        
        try {
            UserDAO userDAO = new UserDAO();
            boolean success = userDAO.resetPassword(email, newPassword);
            
            if (success) {
                // Hủy toàn bộ session sau khi thành công
                session.invalidate();
                
                // Tạo session mới chỉ để hiển thị thông báo
                HttpSession newSession = request.getSession(true);
                newSession.setAttribute("message_resetpass", "Đặt lại mật khẩu thành công! Vui lòng đăng nhập.");
                newSession.setAttribute("messageType", "success");
                
                response.sendRedirect("login.jsp");
            } else {
                request.setAttribute("message_resetpass", "Đặt lại mật khẩu thất bại. Vui lòng thử lại.");
                request.setAttribute("messageType", "error");
                request.getRequestDispatcher("resetpassword.jsp").forward(request, response);
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("message_resetpass", "Lỗi hệ thống: " + e.getMessage());
            request.setAttribute("messageType", "error");
            request.getRequestDispatcher("resetpassword.jsp").forward(request, response);
        }
    }
}