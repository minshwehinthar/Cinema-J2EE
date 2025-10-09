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

@WebServlet("/AdminCancelBookingServlet")
public class AdminCancelBookingServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        doPost(request, response);
    }

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
            UserDAO userDAO = new UserDAO();
            
            // Get booking details before cancellation
            Booking booking = bookingDAO.getBookingById(bookingId);
            if (booking == null) {
                response.sendRedirect("adminBookings.jsp?error=Booking not found");
                return;
            }
            
            // Get customer details
            User customer = userDAO.getUserById(booking.getUserId());
            
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
                // Send cancellation email to customer
                if (customer != null && customer.getEmail() != null) {
                    String subject = "Booking Cancelled - CINEZY Cinema";
                    String body = String.format(
                        "Dear %s,\n\n" +
                        "Your booking (#%d) has been cancelled by the administrator.\n\n" +
                        "Booking Details:\n" +
                        "- Booking ID: %d\n" +
                        "- Status: Cancelled\n" +
                        "- Total Amount: MMK %s\n\n" +
                        "If you have any questions or believe this was done in error, please contact our support team.\n\n" +
                        "Best regards,\nCINEZY Cinema Team",
                        customer.getName(), 
                        bookingId,
                        bookingId,
                        booking.getTotalPrice() != null ? booking.getTotalPrice().toString() : "N/A"
                    );
                    
                    boolean emailSent = EmailUtil.sendEmail(customer.getEmail(), subject, body);
                    
                    if (emailSent) {
                        System.out.println("✅ Cancellation email sent to: " + customer.getEmail());
                    } else {
                        System.out.println("⚠️ Failed to send cancellation email to: " + customer.getEmail());
                    }
                }
                
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