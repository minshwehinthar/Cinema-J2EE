package com.demo.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.time.LocalDate;
import java.util.ArrayList;

import com.demo.dao.ShowtimesDao;
import com.demo.model.Timeslot;

@WebServlet("/GetShowtimesServlet")
public class GetShowtimesServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String movieIdStr = request.getParameter("movie_id");
        String theaterIdStr = request.getParameter("theater_id");
        String dateStr = request.getParameter("date"); // optional, for direct date selection

        if (movieIdStr == null || theaterIdStr == null) {
            request.setAttribute("error", "Invalid selection. Please pick a movie and theater first.");
            request.getRequestDispatcher("selectShowtimes.jsp").forward(request, response);
            return;
        }

        int movieId = Integer.parseInt(movieIdStr);
        int theaterId = Integer.parseInt(theaterIdStr);

        ShowtimesDao dao = new ShowtimesDao();

        // Get available dates for this movie & theater
        LocalDate[] dates = dao.getMovieDates(theaterId, movieId);

        if (dates == null) {
            request.setAttribute("error", "No show dates found for this movie in this theater.");
            request.getRequestDispatcher("selectShowtimes.jsp").forward(request, response);
            return;
        }

        LocalDate startDate = dates[0];
        LocalDate endDate = dates[1];

        // If a specific date is selected, show only that date
        LocalDate selectedDate = (dateStr != null) ? LocalDate.parse(dateStr) : startDate;

        // Get assigned timeslots for this theater, movie, and selected date
        ArrayList<Timeslot> slots = dao.getAssignedTimeslots(theaterId, movieId, selectedDate);

        request.setAttribute("startDate", startDate);
        request.setAttribute("endDate", endDate);
        request.setAttribute("selectedDate", selectedDate);
        request.setAttribute("slots", slots);
        request.setAttribute("movieId", movieId);
        request.setAttribute("theaterId", theaterId);

        request.getRequestDispatcher("selectShowtimes.jsp").forward(request, response);
    }
}
