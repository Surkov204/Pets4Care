package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import service.IProductService;
import service.ProductService;
import model.Product;

import java.io.IOException;
import java.util.List;

@WebServlet("/staff-home")
public class StaffHomeServlet extends HttpServlet {
    
    private IProductService productService;
    private static final int PAGE_SIZE = 12;

    @Override
    public void init() throws ServletException {
        productService = new ProductService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
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

        int offset = (page - 1) * PAGE_SIZE;
        int totalProducts = productService.countAllProducts();
        int totalPages = (int) Math.ceil((double) totalProducts / PAGE_SIZE);

        List<Product> products = productService.getProductsByPage(offset, PAGE_SIZE);

        request.setAttribute("products", products);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);

        request.getRequestDispatcher("staff/dashboard.jsp").forward(request, response);
    }
}

