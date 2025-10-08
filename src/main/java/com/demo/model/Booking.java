package com.demo.model;

import java.math.BigDecimal;
import java.sql.Timestamp;
import java.util.List;

public class Booking {
    private int bookingId;
    private int userId;
    private int showtimeId;
    private BigDecimal totalPrice;
    private String status; // pending/confirmed/cancelled
    private Timestamp bookingTime;
    private String paymentMethod; // cash/kbzpay/wavepay

    private List<Integer> selectedSeatIds; // for storing booked seats

    // Constants for payment methods - ONLY 3
    public static final String CASH = "cash";
    public static final String KBZ_PAY = "kbzpay";
    public static final String WAVE_PAY = "wavepay";

    // Getters & Setters
    public int getBookingId() {
        return bookingId;
    }

    public void setBookingId(int bookingId) {
        this.bookingId = bookingId;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public int getShowtimeId() {
        return showtimeId;
    }

    public void setShowtimeId(int showtimeId) {
        this.showtimeId = showtimeId;
    }

    public BigDecimal getTotalPrice() {
        return totalPrice;
    }

    public void setTotalPrice(BigDecimal totalPrice) {
        this.totalPrice = totalPrice;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public Timestamp getBookingTime() {
        return bookingTime;
    }

    public void setBookingTime(Timestamp bookingTime) {
        this.bookingTime = bookingTime;
    }

    public String getPaymentMethod() {
        return paymentMethod;
    }

    public void setPaymentMethod(String paymentMethod) {
        this.paymentMethod = paymentMethod;
    }

    public List<Integer> getSelectedSeatIds() {
        return selectedSeatIds;
    }

    public void setSelectedSeatIds(List<Integer> selectedSeatIds) {
        this.selectedSeatIds = selectedSeatIds;
    }
}