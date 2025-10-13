/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Interface.java to edit this template
 */
package dao;

import model.Admin;

/**
 *
 * @author ASUS
 */
public interface IAdminDAO {

    Admin login(String username, String password);
    
}
