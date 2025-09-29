/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package service;

import dao.IToyCategoryDAO;
import dao.ToyCategoryDAO;
import java.util.List;
import model.ToyCategory;

/**
 *
 * @author ASUS
 */
public class ToyCategoryService implements IToyCategoryService {
    private IToyCategoryDAO categoryDAO = new ToyCategoryDAO();

    @Override
    public ToyCategory getCategoryById(int id) {
        return categoryDAO.getCategoryById(id);
    }

    @Override
    public List<ToyCategory> getAllCategories() {
        return categoryDAO.getAllCategories();
    }
    
    
}
