package service;

import model.Toy;
import java.util.List;
import model.Review;

public interface IToyService {

    List<Toy> getAllToys();

    List<Toy> getToysByPage(int offset, int limit);

    int countAllToys();

    Toy getToyById(int id);

    boolean checkStockAvailability(int toyId, int quantity);

    List<Review> getToyReviews(int toyId);

    List<String> searchToyNames(String query);

    List<Toy> searchToys(String keyword);

    List<Toy> searchToysByKeyword(String keyword);

    List<Toy> searchToysByKeywordAndCategory(String keyword, int categoryId);

    List<Toy> getToysByCategorySlug(String slug);

    List<Toy> getToysByCategoryId(int categoryId);

    List<Toy> getToysByCategory(int categoryId);

    boolean softDelete(int toyId);

    int addToy(Toy toy);

    int getLastInsertedId();

    boolean deleteToy(int toyId);

    boolean updateToy(Toy toy);

    List<Toy> searchToysByNameOrIdAndCategory(String keyword, int categoryId);

    double getAverageRating(int toyId);

    List<Toy> getSimilarToys(int categoryId, int excludeToyId, int limit);

    String getToyNameById(int toyId);

    List<Review> getReviewsByToyId(int toyId);

}
