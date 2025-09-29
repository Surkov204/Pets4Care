package model;

public class OrderDetail {
    private int detailId;
    private int orderId;
    private int toyId;
    private int quantity;
    private double unitPrice;


    public int getDetailId() { return detailId; }
    public void setDetailId(int detailId) { this.detailId = detailId; }

    public int getOrderId() { return orderId; }
    public void setOrderId(int orderId) { this.orderId = orderId; }

    public int getToyId() { return toyId; }
    public void setToyId(int toyId) { this.toyId = toyId; }

    public int getQuantity() { return quantity; }
    public void setQuantity(int quantity) { this.quantity = quantity; }

    public double getUnitPrice() { return unitPrice; }
    public void setUnitPrice(double unitPrice) { this.unitPrice = unitPrice; }

}
