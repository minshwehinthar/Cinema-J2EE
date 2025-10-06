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

        Integer movieId = request.getParameter("movie_id") != null ? Integer.parseInt(request.getParameter("movie_id")) :
                          (Integer) request.getAttribute("movie_id");
        if(movieId == null) {
            request.setAttribute("msg", "no_selection");
            RequestDispatcher rd = request.getRequestDispatcher("assignTimeslots.jsp");
            rd.forward(request, response);
            return;
        }

        ShowtimesDao dao = new ShowtimesDao();
        LocalDate[] dates = dao.getMovieDates(theaterId, movieId);
        if(dates == null) {
            request.setAttribute("msg", "nodates");
            request.setAttribute("movie_id", movieId);
            RequestDispatcher rd = request.getRequestDispatcher("assignTimeslots.jsp");
            rd.forward(request, response);
            return;
        }

        LocalDate startDate = dates[0];
        LocalDate endDate = dates[1];
        boolean inserted = false;

        LocalDate current = startDate;
        while(!current.isAfter(endDate)) {
            String slotParam = request.getParameter("slot_" + current.toString());
            if(slotParam != null && !slotParam.isEmpty()) {
                int slotId = Integer.parseInt(slotParam);
                if(!dao.isSlotAssigned(theaterId, movieId, slotId, current)) {
                    dao.insertShowtime(theaterId, movieId, slotId, current);
                    inserted = true;
                }
            }
            current = current.plusDays(1);
        }

        if(inserted) {
            request.setAttribute("msg", "timeslot_assigned");
            RequestDispatcher rd = request.getRequestDispatcher("theateradminpickmovies.jsp");
            rd.forward(request, response);
        } else {
            request.setAttribute("msg", "no_selection");
            request.setAttribute("movie_id", movieId);
            RequestDispatcher rd = request.getRequestDispatcher("assignTimeslots.jsp");
            rd.forward(request, response);
        }
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doPost(request, response);
    }
}
