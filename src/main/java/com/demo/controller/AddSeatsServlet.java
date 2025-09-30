package com.demo.controller;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.WebServlet;
import java.io.IOException;
import com.demo.dao.SeatPriceDao;
import com.demo.dao.SeatsDao;

@WebServlet("/AddSeatsServlet")
public class AddSeatsServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

        Integer theaterId = (Integer) request.getSession().getAttribute("theater_id");
        if(theaterId == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String seatType = request.getParameter("seat_type");
        String rowsInput = request.getParameter("rows"); // e.g., "A,B,C"
        int seatsPerRow = Integer.parseInt(request.getParameter("seats_per_row"));

        SeatPriceDao priceDao = new SeatPriceDao();
        int priceId = priceDao.getPriceIdBySeatType(seatType);

        if(priceId == -1) {
            response.sendRedirect("addSeats.jsp?msg=error");
            return;
        }

        SeatsDao seatsDao = new SeatsDao();
        boolean added = seatsDao.addSeatsForRows(theaterId, rowsInput, seatsPerRow, priceId);

        if(added) {
            response.sendRedirect("addSeats.jsp?msg=success");
        } else {
            response.sendRedirect("addSeats.jsp?msg=error");
        }
    }
}
