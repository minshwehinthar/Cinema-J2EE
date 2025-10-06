<%@ page import="com.demo.model.Movies" %>
<%@ page import="com.demo.dao.TheaterMoviesDao" %>
<%@ page import="java.util.ArrayList" %>

<jsp:include page="layout/JSPHeader.jsp"/>
<div class="flex min-h-screen bg-white">

    <!-- Sidebar -->
    <jsp:include page="layout/sidebar.jsp"/>

    <!-- Main Content -->
    <div class="flex-1 sm:ml-64">
        <jsp:include page="layout/AdminHeader.jsp"/>

        <div class="p-8 max-w-8xl">
         <!-- Breadcrumb -->
		<nav class="text-gray-500 text-sm mb-4" aria-label="Breadcrumb">
			<ol class="list-none p-0 inline-flex">
				<li><a href="index.jsp" class="hover:text-red-600">Home</a></li>
            <li><span class="mx-2">/</span></li>
            
            
				<li class="flex items-center text-gray-900 font-semibold">Pick Movie
				</li>
			</ol>
		</nav>
            <h1 class="text-4xl font-bold mb-8 text-gray-900 text-center">Select Movie</h1>

            <%-- Session check --%>
            <%
                Integer theaterId = (Integer) session.getAttribute("theater_id");
                if (theaterId == null) {
            %>
            <p class="text-center text-red-600 text-lg">Theater not found. Please login again.</p>
            <% 
                } else { 
                    TheaterMoviesDao dao = new TheaterMoviesDao();
                    ArrayList<Movies> moviesList = dao.getAvailableMoviesForTheater(theaterId);

                    if (moviesList.isEmpty()) {
            %>
            <div class="flex justify-center mt-8">
    <div class="bg-white shadow-lg rounded-2xl p-6 flex items-center gap-4 border-l-4 border-red-500 max-w-md">
        <!-- Icon -->
        <svg class="w-10 h-10 text-red-500 flex-shrink-0" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" d="M12 9v2m0 4h.01M21 12c0 4.97-4.03 9-9 9s-9-4.03-9-9 4.03-9 9-9 9 4.03 9 9z"/>
        </svg>

        <!-- Text -->
        <div class="flex flex-col">
            <h3 class="text-lg font-semibold text-gray-800">No Movies Available</h3>
            <p class="text-gray-600">All movies have already been added to your theater. Check back later for new releases.</p>
        </div>
    </div>
</div>

            <%
                    } else {
            %>

            <%-- Top Category Section --%>
            <div class="flex flex-col sm:flex-row justify-between items-center gap-4 mb-6 overflow-x-auto">
               	<div>
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
               	<div>
                	<a href="addTimeslots.jsp" class="text-white bg-blue-700 hover:bg-blue-800 focus:ring-4 focus:ring-blue-300 font-medium rounded-lg text-sm px-5 py-2.5 me-2 mb-2 dark:bg-blue-600 dark:hover:bg-blue-700 focus:outline-none dark:focus:ring-blue-800">Add Timeslot</a>
                	
                </div>
            </div>

            <%-- Movie Grid --%>
            <div id="moviesGrid" class="grid grid-cols-10 gap-6">
                <%
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
                    <div class="mt-4">
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
                    <form id="PickMovieServlet" action="PickMovieServlet" method="post" class="flex flex-col gap-4" onsubmit="return validateDates(this)">
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

            <% 
                    } // end else movies available
                } // end else theaterId not null
            %>
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

            noMoviesMessage.classList.toggle('hidden', anyVisible);
            movieDetailSection.classList.add('hidden');
            movieCards.forEach(c => c.classList.remove('ring-4', 'ring-indigo-500'));

            categoryButtons.forEach(b => {
                if(b === btn){
                    b.classList.add('bg-red-500', 'border-red-500', 'text-white');
                    b.classList.remove('border-gray-300', 'text-gray-700', 'bg-white');
                } else {
                    b.classList.add('border-gray-300', 'text-gray-700', 'bg-white');
                    b.classList.remove('bg-red-500', 'border-red-500', 'text-white');
                }
            });
        });
    });

    movieCards.forEach(card => {
        card.addEventListener('click', function() {
            detailPosterImg.src = card.querySelector('img').src;
            detailTitle.textContent = card.dataset.movieTitle;
            detailDesc.textContent = card.dataset.movieDesc;
            detailDirector.textContent = card.dataset.movieDirector;
            detailCast.textContent = card.dataset.movieCast;
            detailGenres.textContent = card.dataset.movieGenres;
            detailDuration.textContent = card.dataset.movieDuration;

            const trailerSrc = "GetMoviesTrailerServlet?movie_id=" + card.dataset.movieId;
            detailTrailer.querySelector('source').src = trailerSrc;
            detailTrailer.load();

            formMovieId.value = card.dataset.movieId;
            formMovieStatus.value = card.dataset.movieStatus;

            movieDetailSection.classList.remove('hidden');
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

    window.addEventListener('DOMContentLoaded', () => {
        if(categoryButtons.length > 0){
            categoryButtons[0].click();
        }
    });
</script>

<jsp:include page="layout/JSPFooter.jsp"/>
