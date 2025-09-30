package com.demo.model;

public class OrderItem {
    private int id;
    private int orderId;
    private FoodItem food;
    private int quantity;
    private double price;

    public OrderItem() {}

    public OrderItem(int orderId, FoodItem food, int quantity, double price) {
        this.orderId = orderId;
        this.food = food;
        this.quantity = quantity;
        this.price = price;
    }

    // Getters & Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getOrderId() { return orderId; }
    public void setOrderId(int orderId) { this.orderId = orderId; }

    public FoodItem getFood() { return food; }
    public void setFood(FoodItem food) { this.food = food; }

    public int getQuantity() { return quantity; }
    public void setQuantity(int quantity) { this.quantity = quantity; }

    public double getPrice() { return price; }
    public void setPrice(double price) { this.price = price; }

    public double getTotalPrice() { return quantity * price; }
}
