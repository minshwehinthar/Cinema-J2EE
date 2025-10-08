package com.demo.controller;

import java.io.IOException;
import java.sql.*;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import com.demo.dao.MyConnection;

@WebServlet("/DeleteMovieServlet")
public class DeleteMovieServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String movieIdParam = request.getParameter("movie_id");
        if (movieIdParam == null || movieIdParam.isEmpty()) {
            response.sendRedirect("showing-now.jsp?msg=invalid");
            return;
        }

        int movieId = Integer.parseInt(movieIdParam);
        String movieStatus = "now-showing"; // default
        String redirectPage;

        // Step 1: Get movie status first
        String getStatusSql = "SELECT status FROM movies WHERE movie_id = ?";
        try (Connection con = MyConnection.getConnection();
             PreparedStatement psStatus = con.prepareStatement(getStatusSql)) {

            psStatus.setInt(1, movieId);
            try (ResultSet rs = psStatus.executeQuery()) {
                if (rs.next()) {
                    movieStatus = rs.getString("status");
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        // Step 2: Delete movie
        String sql = "DELETE FROM movies WHERE movie_id = ?";
        try (Connection con = MyConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, movieId);
            int rowsAffected = ps.executeUpdate();

            // Step 3: Decide redirect based on status
            if ("coming-soon".equalsIgnoreCase(movieStatus)) {
                redirectPage = "coming-soon.jsp";
            } else {
                redirectPage = "showing-now.jsp";
            }

            if (rowsAffected > 0) {
                response.sendRedirect(redirectPage + "?msg=deleted");
            } else {
                response.sendRedirect(redirectPage + "?msg=notfound");
            }

        } catch (SQLException e) {
            e.printStackTrace();
            response.sendRedirect("showing-now.jsp?msg=error");
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect("showing-now.jsp");
    }
}
