/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package model;

/**
 *
 * @author ASUS
 */
public class OrderItem {
    private int toyId;
    private String toyName;
    private int quantity;
    private double unitPrice;

    public OrderItem() {
    }

    public OrderItem(int toyId, String toyName, int quantity, double unitPrice) {
        this.toyId = toyId;
        this.toyName = toyName;
        this.quantity = quantity;
        this.unitPrice = unitPrice;
    }

    public int getToyId() {
        return toyId;
    }

    public void setToyId(int toyId) {
        this.toyId = toyId;
    }

    public String getToyName() {
        return toyName;
    }

    public void setToyName(String toyName) {
        this.toyName = toyName;
    }

    public int getQuantity() {
        return quantity;
    }

    public void setQuantity(int quantity) {
        this.quantity = quantity;
    }

    public double getUnitPrice() {
        return unitPrice;
    }

    public void setUnitPrice(double unitPrice) {
        this.unitPrice = unitPrice;
    }
    public double getTotalPrice() {
        return unitPrice * quantity;
    }
}
