package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Admin;
import model.ProductCategory;
import dao.IProductCategoryDAO;
import dao.ProductCategoryDAO;

import java.io.IOException;
import java.util.List;

@WebServlet("/admin/categories")
public class AdminCategoryServlet extends HttpServlet {
    
    private IProductCategoryDAO categoryDAO = new ProductCategoryDAO();
    
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
                    handleListCategories(request, response);
                    break;
                case "create":
                    handleCreateForm(request, response);
                    break;
                case "edit":
                    handleEditForm(request, response);
                    break;
                case "delete":
                    handleDeleteCategory(request, response);
                    break;
                default:
                    handleListCategories(request, response);
                    break;
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Có lỗi xảy ra: " + e.getMessage());
            handleListCategories(request, response);
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
            response.sendRedirect(request.getContextPath() + "/admin/categories?action=list");
            return;
        }
        
        try {
            switch (action) {
                case "create":
                    handleCreateCategory(request, response);
                    break;
                case "update":
                    handleUpdateCategory(request, response);
                    break;
                default:
                    response.sendRedirect(request.getContextPath() + "/admin/categories?action=list");
                    break;
            }
        } catch (Exception e) {
            e.printStackTrace();
            HttpSession sess = request.getSession();
            sess.setAttribute("errorMessage", "Có lỗi xảy ra: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/admin/categories?action=list");
        }
    }
    
    private void handleListCategories(HttpServletRequest request, HttpServletResponse response) 
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
        
        // Lấy danh sách danh mục
        List<ProductCategory> categories = categoryDAO.getAllCategories();
        
        request.setAttribute("categories", categories);
        
        request.getRequestDispatcher("/admin/manage-category.jsp").forward(request, response);
    }
    
    private void handleCreateForm(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        request.getRequestDispatcher("/admin/create-category.jsp").forward(request, response);
    }
    
    private void handleEditForm(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String categoryIdStr = request.getParameter("id");
        if (categoryIdStr == null || categoryIdStr.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/categories?action=list");
            return;
        }
        
        try {
            int categoryId = Integer.parseInt(categoryIdStr);
            ProductCategory category = categoryDAO.getCategoryById(categoryId);
            
            if (category == null) {
                HttpSession session = request.getSession();
                session.setAttribute("errorMessage", "Không tìm thấy danh mục!");
                response.sendRedirect(request.getContextPath() + "/admin/categories?action=list");
                return;
            }
            
            request.setAttribute("category", category);
            request.getRequestDispatcher("/admin/edit-category.jsp").forward(request, response);
            
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/admin/categories?action=list");
        }
    }
    
    private void handleDeleteCategory(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String categoryIdStr = request.getParameter("id");
        HttpSession session = request.getSession();
        
        if (categoryIdStr == null || categoryIdStr.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/categories?action=list");
            return;
        }
        
        try {
            int categoryId = Integer.parseInt(categoryIdStr);
            
            System.out.println("=== DELETE CATEGORY ===");
            System.out.println("Category ID: " + categoryId);
            
            boolean success = categoryDAO.deleteCategory(categoryId);
            
            System.out.println("Delete result: " + success);
            
            if (success) {
                session.setAttribute("successMessage", "Xóa danh mục thành công!");
            } else {
                session.setAttribute("errorMessage", "Không thể xóa danh mục! Danh mục có thể đang được sử dụng.");
            }
            
        } catch (NumberFormatException e) {
            System.err.println("Invalid category ID: " + categoryIdStr);
            session.setAttribute("errorMessage", "ID danh mục không hợp lệ!");
        } catch (Exception e) {
            System.err.println("Error deleting category: " + e.getMessage());
            e.printStackTrace();
            
            String errorMsg = e.getMessage();
            if (errorMsg != null && (errorMsg.contains("REFERENCE") || errorMsg.contains("constraint") || errorMsg.contains("foreign key"))) {
                session.setAttribute("errorMessage", "Không thể xóa danh mục vì đang có sản phẩm thuộc danh mục này!");
            } else {
                session.setAttribute("errorMessage", "Lỗi khi xóa danh mục: " + errorMsg);
            }
        }
        
        response.sendRedirect(request.getContextPath() + "/admin/categories?action=list");
    }
    
    private void handleCreateCategory(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        
        try {
            String categoryName = request.getParameter("name");
            
            System.out.println("=== CREATE CATEGORY ===");
            System.out.println("Name: " + categoryName);
            
            if (categoryName == null || categoryName.trim().isEmpty()) {
                session.setAttribute("errorMessage", "Tên danh mục không được để trống!");
                response.sendRedirect(request.getContextPath() + "/admin/categories?action=create");
                return;
            }
            
            ProductCategory category = new ProductCategory();
            category.setName(categoryName.trim());
            
            int categoryId = categoryDAO.addCategory(category);
            System.out.println("Category ID returned: " + categoryId);
            
            if (categoryId > 0) {
                session.setAttribute("successMessage", "Thêm danh mục thành công! (ID: " + categoryId + ")");
            } else {
                session.setAttribute("errorMessage", "Không thể thêm danh mục! Vui lòng thử lại.");
            }
            
        } catch (Exception e) {
            System.err.println("Error creating category: " + e.getMessage());
            e.printStackTrace();
            session.setAttribute("errorMessage", "Có lỗi xảy ra khi thêm danh mục: " + e.getMessage());
        }
        
        response.sendRedirect(request.getContextPath() + "/admin/categories?action=list");
    }
    
    private void handleUpdateCategory(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        
        try {
            int categoryId = Integer.parseInt(request.getParameter("categoryId"));
            String categoryName = request.getParameter("name");
            
            System.out.println("=== UPDATE CATEGORY ===");
            System.out.println("ID: " + categoryId + ", Name: " + categoryName);
            
            if (categoryName == null || categoryName.trim().isEmpty()) {
                session.setAttribute("errorMessage", "Tên danh mục không được để trống!");
                response.sendRedirect(request.getContextPath() + "/admin/categories?action=edit&id=" + categoryId);
                return;
            }
            
            ProductCategory category = new ProductCategory();
            category.setCategoryId(categoryId);
            category.setName(categoryName.trim());
            
            boolean success = categoryDAO.updateCategory(category);
            
            if (success) {
                session.setAttribute("successMessage", "Cập nhật danh mục thành công!");
            } else {
                session.setAttribute("errorMessage", "Không thể cập nhật danh mục!");
            }
            
        } catch (NumberFormatException e) {
            System.err.println("Number format error: " + e.getMessage());
            e.printStackTrace();
            session.setAttribute("errorMessage", "Dữ liệu không hợp lệ!");
        } catch (Exception e) {
            System.err.println("Error updating category: " + e.getMessage());
            e.printStackTrace();
            session.setAttribute("errorMessage", "Có lỗi xảy ra khi cập nhật danh mục: " + e.getMessage());
        }
        
        response.sendRedirect(request.getContextPath() + "/admin/categories?action=list");
    }
}


