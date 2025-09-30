package com.demo.model;

public class FoodItem {
    private int id;
    private String name;
    private String image;
    private double price;
    private String description; 
    private String foodType; // snack or drink
    private double rating;   // NEW

    public FoodItem() {}

    public FoodItem(String name, String image, double price, String foodType, double rating) {
        this.name = name;
        this.image = image;
        this.price = price;
        this.foodType = foodType;
        this.rating = rating;
    }

    // Getters & Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getImage() { return image; }
    public void setImage(String image) { this.image = image; }

    public double getPrice() { return price; }
    public void setPrice(double price) { this.price = price; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public String getFoodType() { return foodType; }
    public void setFoodType(String foodType) { this.foodType = foodType; }

    public double getRating() { return rating; }
    public void setRating(double rating) { this.rating = rating; }
}
