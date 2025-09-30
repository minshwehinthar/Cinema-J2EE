package com.demo.model;

import java.util.Date;
import java.util.List;

public class OrderHistory {
    private int id;
    private int orderId;
    private int userId;
    private int theaterId;
    private double totalAmount;
    private String paymentMethod;
    private Date completedAt;

    private List<OrderItemHistory> items; // Order items

    // Getters and Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getOrderId() { return orderId; }
    public void setOrderId(int orderId) { this.orderId = orderId; }

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public int getTheaterId() { return theaterId; }
    public void setTheaterId(int theaterId) { this.theaterId = theaterId; }

    public double getTotalAmount() { return totalAmount; }
    public void setTotalAmount(double totalAmount) { this.totalAmount = totalAmount; }

    public String getPaymentMethod() { return paymentMethod; }
    public void setPaymentMethod(String paymentMethod) { this.paymentMethod = paymentMethod; }

    public Date getCompletedAt() { return completedAt; }
    public void setCompletedAt(Date completedAt) { this.completedAt = completedAt; }

    public List<OrderItemHistory> getItems() { return items; }
    public void setItems(List<OrderItemHistory> items) { this.items = items; }
}
