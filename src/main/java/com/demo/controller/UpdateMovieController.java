package com.demo.controller;

import com.demo.dao.MoviesDao;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;

import java.io.IOException;

@WebServlet("/UpdateMovieController")
@MultipartConfig(maxFileSize = 16177215) // ~16MB
public class UpdateMovieController extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

        int movieId = Integer.parseInt(request.getParameter("movieId"));
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
        boolean success = dao.updateMovie(
                movieId, title, status, duration, director, casts, genres, synopsis, posterPart, trailerPart
        );

        if(success) {
            response.sendRedirect("editMovie.jsp?movieId=" + movieId + "&msg=success");
        } else {
            response.sendRedirect("editMovie.jsp?movieId=" + movieId + "&msg=error");
        }
    }
}
