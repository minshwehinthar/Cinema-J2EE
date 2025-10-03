<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.demo.model.User, com.demo.model.Movies, com.demo.dao.MoviesDao" %>
<%@ page import="java.sql.*, java.util.Base64" %>

<%
    // Admin check
    User user = (User) session.getAttribute("user");
    if(user == null || !"admin".equals(user.getRole())) {
        response.sendRedirect("login.jsp?msg=unauthorized");
        return;
    }

    int movieId = request.getParameter("movieId") != null ? Integer.parseInt(request.getParameter("movieId")) : 0;
    Movies movie = null;
    String posterBase64 = "";
    String posterType = "";

    if(movieId > 0){
        MoviesDao dao = new MoviesDao();
        movie = dao.getMovieById(movieId);

        if(movie != null){
            Connection con = new com.demo.dao.MyConnection().getConnection();
            try{
                PreparedStatement ps = con.prepareStatement("SELECT poster, postertype FROM movies WHERE movie_id=?");
                ps.setInt(1, movieId);
                ResultSet rs = ps.executeQuery();
                if(rs.next()){
                    byte[] posterBytes = rs.getBytes("poster");
                    posterType = rs.getString("postertype");
                    if(posterBytes != null) posterBase64 = Base64.getEncoder().encodeToString(posterBytes);
                }
                rs.close();
                ps.close();
            }catch(Exception e){ e.printStackTrace(); }
            finally { con.close(); }
        }
    }
%>

<jsp:include page="layout/JSPHeader.jsp" />
<div class="flex min-h-screen bg-gray-50">
    <jsp:include page="layout/sidebar.jsp" />
    <div class="flex-1 sm:ml-64">
        <jsp:include page="/layout/AdminHeader.jsp" />

        <div class="max-w-8xl mx-auto px-8 mt-6 pb-12">
            <h2 class="text-3xl font-bold mb-6">Edit Movie</h2>

            <% if(movie == null){ %>
                <div class="text-red-600 font-semibold text-xl">❌ Movie not found.</div>
            <% } else { %>

            <form action="UpdateMovieController" method="post" enctype="multipart/form-data" class="grid grid-cols-1 lg:grid-cols-3 gap-8">
                <input type="hidden" name="movieId" value="<%= movie.getMovie_id() %>">

                <!-- Column 1 -->
                <div class="space-y-6">
                    <div>
                        <label class="font-semibold">Title</label>
                        <input type="text" name="title" value="<%= movie.getTitle() %>" required class="w-full p-4 border rounded-lg">
                    </div>
                    <div>
                        <label class="font-semibold">Duration</label>
                        <input type="text" name="duration" value="<%= movie.getDuration() %>" class="w-full p-4 border rounded-lg">
                    </div>
                    <div>
                        <label class="font-semibold">Casts</label>
                        <textarea name="casts" rows="3" class="w-full p-4 border rounded-lg"><%= movie.getCasts() %></textarea>
                    </div>
                    <div>
                        <label class="font-semibold">Trailer</label>
                        <video id="trailerPreview" controls class="w-72 h-40 rounded-lg border shadow-md">
                            <source src="GetMoviesTrailerServlet?movie_id=<%= movie.getMovie_id() %>" type="video/mp4">
                        </video>
                        <label for="trailerUpload" class="cursor-pointer bg-gray-100 px-6 py-3 rounded-lg mt-2 inline-block">Upload Trailer</label>
                        <input type="file" name="trailer" id="trailerUpload" class="hidden" accept="video/*">
                    </div>
                </div>

                <!-- Column 2 -->
                <div class="space-y-6">
                    <div>
                        <label class="font-semibold">Status</label>
                        <select name="status" class="w-full p-4 border rounded-lg" required>
                            <option value="now-showing" <%= "now-showing".equals(movie.getStatus()) ? "selected" : "" %>>Now Showing</option>
                            <option value="coming-soon" <%= "coming-soon".equals(movie.getStatus()) ? "selected" : "" %>>Coming Soon</option>
                        </select>
                    </div>
                    <div>
                        <label class="font-semibold">Director</label>
                        <input type="text" name="director" value="<%= movie.getDirector() %>" class="w-full p-4 border rounded-lg">
                    </div>
                    <div>
                        <label class="font-semibold">Genres</label>
                        <input type="text" name="genres" value="<%= movie.getGenres() %>" class="w-full p-4 border rounded-lg">
                    </div>
                    <div>
                        <label class="font-semibold">Synopsis</label>
                        <textarea name="synopsis" rows="4" class="w-full p-4 border rounded-lg"><%= movie.getSynopsis() %></textarea>
                    </div>
                </div>

                <!-- Column 3 -->
                <div class="flex flex-col items-center gap-8">
                    <div>
                        <label class="font-semibold">Poster</label>
                        <% if(!posterBase64.isEmpty()){ %>
                            <img id="posterPreview" src="data:<%=posterType%>;base64,<%=posterBase64%>" class="w-56 h-72 object-cover rounded-xl border shadow-md">
                        <% } else { %>
                            <img id="posterPreview" src="assets/img/cart_empty.png" class="w-56 h-72 object-cover rounded-xl border shadow-md">
                        <% } %>
                        <label for="posterUpload" class="cursor-pointer bg-gray-100 px-6 py-3 rounded-lg mt-2 inline-block">Upload Poster</label>
                        <input type="file" name="poster" id="posterUpload" class="hidden" accept="image/*">
                    </div>
                    <button type="submit" class="bg-blue-600 text-white px-10 py-4 rounded-lg hover:bg-blue-700 transition">Save Changes</button>
                </div>
            </form>
            <% } %>
        </div>
    </div>
</div>

<script>
    // Poster preview
    const posterInput = document.getElementById('posterUpload');
    const posterPreview = document.getElementById('posterPreview');
    posterInput.addEventListener('change', () => {
        if (posterInput.files.length > 0) {
            const reader = new FileReader();
            reader.onload = e => posterPreview.src = e.target.result;
            reader.readAsDataURL(posterInput.files[0]);
        }
    });

    // Trailer preview
    const trailerInput = document.getElementById('trailerUpload');
    const trailerPreview = document.getElementById('trailerPreview');
    trailerInput.addEventListener('change', () => {
        if (trailerInput.files.length > 0) {
            trailerPreview.src = URL.createObjectURL(trailerInput.files[0]);
            trailerPreview.load();
        }
    });
</script>

<jsp:include page="layout/JSPFooter.jsp" />
