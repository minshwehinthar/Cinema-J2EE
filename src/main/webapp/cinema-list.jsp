<%@ page contentType="text/html;charset=UTF-8" language="java"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="com.demo.model.User"%>
<%@ page import="com.demo.model.Movies"%>
<%@ page import="com.demo.model.Theater"%>
<%@ page import="com.demo.dao.TheaterMoviesDao"%>
<%@ page import="com.demo.dao.TheaterDAO"%>
<%@ page import="com.demo.dao.ShowtimesDao"%>
<%@ page import="com.demo.model.Showtime"%>
<%@ page import="java.time.LocalDate"%>
<%@ page import="java.time.format.DateTimeFormatter"%>
<%@ page import="java.util.HashMap"%>
<%@ page import="java.util.TreeMap"%>
<%@ page import="java.util.List"%>
<%@ page import="java.util.Map"%>
<%@ page import="java.util.Comparator"%>
<%@ page import="java.util.Collections"%>
<%@ page import="java.util.LinkedHashMap"%>

<jsp:include page="layout/JSPHeader.jsp" />

<%
User user = (User) session.getAttribute("user");
if (user == null) {
	response.sendRedirect("login.jsp?msg=unauthorized");
	return;
}

TheaterMoviesDao dao = new TheaterMoviesDao();
TheaterDAO theaterDao = new TheaterDAO();
ShowtimesDao showtimesDao = new ShowtimesDao();

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

// Create a map to organize movies by date (only dates that have showtimes)
Map<LocalDate, Map<Movies, List<Theater>>> moviesByDate = new TreeMap<>();

// Get all unique show dates from the database
for (Movies movie : moviesList) {
	String status = movie.getStatus();
	// REMOVED THE LINE THAT EXCLUDES COMING-SOON MOVIES
	// if ("coming-soon".equalsIgnoreCase(status)) continue;

	ArrayList<Theater> movieTheaters = dao.getTheatersByMovie(movie.getMovie_id());

	for (Theater theater : movieTheaters) {
		LocalDate[] dates = showtimesDao.getMovieDates(theater.getTheaterId(), movie.getMovie_id());
		if (dates != null && dates.length == 2) {
	LocalDate startDate = dates[0];
	LocalDate endDate = dates[1];

	// Add movie to each date in its showing range
	LocalDate currentDate = startDate;
	while (!currentDate.isAfter(endDate)) {
		if (!moviesByDate.containsKey(currentDate)) {
			moviesByDate.put(currentDate, new HashMap<>());
		}

		// Add theater to movie for this date
		if (!moviesByDate.get(currentDate).containsKey(movie)) {
			moviesByDate.get(currentDate).put(movie, new ArrayList<>());
		}
		if (!moviesByDate.get(currentDate).get(movie).contains(theater)) {
			moviesByDate.get(currentDate).get(movie).add(theater);
		}

		currentDate = currentDate.plusDays(1);
	}
		}
	}
}

// Filter out past dates and sort by date
Map<LocalDate, Map<Movies, List<Theater>>> filteredMoviesByDate = new TreeMap<>();
LocalDate today = LocalDate.now();
for (LocalDate date : moviesByDate.keySet()) {
	if (!date.isBefore(today)) {
		filteredMoviesByDate.put(date, moviesByDate.get(date));
	}
}
%>

<div class="flex min-h-screen">
	<!-- Sidebar -->
	<jsp:include page="layout/sidebar.jsp" />

	<!-- Main content -->
	<div class="flex-1 sm:ml-64">
		<!-- Admin Header -->
		<jsp:include page="layout/AdminHeader.jsp" />

		<div class="p-8">
			<!-- Dashboard modules -->
			<!-- Main Content Area (right of sidebar for all users) -->
			<div class="flex-1">
				<div class="p-8">
					<h2 class="text-2xl font-bold mb-6">Movie Schedule - Now
						Showing & Coming Soon</h2>

					<!-- Filters Row -->
					<div class="mb-6">
						<div
							class="flex flex-col lg:flex-row lg:items-center lg:justify-between gap-4">
							<!-- Date Category Filters -->
							<div class="flex-1">
								<h3 class="text-sm font-semibold text-gray-700 mb-2">Date
									Categories</h3>
								<div class="flex flex-wrap gap-2">
									<button
										class="date-category-btn px-3 py-1 bg-red-600 text-white text-sm rounded-full hover:bg-red-700 transition"
										data-category="all">All Dates</button>
									<button
										class="date-category-btn px-3 py-1 bg-gray-200 text-gray-700 text-sm rounded-full hover:bg-gray-300 transition"
										data-category="today">Today</button>
									<button
										class="date-category-btn px-3 py-1 bg-gray-200 text-gray-700 text-sm rounded-full hover:bg-gray-300 transition"
										data-category="tomorrow">Tomorrow</button>
									<button
										class="date-category-btn px-3 py-1 bg-gray-200 text-gray-700 text-sm rounded-full hover:bg-gray-300 transition"
										data-category="this-week">This Week</button>
									<button
										class="date-category-btn px-3 py-1 bg-gray-200 text-gray-700 text-sm rounded-full hover:bg-gray-300 transition"
										data-category="next-week">Next Week</button>
									<button
										class="date-category-btn px-3 py-1 bg-gray-200 text-gray-700 text-sm rounded-full hover:bg-gray-300 transition"
										data-category="this-month">This Month</button>
								</div>
							</div>

							<!-- Status Filter -->
							<div class="flex-1">
								<h3 class="text-sm font-semibold text-gray-700 mb-2">Filter
									by Status</h3>
								<div class="flex flex-wrap gap-2">
									<button
										class="status-filter-btn px-3 py-1 bg-red-600 text-white text-sm rounded-full hover:bg-red-700 transition"
										data-status="all">All Status</button>
									<button
										class="status-filter-btn px-3 py-1 bg-gray-200 text-gray-700 text-sm rounded-full hover:bg-gray-300 transition"
										data-status="now-showing">Now Showing</button>
									<button
										class="status-filter-btn px-3 py-1 bg-gray-200 text-gray-700 text-sm rounded-full hover:bg-gray-300 transition"
										data-status="coming-soon">Coming Soon</button>
								</div>
							</div>
						</div>
					</div>

					<!-- Date Navigation - Only show if there are dates with showtimes -->
					<%
					if (!filteredMoviesByDate.isEmpty()) {
					%>
					<div class="mb-6">
						<h3 class="text-sm font-semibold text-gray-700 mb-2">Select
							Specific Date</h3>
						<div class="flex space-x-2 overflow-x-auto pb-2">
							<%
							DateTimeFormatter dayFormatter = DateTimeFormatter.ofPattern("E");
							DateTimeFormatter dateFormatter = DateTimeFormatter.ofPattern("MMM dd");
							int activeDay = 0;
							for (LocalDate date : filteredMoviesByDate.keySet()) {
							%>
							<button
								class="date-filter-btn flex-shrink-0 px-4 py-2 rounded-lg border <%=activeDay == 0
		? "bg-red-600 text-white border-red-600"
		: "bg-white text-gray-700 border-gray-300 hover:bg-gray-50"%> transition"
								data-date="<%=date.toString()%>">
								<div class="text-center">
									<div class="text-sm font-semibold"><%=date.format(dayFormatter)%></div>
									<div class="text-xs"><%=date.format(dateFormatter)%></div>
								</div>
							</button>
							<%
							activeDay++;
							}
							%>
						</div>
					</div>

					<!-- Daily Tables -->
					<%
					int tableCount = 0;
					for (LocalDate date : filteredMoviesByDate.keySet()) {
						Map<Movies, List<Theater>> dailyMovies = filteredMoviesByDate.get(date);
						if (!dailyMovies.isEmpty()) {
					%>
					<div
						class="daily-table date-table mb-8 <%=tableCount == 0 ? "" : "hidden"%>"
						data-date="<%=date.toString()%>">
						<div class="bg-red-500 text-white px-6 py-3 rounded-t-lg">
							<h3 class="text-lg font-semibold">
								<%=date.format(DateTimeFormatter.ofPattern("EEEE, MMMM dd, yyyy"))%>
							</h3>
						</div>
						<div class="bg-white rounded-b-lg shadow-md overflow-hidden">
							<div class="overflow-x-auto">
								<table class="min-w-full divide-y divide-gray-200">
									<thead class="bg-gray-50">
										<tr>
											<th
												class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Movie</th>
											<th
												class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Status</th>
											<th
												class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Duration</th>
											<th
												class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Theaters</th>
											<th
												class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Show
												Times</th>
											<th
												class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Actions</th>
										</tr>
									</thead>
									<tbody class="bg-white divide-y divide-gray-200"
										id="table-body-<%=date.toString()%>">
										<%
										for (Movies movie : dailyMovies.keySet()) {
											List<Theater> theatersForMovie = dailyMovies.get(movie);
											String status = movie.getStatus();
											// Create theater IDs string for filtering
											StringBuilder theaterIds = new StringBuilder();
											if (theatersForMovie != null && !theatersForMovie.isEmpty()) {
												for (int i = 0; i < theatersForMovie.size(); i++) {
											theaterIds.append(theatersForMovie.get(i).getTheaterId());
											if (i < theatersForMovie.size() - 1) {
												theaterIds.append(",");
											}
												}
											}
										%>
										<tr class="hover:bg-gray-50 movie-row"
											data-theaters="<%=theaterIds.toString()%>"
											data-status="<%=status != null ? status.toLowerCase() : ""%>">
											<td class="px-6 py-4 whitespace-nowrap">
												<div class="flex items-center">
													<div class="flex-shrink-0 h-16 w-12">
														<img class="h-16 w-12 object-cover rounded"
															src="GetMoviesPosterServlet?movie_id=<%=movie.getMovie_id()%>"
															alt="<%=movie.getTitle()%>">
													</div>
													<div class="ml-4">
														<div class="text-sm font-medium text-gray-900">
															<%=movie.getTitle() != null ? movie.getTitle() : "Untitled"%>
														</div>
														
														<div class="text-xs text-gray-400">
															<%=movie.getGenres() != null ? movie.getGenres() : "N/A"%>
														</div>
													</div>
												</div>
											</td>
											<td class="px-6 py-4 whitespace-nowrap">
												<%
												String statusBadgeClass = "bg-gray-500";
												String statusText = "Unknown";
												if ("now-showing".equalsIgnoreCase(status)) {
													statusBadgeClass = "bg-green-600";
													statusText = "Now Showing";
												} else if ("coming-soon".equalsIgnoreCase(status)) {
													statusBadgeClass = "bg-yellow-500";
													statusText = "Coming Soon";
												}
												%> <span
												class="inline-flex px-2 py-1 text-xs font-semibold rounded-full text-white <%=statusBadgeClass%>">
													<%=statusText%>
											</span>
											</td>
											<td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
												<%=movie.getDuration() != null ? movie.getDuration() : "N/A"%>
											</td>
											<td class="px-6 py-4 text-sm text-gray-500">
												<%
												if (theatersForMovie != null && !theatersForMovie.isEmpty()) {
												%>
												<div class="space-y-1">
													<%
													for (Theater theater : theatersForMovie) {
													%>
													<div class="font-medium"><%=theater.getName()%></div>
													<div class="text-xs text-gray-400"><%=theater.getLocation()%></div>
													<%
													}
													%>
												</div> <%
 } else {
 %> No theaters <%
 }
 %>
											</td>
											<td class="px-6 py-4 text-sm text-gray-500">
												<div class="space-y-1">
													<%
													if (theatersForMovie != null && !theatersForMovie.isEmpty()) {
														for (Theater theater : theatersForMovie) {
															// Get only showtimes for this theater, movie, and date
															ArrayList<String> showtimes = showtimesDao.getFormattedShowtimes(theater.getTheaterId(), movie.getMovie_id(),
															date);
													%>
													<div class="text-xs">
														<span class="font-medium"><%=theater.getName()%></span>:
														<%
														if (showtimes != null && !showtimes.isEmpty()) {
															for (int i = 0; i < showtimes.size(); i++) {
																String start = showtimes.get(i);
														%>
														<span class="text-red-600 font-medium"><%=start.substring(0, 5)%></span><%=(i < showtimes.size() - 1) ? ", " : ""%>
														<%
														}
														} else {
														%>
														<span class="text-gray-400">No shows</span>
														<%
														}
														%>
													</div>
													<%
													}
													} else {
													%>
													No theaters
													<%
													}
													%>
												</div>
											</td>

											<td class="px-6 py-4 whitespace-nowrap text-sm font-medium">
												<div class="flex space-x-2">
													<button type="button"
														class="trailer-btn text-red-600 hover:text-red-900 text-xs"
														data-trailer-url="GetMoviesTrailerServlet?movie_id=<%=movie.getMovie_id()%>">
														Trailer</button>
													<%
													if ("admin".equals(user.getRole())) {
													%>
													<form
														action="<%=request.getContextPath()%>/DeleteMovieServlet"
														method="post" class="inline">
														<input type="hidden" name="movie_id"
															value="<%=movie.getMovie_id()%>" />
														<button type="submit"
															class="text-red-600 hover:text-red-900 text-xs">Delete</button>
													</form>
													<%
													}
													%>
													<%
													if ("theateradmin".equals(user.getRole())) {
													%>
													<form
														action="<%=request.getContextPath()%>/RemoveMovieFromTheaterServlet"
														method="post" class="inline">
														<input type="hidden" name="movie_id"
															value="<%=movie.getMovie_id()%>" /> <input
															type="hidden" name="theater_id" value="<%=theaterId%>" />
														<button type="submit"
															class="text-yellow-600 hover:text-yellow-900 text-xs">Remove</button>
													</form>
													<%
													}
													%>
												</div>
											</td>
										</tr>
										<%
										}
										%>
									</tbody>
								</table>
							</div>
						</div>
					</div>
					<%
					tableCount++;
					}
					}
					%>
					<%
					} else {
					%>
					<!-- No Movies Message -->
					<div class="text-center py-12 bg-white rounded-lg shadow-md">
						<div class="text-gray-500 text-lg mb-4">No movies scheduled</div>
						<p class="text-gray-400">There are no showtimes scheduled in
							the database.</p>
					</div>
					<%
					}
					%>
				</div>
			</div>

			<!-- Right Sidebar (Theater Filter for Admin only) -->
			<%
			if ("admin".equals(user.getRole())) {
			%>
			<!-- Sidebar Toggle Button -->
			<button id="sidebar-toggle"
				class="fixed top-[80px] right-0 z-50 bg-red-600 text-white px-3 py-1 rounded-l-lg shadow-lg hover:bg-red-700 transition">
				☰</button>

			<aside id="right-sidebar"
				class="fixed top-[64px] right-0 w-64 h-[calc(100vh-64px)] bg-white border-l border-gray-200 shadow-md overflow-y-auto p-5 transform translate-x-full transition-transform duration-300 ease-in-out lg:translate-x-0 lg:block">
				<div class="flex justify-between items-center mb-3">
					<h3 class="text-lg font-semibold text-gray-800">Filter by
						Theater</h3>
					<button id="sidebar-close"
						class="lg:hidden text-gray-600 hover:text-red-600 text-xl font-bold">✕</button>
				</div>

				<ul class="space-y-1">
					<!-- All Button -->
					<li
						class="theater-filter px-3 py-2 text-red-700 bg-red-100 rounded-lg cursor-pointer font-semibold"
						data-theater-id="all">Show All Theaters</li>

					<%
					if (theaters != null && theaters.size() > 0) {
					%>
					<%
					for (Theater t : theaters) {
					%>
					<li
						class="theater-filter px-3 py-2 text-gray-700 rounded-lg cursor-pointer hover:bg-red-50 hover:text-red-700 transition"
						data-theater-id="<%=t.getTheaterId()%>"><span
						class="block font-medium"><%=t.getName()%></span> <span
						class="block text-xs text-gray-500"><%=t.getLocation()%></span>
					</li>
					<%
					}
					%>
					<%
					} else {
					%>
					<p class="text-gray-500 text-sm mt-3">No theaters available.</p>
					<%
					}
					%>
				</ul>
			</aside>

			<script>
    const sidebarToggle = document.getElementById('sidebar-toggle');
    const rightSidebar = document.getElementById('right-sidebar');

    sidebarToggle.addEventListener('click', () => {
        const isOpen = !rightSidebar.classList.contains('translate-x-full');
        rightSidebar.classList.toggle('translate-x-full');

        // Change button icon
        sidebarToggle.textContent = isOpen ? '☰' : '✕';
    });

    // Optional: close sidebar by clicking outside (mobile)
    document.addEventListener('click', (e) => {
        if (!rightSidebar.contains(e.target) && !sidebarToggle.contains(e.target) && !rightSidebar.classList.contains('translate-x-full')) {
            rightSidebar.classList.add('translate-x-full');
            sidebarToggle.textContent = '☰';
        }
    });
</script>
			<%
			}
			%>
		</div>

		<!-- Trailer Popup -->
		<div
			class="trailer-popup hidden fixed inset-0 flex items-center justify-center z-50">
			<div class="absolute inset-0 backdrop-blur-xs"></div>
			<div
				class="relative w-full max-w-8xl bg-opacity-80 rounded-lg overflow-hidden transform scale-90 opacity-0 transition-all duration-300 ease-out z-10">
				<button
					class="trailer-close absolute top-3 right-3 text-gray-800 hover:text-red-500 text-3xl font-bold z-20">✕</button>
				<div>
					<h3
						class="text-gray-900 text-2xl md:text-3xl font-semibold text-center mb-4">Trailer</h3>
					<div
						class="w-full aspect-video rounded-xl overflow-hidden shadow-inner">
						<video class="w-full h-full bg-black" controls>
							<source data-src="" type="video/mp4">
							Your browser does not support the video tag.
						</video>
					</div>
				</div>
			</div>
		</div>

		<jsp:include page="layout/JSPFooter.jsp" />

		<script>
// Global variable to track current theater filter
let currentTheaterFilter = 'all';
let currentStatusFilter = 'all';

// Trailer popup functionality
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

// Date category filter functionality
const dateCategoryBtns = document.querySelectorAll('.date-category-btn');
const dateFilterBtns = document.querySelectorAll('.date-filter-btn');
const dateTables = document.querySelectorAll('.daily-table');

dateCategoryBtns.forEach(btn => {
    btn.addEventListener('click', () => {
        const category = btn.getAttribute('data-category');
        
        // Update button styles
        dateCategoryBtns.forEach(b => {
            b.classList.remove('bg-red-600', 'text-white');
            b.classList.add('bg-gray-200', 'text-gray-700', 'hover:bg-gray-300');
        });
        btn.classList.remove('bg-gray-200', 'text-gray-700', 'hover:bg-gray-300');
        btn.classList.add('bg-red-600', 'text-white');

        // Reset date filter buttons
        dateFilterBtns.forEach(b => {
            b.classList.remove('bg-red-600', 'text-white', 'border-red-600');
            b.classList.add('bg-white', 'text-gray-700', 'border-gray-300', 'hover:bg-gray-50');
        });

        // Show/hide tables based on category
        const today = new Date();
        dateTables.forEach(table => {
            const tableDate = new Date(table.getAttribute('data-date'));
            
            let showTable = false;
            
            switch(category) {
                case 'all':
                    showTable = true;
                    break;
                case 'today':
                    showTable = isSameDay(tableDate, today);
                    break;
                case 'tomorrow':
                    const tomorrow = new Date(today);
                    tomorrow.setDate(tomorrow.getDate() + 1);
                    showTable = isSameDay(tableDate, tomorrow);
                    break;
                case 'this-week':
                    showTable = isThisWeek(tableDate);
                    break;
                case 'next-week':
                    showTable = isNextWeek(tableDate);
                    break;
                case 'this-month':
                    showTable = isThisMonth(tableDate);
                    break;
            }
            
            if (showTable) {
                table.classList.remove('hidden');
                // Apply current filters to the shown table
                applyFilters(table);
            } else {
                table.classList.add('hidden');
            }
        });
    });
});

// Status filter functionality
const statusFilterBtns = document.querySelectorAll('.status-filter-btn');

statusFilterBtns.forEach(btn => {
    btn.addEventListener('click', () => {
        const status = btn.getAttribute('data-status');
        currentStatusFilter = status;

        // Update button styles
        statusFilterBtns.forEach(b => {
            b.classList.remove('bg-red-600', 'text-white');
            b.classList.add('bg-gray-200', 'text-gray-700', 'hover:bg-gray-300');
        });
        btn.classList.remove('bg-gray-200', 'text-gray-700', 'hover:bg-gray-300');
        btn.classList.add('bg-red-600', 'text-white');

        // Apply filter to current visible table
        const currentTable = document.querySelector('.daily-table:not(.hidden)');
        if (currentTable) {
            applyFilters(currentTable);
        }
    });
});

// Date filter functionality
dateFilterBtns.forEach((btn, index) => {
    btn.addEventListener('click', () => {
        // Update button styles
        dateFilterBtns.forEach(b => {
            b.classList.remove('bg-red-600', 'text-white', 'border-red-600');
            b.classList.add('bg-white', 'text-gray-700', 'border-gray-300', 'hover:bg-gray-50');
        });
        btn.classList.remove('bg-white', 'text-gray-700', 'border-gray-300', 'hover:bg-gray-50');
        btn.classList.add('bg-red-600', 'text-white', 'border-red-600');

        // Reset category buttons
        dateCategoryBtns.forEach(b => {
            b.classList.remove('bg-red-600', 'text-white');
            b.classList.add('bg-gray-200', 'text-gray-700', 'hover:bg-gray-300');
        });

        // Show selected date table
        const selectedDate = btn.getAttribute('data-date');
        
        dateTables.forEach(table => {
            if (table.getAttribute('data-date') === selectedDate) {
                table.classList.remove('hidden');
                // Apply current filters to the newly shown table
                applyFilters(table);
            } else {
                table.classList.add('hidden');
            }
        });
    });
});

// Helper functions for date categories
function isSameDay(date1, date2) {
    return date1.getFullYear() === date2.getFullYear() &&
           date1.getMonth() === date2.getMonth() &&
           date1.getDate() === date2.getDate();
}

function isThisWeek(date) {
    const today = new Date();
    const startOfWeek = new Date(today);
    startOfWeek.setDate(today.getDate() - today.getDay());
    const endOfWeek = new Date(startOfWeek);
    endOfWeek.setDate(startOfWeek.getDate() + 6);
    
    return date >= startOfWeek && date <= endOfWeek;
}

function isNextWeek(date) {
    const today = new Date();
    const startOfNextWeek = new Date(today);
    startOfNextWeek.setDate(today.getDate() + (7 - today.getDay()));
    const endOfNextWeek = new Date(startOfNextWeek);
    endOfNextWeek.setDate(startOfNextWeek.getDate() + 6);
    
    return date >= startOfNextWeek && date <= endOfNextWeek;
}

function isThisMonth(date) {
    const today = new Date();
    return date.getFullYear() === today.getFullYear() &&
           date.getMonth() === today.getMonth();
}

// Theater filter functionality (for admin)
const theaterFilters = document.querySelectorAll('.theater-filter');

theaterFilters.forEach(item => {
    item.addEventListener('click', () => {
        const theaterId = item.getAttribute('data-theater-id');
        currentTheaterFilter = theaterId;

        // Reset active state
        theaterFilters.forEach(i => {
            i.classList.remove('bg-red-100', 'text-red-700', 'font-semibold');
            i.classList.add('text-gray-700', 'hover:bg-red-50');
        });
        item.classList.add('bg-red-100', 'text-red-700', 'font-semibold');
        item.classList.remove('text-gray-700', 'hover:bg-red-50');

        // Apply filter to current visible table
        const currentTable = document.querySelector('.daily-table:not(.hidden)');
        if (currentTable) {
            applyFilters(currentTable);
        }
    });
});

// Function to apply both theater and status filters
function applyFilters(table) {
    const movieRows = table.querySelectorAll('.movie-row');
    let visibleCount = 0;
    
    movieRows.forEach(row => {
        const rowTheaters = row.getAttribute('data-theaters').split(',');
        const rowStatus = row.getAttribute('data-status');
        
        const theaterMatch = currentTheaterFilter === 'all' || rowTheaters.includes(currentTheaterFilter);
        const statusMatch = currentStatusFilter === 'all' || rowStatus === currentStatusFilter;
        
        if (theaterMatch && statusMatch) {
            row.style.display = '';
            visibleCount++;
        } else {
            row.style.display = 'none';
        }
    });
    
    // Show/hide no results message
    const tableBody = table.querySelector('tbody');
    let noResultsRow = tableBody.querySelector('.no-results-row');
    
    if (visibleCount === 0) {
        if (!noResultsRow) {
            noResultsRow = document.createElement('tr');
            noResultsRow.className = 'no-results-row';
            noResultsRow.innerHTML = `
                <td colspan="6" class="px-6 py-8 text-center text-gray-500">
                    <div class="flex flex-col items-center">
                        <svg class="w-12 h-12 text-gray-400 mb-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9.172 16.172a4 4 0 015.656 0M9 10h.01M15 10h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path>
                        </svg>
                        <p class="text-lg font-medium">No movies found</p>
                        <p class="text-sm">No movies match the current filters for the selected date.</p>
                    </div>
                </td>
            `;
            tableBody.appendChild(noResultsRow);
        } else {
            noResultsRow.style.display = '';
        }
    } else {
        if (noResultsRow) {
            noResultsRow.style.display = 'none';
        }
    }
}

// Initialize first date as active and apply initial filter
if (dateFilterBtns.length > 0) {
    dateFilterBtns[0].click();
    // Apply initial filters to the first table
    const firstTable = document.querySelector('.daily-table:not(.hidden)');
    if (firstTable) {
        applyFilters(firstTable);
    }
}
</script>
	</div>
</div>
</div>

Ï
