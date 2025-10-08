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
            // Save booking info for after login
            session.setAttribute("redirectAfterLogin", true);
            session.setAttribute("pendingBookingMovieId", request.getParameter("movieId"));
            session.setAttribute("pendingBookingTheaterId", request.getParameter("theaterId"));
            session.setAttribute("pendingBookingShowtimeId", request.getParameter("showtimeId"));
            session.setAttribute("pendingBookingShowDate", request.getParameter("showDate"));
            session.setAttribute("pendingBookingSelectedSeats", request.getParameter("selectedSeats"));
            session.setAttribute("pendingBookingSelectedSeatIds", request.getParameter("selectedSeatIds"));
            session.setAttribute("pendingBookingTotalPrice", request.getParameter("totalPrice"));

            response.sendRedirect("login.jsp");
            return;
        }

        // 1️⃣ Restore parameters from request OR session
        String movieIdStr = request.getParameter("movieId");
        String theaterIdStr = request.getParameter("theaterId");
        String showtimeIdStr = request.getParameter("showtimeId");
        String showDate = request.getParameter("showDate");
        String selectedSeats = request.getParameter("selectedSeats");
        String selectedSeatIdsStr = request.getParameter("selectedSeatIds");
        String totalPriceStr = request.getParameter("totalPrice");

        if (movieIdStr == null) {
            // Coming from login redirect → get pending booking from session
            movieIdStr = (String) session.getAttribute("pendingBookingMovieId");
            theaterIdStr = (String) session.getAttribute("pendingBookingTheaterId");
            showtimeIdStr = (String) session.getAttribute("pendingBookingShowtimeId");
            showDate = (String) session.getAttribute("pendingBookingShowDate");
            selectedSeats = (String) session.getAttribute("pendingBookingSelectedSeats");
            selectedSeatIdsStr = (String) session.getAttribute("pendingBookingSelectedSeatIds");
            totalPriceStr = (String) session.getAttribute("pendingBookingTotalPrice");

            // Clear session
            session.removeAttribute("pendingBookingMovieId");
            session.removeAttribute("pendingBookingTheaterId");
            session.removeAttribute("pendingBookingShowtimeId");
            session.removeAttribute("pendingBookingShowDate");
            session.removeAttribute("pendingBookingSelectedSeats");
            session.removeAttribute("pendingBookingSelectedSeatIds");
            session.removeAttribute("pendingBookingTotalPrice");
            session.removeAttribute("redirectAfterLogin");
        }

        // 2️⃣ Validate
        if (movieIdStr == null || theaterIdStr == null || showtimeIdStr == null
                || showDate == null || selectedSeats == null
                || selectedSeatIdsStr == null || totalPriceStr == null) {
            response.sendRedirect("selectShowtimes.jsp?error=invalidSelection");
            return;
        }

        // 3️⃣ Convert to proper types
        int movieId = Integer.parseInt(movieIdStr);
        int theaterId = Integer.parseInt(theaterIdStr);
        int showtimeId = Integer.parseInt(showtimeIdStr);
        double totalPrice = Double.parseDouble(totalPriceStr);
        String[] seatIdsArray = selectedSeatIdsStr.split(",");

        // 4️⃣ Store booking info in session
        session.setAttribute("bookingMovieId", movieId);
        session.setAttribute("bookingTheaterId", theaterId);
        session.setAttribute("bookingShowtimeId", showtimeId);
        session.setAttribute("bookingShowDate", showDate);
        session.setAttribute("bookingSelectedSeats", selectedSeats);
        session.setAttribute("bookingSelectedSeatIds", seatIdsArray);
        session.setAttribute("bookingTotalPrice", totalPrice);

        // 5️⃣ Redirect to bookingConfirmation.jsp
        response.sendRedirect("bookingConfirmation.jsp");
    }


    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doPost(request, response);
    }
}