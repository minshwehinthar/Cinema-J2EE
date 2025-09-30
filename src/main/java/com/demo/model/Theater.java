package com.demo.model;

public class Theater {
    private int theaterId; // matches `theater_id` in DB
    private String name;
    private String location;
    private String image;
    private String imgtype;
    private int userId; // theater admin's user_id
    private java.util.Date createdAt;

    public Theater() {}

    public Theater(String name, String location, String image, int userId) {
        this.name = name;
        this.location = location;
        this.image = image;
        this.userId = userId;
    }

    // Getters & Setters
    public int getTheaterId() { return theaterId; }
    public void setTheaterId(int theaterId) { this.theaterId = theaterId; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getLocation() { return location; }
    public void setLocation(String location) { this.location = location; }

    public String getImage() { return image; }
    public void setImage(String image) { this.image = image; }

    public String getImgtype() { return imgtype; }
    public void setImgtype(String imgtype) { this.imgtype = imgtype; }

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public java.util.Date getCreatedAt() { return createdAt; }
    public void setCreatedAt(java.util.Date createdAt) { this.createdAt = createdAt; }
}
