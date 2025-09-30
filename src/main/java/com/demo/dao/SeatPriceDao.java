package com.demo.dao;

import java.sql.*;
import java.util.ArrayList;
import com.demo.model.SeatPrice;

public class SeatPriceDao {

    public ArrayList<SeatPrice> getAllSeatPrices() {
        ArrayList<SeatPrice> list = new ArrayList<>();
        try (Connection con = new MyConnection().getConnection()) {
            PreparedStatement pstm = con.prepareStatement("SELECT * FROM seatprice");
            ResultSet rs = pstm.executeQuery();
            while (rs.next()) {
                SeatPrice sp = new SeatPrice();
                sp.setPriceId(rs.getInt("price_id"));
                sp.setSeatType(rs.getString("seat_type"));
                sp.setPrice(rs.getBigDecimal("price"));
                list.add(sp);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public boolean updatePrice(int priceId, double price) {
        try (Connection con = new MyConnection().getConnection()) {
            PreparedStatement pstm = con.prepareStatement("UPDATE seatprice SET price = ? WHERE price_id = ?");
            pstm.setDouble(1, price);
            pstm.setInt(2, priceId);
            return pstm.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    
    public int getPriceIdBySeatType(String seatType) {
        int priceId = -1; // default if not found
        try (Connection con = new MyConnection().getConnection()) {
            PreparedStatement pstm = con.prepareStatement(
                "SELECT price_id FROM seatprice WHERE seat_type = ?"
            );
            pstm.setString(1, seatType);
            ResultSet rs = pstm.executeQuery();
            if (rs.next()) {
                priceId = rs.getInt("price_id");
            }
            rs.close();
            pstm.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return priceId;
    }
    
    public ArrayList<String> getAllSeatTypes() {
        ArrayList<String> seatTypes = new ArrayList<>();
        try (Connection con = new MyConnection().getConnection()) {
            PreparedStatement pstm = con.prepareStatement("SELECT seat_type FROM seatprice");
            ResultSet rs = pstm.executeQuery();
            while (rs.next()) {
                seatTypes.add(rs.getString("seat_type"));
            }
            rs.close();
            pstm.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return seatTypes;
    }


    
}
