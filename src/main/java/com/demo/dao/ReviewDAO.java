package com.demo.dao;

import java.sql.*;
import java.util.*;
import java.util.Base64;
import com.demo.model.Review;

public class ReviewDAO {

    // Add review
    public boolean addReview(int userId, int theaterId, String reviewText, String isGood, int rating) {
        String sql = "INSERT INTO reviews (user_id, theater_id, review_text, is_good, rating, created_at) VALUES (?,?,?,?,?,NOW())";
        try (Connection con = MyConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, theaterId);
            ps.setString(3, reviewText);
            ps.setString(4, isGood);
            ps.setInt(5, rating);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // Delete review
    public boolean deleteReviewById(int reviewId, int userId) {
        String sql = "DELETE FROM reviews WHERE id=? AND user_id=?";
        try (Connection con = MyConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, reviewId);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // Update review
    public boolean updateReview(int reviewId, int userId, String reviewText, String isGood, int rating) {
        String sql = "UPDATE reviews SET review_text=?, is_good=?, rating=?, created_at=NOW() WHERE id=? AND user_id=?";
        try (Connection con = MyConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, reviewText);
            ps.setString(2, isGood);
            ps.setInt(3, rating);
            ps.setInt(4, reviewId);
            ps.setInt(5, userId);
            return ps.executeUpdate() > 0;
        } catch(SQLException e){
            e.printStackTrace();
            return false;
        }
    }

    // Get reviews for a theater
    public List<Review> getReviewsByTheater(int theaterId) {
        List<Review> reviews = new ArrayList<>();
        String sql = "SELECT r.*, u.name, u.image, u.imgtype FROM reviews r " +
                     "JOIN users u ON r.user_id = u.user_id " +
                     "WHERE r.theater_id=? ORDER BY r.created_at DESC";
        try (Connection con = MyConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, theaterId);
            ResultSet rs = ps.executeQuery();
            while(rs.next()) {
                Review r = new Review();
                r.setId(rs.getInt("id"));
                r.setUserId(rs.getInt("user_id"));
                r.setTheaterId(rs.getInt("theater_id"));
                r.setReviewText(rs.getString("review_text"));
                r.setIsGood(rs.getString("is_good"));
                r.setRating(rs.getInt("rating"));
                r.setCreatedAt(rs.getTimestamp("created_at").toLocalDateTime());
                r.setUserName(rs.getString("name"));

                byte[] imgBytes = rs.getBytes("image");
                if(imgBytes != null) {
                    String base64Img = "data:" + rs.getString("imgtype") + ";base64," + Base64.getEncoder().encodeToString(imgBytes);
                    r.setUserImage(base64Img);
                }
                reviews.add(r);
            }
        } catch(SQLException e){
            e.printStackTrace();
        }
        return reviews;
    }
}
