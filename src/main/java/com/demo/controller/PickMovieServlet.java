package com.demo.controller;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.time.LocalDate;
import java.util.ArrayList;

import com.demo.dao.ShowtimesDao;
import com.demo.dao.TimeslotDao;
import com.demo.dao.TheaterMoviesDao;
import com.demo.model.Timeslot;

@WebServlet("/PickMovieServlet")
public class PickMovieServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        Integer theaterId = (Integer) session.getAttribute("theater_id");
        if (theaterId == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        int movieId = Integer.parseInt(request.getParameter("movie_id"));
        String movieStatus = request.getParameter("status"); // "now-showing" or "coming-soon"
        LocalDate startDate = null;
        LocalDate endDate = null;

        // For now-showing, parse start/end dates
        if ("now-showing".equalsIgnoreCase(movieStatus)) {
            try {
                startDate = LocalDate.parse(request.getParameter("start_date"));
                endDate = LocalDate.parse(request.getParameter("end_date"));
            } catch (Exception e) {
                response.sendRedirect("theateradminpickmovies.jsp?msg=invaliddate");
                return;
            }
        }
        if ("coming-soon".equalsIgnoreCase(movieStatus)) {
            try {
                startDate = LocalDate.parse(request.getParameter("start_date"));
                endDate = LocalDate.parse(request.getParameter("end_date"));
            } catch (Exception e) {
                response.sendRedirect("theateradminpickmovies.jsp?msg=invaliddate");
                return;
            }
        }

        TheaterMoviesDao theaterDao = new TheaterMoviesDao();
        TimeslotDao slotDao = new TimeslotDao();
        ShowtimesDao showDao = new ShowtimesDao();

        // Now-showing logic
        if ("now-showing".equalsIgnoreCase(movieStatus)) {
            // Check if theater has any timeslots
            ArrayList<Timeslot> allSlots = slotDao.getTimeslotsByTheater(theaterId);
            if (allSlots.isEmpty()) {
                response.sendRedirect("addTimeslots.jsp?msg=notimeslots");
                return;
            }

            // Check if at least one free slot exists in date range
            boolean hasAvailableSlot = false;
            LocalDate current = startDate;
            while (!current.isAfter(endDate)) {
                ArrayList<Timeslot> freeSlots = showDao.getFreeTimeslotsForDate(theaterId, current, allSlots);
                if (!freeSlots.isEmpty()) {
                    hasAvailableSlot = true;
                    break;
                }
                current = current.plusDays(1);
            }

            if (!hasAvailableSlot) {
                response.sendRedirect("addTimeslots.jsp?msg=nofreeslot");
                return;
            }

            // Insert movie with dates
            int row = theaterDao.addMovieToTheater(theaterId, movieId, startDate.toString(), endDate.toString());
            if (row > 0) {
                response.sendRedirect("assignTimeslot.jsp?movie_id=" + movieId + "&msg=added");
            } else {
                response.sendRedirect("theateradminpickmovies.jsp?msg=error");
            }

        } else if ("coming-soon".equalsIgnoreCase(movieStatus)) {
        	 ArrayList<Timeslot> allSlots = slotDao.getTimeslotsByTheater(theaterId);
             if (allSlots.isEmpty()) {
                 response.sendRedirect("addTimeslots.jsp?msg=notimeslots");
                 return;
             }

             // Check if at least one free slot exists in date range
             boolean hasAvailableSlot = false;
             LocalDate current = startDate;
             while (!current.isAfter(endDate)) {
                 ArrayList<Timeslot> freeSlots = showDao.getFreeTimeslotsForDate(theaterId, current, allSlots);
                 if (!freeSlots.isEmpty()) {
                     hasAvailableSlot = true;
                     break;
                 }
                 current = current.plusDays(1);
             }

             if (!hasAvailableSlot) {
                 response.sendRedirect("addTimeslots.jsp?msg=nofreeslot");
                 return;
             }
            // Coming soon → insert with NULL dates or a placeholder
        	int row = theaterDao.addMovieToTheater(theaterId, movieId, startDate.toString(), endDate.toString());
            if (row > 0) {
                response.sendRedirect("assignTimeslot.jsp?movie_id=" + movieId + "&msg=added");
            } else {
                response.sendRedirect("theateradminpickmovies.jsp?msg=error");
            }
        } else {
            // Unknown status
            response.sendRedirect("theateradminpickmovies.jsp?msg=invalidstatus");
        }
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doPost(request, response);
    }
}