package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Admin;
import model.Supplier;
import dao.ISupplierDAO;
import dao.SupplierDAO;

import java.io.IOException;
import java.util.List;

@WebServlet("/admin/suppliers")
public class AdminSupplierServlet extends HttpServlet {
    
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
                    handleListSuppliers(request, response);
                    break;
                case "create":
                    handleCreateForm(request, response);
                    break;
                case "edit":
                    handleEditForm(request, response);
                    break;
                case "delete":
                    handleDeleteSupplier(request, response);
                    break;
                default:
                    handleListSuppliers(request, response);
                    break;
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Có lỗi xảy ra: " + e.getMessage());
            handleListSuppliers(request, response);
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
            response.sendRedirect(request.getContextPath() + "/admin/suppliers?action=list");
            return;
        }
        
        try {
            switch (action) {
                case "create":
                    handleCreateSupplier(request, response);
                    break;
                case "update":
                    handleUpdateSupplier(request, response);
                    break;
                default:
                    response.sendRedirect(request.getContextPath() + "/admin/suppliers?action=list");
                    break;
            }
        } catch (Exception e) {
            e.printStackTrace();
            HttpSession sess = request.getSession();
            sess.setAttribute("errorMessage", "Có lỗi xảy ra: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/admin/suppliers?action=list");
        }
    }
    
    private void handleListSuppliers(HttpServletRequest request, HttpServletResponse response) 
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
        
        // Lấy danh sách nhà cung cấp
        List<Supplier> suppliers = supplierDAO.getAllSuppliers();
        
        // Xử lý tìm kiếm
        String keyword = request.getParameter("keyword");
        if (keyword != null && !keyword.trim().isEmpty()) {
            suppliers = supplierDAO.searchByKeyword(keyword);
            request.setAttribute("keyword", keyword);
        }
        
        request.setAttribute("suppliers", suppliers);
        
        request.getRequestDispatcher("/admin/manage-supplier.jsp").forward(request, response);
    }
    
    private void handleCreateForm(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        request.getRequestDispatcher("/admin/create-supplier.jsp").forward(request, response);
    }
    
    private void handleEditForm(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String supplierIdStr = request.getParameter("id");
        if (supplierIdStr == null || supplierIdStr.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/suppliers?action=list");
            return;
        }
        
        try {
            int supplierId = Integer.parseInt(supplierIdStr);
            Supplier supplier = supplierDAO.getSupplierById(supplierId);
            
            if (supplier == null) {
                HttpSession session = request.getSession();
                session.setAttribute("errorMessage", "Không tìm thấy nhà cung cấp!");
                response.sendRedirect(request.getContextPath() + "/admin/suppliers?action=list");
                return;
            }
            
            request.setAttribute("supplier", supplier);
            request.getRequestDispatcher("/admin/edit-supplier.jsp").forward(request, response);
            
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/admin/suppliers?action=list");
        }
    }
    
    private void handleDeleteSupplier(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String supplierIdStr = request.getParameter("id");
        HttpSession session = request.getSession();
        
        if (supplierIdStr == null || supplierIdStr.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/suppliers?action=list");
            return;
        }
        
        try {
            int supplierId = Integer.parseInt(supplierIdStr);
            
            System.out.println("=== DELETE SUPPLIER ===");
            System.out.println("Supplier ID: " + supplierId);
            
            supplierDAO.deleteSupplier(supplierId);
            
            session.setAttribute("successMessage", "Xóa nhà cung cấp thành công!");
            
        } catch (NumberFormatException e) {
            System.err.println("Invalid supplier ID: " + supplierIdStr);
            session.setAttribute("errorMessage", "ID nhà cung cấp không hợp lệ!");
        } catch (Exception e) {
            System.err.println("Error deleting supplier: " + e.getMessage());
            e.printStackTrace();
            
            String errorMsg = e.getMessage();
            if (errorMsg != null && (errorMsg.contains("REFERENCE") || errorMsg.contains("constraint") || errorMsg.contains("foreign key"))) {
                session.setAttribute("errorMessage", "Không thể xóa nhà cung cấp vì đang có sản phẩm từ nhà cung cấp này!");
            } else {
                session.setAttribute("errorMessage", "Lỗi khi xóa nhà cung cấp: " + errorMsg);
            }
        }
        
        response.sendRedirect(request.getContextPath() + "/admin/suppliers?action=list");
    }
    
    private void handleCreateSupplier(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        
        try {
            String name = request.getParameter("name");
            String address = request.getParameter("address");
            String phone = request.getParameter("phone");
            
            System.out.println("=== CREATE SUPPLIER ===");
            System.out.println("Name: " + name);
            System.out.println("Address: " + address);
            System.out.println("Phone: " + phone);
            
            if (name == null || name.trim().isEmpty()) {
                session.setAttribute("errorMessage", "Tên nhà cung cấp không được để trống!");
                response.sendRedirect(request.getContextPath() + "/admin/suppliers?action=create");
                return;
            }
            
            Supplier supplier = new Supplier();
            supplier.setNameCompany(name.trim());
            supplier.setAddress(address != null ? address.trim() : "");
            supplier.setPhone(phone != null ? phone.trim() : "");
            
            supplierDAO.insertSupplier(supplier);
            
            session.setAttribute("successMessage", "Thêm nhà cung cấp thành công!");
            
        } catch (Exception e) {
            System.err.println("Error creating supplier: " + e.getMessage());
            e.printStackTrace();
            session.setAttribute("errorMessage", "Có lỗi xảy ra khi thêm nhà cung cấp: " + e.getMessage());
        }
        
        response.sendRedirect(request.getContextPath() + "/admin/suppliers?action=list");
    }
    
    private void handleUpdateSupplier(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        
        try {
            int supplierId = Integer.parseInt(request.getParameter("supplierId"));
            String name = request.getParameter("name");
            String address = request.getParameter("address");
            String phone = request.getParameter("phone");
            
            System.out.println("=== UPDATE SUPPLIER ===");
            System.out.println("ID: " + supplierId + ", Name: " + name);
            
            if (name == null || name.trim().isEmpty()) {
                session.setAttribute("errorMessage", "Tên nhà cung cấp không được để trống!");
                response.sendRedirect(request.getContextPath() + "/admin/suppliers?action=edit&id=" + supplierId);
                return;
            }
            
            Supplier supplier = new Supplier();
            supplier.setSupplierId(supplierId);
            supplier.setNameCompany(name.trim());
            supplier.setAddress(address != null ? address.trim() : "");
            supplier.setPhone(phone != null ? phone.trim() : "");
            
            supplierDAO.updateSupplier(supplier);
            
            session.setAttribute("successMessage", "Cập nhật nhà cung cấp thành công!");
            
        } catch (NumberFormatException e) {
            System.err.println("Number format error: " + e.getMessage());
            e.printStackTrace();
            session.setAttribute("errorMessage", "Dữ liệu không hợp lệ!");
        } catch (Exception e) {
            System.err.println("Error updating supplier: " + e.getMessage());
            e.printStackTrace();
            session.setAttribute("errorMessage", "Có lỗi xảy ra khi cập nhật nhà cung cấp: " + e.getMessage());
        }
        
        response.sendRedirect(request.getContextPath() + "/admin/suppliers?action=list");
    }
}


