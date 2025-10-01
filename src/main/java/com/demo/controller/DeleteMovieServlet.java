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

@WebServlet("/deleteMovie")
public class DeleteMovieServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        int movieId = Integer.parseInt(request.getParameter("movieId"));
        boolean success = false;

        try(Connection con = new MyConnection().getConnection();
            PreparedStatement pstm = con.prepareStatement("DELETE FROM movies WHERE movie_id=?")) {
            pstm.setInt(1, movieId);
            success = (pstm.executeUpdate() > 0);
        } catch (SQLException e) {
            e.printStackTrace();
        }

        response.setContentType("application/json");
        response.getWriter().write("{\"success\":" + success + "}");
    }
}

