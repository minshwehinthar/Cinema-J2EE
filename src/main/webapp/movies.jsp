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
                <button class="nav-btn px-4 py-2 border  bg-red-600 text-white text-sm font-medium rounded-md transition" data-filter="all">All</button>
                <button class="nav-btn px-4 py-2 border border-black bg-white text-black text-sm font-medium rounded-md transition" data-filter="now-showing">Now Showing</button>
                <button class="nav-btn px-4 py-2 border border-black bg-white text-black text-sm font-medium rounded-md transition" data-filter="coming-soon">Coming Soon</button>
            </div>
        </div>
    </div>

    <!-- Sidebar Toggle Button -->
    <button id="sidebar-toggle"
        class="fixed top-[80px] right-0 z-50 bg-red-600 text-white px-3 py-1 rounded-l-lg shadow-lg hover:bg-red-700 transition">
        =
    </button>

    <!-- Right Sidebar for Theater Filters -->
    <%
        TheaterDAO theaterDao = new TheaterDAO();
        ArrayList<Theater> theaters = (ArrayList<Theater>) theaterDao.getAllTheaters();
    %>
    <aside id="right-sidebar"
        class="fixed top-[64px] right-0 w-64 h-[600px] bg-white border-l border-gray-200 rounded-md shadow-md overflow-y-auto p-5 transform translate-x-full z-100 transition-transform duration-300 ease-in-out lg:translate-x-0 lg:block">
        <div class="flex justify-between items-center mb-3">
            <h3 class="text-lg font-semibold text-gray-800">Filter by Theater</h3>
            <button id="sidebar-close"
                class="lg:hidden text-gray-600 hover:text-red-600 text-xl font-bold">✕</button>
        </div>

        <ul class="space-y-1 overflow-hidden">
            <li class="theater-btn px-3 py-2 text-red-700 bg-red-100 rounded-lg cursor-pointer font-semibold" data-theater="all">
                Show All Theaters
            </li>

            <%
                if (theaters != null && theaters.size() > 0) {
                    for (Theater t : theaters) {
            %>
            <li class="theater-btn px-3 py-2 text-gray-700 rounded-lg cursor-pointer hover:bg-red-50 hover:text-red-700 transition"
                data-theater="<%=t.getTheaterId()%>">
                <span class="block font-medium"><%=t.getName()%></span>
                <span class="block text-xs text-gray-500"><%=t.getLocation()%></span>
            </li>
            <%
                    }
                } else {
            %>
            <p class="text-gray-500 text-sm mt-3">No theaters available.</p>
            <%
                }
            %>
        </ul>
    </aside>

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
                    for(Theater t : movieTheaters) {
                        if(!theaterIds.isEmpty()) theaterIds += ",";
                        theaterIds += t.getTheaterId();
                    }

                    String badgeClass = "bg-gray-700 text-white";
                    if ("now-showing".equalsIgnoreCase(status)) {
                        badgeClass = "bg-green-500 text-white";
                    } else if ("coming-soon".equalsIgnoreCase(status)) {
                        badgeClass = "bg-orange-300 text-black";
                    }
            %>
            <div class="movie-card group relative overflow-hidden rounded-xl shadow-md border border-gray-200"
                 data-status="<%= status != null ? status : "" %>"
                 data-title="<%= m.getTitle() != null ? m.getTitle().toLowerCase() : "" %>"
                 data-theaters="<%= theaterIds %>">
                 
                <a href="moviedetails.jsp?movie_id=<%= m.getMovie_id() %>" class="block relative">
                    <img src="GetMoviesPosterServlet?movie_id=<%= m.getMovie_id() %>" 
                         class="w-full aspect-[2/3] object-cover transition-transform duration-300 group-hover:scale-105" />
                    <div class="absolute bottom-0 left-0 w-full bg-black/40 backdrop-blur-xs p-4 opacity-0 group-hover:opacity-100 transition-opacity duration-300">
                        <h3 class="text-white font-bold text-lg truncate"><%= m.getTitle() %></h3>
                        <p class="text-gray-300 text-sm truncate"><%= m.getDuration() %></p>
                        <p class="text-gray-200 text-xs line-clamp-3 mt-1">
                            <%= m.getGenres() != null ? m.getGenres() : "N/A" %>
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
    const sidebarToggle = document.getElementById('sidebar-toggle');
    const rightSidebar = document.getElementById('right-sidebar');

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

    // ✅ Separate setActive for status filter (red)
    function setActiveStatus(buttons, clicked) {
        buttons.forEach(btn => {
            btn.classList.remove("bg-red-600", "text-white", "border-red-600");
            btn.classList.add("bg-white", "text-black", "border-black");
        });
        clicked.classList.remove("bg-white", "text-black", "border-black");
        clicked.classList.add("bg-red-600", "text-white", "border-red-600");
    }

    // ✅ Separate setActive for theater filter (light red)
    function setActiveTheater(buttons, clicked) {
        buttons.forEach(btn => {
            btn.classList.remove("bg-red-100", "text-red-700", "font-semibold");
            btn.classList.add("bg-white", "text-gray-700", "font-normal");
        });
        clicked.classList.remove("bg-white", "text-gray-700", "font-normal");
        clicked.classList.add("bg-red-100", "text-red-700", "font-semibold");
    }

    searchInput.addEventListener("input", () => {
        clearTimeout(debounceTimeout);
        debounceTimeout = setTimeout(filterMovies, 500);
    });

    navButtons.forEach(btn => {
        btn.addEventListener("click", () => {
            setActiveStatus(navButtons, btn);
            activeFilter = btn.dataset.filter;
            filterMovies();
        });
    });

    theaterButtons.forEach(btn => {
        btn.addEventListener("click", () => {
            setActiveTheater(theaterButtons, btn);
            activeTheater = btn.dataset.theater;
            filterMovies();
        });
    });

    // Sidebar toggle
    sidebarToggle.addEventListener('click', () => {
        const isOpen = !rightSidebar.classList.contains('translate-x-full');
        rightSidebar.classList.toggle('translate-x-full');
        sidebarToggle.textContent = isOpen ? '-' : '=';
    });

    // Close sidebar by clicking outside
    document.addEventListener('click', (e) => {
        if (!rightSidebar.contains(e.target) && !sidebarToggle.contains(e.target) && !rightSidebar.classList.contains('translate-x-full')) {
            rightSidebar.classList.add('translate-x-full');
            sidebarToggle.textContent = '=';
        }
    });
});
</script>
