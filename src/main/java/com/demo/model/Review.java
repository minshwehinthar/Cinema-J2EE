package com.demo.model;

import java.time.LocalDateTime;

public class Review {
    private int id;
    private int userId;
    private int theaterId;
    private String reviewText;
    private String isGood; // "yes" or "no"
    private int rating;
    private LocalDateTime createdAt;

    // Additional user info
    private String userName;
    private String userImage;

    // Getters and Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public int getTheaterId() { return theaterId; }
    public void setTheaterId(int theaterId) { this.theaterId = theaterId; }

    public String getReviewText() { return reviewText; }
    public void setReviewText(String reviewText) { this.reviewText = reviewText; }

    public String getIsGood() { return isGood; }
    public void setIsGood(String isGood) { this.isGood = isGood; }

    public int getRating() { return rating; }
    public void setRating(int rating) { this.rating = rating; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public String getUserName() { return userName; }
    public void setUserName(String userName) { this.userName = userName; }

    public String getUserImage() { return userImage; }
    public void setUserImage(String userImage) { this.userImage = userImage; }
}
