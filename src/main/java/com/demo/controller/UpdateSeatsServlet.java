package com.demo.controller;

import com.demo.dao.SeatsDao;
import com.demo.model.Seat;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;
import java.util.ArrayList;

@WebServlet("/UpdateSeatsServlet")
public class UpdateSeatsServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

        HttpSession session = request.getSession();

        // Admin session check
        com.demo.model.User user = (com.demo.model.User) session.getAttribute("user");
        if (user == null || !"admin".equals(user.getRole())) {
            response.sendRedirect("login.jsp?msg=unauthorized");
            return;
        }

        // Get theaterId from session
        Integer theaterId = (Integer) session.getAttribute("theater_id");
        if (theaterId == null) {
            response.sendRedirect("create-theater-admin.jsp?msg=noTheater");
            return;
        }

        // Get seat layout JSON from form
        String seatLayoutJson = request.getParameter("seatLayout");
        if (seatLayoutJson == null || seatLayoutJson.isEmpty()) {
            response.sendRedirect("editSeatLayout.jsp?theater_id=" + theaterId + "&msg=emptyLayout");
            return;
        }

        // Parse JSON manually into Seat objects
        List<Seat> seatList = parseSeatJson(seatLayoutJson, theaterId);

        SeatsDao seatDao = new SeatsDao();
        try {
            // Delete existing seats
            seatDao.deleteSeatsByTheater(theaterId);

            // Insert updated seats
            seatDao.insertSeats(seatList);

            // Redirect back to edit page with theater_id and success message
            response.sendRedirect("editSeatLayout.jsp?theater_id=" + theaterId + "&msg=success");

        } catch (SQLException e) {
            e.printStackTrace();
            response.sendRedirect("editSeatLayout.jsp?theater_id=" + theaterId + "&msg=error");
        }
    }

    /**
     * Manually parses seat layout JSON into a list of Seat objects.
     * Example JSON: [[{"type":"normal","active":"1"},...],...]
     */
    private List<Seat> parseSeatJson(String json, int theaterId) {
        List<Seat> seats = new ArrayList<>();

        // Remove outer brackets
        json = json.replaceAll("\\[|\\]", "");

        // Split by seat objects
        String[] seatEntries = json.split("\\},\\{");

        char currentRow = 'A';
        int seatCounter = 1;

        for (String s : seatEntries) {
            if (s.trim().isEmpty()) continue;

            String type = "normal";
            int active = 1;

            if (s.contains("\"type\":\"")) {
                type = s.split("\"type\":\"")[1].split("\"")[0];
            }
            if (s.contains("\"active\":\"")) {
                active = Integer.parseInt(s.split("\"active\":\"")[1].split("\"")[0]);
            }

            Seat seat = new Seat();
            seat.setSeatNumber(currentRow + String.valueOf(seatCounter));
            seat.setSeatType(type.toUpperCase());
            seat.setStatus(active == 1 ? "available" : "unavailable");

            // Set price based on seat type
            seat.setPrice(type.equalsIgnoreCase("VIP") ? new java.math.BigDecimal(15000)
                          : type.equalsIgnoreCase("COUPLE") ? new java.math.BigDecimal(20000)
                          : new java.math.BigDecimal(10000));

            seats.add(seat);

            seatCounter++;
            // TODO: Add logic to move to next row if needed
        }

        return seats;
    }
}
