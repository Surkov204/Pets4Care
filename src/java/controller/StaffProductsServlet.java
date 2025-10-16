package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import dao.IProductDAO;
import dao.ProductDAO;
import dao.IProductCategoryDAO;
import dao.ProductCategoryDAO;
import model.Product;
import model.Staff;

import java.io.IOException;
import java.util.List;
import java.util.Map;

@WebServlet("/staff/products")
public class StaffProductsServlet extends HttpServlet {
    
    private IProductDAO productDAO = new ProductDAO();
    private IProductCategoryDAO categoryDAO = new ProductCategoryDAO();
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        Staff staff = (Staff) session.getAttribute("staff");
        
        // Tạm thời comment authentication để test
        /*
        if (staff == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }
        */
        
        try {
            String action = request.getParameter("action");
            String keyword = request.getParameter("keyword");
            String categoryId = request.getParameter("categoryId");
            String supplierId = request.getParameter("supplierId");
            String minPrice = request.getParameter("minPrice");
            String maxPrice = request.getParameter("maxPrice");
            String stock = request.getParameter("stock");
            String pageStr = request.getParameter("page");
            
            int page = 1;
            int limit = 15; // Mỗi trang hiển thị 15 sản phẩm
            int offset = 0;
            
            if (pageStr != null && !pageStr.trim().isEmpty()) {
                try {
                    page = Integer.parseInt(pageStr);
                    offset = (page - 1) * limit;
                } catch (NumberFormatException e) {
                    page = 1;
                    offset = 0;
                }
            }
            
            List<Product> products = null;
            int totalProducts = 0;
            
            if (action != null && action.equals("view")) {
                // Xem chi tiết product
                String productIdStr = request.getParameter("id");
                if (productIdStr != null) {
                    int productId = Integer.parseInt(productIdStr);
                    Product product = productDAO.getProductById(productId);
                    if (product != null) {
                        request.setAttribute("product", product);
                        request.getRequestDispatcher("/staff/product-detail.jsp").forward(request, response);
                        return;
                    }
                }
            } else if (action != null && action.equals("edit")) {
                // Chỉnh sửa product
                String productIdStr = request.getParameter("id");
                if (productIdStr != null) {
                    int productId = Integer.parseInt(productIdStr);
                    Product product = productDAO.getProductById(productId);
                    if (product != null) {
                        request.setAttribute("product", product);
                        request.getRequestDispatcher("/staff/product-edit.jsp").forward(request, response);
                        return;
                    }
                }
            }
            
            // Debug logging
            System.out.println("=== DEBUG STAFF PRODUCTS SERVLET ===");
            System.out.println("Action: " + action);
            System.out.println("Keyword: " + keyword);
            System.out.println("Stock: " + stock);
            System.out.println("Page: " + page);
            System.out.println("Offset: " + offset);
            System.out.println("Limit: " + limit);
            
            // Lấy danh sách products theo điều kiện
            if (keyword != null && !keyword.trim().isEmpty()) {
                System.out.println("Using searchProducts with keyword: " + keyword);
                products = productDAO.searchProducts(keyword.trim());
                totalProducts = products.size();
                System.out.println("Search returned " + products.size() + " products");
            } else if (action != null && action.equals("filter") && stock != null) {
                // Filter products theo stock status
                System.out.println("Using filterProductsByStock with stock: " + stock);
                products = productDAO.filterProductsByStock(stock);
                totalProducts = products.size();
                System.out.println("Filter returned " + products.size() + " products");
            } else if (categoryId != null || supplierId != null || minPrice != null || maxPrice != null) {
                // Filter products theo category và price
                System.out.println("Using filterProducts with categoryId: " + categoryId);
                products = productDAO.filterProducts(categoryId, minPrice, null);
                totalProducts = products.size();
                System.out.println("Category filter returned " + products.size() + " products");
            } else {
                // Lấy tất cả products với phân trang
                System.out.println("Using getProductsByPage with offset: " + offset + ", limit: " + limit);
                products = productDAO.getProductsByPage(offset, limit);
                totalProducts = productDAO.countAllProducts();
                System.out.println("Pagination returned " + products.size() + " products, total: " + totalProducts);
            }
            
            System.out.println("Final products list size: " + (products != null ? products.size() : "null"));
            System.out.println("=== END DEBUG ===");
            
            // Lấy danh sách categories cho filter
            Map<Integer, String> categories = categoryDAO.getAllCategoriesMap();
            
            request.setAttribute("products", products);
            request.setAttribute("categories", categories);
            request.setAttribute("keyword", keyword);
            request.setAttribute("categoryId", categoryId);
            request.setAttribute("supplierId", supplierId);
            request.setAttribute("minPrice", minPrice);
            request.setAttribute("maxPrice", maxPrice);
            request.setAttribute("currentPage", page);
            request.setAttribute("totalProducts", totalProducts);
            request.setAttribute("totalPages", (int) Math.ceil((double) totalProducts / limit));
            
            System.out.println("=== PAGINATION DEBUG ===");
            System.out.println("Current Page: " + page);
            System.out.println("Total Products: " + totalProducts);
            System.out.println("Total Pages: " + (int) Math.ceil((double) totalProducts / limit));
            System.out.println("=== END PAGINATION DEBUG ===");
            
            request.getRequestDispatcher("/staff/products.jsp").forward(request, response);
            
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Có lỗi xảy ra khi tải dữ liệu: " + e.getMessage());
            request.getRequestDispatcher("/staff/products.jsp").forward(request, response);
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        Staff staff = (Staff) session.getAttribute("staff");
        
        if (staff == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }
        
        try {
            String action = request.getParameter("action");
            
            if (action != null && action.equals("delete")) {
                String productIdStr = request.getParameter("productId");
                
                if (productIdStr != null) {
                    int productId = Integer.parseInt(productIdStr);
                    boolean success = productDAO.deleteProduct(productId);
                    
                    if (success) {
                        request.setAttribute("success", "Xóa sản phẩm thành công!");
                    } else {
                        request.setAttribute("error", "Xóa sản phẩm thất bại!");
                    }
                }
            }
            
            // Redirect về GET để refresh trang
            response.sendRedirect(request.getContextPath() + "/staff/products");
            
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Có lỗi xảy ra: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/staff/products");
        }
    }
}
