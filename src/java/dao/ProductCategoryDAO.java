/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;

import model.ProductCategory;
import utils.DBConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 *
 * @author ASUS
 */
public class ProductCategoryDAO implements IProductCategoryDAO {

    @Override
    public ProductCategory getCategoryById(int id) {
        String sql = "SELECT * FROM ProductCategory WHERE category_id = ?";
        try (Connection conn = DBConnection.getConnection(); 
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return new ProductCategory(rs.getInt("category_id"), rs.getString("name"));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    @Override
    public List<ProductCategory> getAllCategories() {
        List<ProductCategory> list = new ArrayList<>();
        String sql = "SELECT * FROM ProductCategory";

        try (Connection conn = DBConnection.getConnection(); 
             PreparedStatement ps = conn.prepareStatement(sql); 
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                ProductCategory cat = new ProductCategory();
                cat.setCategoryId(rs.getInt("category_id"));
                cat.setName(rs.getString("name"));
                list.add(cat);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    @Override
    public Map<Integer, String> getAllCategoriesMap() {
        Map<Integer, String> categories = new HashMap<>();
        String sql = "SELECT category_id, name FROM ProductCategory";

        try (Connection conn = DBConnection.getConnection(); 
             PreparedStatement ps = conn.prepareStatement(sql); 
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                categories.put(rs.getInt("category_id"), rs.getString("name"));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return categories;
    }

    @Override
    public int addCategory(ProductCategory category) {
        String sql = "INSERT INTO ProductCategory (name) VALUES (?)";
        
        System.out.println("=== ProductCategoryDAO.addCategory ===");
        System.out.println("Category name: " + category.getName());
        
        try (Connection conn = DBConnection.getConnection(); 
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            System.out.println("Connection: " + (conn != null ? "OK" : "FAILED"));
            
            ps.setString(1, category.getName());
            
            System.out.println("Executing insert...");
            int result = ps.executeUpdate();
            System.out.println("Rows affected: " + result);
            
            if (result > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        int generatedId = rs.getInt(1);
                        System.out.println("Generated category ID: " + generatedId);
                        return generatedId;
                    }
                }
            }
            
            System.err.println("No rows inserted!");
            
        } catch (Exception e) {
            System.err.println("ERROR in addCategory: " + e.getMessage());
            e.printStackTrace();
        }
        
        return -1;
    }

    @Override
    public boolean updateCategory(ProductCategory category) {
        String sql = "UPDATE ProductCategory SET name = ? WHERE category_id = ?";
        
        System.out.println("=== ProductCategoryDAO.updateCategory ===");
        System.out.println("Category ID: " + category.getCategoryId() + ", Name: " + category.getName());
        
        try (Connection conn = DBConnection.getConnection(); 
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, category.getName());
            ps.setInt(2, category.getCategoryId());
            
            int result = ps.executeUpdate();
            System.out.println("Rows updated: " + result);
            
            return result > 0;
            
        } catch (Exception e) {
            System.err.println("ERROR in updateCategory: " + e.getMessage());
            e.printStackTrace();
        }
        
        return false;
    }

    @Override
    public boolean deleteCategory(int categoryId) {
        String sql = "DELETE FROM ProductCategory WHERE category_id = ?";
        
        System.out.println("=== ProductCategoryDAO.deleteCategory ===");
        System.out.println("Category ID: " + categoryId);
        
        try (Connection conn = DBConnection.getConnection(); 
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, categoryId);
            
            int result = ps.executeUpdate();
            System.out.println("Rows deleted: " + result);
            
            return result > 0;
            
        } catch (Exception e) {
            System.err.println("ERROR in deleteCategory: " + e.getMessage());
            e.printStackTrace();
        }
        
        return false;
    }

}

