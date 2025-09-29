/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Interface.java to edit this template
 */
package dao;

import java.util.List;
import model.Supplier;

/**
 *
 * @author ASUS
 */
public interface ISupplierDAO {
    Supplier getSupplierById(int id);
    List<Supplier> getAllSuppliers();
    List<Supplier> searchByKeyword(String keyword);
    void insertSupplier(Supplier supplier);
    void updateSupplier(Supplier supplier);
    void deleteSupplier(int id);
}
