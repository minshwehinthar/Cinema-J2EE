package com.demo.controller;

import java.io.IOException;
import java.io.InputStream;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;

import com.demo.dao.MoviesDao;

@WebServlet("/UpdateMovieController")   // ✅ This must match your JSP form action
@MultipartConfig(maxFileSize = 16177215) // enable file upload
public class UpdateMovieController extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

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

        try {
            // You can implement an update method in MoviesDao similar to addMovies
            int rows = dao.updateMovie(movieId, title, status, duration, director,
                                       casts, genres, synopsis, posterPart, trailerPart);

            if (rows > 0) {
                response.sendRedirect("moviesList.jsp?msg=updated");
            } else {
                response.sendRedirect("editMovie.jsp?movieId=" + movieId + "&msg=failed");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("editMovie.jsp?movieId=" + movieId + "&msg=error");
        }
    }
}
