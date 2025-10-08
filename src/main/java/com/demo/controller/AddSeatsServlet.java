package com.demo.controller;

import com.demo.dao.SeatsDao;
import com.demo.dao.SeatPriceDao;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/AddSeatsServlet")
public class AddSeatsServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            int theaterId = Integer.parseInt(request.getParameter("theater_id"));
            int seatsPerRow = Integer.parseInt(request.getParameter("seatsPerRow"));
            int normalRows = Integer.parseInt(request.getParameter("normalRows"));
            int vipRows = Integer.parseInt(request.getParameter("vipRows"));
            int coupleRows = Integer.parseInt(request.getParameter("coupleRows"));
            int coupleSeats = Integer.parseInt(request.getParameter("coupleSeats"));

            // Get actual price IDs from database
            SeatPriceDao priceDao = new SeatPriceDao();
            int normalPriceId = priceDao.getPriceIdBySeatType("Normal");
            int vipPriceId = priceDao.getPriceIdBySeatType("VIP");
            int couplePriceId = priceDao.getPriceIdBySeatType("Couple");

            SeatsDao seatsDao = new SeatsDao();
            
            // Use the method that matches your form parameters
            seatsDao.addSeatsForTheater(theaterId, normalRows, vipRows, coupleRows, 
                                      seatsPerRow, coupleSeats, normalPriceId, vipPriceId, couplePriceId);

            HttpSession session = request.getSession();
            session.setAttribute("success", "Seats added successfully!");
            response.sendRedirect("employees.jsp");
            
        } catch (NumberFormatException e) {
            e.printStackTrace();
            response.sendRedirect("add-seats.jsp?error=invalid_input");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("add-seats.jsp?error=server_error");
        }
    }
}