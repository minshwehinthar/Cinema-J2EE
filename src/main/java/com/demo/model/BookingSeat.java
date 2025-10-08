package com.demo.model;

public class BookingSeat {
	private int id; // auto-increment
	private int bookingId; // corresponds to booking_id
	private int seatId; // corresponds to seat_id

	// Getters & setters
	public int getId() {
		return id;
	}

	public void setId(int id) {
		this.id = id;
	}

	public int getBookingId() {
		return bookingId;
	}

	public void setBookingId(int bookingId) {
		this.bookingId = bookingId;
	}

	public int getSeatId() {
		return seatId;
	}

	public void setSeatId(int seatId) {
		this.seatId = seatId;
	}
}