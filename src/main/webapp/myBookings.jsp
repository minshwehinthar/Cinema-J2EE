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
    }
    
    SimpleDateFormat dateFormat = new SimpleDateFormat("MMM dd, yyyy");
    SimpleDateFormat timeFormat = new SimpleDateFormat("hh:mm a");
    
    // Get pagination attributes
    int currentPageAttr = (Integer) request.getAttribute("currentPage");
    int totalPages = (Integer) request.getAttribute("totalPages");
    int totalRecords = (Integer) request.getAttribute("totalRecords");
    int startRecord = (Integer) request.getAttribute("startRecord");
    int endRecord = (Integer) request.getAttribute("endRecord");
%>

<jsp:include page="layout/JSPHeader.jsp"/>
<jsp:include page="layout/header.jsp"/>

<div class="min-h-screen bg-gray-50 py-8">
    <div class="container mx-auto px-4 max-w-6xl">
        <!-- Header -->
        <div class="text-center mb-12">
            <h1 class="text-4xl font-bold text-gray-900 mb-4">My Bookings</h1>
            <div class="w-24 h-1 bg-red-600 mx-auto"></div>
        </div>
        <div class="flex justify-between items-center">
        <!-- Search Bar -->
        <div class="mb-8">
            <form method="GET" action="" class="max-w-2xl mx-auto">
                <div class="relative">
                    <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                        <svg class="h-5 w-5 text-gray-400" fill="currentColor" viewBox="0 0 20 20">
                            <path fill-rule="evenodd" d="M8 4a4 4 0 100 8 4 4 0 000-8zM2 8a6 6 0 1110.89 3.476l4.817 4.817a1 1 0 01-1.414 1.414l-4.816-4.816A6 6 0 012 8z" clip-rule="evenodd"></path>
                        </svg>
                    </div>
                    <input type="text" 
                           name="search" 
                           id="search"
                           value="<%= searchQuery != null ? searchQuery : "" %>"
                           placeholder="Search by Booking ID, Movie Title, or Theater Name..." 
                           class="block w-full pl-10 pr-12 py-4 border border-gray-300 rounded-2xl ring-0 ring-transparent focus:border-red-500 text-sm">
                    <div class="absolute inset-y-0 right-0 flex items-center pr-3">
                        <% if (searchQuery != null && !searchQuery.isEmpty()) { %>
                        <a href="?" class="text-gray-400 hover:text-gray-600 mr-2">
                            <svg class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
                            </svg>
                        </a>
                        <% } %>
                    </div>
                </div>
                <% if (searchQuery != null && !searchQuery.isEmpty()) { %>
                <div class="mt-2 text-sm text-gray-600 text-center">
                    Showing results for: "<%= searchQuery %>"
                    <% if (filteredBookings != null) { %>
                    - <%= filteredBookings.size() %> booking(s) found
                    <% } %>
                </div>
                <% } %>
            </form>
        </div>

       <!-- Status Cards - Auto Width Based on Content -->
<div class="flex flex-wrap gap-4 mb-6">
    <!-- All Bookings -->
    <div class="bg-white rounded-xl border border-gray-200 px-6 py-4 cursor-pointer status-card active" data-status="all">
        <div class="flex items-center space-x-2 text-gray-900 font-medium">
            <span>All Bookings</span>
            <span class="font-bold text-red-600"><%= filteredBookings != null ? filteredBookings.size() : 0 %></span>
        </div>
    </div>

    <!-- Confirmed -->
    <div class="bg-white rounded-xl border border-gray-200 px-6 py-4 cursor-pointer status-card" data-status="confirmed">
        <%
            long confirmedBookings = 0;
            if (filteredBookings != null) {
                confirmedBookings = filteredBookings.stream()
                    .filter(b -> b != null && "confirmed".equalsIgnoreCase(b.getStatus()))
                    .count();
            }
        %>
        <div class="flex items-center space-x-2 text-gray-900 font-medium">
            <span>Confirmed</span>
            <span class="font-bold text-green-600"><%= confirmedBookings %></span>
        </div>
    </div>

    <!-- Pending -->
    <div class="bg-white rounded-xl border border-gray-200 px-6 py-4 cursor-pointer status-card" data-status="pending">
        <%
            long pendingBookings = 0;
            if (filteredBookings != null) {
                pendingBookings = filteredBookings.stream()
                    .filter(b -> b != null && "pending".equalsIgnoreCase(b.getStatus()))
                    .count();
            }
        %>
        <div class="flex items-center space-x-2 text-gray-900 font-medium">
            <span>Pending</span>
            <span class="font-bold text-yellow-600"><%= pendingBookings %></span>
        </div>
    </div>

    <!-- Cancelled -->
    <div class="bg-white rounded-xl border border-gray-200 px-6 py-4 cursor-pointer status-card" data-status="cancelled">
        <%
            long cancelledBookings = 0;
            if (filteredBookings != null) {
                cancelledBookings = filteredBookings.stream()
                    .filter(b -> b != null && "cancelled".equalsIgnoreCase(b.getStatus()))
                    .count();
            }
        %>
        <div class="flex items-center space-x-2 text-gray-900 font-medium">
            <span>Cancelled</span>
            <span class="font-bold text-red-600"><%= cancelledBookings %></span>
        </div>
    </div>
</div>

        
        </div>

        <!-- Results Count -->
        <div class="flex justify-between items-center mb-4">
            <div class="text-sm text-gray-600">
                Showing <%= startRecord %> to <%= endRecord %> of <%= totalRecords %> bookings
                <% if (searchQuery != null && !searchQuery.isEmpty()) { %>
                (filtered from <%= allBookings != null ? allBookings.size() : 0 %> total bookings)
                <% } %>
            </div>
        </div>

        <!-- Bookings Table -->
        <div class="bg-white rounded-2xl shadow-sm border border-gray-100 overflow-hidden mb-6">
            <% if (userBookings == null || userBookings.isEmpty()) { %>
                <div class="text-center py-16 text-gray-500">
                    <h3 class="text-2xl font-semibold mb-3">
                        <%= allBookings == null ? "Error loading bookings" : 
                           (searchQuery != null && !searchQuery.isEmpty() ? "No bookings found" : "No bookings yet") %>
                    </h3>
                    <p class="mb-8">
                        <%= allBookings == null ? "Please try again later." : 
                           (searchQuery != null && !searchQuery.isEmpty() ? 
                           "No bookings match your search criteria." : "Start booking your first ticket.") %>
                    </p>
                    <% if (allBookings != null && (searchQuery == null || searchQuery.isEmpty())) { %>
                    <a href="movies.jsp" class="inline-flex items-center px-8 py-3 bg-red-600 text-white font-semibold rounded-xl hover:bg-red-700 transition shadow-sm">
                        Book Tickets
                    </a>
                    <% } %>
                    <% if (searchQuery != null && !searchQuery.isEmpty()) { %>
                    <a href="?" class="inline-flex items-center px-8 py-3 bg-gray-600 text-white font-semibold rounded-xl hover:bg-gray-700 transition shadow-sm ml-3">
                        Clear Search
                    </a>
                    <% } %>
                </div>
            <% } else { %>
                <div class="overflow-x-auto">
                    <table class="w-full">
                        <thead class="bg-gray-50 border-b border-gray-200">
                            <tr>
                                <th class="px-6 py-4 text-left text-sm font-semibold text-gray-700 uppercase tracking-wider cursor-pointer sortable" data-sort="bookingId">
                                    <div class="flex items-center space-x-1">
                                        <span>Booking Details</span>
                                        <div class="sort-icons inline-flex flex-col">
                                            <svg class="h-3 w-3 text-gray-400 sort-asc" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 15l7-7 7 7"/>
                                            </svg>
                                            <svg class="h-3 w-3 text-gray-400 sort-desc" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7"/>
                                            </svg>
                                        </div>
                                    </div>
                                </th>
                                <th class="px-6 py-4 text-left text-sm font-semibold text-gray-700 uppercase tracking-wider cursor-pointer sortable" data-sort="movieTitle">
                                    <div class="flex items-center space-x-1">
                                        <span>Movie & Showtime</span>
                                        <div class="sort-icons inline-flex flex-col">
                                            <svg class="h-3 w-3 text-gray-400 sort-asc" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 15l7-7 7 7"/>
                                            </svg>
                                            <svg class="h-3 w-3 text-gray-400 sort-desc" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7"/>
                                            </svg>
                                        </div>
                                    </div>
                                </th>
                                <th class="px-6 py-4 text-left text-sm font-semibold text-gray-700 uppercase tracking-wider cursor-pointer sortable" data-sort="theaterName">
                                    <div class="flex items-center space-x-1">
                                        <span>Theater</span>
                                        <div class="sort-icons inline-flex flex-col">
                                            <svg class="h-3 w-3 text-gray-400 sort-asc" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 15l7-7 7 7"/>
                                            </svg>
                                            <svg class="h-3 w-3 text-gray-400 sort-desc" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7"/>
                                            </svg>
                                        </div>
                                    </div>
                                </th>
                                <th class="px-6 py-4 text-left text-sm font-semibold text-gray-700 uppercase tracking-wider cursor-pointer sortable" data-sort="seatCount">
                                    <div class="flex items-center space-x-1">
                                        <span>Seats</span>
                                        <div class="sort-icons inline-flex flex-col">
                                            <svg class="h-3 w-3 text-gray-400 sort-asc" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 15l7-7 7 7"/>
                                            </svg>
                                            <svg class="h-3 w-3 text-gray-400 sort-desc" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7"/>
                                            </svg>
                                        </div>
                                    </div>
                                </th>
                                <th class="px-6 py-4 text-left text-sm font-semibold text-gray-700 uppercase tracking-wider cursor-pointer sortable" data-sort="totalPrice">
                                    <div class="flex items-center space-x-1">
                                        <span>Amount</span>
                                        <div class="sort-icons inline-flex flex-col">
                                            <svg class="h-3 w-3 text-gray-400 sort-asc" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 15l7-7 7 7"/>
                                            </svg>
                                            <svg class="h-3 w-3 text-gray-400 sort-desc" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7"/>
                                            </svg>
                                        </div>
                                    </div>
                                </th>
                                <th class="px-6 py-4 text-left text-sm font-semibold text-gray-700 uppercase tracking-wider cursor-pointer sortable" data-sort="status">
                                    <div class="flex items-center space-x-1">
                                        <span>Status</span>
                                        <div class="sort-icons inline-flex flex-col">
                                            <svg class="h-3 w-3 text-gray-400 sort-asc" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 15l7-7 7 7"/>
                                            </svg>
                                            <svg class="h-3 w-3 text-gray-400 sort-desc" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7"/>
                                            </svg>
                                        </div>
                                    </div>
                                </th>
                                <th class="px-6 py-4 text-left text-sm font-semibold text-gray-700 uppercase tracking-wider">Actions</th>
                            </tr>
                        </thead>
                        <tbody id="bookingTableBody" class="bg-white divide-y divide-gray-100">
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
                            <tr class="booking-row" 
                                data-status="<%= booking.getStatus().toLowerCase() %>"
                                data-booking-id="<%= booking.getBookingId() %>"
                                data-movie-title="<%= movie != null ? movie.getTitle().toLowerCase() : "" %>"
                                data-theater-name="<%= theater != null ? theater.getName().toLowerCase() : "" %>"
                                data-seat-count="<%= seats != null ? seats.size() : 0 %>"
                                data-total-price="<%= booking.getTotalPrice() != null ? booking.getTotalPrice() : 0 %>"
                                data-booking-date="<%= booking.getBookingTime() != null ? booking.getBookingTime().getTime() : 0 %>">
                                <!-- Booking Details -->
                                <td class="px-6 py-5">
                                    <div class="text-base font-semibold text-gray-900">#<%= booking.getBookingId() %></div>
                                    <div class="text-sm text-gray-500 mt-1">
                                        <%= booking.getBookingTime() != null ? dateFormat.format(booking.getBookingTime()) : "N/A" %>
                                    </div>
                                    <% if (booking.getBookingTime() != null) { %>
                                    <div class="text-xs text-gray-400">
                                        <%= timeFormat.format(booking.getBookingTime()) %>
                                    </div>
                                    <% } %>
                                </td>
                                
                                <!-- Movie & Showtime -->
                                <td class="px-6 py-5">
                                    <% if (movie != null) { %>
                                    <div class="text-sm font-semibold text-gray-900 truncate max-w-xs" title="<%= movie.getTitle() %>">
                                        <%= movie.getTitle() %>
                                    </div>
                                    <% } %>
                                    <% if (showtime != null) { %>
                                    <div class="text-xs text-gray-600 mt-1">
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
                                <td class="px-6 py-5">
                                    <% if (theater != null) { %>
                                    <div class="text-sm font-medium text-gray-900"><%= theater.getName() %></div>
                                    <div class="text-xs text-gray-500 truncate max-w-xs" title="<%= theater.getLocation() %>">
                                        <%= theater.getLocation() %>
                                    </div>
                                    <% } else { %>
                                    <div class="text-sm text-gray-500">Theater info not available</div>
                                    <% } %>
                                </td>
                                
                                <!-- Seats -->
                                <td class="px-6 py-5">
                                    <% if (seats != null && !seats.isEmpty()) { %>
                                    <div class="text-sm font-medium text-gray-900 mb-1">
                                        <%= seats.size() %> seat<%= seats.size() > 1 ? "s" : "" %>
                                    </div>
                                    <div class="text-xs text-gray-600 max-w-xs">
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
                                <td class="px-6 py-5">
                                    <div class="text-base font-bold text-gray-900">
                                        <%= booking.getTotalPrice() != null ? booking.getTotalPrice() + " MMK" : "N/A" %>
                                    </div>
                                    <% if (seats != null && !seats.isEmpty()) { %>
                                    <div class="text-xs text-gray-500">
                                        <%= seats.size() %> x <%= seats.get(0).getPrice() != null ? seats.get(0).getPrice() + " MMK" : "" %>
                                    </div>
                                    <% } %>
                                </td>
                                
                                <!-- Status -->
                                <td class="px-6 py-5">
                                    <span class="inline-flex items-center px-3 py-1 rounded-full text-xs font-medium <%= statusClass %>">
                                        <%= statusText %>
                                    </span>
                                </td>
                                
                                <!-- Actions -->
                                <td class="px-6 py-5">
                                    <div class="flex space-x-3">
                                        <a href="viewTicket.jsp?bookingId=<%= booking.getBookingId() %>" 
                                           class="inline-flex items-center px-4 py-2 bg-red-600 text-white text-sm font-medium rounded-lg hover:bg-red-700 transition shadow-sm">
                                            View Ticket
                                        </a>
                                        <% if ("confirmed".equalsIgnoreCase(booking.getStatus()) || "pending".equalsIgnoreCase(booking.getStatus())) { %>
                                        <button onclick="UserCancelBookingServlet(<%= booking.getBookingId() %>)" 
                                                class="inline-flex items-center px-4 py-2 border border-red-600 text-red-600 text-sm font-medium rounded-lg hover:bg-red-600 hover:text-white transition">
                                            Cancel
                                        </button>
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
        <% if (totalPages > 1) { %>
        <div class="flex items-center justify-between border-t border-gray-200 bg-white px-4 py-3 sm:px-6 rounded-2xl shadow-sm">
            <!-- Mobile view -->
            <div class="flex flex-1 justify-between sm:hidden">
                <% if (currentPageAttr > 1) { %>
                <a href="?page=<%= currentPageAttr - 1 %><%= searchQuery != null ? "&search=" + java.net.URLEncoder.encode(searchQuery, "UTF-8") : "" %>" class="relative inline-flex items-center rounded-md border border-gray-300 bg-white px-4 py-2 text-sm font-medium text-gray-700 hover:bg-gray-50">Previous</a>
                <% } %>
                <% if (currentPageAttr < totalPages) { %>
                <a href="?page=<%= currentPageAttr + 1 %><%= searchQuery != null ? "&search=" + java.net.URLEncoder.encode(searchQuery, "UTF-8") : "" %>" class="relative ml-3 inline-flex items-center rounded-md border border-gray-300 bg-white px-4 py-2 text-sm font-medium text-gray-700 hover:bg-gray-50">Next</a>
                <% } %>
            </div>
            
            <!-- Desktop view -->
            <div class="hidden sm:flex sm:flex-1 sm:items-center sm:justify-between">
                <div>
                    <p class="text-sm text-gray-700">
                        Showing <span class="font-medium"><%= startRecord %></span> to <span class="font-medium"><%= endRecord %></span> of <span class="font-medium"><%= totalRecords %></span> results
                    </p>
                </div>
                <div>
                    <nav class="isolate inline-flex -space-x-px rounded-md shadow-sm" aria-label="Pagination">
                        <!-- Previous Page -->
                        <% if (currentPageAttr > 1) { %>
                        <a href="?page=<%= currentPageAttr - 1 %><%= searchQuery != null ? "&search=" + java.net.URLEncoder.encode(searchQuery, "UTF-8") : "" %>" class="relative inline-flex items-center rounded-l-md px-2 py-2 text-gray-400 ring-1 ring-inset ring-gray-300 hover:bg-gray-50 focus:z-20 focus:outline-offset-0">
                            <span class="sr-only">Previous</span>
                            <svg class="h-5 w-5" viewBox="0 0 20 20" fill="currentColor" aria-hidden="true">
                                <path fill-rule="evenodd" d="M12.79 5.23a.75.75 0 01-.02 1.06L8.832 10l3.938 3.71a.75.75 0 11-1.04 1.08l-4.5-4.25a.75.75 0 010-1.08l4.5-4.25a.75.75 0 011.06.02z" clip-rule="evenodd" />
                            </svg>
                        </a>
                        <% } %>

                        <!-- Page Numbers -->
                        <% 
                            int startPage = Math.max(1, currentPageAttr - 2);
                            int endPage = Math.min(totalPages, currentPageAttr + 2);
                            
                            if (startPage > 1) { 
                        %>
                        <a href="?page=1<%= searchQuery != null ? "&search=" + java.net.URLEncoder.encode(searchQuery, "UTF-8") : "" %>" class="relative inline-flex items-center px-4 py-2 text-sm font-semibold text-gray-900 ring-1 ring-inset ring-gray-300 hover:bg-gray-50 focus:z-20 focus:outline-offset-0">1</a>
                        <% if (startPage > 2) { %>
                        <span class="relative inline-flex items-center px-4 py-2 text-sm font-semibold text-gray-700 ring-1 ring-inset ring-gray-300 focus:outline-offset-0">...</span>
                        <% } }
                        
                        for (int i = startPage; i <= endPage; i++) { 
                            if (i == currentPageAttr) { 
                        %>
                        <a href="?page=<%= i %><%= searchQuery != null ? "&search=" + java.net.URLEncoder.encode(searchQuery, "UTF-8") : "" %>" aria-current="page" class="relative z-10 inline-flex items-center bg-red-600 px-4 py-2 text-sm font-semibold text-white focus:z-20 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-red-600"><%= i %></a>
                        <% } else { %>
                        <a href="?page=<%= i %><%= searchQuery != null ? "&search=" + java.net.URLEncoder.encode(searchQuery, "UTF-8") : "" %>" class="relative inline-flex items-center px-4 py-2 text-sm font-semibold text-gray-900 ring-1 ring-inset ring-gray-300 hover:bg-gray-50 focus:z-20 focus:outline-offset-0"><%= i %></a>
                        <% } 
                        } 
                        
                        if (endPage < totalPages) { 
                            if (endPage < totalPages - 1) { %>
                        <span class="relative inline-flex items-center px-4 py-2 text-sm font-semibold text-gray-700 ring-1 ring-inset ring-gray-300 focus:outline-offset-0">...</span>
                        <% } %>
                        <a href="?page=<%= totalPages %><%= searchQuery != null ? "&search=" + java.net.URLEncoder.encode(searchQuery, "UTF-8") : "" %>" class="relative inline-flex items-center px-4 py-2 text-sm font-semibold text-gray-900 ring-1 ring-inset ring-gray-300 hover:bg-gray-50 focus:z-20 focus:outline-offset-0"><%= totalPages %></a>
                        <% } %>

                        <!-- Next Page -->
                        <% if (currentPageAttr < totalPages) { %>
                        <a href="?page=<%= currentPageAttr + 1 %><%= searchQuery != null ? "&search=" + java.net.URLEncoder.encode(searchQuery, "UTF-8") : "" %>" class="relative inline-flex items-center rounded-r-md px-2 py-2 text-gray-400 ring-1 ring-inset ring-gray-300 hover:bg-gray-50 focus:z-20 focus:outline-offset-0">
                            <span class="sr-only">Next</span>
                            <svg class="h-5 w-5" viewBox="0 0 20 20" fill="currentColor" aria-hidden="true">
                                <path fill-rule="evenodd" d="M7.21 14.77a.75.75 0 01.02-1.06L11.168 10 7.23 6.29a.75.75 0 111.04-1.08l4.5 4.25a.75.75 0 010 1.08l-4.5 4.25a.75.75 0 01-1.06-.02z" clip-rule="evenodd" />
                            </svg>
                        </a>
                        <% } %>
                    </nav>
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
    direction: 'desc' // 'asc' or 'desc'
};

// All bookings data
let allBookingsData = [];

// Initialize when page loads
document.addEventListener('DOMContentLoaded', function() {
    initializeBookingsData();
    setupSorting();
    setupStatusFilter();
    setupSearch();
});

function initializeBookingsData() {
    const bookingRows = document.querySelectorAll('.booking-row');
    allBookingsData = Array.from(bookingRows).map(row => ({
        element: row,
        bookingId: parseInt(row.dataset.bookingId),
        status: row.dataset.status,
        movieTitle: row.dataset.movieTitle || '',
        theaterName: row.dataset.theaterName || '',
        seatCount: parseInt(row.dataset.seatCount) || 0,
        totalPrice: parseFloat(row.dataset.totalPrice) || 0,
        bookingDate: parseInt(row.dataset.bookingDate) || 0
    }));
}

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
        const ascIcon = header.querySelector('.sort-asc');
        const descIcon = header.querySelector('.sort-desc');
        
        ascIcon.classList.remove('text-red-600');
        ascIcon.classList.add('text-gray-400');
        descIcon.classList.remove('text-red-600');
        descIcon.classList.add('text-gray-400');
    });
    
    // Highlight current sort header
    const currentHeader = document.querySelector(`[data-sort="${currentSort.field}"]`);
    if (currentHeader) {
        const ascIcon = currentHeader.querySelector('.sort-asc');
        const descIcon = currentHeader.querySelector('.sort-desc');
        
        if (currentSort.direction === 'asc') {
            ascIcon.classList.remove('text-gray-400');
            ascIcon.classList.add('text-red-600');
        } else {
            descIcon.classList.remove('text-gray-400');
            descIcon.classList.add('text-red-600');
        }
    }
}

function sortAndDisplayBookings() {
    const filteredRows = getFilteredRows();
    
    // Sort the rows
    filteredRows.sort((a, b) => {
        let aValue, bValue;
        
        switch (currentSort.field) {
            case 'bookingId':
                aValue = a.bookingId;
                bValue = b.bookingId;
                break;
            case 'movieTitle':
                aValue = a.movieTitle;
                bValue = b.movieTitle;
                break;
            case 'theaterName':
                aValue = a.theaterName;
                bValue = b.theaterName;
                break;
            case 'seatCount':
                aValue = a.seatCount;
                bValue = b.seatCount;
                break;
            case 'totalPrice':
                aValue = a.totalPrice;
                bValue = b.totalPrice;
                break;
            case 'status':
                aValue = a.status;
                bValue = b.status;
                break;
            default:
                aValue = a.bookingDate;
                bValue = b.bookingDate;
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
    const tableBody = document.getElementById('bookingTableBody');
    tableBody.innerHTML = '';
    
    filteredRows.forEach(booking => {
        tableBody.appendChild(booking.element.cloneNode(true));
    });
    
    updateStats();
}

function setupStatusFilter() {
    document.querySelectorAll('.status-card').forEach(card => {
        card.addEventListener('click', () => {
            const status = card.dataset.status;
            
            // Update active card
            document.querySelectorAll('.status-card').forEach(c => {
                c.classList.remove('active', 'ring-2', 'ring-red-500');
            });
            card.classList.add('active', 'ring-2', 'ring-red-500');
            
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
    
    updateStats();
    updateSortHeaders();
}

function setupSearch() {
    const searchInput = document.getElementById('search');
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
    
    updateStats();
}

function getFilteredRows() {
    const tableBody = document.getElementById('bookingTableBody');
    const visibleRows = Array.from(tableBody.querySelectorAll('.booking-row:not([style*="display: none"])'));
    
    return visibleRows.map(row => {
        return allBookingsData.find(booking => booking.bookingId === parseInt(row.dataset.bookingId));
    }).filter(booking => booking !== undefined);
}

function updateStats() {
    const visibleRows = getFilteredRows();
    
    // Update counts
    document.getElementById('totalBookings').textContent = visibleRows.length;
    document.getElementById('confirmedBookings').textContent = visibleRows.filter(b => b.status === 'confirmed').length;
    document.getElementById('pendingBookings').textContent = visibleRows.filter(b => b.status === 'pending').length;
    document.getElementById('cancelledBookings').textContent = visibleRows.filter(b => b.status === 'cancelled').length;
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

// Auto-focus search input
document.addEventListener('DOMContentLoaded', function() {
    const searchInput = document.getElementById('search');
    if (searchInput) {
        searchInput.focus();
        searchInput.setSelectionRange(searchInput.value.length, searchInput.value.length);
    }
});
</script>

<style>
.sortable:hover {
    background-color: #f9fafb;
}

.sort-icons {
    opacity: 0.6;
}

.sortable:hover .sort-icons {
    opacity: 1;
}

.status-card.active {
    transform: translateY(-2px);
    box-shadow: 0 10px 25px -5px rgba(0, 0, 0, 0.1), 0 10px 10px -5px rgba(0, 0, 0, 0.04);
}

.status-card {
    transition: all 0.3s ease;
    cursor: pointer;
}

.status-card:hover:not(.active) {
    transform: translateY(-1px);
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
}

.booking-row {
    transition: all 0.3s ease;
}

.booking-row:hover {
    background-color: #f9fafb;
}
</style>

<jsp:include page="layout/footer.jsp"/>
<jsp:include page="layout/JSPFooter.jsp"/>