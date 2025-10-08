<%@page import="com.demo.model.Movies"%>
<%@page import="com.demo.dao.MoviesDao"%>
<%@page import="com.demo.dao.TheaterDAO"%>
<%@page import="com.demo.dao.ShowtimesDao"%>
<%@page import="com.demo.dao.UserDAO"%>
<%@page import="com.demo.dao.BookingDao"%>
<
<%@page import="com.demo.model.Booking"%>
<%@page import="com.demo.model.User"%>
<%@page import="com.demo.model.Theater"%>

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

    Booking booking = null;
    User bookingUser = null;
    String showtimeInfo = "";
    Theater theater = null;
    Movies movie = null;

    try {
        booking = bookingDao.getBookingById(bookingId);
        if (booking != null) {
            bookingUser = userDao.getUserById(booking.getUserId());
            showtimeInfo = showtimeDao.getShowtimeById(booking.getShowtimeId());
            
            // Get theater and movie info directly from showtime if needed
            // You might need to modify your ShowtimeDao to return Theater and Movie objects
            // For now, we'll just display the showtime info string
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
%>

<jsp:include page="layout/JSPHeader.jsp"/>
<div class="flex">
    <jsp:include page="layout/sidebar.jsp" />
    <div class="flex-1 sm:ml-64">
        <jsp:include page="layout/AdminHeader.jsp" />
        <div class="p-8 max-w-4xl mx-auto">
            
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

            <!-- Booking Information Card -->
            <div class="bg-white shadow rounded-lg border border-gray-200 overflow-hidden mb-6">
                <div class="px-6 py-4 border-b border-gray-200 bg-red-50">
                    <h2 class="text-lg font-semibold text-red-800">Booking Information</h2>
                </div>
                <div class="p-6">
                    <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                        <div>
                            <h3 class="text-sm font-medium text-gray-500 mb-2">Booking ID</h3>
                            <p class="text-lg font-semibold text-gray-900">#<%= booking.getBookingId() %></p>
                        </div>
                        <div>
                            <h3 class="text-sm font-medium text-gray-500 mb-2">Booking Date & Time</h3>
                            <p class="text-lg font-semibold text-gray-900">
                                <%= booking.getBookingTime() != null ? dateFormat.format(booking.getBookingTime()) + " at " + timeFormat.format(booking.getBookingTime()) : "N/A" %>
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

            <!-- User Information Card -->
            <div class="bg-white shadow rounded-lg border border-gray-200 overflow-hidden mb-6">
                <div class="px-6 py-4 border-b border-gray-200 bg-red-50">
                    <h2 class="text-lg font-semibold text-red-800">Customer Information</h2>
                </div>
                <div class="p-6">
                    <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
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

            <!-- Showtime Information Card -->
            <div class="bg-white shadow rounded-lg border border-gray-200 overflow-hidden mb-6">
                <div class="px-6 py-4 border-b border-gray-200 bg-red-50">
                    <h2 class="text-lg font-semibold text-red-800">Show Information</h2>
                </div>
                <div class="p-6">
                    <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                        <div>
                            <h3 class="text-sm font-medium text-gray-500 mb-2">Showtime ID</h3>
                            <p class="text-lg font-semibold text-gray-900">#<%= booking.getShowtimeId() %></p>
                        </div>
                        <div>
                            <h3 class="text-sm font-medium text-gray-500 mb-2">Show Time</h3>
                            <p class="text-lg font-semibold text-gray-900">
                                <%= !showtimeInfo.isEmpty() ? showtimeInfo : "Time information not available" %>
                            </p>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Seats Information Card -->
            <div class="bg-white shadow rounded-lg border border-gray-200 overflow-hidden">
                <div class="px-6 py-4 border-b border-gray-200 bg-red-50">
                    <h2 class="text-lg font-semibold text-red-800">Seat Information</h2>
                </div>
                <div class="p-6">
                    <% if (booking.getSelectedSeatIds() != null && !booking.getSelectedSeatIds().isEmpty()) { %>
                        <div class="mb-4">
                            <h3 class="text-sm font-medium text-gray-500 mb-2">Total Seats</h3>
                            <p class="text-lg font-semibold text-gray-900"><%= booking.getSelectedSeatIds().size() %> seats</p>
                        </div>
                        <div>
                            <h3 class="text-sm font-medium text-gray-500 mb-2">Seat IDs</h3>
                            <div class="flex flex-wrap gap-2">
                                <% for (Integer seatId : booking.getSelectedSeatIds()) { %>
                                    <span class="inline-flex items-center px-3 py-1 rounded-full text-sm font-medium bg-blue-100 text-blue-800 border border-blue-200">
                                        Seat #<%= seatId %>
                                    </span>
                                <% } %>
                            </div>
                        </div>
                    <% } else { %>
                        <p class="text-gray-500 text-center py-4">No seat information available</p>
                    <% } %>
                </div>
            </div>

            <!-- Action Buttons (Only for admins) -->
            <% if ("admin".equals(currentUser.getRole()) || "theater_admin".equals(currentUser.getRole())) { %>
            <div class="flex justify-end space-x-4 mt-6">
                <% if ("pending".equals(booking.getStatus())) { %>
                    <button onclick="approveBooking(<%= booking.getBookingId() %>)" 
                            class="bg-green-600 text-white px-6 py-2 rounded-lg hover:bg-green-700 transition font-medium">
                        Approve Booking
                    </button>
                <% } %>
                
                <% if ("confirmed".equals(booking.getStatus())) { %>
                    <button onclick="adminCancelBooking(<%= booking.getBookingId() %>)" 
                            class="bg-red-600 text-white px-6 py-2 rounded-lg hover:bg-red-700 transition font-medium">
                        Cancel Booking
                    </button>
                <% } %>
                
                <% if ("cancelled".equals(booking.getStatus())) { %>
                    <button onclick="deleteBooking(<%= booking.getBookingId() %>)" 
                            class="bg-gray-600 text-white px-6 py-2 rounded-lg hover:bg-gray-700 transition font-medium">
                        Delete Booking
                    </button>
                <% } %>
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

<jsp:include page="layout/footer.jsp"/>
<jsp:include page="layout/JSPFooter.jsp"/>