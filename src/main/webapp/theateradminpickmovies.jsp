<%@ page import="com.demo.model.Movies" %>
<%@ page import="com.demo.dao.MoviesDao" %>
<%@ page import="java.util.ArrayList" %>

<jsp:include page="layout/JSPHeader.jsp"/>
<div class="flex min-h-screen bg-gray-100">

    <!-- Sidebar -->
    <jsp:include page="layout/sidebar.jsp"/>

    <!-- Main Content -->
    <div class="flex-1 sm:ml-64">
        <jsp:include page="layout/AdminHeader.jsp"/>

        <div class="p-8 max-w-8xl">
            <h1 class="text-4xl font-bold mb-8 text-indigo-700 text-center">Pick Movies for Your Theater</h1>

            <%-- Top Category Section --%>
            <div class="flex gap-4 overflow-x-auto mb-6">
                <button class="category-btn px-4 py-2 border rounded-md font-semibold" data-status="all">
                    All
                </button>
                <button class="category-btn px-4 py-2 border rounded-md font-semibold" data-status="now-showing">
                    Now Showing
                </button>
                <button class="category-btn px-4 py-2 border rounded-md font-semibold" data-status="coming-soon">
                    Coming Soon
                </button>
            </div>

            <%-- Movie Grid --%>
            <div id="moviesGrid" class="grid grid-cols-10 gap-6">
                <%
                    MoviesDao dao = new MoviesDao();
                    ArrayList<Movies> moviesList = dao.getAllMovies();

                    for (Movies m : moviesList) {
                        String movieStatus = m.getStatus() != null ? m.getStatus().toLowerCase() : "now-showing";
                %>
                <div class="bg-white rounded-2xl shadow-md overflow-hidden cursor-pointer hover:shadow-xl transition duration-300 movie-card"
                     data-movie-id="<%= m.getMovie_id() %>"
                     data-movie-status="<%= movieStatus %>"
                     data-movie-title="<%= m.getTitle() %>"
                     data-movie-desc="<%= m.getSynopsis() != null ? m.getSynopsis() : "" %>"
                     data-movie-cast="<%= m.getCasts() != null ? m.getCasts() : "" %>"
                     data-movie-duration="<%= m.getDuration() != null ? m.getDuration() : "" %>"
                     data-movie-director="<%= m.getDirector() != null ? m.getDirector() : "" %>"
                     data-movie-genres="<%= m.getGenres() != null ? m.getGenres() : "" %>">

                    <img src="GetMoviesPosterServlet?movie_id=<%= m.getMovie_id() %>" 
                         alt="<%= m.getTitle() %> Poster" 
                         class="h-42 object-cover bg-gray-100 rounded-xl"/>
                </div>
                <%
                    }
                %>
            </div>

            <%-- No movies message --%>
            <div id="noMoviesMessage" class="text-center text-gray-500 mt-6 hidden">
                No movies available in this category.
            </div>

            <%-- 3-Column Detail Section --%>
            <div id="movieDetailSection" class="mt-8 hidden p-6 grid grid-cols-1 lg:grid-cols-3 gap-6">

                <!-- Column 1: Poster -->
                <div class="flex justify-center items-start">
                    <img id="detailPosterImg" src="" alt="Poster" class="w-64 h-96 object-cover rounded-xl"/>
                </div>

                <!-- Column 2: Details -->
                <div class="flex flex-col justify-start gap-2">
                    <h2 id="detailTitle" class="text-2xl font-bold text-indigo-700"></h2>
                    <p id="detailDesc" class="text-gray-700"></p>
                    <p class="text-gray-800"><span class="font-semibold">Director:</span> <span id="detailDirector"></span></p>
                    <p class="text-gray-800"><span class="font-semibold">Cast:</span> <span id="detailCast"></span></p>
                    <p class="text-gray-800"><span class="font-semibold">Genres:</span> <span id="detailGenres"></span></p>
                    <p class="text-gray-800"><span class="font-semibold">Duration:</span> <span id="detailDuration"></span></p>

                    <%-- Trailer Section --%>
                    <!-- Trailer Section -->
<div class="mt-4">
<!--     <h3 class="font-semibold text-gray-800 mb-2">Trailer</h3> -->
    <div class="w-72 h-42 aspect-video rounded-xl overflow-hidden border border-gray-200">
        <video id="detailTrailer" controls class="w-full h-full object-cover">
            <source src="" type="video/mp4">
            Your browser does not support the video tag.
        </video>
    </div>
</div>

                </div>

                <!-- Column 3: Date Form -->
                <div>
                    <form id="pickMovieForm" action="PickMovieServlet" method="post" class="flex flex-col gap-4" onsubmit="return validateDates(this)">
                        <input type="hidden" name="movie_id" id="formMovieId"/>
                        <input type="hidden" name="status" id="formMovieStatus"/>

                        <div>
                            <label class="font-medium text-gray-700">Start Date</label>
                            <input type="date" name="start_date" class="border border-gray-300 rounded-lg p-2 w-full" required
                                   min="<%= java.time.LocalDate.now() %>" 
                                   max="<%= java.time.LocalDate.now().plusWeeks(4) %>">
                        </div>

                        <div>
                            <label class="font-medium text-gray-700">End Date</label>
                            <input type="date" name="end_date" class="border border-gray-300 rounded-lg p-2 w-full" required
                                   min="<%= java.time.LocalDate.now() %>" 
                                   max="<%= java.time.LocalDate.now().plusWeeks(4) %>">
                        </div>

                        <button type="submit" class="mt-2 py-2 bg-indigo-600 text-white rounded-2xl hover:bg-indigo-700 transition font-semibold">
                            Pick Movie
                        </button>
                    </form>
                </div>
                
            </div>
            
        </div>
    </div>
</div>

<script>
    const categoryButtons = document.querySelectorAll('.category-btn');
    const movieCards = document.querySelectorAll('.movie-card');
    const movieDetailSection = document.getElementById('movieDetailSection');
    const detailPosterImg = document.getElementById('detailPosterImg');
    const detailTitle = document.getElementById('detailTitle');
    const detailDesc = document.getElementById('detailDesc');
    const detailDirector = document.getElementById('detailDirector');
    const detailCast = document.getElementById('detailCast');
    const detailGenres = document.getElementById('detailGenres');
    const detailDuration = document.getElementById('detailDuration');
    const detailTrailer = document.getElementById('detailTrailer');
    const formMovieId = document.getElementById('formMovieId');
    const formMovieStatus = document.getElementById('formMovieStatus');
    const noMoviesMessage = document.getElementById('noMoviesMessage');

    // Filter by category
    categoryButtons.forEach(btn => {
        btn.addEventListener('click', () => {
            const status = btn.dataset.status.toLowerCase();
            let anyVisible = false;

            movieCards.forEach(card => {
                if(status === 'all' || card.dataset.movieStatus.toLowerCase() === status){
                    card.classList.remove('hidden');
                    anyVisible = true;
                } else {
                    card.classList.add('hidden');
                }
            });

            // Show/hide no-movies message
            noMoviesMessage.classList.toggle('hidden', anyVisible);

            // Hide detail section and remove highlight
            movieDetailSection.classList.add('hidden');
            movieCards.forEach(c => c.classList.remove('ring-4', 'ring-indigo-500'));

            // ---- Handle Active/Inactive Category Design ----
            categoryButtons.forEach(b => {
                if(b === btn){
                    // Active: red background, red border, white text
                    b.classList.add('bg-red-500', 'border-red-500', 'text-white');
                    b.classList.remove('border-gray-300', 'text-gray-700', 'bg-white');
                } else {
                    // Inactive: gray border only
                    b.classList.add('border-gray-300', 'text-gray-700', 'bg-white');
                    b.classList.remove('bg-red-500', 'border-red-500', 'text-white');
                }
            });
        });
    });

    // Show 3-column details when movie clicked
    movieCards.forEach(card => {
        card.addEventListener('click', function() {
            detailPosterImg.src = card.querySelector('img').src;
            detailTitle.textContent = card.dataset.movieTitle;
            detailDesc.textContent = card.dataset.movieDesc;
            detailDirector.textContent = card.dataset.movieDirector;
            detailCast.textContent = card.dataset.movieCast;
            detailGenres.textContent = card.dataset.movieGenres;
            detailDuration.textContent = card.dataset.movieDuration;

            // Set trailer source dynamically
            const trailerSrc = "GetMoviesTrailerServlet?movie_id=" + card.dataset.movieId;
            detailTrailer.querySelector('source').src = trailerSrc;
            detailTrailer.load();

            formMovieId.value = card.dataset.movieId;
            formMovieStatus.value = card.dataset.movieStatus;

            movieDetailSection.classList.remove('hidden');

            // Highlight selected movie
            movieCards.forEach(c => c.classList.remove('ring-4', 'ring-red-500'));
            card.classList.add('ring-4', 'ring-red-500');
        });
    });

    function validateDates(form) {
        if(form.start_date && form.end_date){
            const start = new Date(form.start_date.value);
            const end = new Date(form.end_date.value);
            if(start > end){
                alert("Start Date must be before End Date!");
                return false;
            }
        }
        return true;
    }

    // Optional: Set default active on page load
    window.addEventListener('DOMContentLoaded', () => {
        if(categoryButtons.length > 0){
            categoryButtons[0].click(); // make "All" active by default
        }
    });
</script>



<jsp:include page="layout/JSPFooter.jsp"/>
