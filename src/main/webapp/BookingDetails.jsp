<%@page import="com.demo.model.Movies"%>
<%@page import="com.demo.dao.MoviesDao"%>
<%@page import="com.demo.dao.TheaterDAO"%>
<%@page import="com.demo.dao.ShowtimesDao"%>
<%@page import="com.demo.dao.UserDAO"%>
<%@page import="com.demo.dao.BookingDao"%>
<%@page import="com.demo.dao.SeatsDao"%>
<%@page import="com.demo.model.Booking"%>
<%@page import="com.demo.model.User"%>
<%@page import="com.demo.model.Theater"%>
<%@page import="com.demo.model.Showtime"%>
<%@page import="com.demo.model.Seat"%>
<%@page import="java.util.List"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    // Check if user is logged in
    User currentUser = (User) session.getAttribute("user");
    if (currentUser == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    // Get booking ID from request
    String bookingIdParam = request.getParameter("id");
    if (bookingIdParam == null || bookingIdParam.isEmpty()) {
        if ("admin".equals(currentUser.getRole()) || "theater_admin".equals(currentUser.getRole())) {
            response.sendRedirect("adminBookings.jsp?error=Booking ID is required");
        } else {
            response.sendRedirect("myBookings.jsp?error=Booking ID is required");
        }
        return;
    }

    int bookingId = Integer.parseInt(bookingIdParam);
    BookingDao bookingDao = new BookingDao();
    UserDAO userDao = new UserDAO();
    ShowtimesDao showtimeDao = new ShowtimesDao();
    TheaterDAO theaterDao = new TheaterDAO();
    MoviesDao movieDao = new MoviesDao();
    SeatsDao seatsDao = new SeatsDao();

    Booking booking = null;
    User bookingUser = null;
    Showtime showtime = null;
    Theater theater = null;
    Movies movie = null;
    List<Seat> bookedSeats = null;
    double totalPrice = 0.0;

    try {
        booking = bookingDao.getBookingById(bookingId);
        if (booking != null) {
            bookingUser = userDao.getUserById(booking.getUserId());
            showtime = showtimeDao.getShowtimeDetails(booking.getShowtimeId());
            
            if (showtime != null) {
                theater = theaterDao.getTheaterById(showtime.getTheaterId());
                movie = movieDao.getMovieById(showtime.getMovieId());
            }
            
            // Get detailed seat information
            if (booking.getSelectedSeatIds() != null && !booking.getSelectedSeatIds().isEmpty()) {
                bookedSeats = seatsDao.getSeatsByShowtimeSeatIds(booking.getSelectedSeatIds());
                
                // Calculate total price from seat prices
                for (Seat seat : bookedSeats) {
                    if (seat.getPrice() != null) {
                        totalPrice += seat.getPrice().doubleValue();
                    }
                }
            }
        }
    } catch (Exception e) {
        e.printStackTrace();
        if ("admin".equals(currentUser.getRole()) || "theater_admin".equals(currentUser.getRole())) {
            response.sendRedirect("adminBookings.jsp?error=Error loading booking details");
        } else {
            response.sendRedirect("myBookings.jsp?error=Error loading booking details");
        }
        return;
    }

    if (booking == null) {
        if ("admin".equals(currentUser.getRole()) || "theater_admin".equals(currentUser.getRole())) {
            response.sendRedirect("adminBookings.jsp?error=Booking not found");
        } else {
            response.sendRedirect("myBookings.jsp?error=Booking not found");
        }
        return;
    }

    SimpleDateFormat dateFormat = new SimpleDateFormat("MMM dd, yyyy");
    SimpleDateFormat timeFormat = new SimpleDateFormat("HH:mm");
    SimpleDateFormat dateTimeFormat = new SimpleDateFormat("MMM dd, yyyy 'at' HH:mm");
%>

<jsp:include page="layout/JSPHeader.jsp"/>
<div class="flex">
    <jsp:include page="layout/sidebar.jsp" />
    <div class="flex-1 sm:ml-64">
        <jsp:include page="layout/AdminHeader.jsp" />
        <div class="p-8 max-w-8xl mx-auto ">
            
            <!-- Header Section -->
            <div class="flex justify-between items-center mb-6">
                <div>
                    <h1 class="text-2xl font-bold text-gray-900">Booking Details</h1>
                    <p class="text-gray-600 mt-1">Detailed information for booking #<%= booking.getBookingId() %></p>
                </div>
                <button onclick="window.history.back()" 
                        class="bg-red-600 text-white px-4 py-2 rounded-lg hover:bg-red-700 transition text-sm font-medium">
                    Back to Bookings
                </button>
            </div>

            <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
                <!-- Left Column -->
                <div class="space-y-6">
                    <!-- Booking Information Card -->
                    <div class="bg-white shadow rounded-lg border border-gray-200 overflow-hidden">
                        <div class="px-6 py-4 border-b border-gray-200 bg-red-50">
                            <h2 class="text-lg font-semibold text-red-800">Booking Information</h2>
                        </div>
                        <div class="p-6">
                            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                                <div>
                                    <h3 class="text-sm font-medium text-gray-500 mb-2">Booking ID</h3>
                                    <p class="text-lg font-semibold text-gray-900">#<%= booking.getBookingId() %></p>
                                </div>
                                <div>
                                    <h3 class="text-sm font-medium text-gray-500 mb-2">Booking Date & Time</h3>
                                    <p class="text-lg font-semibold text-gray-900">
                                        <%= booking.getBookingTime() != null ? dateTimeFormat.format(booking.getBookingTime()) : "N/A" %>
                                    </p>
                                </div>
                                <div>
                                    <h3 class="text-sm font-medium text-gray-500 mb-2">Status</h3>
                                    <%
                                        String statusClass = "";
                                        String statusText = "";
                                        if (booking.getStatus() != null) {
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
                                        } else {
                                            statusClass = "bg-gray-100 text-gray-800 border-gray-200";
                                            statusText = "Unknown";
                                        }
                                    %>
                                    <span class="inline-flex items-center px-3 py-1 rounded-full text-sm font-medium border <%= statusClass %>">
                                        <%= statusText %>
                                    </span>
                                </div>
                                <div>
                                    <h3 class="text-sm font-medium text-gray-500 mb-2">Payment Method</h3>
                                    <p class="text-lg font-semibold text-gray-900 capitalize">
                                        <%= booking.getPaymentMethod() != null ? booking.getPaymentMethod() : "Unknown" %>
                                    </p>
                                </div>
                                <div>
                                    <h3 class="text-sm font-medium text-gray-500 mb-2">Total Amount</h3>
                                    <p class="text-lg font-semibold text-red-600">
                                        <%= booking.getTotalPrice() != null ? "MMK " + booking.getTotalPrice() : "N/A" %>
                                    </p>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Show Information Card -->
                    <div class="bg-white shadow rounded-lg border border-gray-200 overflow-hidden">
                        <div class="px-6 py-4 border-b border-gray-200 bg-red-50">
                            <h2 class="text-lg font-semibold text-red-800">Show Information</h2>
                        </div>
                        <div class="p-6">
                            <div class="space-y-4">
                                <% if (movie != null) { %>
    <div class="flex items-center space-x-4">
        <img src="GetMoviesPosterServlet?movie_id=<%= movie.getMovie_id() %>" 
             alt="<%= movie.getTitle() %>" 
             class="w-16 h-24 object-cover rounded-lg">
        <div>
            <h3 class="text-lg font-semibold text-gray-900"><%= movie.getTitle() %></h3>
            <% if (movie.getGenres() != null) { %>
                <p class="text-sm text-gray-600"><%= movie.getGenres() %></p>
            <% } %>
            <% if (movie.getDuration() != null && !movie.getDuration().isEmpty()) { %>
                <p class="text-sm text-gray-600"><%= movie.getDuration() %> minutes</p>
            <% } %>
            <% if (movie.getDirector() != null) { %>
                <p class="text-sm text-gray-500">Director: <%= movie.getDirector() %></p>
            <% } %>
        </div>
    </div>
<% } %>
                                <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                                    <% if (theater != null) { %>
                                        <div>
                                            <h3 class="text-sm font-medium text-gray-500 mb-2">Theater</h3>
                                            <p class="text-lg font-semibold text-gray-900"><%= theater.getName() %></p>
                                            <p class="text-sm text-gray-600"><%= theater.getLocation() %></p>
                                        </div>
                                    <% } %>

                                    <% if (showtime != null) { %>
                                        <div>
                                            <h3 class="text-sm font-medium text-gray-500 mb-2">Show Date</h3>
                                            <p class="text-lg font-semibold text-gray-900">
                                                <%= showtime.getShowDate() != null ? dateFormat.format(showtime.getShowDate()) : "N/A" %>
                                            </p>
                                        </div>
                                        <div>
                                            <h3 class="text-sm font-medium text-gray-500 mb-2">Show Time</h3>
                                            <p class="text-lg font-semibold text-gray-900">
                                                <%= showtime.getStartTime() != null ? showtime.getStartTime() + " - " + showtime.getEndTime() : "N/A" %>
                                            </p>
                                        </div>
                                    <% } %>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Right Column -->
                <div class="space-y-6">
                    <!-- Customer Information Card -->
                    <div class="bg-white shadow rounded-lg border border-gray-200 overflow-hidden">
                        <div class="px-6 py-4 border-b border-gray-200 bg-red-50">
                            <h2 class="text-lg font-semibold text-red-800">Customer Information</h2>
                        </div>
                        <div class="p-6">
                            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                                <div>
                                    <h3 class="text-sm font-medium text-gray-500 mb-2">User ID</h3>
                                    <p class="text-lg font-semibold text-gray-900">#<%= booking.getUserId() %></p>
                                </div>
                                <div>
                                    <h3 class="text-sm font-medium text-gray-500 mb-2">Name</h3>
                                    <p class="text-lg font-semibold text-gray-900">
                                        <%= bookingUser != null ? bookingUser.getName() : "Unknown User" %>
                                    </p>
                                </div>
                                <div>
                                    <h3 class="text-sm font-medium text-gray-500 mb-2">Email</h3>
                                    <p class="text-lg font-semibold text-gray-900">
                                        <%= bookingUser != null ? bookingUser.getEmail() : "N/A" %>
                                    </p>
                                </div>
                                <div>
                                    <h3 class="text-sm font-medium text-gray-500 mb-2">Phone</h3>
                                    <p class="text-lg font-semibold text-gray-900">
                                        <%= bookingUser != null && bookingUser.getPhone() != null ? bookingUser.getPhone() : "N/A" %>
                                    </p>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Seat Information Card -->
                    <div class="bg-white shadow rounded-lg border border-gray-200 overflow-hidden">
                        <div class="px-6 py-4 border-b border-gray-200 bg-red-50">
                            <h2 class="text-lg font-semibold text-red-800">Seat Information</h2>
                        </div>
                        <div class="p-6">
                            <% if (bookedSeats != null && !bookedSeats.isEmpty()) { %>
                                <div class="mb-4">
                                    <h3 class="text-sm font-medium text-gray-500 mb-2">Total Seats</h3>
                                    <p class="text-lg font-semibold text-gray-900"><%= bookedSeats.size() %> seats</p>
                                </div>
                                
                                <div class="mb-4">
                                    <h3 class="text-sm font-medium text-gray-500 mb-2">Seat Details</h3>
                                    <div class="grid grid-cols-2 md:grid-cols-3 gap-3">
                                        <% 
                                        double calculatedTotal = 0;
                                        for (Seat seat : bookedSeats) { 
                                            calculatedTotal += seat.getPrice() != null ? seat.getPrice().doubleValue() : 0;
                                        %>
                                            <div class="bg-gray-50 rounded-lg p-3 border border-gray-200">
                                                <div class="flex justify-between items-start">
                                                    <div>
                                                        <p class="font-semibold text-gray-900"><%= seat.getSeatNumber() %></p>
                                                        <p class="text-sm text-gray-600 capitalize"><%= seat.getSeatType() != null ? seat.getSeatType() : "Standard" %></p>
                                                    </div>
                                                    <p class="text-sm font-medium text-green-600">
                                                        <%= seat.getPrice() != null ? "MMK " + seat.getPrice() : "N/A" %>
                                                    </p>
                                                </div>
                                            </div>
                                        <% } %>
                                    </div>
                                </div>
                                
                                <div class="border-t pt-4">
                                    <div class="flex justify-between items-center">
                                        <span class="text-sm font-medium text-gray-500">Subtotal:</span>
                                        <span class="text-sm font-semibold text-gray-900">MMK <%= String.format("%.2f", calculatedTotal) %></span>
                                    </div>
                                    <div class="flex justify-between items-center mt-2">
                                        <span class="text-lg font-bold text-gray-900">Total Paid:</span>
                                        <span class="text-lg font-bold text-red-600">MMK <%= booking.getTotalPrice() != null ? booking.getTotalPrice() : String.format("%.2f", calculatedTotal) %></span>
                                    </div>
                                </div>
                            <% } else { %>
                                <p class="text-gray-500 text-center py-4">No seat information available</p>
                            <% } %>
                        </div>
                    </div>
                    
                    <div class="flex justify-center space-x-3">
                                    <!-- Approve Button -->
                                    <% if ("pending".equals(booking.getStatus())) { %>
                                        <button onclick="approveBooking(<%= booking.getBookingId() %>)" 
                                                class="inline-flex items-center justify-center w-10 h-10 text-green-600 bg-white border border-green-300 rounded-lg hover:bg-green-50 hover:border-green-400 transition-colors duration-200 shadow-sm cursor-pointer"
                                                title="Approve Booking">
                                            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-5 h-5">
                                                <path stroke-linecap="round" stroke-linejoin="round" d="m4.5 12.75 6 6 9-13.5" />
                                            </svg>
                                        </button>
                                    <% } else { %>
                                        <button class="inline-flex items-center justify-center w-10 h-10 text-gray-300 bg-gray-50 border border-gray-200 rounded-lg transition-colors duration-200 shadow-sm cursor-not-allowed opacity-90"
                                                title="Approve Booking" disabled>
                                            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-5 h-5">
                                                <path stroke-linecap="round" stroke-linejoin="round" d="m4.5 12.75 6 6 9-13.5" />
                                            </svg>
                                        </button>
                                    <% } %>

                                    <!-- Cancel Button -->
                                    <% if ("pending".equals(booking.getStatus()) || "confirmed".equals(booking.getStatus())) { %>
                                        <button onclick="adminCancelBooking(<%= booking.getBookingId() %>)" 
                                                class="inline-flex items-center justify-center w-10 h-10 text-red-600 bg-white border border-red-300 rounded-lg hover:bg-red-50 hover:border-red-400 transition-colors duration-200 shadow-sm cursor-pointer"
                                                title="Cancel Booking">
                                            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-5 h-5">
                                                <path stroke-linecap="round" stroke-linejoin="round" d="M6 18 18 6M6 6l12 12" />
                                            </svg>
                                        </button>
                                    <% } else { %>
                                        <button class="inline-flex items-center justify-center w-10 h-10 text-red-300 bg-gray-50 border border-red-200 rounded-lg transition-colors duration-200 shadow-sm cursor-not-allowed opacity-90"
                                                title="Cancel Booking" disabled>
                                            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-5 h-5">
                                                <path stroke-linecap="round" stroke-linejoin="round" d="M6 18 18 6M6 6l12 12" />
                                            </svg>
                                        </button>
                                    <% } %>

                                    <!-- Delete Button -->
                                    <% if ("cancelled".equals(booking.getStatus())) { %>
                                        <button onclick="deleteBooking(<%= booking.getBookingId() %>)" 
                                                class="inline-flex items-center justify-center w-10 h-10 text-red-600 bg-white border border-red-300 rounded-lg hover:bg-red-50 hover:border-red-400 transition-colors duration-200 shadow-sm cursor-pointer"
                                                title="Delete Booking">
                                            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-5 h-5">
                                                <path stroke-linecap="round" stroke-linejoin="round" d="m14.74 9-.346 9m-4.788 0L9.26 9m9.968-3.21c.342.052.682.107 1.022.166m-1.022-.165L18.16 19.673a2.25 2.25 0 0 1-2.244 2.077H8.084a2.25 2.25 0 0 1-2.244-2.077L4.772 5.79m14.456 0a48.108 48.108 0 0 0-3.478-.397m-12 .562c.34-.059.68-.114 1.022-.165m0 0a48.11 48.11 0 0 1 3.478-.397m7.5 0v-.916c0-1.18-.91-2.164-2.09-2.201a51.964 51.964 0 0 0-3.32 0c-1.18.037-2.09 1.022-2.09 2.201v.916m7.5 0a48.667 48.667 0 0 0-7.5 0" />
                                            </svg>
                                        </button>
                                    <% } else { %>
                                        <button class="inline-flex items-center justify-center w-10 h-10 text-red-300 bg-gray-50 border border-red-200 rounded-lg transition-colors duration-200 shadow-sm cursor-not-allowed opacity-90"
                                                title="Delete Booking" disabled>
                                            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-5 h-5">
                                                <path stroke-linecap="round" stroke-linejoin="round" d="m14.74 9-.346 9m-4.788 0L9.26 9m9.968-3.21c.342.052.682.107 1.022.166m-1.022-.165L18.16 19.673a2.25 2.25 0 0 1-2.244 2.077H8.084a2.25 2.25 0 0 1-2.244-2.077L4.772 5.79m14.456 0a48.108 48.108 0 0 0-3.478-.397m-12 .562c.34-.059.68-.114 1.022-.165m0 0a48.11 48.11 0 0 1 3.478-.397m7.5 0v-.916c0-1.18-.91-2.164-2.09-2.201a51.964 51.964 0 0 0-3.32 0c-1.18.037-2.09 1.022-2.09 2.201v.916m7.5 0a48.667 48.667 0 0 0-7.5 0" />
                                            </svg>
                                        </button>
                                    <% } %>
                                </div>

                   
                </div>
            </div>
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
</script>

<jsp:include page="layout/JSPFooter.jsp"/>