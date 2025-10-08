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
 * Servlet implementation class AdminCancelBookingServlet
 */
@WebServlet("/AdminCancelBookingServlet")
public class AdminCancelBookingServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public AdminCancelBookingServlet() {
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
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        
        if (user == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        try {
            int bookingId = Integer.parseInt(request.getParameter("bookingId"));
            BookingDao bookingDAO = new BookingDao();
            
            // Debug: Check seat status before cancellation
            System.out.println("=== BEFORE CANCELLATION ===");
            bookingDAO.debugSeatStatus(bookingId);
            
            boolean success = bookingDAO.adminCancelBooking(bookingId);
            
            // Debug: Check seat status after cancellation
            System.out.println("=== AFTER CANCELLATION ===");
            bookingDAO.debugSeatStatus(bookingId);
            
            String redirectPage;
            String role = user.getRole();
            
            // Determine redirect page based on user role
            if ("admin".equals(role) || "theateradmin".equals(role)) {
                redirectPage = "adminBookings.jsp";
            } else {
                redirectPage = "myBookings.jsp";
            }
            
            if (success) {
                response.sendRedirect(redirectPage + "?success=Booking cancelled successfully and seats released");
            } else {
                response.sendRedirect(redirectPage + "?error=Failed to cancel booking. Please try again.");
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            String role = user.getRole();
            String redirectPage = ("admin".equals(role) || "theateradmin".equals(role)) ? "adminBookings.jsp" : "myBookings.jsp";
            response.sendRedirect(redirectPage + "?error=Error cancelling booking: " + e.getMessage());
        }
    }
}