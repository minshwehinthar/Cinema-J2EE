<%@page import="com.demo.dao.BookingDao"%>
<%@ page import="com.demo.model.Booking" %>
<%@ page import="com.demo.model.User" %>
<%@ page import="com.demo.model.Showtime" %>
<%@ page import="com.demo.model.Movies" %>
<%@ page import="com.demo.model.Theater" %>
<%@ page import="com.demo.model.Seat" %>
<%@ page import="com.demo.dao.ShowtimesDao" %>
<%@ page import="com.demo.dao.MoviesDao" %>
<%@ page import="com.demo.dao.TheaterDAO" %>
<%@ page import="com.demo.dao.SeatsDao" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.stream.Collectors" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    // Pagination parameters
    int currentPage = 1;
    int recordsPerPage = 5;
    
    // Get records per page from request parameter
    String limitParam = request.getParameter("limit");
    if (limitParam != null && !limitParam.isEmpty()) {
        try {
            recordsPerPage = Integer.parseInt(limitParam);
            // Validate allowed values
            if (recordsPerPage != 5 && recordsPerPage != 10 && recordsPerPage != 15 && recordsPerPage != 20) {
                recordsPerPage = 5;
            }
        } catch (NumberFormatException e) {
            recordsPerPage = 5;
        }
    }
    
    // Get current page from request parameter
    String pageParam = request.getParameter("page");
    if (pageParam != null && !pageParam.isEmpty()) {
        try {
            currentPage = Integer.parseInt(pageParam);
        } catch (NumberFormatException e) {
            currentPage = 1;
        }
    }
    
    if (currentPage < 1) {
        currentPage = 1;
    }

    // Search parameter
    String searchQuery = request.getParameter("search");
    if (searchQuery != null && searchQuery.trim().isEmpty()) {
        searchQuery = null;
    }

    BookingDao bookingDAO = new BookingDao();
    ShowtimesDao showtimesDao = new ShowtimesDao();
    MoviesDao moviesDao = new MoviesDao();
    TheaterDAO theaterDAO = new TheaterDAO();
    SeatsDao seatsDao = new SeatsDao();
    
    List<Booking> allBookings = null;
    List<Booking> userBookings = null;
    List<Booking> filteredBookings = null;
    String errorMessage = null;
    
    try {
        allBookings = bookingDAO.getBookingsByUserId(user.getUserId());
        
        // Apply search filter if search query exists
        if (searchQuery != null && !searchQuery.trim().isEmpty()) {
            final String searchTerm = searchQuery.toLowerCase().trim();
            filteredBookings = allBookings.stream()
                .filter(booking -> {
                    if (booking == null) return false;
                    
                    // Search by booking ID
                    if (String.valueOf(booking.getBookingId()).contains(searchTerm)) {
                        return true;
                    }
                    
                    // Get related objects for search
                    Showtime showtime = showtimesDao.getShowtimeDetails(booking.getShowtimeId());
                    if (showtime != null) {
                        Movies movie = moviesDao.getMovieById(showtime.getMovieId());
                        Theater theater = theaterDAO.getTheaterById(showtime.getTheaterId());
                        
                        // Search by movie title
                        if (movie != null && movie.getTitle() != null && 
                            movie.getTitle().toLowerCase().contains(searchTerm)) {
                            return true;
                        }
                        
                        // Search by theater name
                        if (theater != null && theater.getName() != null && 
                            theater.getName().toLowerCase().contains(searchTerm)) {
                            return true;
                        }
                    }
                    
                    return false;
                })
                .collect(Collectors.toList());
        } else {
            filteredBookings = allBookings;
        }
        
        // Calculate pagination
        int totalRecords = filteredBookings.size();
        int totalPages = (int) Math.ceil((double) totalRecords / recordsPerPage);
        
        if (currentPage > totalPages && totalPages > 0) {
            currentPage = totalPages;
        }
        
        // Get sublist for current page
        int start = (currentPage - 1) * recordsPerPage;
        int end = Math.min(start + recordsPerPage, totalRecords);
        
        if (totalRecords > 0) {
            userBookings = filteredBookings.subList(start, end);
        } else {
            userBookings = new java.util.ArrayList<>();
        }
        
        // Set pagination attributes for use in JSP
        request.setAttribute("currentPage", currentPage);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalRecords", totalRecords);
        request.setAttribute("recordsPerPage", recordsPerPage);
        request.setAttribute("startRecord", totalRecords > 0 ? start + 1 : 0);
        request.setAttribute("endRecord", Math.min(end, totalRecords));
        
    } catch (Exception e) {
        errorMessage = "Error loading bookings: " + e.getMessage();
        userBookings = new java.util.ArrayList<>();
        request.setAttribute("currentPage", 1);
        request.setAttribute("totalPages", 0);
        request.setAttribute("totalRecords", 0);
        request.setAttribute("recordsPerPage", recordsPerPage);
        request.setAttribute("startRecord", 0);
        request.setAttribute("endRecord", 0);
    }
    
    SimpleDateFormat dateFormat = new SimpleDateFormat("MMM dd, yyyy");
    SimpleDateFormat timeFormat = new SimpleDateFormat("hh:mm a");
    
    // Get pagination attributes
    int currentPageAttr = (Integer) request.getAttribute("currentPage");
    int totalPages = (Integer) request.getAttribute("totalPages");
    int totalRecords = (Integer) request.getAttribute("totalRecords");
    int recordsPerPageAttr = (Integer) request.getAttribute("recordsPerPage");
    int startRecord = (Integer) request.getAttribute("startRecord");
    int endRecord = (Integer) request.getAttribute("endRecord");
%>

<jsp:include page="layout/JSPHeader.jsp"/>
<jsp:include page="layout/header.jsp"/>

<div class="min-h-screen bg-gray-50 py-8">
    <div class="container mx-auto px-4 max-w-8xl">
    <nav class="text-gray-500 text-sm mb-4" aria-label="Breadcrumb">
			<ol class="list-none p-0 inline-flex">
				<li><a href="home.jsp" class="hover:text-red-600">Home</a></li>
            <li><span class="mx-2">/</span></li>
            
				<li class="flex items-center text-gray-900 font-semibold">My Bookings
				</li>
			</ol>
		</nav>
        <!-- Header Section -->
        <div class="flex justify-between items-center mb-8">
            <div>
                <h1 class="text-2xl font-bold text-gray-900">My Bookings</h1>
                <p class="text-gray-600 mt-1">Manage and view your movie ticket bookings</p>
            </div>
        </div>

        <!-- Search and Filters -->
        <div class="flex justify-between items-center mb-6">
            <!-- Status Filter -->
            <div class="flex gap-2">
                <button class="statusBtn px-4 py-2 rounded-lg border border-red-500 bg-red-50 text-red-600 font-medium transition-colors duration-200 text-sm" data-status="all">All Bookings</button>
                <button class="statusBtn px-4 py-2 rounded-lg border border-gray-300 bg-white text-gray-700 hover:bg-gray-50 hover:border-gray-400 transition-colors duration-200 text-sm" data-status="confirmed">Confirmed</button>
                <button class="statusBtn px-4 py-2 rounded-lg border border-gray-300 bg-white text-gray-700 hover:bg-gray-50 hover:border-gray-400 transition-colors duration-200 text-sm" data-status="pending">Pending</button>
                <button class="statusBtn px-4 py-2 rounded-lg border border-gray-300 bg-white text-gray-700 hover:bg-gray-50 hover:border-gray-400 transition-colors duration-200 text-sm" data-status="cancelled">Cancelled</button>
            </div>

            <!-- Search -->
            <div class="relative">
                <input type="text" id="searchInput" placeholder="Search by Booking ID, Movie, Theater..." 
                       class="px-4 py-2 border border-gray-300 rounded-lg w-80 focus:outline-none ring-transparent text-sm"/>
            </div>
        </div>

        <!-- Bookings Table -->
        <div class="bg-white shadow rounded-lg border border-gray-200 overflow-hidden">
            <% if (userBookings == null || userBookings.isEmpty()) { %>
                <div class="px-6 py-16 text-center">
                    <div class="w-16 h-16 mx-auto mb-4 text-gray-300">
                        <svg fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1" d="M15 5v2m0 4v2m0 4v2M5 5a2 2 0 00-2 2v3a2 2 0 110 4v3a2 2 0 002 2h14a2 2 0 002-2v-3a2 2 0 110-4V7a2 2 0 00-2-2H5z"/>
                        </svg>
                    </div>
                    <h3 class="text-lg font-medium text-gray-600 mb-2">
                        <%= allBookings == null ? "Error loading bookings" : 
                           (searchQuery != null && !searchQuery.isEmpty() ? "No bookings found" : "No bookings yet") %>
                    </h3>
                    <p class="text-gray-500 mb-6">
                        <%= allBookings == null ? "Please try again later." : 
                           (searchQuery != null && !searchQuery.isEmpty() ? 
                           "No bookings match your search criteria." : "Start booking your first ticket.") %>
                    </p>
                    <% if (allBookings != null && (searchQuery == null || searchQuery.isEmpty())) { %>
                    <a href="movies.jsp" class="inline-flex items-center px-6 py-3 bg-red-600 text-white font-medium rounded-lg hover:bg-red-700 transition-colors duration-200 shadow-sm">
                        Book Tickets Now
                    </a>
                    <% } %>
                    <% if (searchQuery != null && !searchQuery.isEmpty()) { %>
                    <a href="?limit=<%= recordsPerPageAttr %>" class="inline-flex items-center px-6 py-3 bg-gray-600 text-white font-medium rounded-lg hover:bg-gray-700 transition-colors duration-200 shadow-sm ml-3">
                        Clear Search
                    </a>
                    <% } %>
                </div>
            <% } else { %>
                <div class="overflow-x-auto">
                    <table class="min-w-full text-sm text-left">
                        <thead class="bg-red-50 text-gray-900 uppercase text-xs">
                            <tr>
                                <th class="px-6 py-4 font-semibold cursor-pointer sortable" data-sort="bookingId">
                                    <div class="flex items-center space-x-1">
                                        <span>Booking Details</span>
                                        <svg class="w-4 h-4 text-gray-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 16V4m0 0L3 8m4-4l4 4m6 0v12m0 0l4-4m-4 4l-4-4"/>
                                        </svg>
                                    </div>
                                </th>
                                <th class="px-6 py-4 font-semibold cursor-pointer sortable" data-sort="movieTitle">
                                    <div class="flex items-center space-x-1">
                                        <span>Movie & Showtime</span>
                                        <svg class="w-4 h-4 text-gray-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 16V4m0 0L3 8m4-4l4 4m6 0v12m0 0l4-4m-4 4l-4-4"/>
                                        </svg>
                                    </div>
                                </th>
                                <th class="px-6 py-4 font-semibold cursor-pointer sortable" data-sort="theaterName">
                                    <div class="flex items-center space-x-1">
                                        <span>Theater</span>
                                        <svg class="w-4 h-4 text-gray-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 16V4m0 0L3 8m4-4l4 4m6 0v12m0 0l4-4m-4 4l-4-4"/>
                                        </svg>
                                    </div>
                                </th>
                                <th class="px-6 py-4 font-semibold cursor-pointer sortable" data-sort="seatCount">
                                    <div class="flex items-center space-x-1">
                                        <span>Seats</span>
                                        <svg class="w-4 h-4 text-gray-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 16V4m0 0L3 8m4-4l4 4m6 0v12m0 0l4-4m-4 4l-4-4"/>
                                        </svg>
                                    </div>
                                </th>
                                <th class="px-6 py-4 font-semibold cursor-pointer sortable" data-sort="totalPrice">
                                    <div class="flex items-center space-x-1">
                                        <span>Amount</span>
                                        <svg class="w-4 h-4 text-gray-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 16V4m0 0L3 8m4-4l4 4m6 0v12m0 0l4-4m-4 4l-4-4"/>
                                        </svg>
                                    </div>
                                </th>
                                <th class="px-6 py-4 font-semibold">Status</th>
                                <th class="px-6 py-4 font-semibold text-center">Actions</th>
                            </tr>
                        </thead>
                        <tbody id="bookingTableBody" class="divide-y divide-gray-100">
                            <% for (Booking booking : userBookings) { 
                                if (booking == null) continue;
                                
                                // Get detailed information
                                Showtime showtime = showtimesDao.getShowtimeDetails(booking.getShowtimeId());
                                Movies movie = null;
                                Theater theater = null;
                                List<Seat> seats = null;
                                
                                if (showtime != null) {
                                    movie = moviesDao.getMovieById(showtime.getMovieId());
                                    theater = theaterDAO.getTheaterById(showtime.getTheaterId());
                                }
                                
                                if (booking.getSelectedSeatIds() != null && !booking.getSelectedSeatIds().isEmpty()) {
                                    seats = seatsDao.getSeatsByShowtimeSeatIds(booking.getSelectedSeatIds());
                                }
                                
                                String statusClass = "";
                                String statusText = "";
                                if (booking.getStatus() != null) {
                                    switch(booking.getStatus().toLowerCase()) {
                                        case "confirmed":
                                            statusClass = "bg-green-100 text-green-800 border border-green-200";
                                            statusText = "Confirmed";
                                            break;
                                        case "pending":
                                            statusClass = "bg-yellow-100 text-yellow-800 border border-yellow-200";
                                            statusText = "Pending";
                                            break;
                                        case "cancelled":
                                            statusClass = "bg-red-100 text-red-800 border border-red-200";
                                            statusText = "Cancelled";
                                            break;
                                        default:
                                            statusClass = "bg-gray-100 text-gray-800 border border-gray-200";
                                            statusText = booking.getStatus();
                                    }
                                }
                            %>
                            <tr class="hover:bg-red-50 transition-colors duration-150 booking-row" 
                                data-status="<%= booking.getStatus().toLowerCase() %>"
                                data-booking-id="<%= booking.getBookingId() %>"
                                data-movie-title="<%= movie != null ? movie.getTitle().toLowerCase() : "" %>"
                                data-theater-name="<%= theater != null ? theater.getName().toLowerCase() : "" %>"
                                data-seat-count="<%= seats != null ? seats.size() : 0 %>"
                                data-total-price="<%= booking.getTotalPrice() != null ? booking.getTotalPrice() : 0 %>"
                                data-booking-date="<%= booking.getBookingTime() != null ? booking.getBookingTime().getTime() : 0 %>">
                                <!-- Booking Details -->
                                <td class="px-6 py-4">
                                    <div class="flex items-center space-x-3">
                                        <div class="w-10 h-10 bg-red-100 rounded-lg flex items-center justify-center">
                                            <span class="text-red-600 font-bold text-sm">#<%= booking.getBookingId() %></span>
                                        </div>
                                        <div>
                                            <div class="text-sm text-gray-500">
                                                <%= booking.getBookingTime() != null ? dateFormat.format(booking.getBookingTime()) : "N/A" %>
                                            </div>
                                            <% if (booking.getBookingTime() != null) { %>
                                            <div class="text-xs text-gray-400">
                                                <%= timeFormat.format(booking.getBookingTime()) %>
                                            </div>
                                            <% } %>
                                        </div>
                                    </div>
                                </td>
                                
                                <!-- Movie & Showtime -->
                                <td class="px-6 py-4">
                                    <% if (movie != null) { %>
                                    <div class="font-medium text-gray-900"><%= movie.getTitle() %></div>
                                    <% } %>
                                    <% if (showtime != null) { %>
                                    <div class="text-sm text-gray-500 mt-1">
                                        <%= showtime.getShowDate() != null ? dateFormat.format(showtime.getShowDate()) : "N/A" %>
                                    </div>
                                    <div class="text-xs text-gray-500">
                                        <%= showtime.getStartTime() != null ? showtime.getStartTime() : "" %>
                                        <% if (showtime.getEndTime() != null) { %>
                                         - <%= showtime.getEndTime() %>
                                        <% } %>
                                    </div>
                                    <% } else { %>
                                    <div class="text-sm text-gray-500">Show #<%= booking.getShowtimeId() %></div>
                                    <% } %>
                                </td>
                                
                                <!-- Theater -->
                                <td class="px-6 py-4">
                                    <% if (theater != null) { %>
                                    <div class="font-medium text-gray-900"><%= theater.getName() %></div>
                                    <div class="text-sm text-gray-500 truncate max-w-xs" title="<%= theater.getLocation() %>">
                                        <%= theater.getLocation() %>
                                    </div>
                                    <% } else { %>
                                    <div class="text-sm text-gray-500">Theater info not available</div>
                                    <% } %>
                                </td>
                                
                                <!-- Seats -->
                                <td class="px-6 py-4">
                                    <% if (seats != null && !seats.isEmpty()) { %>
                                    <div class="font-medium text-gray-900 mb-1">
                                        <%= seats.size() %> seat<%= seats.size() > 1 ? "s" : "" %>
                                    </div>
                                    <div class="text-sm text-gray-500 max-w-xs">
                                        <% 
                                            String seatNumbers = seats.stream()
                                                .map(Seat::getSeatNumber)
                                                .collect(Collectors.joining(", "));
                                        %>
                                        <%= seatNumbers.length() > 30 ? seatNumbers.substring(0, 30) + "..." : seatNumbers %>
                                    </div>
                                    <% if (seats.size() > 0) { %>
                                    <div class="text-xs text-gray-500 mt-1">
                                        <%= seats.get(0).getSeatType() != null ? seats.get(0).getSeatType() : "Standard" %>
                                    </div>
                                    <% } %>
                                    <% } else { %>
                                    <div class="text-sm text-gray-500">-</div>
                                    <% } %>
                                </td>
                                
                                <!-- Amount -->
                                <td class="px-6 py-4">
                                    <div class="font-semibold text-red-600">
                                        <%= booking.getTotalPrice() != null ? booking.getTotalPrice() + " MMK" : "N/A" %>
                                    </div>
                                    <% if (seats != null && !seats.isEmpty()) { %>
                                    <div class="text-xs text-gray-500">
                                        <%= seats.size() %> x <%= seats.get(0).getPrice() != null ? seats.get(0).getPrice() + " MMK" : "" %>
                                    </div>
                                    <% } %>
                                </td>
                                
                                <!-- Status -->
                                <td class="px-6 py-4">
                                    <span class="inline-flex items-center px-3 py-1 rounded-full text-xs font-medium <%= statusClass %>">
                                        <%= statusText %>
                                    </span>
                                </td>
                                
                                <!-- Actions -->
                                <td class="px-6 py-4">
                                    <div class="flex justify-center space-x-3 min-w-[90px]">
                                        <% if ("pending".equalsIgnoreCase(booking.getStatus())) { %>
                                        <!-- Pending: Show Cancel + View buttons -->
                                        <button onclick="cancelBooking(<%= booking.getBookingId() %>)" 
                                                class="inline-flex items-center justify-center w-10 h-10 text-red-600 bg-white border border-red-300 rounded-lg hover:bg-red-50 hover:border-red-400 transition-colors duration-200 shadow-sm cursor-pointer"
                                                title="Cancel Booking">
                                            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-5 h-5">
                                                <path stroke-linecap="round" stroke-linejoin="round" d="M6 18 18 6M6 6l12 12" />
                                            </svg>
                                        </button>
                                        <a href="viewTicket.jsp?bookingId=<%= booking.getBookingId() %>" 
                                           class="inline-flex items-center justify-center w-10 h-10 text-blue-600 bg-white border border-blue-300 rounded-lg hover:bg-blue-50 hover:border-blue-400 transition-colors duration-200 shadow-sm cursor-pointer"
                                           title="View Ticket">
                                            <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                                <path d="M2.062 12.348a1 1 0 0 1 0-.696 10.75 10.75 0 0 1 19.876 0 1 1 0 0 1 0 .696 10.75 10.75 0 0 1-19.876 0"/>
                                                <circle cx="12" cy="12" r="3"/>
                                            </svg>
                                        </a>
                                        <% } else if ("confirmed".equalsIgnoreCase(booking.getStatus())) { %>
                                        <!-- Confirmed: Show Only View button -->
                                        <button class="inline-flex items-center justify-center w-10 h-10 text-red-300 bg-gray-50 border border-red-200 rounded-lg transition-colors duration-200 shadow-sm cursor-not-allowed opacity-90"
                                                title="Cannot Cancel Confirmed Booking">
                                            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-5 h-5">
                                                <path stroke-linecap="round" stroke-linejoin="round" d="M6 18 18 6M6 6l12 12" />
                                            </svg>
                                        </button>
                                        <a href="viewTicket.jsp?bookingId=<%= booking.getBookingId() %>" 
                                           class="inline-flex items-center justify-center w-10 h-10 text-blue-600 bg-white border border-blue-300 rounded-lg hover:bg-blue-50 hover:border-blue-400 transition-colors duration-200 shadow-sm cursor-pointer"
                                           title="View Ticket">
                                            <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                                <path d="M2.062 12.348a1 1 0 0 1 0-.696 10.75 10.75 0 0 1 19.876 0 1 1 0 0 1 0 .696 10.75 10.75 0 0 1-19.876 0"/>
                                                <circle cx="12" cy="12" r="3"/>
                                            </svg>
                                        </a>
                                        <% } else if ("cancelled".equalsIgnoreCase(booking.getStatus())) { %>
                                        <!-- Cancelled: Show all buttons but disabled -->
                                        <button class="inline-flex items-center justify-center w-10 h-10 text-red-300 bg-gray-50 border border-red-200 rounded-lg transition-colors duration-200 shadow-sm cursor-not-allowed opacity-90"
                                                title="Booking Already Cancelled">
                                            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-5 h-5">
                                                <path stroke-linecap="round" stroke-linejoin="round" d="M6 18 18 6M6 6l12 12" />
                                            </svg>
                                        </button>
                                        <a class="inline-flex items-center justify-center w-10 h-10 text-gray-300 bg-gray-50 border border-gray-200 rounded-lg transition-colors duration-200 shadow-sm cursor-not-allowed opacity-90"
                                           title="Cannot View Cancelled Ticket">
                                            <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                                <path d="M2.062 12.348a1 1 0 0 1 0-.696 10.75 10.75 0 0 1 19.876 0 1 1 0 0 1 0 .696 10.75 10.75 0 0 1-19.876 0"/>
                                                <circle cx="12" cy="12" r="3"/>
                                            </svg>
                                        </a>
                                        <% } %>
                                    </div>
                                </td>
                            </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            <% } %>
        </div>

        <!-- Pagination -->
        <% if (totalPages > 0) { %>
        <div class="flex mt-6 justify-between items-center">
            <!-- Left Section: Total and Row -->
            <div class="flex items-center gap-4">
                <div class="text-sm text-gray-700">
                    Total <span class="shadow-sm px-3 py-2 rounded border border-gray-200 mx-2">
                        <%=totalRecords%>
                    </span>
                </div>
                <div class="flex items-center gap-2">
                    <span class="text-sm text-gray-700">Row</span>
                    <select id="recordsPerPage" onchange="handleLimitChange()"
                        class="bg-gray-50 border border-gray-300 text-gray-900 text-xs rounded-lg focus:border-red-500 block w-full p-2.5"
                        style="appearance: none; -webkit-appearance: none; -moz-appearance: none; background-image: none;">
                        <option value="5" <%=recordsPerPageAttr == 5 ? "selected" : ""%>>5</option>
                        <option value="10" <%=recordsPerPageAttr == 10 ? "selected" : ""%>>10</option>
                        <option value="15" <%=recordsPerPageAttr == 15 ? "selected" : ""%>>15</option>
                        <option value="20" <%=recordsPerPageAttr == 20 ? "selected" : ""%>>20</option>
                    </select>
                </div>
            </div>
            
            <!-- Right Section: Page Info and Navigation -->
            <div class="flex items-center gap-0">
                <div class="text-sm text-gray-700 mr-4">
                    Page <span class="shadow-sm px-3 py-2 rounded border border-gray-200 mx-2">
                        <%=currentPageAttr%>
                    </span> of <span class="shadow-sm px-3 py-2 rounded border border-gray-200 mx-2">
                        <%=totalPages%>
                    </span>
                </div>
                
                <!-- Navigation Buttons - No space between -->
                <div class="flex gap-0">
                    <!-- Previous Button -->
                    <button onclick="handlePrev()"
                        <%=currentPageAttr <= 1 ? "disabled" : ""%>
                        class="flex <%=currentPageAttr <= 1 ? "opacity-50 cursor-not-allowed" : "hover:bg-gray-100 hover:text-gray-700"%> items-center justify-center px-4 h-10 text-base font-medium text-gray-500 bg-white border border-gray-300 rounded-l-lg border-r-0">
                        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7" />
                        </svg>
                    </button>
                    
                    <!-- Next Button -->
                    <button onclick="handleNext()"
                        <%=currentPageAttr >= totalPages ? "disabled" : ""%>
                        class="flex <%=currentPageAttr >= totalPages ? "opacity-50 cursor-not-allowed" : "hover:bg-gray-100 hover:text-gray-700"%> items-center justify-center px-4 h-10 text-base font-medium text-gray-500 bg-white border border-gray-300 rounded-r-lg">
                        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" />
                        </svg>
                    </button>
                </div>
            </div>
        </div>
        <% } %>
    </div>
</div>

<form id="cancelForm" action="UserCancelBookingServlet" method="post" class="hidden">
    <input type="hidden" name="bookingId" id="cancelBookingId">
</form>

<script>
// Sorting state
let currentSort = {
    field: 'bookingId',
    direction: 'desc'
};

// Initialize when page loads
document.addEventListener('DOMContentLoaded', function() {
    setupSorting();
    setupStatusFilter();
    setupSearch();
    
    // Initialize records per page selector
    const recordsSelect = document.getElementById('recordsPerPage');
    if (recordsSelect) {
        recordsSelect.value = '<%= recordsPerPageAttr %>';
    }
});

function setupSorting() {
    document.querySelectorAll('.sortable').forEach(header => {
        header.addEventListener('click', () => {
            const sortField = header.dataset.sort;
            handleSort(sortField);
        });
    });
}

function handleSort(field) {
    // Update sort direction
    if (currentSort.field === field) {
        currentSort.direction = currentSort.direction === 'asc' ? 'desc' : 'asc';
    } else {
        currentSort.field = field;
        currentSort.direction = 'asc';
    }
    
    // Update UI
    updateSortHeaders();
    
    // Sort and display
    sortAndDisplayBookings();
}

function updateSortHeaders() {
    // Reset all headers
    document.querySelectorAll('.sortable').forEach(header => {
        const icon = header.querySelector('svg');
        icon.classList.remove('text-red-600');
        icon.classList.add('text-gray-600');
    });
    
    // Highlight current sort header
    const currentHeader = document.querySelector(`[data-sort="${currentSort.field}"]`);
    if (currentHeader) {
        const icon = currentHeader.querySelector('svg');
        icon.classList.remove('text-gray-600');
        icon.classList.add('text-red-600');
    }
}

function sortAndDisplayBookings() {
    const tableBody = document.getElementById('bookingTableBody');
    const rows = Array.from(tableBody.querySelectorAll('.booking-row'));
    
    rows.sort((a, b) => {
        let aValue, bValue;
        
        switch (currentSort.field) {
            case 'bookingId':
                aValue = parseInt(a.dataset.bookingId);
                bValue = parseInt(b.dataset.bookingId);
                break;
            case 'movieTitle':
                aValue = a.dataset.movieTitle;
                bValue = b.dataset.movieTitle;
                break;
            case 'theaterName':
                aValue = a.dataset.theaterName;
                bValue = b.dataset.theaterName;
                break;
            case 'seatCount':
                aValue = parseInt(a.dataset.seatCount);
                bValue = parseInt(b.dataset.seatCount);
                break;
            case 'totalPrice':
                aValue = parseFloat(a.dataset.totalPrice);
                bValue = parseFloat(b.dataset.totalPrice);
                break;
            default:
                aValue = parseInt(a.dataset.bookingDate);
                bValue = parseInt(b.dataset.bookingDate);
        }
        
        // Handle string comparison
        if (typeof aValue === 'string') {
            aValue = aValue.toLowerCase();
            bValue = bValue.toLowerCase();
        }
        
        if (currentSort.direction === 'asc') {
            return aValue > bValue ? 1 : aValue < bValue ? -1 : 0;
        } else {
            return aValue < bValue ? 1 : aValue > bValue ? -1 : 0;
        }
    });
    
    // Update table
    tableBody.innerHTML = '';
    rows.forEach(row => tableBody.appendChild(row));
}

function setupStatusFilter() {
    document.querySelectorAll('.statusBtn').forEach(card => {
        card.addEventListener('click', () => {
            const status = card.dataset.status;
            
            // Update active card
            document.querySelectorAll('.statusBtn').forEach(c => {
                c.classList.remove('border-red-500', 'bg-red-50', 'text-red-600');
                c.classList.add('border-gray-300', 'bg-white', 'text-gray-700');
            });
            
            card.classList.add('border-red-500', 'bg-red-50', 'text-red-600');
            card.classList.remove('border-gray-300', 'bg-white', 'text-gray-700');
            
            // Apply filter
            applyStatusFilter(status);
        });
    });
}

function applyStatusFilter(status) {
    const tableBody = document.getElementById('bookingTableBody');
    const rows = tableBody.querySelectorAll('.booking-row');
    
    rows.forEach(row => {
        if (status === 'all' || row.dataset.status === status) {
            row.style.display = '';
        } else {
            row.style.display = 'none';
        }
    });
}

function setupSearch() {
    const searchInput = document.getElementById('searchInput');
    searchInput.addEventListener('input', debounce(function() {
        const searchTerm = this.value.toLowerCase().trim();
        filterBySearch(searchTerm);
    }, 300));
}

function filterBySearch(searchTerm) {
    const tableBody = document.getElementById('bookingTableBody');
    const rows = tableBody.querySelectorAll('.booking-row');
    
    rows.forEach(row => {
        const bookingId = row.dataset.bookingId;
        const movieTitle = row.dataset.movieTitle;
        const theaterName = row.dataset.theaterName;
        
        const matches = !searchTerm || 
            bookingId.includes(searchTerm) ||
            movieTitle.includes(searchTerm) ||
            theaterName.includes(searchTerm);
        
        row.style.display = matches ? '' : 'none';
    });
}

// Pagination functions
function handlePrev() {
    <% if (currentPageAttr > 1) { %>
        const prevPage = <%= currentPageAttr - 1 %>;
        navigateToPage(prevPage);
    <% } %>
}

function handleNext() {
    <% if (currentPageAttr < totalPages) { %>
        const nextPage = <%= currentPageAttr + 1 %>;
        navigateToPage(nextPage);
    <% } %>
}

function handleLimitChange() {
    const select = document.getElementById('recordsPerPage');
    const newLimit = select.value;
    
    // Create URL with new limit
    let url = '?limit=' + newLimit;
    
    // Keep search parameter if exists
    const searchQuery = '<%= searchQuery != null ? searchQuery : "" %>';
    if (searchQuery) {
        url += '&search=' + encodeURIComponent(searchQuery);
    }
    
    // Reset to first page when changing limit
    url += '&page=1';
    
    window.location.href = url;
}

function navigateToPage(page) {
    let url = '?page=' + page;
    
    // Add search parameter if exists
    const searchQuery = '<%= searchQuery != null ? searchQuery : "" %>';
    if (searchQuery) {
        url += '&search=' + encodeURIComponent(searchQuery);
    }
    
    // Add limit parameter
    const currentLimit = <%= recordsPerPageAttr %>;
    url += '&limit=' + currentLimit;
    
    window.location.href = url;
}

function cancelBooking(bookingId) {
    if (confirm('Are you sure you want to cancel this booking?')) {
        document.getElementById('cancelBookingId').value = bookingId;
        document.getElementById('cancelForm').submit();
    }
}

function debounce(func, delay) {
    let timer;
    return function(...args) {
        clearTimeout(timer);
        timer = setTimeout(() => func.apply(this, args), delay);
    };
}
</script>

<jsp:include page="layout/footer.jsp"/>
<jsp:include page="layout/JSPFooter.jsp"/>