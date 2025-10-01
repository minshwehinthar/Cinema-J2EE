<%@ page import="com.demo.model.Movies" %>
<%@ page import="com.demo.dao.MoviesDao" %>
<jsp:include page="layout/JSPHeader.jsp"></jsp:include>
<jsp:include page="layout/header.jsp"></jsp:include>

<%
    int movie_id = 0;
    if(request.getParameter("movie_id") != null){
        movie_id = Integer.parseInt(request.getParameter("movie_id"));
    }

    MoviesDao dao = new MoviesDao();
    Movies movie = dao.getMovieById(movie_id);

    if(movie == null){
%>
    <h2 class="text-center text-2xl mt-20">Movie not found.</h2>
<%
    } else {
        String posterUrl = "GetMoviesPosterServlet?movie_id=" + movie.getMovie_id();
        String trailerUrl = "GetMoviesTrailerServlet?movie_id=" + movie.getMovie_id();
        String status = movie.getStatus() != null ? movie.getStatus() : "";
        boolean isNowShowing = "now-showing".equalsIgnoreCase(status);
%>

<section class="py-16 bg-gray-50 relative">
    <div class="container mx-auto px-4">
        
        <a href="movies.jsp" class="absolute top-6 left-8 flex items-center">
            <img src="assets/images/back.png" alt="Back" class="w-10 h-10 hover:opacity-100 transition">
        </a>

        <div class="flex flex-col lg:flex-row gap-8 mt-10">
            <!-- Poster -->
            <div class="lg:w-5/12 w-full flex justify-center">
                <img class="w-[300px] h-[450px] object-cover rounded-2xl shadow-2xl"
                     src="<%= posterUrl %>" 
                     alt="<%= movie.getTitle() %> Poster"/>
            </div>

            <!-- Movie Info -->
            <div class="lg:w-7/12 w-full">
                <h1 class="mb-6 text-4xl md:text-5xl font-bold font-heading leading-tight">
                    <%= movie.getTitle() %>
                </h1>

                <div class="mb-6 text-gray-700 space-y-2">
                    <p><strong>Status:</strong> <%= movie.getStatus() != null ? movie.getStatus() : "N/A" %></p>
                    <p><strong>Duration:</strong> <%= movie.getDuration() != null ? movie.getDuration() : "N/A" %></p>
                    <p><strong>Director:</strong> <%= movie.getDirector() != null ? movie.getDirector() : "N/A" %></p>
                    <p><strong>Cast:</strong> <%= movie.getCasts() != null ? movie.getCasts() : "N/A" %></p>
                    <p><strong>Genres:</strong> <%= movie.getGenres() != null ? movie.getGenres() : "N/A" %></p>
                </div>

                <p class="mb-8 text-lg leading-relaxed text-gray-700">
                    <%= movie.getSynopsis() != null ? movie.getSynopsis() : "No synopsis available." %>
                </p>

                <div class="flex flex-wrap gap-4">
                    <% if(isNowShowing) { %>
                        <!-- Only show Get Tickets if Now Showing -->
                        <a href="GetMovieTheatersServlet?movie_id=<%= movie.getMovie_id() %>" 
                           class="py-3 px-6 text-white font-semibold border border-indigo-700 rounded-xl shadow-xl bg-indigo-600 hover:bg-indigo-700 transition ease-in-out duration-200 inline-block text-center">
                           Get Tickets
                        </a>
                    <% } %>

                    <!-- Always show trailer -->
                    <button class="movie-trailer-btn py-3 px-6 font-semibold border border-indigo-600 rounded-xl bg-white text-indigo-600 shadow hover:bg-indigo-50 transition ease-in-out duration-200 inline-block text-center">
        Watch Trailer
    </button>
                </div>
            </div>
        </div>
    </div>

    <!-- Trailer Popup -->
    <div class="trailer-popup hidden fixed inset-0 bg-black bg-opacity-75 flex items-center justify-center z-50">
        <div class="relative bg-white rounded-2xl p-6 max-w-4xl w-full mx-4">
            <button class="trailer-close absolute top-4 right-4 text-gray-500 hover:text-gray-700 text-2xl font-bold">×</button>
            <h3 class="text-2xl font-bold mb-4">
                <%= movie.getTitle() %> - Official Trailer
            </h3>
            <div class="aspect-video bg-gray-200 rounded-lg flex items-center justify-center">
                <iframe class="w-full h-full rounded-lg"
                        src="<%= trailerUrl %>"
                        title="Movie Trailer"
                        frameborder="0"
                        allowfullscreen>
                </iframe>
            </div>
        </div>
    </div>
</section>

<% } %>
<jsp:include page="layout/footer.jsp"></jsp:include>
<jsp:include page="layout/JSPFooter.jsp"></jsp:include>