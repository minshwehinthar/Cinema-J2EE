package com.demo.controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import com.demo.dao.MyConnection;

@WebServlet("/DeleteMovieServlet")
public class DeleteMovieServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    // Handle POST request to delete movie
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String movieIdParam = request.getParameter("movie_id");
        if (movieIdParam == null || movieIdParam.isEmpty()) {
            response.sendRedirect("showing-now.jsp?msg=invalid");
            return;
        }

        int movieId = Integer.parseInt(movieIdParam);

        String sql = "DELETE FROM movies WHERE movie_id = ?";

        try (Connection con = MyConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, movieId);
            int rowsAffected = ps.executeUpdate();

            if (rowsAffected > 0) {
                response.sendRedirect("showing-now.jsp?msg=deleted");
            } else {
                response.sendRedirect("showing-now.jsp?msg=notfound");
            }

        } catch (SQLException e) {
            e.printStackTrace();
            response.sendRedirect("showing-now.jsp?msg=error");
        }
    }

    // Redirect GET requests to movies.jsp
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect("showing-now.jsp");
    }
}
