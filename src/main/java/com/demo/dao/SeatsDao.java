package com.demo.dao;

import java.util.List;
import java.util.ArrayList;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import com.demo.model.Seat;

public class SeatsDao {

    public int addSeatsForType(int theaterId, int startRowIndex, int numRows, int seatsPerRow, int priceId, boolean coupleSeats) {
        int lastRowIndexUsed = startRowIndex;
        String sql = "INSERT INTO seats (theater_id, seat_number, price_id, status) VALUES (?, ?, ?, 'available')";

        try (Connection con = new MyConnection().getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            for (int r = 0; r < numRows; r++) {
                char rowLetter = (char) ('A' + startRowIndex + r);
                int cols = seatsPerRow;

                if (coupleSeats) {
                    // For couple seats, each seat occupies 2 columns
                    cols = seatsPerRow / 2;
                }

                for (int c = 1; c <= cols; c++) {
                    String seatNumber = String.valueOf(rowLetter) + c;
                    ps.setInt(1, theaterId);
                    ps.setString(2, seatNumber);
                    ps.setInt(3, priceId);
                    ps.addBatch();
                }

                lastRowIndexUsed = startRowIndex + r;
            }

            ps.executeBatch();
            return lastRowIndexUsed + 1; // next available row index

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return startRowIndex; // return current if failed
    }

    public List<Seat> getSeatsByTheater(int theaterId) {
        List<Seat> seats = new ArrayList<>();
        String sql = "SELECT s.seat_id, s.seat_number, s.status, sp.seat_type, sp.price " +
                     "FROM seats s " +
                     "LEFT JOIN seatprice sp ON s.price_id = sp.price_id " +
                     "WHERE s.theater_id = ? " +
                     "ORDER BY s.seat_number";

        try (Connection con = MyConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, theaterId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Seat seat = new Seat();
                seat.setSeatId(rs.getInt("seat_id"));
                seat.setSeatNumber(rs.getString("seat_number"));
                seat.setStatus(rs.getString("status"));
                seat.setSeatType(rs.getString("seat_type"));
                seat.setPrice(rs.getBigDecimal("price"));
                seats.add(seat);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return seats;
    }
    // Delete all seats for a given theater
    public void deleteSeatsByTheater(int theaterId) throws SQLException {
        String sql = "DELETE FROM seats WHERE theater_id = ?";
        try (Connection con = MyConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, theaterId);
            ps.executeUpdate();
        }
    }

    // Insert a list of seats
    public void insertSeats(List<Seat> seats) throws SQLException {
        String sql = "INSERT INTO seats (theater_id, seat_number, seat_type, status, price) VALUES (?, ?, ?, ?, ?)";
        try (Connection con = MyConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            for (Seat seat : seats) {
                ps.setInt(1, seat.getSeatId()); // theaterId should be stored in Seat.seatId temporarily
                ps.setString(2, seat.getSeatNumber());
                ps.setString(3, seat.getSeatType());
                ps.setString(4, seat.getStatus());
                ps.setBigDecimal(5, seat.getPrice());
                ps.addBatch();
            }
            ps.executeBatch();
        }
    }
}