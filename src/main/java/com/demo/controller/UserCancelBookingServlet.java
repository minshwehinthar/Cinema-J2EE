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

@WebServlet("/UserCancelBookingServlet")
public class UserCancelBookingServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
       
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
            
            boolean success = bookingDAO.adminCancelBooking(bookingId); // Using same method
            
            if (success) {
                response.sendRedirect("myBookings.jsp?success=Booking cancelled successfully");
            } else {
                response.sendRedirect("myBookings.jsp?error=Failed to cancel booking. Please try again.");
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("myBookings.jsp?error=Error cancelling booking: " + e.getMessage());
        }
    }
    
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        doPost(request, response);
    }
}
