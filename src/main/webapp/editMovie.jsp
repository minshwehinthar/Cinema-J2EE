<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.demo.model.User, com.demo.model.Movies, com.demo.dao.MoviesDao" %>
<%
    User user = (User) session.getAttribute("user");
    if(user == null || !"admin".equals(user.getRole())) {
        response.sendRedirect("login.jsp?msg=unauthorized");
        return;
    }

    int movieId = request.getParameter("movieId") != null ? Integer.parseInt(request.getParameter("movieId")) : 0;
    Movies movie = null;
    if(movieId > 0) {
        MoviesDao dao = new MoviesDao();
        movie = dao.getMovieById(movieId);
    }
%>

<jsp:include page="layout/JSPHeader.jsp" />
<div class="flex min-h-screen">
    <jsp:include page="layout/sidebar.jsp" />
    <div class="flex-1 sm:ml-64 bg-white">
        <jsp:include page="/layout/AdminHeader.jsp" />
        <div class="max-w-8xl mx-auto px-8 mt-6">
            <h2 class="text-3xl font-bold mb-6">Edit Movie</h2>

            <form action="UpdateMovieController" method="post" enctype="multipart/form-data" class="grid grid-cols-1 lg:grid-cols-3 gap-8">
                <input type="hidden" name="movieId" value="<%= movie != null ? movie.getMovie_id() : 0 %>">

                <!-- Column 1 -->
                <div class="space-y-6">
                    <div>
                        <label>Title</label>
                        <input type="text" name="title" value="<%= movie != null ? movie.getTitle() : "" %>" required class="w-full p-4 border rounded-lg">
                    </div>
                    <div>
                        <label>Duration</label>
                        <input type="text" name="duration" value="<%= movie != null ? movie.getDuration() : "" %>" class="w-full p-4 border rounded-lg">
                    </div>
                    <div>
                        <label>Casts</label>
                        <textarea name="casts" rows="3" class="w-full p-4 border rounded-lg"><%= movie != null ? movie.getCasts() : "" %></textarea>
                    </div>
                    <div>
                        <label>Trailer</label>
                        <% if(movie != null) { %>
                        <video id="trailerPreview" controls class="w-72 h-40 rounded-lg border shadow-md">
                            <source src="MovieMedia?movieId=<%= movie.getMovie_id() %>&type=trailer" type="<%= movie.getTrailertype() != null ? movie.getTrailertype() : "video/mp4" %>">
                        </video>
                        <% } %>
                        <label for="trailerUpload" class="cursor-pointer bg-gray-100 px-6 py-3 rounded-lg mt-2">Upload Trailer</label>
                        <input type="file" name="trailer" id="trailerUpload" class="hidden" accept="video/*">
                    </div>
                </div>

                <!-- Column 2 -->
                <div class="space-y-6">
                    <div>
                        <label>Status</label>
                        <select name="status" class="w-full p-4 border rounded-lg" required>
                            <option value="now-showing" <%= movie != null && "now-showing".equals(movie.getStatus()) ? "selected" : "" %>>Now Showing</option>
                            <option value="coming-soon" <%= movie != null && "coming-soon".equals(movie.getStatus()) ? "selected" : "" %>>Coming Soon</option>
                        </select>
                    </div>
                    <div>
                        <label>Director</label>
                        <input type="text" name="director" value="<%= movie != null ? movie.getDirector() : "" %>" class="w-full p-4 border rounded-lg">
                    </div>
                    <div>
                        <label>Genres</label>
                        <input type="text" name="genres" value="<%= movie != null ? movie.getGenres() : "" %>" class="w-full p-4 border rounded-lg">
                    </div>
                    <div>
                        <label>Synopsis</label>
                        <textarea name="synopsis" rows="4" class="w-full p-4 border rounded-lg"><%= movie != null ? movie.getSynopsis() : "" %></textarea>
                    </div>
                </div>

                <!-- Column 3 -->
                <div class="flex flex-col items-center gap-8">
                    <div>
                        <label>Poster</label>
                        <% if(movie != null) { %>
                        <img id="posterPreview" src="MovieMedia?movieId=<%= movie.getMovie_id() %>&type=poster" class="w-56 h-72 object-cover rounded-xl border shadow-md">
                        <% } %>
                        <label for="posterUpload" class="cursor-pointer bg-gray-100 px-6 py-3 rounded-lg mt-2">Upload Poster</label>
                        <input type="file" name="poster" id="posterUpload" class="hidden" accept="image/*">
                    </div>
                    <button type="submit" class="bg-blue-600 text-white px-10 py-4 rounded-lg">Save Changes</button>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
    const posterInput = document.getElementById('posterUpload');
    const posterPreview = document.getElementById('posterPreview');
    posterInput.addEventListener('change', () => {
        if (posterInput.files.length > 0) {
            const reader = new FileReader();
            reader.onload = e => posterPreview.src = e.target.result;
            reader.readAsDataURL(posterInput.files[0]);
        }
    });

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
