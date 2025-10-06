package com.demo.controller;

import com.demo.dao.SeatsDao;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;

@WebServlet("/AddSeatsServlet")
public class AddSeatsServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        int theaterId = Integer.parseInt(request.getParameter("theater_id"));
        int seatsPerRow = Integer.parseInt(request.getParameter("seatsPerRow"));

        int normalRows = Integer.parseInt(request.getParameter("normalRows"));
        int vipRows = Integer.parseInt(request.getParameter("vipRows"));
        int coupleRows = Integer.parseInt(request.getParameter("coupleRows"));
        int coupleSeats = Integer.parseInt(request.getParameter("coupleSeats"));

        SeatsDao dao = new SeatsDao();
        int nextRow = 0;

        // Add Normal seats (price_id = 1)
        if (normalRows > 0)
            nextRow = dao.addSeatsForType(theaterId, nextRow, normalRows, seatsPerRow, 1, false);

        // Add VIP seats (price_id = 2)
        if (vipRows > 0)
            nextRow = dao.addSeatsForType(theaterId, nextRow, vipRows, seatsPerRow, 2, false);

        // Add Couple seats (price_id = 3)
        if (coupleRows > 0)
            nextRow = dao.addSeatsForType(theaterId, nextRow, coupleRows, coupleSeats * 2, 3, true);

        HttpSession session = request.getSession();
        session.setAttribute("success", "Seats added successfully!");
        response.sendRedirect("employees.jsp");
    }
}