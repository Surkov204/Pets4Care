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

}

