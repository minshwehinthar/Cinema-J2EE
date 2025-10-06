package com.demo.controller;

import com.demo.dao.TimeslotDao;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/DeleteTimeslotServlet")
public class DeleteTimeslotServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        int slotId = Integer.parseInt(request.getParameter("slotId"));

        TimeslotDao dao = new TimeslotDao();
        boolean deleted = dao.deleteTimeslot(slotId);

        if(deleted) {
            response.sendRedirect("addTimeslots.jsp?msg=Timeslot deleted successfully");
        } else {
            response.sendRedirect("addTimeslots.jsp?msg=Failed to delete timeslot");
        }
    }
}
