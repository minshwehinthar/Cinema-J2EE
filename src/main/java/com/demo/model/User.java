package com.demo.model;

import java.sql.Date;

public class User {
private int userId;
private String name;
private String email;
private String password;
private String phone;
private String role;
private String gender;
private Date birthdate;
private byte[] image;
private String imgtype;
private String status;
private String createdAt;

// Getters & Setters
public int getUserId() { return userId; }
public void setUserId(int userId) { this.userId = userId; }

public String getName() { return name; }
public void setName(String name) { this.name = name; }

public String getEmail() { return email; }
public void setEmail(String email) { this.email = email; }

public String getPassword() { return password; }
public void setPassword(String password) { this.password = password; }

public String getPhone() { return phone; }
public void setPhone(String phone) { this.phone = phone; }

public String getRole() { return role; }
public void setRole(String role) { this.role = role; }

public String getGender() { return gender; }
public void setGender(String gender) { this.gender = gender; }

public Date getBirthdate() { return birthdate; }
public void setBirthdate(Date birthdate) { this.birthdate = birthdate; }

public byte[] getImage() { return image; }
public void setImage(byte[] image) { this.image = image; }

public String getImgtype() { return imgtype; }
public void setImgtype(String imgtype) { this.imgtype = imgtype; }

public String getStatus() { return status; }
public void setStatus(String status) { this.status = status; }

public String getCreatedAt() { return createdAt; }
public void setCreatedAt(String createdAt) { this.createdAt = createdAt; }

}
