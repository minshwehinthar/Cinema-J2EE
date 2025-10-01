package com.demo.controller;

import java.io.IOException;

import com.demo.dao.MoviesDao;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;

@WebServlet("/AddMovieController")
@MultipartConfig(maxFileSize = 16177215) // ~16MB
public class AddMovieController extends HttpServlet {
    private static final long serialVersionUID = 1L;

    public AddMovieController() {
        super();
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String title = request.getParameter("title");
        String status = request.getParameter("status");
        String duration = request.getParameter("duration");
        String director = request.getParameter("director");
        String casts = request.getParameter("casts");
        String genres = request.getParameter("genres");
        String synopsis = request.getParameter("synopsis");

        Part posterPart = request.getPart("poster");
        Part trailerPart = request.getPart("trailer");

        MoviesDao dao = new MoviesDao();
        int row = dao.addMovies(title, status, duration, director, casts, genres, synopsis, posterPart, trailerPart);

        if (row > 0) {
            request.setAttribute("message", "Movie added successfully!");
        } else {
            request.setAttribute("message", "Failed to add movie!");
        }

        request.getRequestDispatcher("addMovies.jsp").forward(request, response);
    }
}
