package com.demo.dao;

import com.demo.model.Booking;
import com.demo.model.BookingDetails;
import com.demo.model.BookingSeat;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class BookingDao {

    // 1. Create new booking with pending status but seats marked as booked
    public int insertBooking(Booking booking) {
        int bookingId = 0;
        Connection conn = null;
        PreparedStatement ps = null;
        
        try {
            conn = MyConnection.getConnection();
            conn.setAutoCommit(false);
            
            // Insert booking with pending status
            String sql = "INSERT INTO bookings (user_id, showtime_id, total_price, status, booking_time, payment_method) "
                       + "VALUES (?, ?, ?, 'pending', ?, ?)";
            
            ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            ps.setInt(1, booking.getUserId());
            ps.setInt(2, booking.getShowtimeId());
            ps.setBigDecimal(3, booking.getTotalPrice());
            ps.setTimestamp(4, booking.getBookingTime());
            ps.setString(5, booking.getPaymentMethod());

            int affectedRows = ps.executeUpdate();
            if (affectedRows == 0) {
                throw new SQLException("Creating booking failed, no rows affected.");
            }

            // Get generated booking ID
            try (ResultSet generatedKeys = ps.getGeneratedKeys()) {
                if (generatedKeys.next()) {
                    bookingId = generatedKeys.getInt(1);
                } else {
                    throw new SQLException("Creating booking failed, no ID obtained.");
                }
            }
            ps.close();

            // Insert booking seats
            if (booking.getSelectedSeatIds() != null && !booking.getSelectedSeatIds().isEmpty()) {
                String seatSql = "INSERT INTO booking_seats (booking_id, seat_id) VALUES (?, ?)";
                ps = conn.prepareStatement(seatSql);
                
                for (int seatId : booking.getSelectedSeatIds()) {
                    ps.setInt(1, bookingId);
                    ps.setInt(2, seatId); // This is showtime_seats.id
                    ps.addBatch();
                }
                ps.executeBatch();
                ps.close();
                
                // Mark seats as 'booked' in showtime_seats
                String updateSeatSql = "UPDATE showtime_seats SET status = 'booked' WHERE id = ?";
                ps = conn.prepareStatement(updateSeatSql);
                
                for (int showtimeSeatId : booking.getSelectedSeatIds()) {
                    ps.setInt(1, showtimeSeatId);
                    ps.addBatch();
                }
                ps.executeBatch();
            }
            
            conn.commit();
            return bookingId;
            
        } catch (SQLException e) {
            try {
                if (conn != null) conn.rollback();
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
            e.printStackTrace();
            return 0;
        } finally {
            try {
                if (ps != null) ps.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }

    // 2. ADMIN APPROVES PENDING BOOKING - ADDED THIS METHOD
    public boolean approveBooking(int bookingId) {
        String sql = "UPDATE bookings SET status = 'confirmed' WHERE booking_id = ? AND status = 'pending'";
        
        try (Connection conn = MyConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, bookingId);
            int rowsAffected = ps.executeUpdate();
            
            if (rowsAffected > 0) {
                System.out.println("Booking " + bookingId + " approved successfully");
            } else {
                System.out.println("No booking found or booking is not pending: " + bookingId);
            }
            
            return rowsAffected > 0;
            
        } catch (SQLException e) {
            System.out.println("Error in approveBooking: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    // 3. FIXED: Admin cancels booking - PROPERLY UPDATES showtime_seats
    public boolean adminCancelBooking(int bookingId) {
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        
        try {
            conn = MyConnection.getConnection();
            conn.setAutoCommit(false);
            
            // Get booking details
            Booking booking = getBookingById(bookingId);
            if (booking == null) {
                System.out.println("Booking not found: " + bookingId);
                return false;
            }
            
            // Only allow cancellation of pending or confirmed bookings
            if (!"pending".equals(booking.getStatus()) && !"confirmed".equals(booking.getStatus())) {
                System.out.println("Cannot cancel booking - status is: " + booking.getStatus());
                return false;
            }
            
            System.out.println("Cancelling booking ID: " + bookingId + ", Showtime ID: " + booking.getShowtimeId());
            
            // Update booking status to cancelled
            String updateSql = "UPDATE bookings SET status = 'cancelled' WHERE booking_id = ? AND status IN ('pending', 'confirmed')";
            stmt = conn.prepareStatement(updateSql);
            stmt.setInt(1, bookingId);
            int rowsUpdated = stmt.executeUpdate();
            
            if (rowsUpdated == 0) {
                conn.rollback();
                System.out.println("No rows updated in bookings table");
                return false;
            }
            stmt.close();
            
            // FIXED: Get the showtime_seat IDs from booking_seats and update showtime_seats
            if (booking.getSelectedSeatIds() != null && !booking.getSelectedSeatIds().isEmpty()) {
                // First, get the actual showtime_seat IDs from booking_seats
                String getSeatIdsSql = "SELECT seat_id FROM booking_seats WHERE booking_id = ?";
                stmt = conn.prepareStatement(getSeatIdsSql);
                stmt.setInt(1, bookingId);
                rs = stmt.executeQuery();
                
                List<Integer> showtimeSeatIds = new ArrayList<>();
                while (rs.next()) {
                    showtimeSeatIds.add(rs.getInt("seat_id"));
                }
                rs.close();
                stmt.close();
                
                System.out.println("Found " + showtimeSeatIds.size() + " showtime_seat IDs to release");
                
                // Now update showtime_seats using the actual IDs
                String releaseSeatsSql = "UPDATE showtime_seats SET status = 'available' WHERE id = ?";
                stmt = conn.prepareStatement(releaseSeatsSql);
                
                for (Integer showtimeSeatId : showtimeSeatIds) {
                    stmt.setInt(1, showtimeSeatId);
                    stmt.addBatch();
                    System.out.println("Releasing showtime_seat ID: " + showtimeSeatId);
                }
                
                int[] batchResults = stmt.executeBatch();
                System.out.println("Seats released in adminCancelBooking: " + batchResults.length + " seats");
                
                // Verify the update
                for (int i = 0; i < batchResults.length; i++) {
                    if (batchResults[i] == 0) {
                        System.out.println("Warning: Showtime seat ID " + showtimeSeatIds.get(i) + " was not updated");
                    }
                }
            } else {
                System.out.println("No seats to release for booking: " + bookingId);
            }
            
            conn.commit();
            System.out.println("Admin cancellation completed successfully for booking: " + bookingId);
            return true;
            
        } catch (SQLException e) {
            System.out.println("Error in adminCancelBooking: " + e.getMessage());
            e.printStackTrace();
            try {
                if (conn != null) conn.rollback();
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
            return false;
        } finally {
            try {
                if (rs != null) rs.close();
                if (stmt != null) stmt.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }

    // 4. FIXED: Delete cancelled booking - PROPERLY UPDATES showtime_seats
    public boolean deleteBooking(int bookingId) {
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        
        try {
            conn = MyConnection.getConnection();
            conn.setAutoCommit(false);
            
            // Get booking details first
            Booking booking = getBookingById(bookingId);
            if (booking == null) {
                System.out.println("Booking not found: " + bookingId);
                return false;
            }
            
            // ONLY allow deletion if booking is cancelled
            if (!"cancelled".equals(booking.getStatus())) {
                System.out.println("Cannot delete booking - status is: " + booking.getStatus());
                return false;
            }
            
            System.out.println("Deleting cancelled booking ID: " + bookingId);
            
            // FIXED: Get the showtime_seat IDs from booking_seats before deleting them
            String getSeatIdsSql = "SELECT seat_id FROM booking_seats WHERE booking_id = ?";
            stmt = conn.prepareStatement(getSeatIdsSql);
            stmt.setInt(1, bookingId);
            rs = stmt.executeQuery();
            
            List<Integer> showtimeSeatIds = new ArrayList<>();
            while (rs.next()) {
                showtimeSeatIds.add(rs.getInt("seat_id"));
            }
            rs.close();
            stmt.close();
            
            System.out.println("Found " + showtimeSeatIds.size() + " showtime_seat IDs to release");
            
            // Release seats in showtime_seats
            if (!showtimeSeatIds.isEmpty()) {
                String releaseSeatsSql = "UPDATE showtime_seats SET status = 'available' WHERE id = ?";
                stmt = conn.prepareStatement(releaseSeatsSql);
                
                for (Integer showtimeSeatId : showtimeSeatIds) {
                    stmt.setInt(1, showtimeSeatId);
                    stmt.addBatch();
                    System.out.println("Releasing showtime_seat ID: " + showtimeSeatId);
                }
                
                int[] batchResults = stmt.executeBatch();
                System.out.println("Seats released in deleteBooking: " + batchResults.length + " seats");
                stmt.close();
            }
            
            // Delete from booking_seats
            String deleteSeatsSql = "DELETE FROM booking_seats WHERE booking_id = ?";
            stmt = conn.prepareStatement(deleteSeatsSql);
            stmt.setInt(1, bookingId);
            int seatsDeleted = stmt.executeUpdate();
            System.out.println("Booking seats deleted: " + seatsDeleted);
            stmt.close();
            
            // Delete the booking
            String deleteSql = "DELETE FROM bookings WHERE booking_id = ? AND status = 'cancelled'";
            stmt = conn.prepareStatement(deleteSql);
            stmt.setInt(1, bookingId);
            int rowsAffected = stmt.executeUpdate();
            
            System.out.println("Booking deleted: " + rowsAffected);
            
            conn.commit();
            return rowsAffected > 0;
            
        } catch (SQLException e) {
            System.out.println("Error in deleteBooking: " + e.getMessage());
            e.printStackTrace();
            try {
                if (conn != null) conn.rollback();
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
            return false;
        } finally {
            try {
                if (rs != null) rs.close();
                if (stmt != null) stmt.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }

    // 5. Get all bookings for admin
    public List<Booking> getAllBookings() {
        List<Booking> bookings = new ArrayList<>();
        String sql = "SELECT * FROM bookings ORDER BY booking_time DESC";
        
        try (Connection conn = MyConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                Booking booking = extractBookingFromResultSet(rs, conn);
                bookings.add(booking);
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return bookings;
    }

    // 6. Get bookings by user ID
    public List<Booking> getBookingsByUserId(int userId) {
        List<Booking> bookings = new ArrayList<>();
        String sql = "SELECT * FROM bookings WHERE user_id = ? ORDER BY booking_time DESC";
        
        try (Connection conn = MyConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                Booking booking = extractBookingFromResultSet(rs, conn);
                bookings.add(booking);
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return bookings;
    }

    // 7. Get booking by ID
    public Booking getBookingById(int bookingId) throws SQLException {
        Booking booking = null;
        String sqlBooking = "SELECT * FROM bookings WHERE booking_id = ?";

        try (Connection conn = MyConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sqlBooking)) {

            ps.setInt(1, bookingId);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                booking = new Booking();
                booking.setBookingId(rs.getInt("booking_id"));
                booking.setUserId(rs.getInt("user_id"));
                booking.setShowtimeId(rs.getInt("showtime_id"));
                booking.setTotalPrice(rs.getBigDecimal("total_price"));
                booking.setStatus(rs.getString("status"));
                booking.setBookingTime(rs.getTimestamp("booking_time"));
                booking.setPaymentMethod(rs.getString("payment_method"));

                // Get booked seat IDs (these are showtime_seats.id values)
                List<Integer> seatIds = getSeatIdsForBooking(conn, booking.getBookingId());
                booking.setSelectedSeatIds(seatIds);
            }
        }
        return booking;
    }

    // 8. DEBUG METHOD: Check seat status in showtime_seats
    public void debugSeatStatus(int bookingId) {
        String sql = "SELECT bs.seat_id, ss.status, ss.showtime_id, ss.seat_id as actual_seat_id " +
                     "FROM booking_seats bs " +
                     "JOIN showtime_seats ss ON bs.seat_id = ss.id " +
                     "WHERE bs.booking_id = ?";
        
        try (Connection conn = MyConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, bookingId);
            ResultSet rs = ps.executeQuery();
            
            System.out.println("=== DEBUG Seat Status for Booking " + bookingId + " ===");
            while (rs.next()) {
                System.out.println("Showtime_Seat ID: " + rs.getInt("seat_id") + 
                                 ", Status: " + rs.getString("status") +
                                 ", Showtime ID: " + rs.getInt("showtime_id") +
                                 ", Actual Seat ID: " + rs.getInt("actual_seat_id"));
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    // Helper methods
    private Booking extractBookingFromResultSet(ResultSet rs, Connection conn) throws SQLException {
        Booking booking = new Booking();
        booking.setBookingId(rs.getInt("booking_id"));
        booking.setUserId(rs.getInt("user_id"));
        booking.setShowtimeId(rs.getInt("showtime_id"));
        booking.setTotalPrice(rs.getBigDecimal("total_price"));
        booking.setStatus(rs.getString("status"));
        booking.setBookingTime(rs.getTimestamp("booking_time"));
        booking.setPaymentMethod(rs.getString("payment_method"));
        
        List<Integer> seatIds = getSeatIdsForBooking(conn, booking.getBookingId());
        booking.setSelectedSeatIds(seatIds);
        
        return booking;
    }
    
    private List<Integer> getSeatIdsForBooking(Connection conn, int bookingId) throws SQLException {
        List<Integer> seatIds = new ArrayList<>();
        String sql = "SELECT seat_id FROM booking_seats WHERE booking_id = ?";
        
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, bookingId);
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                seatIds.add(rs.getInt("seat_id"));
            }
        }
        return seatIds;
    }
    

	// Fetch booking details for voucher
    public BookingDetails getBookingDetails(int bookingId) {
        BookingDetails details = new BookingDetails();

        try (Connection conn = MyConnection.getConnection()) {
            // Basic booking info
            String bookingSql = "SELECT b.booking_id, b.booking_time, b.total_price, " +
                    "s.show_date, s.movie_id, s.theater_id, s.slot_id " +
                    "FROM bookings b " +
                    "JOIN showtimes s ON b.showtime_id = s.showtime_id " +
                    "WHERE b.booking_id = ?";

            PreparedStatement stmt = conn.prepareStatement(bookingSql);
            stmt.setInt(1, bookingId);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                details.setBookingId(rs.getInt("booking_id"));
                details.setBookingDate(rs.getTimestamp("booking_time"));
                details.setTotalPrice(rs.getBigDecimal("total_price"));
                details.setShowDate(rs.getDate("show_date"));

                int movieId = rs.getInt("movie_id");
                int theaterId = rs.getInt("theater_id");
                int slotId = rs.getInt("slot_id");

                // Movie title
                String movieSql = "SELECT title FROM movies WHERE movie_id = ?";
                stmt = conn.prepareStatement(movieSql);
                stmt.setInt(1, movieId);
                ResultSet movieRs = stmt.executeQuery();
                if (movieRs.next()) details.setMovieTitle(movieRs.getString("title"));

                // Theater name
                String theaterSql = "SELECT name FROM theater WHERE theater_id = ?";
                stmt = conn.prepareStatement(theaterSql);
                stmt.setInt(1, theaterId);
                ResultSet theaterRs = stmt.executeQuery();
                if (theaterRs.next()) details.setTheaterName(theaterRs.getString("name"));

                // Timeslot
                String slotSql = "SELECT start_time, end_time FROM timeslots WHERE slot_id = ?";
                stmt = conn.prepareStatement(slotSql);
                stmt.setInt(1, slotId);
                ResultSet slotRs = stmt.executeQuery();
                if (slotRs.next()) {
                    details.setShowTime(slotRs.getString("start_time") + " - " + slotRs.getString("end_time"));
                }

                // Seats
                String seatSql = "SELECT s.seat_number " +
                        "FROM booking_seats bs " +
                        "JOIN seats s ON bs.seat_id = s.seat_id " +
                        "WHERE bs.booking_id = ? " +
                        "ORDER BY s.seat_number";
                stmt = conn.prepareStatement(seatSql);
                stmt.setInt(1, bookingId);
                ResultSet seatRs = stmt.executeQuery();
                StringBuilder seatNumbers = new StringBuilder();
                int seatCount = 0;
                while (seatRs.next()) {
                    if (seatCount > 0) seatNumbers.append(", ");
                    seatNumbers.append(seatRs.getString("seat_number"));
                    seatCount++;
                }

                details.setSeatNumbers(seatNumbers.toString());
                details.setTotalSeats(seatCount);

                return details;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return null;
    }
    
    // Insert booking_seats & update showtime_seats
    public void bookSeats(List<BookingSeat> bookingSeats, int showtimeId) {
        String insertSQL = "INSERT INTO booking_seats (booking_id, seat_id) VALUES (?, ?)";
        String updateSQL = "UPDATE showtime_seats SET status='booked' WHERE showtime_id=? AND seat_id=?";

        Connection conn = null;
        PreparedStatement psInsert = null;
        PreparedStatement psUpdate = null;

        try {
            conn = MyConnection.getConnection();
            conn.setAutoCommit(false); // start transaction

            psInsert = conn.prepareStatement(insertSQL);
            psUpdate = conn.prepareStatement(updateSQL);

            for (BookingSeat bs : bookingSeats) {
                // Insert into booking_seats
                psInsert.setInt(1, bs.getBookingId());
                psInsert.setInt(2, bs.getSeatId());
                psInsert.addBatch();

                // Update showtime_seats
                psUpdate.setInt(1, showtimeId);
                psUpdate.setInt(2, bs.getSeatId());
                psUpdate.addBatch();
            }

            psInsert.executeBatch();
            psUpdate.executeBatch();

            conn.commit(); // commit transaction
        } catch (SQLException e) {
            e.printStackTrace();
            try { if (conn != null) conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
        } finally {
            try {
                if (psInsert != null) psInsert.close();
                if (psUpdate != null) psUpdate.close();
                if (conn != null) conn.setAutoCommit(true);
                if (conn != null) conn.close();
            } catch (SQLException e) { e.printStackTrace(); }
        }
    }
    
    public boolean updateBookingStatus(int bookingId, String status) {
        String sql = "UPDATE bookings SET status = ? WHERE booking_id = ?";
        try (Connection conn = MyConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, status);
            stmt.setInt(2, bookingId);
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
    
 
    public List<Booking> getBookingsByTheaterId(int theaterId) {
        List<Booking> bookings = new ArrayList<>();
        String sql = "SELECT b.* FROM bookings b " +
                     "JOIN showtimes s ON b.showtime_id = s.showtime_id " +
                     "WHERE s.theater_id = ? " +
                     "ORDER BY b.booking_time DESC";
        
        try (Connection conn = MyConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, theaterId);
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                Booking booking = extractBookingFromResultSet(rs, conn);
                bookings.add(booking);
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return bookings;
    }

    // Add this method to get booking details with theater info
    public Booking getBookingWithTheaterInfo(int bookingId) throws SQLException {
        Booking booking = null;
        String sql = "SELECT b.*, s.theater_id, t.name as theater_name " +
                     "FROM bookings b " +
                     "JOIN showtimes s ON b.showtime_id = s.showtime_id " +
                     "LEFT JOIN theater t ON s.theater_id = t.theater_id " +
                     "WHERE b.booking_id = ?";

        try (Connection conn = MyConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, bookingId);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                booking = extractBookingFromResultSet(rs, conn);
                // You can extend Booking model to include theater info if needed
            }
        }
        return booking;
    }
 // Add this method to your BookingDao class
    public int getTheaterIdByBookingId(int bookingId) {
        int theaterId = 0;
        String sql = "SELECT s.theater_id FROM bookings b " +
                     "JOIN showtimes s ON b.showtime_id = s.showtime_id " +
                     "WHERE b.booking_id = ?";
        
        try (Connection conn = MyConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, bookingId);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                theaterId = rs.getInt("theater_id");
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return theaterId;
    }

 
}