package com.demo.model;

import java.util.Date;
import java.util.List;

public class Order {
    private int id;
    private int userId;
    private int theaterId;
    private double totalAmount;
    private String paymentMethod; // Cash / KPZ / Wave
    private String status; // pending / completed / picked
    private boolean adminConfirmed;
    private Date createdAt;
    private Date updatedAt;
    private List<OrderItem> items;

    public Order() {}

    // Getters & Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public int getTheaterId() { return theaterId; }
    public void setTheaterId(int theaterId) { this.theaterId = theaterId; }

    public double getTotalAmount() { return totalAmount; }
    public void setTotalAmount(double totalAmount) { this.totalAmount = totalAmount; }

    public String getPaymentMethod() { return paymentMethod; }
    public void setPaymentMethod(String paymentMethod) { this.paymentMethod = paymentMethod; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public boolean isAdminConfirmed() { return adminConfirmed; }
    public void setAdminConfirmed(boolean adminConfirmed) { this.adminConfirmed = adminConfirmed; }

    public Date getCreatedAt() { return createdAt; }
    public void setCreatedAt(Date createdAt) { this.createdAt = createdAt; }

    public Date getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Date updatedAt) { this.updatedAt = updatedAt; }

    public List<OrderItem> getItems() { return items; }
    public void setItems(List<OrderItem> items) { this.items = items; }
}
