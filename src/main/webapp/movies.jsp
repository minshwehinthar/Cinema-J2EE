<%@ page import="com.demo.model.Movies" %>
<%@ page import="com.demo.model.Theater" %>
<%@ page import="com.demo.dao.TheaterMoviesDao" %>
<%@ page import="com.demo.dao.TheaterDAO" %>
<%@ page import="java.util.ArrayList" %>

<jsp:include page="layout/JSPHeader.jsp"></jsp:include>
<jsp:include page="layout/header.jsp"></jsp:include>

<section class="bg-gray-50 min-h-screen py-16 px-6 md:px-12">
    <!-- Header Row -->
    <div class="max-w-8xl mx-auto flex flex-col md:flex-row md:items-center md:justify-between mb-12">
        <!-- Left: Title -->
        <div class="mb-6 md:mb-0">
            <h1 class="text-4xl md:text-5xl font-bold tracking-tight text-black">Movies</h1>
            <p class="text-gray-600 text-base mt-2">Explore now-showing hits & upcoming blockbusters</p>
        </div>

        <!-- Right: Search + Filters -->
        <div class="flex flex-col items-end gap-4 w-full md:w-auto">
            <!-- Search Bar -->
            <input id="searchInput" type="text" placeholder="Search movies..." 
                   class="w-full md:w-80 px-4 py-3 border border-gray-300 text-black text-sm rounded-md focus:ring-2 focus:ring-black focus:outline-none" />

            <!-- Status Filter Buttons -->
            <div class="flex gap-2 flex-wrap justify-end mt-3">
                <button class="nav-btn px-4 py-2 border border-black bg-black text-white text-sm font-medium rounded-md hover:bg-gray-800 transition" data-filter="all">All Movies</button>
                <button class="nav-btn px-4 py-2 border border-black bg-white text-black text-sm font-medium rounded-md hover:bg-gray-100 transition" data-filter="now-showing">Now Showing</button>
                <button class="nav-btn px-4 py-2 border border-black bg-white text-black text-sm font-medium rounded-md hover:bg-gray-100 transition" data-filter="coming-soon">Coming Soon</button>
            </div>

            <!-- Theater Filter Buttons -->
            <%
                TheaterDAO theaterDao = new TheaterDAO();
                ArrayList<Theater> theaters = (ArrayList<Theater>) theaterDao.getAllTheaters();
            %>
            <div class="flex gap-2 flex-wrap justify-end mt-3">
               
                <button class="theater-btn px-3 py-1 border border-black bg-black text-white text-sm font-medium rounded-md hover:bg-gray-800 transition" data-theater="all">All</button>
                <% for(Theater t : theaters) { %>
                    <button class="theater-btn px-3 py-1 border border-black bg-white text-black text-sm font-medium rounded-md hover:bg-gray-100 transition"
                            data-theater="<%= t.getTheaterId() %>">
                        <%= t.getName() %>
                    </button>
                <% } %>
            </div>
        </div>
    </div>

    <!-- Movies Grid -->
    <div class="max-w-8xl mx-auto">
        <div class="movie-grid grid grid-cols-1 sm:grid-cols-2 md:grid-cols-4 lg:grid-cols-5 gap-8">
            <%
                TheaterMoviesDao dao = new TheaterMoviesDao();
                ArrayList<Movies> moviesList = dao.getMoviesPickedByTheaters();

                for(Movies m : moviesList) {
                    String status = m.getStatus();
                    ArrayList<Theater> movieTheaters = dao.getTheatersByMovie(m.getMovie_id());
                    String theaterIds = "";
                    String theaterNames = "";
                    for(Theater t : movieTheaters) {
                        if(!theaterIds.isEmpty()) theaterIds += ",";
                        theaterIds += t.getTheaterId();

                        if(!theaterNames.isEmpty()) theaterNames += ", ";
                        theaterNames += t.getName();
                    }

                    // Set badge color based on status
                    String badgeClass = "bg-gray-700 text-white";
                    if ("now-showing".equalsIgnoreCase(status)) {
                        badgeClass = "bg-green-500 text-white"; // green
                    } else if ("coming-soon".equalsIgnoreCase(status)) {
                        badgeClass = "bg-orange-300 text-black"; // yellow
                    }
            %>
            <!-- Movie Card -->
            <div class="movie-card group relative overflow-hidden rounded-xl shadow-md border border-gray-200"
                 data-status="<%= status != null ? status : "" %>"
                 data-title="<%= m.getTitle() != null ? m.getTitle().toLowerCase() : "" %>"
                 data-theaters="<%= theaterIds %>">
                 
                <a href="moviedetails.jsp?movie_id=<%= m.getMovie_id() %>" class="block relative">
                    <!-- Poster Image with realistic ratio -->
                    <img src="GetMoviesPosterServlet?movie_id=<%= m.getMovie_id() %>" 
                         class="w-full aspect-[2/3] object-cover transition-transform duration-300 group-hover:scale-105" />

                    <!-- Overlay Info with blur -->
                    <div class="absolute bottom-0 left-0 w-full bg-black/40 backdrop-blur-xs p-4 opacity-0 group-hover:opacity-100 transition-opacity duration-300">
                        <h3 class="text-white font-bold text-lg truncate"><%= m.getTitle() != null ? m.getTitle() : "Untitled" %></h3>
                        <p class="text-gray-300 text-sm truncate"><%= m.getDuration() %></p>
                        <p class="text-gray-200 text-xs line-clamp-3 mt-1">
    <%= (m.getSynopsis() != null && !m.getSynopsis().trim().isEmpty()) 
            ? m.getSynopsis() 
            : "No synopsis available." %>
</p>

                        <span class="inline-block mt-2 px-2 py-1 text-xs font-semibold rounded-full uppercase <%= badgeClass %>">
                            <%= status != null ? status : "Unknown" %>
                        </span>
                    </div>
                </a>
            </div>
            <% } %>
        </div>
    </div>
</section>

<jsp:include page="layout/footer.jsp"></jsp:include>
<jsp:include page="layout/JSPFooter.jsp"></jsp:include>

<!-- Search + Filter Script -->
<script>
document.addEventListener("DOMContentLoaded", () => {
    const searchInput = document.getElementById("searchInput");
    const navButtons = document.querySelectorAll(".nav-btn");
    const theaterButtons = document.querySelectorAll(".theater-btn");
    const movieCards = document.querySelectorAll(".movie-card");

    let activeFilter = "all";
    let activeTheater = "all";
    let debounceTimeout;

    function filterMovies() {
        const query = searchInput.value.toLowerCase().trim();

        movieCards.forEach(card => {
            const status = card.dataset.status || "";
            const title = card.dataset.title || "";
            const theaters = card.dataset.theaters ? card.dataset.theaters.split(",") : [];

            const matchesFilter = (activeFilter === "all" || status === activeFilter);
            const matchesTheater = (activeTheater === "all" || theaters.includes(activeTheater));
            const matchesSearch = title.includes(query);

            card.style.display = (matchesFilter && matchesTheater && matchesSearch) ? "" : "none";
        });
    }

    function setActive(buttons, clicked) {
        buttons.forEach(btn => {
            btn.classList.remove("bg-black","text-white");
            btn.classList.add("bg-white","text-black");
        });
        clicked.classList.remove("bg-indigo-600","text-black");
        clicked.classList.remove("bg-white","text-black");
        
        clicked.classList.add("bg-black","text-white");
    }

    // Debounced search
    searchInput.addEventListener("input", () => {
        clearTimeout(debounceTimeout);
        debounceTimeout = setTimeout(filterMovies, 500);
    });

    // Status filter buttons
    navButtons.forEach(btn => {
        btn.addEventListener("click", () => {
            setActive(navButtons, btn);
            activeFilter = btn.dataset.filter;
            filterMovies();
        });
    });

    // Theater filter buttons
    theaterButtons.forEach(btn => {
        btn.addEventListener("click", () => {
            setActive(theaterButtons, btn);
            activeTheater = btn.dataset.theater;
            filterMovies();
        });
    });
});
</script>
