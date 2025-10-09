<%@ page contentType="text/html;charset=UTF-8" language="java"%>
<%@ page import="com.demo.model.Movies"%>
<%@ page import="com.demo.dao.MoviesDao"%>
<%@ page import="java.sql.*"%>
<%@ page import="java.util.Base64"%>
<%@ page import="com.demo.model.User"%>

<%
// Get the logged-in user from session
User user = (User) session.getAttribute("user");

// Only allow admin or theater_admin
if (user == null || (!"admin".equals(user.getRole()) && !"theateradmin".equals(user.getRole()))) {
	response.sendRedirect("login.jsp?msg=unauthorized");
	return; // stop rendering the rest of the page
}

String idParam = request.getParameter("id");
Movies movie = null;
String posterBase64 = "";
String posterType = "";

if (idParam != null) {
	int movieId = Integer.parseInt(idParam);
	MoviesDao dao = new MoviesDao();
	movie = dao.getMovieById(movieId);

	if (movie != null) {
		Connection con = new com.demo.dao.MyConnection().getConnection();
		try {
	PreparedStatement ps = con.prepareStatement("SELECT poster, postertype FROM movies WHERE movie_id=?");
	ps.setInt(1, movieId);
	ResultSet rs = ps.executeQuery();
	if (rs.next()) {
		byte[] posterBytes = rs.getBytes("poster");
		posterType = rs.getString("postertype");
		if (posterBytes != null) {
			posterBase64 = Base64.getEncoder().encodeToString(posterBytes);
		}
	}
	rs.close();
	ps.close();
		} catch (Exception e) {
	e.printStackTrace();
		} finally {
	con.close();
		}
	}
}
%>

<jsp:include page="layout/JSPHeader.jsp" />

<div class="flex min-h-screen">
	<!-- Sidebar -->
	<jsp:include page="layout/sidebar.jsp" />

	<!-- Main content -->
	<div class="flex-1 sm:ml-64">
		<!-- Admin Header -->
		<jsp:include page="layout/AdminHeader.jsp" />

		<div class="">
			<!-- Dashboard modules -->
			<div class="max-w-8xl mx-auto px-4 py-8">
				<!-- Breadcrumb -->
				<nav class="text-gray-500 text-sm mb-6" aria-label="Breadcrumb">
					<ol class="list-none p-0 inline-flex">
						<li><a href="home.jsp" class="hover:text-red-600">Home</a></li>
						<li><span class="mx-2">/</span></li>
						<li><a href="moviesList.jsp"
							class="hover:text-red-600">Movies Management</a></li>
						<li><span class="mx-2">/</span></li>
						<li class="text-gray-900 font-semibold">Movie Details</li>
					</ol>
				</nav>

				<%
				if (movie == null) {
				%>
				<div class="text-center py-20">
					<div class="w-24 h-24 mx-auto mb-4 text-gray-300">
						<svg fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round"
								stroke-linejoin="round" stroke-width="1"
								d="M19 11H5m14 0a2 2 0 012 2v6a2 2 0 01-2 2H5a2 2 0 01-2-2v-6a2 2 0 012-2m14 0V9a2 2 0 00-2-2M5 11V9a2 2 0 012-2m0 0V5a2 2 0 012-2h6a2 2 0 012 2v2M7 7h10" />
                    </svg>
					</div>
					<h3 class="text-lg font-medium text-gray-600 mb-2">Movie not
						found</h3>
					<p class="text-gray-500">The movie you're looking for doesn't
						exist.</p>
				</div>
				<%
				} else {
				String posterUrl = "GetMoviesPosterServlet?movie_id=" + movie.getMovie_id();
				String trailerUrl = "GetMoviesTrailerServlet?movie_id=" + movie.getMovie_id();
				String status = movie.getStatus() != null ? movie.getStatus() : "";
				boolean isNowShowing = "now-showing".equalsIgnoreCase(status);
				%>

				<div class="flex flex-col lg:flex-row gap-10">
					<!-- Poster -->
					<div class="lg:w-5/12 w-full flex justify-center">
						<div
							class="w-[300px] h-[450px] rounded-2xl shadow-md overflow-hidden bg-gray-200">
							<%
							if (!posterBase64.isEmpty()) {
							%>
							<img src="data:<%=posterType%>;base64,<%=posterBase64%>"
								alt="<%=movie.getTitle()%> Poster"
								class="w-full h-full object-cover" />
							<%
							} else {
							%>
							<div class="w-full h-full flex items-center justify-center">
								<svg class="w-16 h-16 text-gray-400" fill="none"
									stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round"
										stroke-linejoin="round" stroke-width="2"
										d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z"></path>
                            </svg>
							</div>
							<%
							}
							%>
						</div>
					</div>

					<!-- Movie Info -->
					<div class="lg:w-7/12 w-full flex flex-col justify-between">
						<div class="mb-8">
							<h1 class="mb-6 text-3xl font-bold leading-tight text-red-900">
								<%=movie.getTitle()%>
							</h1>

							<table class="w-full text-gray-700 border-collapse">
								<tbody>
									<tr class="mb-2">
										<td class="py-2 font-semibold w-32">Status:</td>
										<td class="py-2"><span
											class="px-3 py-1 rounded-full text-sm font-medium <%="Released".equals(movie.getStatus())
		? "bg-green-100 text-green-800 border border-green-200"
		: "bg-yellow-100 text-yellow-800 border border-yellow-200"%>">
												<%=movie.getStatus() != null ? movie.getStatus() : "N/A"%>
										</span></td>
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

							<div class="mt-8">
								<h3 class="text-xl font-semibold text-gray-900 mb-4">Synopsis</h3>
								<p class="text-lg leading-relaxed text-gray-700">
									<%=movie.getSynopsis() != null ? movie.getSynopsis() : "No synopsis available."%>
								</p>
							</div>
						</div>

						<!-- Action Buttons -->
						<div class="flex flex-wrap gap-4 mt-8">
							<!-- Edit Button -->
							<a href="editMovie.jsp?movieId=<%=movie.getMovie_id()%>"
								class="py-3 px-6 flex items-center justify-center text-white font-semibold border border-red-500 rounded-md shadow-md bg-red-500 hover:bg-red-600 transition-colors duration-200 text-center">
								<svg xmlns="http://www.w3.org/2000/svg" fill="none"
									viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor"
									class="w-5 h-5 mr-2">
                            <path stroke-linecap="round"
										stroke-linejoin="round"
										d="m16.862 4.487 1.687-1.688a1.875 1.875 0 1 1 2.652 2.652L10.582 16.07a4.5 4.5 0 0 1-1.897 1.13L6 18l.8-2.685a4.5 4.5 0 0 1 1.13-1.897l8.932-8.931Zm0 0L19.5 7.125M18 14v4.75A2.25 2.25 0 0 1 15.75 21H5.25A2.25 2.25 0 0 1 3 18.75V8.25A2.25 2.25 0 0 1 5.25 6H10" />
                        </svg> Edit Movie
							</a>

							<!-- Watch Trailer Button -->
							<button
								class="movie-trailer-btn py-3 px-6 flex items-center justify-center font-semibold border border-red-500 rounded-md bg-white text-red-500 shadow-sm hover:bg-red-50 hover:text-red-600 transition-colors duration-200 text-center">
								<svg xmlns="http://www.w3.org/2000/svg" fill="none"
									viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor"
									class="w-5 h-5 mr-2">
                            <path stroke-linecap="round"
										stroke-linejoin="round"
										d="M5.25 5.653c0-.856.917-1.398 1.667-.986l11.54 6.347a1.125 1.125 0 0 1 0 1.972l-11.54 6.347a1.125 1.125 0 0 1-1.667-.986V5.653Z" />
                        </svg>
								Watch Trailer
							</button>
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
                        <path stroke-linecap="round"
									stroke-linejoin="round" d="M6 18 18 6M6 6l12 12" />
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
				<%
				}
				%>
			</div>
		</div>
	</div>
</div>

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

if (trailerBtn) {
    trailerBtn.addEventListener('click', openTrailer);
}
if (trailerClose) {
    trailerClose.addEventListener('click', closeTrailer);
}
if (trailerPopup) {
    trailerPopup.addEventListener('click', (e) => {
        if (e.target === trailerPopup) closeTrailer();
    });
}
</script>

<jsp:include page="layout/footer.jsp" />
<jsp:include page="layout/JSPFooter.jsp" />