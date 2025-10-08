package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import service.ProductService;
import model.Product;
import model.Staff;
import model.Review;

import java.io.IOException;
import java.util.List;
import java.util.logging.Logger;

@WebServlet("/staff/products")
public class StaffProductServlet extends HttpServlet {
    private ProductService productService = new ProductService();
    private static final Logger logger = Logger.getLogger(StaffProductServlet.class.getName());

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Kiểm tra xác thực staff
        if (!isStaffAuthenticated(request)) {
            response.sendRedirect(request.getContextPath() + "/login.jsp?error=staff_required");
            return;
        }

        try {
            String action = request.getParameter("action");
            if (action == null) {
                action = "list";
            }

            switch (action) {
                case "list":
                    handleListProducts(request, response);
                    break;
                case "view":
                    handleViewProduct(request, response);
                    break;
                case "search":
                    handleSearchProducts(request, response);
                    break;
                case "filter":
                    handleFilterProducts(request, response);
                    break;
                default:
                    handleListProducts(request, response);
                    break;
            }
        } catch (Exception e) {
            logger.severe("Error in StaffProductServlet: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("error", "Có lỗi xảy ra: " + e.getMessage());
            request.getRequestDispatcher("/staff/product-list.jsp").forward(request, response);
        }
    }

    private boolean isStaffAuthenticated(HttpServletRequest request) {
        HttpSession session = request.getSession();
        Staff staff = (Staff) session.getAttribute("staff");
        return staff != null;
    }

    private void handleListProducts(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Xử lý phân trang
        int page = 1;
        String pageRaw = request.getParameter("page");
        if (pageRaw != null) {
            try {
                page = Integer.parseInt(pageRaw);
                if (page < 1) page = 1;
            } catch (NumberFormatException e) {
                page = 1;
            }
        }

        int pageSize = 12;
        int offset = (page - 1) * pageSize;
        
        List<Product> products = productService.getProductsByPage(offset, pageSize);
        int totalProducts = productService.countAllProducts();
        int totalPages = (int) Math.ceil((double) totalProducts / pageSize);

        request.setAttribute("products", products);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalProducts", totalProducts);

        request.getRequestDispatcher("/staff/product-list.jsp").forward(request, response);
    }

    private void handleViewProduct(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String productIdRaw = request.getParameter("id");
        if (productIdRaw == null) {
            response.sendRedirect(request.getContextPath() + "/staff/products");
            return;
        }

        try {
            int productId = Integer.parseInt(productIdRaw);
            Product product = productService.getProductById(productId);
            
            if (product != null) {
                // Lấy danh sách đánh giá sản phẩm
                List<Review> productReviews = productService.getProductReviews(productId);
                
                request.setAttribute("product", product);
                request.setAttribute("productReviews", productReviews);
                request.getRequestDispatcher("/staff/product-detail.jsp").forward(request, response);
            } else {
                request.setAttribute("error", "Không tìm thấy sản phẩm");
                response.sendRedirect(request.getContextPath() + "/staff/products");
            }
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/staff/products");
        }
    }

    private void handleSearchProducts(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String keyword = request.getParameter("keyword");
        if (keyword == null || keyword.trim().isEmpty()) {
            handleListProducts(request, response);
            return;
        }

        // Xử lý phân trang cho kết quả tìm kiếm
        int page = 1;
        String pageRaw = request.getParameter("page");
        if (pageRaw != null) {
            try {
                page = Integer.parseInt(pageRaw);
                if (page < 1) page = 1;
            } catch (NumberFormatException e) {
                page = 1;
            }
        }

        int pageSize = 12;
        int offset = (page - 1) * pageSize;
        
        List<Product> products = productService.searchProducts(keyword.trim(), offset, pageSize);
        int totalProducts = productService.countSearchProducts(keyword.trim());
        int totalPages = (int) Math.ceil((double) totalProducts / pageSize);

        request.setAttribute("products", products);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalProducts", totalProducts);
        request.setAttribute("keyword", keyword);

        request.getRequestDispatcher("/staff/product-list.jsp").forward(request, response);
    }

    private void handleFilterProducts(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String categoryIdRaw = request.getParameter("categoryId");
        String supplierIdRaw = request.getParameter("supplierId");
        String minPriceRaw = request.getParameter("minPrice");
        String maxPriceRaw = request.getParameter("maxPrice");

        // Xử lý phân trang cho kết quả lọc
        int page = 1;
        String pageRaw = request.getParameter("page");
        if (pageRaw != null) {
            try {
                page = Integer.parseInt(pageRaw);
                if (page < 1) page = 1;
            } catch (NumberFormatException e) {
                page = 1;
            }
        }

        int pageSize = 12;
        int offset = (page - 1) * pageSize;
        
        List<Product> products = productService.filterProducts(categoryIdRaw, supplierIdRaw, minPriceRaw, maxPriceRaw, offset, pageSize);
        int totalProducts = productService.countFilterProducts(categoryIdRaw, supplierIdRaw, minPriceRaw, maxPriceRaw);
        int totalPages = (int) Math.ceil((double) totalProducts / pageSize);

        request.setAttribute("products", products);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalProducts", totalProducts);
        request.setAttribute("selectedCategoryId", categoryIdRaw);
        request.setAttribute("selectedSupplierId", supplierIdRaw);
        request.setAttribute("selectedMinPrice", minPriceRaw);
        request.setAttribute("selectedMaxPrice", maxPriceRaw);

        request.getRequestDispatcher("/staff/product-list.jsp").forward(request, response);
    }
}
