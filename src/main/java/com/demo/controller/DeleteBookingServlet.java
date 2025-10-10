package com.demo.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import com.demo.dao.BookingDao;
import com.demo.dao.UserDAO;
import com.demo.model.User;
import com.demo.model.Booking;
import com.demo.util.EmailUtil;

@WebServlet("/DeleteBookingServlet")
public class DeleteBookingServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        doPost(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            int bookingId = Integer.parseInt(request.getParameter("bookingId"));
            BookingDao bookingDAO = new BookingDao();
            UserDAO userDAO = new UserDAO();
            
            // Get booking details before deletion
            Booking booking = bookingDAO.getBookingById(bookingId);
            if (booking == null) {
                response.sendRedirect("adminBookings.jsp?error=Booking not found");
                return;
            }
            
            // Get customer details
            User customer = userDAO.getUserById(booking.getUserId());
            
            // Debug: Check seat status before deletion
            System.out.println("=== BEFORE DELETION ===");
            bookingDAO.debugSeatStatus(bookingId);
            
            boolean success = bookingDAO.deleteBooking(bookingId);
            
            if (success) {
                // Send deletion notification email to customer (if needed)
                // Note: Usually we don't email when deleting cancelled bookings, but you can enable if needed
                boolean sendDeletionEmail = false; // Set to true if you want to notify about permanent deletion
                
                if (sendDeletionEmail && customer != null && customer.getEmail() != null) {
                    String subject = "Booking Permanently Deleted - CINEZY Cinema";
                    String body = String.format(
                        "Dear %s,\n\n" +
                        "Your cancelled booking (#%d) has been permanently deleted from our system as per our data retention policy.\n\n" +
                        "This is an informational email. No action is required from your side.\n\n" +
                        "Best regards,\nCINEZY Cinema Team",
                        customer.getName(), 
                        bookingId
                    );
                    
                    boolean emailSent = EmailUtil.sendEmail(customer.getEmail(), subject, body);
                    
                    if (emailSent) {
                        System.out.println("✅ Deletion notification email sent to: " + customer.getEmail());
                    } else {
                        System.out.println("⚠️ Failed to send deletion notification email to: " + customer.getEmail());
                    }
                }
                
                response.sendRedirect("adminBookings.jsp?success=Booking deleted successfully and seats released");
            } else {
                response.sendRedirect("adminBookings.jsp?error=Failed to delete booking. Make sure booking is cancelled.");
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("adminBookings.jsp?error=Error deleting booking: " + e.getMessage());
        }
    }
}