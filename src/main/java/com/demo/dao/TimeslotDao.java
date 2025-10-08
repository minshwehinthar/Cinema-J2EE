package com.demo.dao;

import java.sql.*;
import java.time.LocalDate;
import java.util.ArrayList;
import com.demo.model.Timeslot;

public class TimeslotDao {
	
    public int addTimeslot(int theaterId, String startTime, String endTime) {
        int row = 0;
        MyConnection conObj = new MyConnection();
        Connection con = conObj.getConnection();

        try {
            PreparedStatement pstm = con.prepareStatement(
                "INSERT INTO timeslots (theater_id, start_time, end_time) VALUES (?, ?, ?)"
            );
            pstm.setInt(1, theaterId);
            pstm.setString(2, startTime);
            pstm.setString(3, endTime);
            row = pstm.executeUpdate();

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return row;
    }

    public ArrayList<Timeslot> getTimeslotsByTheater(int theaterId) {
        ArrayList<Timeslot> list = new ArrayList<>();
        MyConnection conObj = new MyConnection();
        Connection con = conObj.getConnection();

        try {
            PreparedStatement pstm = con.prepareStatement(
                "SELECT * FROM timeslots WHERE theater_id = ? ORDER BY start_time"
            );
            pstm.setInt(1, theaterId);
            ResultSet rs = pstm.executeQuery();

            while(rs.next()){
                Timeslot t = new Timeslot();
                t.setSlotId(rs.getInt("slot_id"));
                t.setStartTime(rs.getTime("start_time"));
                t.setEndTime(rs.getTime("end_time"));
                t.setTheaterId(rs.getInt("theater_id"));
                list.add(t);
            }

        } catch(SQLException e) {
            e.printStackTrace();
        }

        return list;
    }
    
    public boolean isTimeslotAvailable(int theaterId, String startTime, String endTime) {
        MyConnection conObj = new MyConnection();
        Connection con = conObj.getConnection();
        boolean available = false;

        try {
            PreparedStatement pstm = con.prepareStatement(
                "SELECT COUNT(*) FROM timeslots " +
                "WHERE theater_id = ? AND (" +
                "(start_time < ? AND end_time > ?) OR " +
                "(start_time < ? AND end_time > ?) OR " +
                "(start_time >= ? AND end_time <= ?))"
            );
            pstm.setInt(1, theaterId);
            pstm.setString(2, endTime);   
            pstm.setString(3, endTime);   
            pstm.setString(4, startTime); 
            pstm.setString(5, startTime); 
            pstm.setString(6, startTime); 
            pstm.setString(7, endTime);   

            ResultSet rs = pstm.executeQuery();
            if(rs.next()) {
                int count = rs.getInt(1);
                available = (count == 0);
            }
        } catch(SQLException e) {
            e.printStackTrace();
        }

        return available;
    }
    
    public ArrayList<Timeslot> getAvailableTimeslotsForMovie(int theaterId, int movieId, String startDate, String endDate) {
        ArrayList<Timeslot> list = new ArrayList<>();
        Connection con = new MyConnection().getConnection();
        try {
            PreparedStatement pstm = con.prepareStatement(
                "SELECT * FROM timeslots t " +
                "WHERE t.theater_id = ? " +
                "AND t.slot_id NOT IN (" +
                "   SELECT slot_id FROM showtimes WHERE theater_id = ? " +
                "   AND show_date BETWEEN ? AND ?" +
                ")"
            );
            pstm.setInt(1, theaterId);
            pstm.setInt(2, theaterId);
            pstm.setString(3, startDate);
            pstm.setString(4, endDate);
            ResultSet rs = pstm.executeQuery();
            while(rs.next()){
                Timeslot t = new Timeslot();
                t.setSlotId(rs.getInt("slot_id"));
                t.setStartTime(rs.getTime("start_time"));
                t.setEndTime(rs.getTime("end_time"));
                t.setTheaterId(rs.getInt("theater_id"));
                list.add(t);
            }
        } catch(SQLException e) {
            e.printStackTrace();
        }
        return list;
    }
    /////////
	
//	public int addTimeslot(int theaterId, String startTime, String endTime) {
//        int row = 0;
//        MyConnection conObj = new MyConnection();
//        Connection con = conObj.getConnection();
//
//        try {
//            PreparedStatement pstm = con.prepareStatement(
//                "INSERT INTO timeslots (theater_id, start_time, end_time) VALUES (?, ?, ?)"
//            );
//            pstm.setInt(1, theaterId);
//            pstm.setString(2, startTime);
//            pstm.setString(3, endTime);
//            row = pstm.executeUpdate();
//
//        } catch (SQLException e) {
//            e.printStackTrace();
//        }
//        return row;
//    }
//
//    public ArrayList<Timeslot> getTimeslotsByTheater(int theaterId) {
//        ArrayList<Timeslot> list = new ArrayList<>();
//        MyConnection conObj = new MyConnection();
//        Connection con = conObj.getConnection();
//
//        try {
//            PreparedStatement pstm = con.prepareStatement(
//                "SELECT * FROM timeslots WHERE theater_id = ? ORDER BY start_time"
//            );
//            pstm.setInt(1, theaterId);
//            ResultSet rs = pstm.executeQuery();
//
//            while(rs.next()){
//                Timeslot t = new Timeslot();
//                t.setSlotId(rs.getInt("slot_id"));
//                t.setStartTime(rs.getTime("start_time"));
//                t.setEndTime(rs.getTime("end_time"));
//                t.setTheaterId(rs.getInt("theater_id"));
//                list.add(t);
//            }
//
//        } catch(SQLException e) {
//            e.printStackTrace();
//        }
//
//        return list;
//    }
//    
//    public boolean isTimeslotAvailable(int theaterId, String startTime, String endTime) {
//        MyConnection conObj = new MyConnection();
//        Connection con = conObj.getConnection();
//        boolean available = false;
//
//        try {
//            PreparedStatement pstm = con.prepareStatement(
//                "SELECT COUNT(*) FROM timeslots " +
//                "WHERE theater_id = ? AND (" +
//                "(start_time < ? AND end_time > ?) OR " +
//                "(start_time < ? AND end_time > ?) OR " +
//                "(start_time >= ? AND end_time <= ?))"
//            );
//            pstm.setInt(1, theaterId);
//            pstm.setString(2, endTime);   
//            pstm.setString(3, endTime);   
//            pstm.setString(4, startTime); 
//            pstm.setString(5, startTime); 
//            pstm.setString(6, startTime); 
//            pstm.setString(7, endTime);   
//
//            ResultSet rs = pstm.executeQuery();
//            if(rs.next()) {
//                int count = rs.getInt(1);
//                available = (count == 0);
//            }
//        } catch(SQLException e) {
//            e.printStackTrace();
//        }
//
//        return available;
//    }
//    
//    public ArrayList<Timeslot> getAvailableTimeslotsForMovie(int theaterId, int movieId, String startDate, String endDate) {
//        ArrayList<Timeslot> list = new ArrayList<>();
//        Connection con = new MyConnection().getConnection();
//        try {
//            PreparedStatement pstm = con.prepareStatement(
//                "SELECT * FROM timeslots t " +
//                "WHERE t.theater_id = ? " +
//                "AND t.slot_id NOT IN (" +
//                "   SELECT slot_id FROM showtimes WHERE theater_id = ? " +
//                "   AND show_date BETWEEN ? AND ?" +
//                ")"
//            );
//            pstm.setInt(1, theaterId);
//            pstm.setInt(2, theaterId);
//            pstm.setString(3, startDate);
//            pstm.setString(4, endDate);
//            ResultSet rs = pstm.executeQuery();
//            while(rs.next()){
//                Timeslot t = new Timeslot();
//                t.setSlotId(rs.getInt("slot_id"));
//                t.setStartTime(rs.getTime("start_time"));
//                t.setEndTime(rs.getTime("end_time"));
//                t.setTheaterId(rs.getInt("theater_id"));
//                list.add(t);
//            }
//        } catch(SQLException e) {
//            e.printStackTrace();
//        }
//        return list;
//    }
      //////////////

//    public int addTimeslot(int theaterId, String startTime, String endTime) {
//        int row = 0;
//        MyConnection conObj = new MyConnection();
//        Connection con = conObj.getConnection();
//
//        try {
//            PreparedStatement pstm = con.prepareStatement(
//                "INSERT INTO timeslots (theater_id, start_time, end_time) VALUES (?, ?, ?)"
//            );
//            pstm.setInt(1, theaterId);
//            pstm.setString(2, startTime);
//            pstm.setString(3, endTime);
//            row = pstm.executeUpdate();
//
//        } catch (SQLException e) {
//            e.printStackTrace();
//        }
//        return row;
//    }

//    public ArrayList<Timeslot> getTimeslotsByTheater(int theaterId) {
//        ArrayList<Timeslot> list = new ArrayList<>();
//        MyConnection conObj = new MyConnection();
//        Connection con = conObj.getConnection();
//
//        try {
//            PreparedStatement pstm = con.prepareStatement(
//                "SELECT * FROM timeslots WHERE theater_id = ? ORDER BY start_time"
//            );
//            pstm.setInt(1, theaterId);
//            ResultSet rs = pstm.executeQuery();
//
//            while(rs.next()){
//                Timeslot t = new Timeslot();
//                t.setSlotId(rs.getInt("slot_id"));
//                t.setStartTime(rs.getTime("start_time"));
//                t.setEndTime(rs.getTime("end_time"));
//                t.setTheaterId(rs.getInt("theater_id"));
//                list.add(t);
//            }
//
//        } catch(SQLException e) {
//            e.printStackTrace();
//        }
//
//        return list;
//    }
//    
//    public boolean isTimeslotAvailable(int theaterId, String startTime, String endTime) {
//        MyConnection conObj = new MyConnection();
//        Connection con = conObj.getConnection();
//        boolean available = false;
//
//        try {
//            PreparedStatement pstm = con.prepareStatement(
//                "SELECT COUNT(*) FROM timeslots " +
//                "WHERE theater_id = ? AND (" +
//                "(start_time < ? AND end_time > ?) OR " +
//                "(start_time < ? AND end_time > ?) OR " +
//                "(start_time >= ? AND end_time <= ?))"
//            );
//            pstm.setInt(1, theaterId);
//            pstm.setString(2, endTime);   
//            pstm.setString(3, endTime);   
//            pstm.setString(4, startTime); 
//            pstm.setString(5, startTime); 
//            pstm.setString(6, startTime); 
//            pstm.setString(7, endTime);   
//
//            ResultSet rs = pstm.executeQuery();
//            if(rs.next()) {
//                int count = rs.getInt(1);
//                available = (count == 0);
//            }
//        } catch(SQLException e) {
//            e.printStackTrace();
//        }
//
//        return available;
//    }
//    
//    public ArrayList<Timeslot> getAvailableTimeslotsForMovie(int theaterId, int movieId, String startDate, String endDate) {
//        ArrayList<Timeslot> list = new ArrayList<>();
//        Connection con = new MyConnection().getConnection();
//        try {
//            PreparedStatement pstm = con.prepareStatement(
//                "SELECT * FROM timeslots t " +
//                "WHERE t.theater_id = ? " +
//                "AND t.slot_id NOT IN (" +
//                "   SELECT slot_id FROM showtimes WHERE theater_id = ? " +
//                "   AND show_date BETWEEN ? AND ?" +
//                ")"
//            );
//            pstm.setInt(1, theaterId);
//            pstm.setInt(2, theaterId);
//            pstm.setString(3, startDate);
//            pstm.setString(4, endDate);
//            ResultSet rs = pstm.executeQuery();
//            while(rs.next()){
//                Timeslot t = new Timeslot();
//                t.setSlotId(rs.getInt("slot_id"));
//                t.setStartTime(rs.getTime("start_time"));
//                t.setEndTime(rs.getTime("end_time"));
//                t.setTheaterId(rs.getInt("theater_id"));
//                list.add(t);
//            }
//        } catch(SQLException e) {
//            e.printStackTrace();
//        }
//        return list;
//    }
    public boolean updateTimeslot(int slotId, String startTime, String endTime) {
        boolean updated = false;
        MyConnection conObj = new MyConnection();
        Connection con = conObj.getConnection();

        try {
            PreparedStatement pstm = con.prepareStatement(
                "UPDATE timeslots SET start_time = ?, end_time = ? WHERE slot_id = ?"
            );
            pstm.setString(1, startTime);
            pstm.setString(2, endTime);
            pstm.setInt(3, slotId);

            int row = pstm.executeUpdate();
            updated = (row > 0);
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return updated;
    }

    public boolean deleteTimeslot(int slotId) {
        boolean deleted = false;
        MyConnection conObj = new MyConnection();
        Connection con = conObj.getConnection();

        try {
            PreparedStatement pstm = con.prepareStatement(
                "DELETE FROM timeslots WHERE slot_id = ?"
            );
            pstm.setInt(1, slotId);
            int row = pstm.executeUpdate();
            deleted = (row > 0);
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return deleted;
    }


}
