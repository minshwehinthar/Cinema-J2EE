package com.demo.controller;

import com.demo.dao.MoviesDao;
import com.demo.model.Movies;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebServlet("/MovieMediaServlet")
public class MovieMediaServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String movieIdParam = request.getParameter("movieId");
        String type = request.getParameter("type"); // poster or trailer

        if(movieIdParam == null || type == null) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Missing parameters");
            return;
        }

        int movieId = Integer.parseInt(movieIdParam);
        MoviesDao dao = new MoviesDao();
        Movies movie = dao.getMovieById(movieId);

        if(movie.getMovie_id() == 0) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Movie not found");
            return;
        }

        byte[] mediaBytes = null;
        String contentType = "";

        if("poster".equals(type)){
            mediaBytes = dao.getPosterById(movieId);
            contentType = movie.getPostertype();
        } else if("trailer".equals(type)){
            mediaBytes = dao.getTrailerById(movieId);
            contentType = movie.getTrailertype();
        } else {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid type");
            return;
        }

        if(mediaBytes == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Media not found");
            return;
        }

        response.setContentType(contentType);
        response.setContentLength(mediaBytes.length);
        response.getOutputStream().write(mediaBytes);
    }
}
