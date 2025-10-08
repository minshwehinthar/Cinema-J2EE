package com.demo.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

import com.demo.dao.BookingDao;
import com.demo.model.User;

/**
 * Servlet implementation class ApproveBookingServlet
 */
@WebServlet("/ApproveBookingServlet")
public class ApproveBookingServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public ApproveBookingServlet() {
        super();
        // TODO Auto-generated constructor stub
    }

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
	 */
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        doPost(request, response);
    }

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            int bookingId = Integer.parseInt(request.getParameter("bookingId"));
            BookingDao bookingDAO = new BookingDao();
            
            boolean success = bookingDAO.approveBooking(bookingId);
            
            if (success) {
                response.sendRedirect("adminBookings.jsp?success=Booking approved successfully");
            } else {
                response.sendRedirect("adminBookings.jsp?error=Failed to approve booking. Booking may not be in pending status.");
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("adminBookings.jsp?error=Error approving booking: " + e.getMessage());
        }
    }
}