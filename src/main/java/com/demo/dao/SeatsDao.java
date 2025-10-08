package com.demo.dao;

import java.sql.*;
import java.util.*;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

import com.demo.model.Seat;
import com.demo.model.SeatPrice;
import com.demo.model.BookingSeat;
import com.demo.model.ShowtimeSeat;

public class SeatsDao {

    // ✅ Add new seats for a specific theater and seat type
    public int addSeatsForType(int theaterId, int startRowIndex, int numRows, int seatsPerRow, int priceId, boolean coupleSeats) {
        int lastRowIndexUsed = startRowIndex;
        String sql = "INSERT INTO seats (theater_id, seat_number, price_id) VALUES (?, ?, ?)";

        try (Connection con = MyConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            for (int r = 0; r < numRows; r++) {
                char rowLetter = (char) ('A' + startRowIndex + r);
                int cols = coupleSeats ? seatsPerRow / 2 : seatsPerRow;

                for (int c = 1; c <= cols; c++) {
                    String seatNumber = rowLetter + String.valueOf(c);
                    ps.setInt(1, theaterId);
                    ps.setString(2, seatNumber);
                    ps.setInt(3, priceId);
                    ps.addBatch();
                }

                lastRowIndexUsed = startRowIndex + r;
            }

            ps.executeBatch();
            return lastRowIndexUsed + 1;

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return startRowIndex;
    }

    // ✅ Get all seats for a theater
    public List<Seat> getSeatsByTheater(int theaterId) {
        List<Seat> seats = new ArrayList<>();
        String sql = """
            SELECT s.seat_id, s.theater_id, s.seat_number, s.price_id,
                   sp.seat_type, sp.price
            FROM seats s
            LEFT JOIN seatprice sp ON s.price_id = sp.price_id
            WHERE s.theater_id = ?
            ORDER BY s.seat_number
        """;

        try (Connection con = MyConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, theaterId);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                Seat seat = new Seat();
                seat.setSeatId(rs.getInt("seat_id"));
                seat.setTheaterId(rs.getInt("theater_id"));
                seat.setSeatNumber(rs.getString("seat_number"));
                seat.setPriceId(rs.getInt("price_id"));
                seat.setSeatType(rs.getString("seat_type"));
                seat.setPrice(rs.getBigDecimal("price"));
                seats.add(seat);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return seats;
    }

    // ✅ Delete all seats for a theater
    public boolean deleteSeatsByTheater(int theaterId) {
        String sql = "DELETE FROM seats WHERE theater_id = ?";
        try (Connection con = MyConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, theaterId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // ✅ Insert a list of seats (bulk insert)
    public void insertSeats(List<Seat> seats) throws SQLException {
        String sql = "INSERT INTO seats (theater_id, seat_number, price_id) VALUES (?, ?, ?)";
        try (Connection con = MyConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            for (Seat seat : seats) {
                ps.setInt(1, seat.getTheaterId());
                ps.setString(2, seat.getSeatNumber());
                ps.setInt(3, seat.getPriceId());
                ps.addBatch();
            }

            ps.executeBatch();
        }
    }

    // ✅ Get one seat by ID
    public Seat getSeatById(int seatId) {
        String sql = """
            SELECT s.*, sp.seat_type, sp.price
            FROM seats s
            LEFT JOIN seatprice sp ON s.price_id = sp.price_id
            WHERE s.seat_id = ?
        """;

        try (Connection con = MyConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, seatId);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                Seat seat = new Seat();
                seat.setSeatId(rs.getInt("seat_id"));
                seat.setTheaterId(rs.getInt("theater_id"));
                seat.setSeatNumber(rs.getString("seat_number"));
                seat.setPriceId(rs.getInt("price_id"));
                seat.setSeatType(rs.getString("seat_type"));
                seat.setPrice(rs.getBigDecimal("price"));
                return seat;
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return null;
    }

    // ✅ Update seat price type
    public boolean updateSeatPriceType(int seatId, int priceId) {
        String sql = "UPDATE seats SET price_id = ? WHERE seat_id = ?";
        try (Connection con = MyConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, priceId);
            ps.setInt(2, seatId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    //////////////////
    ///
    public List<ShowtimeSeat> getSeatsByShowtime(int showtimeId) {
		List<ShowtimeSeat> list = new ArrayList<>();

		String sql = "SELECT ss.id AS showtime_seat_id, ss.status, "
				+ "s.seat_id, s.seat_number, s.theater_id, sp.seat_type, sp.price " + "FROM showtime_seats ss "
				+ "JOIN seats s ON ss.seat_id = s.seat_id " + "JOIN seatprice sp ON s.price_id = sp.price_id "
				+ "WHERE ss.showtime_id = ? " + "ORDER BY s.seat_number";

		try (Connection con = MyConnection.getConnection(); PreparedStatement pst = con.prepareStatement(sql)) {

			pst.setInt(1, showtimeId);
			ResultSet rs = pst.executeQuery();

			while (rs.next()) {
				// Seat object
				Seat seat = new Seat();
				seat.setSeatId(rs.getInt("seat_id"));
				seat.setTheaterId(rs.getInt("theater_id"));
				seat.setSeatNumber(rs.getString("seat_number"));
				seat.setSeatType(rs.getString("seat_type"));
				seat.setPrice(rs.getBigDecimal("price")); // get from seatprice table

				// ShowtimeSeat object
				ShowtimeSeat ss = new ShowtimeSeat();
				ss.setId(rs.getInt("showtime_seat_id"));
				ss.setShowtimeId(showtimeId);
				ss.setSeatId(seat.getSeatId());
				ss.setStatus(rs.getString("status"));
				ss.setSeat(seat);

				list.add(ss);
			}

		} catch (Exception e) {
			e.printStackTrace();
		}

		return list;
	}

	public void markSeatBooked(int showtimeSeatId) {
		String sql = "UPDATE showtime_seats SET status = 'booked' WHERE id = ?";

		try (Connection conn = MyConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

			ps.setInt(1, showtimeSeatId);
			ps.executeUpdate();

		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	// Optional: get all seats for a theater (not showtime-specific)
//	public List<Seat> getSeatsByTheater(int theaterId) {
//		List<Seat> list = new ArrayList<>();
//		String sql = "SELECT s.seat_id, s.seat_number, sp.seat_type, sp.price " + "FROM seats s "
//				+ "JOIN seatprice sp ON s.price_id = sp.price_id " + "WHERE s.theater_id = ? "
//				+ "ORDER BY s.seat_number";
//
//		try (Connection con = MyConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
//
//			ps.setInt(1, theaterId);
//			ResultSet rs = ps.executeQuery();
//
//			while (rs.next()) {
//				Seat seat = new Seat();
//				seat.setSeatId(rs.getInt("seat_id"));
//				seat.setSeatNumber(rs.getString("seat_number"));
//				seat.setSeatType(rs.getString("seat_type"));
//				seat.setPrice(rs.getBigDecimal("price"));
//				list.add(seat);
//			}
//
//		} catch (SQLException e) {
//			e.printStackTrace();
//		}
//
//		return list;
//	}

	public void addSeatsForType(int theaterId, int rows, int startCol, int endCol, int priceId) {
		String sql = "INSERT INTO seats (theater_id, seat_number, price_id) VALUES (?, ?, ?)";
		try (Connection con = MyConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

			for (int r = 0; r < rows; r++) {
				for (int c = startCol; c <= endCol; c++) {
					String seatNumber = (char) ('A' + r) + String.valueOf(c); // Example: A1, A2...
					ps.setInt(1, theaterId);
					ps.setString(2, seatNumber);
					ps.setInt(3, priceId);
					ps.addBatch();
				}
			}
			ps.executeBatch();

		} catch (SQLException e) {
			e.printStackTrace();
		}
	}

	public void createShowtimeSeats(int showtimeId, List<Integer> seatIds) {
		String sql = "INSERT INTO showtime_seats (showtime_id, seat_id, status) VALUES (?, ?, 'available')";
		try (Connection con = MyConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

			for (int seatId : seatIds) {
				ps.setInt(1, showtimeId);
				ps.setInt(2, seatId);
				ps.addBatch();
			}
			ps.executeBatch();
		} catch (SQLException e) {
			e.printStackTrace();
		}
	}

	public void initializeShowtimeSeats(int showtimeId, int theaterId) {
		String selectSeatsQuery = "SELECT seat_id FROM seats WHERE theater_id = ?";
		String insertShowtimeSeatQuery = "INSERT INTO showtime_seats (showtime_id, seat_id, status) VALUES (?, ?, 'available')";

		try (Connection conn = MyConnection.getConnection();
				PreparedStatement selectStmt = conn.prepareStatement(selectSeatsQuery);
				PreparedStatement insertStmt = conn.prepareStatement(insertShowtimeSeatQuery)) {

			selectStmt.setInt(1, theaterId);
			ResultSet rs = selectStmt.executeQuery();

			while (rs.next()) {
				int seatId = rs.getInt("seat_id");
				insertStmt.setInt(1, showtimeId);
				insertStmt.setInt(2, seatId);
				insertStmt.addBatch();
			}

			insertStmt.executeBatch();

			System.out.println("✅ Showtime seats initialized for showtime ID: " + showtimeId);

		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	
	public List<Seat> getSeatsByShowtimeSeatIds(List<Integer> showtimeSeatIds) {
	    List<Seat> seats = new ArrayList<>();
	    if (showtimeSeatIds == null || showtimeSeatIds.isEmpty()) return seats;

	    StringBuilder sb = new StringBuilder("SELECT s.seat_id, s.seat_number, s.theater_id, sp.price_id, sp.price, sp.seat_type " +
	                                         "FROM showtime_seats ss " +
	                                         "JOIN seats s ON ss.seat_id = s.seat_id " +
	                                         "JOIN seatprice sp ON s.price_id = sp.price_id " +
	                                         "WHERE ss.id IN (");
	    for (int i = 0; i < showtimeSeatIds.size(); i++) {
	        if (i > 0) sb.append(",");
	        sb.append("?");
	    }
	    sb.append(")");

	    try (Connection conn = MyConnection.getConnection();
	         PreparedStatement ps = conn.prepareStatement(sb.toString())) {

	        for (int i = 0; i < showtimeSeatIds.size(); i++) {
	            ps.setInt(i + 1, showtimeSeatIds.get(i));
	        }

	        ResultSet rs = ps.executeQuery();
	        while (rs.next()) {
	            Seat seat = new Seat();
	            seat.setSeatId(rs.getInt("seat_id")); // This is the actual seat_id from seats table
	            seat.setSeatNumber(rs.getString("seat_number"));
	            seat.setSeatType(rs.getString("seat_type"));
	            seat.setTheaterId(rs.getInt("theater_id"));
	            seat.setPriceId(rs.getInt("price_id"));
	            seat.setPrice(rs.getBigDecimal("price"));
	            seats.add(seat);
	        }

	    } catch (SQLException e) {
	        e.printStackTrace();
	    }

	    return seats;
	}
	
	public void addSeatsForTheater(int theaterId, int normalRows, int vipRows, int coupleRows, int seatsPerRow,
			int coupleSeats, int normalPriceId, int vipPriceId, int couplePriceId) {

		char rowLetter = 'A'; // Start from row A

		try (Connection con = MyConnection.getConnection()) {
			String sql = "INSERT INTO seats (theater_id, seat_number, price_id) VALUES (?, ?, ?)";
			PreparedStatement ps = con.prepareStatement(sql);

// --- Normal seats ---
			for (int r = 0; r < normalRows; r++) {
				for (int s = 1; s <= seatsPerRow; s++) {
					String seatNumber = rowLetter + String.valueOf(s);
					ps.setInt(1, theaterId);
					ps.setString(2, seatNumber);
					ps.setInt(3, normalPriceId);
					ps.addBatch();
				}
				rowLetter++;
			}

// --- VIP seats ---
			for (int r = 0; r < vipRows; r++) {
				for (int s = 1; s <= seatsPerRow; s++) {
					String seatNumber = rowLetter + String.valueOf(s);
					ps.setInt(1, theaterId);
					ps.setString(2, seatNumber);
					ps.setInt(3, vipPriceId);
					ps.addBatch();
				}
				rowLetter++;
			}

// --- Couple seats (logical count) ---
			for (int r = 0; r < coupleRows; r++) {
				for (int s = 1; s <= coupleSeats; s++) {
					String seatNumber = rowLetter + String.valueOf(s);
					ps.setInt(1, theaterId);
					ps.setString(2, seatNumber);
					ps.setInt(3, couplePriceId);
					ps.addBatch();
				}
				rowLetter++;
			}

			ps.executeBatch();
			ps.close();
			System.out.println("Seats added successfully for theater " + theaterId);

		} catch (Exception e) {
			e.printStackTrace();
		}
	}
	
	 

 // Insert booked seats into booking_seats
    public void insertBookingSeats(List<BookingSeat> bookingSeats) throws SQLException {
        String insertSQL = "INSERT INTO booking_seats (booking_id, seat_id) VALUES (?, ?)";
        try (Connection conn = MyConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(insertSQL)) {

            for (BookingSeat bs : bookingSeats) {
                ps.setInt(1, bs.getBookingId());
                ps.setInt(2, bs.getSeatId());
                ps.addBatch();
            }
            ps.executeBatch();
        }
    }
    
    public void updateSeatsStatusById(List<Integer> showtimeSeatIds) throws SQLException {
        String sql = "UPDATE showtime_seats SET status='booked' WHERE id=?";
        try (Connection conn = MyConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            for (int id : showtimeSeatIds) {
                ps.setInt(1, id);
                ps.addBatch();
            }
            ps.executeBatch();
        }
    }
    
 // Check if a showtime_seats row (by id) is already booked
    public boolean isSeatBookedById(int showtimeSeatId) throws SQLException {
        String sql = "SELECT status FROM showtime_seats WHERE id = ?";
        try (Connection conn = MyConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, showtimeSeatId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    String status = rs.getString("status");
                    return "booked".equalsIgnoreCase(status);
                } else {
                    // Row not found — treat as not booked
                    return false;
                }
            }
        }
    }
}
