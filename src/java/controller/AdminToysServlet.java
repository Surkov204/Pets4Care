package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Admin;
import model.Product;
import model.ProductCategory;
import model.Supplier;
import dao.IProductDAO;
import dao.ProductDAO;
import dao.IProductCategoryDAO;
import dao.ProductCategoryDAO;
import dao.ISupplierDAO;
import dao.SupplierDAO;

import java.io.IOException;
import java.util.List;
import java.util.Map;

@WebServlet("/admin/toys")
public class AdminToysServlet extends HttpServlet {
    
    private IProductDAO productDAO = new ProductDAO();
    private IProductCategoryDAO categoryDAO = new ProductCategoryDAO();
    private ISupplierDAO supplierDAO = new SupplierDAO();
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Kiểm tra đăng nhập admin
        HttpSession session = request.getSession();
        Admin admin = (Admin) session.getAttribute("admin");
        if (admin == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }
        
        String action = request.getParameter("action");
        if (action == null) {
            action = "list";
        }
        
        try {
            switch (action) {
                case "list":
                    handleListProducts(request, response);
                    break;
                case "create":
                    handleCreateForm(request, response);
                    break;
                case "edit":
                    handleEditForm(request, response);
                    break;
                case "delete":
                    handleDeleteProduct(request, response);
                    break;
                default:
                    handleListProducts(request, response);
                    break;
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Có lỗi xảy ra: " + e.getMessage());
            handleListProducts(request, response);
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Kiểm tra đăng nhập admin
        HttpSession session = request.getSession();
        Admin admin = (Admin) session.getAttribute("admin");
        if (admin == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }
        
        String action = request.getParameter("action");
        if (action == null) {
            response.sendRedirect(request.getContextPath() + "/admin/toys");
            return;
        }
        
        try {
            switch (action) {
                case "create":
                    handleCreateProduct(request, response);
                    break;
                case "update":
                    handleUpdateProduct(request, response);
                    break;
                default:
                    response.sendRedirect(request.getContextPath() + "/admin/toys");
                    break;
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Có lỗi xảy ra: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/admin/toys");
        }
    }
    
    private void handleListProducts(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        
        // Lấy message từ session và xóa ngay sau đó (flash message)
        String successMessage = (String) session.getAttribute("successMessage");
        String errorMessage = (String) session.getAttribute("errorMessage");
        if (successMessage != null) {
            request.setAttribute("success", successMessage);
            session.removeAttribute("successMessage");
        }
        if (errorMessage != null) {
            request.setAttribute("error", errorMessage);
            session.removeAttribute("errorMessage");
        }
        
        // Lấy danh sách sản phẩm
        List<Product> products = productDAO.getAllProducts();
        
        // Lấy danh sách categories và suppliers
        List<ProductCategory> categories = categoryDAO.getAllCategories();
        List<Supplier> suppliers = supplierDAO.getAllSuppliers();
        
        // Tạo map để hiển thị tên supplier
        Map<Integer, String> supplierMap = new java.util.HashMap<>();
        for (Supplier supplier : suppliers) {
            supplierMap.put(supplier.getSupplierId(), supplier.getNameCompany());
        }
        
        // Xử lý tìm kiếm và lọc
        String keyword = request.getParameter("keyword");
        String categoryIdStr = request.getParameter("category");
        
        if (keyword != null && !keyword.trim().isEmpty()) {
            products = productDAO.searchProducts(keyword);
        } else if (categoryIdStr != null && !categoryIdStr.isEmpty()) {
            try {
                int categoryId = Integer.parseInt(categoryIdStr);
                products = productDAO.getProductsByCategory(categoryId);
            } catch (NumberFormatException e) {
                // Nếu categoryId không hợp lệ, giữ nguyên danh sách
            }
        }
        
        request.setAttribute("products", products);
        request.setAttribute("categories", categories);
        request.setAttribute("suppliers", suppliers);
        request.setAttribute("supplierMap", supplierMap);
        request.setAttribute("keyword", keyword);
        request.setAttribute("selectedCategory", categoryIdStr);
        
        request.getRequestDispatcher("/admin/manage-toy.jsp").forward(request, response);
    }
    
    private void handleCreateForm(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        List<ProductCategory> categories = categoryDAO.getAllCategories();
        List<Supplier> suppliers = supplierDAO.getAllSuppliers();
        
        request.setAttribute("categories", categories);
        request.setAttribute("suppliers", suppliers);
        
        request.getRequestDispatcher("/admin/create-toy.jsp").forward(request, response);
    }
    
    private void handleEditForm(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String productIdStr = request.getParameter("id");
        if (productIdStr == null || productIdStr.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/toys");
            return;
        }
        
        try {
            int productId = Integer.parseInt(productIdStr);
            Product product = productDAO.getProductById(productId);
            
            if (product == null) {
                response.sendRedirect(request.getContextPath() + "/admin/toys");
                return;
            }
            
            List<ProductCategory> categories = categoryDAO.getAllCategories();
            List<Supplier> suppliers = supplierDAO.getAllSuppliers();
            
            request.setAttribute("product", product);
            request.setAttribute("categories", categories);
            request.setAttribute("suppliers", suppliers);
            
            request.getRequestDispatcher("/admin/edit-toy.jsp").forward(request, response);
            
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/admin/toys");
        }
    }
    
    private void handleDeleteProduct(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String productIdStr = request.getParameter("id");
        HttpSession session = request.getSession();
        
        if (productIdStr == null || productIdStr.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/toys?action=list");
            return;
        }
        
        try {
            int productId = Integer.parseInt(productIdStr);
            
            // Log để debug
            System.out.println("=== DELETE PRODUCT ===");
            System.out.println("Product ID: " + productId);
            
            // Thử xóa sản phẩm
            boolean success = productDAO.deleteProduct(productId);
            
            System.out.println("Delete result: " + success);
            
            if (success) {
                session.setAttribute("successMessage", "Xóa sản phẩm thành công!");
            } else {
                session.setAttribute("errorMessage", "Không thể xóa sản phẩm! Sản phẩm có thể đang được sử dụng trong đơn hàng.");
            }
            
        } catch (NumberFormatException e) {
            System.err.println("Invalid product ID: " + productIdStr);
            session.setAttribute("errorMessage", "ID sản phẩm không hợp lệ!");
        } catch (Exception e) {
            System.err.println("Error deleting product: " + e.getMessage());
            e.printStackTrace();
            
            // Kiểm tra nếu là lỗi foreign key constraint
            String errorMsg = e.getMessage();
            if (errorMsg != null && (errorMsg.contains("REFERENCE") || errorMsg.contains("constraint") || errorMsg.contains("foreign key"))) {
                session.setAttribute("errorMessage", "Không thể xóa sản phẩm vì đang có đơn hàng hoặc dữ liệu liên quan!");
            } else {
                session.setAttribute("errorMessage", "Lỗi khi xóa sản phẩm: " + errorMsg);
            }
        }
        
        response.sendRedirect(request.getContextPath() + "/admin/toys?action=list");
    }
    
    private void handleCreateProduct(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        
        try {
            // Log dữ liệu nhận được
            System.out.println("=== CREATE PRODUCT ===");
            System.out.println("Name: " + request.getParameter("name"));
            System.out.println("Price: " + request.getParameter("price"));
            System.out.println("CategoryId: " + request.getParameter("categoryId"));
            System.out.println("StockQuantity: " + request.getParameter("stockQuantity"));
            System.out.println("SupplierId: " + request.getParameter("supplierId"));
            System.out.println("Description: " + request.getParameter("description"));
            System.out.println("ImageUrl: " + request.getParameter("imageUrl"));
            
            Product product = new Product();
            product.setName(request.getParameter("name"));
            product.setPrice(Double.parseDouble(request.getParameter("price")));
            product.setCategoryId(Integer.parseInt(request.getParameter("categoryId")));
            product.setStockQuantity(Integer.parseInt(request.getParameter("stockQuantity")));
            product.setSupplierId(Integer.parseInt(request.getParameter("supplierId")));
            product.setDescription(request.getParameter("description"));
            // Bảng Products không có trường image_url
            
            // Lấy adminId từ session
            Admin admin = (Admin) session.getAttribute("admin");
            System.out.println("Admin ID: " + admin.getAdmin_id());
            product.setAdminId(admin.getAdmin_id());
            
            int productId = productDAO.addProduct(product);
            System.out.println("Product ID returned: " + productId);
            
            if (productId > 0) {
                session.setAttribute("successMessage", "Thêm sản phẩm thành công! (ID: " + productId + ")");
            } else {
                session.setAttribute("errorMessage", "Không thể thêm sản phẩm! Vui lòng kiểm tra dữ liệu.");
            }
            
        } catch (NumberFormatException e) {
            System.err.println("Number format error: " + e.getMessage());
            e.printStackTrace();
            session.setAttribute("errorMessage", "Dữ liệu không hợp lệ! Vui lòng kiểm tra giá, số lượng, danh mục và nhà cung cấp.");
        } catch (NullPointerException e) {
            System.err.println("Null pointer error: " + e.getMessage());
            e.printStackTrace();
            session.setAttribute("errorMessage", "Thiếu thông tin bắt buộc! Vui lòng điền đầy đủ các trường.");
        } catch (Exception e) {
            System.err.println("Error creating product: " + e.getMessage());
            e.printStackTrace();
            session.setAttribute("errorMessage", "Có lỗi xảy ra khi thêm sản phẩm: " + e.getMessage());
        }
        
        response.sendRedirect(request.getContextPath() + "/admin/toys?action=list");
    }
    
    private void handleUpdateProduct(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        
        try {
            Product product = new Product();
            product.setProductId(Integer.parseInt(request.getParameter("productId")));
            product.setName(request.getParameter("name"));
            product.setPrice(Double.parseDouble(request.getParameter("price")));
            product.setCategoryId(Integer.parseInt(request.getParameter("categoryId")));
            product.setStockQuantity(Integer.parseInt(request.getParameter("stockQuantity")));
            product.setSupplierId(Integer.parseInt(request.getParameter("supplierId")));
            product.setDescription(request.getParameter("description"));
            // Bảng Products không có trường image_url
            
            // Lấy adminId từ session
            Admin admin = (Admin) session.getAttribute("admin");
            product.setAdminId(admin.getAdmin_id());
            
            boolean success = productDAO.updateProduct(product);
            
            if (success) {
                session.setAttribute("successMessage", "Cập nhật sản phẩm thành công!");
            } else {
                session.setAttribute("errorMessage", "Không thể cập nhật sản phẩm!");
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("errorMessage", "Có lỗi xảy ra khi cập nhật sản phẩm: " + e.getMessage());
        }
        
        response.sendRedirect(request.getContextPath() + "/admin/toys?action=list");
    }
}
