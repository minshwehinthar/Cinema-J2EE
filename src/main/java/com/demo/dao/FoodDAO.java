package com.demo.dao;

import java.sql.*;
import java.util.*;

import com.demo.model.FoodItem;

public class FoodDAO {

    // --- Get all food items ---
    public List<FoodItem> getAllFoods() {
        List<FoodItem> list = new ArrayList<>();
        String sql = "SELECT * FROM food_items ORDER BY id DESC";

        try (Connection con = MyConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                FoodItem f = new FoodItem();
                f.setId(rs.getInt("id"));
                f.setName(rs.getString("name"));
                f.setPrice(rs.getDouble("price"));
                f.setImage(rs.getString("image"));
                f.setDescription(rs.getString("description"));
                f.setFoodType(rs.getString("food_type"));
                f.setRating(rs.getDouble("rating"));
                list.add(f);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    // --- Get a food item by ID ---
    public FoodItem getFoodById(int id) {
        FoodItem food = null;
        String sql = "SELECT * FROM food_items WHERE id=?";
        try (Connection con = MyConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                food = new FoodItem();
                food.setId(rs.getInt("id"));
                food.setName(rs.getString("name"));
                food.setPrice(rs.getDouble("price"));
                food.setImage(rs.getString("image"));
                food.setDescription(rs.getString("description"));
                food.setFoodType(rs.getString("food_type"));
                food.setRating(rs.getDouble("rating"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return food;
    }

    // --- Add new food item ---
    public boolean addFood(FoodItem f) {
        String sql = "INSERT INTO food_items(name, price, image, description, food_type, rating) VALUES(?,?,?,?,?,?)";
        try (Connection con = MyConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, f.getName());
            ps.setDouble(2, f.getPrice());
            ps.setString(3, f.getImage());
            ps.setString(4, f.getDescription());
            ps.setString(5, f.getFoodType());
            ps.setDouble(6, f.getRating());

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // --- Update food item ---
    public boolean updateFood(FoodItem f) {
        String sql = "UPDATE food_items SET name=?, price=?, image=?, description=?, food_type=?, rating=? WHERE id=?";
        try (Connection con = MyConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, f.getName());
            ps.setDouble(2, f.getPrice());
            ps.setString(3, f.getImage());
            ps.setString(4, f.getDescription());
            ps.setString(5, f.getFoodType());
            ps.setDouble(6, f.getRating());
            ps.setInt(7, f.getId());

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // --- Delete food item ---
    public boolean deleteFood(int id) {
        String sql = "DELETE FROM food_items WHERE id=?";
        try (Connection con = MyConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            int affectedRows = ps.executeUpdate();
            return affectedRows > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // --- Get all foods as Map (for AJAX) ---
    public List<Map<String, Object>> getAllFoodsMap() {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT * FROM food_items ORDER BY id DESC";
        try (Connection con = MyConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Map<String, Object> f = new HashMap<>();
                f.put("id", rs.getInt("id"));
                f.put("name", rs.getString("name"));
                f.put("price", rs.getDouble("price"));
                f.put("image", rs.getString("image"));
                f.put("food_type", rs.getString("food_type"));
                f.put("rating", rs.getDouble("rating"));
                list.add(f);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }
}
