/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package service;

import dao.ISupplierDAO;
import dao.SupplierDAO;
import java.util.List;
import model.Supplier;

/**
 *
 * @author ASUS
 */
public class SupplierService implements ISupplierService {

    private ISupplierDAO supplierDAO = new SupplierDAO();

    @Override
    public Supplier getSupplierById(int id) {
        return supplierDAO.getSupplierById(id);
    }

    @Override
    public List<Supplier> getAllSuppliers() {
        return supplierDAO.getAllSuppliers();
    }

    @Override
    public List<Supplier> searchByKeyword(String keyword) {
        return supplierDAO.searchByKeyword(keyword);
    }

    @Override
    public void insertSupplier(Supplier supplier) {
        supplierDAO.insertSupplier(supplier);
    }

    @Override
    public void updateSupplier(Supplier supplier) {
        supplierDAO.updateSupplier(supplier);
    }

    @Override
    public void deleteSupplier(int id) {
        supplierDAO.deleteSupplier(id);
    }
}
