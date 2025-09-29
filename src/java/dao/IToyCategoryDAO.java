/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Interface.java to edit this template
 */
package dao;

import java.util.List;
import model.ToyCategory;

/**
 *
 * @author ASUS
 */
public interface IToyCategoryDAO {
     ToyCategory getCategoryById(int id);
     
     List<ToyCategory> getAllCategories();

}
