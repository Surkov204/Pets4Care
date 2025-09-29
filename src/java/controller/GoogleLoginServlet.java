package controller;


import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import model.Customer;
import model.GoogleUser;
import service.UserService;
import utils.GoogleConstants;
import java.io.IOException;
import service.IUserService;
import utils.*;

@WebServlet(name = "GoogleLoginServlet", urlPatterns = {"/logingoogle"})
public class GoogleLoginServlet extends HttpServlet {

    private final IUserService userService = new UserService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String code = request.getParameter("code");

        if (code == null || code.isEmpty()) {
            // Chưa đăng nhập → redirect đến Google
//            String oauthURL = "https://accounts.google.com/o/oauth2/auth"
//                    + "?client_id=" + GoogleConstants.CLIENT_ID
//                    + "&redirect_uri=" + GoogleConstants.REDIRECT_URI
//                    + "&response_type=code"
//                    + "&scope=email%20profile"
//                    + "&prompt=select_account";
        //    response.sendRedirect(oauthURL);
            return;
        }

        // Đã đăng nhập → lấy thông tin user từ Google
        String accessToken = GoogleUtils.getToken(code);
        GoogleUser googleUser = GoogleUtils.getUserInfo(accessToken);

        Customer customer = userService.loginWithGoogle(googleUser);

        // Lưu session và chuyển về home
        HttpSession session = request.getSession();
        session.setAttribute("currentUser", customer);
        session.setAttribute("role", "customer");

        response.sendRedirect("home");
    }
}
