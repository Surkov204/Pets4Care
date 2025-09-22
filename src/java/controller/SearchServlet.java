package controller;

import dao.ToyDAO;
import model.Toy;

import java.io.IOException;
import java.util.*;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(name = "SearchServlet", urlPatterns = {"/search"})
public class SearchServlet extends HttpServlet {

    private ToyDAO toyDAO;

    @Override
    public void init() throws ServletException {
        toyDAO = new ToyDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String keyword = request.getParameter("keyword");
        String categoryIdParam = request.getParameter("categoryId");

        List<Toy> searchResults = new ArrayList<>();
        int categoryId = -1;
        String categoryName = null;

        Map<Integer, String> categoryMap = toyDAO.getAllCategoriesMap();

        // Ánh xạ từ khóa → categoryId
        Map<String, Integer> keywordToCategory = new HashMap<>();
        keywordToCategory.put("chó", 1);
        keywordToCategory.put("cún", 1);
        keywordToCategory.put("mèo", 2);
        keywordToCategory.put("vật nuôi", 3);
        keywordToCategory.put("hamster", 3);
        keywordToCategory.put("vịt", 2);
        keywordToCategory.put("thú cưng", 3);
        keywordToCategory.put("gà", 1);
        keywordToCategory.put("chuột", 2);
        keywordToCategory.put("phụ kiện mèo", 8);
        keywordToCategory.put("dinh dưỡng mèo", 5);
        keywordToCategory.put("chăm sóc da mèo", 10);

        if (categoryIdParam != null && !categoryIdParam.isEmpty()) {
            try {
                categoryId = Integer.parseInt(categoryIdParam);
                searchResults = toyDAO.getToysByCategory(categoryId);
                categoryName = categoryMap.getOrDefault(categoryId, "Danh mục không xác định");
            } catch (NumberFormatException e) {
                e.printStackTrace();
            }
        } else if (keyword != null && !keyword.trim().isEmpty()) {
            String inputKeyword = keyword.trim().toLowerCase();

            for (Map.Entry<String, Integer> entry : keywordToCategory.entrySet()) {
                if (inputKeyword.contains(entry.getKey())) {
                    categoryId = entry.getValue();
                    break;
                }
            }

            if (categoryId == -1) {
                searchResults = toyDAO.searchToysByKeyword(inputKeyword);
                categoryName = "Tất cả sản phẩm";
            } else {
                searchResults = toyDAO.searchToysByKeywordAndCategory(inputKeyword, categoryId);
                categoryName = categoryMap.getOrDefault(categoryId, "Danh mục không xác định");
            }

            request.setAttribute("keyword", keyword);
        }
        System.out.println("Kết quả tìm kiếm trả về: " + searchResults.size());


        request.setAttribute("searchResults", searchResults);
        request.setAttribute("selectedCategory", categoryId);
        request.setAttribute("categoryName", categoryName);
        request.setAttribute("categories", categoryMap);

        request.getRequestDispatcher("searchResult.jsp").forward(request, response);
    }
}
