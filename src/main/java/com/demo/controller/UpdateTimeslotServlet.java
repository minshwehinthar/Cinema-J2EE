package com.demo.controller;

import com.demo.dao.TimeslotDao;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/UpdateTimeslotServlet")
public class UpdateTimeslotServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        int slotId = Integer.parseInt(request.getParameter("slotId"));
        String startTime = request.getParameter("startTime");
        String endTime = request.getParameter("endTime");

        TimeslotDao dao = new TimeslotDao();
        boolean updated = dao.updateTimeslot(slotId, startTime, endTime);

        if(updated) {
            response.sendRedirect("addTimeslots.jsp?msg=Timeslot updated successfully");
        } else {
            response.sendRedirect("addTimeslots.jsp?msg=Failed to update timeslot");
        }
    }
}
