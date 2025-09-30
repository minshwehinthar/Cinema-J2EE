package com.demo.dao;

import com.demo.model.User;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class UserDAO {
	   public boolean register(User user) {
	        String sql = "INSERT INTO users(name,email,password,phone,role,status) VALUES(?,?,?,?,?,?)";
	        try (Connection con = MyConnection.getConnection();
	             PreparedStatement ps = con.prepareStatement(sql)) {

	            ps.setString(1, user.getName());
	            ps.setString(2, user.getEmail());
	            ps.setString(3, user.getPassword());
	            ps.setString(4, user.getPhone());
	            ps.setString(5, user.getRole());
	            ps.setString(6, "active");

	            return ps.executeUpdate() > 0;
	        } catch (SQLException e) {
	            e.printStackTrace();
	        }
	        return false;
	    }
	   
	   public User login(String email, String password) {
		    String sql = "SELECT * FROM users WHERE email=? AND password=?";
		    try (Connection con = MyConnection.getConnection();
		         PreparedStatement ps = con.prepareStatement(sql)) {
		        ps.setString(1, email);
		        ps.setString(2, password);

		        ResultSet rs = ps.executeQuery();
		        if (rs.next()) {
		            return extractUser(rs); // fetch all fields
		        }
		    } catch (SQLException e) {
		        e.printStackTrace();
		    }
		    return null;
		}




public void updateStatus(String email, String status) {
    String sql = "UPDATE users SET status=? WHERE email=?";
    try (Connection con = MyConnection.getConnection();
         PreparedStatement ps = con.prepareStatement(sql)) {

        ps.setString(1, status);
        ps.setString(2, email);
        ps.executeUpdate();

    } catch (SQLException e) {
        e.printStackTrace();
    }
}

//public User getUserById(int userId) {
//    User user = null;
//    try (Connection con = MyConnection.getConnection()) {
//        String sql = "SELECT * FROM users WHERE user_id=?";
//        PreparedStatement ps = con.prepareStatement(sql);
//        ps.setInt(1, userId);
//        ResultSet rs = ps.executeQuery();
//        if (rs.next()) {
//            user = new User();
//            user.setUserId(rs.getInt("user_id"));
//            user.setName(rs.getString("name"));
//            user.setEmail(rs.getString("email"));
//            user.setPhone(rs.getString("phone"));
//            user.setRole(rs.getString("role"));
//        }
//    } catch (Exception e) {
//        e.printStackTrace();
//    }
//    return user;
//}

/////////////////
//private User extractUser(ResultSet rs) throws SQLException {
//    User user = new User();
//    user.setUserId(rs.getInt("user_id"));
//    user.setName(rs.getString("name"));
//    user.setEmail(rs.getString("email"));
//    user.setPhone(rs.getString("phone"));
//    user.setPassword(rs.getString("password"));
//    user.setRole(rs.getString("role") != null ? rs.getString("role") : "user");
//    user.setGender(rs.getString("gender"));
//    user.setBirthdate(rs.getDate("birthdate"));
//    user.setImage(rs.getBytes("image"));
//    user.setImgtype(rs.getString("imgtype"));
//    user.setStatus(rs.getString("status") != null ? rs.getString("status") : "active");
//    user.setCreatedAt(rs.getString("created_at")); // ✅ match table column
//    return user;
//}


////Get all users
//public List<User> getAllUsers() {
//    List<User> users = new ArrayList<>();
//    String sql = "SELECT * FROM users ORDER BY created_at DESC"; // ✅ match DB column
//    try (Connection conn = new MyConnection().getConnection();
//         PreparedStatement ps = conn.prepareStatement(sql);
//         ResultSet rs = ps.executeQuery()) {
//        while (rs.next()) {
//            users.add(extractUser(rs));
//        }
//    } catch (Exception e) { e.printStackTrace(); }
//    return users;
//}


//Create user
public boolean createUser(User user) {
	  String sql = "INSERT INTO users(name, email, phone, role, password, birthdate, gender, image, imgtype, status, created_at) " +
	               "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
	  try (Connection conn = new MyConnection().getConnection();
	       PreparedStatement ps = conn.prepareStatement(sql)) {

	      ps.setString(1, user.getName());
	      ps.setString(2, user.getEmail());
	      ps.setString(3, user.getPhone());
	      ps.setString(4, user.getRole());
	      ps.setString(5, user.getPassword());
	      ps.setDate(6, user.getBirthdate());
	      ps.setString(7, user.getGender());
	      ps.setBytes(8, user.getImage());
	      ps.setString(9, user.getImgtype());
	      ps.setString(10, user.getStatus() != null ? user.getStatus() : "active");
	      ps.setString(11, user.getCreatedAt());

	      return ps.executeUpdate() > 0;
	  } catch (Exception e) {
	      e.printStackTrace();
	  }
	  return false;
	}


	////Update full user
	//public boolean updateUser(User user) {
	// String sql = "UPDATE users SET name=?, email=?, phone=?, password=?, birthdate=?, gender=?, image=?, imgtype=?, role=?, status=? WHERE user_id=?";
	// try (Connection conn = new MyConnection().getConnection();
//	      PreparedStatement ps = conn.prepareStatement(sql)) {
//	     ps.setString(1, user.getName());
//	     ps.setString(2, user.getEmail());
//	     ps.setString(3, user.getPhone());
//	     ps.setString(4, user.getPassword());
//	     ps.setDate(5, user.getBirthdate());
//	     ps.setString(6, user.getGender());
//	     ps.setBytes(7, user.getImage());
//	     ps.setString(8, user.getImgtype());
//	     ps.setString(9, user.getRole() != null ? user.getRole() : "user");
//	     ps.setString(10, user.getStatus() != null ? user.getStatus() : "active");
//	     ps.setInt(11, user.getUserId());
//	     return ps.executeUpdate() > 0;
	// } catch (Exception e) { e.printStackTrace(); }
	// return false;
	//}



	//Delete user
	public boolean deleteUser(int userId) {
	 String sql = "DELETE FROM users WHERE user_id=?";
	 try (Connection conn = new MyConnection().getConnection();
	      PreparedStatement ps = conn.prepareStatement(sql)) {
	     ps.setInt(1, userId);
	     return ps.executeUpdate() > 0;
	 } catch (Exception e) { e.printStackTrace(); }
	 return false;
	}

	//Check if email exists
	public boolean existsByEmail(String email) {
	 String sql = "SELECT user_id FROM users WHERE email=?";
	 try (Connection conn = new MyConnection().getConnection();
	      PreparedStatement ps = conn.prepareStatement(sql)) {
	     ps.setString(1, email);
	     try (ResultSet rs = ps.executeQuery()) {
	         return rs.next();
	     }
	 } catch (Exception e) { e.printStackTrace(); }
	 return false;
	}

	//Check password
	public boolean checkPassword(int userId, String password) {
	 String sql = "SELECT user_id FROM users WHERE user_id=? AND password=?";
	 try (Connection conn = new MyConnection().getConnection();
	      PreparedStatement ps = conn.prepareStatement(sql)) {
	     ps.setInt(1, userId);
	     ps.setString(2, password);
	     try (ResultSet rs = ps.executeQuery()) {
	         return rs.next();
	     }
	 } catch (Exception e) { e.printStackTrace(); }
	 return false;
	}

	//Update password
	public boolean updatePassword(int userId, String newPassword) {
	 String sql = "UPDATE users SET password=? WHERE user_id=?";
	 try (Connection conn = new MyConnection().getConnection();
	      PreparedStatement ps = conn.prepareStatement(sql)) {
	     ps.setString(1, newPassword);
	     ps.setInt(2, userId);
	     return ps.executeUpdate() > 0;
	 } catch (Exception e) { e.printStackTrace(); }
	 return false;
	}

	//Update single field
	public boolean updateField(int userId, String field, String value) {
	 String sql = "UPDATE users SET " + field + "=? WHERE user_id=?";
	 try (Connection conn = new MyConnection().getConnection();
	      PreparedStatement ps = conn.prepareStatement(sql)) {
	     ps.setString(1, value);
	     ps.setInt(2, userId);
	     return ps.executeUpdate() > 0;
	 } catch (Exception e) { e.printStackTrace(); }
	 return false;
	}

	//Get multiple users by IDs
	public List<User> getUsersByIds(List<Integer> ids) {
	 List<User> list = new ArrayList<>();
	 if (ids == null || ids.isEmpty()) return list;

	 StringBuilder sb = new StringBuilder();
	 for (int i = 0; i < ids.size(); i++) {
	     sb.append("?");
	     if (i < ids.size() - 1) sb.append(",");
	 }

	 String sql = "SELECT * FROM users WHERE user_id IN (" + sb.toString() + ")";
	 try (Connection conn = new MyConnection().getConnection();
	      PreparedStatement ps = conn.prepareStatement(sql)) {

	     for (int i = 0; i < ids.size(); i++) ps.setInt(i + 1, ids.get(i));

	     try (ResultSet rs = ps.executeQuery()) {
	         while (rs.next()) {
	             list.add(extractUser(rs));
	         }
	     }
	 } catch (SQLException e) { e.printStackTrace(); }
	 return list;
	}

	//Extract user from ResultSet
	private User extractUser(ResultSet rs) throws SQLException {
	    User user = new User();
	    user.setUserId(rs.getInt("user_id"));
	    user.setName(rs.getString("name"));
	    user.setEmail(rs.getString("email"));
	    user.setPhone(rs.getString("phone"));
	    user.setPassword(rs.getString("password"));
	    user.setRole(rs.getString("role") != null ? rs.getString("role") : "user");
	    user.setGender(rs.getString("gender"));
	    user.setBirthdate(rs.getDate("birthdate"));
	    user.setImage(rs.getBytes("image"));
	    user.setImgtype(rs.getString("imgtype"));
	    user.setStatus(rs.getString("status") != null ? rs.getString("status") : "active");
	    user.setCreatedAt(rs.getString("created_at"));
	    return user;
	}

	// Get user by ID
	public User getUserById(int userId) {
	    User user = null;
	    String sql = "SELECT * FROM users WHERE user_id=?";
	    try (Connection conn = MyConnection.getConnection();
	         PreparedStatement ps = conn.prepareStatement(sql)) {

	        ps.setInt(1, userId);
	        try (ResultSet rs = ps.executeQuery()) {
	            if (rs.next()) {
	                user = extractUser(rs);
	            }
	        }
	    } catch (Exception e) { e.printStackTrace(); }
	    return user;
	}

	// Update user (full update)
	public boolean updateUser(User user) {
	    String sql = "UPDATE users SET name=?, email=?, phone=?, password=?, birthdate=?, gender=?, image=?, imgtype=?, role=?, status=? WHERE user_id=?";
	    try (Connection conn = MyConnection.getConnection();
	         PreparedStatement ps = conn.prepareStatement(sql)) {

	        ps.setString(1, user.getName());
	        ps.setString(2, user.getEmail());
	        ps.setString(3, user.getPhone());
	        ps.setString(4, user.getPassword());
	        ps.setDate(5, user.getBirthdate());
	        ps.setString(6, user.getGender());
	        ps.setBytes(7, user.getImage());
	        ps.setString(8, user.getImgtype());
	        ps.setString(9, user.getRole());
	        ps.setString(10, user.getStatus());
	        ps.setInt(11, user.getUserId());

	        return ps.executeUpdate() > 0;
	    } catch (Exception e) { e.printStackTrace(); }
	    return false;
	}

	// Get all users
	public List<User> getAllUsers() {
	    List<User> users = new ArrayList<>();
	    String sql = "SELECT * FROM users ORDER BY created_at DESC";
	    try (Connection conn = MyConnection.getConnection();
	         PreparedStatement ps = conn.prepareStatement(sql);
	         ResultSet rs = ps.executeQuery()) {

	        while (rs.next()) {
	            users.add(extractUser(rs));
	        }
	    } catch (Exception e) { e.printStackTrace(); }
	    return users;
	}
	

public int getTheaterIdByUserId(int userId) {
    MyConnection conObj = new MyConnection();
    Connection con = conObj.getConnection();
    int theaterId = 0;

    try {
        PreparedStatement pstm = con.prepareStatement(
            "SELECT theater_id FROM theaters WHERE user_id = ?"
        );
        pstm.setInt(1, userId);
        ResultSet rs = pstm.executeQuery();

        if (rs.next()) {
            theaterId = rs.getInt("theater_id");
        }

    } catch (SQLException e) {
        e.printStackTrace();
    }

    return theaterId;
}


}
