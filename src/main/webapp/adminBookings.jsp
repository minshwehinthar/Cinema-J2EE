<%@page import="com.demo.dao.TheaterDAO"%>
<%@page import="com.demo.dao.BookingDao"%>
<%@page import="com.demo.dao.UserDAO"%>
<%@page import="com.demo.dao.MoviesDao"%>
<%@page import="com.demo.dao.ShowtimesDao"%>

<%@ page import="com.demo.model.Booking" %>
<%@ page import="com.demo.model.User" %>
<%@ page import="com.demo.model.Theater" %>
<%@ page import="com.demo.model.Movies" %>
<%@ page import="com.demo.model.Showtime" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    // Check if user is admin or theater admin
    User adminUser = (User) session.getAttribute("user");
    if (adminUser == null || (!"admin".equals(adminUser.getRole()) && !"theateradmin".equals(adminUser.getRole()))) {
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
                recordsPerPage = 10;
            }
        } catch (NumberFormatException e) {
            recordsPerPage = 10;
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

    // Get theater info for theater admin
    Theater userTheater = null;
    if ("theater_admin".equals(adminUser.getRole())) {
        TheaterDAO theaterDao = new TheaterDAO();
        userTheater = theaterDao.getTheaterByUserId(adminUser.getUserId());
    }

    // Initialize DAOs for additional data
    BookingDao bookingDAO = new BookingDao();
    UserDAO userDAO = new UserDAO();
    MoviesDao movieDAO = new MoviesDao();
    TheaterDAO theaterDAO = new TheaterDAO();
    ShowtimesDao showtimeDAO = new ShowtimesDao();
    
    // Get bookings based on user role
    List<Booking> allBookings = null;
    List<Booking> userBookings = null;
    String errorMessage = null;
    
    try {
        if ("theater_admin".equals(adminUser.getRole()) && userTheater != null) {
            allBookings = bookingDAO.getBookingsByTheaterId(userTheater.getTheaterId());
        } else {
            allBookings = bookingDAO.getAllBookings();
        }
        
        // Calculate pagination
        int totalRecords = allBookings.size();
        int totalPages = (int) Math.ceil((double) totalRecords / recordsPerPage);
        
        if (currentPage > totalPages && totalPages > 0) {
            currentPage = totalPages;
        }
        
        // Get sublist for current page
        int start = (currentPage - 1) * recordsPerPage;
        int end = Math.min(start + recordsPerPage, totalRecords);
        
        if (totalRecords > 0) {
            userBookings = allBookings.subList(start, end);
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
        allBookings = new java.util.ArrayList<>();
        userBookings = new java.util.ArrayList<>();
        request.setAttribute("currentPage", 1);
        request.setAttribute("totalPages", 0);
        request.setAttribute("totalRecords", 0);
        request.setAttribute("recordsPerPage", recordsPerPage);
        request.setAttribute("startRecord", 0);
        request.setAttribute("endRecord", 0);
    }
    
    SimpleDateFormat dateFormat = new SimpleDateFormat("MMM dd, yyyy");
    SimpleDateFormat timeFormat = new SimpleDateFormat("HH:mm");
    
    // Get pagination attributes
    int currentPageAttr = (Integer) request.getAttribute("currentPage");
    int totalPages = (Integer) request.getAttribute("totalPages");
    int totalRecords = (Integer) request.getAttribute("totalRecords");
    int recordsPerPageAttr = (Integer) request.getAttribute("recordsPerPage");
    int startRecord = (Integer) request.getAttribute("startRecord");
    int endRecord = (Integer) request.getAttribute("endRecord");
%>


<div class="flex">
    <jsp:include page="layout/sidebar.jsp" />
    <div class="flex-1 sm:ml-64">
        <jsp:include page="layout/AdminHeader.jsp" />
        <div class="p-8 max-w-8xl mx-auto">
            
            <!-- Header Section -->
            <div class="flex justify-between items-center mb-6">
                <div>
                    <h1 class="text-2xl font-bold text-gray-900">Booking Management</h1>
                    <p class="text-gray-600 mt-1">
                        <% if ("theater_admin".equals(adminUser.getRole()) && userTheater != null) { %>
                            Managing bookings for <span class="font-semibold text-red-600"><%= userTheater.getName() %></span>
                        <% } else { %>
                            Manage all customer bookings and seat availability
                        <% } %>
                    </p>
                </div>
                
            </div>

            <!-- Theater Admin Info Card -->
            <% if ("theater_admin".equals(adminUser.getRole()) && userTheater != null) { %>
            <div class="bg-gradient-to-r from-red-50 to-white border border-red-200 rounded-lg p-6 mb-6 shadow-sm">
                <div class="flex items-center justify-between">
                    <div class="flex items-center space-x-4">
                        <div class="w-12 h-12 bg-red-100 rounded-lg flex items-center justify-center">
                            <svg class="w-6 h-6 text-red-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4"/>
                            </svg>
                        </div>
                        <div>
                            <h3 class="text-lg font-semibold text-red-800"><%= userTheater.getName() %></h3>
                            <p class="text-red-600 text-sm"><%= userTheater.getLocation() %></p>
                        </div>
                    </div>
                    <span class="inline-flex items-center px-3 py-1 rounded-full text-sm font-medium bg-red-100 text-red-800 border border-red-200">
                        Theater Admin
                    </span>
                </div>
            </div>
            <% } %>

            <!-- Search and Filter -->
            <div class="flex justify-between items-center mb-6">
                <div class="flex space-x-4">
                    <input type="text" id="searchInput" placeholder="Search by ID, User, Movie, Theater..." 
                           class="px-4 py-2 border border-gray-300 rounded-lg w-80 focus:outline-none ring-transparent "/>
                    
                    
                </div>
                <div>
                <select id="statusFilter" onchange="filterTable()" 
        class="bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg ring-transprent block w-full p-2.5"
        style="appearance: none; -webkit-appearance: none; -moz-appearance: none; background-image: none;">
    <option value="">All Status</option>
    <option value="pending">Pending</option>
    <option value="confirmed">Confirmed</option>
    <option value="cancelled">Cancelled</option>
</select>
                </div>
            </div>

            <!-- Bookings Table -->
            <div class="bg-white shadow rounded-lg border border-gray-200 overflow-hidden">
                <div class="overflow-x-auto">
                    <table class="min-w-full text-sm text-left">
                        <thead class="bg-red-50 text-gray-900 uppercase text-xs">
                            <tr>
                                <th class="px-6 py-4 font-semibold cursor-pointer" onclick="sortTable('id')">
                                    <div class="flex items-center space-x-1">
                                        <span>Booking ID</span>
                                        <svg class="w-4 h-4 text-gray-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 16V4m0 0L3 8m4-4l4 4m6 0v12m0 0l4-4m-4 4l-4-4"/>
                                        </svg>
                                    </div>
                                </th>
                                <th class="px-6 py-4 font-semibold">Customer Info</th>
                                <th class="px-6 py-4 font-semibold">Movie & Theater</th>
                                <th class="px-6 py-4 font-semibold cursor-pointer" onclick="sortTable('price')">
                                    <div class="flex items-center space-x-1">
                                        <span>Payment</span>
                                        <svg class="w-4 h-4 text-gray-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 16V4m0 0L3 8m4-4l4 4m6 0v12m0 0l4-4m-4 4l-4-4"/>
                                        </svg>
                                    </div>
                                </th>
                                <th class="px-6 py-4 font-semibold">Status</th>
                                <th class="px-6 py-4 font-semibold text-center">Actions</th>
                            </tr>
                        </thead>
                        <tbody id="tableBody" class="divide-y divide-gray-100">
                            <% if (userBookings.isEmpty()) { %>
                                <tr>
                                    <td colspan="6" class="px-6 py-8 text-center">
                                        <div class="w-16 h-16 mx-auto mb-4 text-gray-300">
                                            <svg fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1" d="M16 11V7a4 4 0 00-8 0v4M5 9h14l1 12H4L5 9z"/>
                                            </svg>
                                        </div>
                                        <h3 class="text-lg font-medium text-gray-600 mb-2">No bookings found</h3>
                                        <p class="text-gray-500">
                                            <% if ("theater_admin".equals(adminUser.getRole()) && userTheater != null) { %>
                                                No bookings for <%= userTheater.getName() %> yet.
                                            <% } else { %>
                                                There are no bookings in the system yet.
                                            <% } %>
                                        </p>
                                    </td>
                                </tr>
                            <% } else { 
                                for (Booking booking : userBookings) { 
                                    // Get additional data for each booking
                                    User customer = userDAO.getUserById(booking.getUserId());
                                    Showtime showtime = showtimeDAO.getShowtimeDetails(booking.getShowtimeId());
                                    Movies movie = null;
                                    Theater theater = null;
                                    
                                    if (showtime != null) {
                                        movie = movieDAO.getMovieById(showtime.getMovieId());
                                        theater = theaterDAO.getTheaterById(showtime.getTheaterId());
                                    }
                                    
                                    String statusClass = "";
                                    String statusText = "";
                                    
                                    switch(booking.getStatus().toLowerCase()) {
                                        case "pending":
                                            statusClass = "bg-yellow-100 text-yellow-800 border-yellow-200";
                                            statusText = "Pending";
                                            break;
                                        case "confirmed":
                                            statusClass = "bg-green-100 text-green-800 border-green-200";
                                            statusText = "Confirmed";
                                            break;
                                        case "cancelled":
                                            statusClass = "bg-red-100 text-red-800 border-red-200";
                                            statusText = "Cancelled";
                                            break;
                                        default:
                                            statusClass = "bg-gray-100 text-gray-800 border-gray-200";
                                            statusText = booking.getStatus();
                                    }
                            %>
                            <tr class="hover:bg-red-50 transition-colors duration-150" id="bookingRow<%= booking.getBookingId() %>">
                                <!-- Booking ID -->
                                <td class="px-6 py-4">
                                    <div class="flex items-center space-x-3">
                                        <div class="w-10 h-10 bg-red-100 rounded-lg flex items-center justify-center">
                                            <span class="text-red-600 font-bold text-sm">#<%= booking.getBookingId() %></span>
                                        </div>
                                        <div class="text-xs text-gray-500">
                                            <%= booking.getBookingTime() != null ? dateFormat.format(booking.getBookingTime()) : "N/A" %>
                                        </div>
                                    </div>
                                </td>
                                
                                <!-- Customer Info -->
                                <td class="px-6 py-4">
                                    <div class="font-medium text-gray-900">
                                        <%= customer != null ? customer.getName() : "User #" + booking.getUserId() %>
                                    </div>
                                    <div class="text-sm text-gray-500">
                                        <%= customer != null && customer.getEmail() != null ? customer.getEmail() : "No email" %>
                                    </div>
                                    <div class="text-xs text-gray-400 mt-1">
                                        User ID: #<%= booking.getUserId() %>
                                    </div>
                                </td>
                                
                                <!-- Movie & Theater Details -->
                                <td class="px-6 py-4">
                                    <div class="font-medium text-gray-900">
                                        <%= movie != null ? movie.getTitle() : "Movie #" + (showtime != null ? showtime.getMovieId() : "N/A") %>
                                    </div>
                                    <div class="text-sm text-gray-600">
                                        <%= theater != null ? theater.getName() : "Theater #" + (showtime != null ? showtime.getTheaterId() : "N/A") %>
                                    </div>
                                    <div class="text-xs text-gray-500 mt-1">
                                        Showtime #<%= booking.getShowtimeId() %>
                                        • <%= booking.getSelectedSeatIds() != null ? booking.getSelectedSeatIds().size() + " seats" : "No seats" %>
                                    </div>
                                </td>
                                
                                <!-- Payment -->
                                <td class="px-6 py-4">
                                    <div class="font-semibold text-red-600">
                                        <%= booking.getTotalPrice() != null ? "MMK " + booking.getTotalPrice() : "N/A" %>
                                    </div>
                                    <div class="text-xs text-gray-500 capitalize mt-1">
                                        <%= booking.getPaymentMethod() != null ? booking.getPaymentMethod() : "Unknown" %>
                                    </div>
                                </td>
                                
                                <!-- Status -->
                                <td class="px-6 py-4">
                                    <span class="inline-flex items-center px-3 py-1 rounded-full text-xs font-medium border <%= statusClass %>">
                                         <%= statusText %>
                                    </span>
                                </td>
                                
                                <!-- Actions -->
                                <td class="px-6 py-4">
                                    <div class="flex justify-center space-x-3 min-w-[90px]">
                                        <!-- Approve Button -->
                                        <% if ("pending".equals(booking.getStatus())) { %>
                                            <button onclick="approveBooking(<%= booking.getBookingId() %>)" 
                                                    class="inline-flex items-center justify-center w-10 h-10 text-gray-600 bg-white border border-gray-300 rounded-lg hover:bg-gray-50 hover:border-gray-400 transition-colors duration-200 shadow-sm cursor-pointer">
                                                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-5 h-5">
                                                    <path stroke-linecap="round" stroke-linejoin="round" d="m4.5 12.75 6 6 9-13.5" />
                                                </svg>
                                            </button>
                                        <% } else { %>
                                            <button class="inline-flex items-center justify-center w-10 h-10 text-gray-300 bg-gray-50 border border-gray-200 rounded-lg transition-colors duration-200 shadow-sm cursor-not-allowed opacity-90" disabled>
                                                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-5 h-5">
                                                    <path stroke-linecap="round" stroke-linejoin="round" d="m4.5 12.75 6 6 9-13.5" />
                                                </svg>
                                            </button>
                                        <% } %>

                                        <!-- Details Button -->
                                        <button onclick="viewBookingDetails(<%= booking.getBookingId() %>)" 
                                                class="inline-flex items-center justify-center w-10 h-10 text-gray-600 bg-white border border-gray-300 rounded-lg hover:bg-gray-50 hover:border-gray-400 transition-colors duration-200 shadow-sm cursor-pointer">
                                            <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                                <path d="M2.062 12.348a1 1 0 0 1 0-.696 10.75 10.75 0 0 1 19.876 0 1 1 0 0 1 0 .696 10.75 10.75 0 0 1-19.876 0"/>
                                                <circle cx="12" cy="12" r="3"/>
                                            </svg>
                                        </button>

                                        <!-- Cancel Button -->
                                        <% if ("pending".equals(booking.getStatus()) || "confirmed".equals(booking.getStatus())) { %>
                                            <button onclick="adminCancelBooking(<%= booking.getBookingId() %>)" 
                                                    class="inline-flex items-center justify-center w-10 h-10 text-red-600 bg-white border border-red-300 rounded-lg hover:bg-red-50 hover:border-red-400 transition-colors duration-200 shadow-sm cursor-pointer">
                                                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-5 h-5">
                                                    <path stroke-linecap="round" stroke-linejoin="round" d="M6 18 18 6M6 6l12 12" />
                                                </svg>
                                            </button>
                                        <% } else { %>
                                            <button class="inline-flex items-center justify-center w-10 h-10 text-red-300 bg-gray-50 border border-red-200 rounded-lg transition-colors duration-200 shadow-sm cursor-not-allowed opacity-90" disabled>
                                                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-5 h-5">
                                                    <path stroke-linecap="round" stroke-linejoin="round" d="M6 18 18 6M6 6l12 12" />
                                                </svg>
                                            </button>
                                        <% } %>

                                        <!-- Delete Button -->
                                        <% if ("cancelled".equals(booking.getStatus())) { %>
                                            <button onclick="deleteBooking(<%= booking.getBookingId() %>)" 
                                                    class="inline-flex items-center justify-center w-10 h-10 text-red-600 bg-white border border-red-300 rounded-lg hover:bg-red-50 hover:border-red-400 transition-colors duration-200 shadow-sm cursor-pointer">
                                                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-5 h-5">
                                                    <path stroke-linecap="round" stroke-linejoin="round" d="m14.74 9-.346 9m-4.788 0L9.26 9m9.968-3.21c.342.052.682.107 1.022.166m-1.022-.165L18.16 19.673a2.25 2.25 0 0 1-2.244 2.077H8.084a2.25 2.25 0 0 1-2.244-2.077L4.772 5.79m14.456 0a48.108 48.108 0 0 0-3.478-.397m-12 .562c.34-.059.68-.114 1.022-.165m0 0a48.11 48.11 0 0 1 3.478-.397m7.5 0v-.916c0-1.18-.91-2.164-2.09-2.201a51.964 51.964 0 0 0-3.32 0c-1.18.037-2.09 1.022-2.09 2.201v.916m7.5 0a48.667 48.667 0 0 0-7.5 0" />
                                                </svg>
                                            </button>
                                        <% } else { %>
                                            <button class="inline-flex items-center justify-center w-10 h-10 text-red-300 bg-gray-50 border border-red-200 rounded-lg transition-colors duration-200 shadow-sm cursor-not-allowed opacity-90" disabled>
                                                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-5 h-5">
                                                    <path stroke-linecap="round" stroke-linejoin="round" d="m14.74 9-.346 9m-4.788 0L9.26 9m9.968-3.21c.342.052.682.107 1.022.166m-1.022-.165L18.16 19.673a2.25 2.25 0 0 1-2.244 2.077H8.084a2.25 2.25 0 0 1-2.244-2.077L4.772 5.79m14.456 0a48.108 48.108 0 0 0-3.478-.397m-12 .562c.34-.059.68-.114 1.022-.165m0 0a48.11 48.11 0 0 1 3.478-.397m7.5 0v-.916c0-1.18-.91-2.164-2.09-2.201a51.964 51.964 0 0 0-3.32 0c-1.18.037-2.09 1.022-2.09 2.201v.916m7.5 0a48.667 48.667 0 0 0-7.5 0" />
                                                </svg>
                                            </button>
                                        <% } %>
                                    </div>
                                </td>
                            </tr>
                            <% } 
                            } %>
                        </tbody>
                    </table>
                </div>
            </div>

            <!-- Pagination -->
            <% if (totalPages > 0) { %>
            <!-- Page Info and Records Per Page -->
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
</div>

<!-- Hidden forms for actions -->
<form id="approveForm" action="ApproveBookingServlet" method="post" class="hidden">
    <input type="hidden" name="bookingId" id="approveBookingId">
</form>

<form id="adminCancelForm" action="AdminCancelBookingServlet" method="post" class="hidden">
    <input type="hidden" name="bookingId" id="adminCancelBookingId">
</form>

<form id="deleteForm" action="DeleteBookingServlet" method="post" class="hidden">
    <input type="hidden" name="bookingId" id="deleteBookingId">
</form>

<script>
// Action functions
function approveBooking(bookingId) {
    if (confirm('Are you sure you want to approve this booking?')) {
        document.getElementById('approveBookingId').value = bookingId;
        document.getElementById('approveForm').submit();
    }
}

function adminCancelBooking(bookingId) {
    if (confirm('Are you sure you want to cancel this booking? This will release the seats for other users.')) {
        document.getElementById('adminCancelBookingId').value = bookingId;
        document.getElementById('adminCancelForm').submit();
    }
}

function deleteBooking(bookingId) {
    if (confirm('Are you sure you want to permanently delete this cancelled booking? This action cannot be undone.')) {
        document.getElementById('deleteBookingId').value = bookingId;
        document.getElementById('deleteForm').submit();
    }
}

function viewBookingDetails(bookingId) {
    window.location.href = 'BookingDetails.jsp?id=' + bookingId;
}

function refreshPage() {
    window.location.reload();
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
    const searchInput = document.getElementById('searchInput');
    const statusFilter = document.getElementById('statusFilter');
    
    if (searchInput.value) {
        url += '&search=' + encodeURIComponent(searchInput.value);
    }
    
    if (statusFilter.value) {
        url += '&status=' + encodeURIComponent(statusFilter.value);
    }
    
    // Reset to first page when changing limit
    url += '&page=1';
    
    window.location.href = url;
}

function navigateToPage(page) {
    let url = '?page=' + page;
    
    // Add limit parameter
    const currentLimit = <%= recordsPerPageAttr %>;
    url += '&limit=' + currentLimit;
    
    // Add search parameter if exists
    const searchInput = document.getElementById('searchInput');
    const statusFilter = document.getElementById('statusFilter');
    
    if (searchInput.value) {
        url += '&search=' + encodeURIComponent(searchInput.value);
    }
    
    if (statusFilter.value) {
        url += '&status=' + encodeURIComponent(statusFilter.value);
    }
    
    window.location.href = url;
}

// Search and Filter functionality
const searchInput = document.getElementById('searchInput');
const statusFilter = document.getElementById('statusFilter');

function filterTable() {
    const searchTerm = searchInput.value.toLowerCase();
    const statusValue = statusFilter.value.toLowerCase();
    
    const rows = document.querySelectorAll('#tableBody tr');
    
    rows.forEach(row => {
        if (row.cells.length < 6) return; // Skip empty row
        
        const bookingId = row.cells[0].textContent.toLowerCase();
        const customerInfo = row.cells[1].textContent.toLowerCase();
        const movieTheaterInfo = row.cells[2].textContent.toLowerCase();
        const paymentInfo = row.cells[3].textContent.toLowerCase();
        const statusCell = row.cells[4];
        const status = statusCell.textContent.toLowerCase();
        
        const matchesSearch = bookingId.includes(searchTerm) || 
                             customerInfo.includes(searchTerm) || 
                             movieTheaterInfo.includes(searchTerm) ||
                             paymentInfo.includes(searchTerm);
        
        const matchesStatus = statusValue === '' || status.includes(statusValue);
        
        row.style.display = (matchesSearch && matchesStatus) ? '' : 'none';
    });
}

searchInput.addEventListener('input', filterTable);
statusFilter.addEventListener('change', filterTable);

// Simple sorting function
let currentSort = { field: '', direction: 'asc' };

function sortTable(field) {
    const tbody = document.getElementById('tableBody');
    const rows = Array.from(tbody.querySelectorAll('tr')).filter(row => row.style.display !== 'none');
    
    rows.sort((a, b) => {
        let aValue, bValue;
        
        switch(field) {
            case 'id':
                aValue = parseInt(a.cells[0].querySelector('span').textContent.replace('#', ''));
                bValue = parseInt(b.cells[0].querySelector('span').textContent.replace('#', ''));
                break;
            case 'price':
                aValue = parseFloat(a.cells[3].textContent.replace('MMK ', '')) || 0;
                bValue = parseFloat(b.cells[3].textContent.replace('MMK ', '')) || 0;
                break;
            default:
                return 0;
        }
        
        if (currentSort.field === field && currentSort.direction === 'asc') {
            return aValue - bValue;
        } else {
            return bValue - aValue;
        }
    });
    
    // Toggle sort direction
    if (currentSort.field === field) {
        currentSort.direction = currentSort.direction === 'asc' ? 'desc' : 'asc';
    } else {
        currentSort.field = field;
        currentSort.direction = 'asc';
    }
    
    // Re-append sorted rows
    rows.forEach(row => tbody.appendChild(row));
}

// Initialize on load
document.addEventListener('DOMContentLoaded', function() {
    // Initialize records per page selector
    const recordsSelect = document.getElementById('recordsPerPage');
    if (recordsSelect) {
        recordsSelect.value = '<%= recordsPerPageAttr %>';
    }
    
    // Set initial values for search and filter from URL parameters if they exist
    const urlParams = new URLSearchParams(window.location.search);
    const searchParam = urlParams.get('search');
    const statusParam = urlParams.get('status');
    
    if (searchParam) {
        searchInput.value = searchParam;
    }
    
    if (statusParam) {
        statusFilter.value = statusParam;
    }
    
    // Apply initial filter if parameters exist
    if (searchParam || statusParam) {
        filterTable();
    }
});
</script>