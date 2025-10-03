package com.demo.controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

import com.demo.dao.MyConnection;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/CreateSeatsServlet")
public class CreateSeatsServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String theaterIdStr = request.getParameter("theater_id");
        String seatNumber = request.getParameter("seat_number");
        String priceIdStr = request.getParameter("price_id");

        if (theaterIdStr == null || seatNumber == null || priceIdStr == null ||
            theaterIdStr.isEmpty() || seatNumber.isEmpty() || priceIdStr.isEmpty()) {
            response.getWriter().println("All fields are required.");
            return;
        }

        int theaterId = Integer.parseInt(theaterIdStr);
        int priceId = Integer.parseInt(priceIdStr);

        String sql = "INSERT INTO seats (theater_id, seat_number, price_id) VALUES (?, ?, ?)";

        try (Connection con = MyConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, theaterId);
            ps.setString(2, seatNumber);
            ps.setInt(3, priceId);

            int rows = ps.executeUpdate();

            if (rows > 0) {
                response.getWriter().println("Seat created successfully!");
            } else {
                response.getWriter().println("Failed to create seat.");
            }

        } catch (SQLException e) {
            e.printStackTrace();
            response.getWriter().println("Database error: " + e.getMessage());
        }
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.getWriter().println("Use POST method to create seats.");
    }
}
