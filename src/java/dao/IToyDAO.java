package dao;

import model.Toy;
import java.util.List;
import java.util.Map;
import model.Review;
import model.Toy;

public interface IToyDAO {

    List<Toy> getAllToys();

    List<Toy> getToysByPage(int offset, int limit);

    int countAllToys();

    Toy getToyById(int id);

    boolean checkStockAvailability(int toyId, int quantity);

    List<Review> getToyReviews(int toyId);

    List<String> searchToyNames(String query);

    List<Toy> searchToys(String keyword);

    List<Toy> searchToysByKeyword(String keyword); // ✔️ thêm

    List<Toy> searchToysByKeywordAndCategory(String keyword, int categoryId); // ✔️ thêm

    List<Toy> getToysByCategorySlug(String slug);

    List<Toy> getToysByCategoryId(int categoryId);

    List<Toy> getToysByCategory(int categoryId); // ✔️ thêm (nếu dùng riêng)

    boolean softDelete(int toyId);

    int addToy(Toy toy);

    int getLastInsertedId();

    boolean deleteToy(int toyId);

    boolean updateToy(Toy toy);

    List<Toy> searchToysByNameOrIdAndCategory(String keyword, int categoryId);

    double getAverageRating(int toyId);

    List<Toy> getSimilarToys(int categoryId, int excludeToyId, int limit);

    String getToyNameById(int toyId); // ✔️ thêm

    List<Review> getReviewsByToyId(int toyId);

    Map<Integer, String> getAllCategoriesMap();
}
