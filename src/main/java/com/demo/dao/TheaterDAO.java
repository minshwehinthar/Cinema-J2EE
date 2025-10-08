package com.demo.dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

import com.demo.model.Theater;

public class TheaterDAO {
//
//    // Get all theaters
//    public List<Theater> getAllTheaters() {
//        List<Theater> list = new ArrayList<>();
//        String sql = "SELECT * FROM theaters ORDER BY theater_id";
//
//        try (Connection con = MyConnection.getConnection();
//             PreparedStatement ps = con.prepareStatement(sql);
//             ResultSet rs = ps.executeQuery()) {
//
//            while (rs.next()) {
//                Theater t = new Theater();
//                t.setTheaterId(rs.getInt("theater_id"));
//                t.setName(rs.getString("name"));
//                t.setLocation(rs.getString("location"));
//                t.setImage(rs.getString("image")); // path instead of Base64
//                t.setImgtype(rs.getString("imgtype"));
//                t.setUserId(rs.getInt("user_id"));
//                t.setCreatedAt(rs.getTimestamp("created_at"));
//                list.add(t);
//            }
//
//        } catch (SQLException e) {
//            e.printStackTrace();
//        }
//
//        return list;
//    }

//    // Get theater by theaterId
//    public Theater getTheaterById(int theaterId) {
//        Theater theater = null;
//        String sql = "SELECT * FROM theaters WHERE theater_id=?";
//
//        try (Connection con = MyConnection.getConnection();
//             PreparedStatement ps = con.prepareStatement(sql)) {
//
//            ps.setInt(1, theaterId);
//            ResultSet rs = ps.executeQuery();
//
//            if (rs.next()) {
//                theater = new Theater();
//                theater.setTheaterId(rs.getInt("theater_id"));
//                theater.setName(rs.getString("name"));
//                theater.setLocation(rs.getString("location"));
//                theater.setImage(rs.getString("image")); // path instead of Base64
//                theater.setImgtype(rs.getString("imgtype"));
//                theater.setUserId(rs.getInt("user_id"));
//                theater.setCreatedAt(rs.getTimestamp("created_at"));
//            }
//
//        } catch (SQLException e) {
//            e.printStackTrace();
//        }
//
//        return theater;
//    }

    // Get theater by userId
    public Theater getTheaterByUserId(int userId) {
        Theater theater = null;
        String sql = "SELECT * FROM theaters WHERE user_id=?";

        try (Connection con = MyConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                theater = new Theater();
                theater.setTheaterId(rs.getInt("theater_id"));
                theater.setName(rs.getString("name"));
                theater.setLocation(rs.getString("location"));
                theater.setImage(rs.getString("image")); // path instead of Base64
                theater.setImgtype(rs.getString("imgtype"));
                theater.setUserId(rs.getInt("user_id"));
                theater.setCreatedAt(rs.getTimestamp("created_at"));
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return theater;
    }

    // Create theater
 // Create theater
    public int createTheater(Theater theater) {
        String sql = "INSERT INTO theaters (name, location, image, imgtype, user_id, created_at) VALUES (?, ?, ?, ?, ?, NOW())";

        try (Connection con = MyConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setString(1, theater.getName());
            ps.setString(2, theater.getLocation());

            // Convert Base64 to bytes for BLOB column
            if (theater.getImage() != null && !theater.getImage().isEmpty()) {
                byte[] imageBytes = java.util.Base64.getDecoder().decode(theater.getImage());
                ps.setBytes(3, imageBytes);
            } else {
                ps.setNull(3, Types.BLOB);
            }

            ps.setString(4, theater.getImgtype());
            ps.setInt(5, theater.getUserId());

            int affectedRows = ps.executeUpdate();
            if (affectedRows > 0) {
                ResultSet rs = ps.getGeneratedKeys();
                if (rs.next()) {
                    theater.setTheaterId(rs.getInt(1));
                    return theater.getTheaterId();
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return -1;
    }


//    // Update theater
//    public boolean updateTheater(Theater theater) {
//        String sql = "UPDATE theaters SET name=?, location=?, image=?, imgtype=? WHERE theater_id=?";
//
//        try (Connection con = MyConnection.getConnection();
//             PreparedStatement ps = con.prepareStatement(sql)) {
//
//            ps.setString(1, theater.getName());
//            ps.setString(2, theater.getLocation());
//
//            // Store file path or null
//            if (theater.getImage() != null) {
//                ps.setString(3, theater.getImage());
//            } else {
//                ps.setNull(3, Types.VARCHAR);
//            }
//
//            ps.setString(4, theater.getImgtype());
//            ps.setInt(5, theater.getTheaterId());
//
//            return ps.executeUpdate() > 0;
//
//        } catch (SQLException e) {
//            e.printStackTrace();
//        }
//
//        return false;
//    }

    // Delete theater
    public boolean deleteTheater(int theaterId) {
        String sql = "DELETE FROM theaters WHERE theater_id=?";
        try (Connection con = MyConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, theaterId);
            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // Get all theaters by user
    public List<Theater> getTheatersByUserId(int userId) {
        List<Theater> theaters = new ArrayList<>();
        String sql = "SELECT * FROM theaters WHERE user_id=?";
        try (Connection conn = MyConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Theater t = new Theater();
                t.setTheaterId(rs.getInt("theater_id"));
                t.setName(rs.getString("name"));
                t.setLocation(rs.getString("location"));
                t.setImage(rs.getString("image"));
                t.setImgtype(rs.getString("imgtype"));
                t.setUserId(rs.getInt("user_id"));
                t.setCreatedAt(rs.getTimestamp("created_at"));
                theaters.add(t);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return theaters;
    }
    
    // Get all theaters
    public List<Theater> getAllTheaters() {
        List<Theater> list = new ArrayList<>();
        String sql = "SELECT * FROM theaters ORDER BY theater_id";

        try (Connection con = MyConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Theater t = new Theater();
                t.setTheaterId(rs.getInt("theater_id"));
                t.setName(rs.getString("name"));
                t.setLocation(rs.getString("location"));

                byte[] imgBytes = rs.getBytes("image");
                if (imgBytes != null && imgBytes.length > 0) {
                    t.setImage(java.util.Base64.getEncoder().encodeToString(imgBytes));
                }

                t.setImgtype(rs.getString("imgtype"));
                t.setUserId(rs.getInt("user_id"));
                t.setCreatedAt(rs.getTimestamp("created_at"));
                list.add(t);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return list;
    }

    public Theater getTheaterById(int theaterId) {
        Theater theater = null;
        String sql = "SELECT * FROM theaters WHERE theater_id=?";

        try (Connection con = MyConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, theaterId);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                theater = new Theater();
                theater.setTheaterId(rs.getInt("theater_id"));
                theater.setName(rs.getString("name"));
                theater.setLocation(rs.getString("location"));

                byte[] imgBytes = rs.getBytes("image");
                if (imgBytes != null && imgBytes.length > 0) {
                    theater.setImage(java.util.Base64.getEncoder().encodeToString(imgBytes));
                }

                theater.setImgtype(rs.getString("imgtype"));
                theater.setUserId(rs.getInt("user_id"));
                theater.setCreatedAt(rs.getTimestamp("created_at"));
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return theater;
    }

    // Update theater
    public boolean updateTheater(Theater theater) {
        String sql = "UPDATE theaters SET name=?, location=?, image=?, imgtype=? WHERE theater_id=?";

        try (Connection con = MyConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, theater.getName());
            ps.setString(2, theater.getLocation());

            if (theater.getImage() != null) {
                ps.setBytes(3, java.util.Base64.getDecoder().decode(theater.getImage()));
            } else {
                ps.setNull(3, Types.BLOB);
            }

            ps.setString(4, theater.getImgtype());
            ps.setInt(5, theater.getTheaterId());

            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return false;
    }
    
    public Integer getTheaterIdByAdmin(int adminId) {
        Integer theaterId = null;
        try (Connection con = MyConnection.getConnection();
             PreparedStatement ps = con.prepareStatement("SELECT theater_id FROM theaters WHERE user_id = ?")) {
            ps.setInt(1, adminId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                theaterId = rs.getInt("theater_id");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return theaterId;
    }
    public int getTheaterIdByUserId(int userId) {
        int theaterId = 0;
        try {
            Connection con = MyConnection.getConnection();
            PreparedStatement ps = con.prepareStatement("SELECT theater_id FROM users WHERE user_id=?");
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                theaterId = rs.getInt("theater_id");
            }
        } catch(Exception e) {
            e.printStackTrace();
        }
        return theaterId;
    }

}
