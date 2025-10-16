/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Interface.java to edit this template
 */
package service;

import java.util.List;
import model.ProductCategory;

/**
 *
 * @author ASUS
 */
public interface IProductCategoryService {
    ProductCategory getCategoryById(int id);
    
    List<ProductCategory> getAllCategories();

}

