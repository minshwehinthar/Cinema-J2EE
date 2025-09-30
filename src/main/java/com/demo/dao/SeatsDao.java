package com.demo.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

public class SeatsDao {

    public boolean addSeatsForRows(int theaterId, String rowsInput, int seatsPerRow, int priceId) {
        MyConnection conObj = new MyConnection();
        Connection con = conObj.getConnection();

        String[] rows = rowsInput.split(",");
        try {
            for(String row : rows) {
                row = row.trim().toUpperCase();
                for(int col=1; col<=seatsPerRow; col++) {
                    String seatNumber = row + col;
                    PreparedStatement pstm = con.prepareStatement(
                        "INSERT INTO seats (theater_id, seat_number, price_id) VALUES (?, ?, ?)"
                    );
                    pstm.setInt(1, theaterId);
                    pstm.setString(2, seatNumber);
                    pstm.setInt(3, priceId);
                    pstm.executeUpdate();
                    pstm.close();
                }
            }
            return true;
        } catch(SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
}
