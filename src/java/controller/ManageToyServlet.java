/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller;

import jakarta.servlet.RequestDispatcher;
import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;
import java.io.File;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import model.Admin;
import model.Supplier;
import model.Product;
import model.ProductCategory;
import service.ISupplierService;
import service.IProductCategoryService;
import service.IProductService;
import service.SupplierService;
import service.ProductCategoryService;
import service.ProductService;

/**
 *
 * @author ASUS
 */
@WebServlet(name = "ManageToyServlet", urlPatterns = {"/admin/toys"})
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024,
        maxFileSize = 1024 * 1024 * 5,
        maxRequestSize = 1024 * 1024 * 10
)

public class ManageToyServlet extends HttpServlet {

    private IProductService toyService = new ProductService();

    /**
     * Processes requests for both HTTP <code>GET</code> and <code>POST</code>
     * methods.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        try (PrintWriter out = response.getWriter()) {
            /* TODO output your page here. You may use following sample code. */
            out.println("<!DOCTYPE html>");
            out.println("<html>");
            out.println("<head>");
            out.println("<title>Servlet ManageToyServlet</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet ManageToyServlet at " + request.getContextPath() + "</h1>");
            out.println("</body>");
            out.println("</html>");
        }
    }

    // <editor-fold defaultstate="collapsed" desc="HttpServlet methods. Click on the + sign on the left to edit the code.">
    /**
     * Handles the HTTP <code>GET</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        if (action == null) {
            action = "";
        }

        switch (action) {
            case "create":
                showCreateForm(request, response);
                break;
            case "edit":
                showEditForm(request, response);
                break;
            case "delete":
                deleteToy(request, response);
                break;
            default:
                listToys(request, response);
                break;
        }
    }

    /**
     * Handles the HTTP <code>POST</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        if (action == null) {
            action = "";
        }

        switch (action) {
            case "create":
                createToy(request, response);
                break;
            case "edit":
                editToy(request, response);
                break;
            default:
                listToys(request, response);
                break;
        }
    }

    /**
     * Returns a short description of the servlet.
     *
     * @return a String containing servlet description
     */
    @Override
    public String getServletInfo() {
        return "Short description";
    }// </editor-fold>

    private void listToys(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        String keyword = request.getParameter("keyword");
        String categoryParam = request.getParameter("category");
        int categoryId = -1;

        try {
            if (categoryParam != null && !categoryParam.isEmpty()) {
                categoryId = Integer.parseInt(categoryParam);
            }
        } catch (NumberFormatException ignored) {
        }

        List<Product> toys = toyService.searchProductsByNameOrIdAndCategory(keyword, categoryId);

        // Truyền categories cho dropdown lọc
        List<ProductCategory> categories = categoryService.getAllCategories();
        request.setAttribute("categories", categories);
        request.setAttribute("selectedCategory", categoryId);

        // Truyền supplierMap để hiển thị tên nhà cung cấp trong bảng
        List<Supplier> suppliers = supplierService.getAllSuppliers();
        Map<Integer, String> supplierMap = new HashMap<>();
        for (Supplier s : suppliers) {
            supplierMap.put(s.getSupplierId(), s.getNameCompany());
        }
        request.setAttribute("supplierMap", supplierMap);

        // Truyền toys về để hiển thị bảng
        request.setAttribute("toys", toys);

        RequestDispatcher dispatcher = request.getRequestDispatcher("/admin/manage-toy.jsp");
        dispatcher.forward(request, response);
    }

    private IProductCategoryService categoryService = new ProductCategoryService();
    private ISupplierService supplierService = new SupplierService();

    private void showCreateForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        List<ProductCategory> categories = categoryService.getAllCategories();
        List<Supplier> suppliers = supplierService.getAllSuppliers();

        request.setAttribute("categories", categories);
        request.setAttribute("suppliers", suppliers);
        RequestDispatcher dispatcher = request.getRequestDispatcher("/admin/create-toy.jsp");
        dispatcher.forward(request, response);
    }

    private void showEditForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int toyId = Integer.parseInt(request.getParameter("id"));
        Product toy = toyService.getProductById(toyId);

        List<ProductCategory> categories = categoryService.getAllCategories();
        List<Supplier> suppliers = supplierService.getAllSuppliers();

        request.setAttribute("toy", toy);
        request.setAttribute("categories", categories);
        request.setAttribute("suppliers", suppliers);

        RequestDispatcher dispatcher = request.getRequestDispatcher("/admin/edit-toy.jsp");
        dispatcher.forward(request, response);
    }

    private void deleteToy(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        int toyId = Integer.parseInt(request.getParameter("id"));
        toyService.deleteProduct(toyId); // TODO: bạn cần tạo hàm này trong service + dao
        response.sendRedirect("toys");
    }

    private void createToy(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        String name = request.getParameter("name");
        double price = Double.parseDouble(request.getParameter("price"));
        int categoryId = Integer.parseInt(request.getParameter("categoryId"));
        int stock = Integer.parseInt(request.getParameter("stock"));
        int supplierId = Integer.parseInt(request.getParameter("supplierId"));
        String description = request.getParameter("description");
        Admin currentAdmin = (Admin) request.getSession().getAttribute("admin");
        // Tạo toy chưa có ảnh
        Product toy = new Product();
        toy.setName(name);
        toy.setPrice(price);
        toy.setCategoryId(categoryId);
        toy.setStockQuantity(stock);
        toy.setSupplierId(supplierId);
        toy.setDescription(description);
        toy.setImageUrl(""); // (nếu cần)
        if (currentAdmin != null) {
            toy.setAdminId(currentAdmin.getAdmin_id());
        }

        int newToyId = toyService.addProduct(toy); // Trả về ID nếu thành công

        if (newToyId > 0) {
            Part filePart = request.getPart("image");
            if (filePart != null && filePart.getSize() > 0) {
                String extension = filePart.getSubmittedFileName().substring(filePart.getSubmittedFileName().lastIndexOf('.') + 1);
                String savedFileName = "toy_" + newToyId + "." + extension;
                saveImage(request, newToyId); // trong createToy

            }
            response.sendRedirect("toys");
        } else {
            response.getWriter().println("❌ Thêm sản phẩm thất bại.");
        }
    }

    private void editToy(HttpServletRequest request, HttpServletResponse response)
            throws IOException, ServletException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        Admin currentAdmin = (Admin) request.getSession().getAttribute("admin");
        int toyId = Integer.parseInt(request.getParameter("toyId"));
        String name = request.getParameter("name");
        double price = Double.parseDouble(request.getParameter("price"));
        int categoryId = Integer.parseInt(request.getParameter("categoryId"));
        int stock = Integer.parseInt(request.getParameter("stock"));
        int supplierId = Integer.parseInt(request.getParameter("supplierId"));
        String description = request.getParameter("description");

        Product toy = new Product();
        toy.setProductId(toyId);
        toy.setName(name);
        toy.setPrice(price);
        toy.setCategoryId(categoryId);
        toy.setStockQuantity(stock);
        toy.setSupplierId(supplierId);
        toy.setDescription(description);
        if (currentAdmin != null) {
            toy.setAdminId(currentAdmin.getAdmin_id());
        }

        Part filePart = request.getPart("image");
        if (filePart != null && filePart.getSize() > 0) {
            String extension = filePart.getSubmittedFileName().substring(filePart.getSubmittedFileName().lastIndexOf('.') + 1);
            String savedFileName = "toy_" + toyId + "." + extension;
            saveImage(request, toyId); // trong editToy

        }

        boolean success = toyService.updateProduct(toy);
        if (success) {
            response.sendRedirect("toys");
        } else {
            response.getWriter().println("❌ Cập nhật sản phẩm thất bại.");
        }
    }

    private void saveImage(HttpServletRequest request, int toyId) throws IOException, ServletException {
        Part filePart = request.getPart("image");
        if (filePart != null && filePart.getSize() > 0) {
            // Đường dẫn đến thư mục images thực sự nằm trong thư mục gốc của project
            String imageFolderPath = getServletContext().getRealPath("/") // trả về build/web
                    .replace("build\\web", "web") // chuyển thành thư mục gốc web/
                    + "images";

            File uploadDir = new File(imageFolderPath);
            if (!uploadDir.exists()) {
                uploadDir.mkdirs();
            }

            // Tên file ảnh theo định dạng toy_<id>.jpg
            String fileName = "toy_" + toyId + ".jpg";
            File file = new File(uploadDir, fileName);

            // Ghi ảnh vào file
            try (InputStream input = filePart.getInputStream(); FileOutputStream output = new FileOutputStream(file)) {
                byte[] buffer = new byte[1024];
                int bytesRead;
                while ((bytesRead = input.read(buffer)) != -1) {
                    output.write(buffer, 0, bytesRead);
                }
            }
        }
    }

}
