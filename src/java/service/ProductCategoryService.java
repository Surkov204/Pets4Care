/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package service;

import dao.IProductCategoryDAO;
import dao.ProductCategoryDAO;
import java.util.List;
import model.ProductCategory;

/**
 *
 * @author ASUS
 */
public class ProductCategoryService implements IProductCategoryService {
    private IProductCategoryDAO categoryDAO = new ProductCategoryDAO();

    @Override
    public ProductCategory getCategoryById(int id) {
        return categoryDAO.getCategoryById(id);
    }

    @Override
    public List<ProductCategory> getAllCategories() {
        return categoryDAO.getAllCategories();
    }
    
    
}

