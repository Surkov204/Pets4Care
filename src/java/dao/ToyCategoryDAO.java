/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;

import model.ToyCategory;
import utils.DBConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 *
 * @author ASUS
 */
public class ToyCategoryDAO implements IToyCategoryDAO {

    @Override
    public ToyCategory getCategoryById(int id) {
        String sql = "SELECT * FROM ToyCategory WHERE category_id = ?";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return new ToyCategory(rs.getInt("category_id"), rs.getString("name"));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    @Override
    public List<ToyCategory> getAllCategories() {
        List<ToyCategory> list = new ArrayList<>();
        String sql = "SELECT * FROM ToyCategory";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                ToyCategory cat = new ToyCategory();
                cat.setCategoryId(rs.getInt("category_id"));
                cat.setName(rs.getString("name"));
                list.add(cat);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

}
