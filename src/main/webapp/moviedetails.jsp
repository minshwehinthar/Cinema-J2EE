<%@ page import="com.demo.model.Movies"%>
<%@ page import="com.demo.dao.MoviesDao"%>
<jsp:include page="layout/JSPHeader.jsp"></jsp:include>
<jsp:include page="layout/header.jsp"></jsp:include>

<%
int movie_id = 0;
if (request.getParameter("movie_id") != null) {
	movie_id = Integer.parseInt(request.getParameter("movie_id"));
}

MoviesDao dao = new MoviesDao();
Movies movie = dao.getMovieById(movie_id);

if (movie == null) {
%>
<h2 class="text-center text-2xl text-gray-800">Movie not found.</h2>
<%
} else {
String posterUrl = "GetMoviesPosterServlet?movie_id=" + movie.getMovie_id();
String trailerUrl = "GetMoviesTrailerServlet?movie_id=" + movie.getMovie_id();
String status = movie.getStatus() != null ? movie.getStatus() : "";
boolean isNowShowing = "now-showing".equalsIgnoreCase(status);
%>


<section class="py-8">
	<div class="max-w-8xl mx-auto">
		<!-- Breadcrumb -->
		<nav class="text-gray-500 text-sm mb-4" aria-label="Breadcrumb">
			<ol class="list-none p-0 inline-flex">
				<li><a href="home.jsp" class="hover:text-red-600">Home</a></li>
            <li><span class="mx-2">/</span></li>
            <li><a href="movies.jsp" class="hover:text-red-600">Movies</a></li>
            <li><span class="mx-2">/</span></li>
				<li class="flex items-center text-gray-900 font-semibold">Movie Detailss
				</li>
			</ol>
		</nav>

		<div class="flex flex-col lg:flex-row gap-10 my-8">
			<!-- Poster -->
			<div class="lg:w-5/12 w-full flex justify-center">
				<img class="w-[300px] h-[450px] object-cover rounded-2xl shadow-md"
					src="<%=posterUrl%>" alt="<%=movie.getTitle()%> Poster" />
			</div>

			<!-- Movie Info -->
			<div class="lg:w-7/12 w-full flex flex-col justify-between">
				<div class="mb-8">
					<h1
						class="mb-6 text-3xl  font-bold leading-tight text-red-900">
						<%=movie.getTitle()%>
					</h1>

					<table class="w-full text-gray-700 border-collapse">
						<tbody>
							<tr class="mb-2">
								<td class="py-2 font-semibold w-32">Status:</td>
								<td class="py-2"><%=movie.getStatus() != null ? movie.getStatus() : "N/A"%></td>
							</tr>
							<tr class="mb-2">
								<td class="py-2 font-semibold">Duration:</td>
								<td class="py-2"><%=movie.getDuration() != null ? movie.getDuration() : "N/A"%></td>
							</tr>
							<tr class="mb-2">
								<td class="py-2 font-semibold">Director:</td>
								<td class="py-2"><%=movie.getDirector() != null ? movie.getDirector() : "N/A"%></td>
							</tr>
							<tr class="mb-2">
								<td class="py-2 font-semibold">Cast:</td>
								<td class="py-2"><%=movie.getCasts() != null ? movie.getCasts() : "N/A"%></td>
							</tr>
							<tr class="mb-2">
								<td class="py-2 font-semibold">Genres:</td>
								<td class="py-2"><%=movie.getGenres() != null ? movie.getGenres() : "N/A"%></td>
							</tr>
						</tbody>
					</table>

					<p class="mt-6 text-lg leading-relaxed text-gray-700">
						<%=movie.getSynopsis() != null ? movie.getSynopsis() : "No synopsis available."%>
					</p>
				</div>


				<div class="flex flex-wrap gap-4 mt-4">
					<%
					if (isNowShowing) {
					%>
					<a
						href="GetMovieTheatersServlet?movie_id=<%=movie.getMovie_id()%>"
						class="py-3 px-6 flex items-center justify-center text-white font-semibold border border-red-500 rounded-md shadow-md bg-red-500 hover:bg-red-600 transition-colors duration-200 text-center">
						<svg xmlns="http://www.w3.org/2000/svg" fill="none"
							viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor"
							class="w-5 h-5 mr-2">
              <path stroke-linecap="round" stroke-linejoin="round"
								d="M16.5 6v.75m0 3v.75m0 3v.75m0 3V18m-9-5.25h5.25M7.5 15h3M3.375 5.25c-.621 0-1.125.504-1.125 1.125v3.026a2.999 2.999 0 0 1 0 5.198v3.026c0 .621.504 1.125 1.125 1.125h17.25c.621 0 1.125-.504 1.125-1.125v-3.026a2.999 2.999 0 0 1 0-5.198V6.375c0-.621-.504-1.125-1.125-1.125H3.375Z" />
           </svg> Get Tickets
					</a>
					<%
					}
					%>

					<button
						class="movie-trailer-btn py-3 px-6 flex items-center justify-center font-semibold border border-red-500 rounded-md bg-white text-red-500 shadow-sm hover:bg-red-50 hover:text-red-600 transition-colors duration-200 text-center">
						<i class="fa-solid fa-play mr-2"></i> Watch Trailer
					</button>
				</div>

			</div>
		</div>
	</div>

	<!-- Trailer Popup -->
	<div
		class="trailer-popup hidden fixed inset-0 flex items-center justify-center z-50">
		<!-- Blur layer behind the card -->
		<div class="absolute inset-0 backdrop-blur-xs"></div>

		<div
			class="relative w-full max-w-8xl bg-opacity-80 rounded-lg overflow-hidden transform scale-90 opacity-0 transition-all duration-300 ease-out z-10">
			<!-- Close Button -->
			<button
				class="trailer-close absolute top-3 right-3 text-gray-800 hover:text-red-500 text-3xl font-bold z-20">
				<svg xmlns="http://www.w3.org/2000/svg" fill="none"
					viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor"
					class="size-6">
  <path stroke-linecap="round" stroke-linejoin="round"
						d="M6 18 18 6M6 6l12 12" />
</svg>
			</button>

			<!-- Video Content -->
			<div class="">
				<h3
					class="text-gray-900 text-2xl md:text-3xl font-semibold text-center mb-4">
					<%=movie.getTitle()%>
					- Trailer
				</h3>
				<div
					class="w-full aspect-video rounded-xl overflow-hidden shadow-inner">
					<video class="w-full h-full bg-black" controls>
						<source data-src="<%=trailerUrl%>" type="video/mp4">
						Your browser does not support the video tag.
					</video>
				</div>
			</div>
		</div>
	</div>
</section>

<%
}
%>
<jsp:include page="layout/footer.jsp"></jsp:include>
<jsp:include page="layout/JSPFooter.jsp"></jsp:include>

<script>
const trailerBtn = document.querySelector('.movie-trailer-btn');
const trailerPopup = document.querySelector('.trailer-popup');
const trailerClose = trailerPopup.querySelector('.trailer-close');
const trailerCard = trailerPopup.querySelector('div.relative');
const trailerVideo = trailerPopup.querySelector('video');
const trailerSource = trailerVideo.querySelector('source');

function openTrailer() {
    if (!trailerSource.src) {
        trailerSource.src = trailerSource.getAttribute('data-src');
        trailerVideo.load();
    }
    trailerPopup.classList.remove('hidden');
    requestAnimationFrame(() => {
        trailerCard.classList.remove('scale-90', 'opacity-0');
        trailerCard.classList.add('scale-100', 'opacity-100');
    });
    trailerVideo.play();
}

function closeTrailer() {
    trailerVideo.pause();
    trailerVideo.currentTime = 0;
    trailerCard.classList.remove('scale-100', 'opacity-100');
    trailerCard.classList.add('scale-90', 'opacity-0');
    setTimeout(() => {
        trailerPopup.classList.add('hidden');
    }, 300);
}

trailerBtn.addEventListener('click', openTrailer);
trailerClose.addEventListener('click', closeTrailer);
trailerPopup.addEventListener('click', (e) => {
    if (e.target === trailerPopup) closeTrailer();
});
</script>
<script>
const getTicketsBtn = document.querySelector('a[href*="GetMovieTheatersServlet"]');
if (getTicketsBtn) {
    <% boolean isLoggedIn = session.getAttribute("user") != null; %>
    const isLoggedIn = <%=isLoggedIn%>; // true if user is logged in

    getTicketsBtn.addEventListener('click', function(event) {
        if (!isLoggedIn) {
            event.preventDefault(); // Stop normal navigation

            const goLogin = confirm("You need to login first to get tickets.\n\nPress OK to go to login, or Cancel to stay here.");

            if (goLogin) {
                // Save current URL for redirect after login
                const currentURL = window.location.href;
                sessionStorage.setItem("redirectAfterLogin", currentURL);
                // Go to login page
                window.location.href = "login.jsp?msg=please_login";
            } 
            // If Cancel → do nothing, stay on page
        }
    });
}
</script>

