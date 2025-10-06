<%@page import="com.demo.dao.ShowtimesDao"%>
<%@page import="com.demo.dao.TimeslotDao"%>
<%@page import="com.demo.model.Timeslot"%>
<%@page import="com.demo.model.Movies"%>
<%@page import="com.demo.dao.MoviesDao"%>
<%@page import="java.time.LocalDate"%>
<%@page import="java.util.ArrayList"%>

<jsp:include page="layout/JSPHeader.jsp"/>
<div class="flex min-h-screen bg-gray-50">

    <!-- Sidebar -->
    <jsp:include page="layout/sidebar.jsp"/>

    <!-- Main Content -->
    <div class="flex-1 sm:ml-64">
        <jsp:include page="layout/AdminHeader.jsp"/>

        <div class="p-8 max-w-8xl mx-auto">
 <!-- Breadcrumb -->
		<nav class="text-gray-500 text-sm mb-8" aria-label="Breadcrumb">
			<ol class="list-none p-0 inline-flex">
				<li><a href="index.jsp" class="hover:text-red-600">Home</a></li>
            <li><span class="mx-2">/</span></li>
            
            <li><a href="theateradminpickmovies.jsp" class="hover:text-red-600">Pick Movie & Date</a></li>
            <li><span class="mx-2">/</span></li>
				<li class="flex items-center text-gray-900 font-semibold">Add Timeslot
				</li>
			</ol>
		</nav>
            <%
                Integer theaterId = (Integer) session.getAttribute("theater_id");
                if (theaterId == null) {
            %>
                <p class="text-center text-red-600 text-lg font-medium">Theater not found. Please login again.</p>
            <% 
                } else { 
                    int movieId = Integer.parseInt(request.getParameter("movie_id"));

                    ShowtimesDao showDao = new ShowtimesDao();
                    TimeslotDao slotDao = new TimeslotDao();
                    MoviesDao movieDao = new MoviesDao();

                    Movies movie = movieDao.getMovieById(movieId);
                    LocalDate[] dates = showDao.getMovieDates(theaterId, movieId);

                    if (movie == null || dates == null) {
            %>
                        <p class="text-center text-red-600 text-lg font-medium">Movie details not found. Please pick movie again.</p>
            <%
                    } else {
                        LocalDate start = dates[0];
                        LocalDate end = dates[1];

                        String msg = request.getParameter("msg");
                        if ("no_selection".equals(msg)) {
            %>
                            <p class="text-center text-yellow-600 font-medium mb-6"> No timeslots selected for any date.</p>
            <%
                        }
            %>

            <!-- Movie Header -->
            <div class="flex flex-col md:flex-row gap-8 mb-10 border-b border-gray-200 pb-8">
                <!-- Poster -->
                <div class="flex-shrink-0">
                    <img src="GetMoviesPosterServlet?movie_id=<%= movieId %>" 
                         alt="<%= movie.getTitle() %> Poster" 
                         class="w-56 h-80 object-cover rounded-lg"/>
                </div>

                <!-- Movie Info -->
                <div class="flex flex-col justify-center space-y-3">
                    <h1 class="text-3xl font-bold text-gray-900"><%= movie.getTitle() %></h1>
                    <p class="text-gray-600"><%= movie.getSynopsis() != null ? movie.getSynopsis() : "" %></p>
                    <ul class="text-gray-700 text-sm space-y-1">
                        <li><span class="font-semibold">Director:</span> <%= movie.getDirector() != null ? movie.getDirector() : "-" %></li>
                        <li><span class="font-semibold">Cast:</span> <%= movie.getCasts() != null ? movie.getCasts() : "-" %></li>
                        <li><span class="font-semibold">Genres:</span> <%= movie.getGenres() != null ? movie.getGenres() : "-" %></li>
                        <li><span class="font-semibold">Duration:</span> <%= movie.getDuration() != null ? movie.getDuration() : "-" %></li>
                    </ul>
                </div>
            </div>

            <!-- Timeslot Assignment -->
            <form action="AssignTimeslotServlet" method="post" class="space-y-10">
                <input type="hidden" name="movie_id" value="<%= movieId %>"/>

                <div class="grid md:grid-cols-2 lg:grid-cols-3 gap-10">
                    <%
                        LocalDate current = start;
                        while (!current.isAfter(end)) {
                            ArrayList<Timeslot> allSlots = slotDao.getTimeslotsByTheater(theaterId);
                            ArrayList<Timeslot> freeSlots = showDao.getFreeTimeslotsForDate(theaterId, current, allSlots);

                            if (freeSlots.isEmpty()) {
                    %>
                        <div class="flex flex-col">
                            <h2 class="text-lg font-semibold text-sky-600"><%= current %></h2>
                            <p class="text-gray-400 mt-2">No free slots available</p>
                        </div>
                    <%
                            } else {
                    %>
                        <div class="flex flex-col">
                            <h2 class="text-lg font-semibold text-rose-600 mb-2"><%= current %></h2>
                            <div class="relative">
                                <!-- Hidden select (for submission) -->
                                <select name="slot_<%= current %>" class="hidden">
                                    <option value="">-- Select Slot --</option>
                                    <% for (Timeslot t : freeSlots) { %>
                                        <option value="<%= t.getSlotId() %>">
                                            <%= t.getStartTime() %> - <%= t.getEndTime() %>
                                        </option>
                                    <% } %>
                                </select>

                                <!-- Custom Dropdown -->
                                <button type="button"
                                    class="dropdown-btn w-full border border-rose-400 bg-white text-gray-700 rounded-lg px-4 py-2 flex justify-between items-center focus:ring-2 focus:ring-rose-400">
                                    <span class="dropdown-label">-- Select Slot --</span>
                                    <svg class="w-5 h-5 text-rose-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                              d="M19 9l-7 7-7-7"/>
                                    </svg>
                                </button>

                                <div class="dropdown-options absolute left-0 right-0 mt-1 bg-white border border-rose-400 rounded-lg shadow-lg hidden z-10">
                                    <% for (Timeslot t : freeSlots) { %>
                                        <div class="dropdown-option px-4 py-2 hover:bg-rose-100 cursor-pointer text-gray-700"
                                             data-value="<%= t.getSlotId() %>">
                                            <%= t.getStartTime() %> - <%= t.getEndTime() %>
                                        </div>
                                    <% } %>
                                </div>
                            </div>
                        </div>
                    <%
                            }
                            current = current.plusDays(1);
                        }
                    %>
                </div>

                <div class="text-center">
                    <button type="submit"
                        class="px-10 py-3 bg-rose-600 text-white text-lg font-semibold rounded-lg hover:bg-rose-700 transition">
                        Save Assigned Timeslots
                    </button>
                </div>
            </form>

            <%
                    } // movie exists
                } // theaterId check
            %>
        </div>
    </div>
</div>

<!-- Custom Dropdown Script -->
<script>
document.addEventListener("DOMContentLoaded", () => {
    document.querySelectorAll(".dropdown-btn").forEach(btn => {
        const container = btn.closest("div.relative");
        const hiddenSelect = container.querySelector("select");
        const optionsBox = container.querySelector(".dropdown-options");
        const label = btn.querySelector(".dropdown-label");

        // Toggle dropdown
        btn.addEventListener("click", () => {
            optionsBox.classList.toggle("hidden");
        });

        // Select option
        optionsBox.querySelectorAll(".dropdown-option").forEach(opt => {
            opt.addEventListener("click", () => {
                const value = opt.dataset.value;
                const text = opt.innerText;

                // Update label
                label.innerText = text;

                // Update hidden select
                hiddenSelect.value = value;

                // Close dropdown
                optionsBox.classList.add("hidden");
            });
        });

        // Close if clicked outside
        document.addEventListener("click", (e) => {
            if (!container.contains(e.target)) {
                optionsBox.classList.add("hidden");
            }
        });
    });
});
</script>

<jsp:include page="layout/JSPFooter.jsp"/>
