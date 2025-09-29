package model;

public class CartItem {
    private Toy toy;
    private int quantity;

    public CartItem(Toy toy, int quantity) {
        this.toy = toy;
        this.quantity = quantity;
    }

    public Toy getToy() {
        return toy;
    }

    public void setToy(Toy toy) {
        this.toy = toy;
    }

    public int getQuantity() {
        return quantity;
    }

    public void setQuantity(int quantity) {
        this.quantity = quantity;
    }

    public double getTotalPrice() {
        return toy.getPrice() * quantity;
    }
}
