package controller;

import java.io.IOException;
import java.util.List;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import model.Customer;
import model.Review;
import model.Toy;
import service.IToyService;
import service.IReviewService;
import service.ToyService;
import service.ReviewService;


@WebServlet(name = "ToyDetailServlet", urlPatterns = { "/toydetailservlet" })
public class ToyDetailServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private final IToyService toyService = new ToyService();
    private final IReviewService reviewService = new ReviewService();

    // Phương thức GET để hiển thị chi tiết sản phẩm
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String idParam = request.getParameter("id");
        System.out.println("Received toyId: " + idParam);

        if (idParam == null || idParam.isEmpty()) {
            response.sendRedirect("home1.jsp"); // Redirect về trang chủ nếu không có tham số id
            return;
        }

        int toyId;
        try {
            toyId = Integer.parseInt(idParam);
        } catch (NumberFormatException ex) {
            response.sendRedirect("home1.jsp"); // Redirect nếu không thể parse toyId
            return;
        }

        Toy toy = toyService.getToyById(toyId); // Lấy sản phẩm theo toyId
        System.out.println("Toy found: " + (toy != null ? toy.getName() : "null"));
        if (toy == null) {
            request.setAttribute("error", "Sản phẩm không tồn tại!"); // Nếu không tìm thấy sản phẩm
            request.getRequestDispatcher("home1.jsp").forward(request, response);
            return;
        }

        HttpSession session = request.getSession();
        Customer currentUser = (Customer) session.getAttribute("currentUser");

        boolean canReview = false;
        if (currentUser != null) {
            canReview = reviewService.hasPurchasedAndCompleted(currentUser.getCustomerId(), toyId); // Kiểm tra xem người dùng đã mua sản phẩm chưa
        }

        double avgRating = toyService.getAverageRating(toyId); // Lấy đánh giá trung bình
        List<Review> reviews = reviewService.listByToy(toyId, 10); // Lấy danh sách đánh giá
        List<Toy> similar = toyService.getSimilarToys(toy.getCategoryId(), toyId, 6); // Lấy sản phẩm tương tự

        request.setAttribute("toy", toy);
        request.setAttribute("avgRating", avgRating);
        request.setAttribute("reviews", reviews);
        request.setAttribute("similar", similar);
        request.setAttribute("canReview", canReview); // Truyền thông tin có thể đánh giá sản phẩm

        request.getRequestDispatcher("toy/toy-detail.jsp").forward(request, response); // Chuyển tiếp dữ liệu sang JSP
    }

    // Phương thức POST để xử lý đánh giá sản phẩm
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String toyIdRaw = request.getParameter("toyId");
        String ratingRaw = request.getParameter("rating");
        String comment = request.getParameter("comment");

        HttpSession session = request.getSession();
        Customer currentUser = (Customer) session.getAttribute("currentUser");

        try {
            int toyId = Integer.parseInt(toyIdRaw);
            int rating = Integer.parseInt(ratingRaw);

            // Kiểm tra nếu người dùng đã đăng nhập và rating hợp lệ
            if (currentUser != null && rating >= 1 && rating <= 5) {
                boolean canReview = reviewService.hasPurchasedAndCompleted(currentUser.getCustomerId(), toyId); // Kiểm tra đã mua sản phẩm
                if (canReview) {
                    Review review = new Review();
                    review.setToyId(toyId);
                    review.setCustomerId(currentUser.getCustomerId());
                    review.setRating(rating);
                    review.setComment(comment);
                    reviewService.add(review); // Thêm đánh giá vào cơ sở dữ liệu

                    request.setAttribute("message", "✅ Gửi đánh giá thành công!");
                } else {
                    request.setAttribute("error", "⚠️ Bạn cần mua và hoàn tất đơn hàng mới được đánh giá sản phẩm này.");
                }
            }

            // Lấy lại dữ liệu chi tiết sản phẩm sau khi gửi đánh giá
            Toy toy = toyService.getToyById(toyId);
            double avgRating = toyService.getAverageRating(toyId);
            List<Review> reviews = reviewService.listByToy(toyId, 10);
            List<Toy> similar = toyService.getSimilarToys(toy.getCategoryId(), toyId, 6);
            boolean canReview = currentUser != null && reviewService.hasPurchasedAndCompleted(currentUser.getCustomerId(), toyId);

            request.setAttribute("toy", toy);
            request.setAttribute("avgRating", avgRating);
            request.setAttribute("reviews", reviews);
            request.setAttribute("similar", similar);
            request.setAttribute("canReview", canReview);

            request.getRequestDispatcher("toy/toy-detail.jsp").forward(request, response); // Hiển thị lại trang chi tiết sau khi gửi đánh giá

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("home.jsp"); // Nếu có lỗi, redirect về trang chủ
        }
    }

    
}
