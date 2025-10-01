<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.demo.dao.MoviesDao" %>
<%@ page import="com.demo.model.Movies" %>

<%
    String movieIdParam = request.getParameter("movieId");
    if(movieIdParam == null){
        response.sendRedirect("moviesList.jsp");
        return;
    }

    int movieId = Integer.parseInt(movieIdParam);
    MoviesDao moviesDAO = new MoviesDao();
    Movies movie = moviesDAO.getMovieById(movieId);

    if(movie.getMovie_id() == 0){
        out.println("<h2>Movie not found!</h2>");
        return;
    }
%>

<jsp:include page="layout/JSPHeader.jsp"/>
<div class="flex">
    <jsp:include page="layout/sidebar.jsp"/>
    <div class="flex-1 sm:ml-64">
        <jsp:include page="/layout/AdminHeader.jsp"/>
        <div class="p-8 bg-white shadow rounded-lg">
            <h1 class="text-3xl font-bold mb-4 text-gray-900"><%= movie.getTitle() %></h1>

            <div class="flex flex-col md:flex-row gap-6">
                <!-- Poster -->
                <div class="w-full md:w-1/3">
                    <img src="MovieMediaServlet?movieId=<%= movie.getMovie_id() %>&type=poster" 
                         class="rounded-lg shadow" 
                         alt="<%= movie.getTitle() %> Poster"
                         onerror="this.src='https://via.placeholder.com/300x450?text=No+Poster';"/>
                </div>

                <!-- Details -->
                <div class="flex-1">
                    <p><strong>Status:</strong> 
                        <span class="<%= "now-showing".equals(movie.getStatus())?"text-green-600":"text-yellow-600" %> font-semibold">
                            <%= movie.getStatus() %>
                        </span>
                    </p>
                    <p><strong>Duration:</strong> <%= movie.getDuration() %></p>
                    <p><strong>Director:</strong> <%= movie.getDirector() != null ? movie.getDirector() : "-" %></p>
                    <p><strong>Genres:</strong> <%= movie.getGenres() != null ? movie.getGenres() : "-" %></p>
                    <p><strong>Casts:</strong> <%= movie.getCasts() != null ? movie.getCasts() : "-" %></p>
                    <p class="mt-4"><strong>Synopsis:</strong><br/> <%= movie.getSynopsis() != null ? movie.getSynopsis() : "-" %></p>

                    <!-- Trailer -->
                    <div class="mt-6">
                        <strong>Trailer:</strong>
                        <video controls class="w-full rounded-lg mt-2" onerror="this.style.display='none';">
                            <source src="MovieMediaServlet?movieId=<%= movie.getMovie_id() %>&type=trailer" type="<%= movie.getTrailertype() %>">
                            Your browser does not support the video tag.
                        </video>
                    </div>

                    <!-- Action Buttons -->
                    <div class="mt-6 flex space-x-2">
                        <a href="editMovie.jsp?movieId=<%= movie.getMovie_id() %>" 
                           class="bg-blue-500 text-white px-4 py-2 rounded hover:bg-blue-600">Edit Movie</a>
                        <a href="moviesList.jsp" 
                           class="bg-gray-500 text-white px-4 py-2 rounded hover:bg-gray-600">Back to List</a>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
<jsp:include page="layout/JSPFooter.jsp"/>
