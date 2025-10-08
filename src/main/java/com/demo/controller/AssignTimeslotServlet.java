package com.demo.controller;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.time.LocalDate;

import com.demo.dao.ShowtimesDao;

@WebServlet("/AssignTimeslotServlet")
public class AssignTimeslotServlet extends HttpServlet {
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
        ShowtimesDao dao = new ShowtimesDao();

        // ✅ Get movie start/end dates
        LocalDate[] dates = dao.getMovieDates(theaterId, movieId);
        if (dates == null) {
            response.sendRedirect("assignTimeslot.jsp?movie_id=" + movieId + "&msg=nodates");
            return;
        }

        LocalDate startDate = dates[0];
        LocalDate endDate = dates[1];

        boolean inserted = false;

        // ✅ Loop all dates, check selected slot, insert only if chosen
        LocalDate current = startDate;
        while (!current.isAfter(endDate)) {
            String slotParam = request.getParameter("slot_" + current.toString());
            if (slotParam != null && !slotParam.isEmpty()) {
                int slotId = Integer.parseInt(slotParam);

                // Insert only if not already assigned
                if (!dao.isSlotAssigned(theaterId, movieId, slotId, current)) {
                    dao.insertShowtime(theaterId, movieId, slotId, current);
                    inserted = true;
                }
            }
            current = current.plusDays(1);
        }

        if (inserted) {
            response.sendRedirect("theateradminpickmovies.jsp?msg=timeslot_assigned");
        } else {
            response.sendRedirect("assignTimeslot.jsp?movie_id=" + movieId + "&msg=no_selection");
        }
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doPost(request, response);
    }
}