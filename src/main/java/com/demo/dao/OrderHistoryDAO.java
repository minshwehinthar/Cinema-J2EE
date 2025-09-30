package com.demo.dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

import com.demo.model.OrderHistory;
import com.demo.model.OrderItemHistory;

public class OrderHistoryDAO {
    private Connection conn;

    public OrderHistoryDAO(Connection conn) {
        this.conn = conn;
    }

    // Fetch all order history with items
    public List<OrderHistory> getAllOrderHistory() throws SQLException {
        List<OrderHistory> orders = new ArrayList<>();
        String sql = "SELECT * FROM order_history ORDER BY completed_at DESC";
        PreparedStatement ps = conn.prepareStatement(sql);
        ResultSet rs = ps.executeQuery();

        while (rs.next()) {
            OrderHistory order = new OrderHistory();
            order.setId(rs.getInt("id"));
            order.setOrderId(rs.getInt("order_id"));
            order.setUserId(rs.getInt("user_id"));
            order.setTheaterId(rs.getInt("theater_id"));
            order.setTotalAmount(rs.getDouble("total_amount"));
            order.setPaymentMethod(rs.getString("payment_method"));
            order.setCompletedAt(rs.getTimestamp("completed_at"));

            // Get items for this order
            order.setItems(getOrderItemsByOrderHistoryId(order.getId()));

            orders.add(order);
        }
        rs.close();
        ps.close();
        return orders;
    }

    // Fetch order items by order_history_id
    private List<OrderItemHistory> getOrderItemsByOrderHistoryId(int orderHistoryId) throws SQLException {
        List<OrderItemHistory> items = new ArrayList<>();
        String sql = "SELECT * FROM order_items_history WHERE order_history_id = ?";
        PreparedStatement ps = conn.prepareStatement(sql);
        ps.setInt(1, orderHistoryId);
        ResultSet rs = ps.executeQuery();

        while (rs.next()) {
            OrderItemHistory item = new OrderItemHistory();
            item.setId(rs.getInt("id"));
            item.setOrderHistoryId(rs.getInt("order_history_id"));
            item.setFoodId(rs.getInt("food_id"));
            item.setQuantity(rs.getInt("quantity"));
            item.setPrice(rs.getDouble("price"));
            items.add(item);
        }
        rs.close();
        ps.close();
        return items;
    }
    
 // Delete order by order_id and its items
    public boolean deleteOrder(int orderId) {
        String deleteItemsSQL = "DELETE oih FROM order_items_history oih " +
                                "JOIN order_history oh ON oih.order_history_id = oh.id " +
                                "WHERE oh.order_id = ?";
        String deleteOrderSQL = "DELETE FROM order_history WHERE order_id = ?";

        try {
            conn.setAutoCommit(false);

            // Delete items
            try (PreparedStatement ps1 = conn.prepareStatement(deleteItemsSQL)) {
                ps1.setInt(1, orderId);
                ps1.executeUpdate();
            }

            // Delete order
            try (PreparedStatement ps2 = conn.prepareStatement(deleteOrderSQL)) {
                ps2.setInt(1, orderId);
                ps2.executeUpdate();
            }

            conn.commit();
            return true;
        } catch (SQLException e) {
            try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            e.printStackTrace();
            return false;
        } finally {
            try { conn.setAutoCommit(true); } catch (SQLException ex) { ex.printStackTrace(); }
        }
    }

}
