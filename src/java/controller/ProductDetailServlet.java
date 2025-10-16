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
import model.Product;
import service.IProductService;
import service.IReviewService;
import service.ProductService;
import service.ReviewService;


@WebServlet(name = "ProductDetailServlet", urlPatterns = { "/productdetailservlet" })
public class ProductDetailServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private final IProductService productService = new ProductService();
    private final IReviewService reviewService = new ReviewService();

    // Phương thức GET để hiển thị chi tiết sản phẩm
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String idParam = request.getParameter("id");
        System.out.println("Received productId: " + idParam);

        if (idParam == null || idParam.isEmpty()) {
            response.sendRedirect("home.jsp"); // Redirect về trang chủ nếu không có tham số id
            return;
        }

        int productId;
        try {
            productId = Integer.parseInt(idParam);
        } catch (NumberFormatException ex) {
            response.sendRedirect("home.jsp"); // Redirect nếu không thể parse productId
            return;
        }

        Product product = productService.getProductById(productId); // Lấy sản phẩm theo productId
        System.out.println("Product found: " + (product != null ? product.getName() : "null"));
        if (product == null) {
            request.setAttribute("error", "Sản phẩm không tồn tại!"); // Nếu không tìm thấy sản phẩm
            request.getRequestDispatcher("home.jsp").forward(request, response);
            return;
        }

        HttpSession session = request.getSession();
        Customer currentUser = (Customer) session.getAttribute("currentUser");

        boolean canReview = false;
        if (currentUser != null) {
            canReview = reviewService.hasPurchasedAndCompleted(currentUser.getCustomerId(), productId); // Kiểm tra xem người dùng đã mua sản phẩm chưa
        }

        double avgRating = productService.getAverageRating(productId); // Lấy đánh giá trung bình
        List<Review> reviews = reviewService.listByProduct(productId, 10); // Lấy danh sách đánh giá
        List<Product> similar = productService.getSimilarProducts(product.getCategoryId(), productId, 6); // Lấy sản phẩm tương tự

        request.setAttribute("product", product);
        request.setAttribute("avgRating", avgRating);
        request.setAttribute("reviews", reviews);
        request.setAttribute("similar", similar);
        request.setAttribute("canReview", canReview); // Truyền thông tin có thể đánh giá sản phẩm

        request.getRequestDispatcher("product/product-detail.jsp").forward(request, response); // Chuyển tiếp dữ liệu sang JSP
    }

    // Phương thức POST để xử lý đánh giá sản phẩm
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String productIdRaw = request.getParameter("productId");
        String ratingRaw = request.getParameter("rating");
        String comment = request.getParameter("comment");

        HttpSession session = request.getSession();
        Customer currentUser = (Customer) session.getAttribute("currentUser");

        try {
            int productId = Integer.parseInt(productIdRaw);
            int rating = Integer.parseInt(ratingRaw);

            // Kiểm tra nếu người dùng đã đăng nhập và rating hợp lệ
            if (currentUser != null && rating >= 1 && rating <= 5) {
                boolean canReview = reviewService.hasPurchasedAndCompleted(currentUser.getCustomerId(), productId); // Kiểm tra đã mua sản phẩm
                if (canReview) {
                    Review review = new Review();
                    review.setProductId(productId);
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
            Product product = productService.getProductById(productId);
            double avgRating = productService.getAverageRating(productId);
            List<Review> reviews = reviewService.listByProduct(productId, 10);
            List<Product> similar = productService.getSimilarProducts(product.getCategoryId(), productId, 6);
            boolean canReview = currentUser != null && reviewService.hasPurchasedAndCompleted(currentUser.getCustomerId(), productId);

            request.setAttribute("product", product);
            request.setAttribute("avgRating", avgRating);
            request.setAttribute("reviews", reviews);
            request.setAttribute("similar", similar);
            request.setAttribute("canReview", canReview);

            request.getRequestDispatcher("product/product-detail.jsp").forward(request, response); // Hiển thị lại trang chi tiết sau khi gửi đánh giá

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("home.jsp"); // Nếu có lỗi, redirect về trang chủ
        }
    }

    
}

