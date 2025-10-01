<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.demo.dao.MoviesDao" %>
<%@ page import="com.demo.model.Movies" %>

<%
    String movieIdParam = request.getParameter("movie_id");
    if (movieIdParam == null) {
        out.println("<p class='text-red-600'>No movie selected.</p>");
        return;
    }

    int movieId = Integer.parseInt(movieIdParam);
    MoviesDao dao = new MoviesDao();
    Movies movie = dao.getMovieById(movieId);

    if (movie == null) {
        out.println("<p class='text-red-600'>Movie not found.</p>");
        return;
    }
%>

<jsp:include page="layout/JSPHeader.jsp"/>

<section class="bg-gray-50 min-h-screen py-12">
    <div class="container mx-auto px-4">
        <div class="bg-white rounded-2xl shadow-lg p-8 flex flex-col md:flex-row gap-8">
            
            <!-- Poster -->
            <div class="flex-shrink-0 md:w-1/3">
                <img src="GetMoviesPosterServlet?movie_id=<%= movie.getMovie_id() %>"
                     alt="<%= movie.getTitle() %> Poster"
                     class="w-full h-auto rounded-xl object-cover"
                     onerror="this.src='https://via.placeholder.com/300x450?text=No+Poster';"/>
            </div>

            <!-- Movie Details -->
            <div class="flex-1">
                <h1 class="text-4xl font-bold text-indigo-700 mb-4"><%= movie.getTitle() %></h1>

                <div class="mb-4">
                    <span class="px-3 py-1 text-xs font-semibold rounded-md uppercase <%= "now-showing".equalsIgnoreCase(movie.getStatus()) ? "bg-green-600 text-white" : "bg-yellow-600 text-white" %>">
                        <%= movie.getStatus().equalsIgnoreCase("now-showing") ? "Now Showing" : "Coming Soon" %>
                    </span>
                </div>

                <p class="mb-2"><strong>Duration:</strong> <%= movie.getDuration() != null ? movie.getDuration() : "-" %></p>
                <p class="mb-2"><strong>Director:</strong> <%= movie.getDirector() != null ? movie.getDirector() : "-" %></p>
                <p class="mb-2"><strong>Casts:</strong> <%= movie.getCasts() != null ? movie.getCasts() : "-" %></p>
                <p class="mb-2"><strong>Genres:</strong> <%= movie.getGenres() != null ? movie.getGenres() : "-" %></p>
                <p class="mb-4"><strong>Synopsis:</strong> <%= movie.getSynopsis() != null ? movie.getSynopsis() : "-" %></p>

                <!-- Trailer Video -->
                <%
                    byte[] trailerBytes = dao.getTrailerById(movieId);
                    if (trailerBytes != null && trailerBytes.length > 0) {
                %>
                <video controls class="w-full rounded-xl mb-4">
                    <source src="GetMoviesTrailerServlet?movie_id=<%= movie.getMovie_id() %>" type="<%= movie.getTrailertype() %>">
                    Your browser does not support the video tag.
                </video>
                <% } else { %>
                    <p class="text-gray-500 italic">No trailer available.</p>
                <% } %>

                <!-- Action Buttons -->
                <div class="flex gap-4 mt-6">
                    <a href="editMovie.jsp?movieId=<%= movie.getMovie_id() %>"
                       class="px-6 py-2 bg-blue-600 text-white rounded-xl hover:bg-blue-700 transition">Edit</a>
                    <a href="PickMovieServlet?movie_id=<%= movie.getMovie_id() %>"
                       class="px-6 py-2 bg-green-600 text-white rounded-xl hover:bg-green-700 transition">Pick Movie</a>
                </div>

            </div>
        </div>
    </div>
</section>

<jsp:include page="layout/JSPFooter.jsp"/>
