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

@WebServlet("/ApproveBookingServlet")
public class ApproveBookingServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        doPost(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            int bookingId = Integer.parseInt(request.getParameter("bookingId"));
            BookingDao bookingDAO = new BookingDao();
            UserDAO userDAO = new UserDAO();
            
            // Get booking details before approval
            Booking booking = bookingDAO.getBookingById(bookingId);
            if (booking == null) {
                response.sendRedirect("adminBookings.jsp?error=Booking not found");
                return;
            }
            
            // Get customer details
            User customer = userDAO.getUserById(booking.getUserId());
            
            boolean success = bookingDAO.approveBooking(bookingId);
            
            if (success) {
                // Send approval email to customer
                if (customer != null && customer.getEmail() != null) {
                    String subject = "Booking Approved - CINEZY Cinema";
                    String body = String.format(
                        "Dear %s,\n\n" +
                        "Your booking (#%d) has been approved successfully!\n\n" +
                        "Booking Details:\n" +
                        "- Booking ID: %d\n" +
                        "- Status: Confirmed\n" +
                        "- Total Amount: MMK %s\n\n" +
                        "Thank you for choosing CINEZY Cinema. We look forward to seeing you!\n\n" +
                        "Best regards,\nCINEZY Cinema Team",
                        customer.getName(), 
                        bookingId,
                        bookingId,
                        booking.getTotalPrice() != null ? booking.getTotalPrice().toString() : "N/A"
                    );
                    
                    boolean emailSent = EmailUtil.sendEmail(customer.getEmail(), subject, body);
                    
                    if (emailSent) {
                        System.out.println("✅ Approval email sent to: " + customer.getEmail());
                    } else {
                        System.out.println("⚠️ Failed to send approval email to: " + customer.getEmail());
                    }
                }
                
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