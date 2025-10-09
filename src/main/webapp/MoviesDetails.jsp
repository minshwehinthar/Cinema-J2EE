<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.demo.model.Movies" %>
<%@ page import="com.demo.dao.MoviesDao" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.Base64" %>
<%@ page import="com.demo.model.User" %>

<%
    // Get the logged-in user from session
    User user = (User) session.getAttribute("user");

    // Only allow admin or theater_admin
    if (user == null || 
       (!"admin".equals(user.getRole()) && !"theateradmin".equals(user.getRole()))) {
        response.sendRedirect("login.jsp?msg=unauthorized");
        return; // stop rendering the rest of the page
    }
    
    String idParam = request.getParameter("id");
    Movies movie = null;
    String posterBase64 = "";
    String posterType = "";

    if(idParam != null){
        int movieId = Integer.parseInt(idParam);
        MoviesDao dao = new MoviesDao();
        movie = dao.getMovieById(movieId);

        if(movie != null){
            Connection con = new com.demo.dao.MyConnection().getConnection();
            try {
                PreparedStatement ps = con.prepareStatement(
                    "SELECT poster, postertype FROM movies WHERE movie_id=?");
                ps.setInt(1, movieId);
                ResultSet rs = ps.executeQuery();
                if(rs.next()){
                    byte[] posterBytes = rs.getBytes("poster");
                    posterType = rs.getString("postertype");
                    if(posterBytes != null){
                        posterBase64 = Base64.getEncoder().encodeToString(posterBytes);
                    }
                }
                rs.close();
                ps.close();
            } catch(Exception e){ e.printStackTrace(); }
            finally { con.close(); }
        }
    }
%>

<jsp:include page="layout/JSPHeader.jsp" />

<div class="flex min-h-screen bg-gray-50">
    <!-- Sidebar -->
    <jsp:include page="layout/sidebar.jsp"/>

    <!-- Main content -->
    <div class="flex-1 sm:ml-64">
        <!-- Admin Header -->
        <jsp:include page="layout/AdminHeader.jsp"/>

        <div class="p-6">
            <!-- Back button -->
            <div class="mb-6">
                <a href="movies-management.jsp" class="inline-flex items-center text-indigo-600 hover:text-indigo-800 font-medium">
                    <svg class="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 19l-7-7m0 0l7-7m-7 7h18"></path>
                    </svg>
                    Back to Movies
                </a>
            </div>

            <% if(movie == null){ %>
                <div class="text-center mt-20 text-red-600 font-semibold text-xl">
                    ❌ Movie not found!
                </div>
            <% } else { %>
            
            <div class="max-w-7xl mx-auto">
                <!-- Movie header with title and status -->
                <div class="bg-white rounded-xl shadow-sm p-6 mb-6">
                    <div class="flex flex-col md:flex-row md:items-center md:justify-between">
                        <div>
                            <h1 class="text-3xl font-bold text-gray-900"><%= movie.getTitle() %></h1>
                            <div class="flex items-center mt-2">
                                <span class="px-3 py-1 rounded-full text-sm font-medium <%= "Released".equals(movie.getStatus()) ? "bg-green-100 text-green-800" : "bg-yellow-100 text-yellow-800" %>">
                                    <%= movie.getStatus() %>
                                </span>
                                <span class="ml-4 text-gray-600">
                                    <svg class="w-5 h-5 inline mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"></path>
                                    </svg>
                                    <%= movie.getDuration() %>
                                </span>
                            </div>
                        </div>
                        <div class="mt-4 md:mt-0">
                            <button class="px-4 py-2 bg-indigo-600 text-white rounded-lg hover:bg-indigo-700 transition-colors font-medium">
                                Edit Movie
                            </button>
                        </div>
                    </div>
                </div>
                
                <!-- Main content grid -->
                <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
                    <!-- Left column - Poster and basic info -->
                    <div class="lg:col-span-1">
                        <div class="bg-white rounded-xl shadow-sm overflow-hidden">
                            <!-- Poster -->
                            <div class="p-4">
                                <% if (!posterBase64.isEmpty()) { %>
                                    <img src="data:<%=posterType%>;base64,<%=posterBase64%>"
                                         alt="Movie Poster"
                                         class="w-full aspect-[2/3] object-cover rounded-lg shadow-md" />
                                <% } else { %>
                                    <div class="w-full aspect-[2/3] bg-gray-200 rounded-lg flex items-center justify-center">
                                        <svg class="w-16 h-16 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z"></path>
                                        </svg>
                                    </div>
                                <% } %>
                            </div>
                            
                            <!-- Movie details -->
                            <div class="p-4 border-t border-gray-100">
                                <h3 class="text-lg font-semibold text-gray-900 mb-4">Movie Details</h3>
                                
                                <div class="space-y-4">
                                    <div>
                                        <p class="text-sm text-gray-500">Director</p>
                                        <p class="font-medium"><%= movie.getDirector() %></p>
                                    </div>
                                    
                                    <div>
                                        <p class="text-sm text-gray-500">Cast</p>
                                        <p class="font-medium"><%= movie.getCasts() %></p>
                                    </div>
                                    
                                    <div>
                                        <p class="text-sm text-gray-500">Genres</p>
                                        <p class="font-medium"><%= movie.getGenres() %></p>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    
                    <!-- Right column - Synopsis and trailer -->
                    <div class="lg:col-span-2 space-y-6">
                        <!-- Synopsis -->
                        <div class="bg-white rounded-xl shadow-sm p-6">
                            <h2 class="text-xl font-bold text-gray-900 mb-4">Synopsis</h2>
                            <p class="text-gray-700 leading-relaxed"><%= movie.getSynopsis() %></p>
                        </div>
                        
                        <!-- Trailer -->
                        <div class="bg-white rounded-xl shadow-sm p-6">
                            <h2 class="text-xl font-bold text-gray-900 mb-4 flex items-center">
                                <svg class="w-6 h-6 mr-2 text-indigo-600" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M14.752 11.168l-3.197-2.132A1 1 0 0010 9.87v4.263a1 1 0 001.555.832l3.197-2.132a1 1 0 000-1.664z"></path>
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path>
                                </svg>
                                Watch Trailer
                            </h2>
                            <div class="w-full aspect-video rounded-lg overflow-hidden bg-gray-900">
                                <video controls class="w-full h-full">
                                    <source src="GetMoviesTrailerServlet?movie_id=<%= movie.getMovie_id() %>" type="video/mp4">
                                    Your browser does not support the video tag.
                                </video>
                            </div>
                        </div>
                        
                        <!-- Actions -->
                        <div class="bg-white rounded-xl shadow-sm p-6">
                            <h2 class="text-xl font-bold text-gray-900 mb-4">Manage Movie</h2>
                            <div class="flex flex-wrap gap-3">
                                <button class="px-4 py-2 bg-indigo-600 text-white rounded-lg hover:bg-indigo-700 transition-colors font-medium">
                                    Edit Details
                                </button>
                                <button class="px-4 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700 transition-colors font-medium">
                                    Update Showtimes
                                </button>
                                <button class="px-4 py-2 bg-yellow-600 text-white rounded-lg hover:bg-yellow-700 transition-colors font-medium">
                                    Change Poster
                                </button>
                                <button class="px-4 py-2 bg-red-600 text-white rounded-lg hover:bg-red-700 transition-colors font-medium">
                                    Delete Movie
                                </button>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <% } %>
        </div>
    </div>
</div>

<jsp:include page="layout/JSPFooter.jsp" />