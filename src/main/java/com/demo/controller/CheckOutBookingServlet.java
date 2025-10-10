package com.demo.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/CheckOutBookingServlet")
public class CheckOutBookingServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        Object userObj = session.getAttribute("user");

        if (userObj == null) {
            // Save ALL booking parameters to session
            session.setAttribute("pendingBookingMovieId", request.getParameter("movieId"));
            session.setAttribute("pendingBookingTheaterId", request.getParameter("theaterId"));
            session.setAttribute("pendingBookingShowtimeId", request.getParameter("showtimeId"));
            session.setAttribute("pendingBookingShowDate", request.getParameter("showDate"));
            session.setAttribute("pendingBookingSelectedSeats", request.getParameter("selectedSeats"));
            session.setAttribute("pendingBookingSelectedSeatIds", request.getParameter("selectedSeatIds"));
            session.setAttribute("pendingBookingTotalPrice", request.getParameter("totalPrice"));
            session.setAttribute("redirectAfterLogin", "CheckOutBookingServlet");

            response.sendRedirect("login.jsp");
            return;
        }

        // User is logged in - process booking
        processBooking(request, response);
    }

    private void processBooking(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        
        // Get parameters from request OR from session (if coming from login)
        String movieIdStr = getParameterOrAttribute(request, session, "movieId", "pendingBookingMovieId");
        String theaterIdStr = getParameterOrAttribute(request, session, "theaterId", "pendingBookingTheaterId");
        String showtimeIdStr = getParameterOrAttribute(request, session, "showtimeId", "pendingBookingShowtimeId");
        String showDate = getParameterOrAttribute(request, session, "showDate", "pendingBookingShowDate");
        String selectedSeats = getParameterOrAttribute(request, session, "selectedSeats", "pendingBookingSelectedSeats");
        String selectedSeatIdsStr = getParameterOrAttribute(request, session, "selectedSeatIds", "pendingBookingSelectedSeatIds");
        String totalPriceStr = getParameterOrAttribute(request, session, "totalPrice", "pendingBookingTotalPrice");

        // Clear pending booking data
        clearPendingBooking(session);

        // Validate and process (your existing code)
        if (movieIdStr == null || theaterIdStr == null || showtimeIdStr == null
                || showDate == null || selectedSeats == null
                || selectedSeatIdsStr == null || totalPriceStr == null) {
            response.sendRedirect("selectShowtimes.jsp?error=invalidSelection");
            return;
        }

        // Convert and store in session for confirmbooking.jsp
        int movieId = Integer.parseInt(movieIdStr);
        int theaterId = Integer.parseInt(theaterIdStr);
        int showtimeId = Integer.parseInt(showtimeIdStr);
        double totalPrice = Double.parseDouble(totalPriceStr);
        String[] seatIdsArray = selectedSeatIdsStr.split(",");

        session.setAttribute("bookingMovieId", movieId);
        session.setAttribute("bookingTheaterId", theaterId);
        session.setAttribute("bookingShowtimeId", showtimeId);
        session.setAttribute("bookingShowDate", showDate);
        session.setAttribute("bookingSelectedSeats", selectedSeats);
        session.setAttribute("bookingSelectedSeatIds", seatIdsArray);
        session.setAttribute("bookingTotalPrice", totalPrice);

        // Redirect to confirmbooking.jsp
        response.sendRedirect("bookingConfirmation.jsp");
    }

    private String getParameterOrAttribute(HttpServletRequest request, HttpSession session, 
                                         String paramName, String attrName) {
        String value = request.getParameter(paramName);
        if (value == null) {
            value = (String) session.getAttribute(attrName);
        }
        return value;
    }

    private void clearPendingBooking(HttpSession session) {
        session.removeAttribute("pendingBookingMovieId");
        session.removeAttribute("pendingBookingTheaterId");
        session.removeAttribute("pendingBookingShowtimeId");
        session.removeAttribute("pendingBookingShowDate");
        session.removeAttribute("pendingBookingSelectedSeats");
        session.removeAttribute("pendingBookingSelectedSeatIds");
        session.removeAttribute("pendingBookingTotalPrice");
        session.removeAttribute("redirectAfterLogin");
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doPost(request, response);
    }
}