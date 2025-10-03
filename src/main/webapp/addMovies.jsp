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

<div class="flex min-h-screen bg-gray-50">
    <!-- Sidebar -->
    <jsp:include page="layout/sidebar.jsp" />

    <!-- Main content -->
    <div class="flex-1 sm:ml-64">
        <jsp:include page="/layout/AdminHeader.jsp" />

        <div class="flex justify-center">
            <div class="w-full max-w-8xl p-10">
                <h2 class="text-3xl font-bold mb-10 text-center text-gray-800">➕ Add New Movie</h2>

                <% String msg = request.getParameter("msg"); %>
                <% if ("success".equals(msg)) { %>
                    <p class="text-green-600 mb-6 text-center font-semibold">✅ Movie added successfully!</p>
                <% } else if ("error".equals(msg)) { %>
                    <p class="text-red-600 mb-6 text-center font-semibold">❌ Error adding movie. Try again.</p>
                <% } %>

                <form action="AddMoviesServlet" method="post" enctype="multipart/form-data"
                      class="grid grid-cols-1 md:grid-cols-3 gap-10">

                    <!-- Column 1: Movie Info -->
                    <div class="flex flex-col gap-6">
                        <label class="font-medium text-gray-700">Movie Title</label>
                        <input type="text" name="title" placeholder="Enter movie title"
                               class="p-4 border border-gray-300 rounded-xl shadow-sm focus:ring-2 focus:ring-indigo-400 focus:outline-none" required>

                        <label class="font-medium text-gray-700">Status</label>
                        <select name="status" class="p-4 border border-gray-300 rounded-xl shadow-sm focus:ring-2 focus:ring-indigo-400 focus:outline-none" required>
                            <option value="now-showing" selected>Now Showing</option>
                            <option value="coming-soon">Coming Soon</option>
                        </select>
                        
                        <label class="font-medium text-gray-700">Cast Members</label>
                        <textarea name="casts" rows="4" placeholder="Enter cast members separated by commas"
                                  class="p-4 border border-gray-300 rounded-xl shadow-sm focus:ring-2 focus:ring-indigo-400 focus:outline-none"></textarea>
                        
 <!-- Trailer Preview (16:9 ratio) -->
                        <div class="w-full flex justify-center">
                            <div class="w-full sm:w-64 aspect-video">
                                <video id="trailerPreview" class="w-full h-full rounded-2xl border border-gray-200 shadow-lg" controls>
                                    <source src="" type="video/mp4">
                                    Your browser does not support the video tag.
                                </video>
                            </div>
                        </div>

                        <!-- Trailer Upload -->
                        <div class="w-full flex justify-center">
                            <label for="trailerUpload"
                                   class="flex items-center gap-3 cursor-pointer bg-indigo-50 text-indigo-700 font-medium p-3 rounded-xl hover:bg-indigo-100 transition-all">
                                <i data-feather="video"></i> Upload Trailer
                            </label>
                            <input type="file" name="trailer" id="trailerUpload" class="hidden" accept="video/*" required>
                        </div>
                       
                    </div>

                    <!-- Column 2: Cast, Genre, Synopsis -->
                    <div class="flex flex-col gap-6">
						<!-- Duration (3 inputs in a row) -->
<label class="font-medium text-gray-700">Duration</label>
<div class="flex gap-4">
    <input type="number" name="hours" placeholder="Hr" min="1" max="24"
           class="no-spinner w-20 p-3 border border-gray-300 rounded-xl shadow-sm focus:ring-2 focus:ring-indigo-400 focus:outline-none">

    <input type="number" name="minutes" placeholder="Min" min="0" max="59"
           class="no-spinner w-20 p-3 border border-gray-300 rounded-xl shadow-sm focus:ring-2 focus:ring-indigo-400 focus:outline-none">

    <input type="number" name="seconds" placeholder="Sec" min="0" max="59"
           class="no-spinner w-20 p-3 border border-gray-300 rounded-xl shadow-sm focus:ring-2 focus:ring-indigo-400 focus:outline-none">
</div>

<!-- Hidden field to hold final formatted duration -->
<input type="hidden" name="duration" id="durationField" required>
						

                        <label class="font-medium text-gray-700">Director</label>
                        <input type="text" name="director" placeholder="Director Name"
                               class="p-4 border border-gray-300 rounded-xl shadow-sm focus:ring-2 focus:ring-indigo-400 focus:outline-none" required>
                               
                       
                        <label class="font-medium text-gray-700">Synopsis</label>
                        <textarea name="synopsis" rows="4" placeholder="Movie synopsis"
                                  class="p-4 border border-gray-300 rounded-xl shadow-sm focus:ring-2 focus:ring-indigo-400 focus:outline-none"></textarea>
                                  
                                   <label class="font-medium text-gray-700">Genres</label>
                        <input type="text" name="genres" placeholder="Enter genres"
                               class="p-4 w-full border border-gray-300 rounded-xl shadow-sm focus:ring-2 focus:ring-indigo-400 focus:outline-none">
                               
                               
                                  
                    </div>

                    <!-- Column 3: Poster & Trailer Preview -->
                    <div class="flex flex-col gap-6 items-start">
                    


                        <!-- Poster Preview (2:3 ratio) -->
                        <div class="w-full flex justify-center">
                            <div class="w-80 aspect-[2/3]">
                                <img id="posterPreview" src="assets/img/cart_empty.png" alt="Poster Preview"
                                     class="w-full h-full object-cover rounded-2xl border border-gray-200 shadow-lg">
                            </div>
                        </div>

                        <!-- Poster Upload -->
                        <div class="w-full flex justify-center">
                            <label for="posterUpload"
                                   class="flex items-center gap-3 cursor-pointer bg-indigo-50 text-indigo-700 font-medium p-3 rounded-xl hover:bg-indigo-100 transition-all">
                                <i data-feather="camera"></i> Upload Poster
                            </label>
                            <input type="file" name="poster" id="posterUpload" class="hidden" accept="image/*" required>
                        </div>

                        

                        <!-- Submit Button -->
                        <div class="w-full flex justify-center">
                            <button type="submit"
                                    class="bg-indigo-600 text-white p-3 px-10 rounded-2xl hover:bg-indigo-700 shadow-lg transition-all font-semibold mt-4">
                                Add Movie
                            </button>
                        </div>

                    </div>

                </form>
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
                } else {
                    posterPreview.src = 'assets/img/cart_empty.png';
                }
            });

            // Trailer preview
            const trailerInput = document.getElementById('trailerUpload');
            const trailerPreview = document.getElementById('trailerPreview');
            trailerInput.addEventListener('change', () => {
                if (trailerInput.files.length > 0) {
                    const file = trailerInput.files[0];
                    const url = URL.createObjectURL(file);
                    trailerPreview.src = url;
                    trailerPreview.load();
                } else {
                    trailerPreview.src = "";
                }
            });
        </script>
        <style>
    /* Hide spinner in Chrome, Safari, Edge */
    input[type=number].no-spinner::-webkit-outer-spin-button,
    input[type=number].no-spinner::-webkit-inner-spin-button {
        -webkit-appearance: none;
        margin: 0;
    }

    /* Hide spinner in Firefox */
    input[type=number].no-spinner {
        -moz-appearance: textfield;
    }
</style>
        <script>
    const form = document.querySelector("form");
    const durationField = document.getElementById("durationField");

    form.addEventListener("submit", (e) => {
        const hrs = form.hours.value || 0;
        const mins = form.minutes.value || 0;
        const secs = form.seconds.value || 0;

        let duration = "";
        if (hrs > 0) duration += hrs + "h ";
        if (mins > 0) duration += mins + "m ";
        if (secs > 0) duration += secs + "s";

        durationField.value = duration.trim();
    });
</script>
        

    </div>
</div>

<jsp:include page="layout/JSPFooter.jsp" />
