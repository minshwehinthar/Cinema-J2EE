<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="com.demo.model.User" %>
<%@ page import="com.demo.model.Movies" %>
<%@ page import="com.demo.model.Theater" %>
<%@ page import="com.demo.dao.TheaterMoviesDao" %>
<%@ page import="com.demo.dao.TheaterDAO" %>

<jsp:include page="layout/JSPHeader.jsp"/>

<%
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect("login.jsp?msg=unauthorized");
        return;
    }

    TheaterMoviesDao dao = new TheaterMoviesDao();
    TheaterDAO theaterDao = new TheaterDAO();

    ArrayList<Movies> moviesList = new ArrayList<>();
    ArrayList<Theater> theaters = (ArrayList<Theater>) theaterDao.getAllTheaters();

    int theaterId = 0;

    if ("theateradmin".equals(user.getRole())) {
        moviesList = dao.getMoviesByTheaterAdmin(user.getUserId());
        ArrayList<Theater> filteredTheaters = new ArrayList<>();
        for (Theater t : theaters) {
            if (t.getUserId() == user.getUserId()) {
                filteredTheaters.add(t);
                theaterId = t.getTheaterId();
                break;
            }
        }
        theaters = filteredTheaters;
    } else {
        moviesList = dao.getMoviesPickedByTheaters();
    }
%>

<!-- Full-width Admin Header -->
<div class="fixed top-0 left-0 w-full z-50">
    <jsp:include page="layout/AdminHeader.jsp"/>
</div>

<!-- Page Layout -->
<div class="flex pt-[64px]">
    <!-- Left Sidebar -->
    <jsp:include page="layout/sidebar.jsp"/>

    <!-- Main Content -->
    <div class="flex-1 sm:ml-64 sm:mr-64 p-8">
        <h2 class="text-2xl font-bold mb-6">Now Showing</h2>

        <!-- Movies Grid -->
        <div class="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-6" id="movies-grid">
            <% for (Movies m : moviesList) { 
                   String status = m.getStatus();
                   if ("coming-soon".equalsIgnoreCase(status)) continue;

                   ArrayList<Theater> movieTheatersList = dao.getTheatersByMovie(m.getMovie_id());
                   String movieTheaters = "";
                   if (movieTheatersList != null && !movieTheatersList.isEmpty()) {
                       for (int i = 0; i < movieTheatersList.size(); i++) {
                           movieTheaters += movieTheatersList.get(i).getTheaterId();
                           if (i < movieTheatersList.size() - 1) movieTheaters += ",";
                       }
                   }

                   String movieCategory = m.getGenres() != null && !m.getGenres().isEmpty() ? m.getGenres().split(",")[0].trim().toLowerCase() : "";
            %>
            <div class="movie-card group relative overflow-hidden rounded-xl shadow-md border border-gray-200" 
                 data-status="<%= status != null ? status : "" %>"
                 data-title="<%= m.getTitle() != null ? m.getTitle().toLowerCase() : "" %>"
                 data-theaters="<%= movieTheaters %>"
                 data-category="<%= movieCategory %>">

                <img src="GetMoviesPosterServlet?movie_id=<%= m.getMovie_id() %>" 
                     class="w-full aspect-[2/3] object-cover transition-transform duration-300 group-hover:scale-105" />

                <div class="absolute bottom-0 left-0 w-full bg-black/60 p-4 opacity-0 group-hover:opacity-100 transition-opacity duration-300">
                    <div class="text-white">
                        <h3 class="text-lg font-bold mb-2 truncate"><%= m.getTitle() != null ? m.getTitle() : "Untitled" %></h3>

                        <table class="text-xs w-full mb-2">
                            <tbody>
                                <tr><td class="font-semibold w-20">Status:</td><td><%= status %></td></tr>
                                <tr><td class="font-semibold">Duration:</td><td><%= m.getDuration() != null ? m.getDuration() : "N/A" %></td></tr>
                                <tr><td class="font-semibold">Director:</td><td><%= m.getDirector() != null ? m.getDirector() : "N/A" %></td></tr>
                                <tr><td class="font-semibold">Genres:</td><td><%= m.getGenres() != null ? m.getGenres() : "N/A" %></td></tr>
                            </tbody>
                        </table>

                        <p class="text-xs line-clamp-3 mb-3"><%= (m.getSynopsis() != null && !m.getSynopsis().trim().isEmpty()) ? m.getSynopsis() : "No synopsis available." %></p>

<%
    String statusBadgeClass = "bg-gray-500 text-white";
    if ("now-showing".equalsIgnoreCase(status)) {
        statusBadgeClass = "bg-green-600 text-white";
    } else if ("coming-soon".equalsIgnoreCase(status)) {
        statusBadgeClass = "bg-yellow-500 text-white";
    } else {
        statusBadgeClass = "bg-red-500 text-white";
    }
%>
<span class="inline-block mt-1 px-2 py-1 text-xs font-semibold rounded-full uppercase <%= statusBadgeClass %>"><%= status %></span>

                        <div class="flex flex-wrap gap-2 mt-3">
                            <% if ("admin".equals(user.getRole())) { %>
                                <form action="<%= request.getContextPath() %>/DeleteMovieServlet" method="post">
                                    <input type="hidden" name="movie_id" value="<%= m.getMovie_id() %>" />
                                    <button type="submit" class="px-3 py-1 bg-red-600 text-white text-xs rounded-md hover:bg-red-700 transition">Delete</button>
                                </form>
                            <% } %>

                            <% if ("theateradmin".equals(user.getRole())) { %>
                                <form action="<%= request.getContextPath() %>/RemoveMovieFromTheaterServlet" method="post">
                                    <input type="hidden" name="movie_id" value="<%= m.getMovie_id() %>" />
                                    <input type="hidden" name="theater_id" value="<%= theaterId %>" />
                                    <button type="submit" class="px-3 py-1 bg-yellow-500 text-white text-xs rounded-md hover:bg-yellow-600 transition">Remove</button>
                                </form>
                            <% } %>

                            <button type="button" class="trailer-btn px-3 py-1 border border-white text-white text-xs rounded-md hover:bg-white hover:text-red-600 transition"
                                    data-trailer-url="GetMoviesTrailerServlet?movie_id=<%= m.getMovie_id() %>">
                                Trailer
                            </button>
                        </div>
                    </div>
                </div>
            </div>
            <% } %>
        </div>
    </div>

   <!-- Right Sidebar (Theater Filter with All Button) -->
<% if ("admin".equals(user.getRole())) { %>
<aside id="right-sidebar" 
       class="fixed top-[64px] right-0 w-64 h-[calc(100vh-64px)] bg-white border-l border-gray-200 shadow-md overflow-y-auto p-5 hidden sm:block">
    <h3 class="text-lg font-semibold text-gray-800 mb-3">Theater</h3>

    <ul class="space-y-1">
        <!-- All Button -->
        <li class="theater-filter px-3 py-2 text-blue-700 bg-blue-100 rounded-lg cursor-pointer font-semibold"
            data-theater-id="all">
            Show All
        </li>

        <% if (theaters != null && theaters.size() > 0) { %>
            <% for (Theater t : theaters) { %>
                <li class="theater-filter px-3 py-2 text-gray-700 rounded-lg cursor-pointer hover:bg-blue-50 hover:text-blue-700 transition"
                    data-theater-id="<%= t.getTheaterId() %>">
                    <span class="block font-medium"><%= t.getName() %></span>
                </li>
            <% } %>
        <% } else { %>
            <p class="text-gray-500 text-sm mt-3">No theaters available.</p>
        <% } %>
    </ul>
</aside>
<% } %>

</div>

<!-- Trailer Popup -->
<div class="trailer-popup hidden fixed inset-0 flex items-center justify-center z-50">
    <div class="absolute inset-0 backdrop-blur-xs"></div>
    <div class="relative w-full max-w-8xl bg-opacity-80 rounded-lg overflow-hidden transform scale-90 opacity-0 transition-all duration-300 ease-out z-10">
        <button class="trailer-close absolute top-3 right-3 text-gray-800 hover:text-red-500 text-3xl font-bold z-20">✕</button>
        <div>
            <h3 class="text-gray-900 text-2xl md:text-3xl font-semibold text-center mb-4">Trailer</h3>
            <div class="w-full aspect-video rounded-xl overflow-hidden shadow-inner">
                <video class="w-full h-full bg-black" controls>
                    <source data-src="" type="video/mp4">
                    Your browser does not support the video tag.
                </video>
            </div>
        </div>
    </div>
</div>

<jsp:include page="layout/JSPFooter.jsp"/>

<script>
const trailerBtns = document.querySelectorAll('.trailer-btn');
const trailerPopup = document.querySelector('.trailer-popup');
const trailerClose = trailerPopup.querySelector('.trailer-close');
const trailerVideo = trailerPopup.querySelector('video');
const trailerSource = trailerVideo.querySelector('source');
const trailerCard = trailerPopup.querySelector('div.relative');

trailerBtns.forEach(btn => {
    btn.addEventListener('click', () => {
        const url = btn.getAttribute('data-trailer-url');
        trailerSource.src = url;
        trailerVideo.load();
        trailerPopup.classList.remove('hidden');
        requestAnimationFrame(() => {
            trailerCard.classList.remove('scale-90','opacity-0');
            trailerCard.classList.add('scale-100','opacity-100');
        });
        trailerVideo.play();
    });
});

trailerClose.addEventListener('click', () => {
    trailerVideo.pause();
    trailerVideo.currentTime = 0;
    trailerCard.classList.remove('scale-100','opacity-100');
    trailerCard.classList.add('scale-90','opacity-0');
    setTimeout(() => trailerPopup.classList.add('hidden'), 300);
});

trailerPopup.addEventListener('click', e => {
    if (e.target === trailerPopup) {
        trailerVideo.pause();
        trailerVideo.currentTime = 0;
        trailerCard.classList.remove('scale-100','opacity-100');
        trailerCard.classList.add('scale-90','opacity-0');
        setTimeout(() => trailerPopup.classList.add('hidden'), 300);
    }
});

// Theater filter logic with “All” option
const theaterFilters = document.querySelectorAll('.theater-filter');
const movieCards = document.querySelectorAll('.movie-card');

theaterFilters.forEach(item => {
    item.addEventListener('click', () => {
        const theaterId = item.getAttribute('data-theater-id');

        // reset active
        theaterFilters.forEach(i => i.classList.remove('bg-blue-100','text-blue-700','font-semibold'));
        item.classList.add('bg-blue-100','text-blue-700','font-semibold');

        // show all movies if “All” selected
        if (theaterId === "all") {
            movieCards.forEach(card => card.style.display = '');
            return;
        }

        // filter by theater
        movieCards.forEach(card => {
            const theaters = card.getAttribute('data-theaters').split(",");
            card.style.display = theaters.includes(theaterId) ? '' : 'none';
        });
    });
});
</script>
