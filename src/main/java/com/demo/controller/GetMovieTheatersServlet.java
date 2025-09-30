package com.demo.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.ArrayList;

import com.demo.dao.TheaterMoviesDao;
import com.demo.model.Theater;

@WebServlet("/GetMovieTheatersServlet")
public class GetMovieTheatersServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        int movieId = Integer.parseInt(request.getParameter("movie_id"));

        TheaterMoviesDao dao = new TheaterMoviesDao();
        ArrayList<Theater> theaters = dao.getTheatersByMovie(movieId);

        request.setAttribute("theaters", theaters);
        request.setAttribute("movie_id", movieId);
        request.getRequestDispatcher("availableTheaters.jsp").forward(request, response);
    }
}
