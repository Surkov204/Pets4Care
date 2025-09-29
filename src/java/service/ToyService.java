package service;

import dao.IToyDAO;
import dao.ToyDAO;
import model.Toy;

import java.util.List;
import model.Review;

public class ToyService implements IToyService {

    private IToyDAO toyDAO = new ToyDAO();

    @Override
    public List<Toy> getAllToys() {
        return toyDAO.getAllToys();
    }

    @Override
    public List<Toy> getToysByPage(int offset, int limit) {
        return toyDAO.getToysByPage(offset, limit);
    }

    @Override
    public int countAllToys() {
        return toyDAO.countAllToys();
    }

    @Override
    public Toy getToyById(int id) {
        return toyDAO.getToyById(id);
    }

    @Override
    public boolean checkStockAvailability(int toyId, int quantity) {
        return toyDAO.checkStockAvailability(toyId, quantity);
    }

    @Override
    public List<Review> getToyReviews(int toyId) {
        return toyDAO.getToyReviews(toyId);
    }

    @Override
    public List<String> searchToyNames(String query) {
        return toyDAO.searchToyNames(query);
    }

    @Override
    public List<Toy> searchToys(String keyword) {
        return toyDAO.searchToys(keyword);
    }

    @Override
    public List<Toy> searchToysByKeyword(String keyword) {
        return toyDAO.searchToysByKeyword(keyword);
    }

    @Override
    public List<Toy> searchToysByKeywordAndCategory(String keyword, int categoryId) {
        return toyDAO.searchToysByKeywordAndCategory(keyword, categoryId);
    }

    @Override
    public List<Toy> getToysByCategorySlug(String slug) {
        return toyDAO.getToysByCategorySlug(slug);
    }

    @Override
    public List<Toy> getToysByCategoryId(int categoryId) {
        return toyDAO.getToysByCategoryId(categoryId);
    }

    @Override
    public List<Toy> getToysByCategory(int categoryId) {
        return toyDAO.getToysByCategory(categoryId);
    }

    @Override
    public boolean softDelete(int toyId) {
        return toyDAO.softDelete(toyId);
    }

    @Override
    public int addToy(Toy toy) {
        return toyDAO.addToy(toy);
    }

    @Override
    public int getLastInsertedId() {
        return toyDAO.getLastInsertedId();
    }

    @Override
    public boolean deleteToy(int toyId) {
        return toyDAO.deleteToy(toyId);
    }

    @Override
    public boolean updateToy(Toy toy) {
        return toyDAO.updateToy(toy);
    }

    @Override
    public List<Toy> searchToysByNameOrIdAndCategory(String keyword, int categoryId) {
        return toyDAO.searchToysByNameOrIdAndCategory(keyword, categoryId);
    }

    @Override
    public double getAverageRating(int toyId) {
        return toyDAO.getAverageRating(toyId);
    }

    @Override
    public List<Toy> getSimilarToys(int categoryId, int excludeToyId, int limit) {
        return toyDAO.getSimilarToys(categoryId, excludeToyId, limit);
    }

    @Override
    public String getToyNameById(int toyId) {
        return toyDAO.getToyNameById(toyId);
    }

    @Override
    public List<Review> getReviewsByToyId(int toyId) {
        return toyDAO.getReviewsByToyId(toyId);
    }

}
