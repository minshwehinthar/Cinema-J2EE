package com.demo.model;

public class CartItem {
    private int id;
    private int userId;
    private FoodItem food;
    private int quantity;

    public CartItem() {}

    public CartItem(int userId, FoodItem food, int quantity) {
        this.userId = userId;
        this.food = food;
        this.quantity = quantity;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public FoodItem getFood() { return food; }
    public void setFood(FoodItem food) { this.food = food; }

    public int getQuantity() { return quantity; }
    public void setQuantity(int quantity) { this.quantity = quantity; }

    public double getTotalPrice() {
        return food.getPrice() * quantity;
    }
}
