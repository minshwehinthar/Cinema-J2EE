<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.demo.model.Movies" %>
<%@ page import="com.demo.dao.MoviesDao" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.Base64" %>

<jsp:include page="layout/JSPHeader.jsp" />
<jsp:include page="layout/header.jsp" />

<%
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

<% if(movie == null){ %>
    <div class="text-center mt-20 text-red-600 font-semibold text-xl">
        ❌ Movie not found!
    </div>
<% } else { %>

<div class="min-h-screen bg-gray-50 py-10 px-6">
    <div class="max-w-6xl mx-auto bg-white rounded-2xl shadow-lg overflow-hidden">
        <div class="grid md:grid-cols-2 gap-10 p-8">

            <!-- Poster -->
            <div class="flex justify-center">
                <% if (!posterBase64.isEmpty()) { %>
                    <img src="data:<%=posterType%>;base64,<%=posterBase64%>"
                         alt="Movie Poster"
                         class="w-80 aspect-[2/3] object-cover rounded-2xl shadow-xl border border-gray-200" />
                <% } else { %>
                    <img src="assets/img/cart_empty.png"
                         class="w-80 aspect-[2/3] object-cover rounded-2xl border border-gray-200 shadow-lg" />
                <% } %>
            </div>

            <!-- Movie Info -->
            <div class="flex flex-col gap-6">
                <h1 class="text-4xl font-bold text-gray-800"><%= movie.getTitle() %></h1>
                <p class="text-indigo-600 font-medium"><%= movie.getStatus() %></p>
                <p><span class="font-semibold">Duration:</span> <%= movie.getDuration() %></p>
                <p><span class="font-semibold">Director:</span> <%= movie.getDirector() %></p>
                <p><span class="font-semibold">Cast:</span> <%= movie.getCasts() %></p>
                <p><span class="font-semibold">Genres:</span> <%= movie.getGenres() %></p>
                <p class="text-gray-700 leading-relaxed"><%= movie.getSynopsis() %></p>
            </div>
        </div>

        <!-- Trailer -->
        <div class="w-full px-8 pb-8">
            <h2 class="text-2xl font-bold text-gray-800 mb-4">🎬 Watch Trailer</h2>
            <div class="w-full aspect-video rounded-2xl overflow-hidden shadow-lg border border-gray-200">
                <video controls class="w-full h-full">
                    <source src="GetMoviesTrailerServlet?movie_id=<%= movie.getMovie_id() %>" type="video/mp4">
                    Your browser does not support the video tag.
                </video>
            </div>
        </div>
    </div>
</div>

<% } %>

<jsp:include page="layout/JSPFooter.jsp" />
