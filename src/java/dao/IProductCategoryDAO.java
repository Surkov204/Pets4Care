/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Interface.java to edit this template
 */
package dao;

import java.util.List;
import java.util.Map;
import model.ProductCategory;

/**
 *
 * @author ASUS
 */
public interface IProductCategoryDAO {
     ProductCategory getCategoryById(int id);
     
     List<ProductCategory> getAllCategories();
     
     Map<Integer, String> getAllCategoriesMap();

}

