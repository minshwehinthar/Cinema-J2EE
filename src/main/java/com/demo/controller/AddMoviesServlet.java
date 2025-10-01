package com.demo.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;

import java.io.IOException;

import com.demo.dao.MoviesDao;

/**
 * Servlet implementation class AddMoviesServlet
 */
@WebServlet("/AddMoviesServlet")
@MultipartConfig(maxFileSize = 1024*1024*1024)
public class AddMoviesServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public AddMoviesServlet() {
        super();
        // TODO Auto-generated constructor stub
    }

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		doPost(request, response);
	}

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
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
		if(row>0) {
			response.sendRedirect("addMovies.jsp");
		}
	}
}