package com.demo.dao;

import java.sql.*;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.ArrayList;

import com.demo.dao.MyConnection;
import com.demo.model.Showtime;
import com.demo.model.Timeslot;

public class ShowtimesDao {

    // Check if a timeslot is already assigned for a given date
    public boolean isSlotAssigned(int theaterId, int movieId, int slotId, LocalDate date) {
        boolean exists = false;
        try (Connection con = new MyConnection().getConnection()) {
            PreparedStatement pstm = con.prepareStatement(
                "SELECT * FROM showtimes WHERE theater_id=? AND movie_id=? AND slot_id=? AND show_date=?"
            );
            pstm.setInt(1, theaterId);
            pstm.setInt(2, movieId);
            pstm.setInt(3, slotId);
            pstm.setDate(4, Date.valueOf(date));
            ResultSet rs = pstm.executeQuery();
            exists = rs.next();
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return exists;
    }

    // Get movie start & end dates from theater_movies
    public LocalDate[] getMovieDates(int theaterId, int movieId) {
        LocalDate[] dates = null;
        try (Connection con = new MyConnection().getConnection()) {
            PreparedStatement pstm = con.prepareStatement(
                "SELECT start_date, end_date FROM theater_movies WHERE theater_id=? AND movie_id=?"
            );
            pstm.setInt(1, theaterId);
            pstm.setInt(2, movieId);
            ResultSet rs = pstm.executeQuery();
            if (rs.next()) {
                LocalDate start = rs.getDate("start_date").toLocalDate();
                LocalDate end = rs.getDate("end_date").toLocalDate();
                dates = new LocalDate[]{start, end};
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return dates;
    }

    // Assign timeslot across all dates (no duplicates)
    public boolean assignTimeslot(int theaterId, int movieId, int slotId, LocalDate start, LocalDate end) {
        if (start == null || end == null) return false;

        try (Connection con = new MyConnection().getConnection()) {
            PreparedStatement insertStmt = con.prepareStatement(
                "INSERT INTO showtimes (theater_id, movie_id, slot_id, show_date) VALUES (?, ?, ?, ?)"
            );

            LocalDate current = start;
            while (!current.isAfter(end)) {
                // Skip if slot already exists for this date
                if (!isSlotAssigned(theaterId, movieId, slotId, current)) {
                    insertStmt.setInt(1, theaterId);
                    insertStmt.setInt(2, movieId);
                    insertStmt.setInt(3, slotId);
                    insertStmt.setDate(4, Date.valueOf(current));
                    insertStmt.executeUpdate();
                }
                current = current.plusDays(1);
            }
            return true;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    
    public ArrayList<Timeslot> getFreeTimeslotsForDate(int theaterId, LocalDate date, ArrayList<Timeslot> allSlots) {
        ArrayList<Timeslot> freeSlots = new ArrayList<>();
        try (Connection con = new MyConnection().getConnection()) {
            for (Timeslot t : allSlots) {
                PreparedStatement pstm = con.prepareStatement(
                    "SELECT * FROM showtimes WHERE theater_id=? AND slot_id=? AND show_date=?"
                );
                pstm.setInt(1, theaterId);
                pstm.setInt(2, t.getSlotId());
                pstm.setDate(3, Date.valueOf(date));
                ResultSet rs = pstm.executeQuery();
                if (!rs.next()) { 
                    freeSlots.add(t);
                }
                rs.close();
                pstm.close();
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return freeSlots;
    }
    
    
    public boolean insertShowtime(int theaterId, int movieId, int slotId, LocalDate date) {
        try (Connection con = new MyConnection().getConnection()) {
            PreparedStatement pstm = con.prepareStatement(
                "INSERT INTO showtimes (theater_id, movie_id, slot_id, show_date) VALUES (?, ?, ?, ?)"
            );
            pstm.setInt(1, theaterId);
            pstm.setInt(2, movieId);
            pstm.setInt(3, slotId);
            pstm.setDate(4, Date.valueOf(date));
            return pstm.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    
    public ArrayList<Timeslot> getAssignedTimeslots(int theaterId, int movieId, LocalDate date) {
        ArrayList<Timeslot> slots = new ArrayList<>();
        try (Connection con = new MyConnection().getConnection()) {
            PreparedStatement pstm = con.prepareStatement(
                "SELECT s.slot_id, t.start_time, t.end_time " +
                "FROM showtimes s JOIN timeslots t ON s.slot_id = t.slot_id " +
                "WHERE s.theater_id=? AND s.movie_id=? AND s.show_date=?"
            );
            pstm.setInt(1, theaterId);
            pstm.setInt(2, movieId);
            pstm.setDate(3, Date.valueOf(date));
            ResultSet rs = pstm.executeQuery();
            while (rs.next()) {
                slots.add(new Timeslot(
                    rs.getInt("slot_id"),
                    theaterId,
                    rs.getTime("start_time"),
                    rs.getTime("end_time")
                ));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return slots;
    }

    


}
