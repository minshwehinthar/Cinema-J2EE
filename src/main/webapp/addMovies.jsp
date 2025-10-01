<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.demo.model.User" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null || !"admin".equals(user.getRole())) {
        response.sendRedirect("login.jsp?msg=unauthorized");
        return;
    }
%>

<script src="https://unpkg.com/feather-icons"></script>
<jsp:include page="layout/JSPHeader.jsp" />

<div class="flex min-h-screen">
    <!-- Sidebar -->
    <jsp:include page="layout/sidebar.jsp" />

    <!-- Main content -->
    <div class="flex-1 sm:ml-64 bg-white">
        <jsp:include page="/layout/AdminHeader.jsp" />

        <div class="max-w-8xl mx-auto px-8 mt-6">
        <!-- Breadcrumb -->
        <div class="max-w-8xl mx-auto py-6">
            <nav class="text-sm text-gray-500 mb-4" aria-label="Breadcrumb">
                <ol class="flex items-center space-x-2">
                    <li><a href="index.jsp" class="hover:underline">Home</a></li>
                    <li>/</li>
                    <li><a href="movie-list.jsp" class="hover:underline">Movie List</a></li>
                    <li>/</li>
                    <li class="text-gray-700">Create Movie</li>
                </ol>
            </nav>
        </div>
            <h2 class="text-3xl font-bold mb-6 flex items-center gap-2">
                <i data-feather="film"></i> Add New Movie
            </h2>

            <% String msg = request.getParameter("msg"); %>
            <% if ("success".equals(msg)) { %>
                <p class="text-green-600 mb-6 font-semibold">✅ Movie added successfully!</p>
            <% } else if ("error".equals(msg)) { %>
                <p class="text-red-600 mb-6 font-semibold">❌ Error adding movie. Try again.</p>
            <% } %>

            <form action="AddMovieController" method="post" enctype="multipart/form-data" class="grid grid-cols-1 lg:grid-cols-3 gap-8">
                
                <!-- Column 1 -->
                <div class="space-y-6">
                    <div>
                        <label class="font-medium text-gray-700">Title</label>
                        <input type="text" name="title" placeholder="Avengers: Endgame"
                               class="w-full p-4 border rounded-lg focus:ring-2 focus:ring-blue-400" required>
                    </div>
                    <div>
                        <label class="font-medium text-gray-700">Duration</label>
                        <input type="text" name="duration" placeholder="2h 15m"
                               class="w-full p-4 border rounded-lg focus:ring-2 focus:ring-blue-400">
                    </div>
                    <div>
                        <label class="font-medium text-gray-700">Casts</label>
                        <textarea name="casts" rows="3" placeholder="Robert Downey Jr, Chris Evans..."
                                  class="w-full p-4 border rounded-lg focus:ring-2 focus:ring-blue-400"></textarea>
                    </div>
                    <!-- Trailer -->
                    <div class="flex flex-col items-center gap-4">
                        <label class="font-medium text-gray-700">Trailer</label>
                        <video id="trailerPreview" controls class="w-72 h-40 rounded-lg border shadow-md">
                            <source src="" type="video/mp4">
                        </video>
                        <label for="trailerUpload"
                               class="cursor-pointer bg-gray-100 px-6 py-3 rounded-lg hover:bg-gray-200 transition-colors flex items-center gap-2">
                            <i data-feather="film"></i> Upload Trailer
                        </label>
                        <input type="file" name="trailer" id="trailerUpload" class="hidden" accept="video/*" required>
                    </div>
                   
                </div>

                <!-- Column 2 -->
                <div class="space-y-6">
                    <div>
                        <label class="font-medium text-gray-700">Status</label>
                        <select name="status"
                                class="w-full p-4 border rounded-lg focus:ring-2 focus:ring-blue-400" required>
                            <option value="now-showing">Now Showing</option>
                            <option value="coming-soon">Coming Soon</option>
                        </select>
                    </div>
                    <div>
                        <label class="font-medium text-gray-700">Director</label>
                        <input type="text" name="director" placeholder="Anthony Russo"
                               class="w-full p-4 border rounded-lg focus:ring-2 focus:ring-blue-400">
                    </div>
                    <div>
                        <label class="font-medium text-gray-700">Genres</label>
                        <input type="text" name="genres" placeholder="Action, Adventure"
                               class="w-full p-4 border rounded-lg focus:ring-2 focus:ring-blue-400">
                    </div>
                    <div>
                        <label class="font-medium text-gray-700">Synopsis</label>
                        <textarea name="synopsis" rows="4" placeholder="Movie storyline..."
                                  class="w-full p-4 border rounded-lg focus:ring-2 focus:ring-blue-400"></textarea>
                    </div>
                </div>

                <!-- Column 3 (Poster & Trailer) -->
                <div class="flex flex-col items-center gap-8">
                    <!-- Poster -->
                    <div class="flex flex-col items-center gap-4">
                        <label class="font-medium text-gray-700">Poster</label>
                        <img id="posterPreview" src="assets/img/placeholder_poster.png"
                             class="w-56 h-72 object-cover rounded-xl border shadow-md">
                        <label for="posterUpload"
                               class="cursor-pointer bg-gray-100 px-6 py-3 rounded-lg hover:bg-gray-200 transition-colors flex items-center gap-2">
                            <i data-feather="image"></i> Upload Poster
                        </label>
                        <input type="file" name="poster" id="posterUpload" class="hidden" accept="image/*" required>
                    </div>

                    
                    <!-- Full width Submit (below all 3 cols) -->
                <div class="col-span-1 lg:col-span-3 text-center mt-8">
                    <button type="submit"
                            class="bg-blue-600 text-white px-10 py-4 rounded-lg hover:bg-blue-700 transition-colors font-medium">
                        ➕ Add Movie
                    </button>
                </div>
                </div>

               
            </form>
        </div>
    </div>
</div>

<script>
    feather.replace();

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
            const fileURL = URL.createObjectURL(trailerInput.files[0]);
            trailerPreview.src = fileURL;
            trailerPreview.load();
        }
    });
</script>

<jsp:include page="layout/JSPFooter.jsp" />
