package com.demo.dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

import com.demo.model.FoodItem;
import com.demo.model.Order;
import com.demo.model.OrderItem;

public class OrderDAO {

    // Place order
    public boolean placeOrder(Order order) {
        String sqlOrder = "INSERT INTO orders(user_id, theater_id, total_amount, payment_method, status, created_at) VALUES(?,?,?,?,?,NOW())";
        String sqlItem = "INSERT INTO order_items(order_id, food_id, quantity, price) VALUES(?,?,?,?)";

        try (Connection con = MyConnection.getConnection()) {
            con.setAutoCommit(false);

            // Insert order
            PreparedStatement psOrder = con.prepareStatement(sqlOrder, Statement.RETURN_GENERATED_KEYS);
            psOrder.setInt(1, order.getUserId());
            psOrder.setInt(2, order.getTheaterId());
            psOrder.setDouble(3, order.getTotalAmount());
            psOrder.setString(4, order.getPaymentMethod());
            psOrder.setString(5, order.getStatus());
            psOrder.executeUpdate();

            ResultSet rs = psOrder.getGeneratedKeys();
            int orderId = 0;
            if (rs.next()) orderId = rs.getInt(1);
            order.setId(orderId);

            // Insert order items
            if (order.getItems() != null) {
                for (OrderItem item : order.getItems()) {
                    PreparedStatement psItem = con.prepareStatement(sqlItem);
                    psItem.setInt(1, orderId);
                    psItem.setInt(2, item.getFood().getId());
                    psItem.setInt(3, item.getQuantity());
                    psItem.setDouble(4, item.getPrice());
                    psItem.executeUpdate();
                }
            }

            con.commit();
            return true;

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // Get order by ID
    public Order getOrderById(int orderId) {
        String sqlOrder = "SELECT * FROM orders WHERE id=?";
        String sqlItems = "SELECT oi.*, f.name, f.price, f.image FROM order_items oi JOIN food_items f ON oi.food_id = f.id WHERE oi.order_id=?";

        try (Connection con = MyConnection.getConnection()) {
            PreparedStatement psOrder = con.prepareStatement(sqlOrder);
            psOrder.setInt(1, orderId);
            ResultSet rsOrder = psOrder.executeQuery();

            if (rsOrder.next()) {
                Order order = extractOrder(rsOrder);

                // Load items
                PreparedStatement psItems = con.prepareStatement(sqlItems);
                psItems.setInt(1, orderId);
                ResultSet rsItems = psItems.executeQuery();
                List<OrderItem> items = new ArrayList<>();
                while (rsItems.next()) {
                    OrderItem item = new OrderItem();
                    FoodItem f = new FoodItem();
                    f.setId(rsItems.getInt("food_id"));
                    f.setName(rsItems.getString("name"));
                    f.setPrice(rsItems.getDouble("price"));
                    f.setImage(rsItems.getString("image"));
                    item.setFood(f);
                    item.setQuantity(rsItems.getInt("quantity"));
                    item.setPrice(rsItems.getDouble("price"));
                    items.add(item);
                }
                order.setItems(items != null ? items : new ArrayList<>());
                return order;
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public List<Order> getPendingOrders() {
        List<Order> list = new ArrayList<>();
        String sqlOrders = "SELECT * FROM orders WHERE status='pending' ORDER BY created_at DESC";
        String sqlItems = "SELECT oi.*, f.name, f.price, f.image, f.description, f.food_type, f.rating " +
                          "FROM order_items oi " +
                          "JOIN food_items f ON oi.food_id = f.id " +
                          "WHERE oi.order_id=?";

        try (Connection con = MyConnection.getConnection();
             PreparedStatement psOrders = con.prepareStatement(sqlOrders);
             ResultSet rsOrders = psOrders.executeQuery()) {

            while (rsOrders.next()) {
                Order o = extractOrder(rsOrders);

                // Load items
                PreparedStatement psItems = con.prepareStatement(sqlItems);
                psItems.setInt(1, o.getId());
                ResultSet rsItems = psItems.executeQuery();

                List<OrderItem> items = new ArrayList<>();
                while (rsItems.next()) {
                    FoodItem f = new FoodItem();
                    f.setId(rsItems.getInt("food_id"));
                    f.setName(rsItems.getString("name"));
                    f.setPrice(rsItems.getDouble("price"));
                    f.setImage(rsItems.getString("image"));
                    f.setDescription(rsItems.getString("description"));
                    f.setFoodType(rsItems.getString("food_type"));
                    f.setRating(rsItems.getDouble("rating"));

                    OrderItem item = new OrderItem();
                    item.setId(rsItems.getInt("id"));
                    item.setOrderId(o.getId());
                    item.setFood(f);
                    item.setQuantity(rsItems.getInt("quantity"));
                    item.setPrice(rsItems.getDouble("price"));

                    items.add(item);
                }

                o.setItems(items);
                list.add(o);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }



 // Get completed orders (with items)
    public List<Order> getCompletedOrders() {
        List<Order> list = new ArrayList<>();
        String sqlOrders = "SELECT * FROM orders WHERE status='completed' ORDER BY updated_at DESC";
        String sqlItems = "SELECT oi.*, f.name, f.price, f.image, f.description, f.food_type, f.rating " +
                          "FROM order_items oi JOIN food_items f ON oi.food_id = f.id WHERE oi.order_id=?";

        try (Connection con = MyConnection.getConnection();
             PreparedStatement psOrders = con.prepareStatement(sqlOrders);
             ResultSet rsOrders = psOrders.executeQuery()) {

            while (rsOrders.next()) {
                Order o = extractOrder(rsOrders);

                // Load items for each completed order
                PreparedStatement psItems = con.prepareStatement(sqlItems);
                psItems.setInt(1, o.getId());
                ResultSet rsItems = psItems.executeQuery();
                List<OrderItem> items = new ArrayList<>();
                while (rsItems.next()) {
                    FoodItem f = new FoodItem();
                    f.setId(rsItems.getInt("food_id"));
                    f.setName(rsItems.getString("name"));
                    f.setPrice(rsItems.getDouble("price"));
                    f.setImage(rsItems.getString("image"));
                    f.setDescription(rsItems.getString("description"));
                    f.setFoodType(rsItems.getString("food_type"));
                    f.setRating(rsItems.getDouble("rating"));

                    OrderItem item = new OrderItem();
                    item.setId(rsItems.getInt("id"));
                    item.setOrderId(o.getId());
                    item.setFood(f);
                    item.setQuantity(rsItems.getInt("quantity"));
                    item.setPrice(rsItems.getDouble("price"));

                    items.add(item);
                }

                o.setItems(items);
                list.add(o);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }


    // Admin confirm order (move to history)
    public boolean confirmOrder(int orderId){
        try(Connection con = MyConnection.getConnection()){
            con.setAutoCommit(false);

            // Get full order
            Order o = getOrderById(orderId);
            if(o == null) return false;

            // Insert into order_history
            String sqlHistory = "INSERT INTO order_history(order_id,user_id,theater_id,total_amount,payment_method) VALUES (?,?,?,?,?)";
            PreparedStatement psHistory = con.prepareStatement(sqlHistory, Statement.RETURN_GENERATED_KEYS);
            psHistory.setInt(1, o.getId());
            psHistory.setInt(2, o.getUserId());
            psHistory.setInt(3, o.getTheaterId());
            psHistory.setDouble(4, o.getTotalAmount());
            psHistory.setString(5, o.getPaymentMethod());
            psHistory.executeUpdate();

            ResultSet rs = psHistory.getGeneratedKeys();
            int historyId = 0;
            if(rs.next()) historyId = rs.getInt(1);

            // Move items
            if(o.getItems() != null){
                for(OrderItem item : o.getItems()){
                    String sqlItem = "INSERT INTO order_items_history(order_history_id,food_id,quantity,price) VALUES (?,?,?,?)";
                    PreparedStatement psItem = con.prepareStatement(sqlItem);
                    psItem.setInt(1, historyId);
                    psItem.setInt(2, item.getFood().getId());
                    psItem.setInt(3, item.getQuantity());
                    psItem.setDouble(4, item.getPrice());
                    psItem.executeUpdate();
                }
            }

            // Delete from active orders
            PreparedStatement psDelItems = con.prepareStatement("DELETE FROM order_items WHERE order_id=?");
            psDelItems.setInt(1, orderId);
            psDelItems.executeUpdate();

            PreparedStatement psDelOrder = con.prepareStatement("DELETE FROM orders WHERE id=?");
            psDelOrder.setInt(1, orderId);
            psDelOrder.executeUpdate();

            con.commit();
            return true;

        } catch(Exception e){ 
            e.printStackTrace(); 
        }
        return false;
    }
    
 // Mark order as completed (only update status)
    public boolean completeOrder(int orderId) {
        String sql = "UPDATE orders SET status='completed', updated_at=NOW() WHERE id=?";
        try (Connection con = MyConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            int rows = ps.executeUpdate();
            return rows > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

 // Get all orders (pending + completed)
    public List<Order> getAllOrders() {
        List<Order> list = new ArrayList<>();
        String sqlOrders = "SELECT * FROM orders ORDER BY created_at DESC";
        String sqlItems = "SELECT oi.*, f.name, f.price, f.image " +
                          "FROM order_items oi " +
                          "JOIN food_items f ON oi.food_id = f.id " +
                          "WHERE oi.order_id=?";

        try (Connection con = MyConnection.getConnection();
             PreparedStatement psOrders = con.prepareStatement(sqlOrders);
             ResultSet rsOrders = psOrders.executeQuery()) {

            while (rsOrders.next()) {
                Order order = extractOrder(rsOrders);

                // Load items
                PreparedStatement psItems = con.prepareStatement(sqlItems);
                psItems.setInt(1, order.getId());
                ResultSet rsItems = psItems.executeQuery();
                List<OrderItem> items = new ArrayList<>();
                while (rsItems.next()) {
                    OrderItem item = new OrderItem();
                    FoodItem f = new FoodItem();
                    f.setId(rsItems.getInt("food_id"));
                    f.setName(rsItems.getString("name"));
                    f.setPrice(rsItems.getDouble("price"));
                    f.setImage(rsItems.getString("image"));
                    item.setFood(f);
                    item.setQuantity(rsItems.getInt("quantity"));
                    item.setPrice(rsItems.getDouble("price"));
                    items.add(item);
                }
                order.setItems(items);

                list.add(order);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return list;
    }


    


    

    // Helper: extract Order from ResultSet
    private Order extractOrder(ResultSet rs) throws SQLException {
        Order o = new Order();
        o.setId(rs.getInt("id"));
        o.setUserId(rs.getInt("user_id"));
        o.setTheaterId(rs.getInt("theater_id"));
        o.setTotalAmount(rs.getDouble("total_amount"));
        o.setPaymentMethod(rs.getString("payment_method"));
        o.setStatus(rs.getString("status"));
        o.setCreatedAt(rs.getTimestamp("created_at"));
        o.setUpdatedAt(rs.getTimestamp("updated_at"));
        o.setItems(new ArrayList<>()); // always initialize
        return o;
    }
    
    // ✅ Add this method for AJAX Complete button
    public boolean markOrderComplete(int orderId){
        String sql = "UPDATE orders SET status='Completed' WHERE id=?";
        try (Connection conn = MyConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            int updated = ps.executeUpdate();
            return updated > 0;
        } catch (SQLException e){
            e.printStackTrace();
            return false;
        }
    }
//    public boolean markOrderPicked(int orderId) {
//        try (Connection conn = MyConnection.getConnection()) {
//            String sql = "UPDATE orders SET status = 'Picked' WHERE id = ?";
//            PreparedStatement ps = conn.prepareStatement(sql);
//            ps.setInt(1, orderId);
//            int rows = ps.executeUpdate();
//            return rows > 0;
//        } catch (SQLException e) {
//            e.printStackTrace();
//        }
//        return false;
//    }
    
    public boolean pickOrder(int orderId) {
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = MyConnection.getConnection();
            conn.setAutoCommit(false);

            // 1. Update order status to "picked"
            ps = conn.prepareStatement("UPDATE orders SET status='picked', updated_at=NOW() WHERE id=?");
            ps.setInt(1, orderId);
            int updatedRows = ps.executeUpdate();
            ps.close();

            if (updatedRows == 0) {
                conn.rollback();
                return false; // Order not found
            }

            // 2. Get order details
            ps = conn.prepareStatement("SELECT * FROM orders WHERE id=?");
            ps.setInt(1, orderId);
            rs = ps.executeQuery();
            if (!rs.next()) {
                conn.rollback();
                return false;
            }

            int userId = rs.getInt("user_id");
            int theaterId = rs.getInt("theater_id");
            double totalAmount = rs.getDouble("total_amount");
            String paymentMethod = rs.getString("payment_method");

            rs.close();
            ps.close();

            // 3. Insert into order_history
            ps = conn.prepareStatement(
                "INSERT INTO order_history (order_id, user_id, theater_id, total_amount, payment_method, completed_at) VALUES (?, ?, ?, ?, ?, NOW())",
                Statement.RETURN_GENERATED_KEYS
            );
            ps.setInt(1, orderId);
            ps.setInt(2, userId);
            ps.setInt(3, theaterId);
            ps.setDouble(4, totalAmount);
            ps.setString(5, paymentMethod);
            ps.executeUpdate();

            rs = ps.getGeneratedKeys();
            int orderHistoryId = 0;
            if (rs.next()) orderHistoryId = rs.getInt(1);

            rs.close();
            ps.close();

            // 4. Copy order_items → order_items_history
            ps = conn.prepareStatement("SELECT * FROM order_items WHERE order_id=?");
            ps.setInt(1, orderId);
            rs = ps.executeQuery();

            PreparedStatement psInsertItem = conn.prepareStatement(
                "INSERT INTO order_items_history (order_history_id, food_id, quantity, price) VALUES (?, ?, ?, ?)"
            );
            while (rs.next()) {
                psInsertItem.setInt(1, orderHistoryId);
                psInsertItem.setInt(2, rs.getInt("food_id"));
                psInsertItem.setInt(3, rs.getInt("quantity"));
                psInsertItem.setDouble(4, rs.getDouble("price"));
                psInsertItem.addBatch();
            }
            psInsertItem.executeBatch();
            psInsertItem.close();
            rs.close();
            ps.close();

            // 5. Delete from orders and order_items
            ps = conn.prepareStatement("DELETE FROM orders WHERE id=?");
            ps.setInt(1, orderId);
            ps.executeUpdate();
            ps.close();

            conn.commit();
            return true;

        } catch (Exception e) {
            e.printStackTrace();
            try { if (conn != null) conn.rollback(); } catch (Exception ex) {}
            return false;
        } finally {
            try { if (rs != null) rs.close(); } catch (Exception e) {}
            try { if (ps != null) ps.close(); } catch (Exception e) {}
            try { if (conn != null) conn.setAutoCommit(true); } catch (Exception e) {}
        }
    }

}
