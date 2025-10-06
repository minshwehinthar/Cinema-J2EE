package com.demo.controller;

import com.demo.dao.TimeslotDao;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.time.LocalTime;
import java.time.format.DateTimeParseException;

@WebServlet("/AddTimeslotServlet")
public class AddTimeslotServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        int theaterId = Integer.parseInt(request.getParameter("theaterId"));
        String startTimeStr = request.getParameter("startTime");
        String endTimeStr = request.getParameter("endTime");

        // Basic validation: start time must be before end time
        try {
            LocalTime startTime = LocalTime.parse(startTimeStr);
            LocalTime endTime = LocalTime.parse(endTimeStr);

            if (!startTime.isBefore(endTime)) {
                response.sendRedirect("addTimeslots.jsp?msg=Start time must be before end time");
                return;
            }

            TimeslotDao dao = new TimeslotDao();
            boolean available = dao.isTimeslotAvailable(theaterId, startTimeStr, endTimeStr);

            if (!available) {
                response.sendRedirect("addTimeslots.jsp?msg=Timeslot overlaps with existing one");
                return;
            }

            int row = dao.addTimeslot(theaterId, startTimeStr, endTimeStr);
            if (row > 0) {
                response.sendRedirect("addTimeslots.jsp?msg=Timeslot added successfully");
            } else {
                response.sendRedirect("addTimeslots.jsp?msg=Failed to add timeslot");
            }

        } catch (DateTimeParseException e) {
            // Invalid time format
            response.sendRedirect("addTimeslots.jsp?msg=Invalid time format");
        }
    }
}
