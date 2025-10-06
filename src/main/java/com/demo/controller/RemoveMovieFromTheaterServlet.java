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

@WebServlet("/RemoveMovieFromTheaterServlet")
public class RemoveMovieFromTheaterServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String movieIdParam = request.getParameter("movie_id");
        String theaterIdParam = request.getParameter("theater_id");

        if (movieIdParam == null || theaterIdParam == null || movieIdParam.isEmpty() || theaterIdParam.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/showing-now.jsp?msg=invalid");
            return;
        }

        int movieId = Integer.parseInt(movieIdParam);
        int theaterId = Integer.parseInt(theaterIdParam);

        String sql = "DELETE FROM theater_movies WHERE movie_id = ? AND theater_id = ?";

        try (Connection con = MyConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, movieId);
            ps.setInt(2, theaterId);

            int rowsAffected = ps.executeUpdate();

            if (rowsAffected > 0) {
                response.sendRedirect(request.getContextPath() + "/showing-now.jsp?msg=removed");
            } else {
                response.sendRedirect(request.getContextPath() + "/showing-now.jsp?msg=notfound");
            }

        } catch (SQLException e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/showing-now.jsp?msg=error");
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect(request.getContextPath() + "/showing-now.jsp");
    }
}
