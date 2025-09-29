/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;

import dao.ISupplierDAO;
import model.Supplier;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import utils.DBConnection;

/**
 *
 * @author ASUS
 */
public class SupplierDAO implements ISupplierDAO {

    @Override
    public Supplier getSupplierById(int id) {
        String sql = "SELECT * FROM Supplier WHERE supplier_id = ?";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return new Supplier(
                        rs.getInt("supplier_id"),
                        rs.getString("name_Company"),
                        rs.getString("address"),
                        rs.getString("phone")
                );
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    @Override
    public List<Supplier> getAllSuppliers() {
        List<Supplier> list = new ArrayList<>();
        String sql = "SELECT * FROM Supplier";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                list.add(new Supplier(
                        rs.getInt("supplier_id"),
                        rs.getString("name_Company"),
                        rs.getString("address"),
                        rs.getString("phone")
                ));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    @Override
    public List<Supplier> searchByKeyword(String keyword) {
        List<Supplier> list = new ArrayList<>();
        String sql = "SELECT * FROM Supplier WHERE name_Company LIKE ? OR CAST(supplier_id AS CHAR) LIKE ?";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            String kw = "%" + keyword + "%";
            ps.setString(1, kw);
            ps.setString(2, kw);

            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Supplier supplier = new Supplier(
                        rs.getInt("supplier_id"),
                        rs.getString("name_Company"),
                        rs.getString("address"),
                        rs.getString("phone")
                );
                list.add(supplier);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    @Override
    public void insertSupplier(Supplier supplier) {
        String sql = "INSERT INTO Supplier (name_Company, address, phone) VALUES (?, ?, ?)";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, supplier.getNameCompany());
            ps.setString(2, supplier.getAddress());
            ps.setString(3, supplier.getPhone());
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    @Override
    public void updateSupplier(Supplier supplier) {
        String sql = "UPDATE Supplier SET name_Company = ?, address = ?, phone = ? WHERE supplier_id = ?";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, supplier.getNameCompany());
            ps.setString(2, supplier.getAddress());
            ps.setString(3, supplier.getPhone());
            ps.setInt(4, supplier.getSupplierId());
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    @Override
    public void deleteSupplier(int id) {
        String sql = "DELETE FROM Supplier WHERE supplier_id = ?";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, id);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

}
