<%@page import="com.demo.dao.SeatsDao"%>
<%@ page import="com.demo.dao.MoviesDao" %>
<%@ page import="com.demo.dao.TheaterDAO" %>
<%@ page import="com.demo.dao.ShowtimesDao" %>
<%@ page import="com.demo.dao.BookingDao"%>
<%@ page import="com.demo.model.Movies" %>
<%@ page import="com.demo.model.Theater" %>
<%@ page import="com.demo.model.User" %>
<%@ page import="com.demo.model.Booking" %>
<%@ page import="com.demo.model.Showtime" %>
<%@ page import="com.demo.model.Seat" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.List" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    Integer bookingId = request.getParameter("bookingId") != null
            ? Integer.parseInt(request.getParameter("bookingId"))
            : null;
    if (bookingId == null) {
        out.println("<h2 style='text-align:center;color:red;margin-top:50px;'>Booking ID not provided!</h2>");
        return;
    }

    BookingDao bookingDao = new BookingDao();
    Booking booking = bookingDao.getBookingById(bookingId);
    if (booking == null) {
        out.println("<h2 style='text-align:center;color:red;margin-top:50px;'>Booking not found!</h2>");
        return;
    }

    SeatsDao seatDao = new SeatsDao();
    List<Seat> seats = seatDao.getSeatsByShowtimeSeatIds(booking.getSelectedSeatIds());

    System.out.println("DEBUG: booking.getSelectedSeatIds() = " + booking.getSelectedSeatIds());
    System.out.println("DEBUG: seats found = " + (seats != null ? seats.size() : 0));
    
    if (seats != null && !seats.isEmpty()) {
        for (Seat seat : seats) {
            System.out.println("DEBUG: Seat - Number: " + seat.getSeatNumber() + ", Type: " + seat.getSeatType());
        }
    }

    ShowtimesDao showDao = new ShowtimesDao();
    Showtime showtime = showDao.getShowtimeDetails(booking.getShowtimeId());

    MoviesDao moviesDao = new MoviesDao();
    Movies movie = showtime != null ? moviesDao.getMovieById(showtime.getMovieId()) : null;

    TheaterDAO theaterDao = new TheaterDAO();
    Theater theater = showtime != null ? theaterDao.getTheaterById(showtime.getTheaterId()) : null;

    SimpleDateFormat dateFormat = new SimpleDateFormat("EEEE, MMMM d, yyyy");
    SimpleDateFormat timeFormat = new SimpleDateFormat("h:mm a");
    SimpleDateFormat dateTimeFormat = new SimpleDateFormat("MMM dd, yyyy 'at' h:mm a");

    String status = booking.getStatus();
    String statusColor = "text-yellow-600";
    if ("confirmed".equalsIgnoreCase(status)) statusColor = "text-green-600";
    else if ("cancelled".equalsIgnoreCase(status)) statusColor = "text-red-600";
    
    StringBuilder seatNumbersStr = new StringBuilder();
    int totalSeats = 0;
    if (seats != null && !seats.isEmpty()) {
        totalSeats = seats.size();
        for (int i = 0; i < seats.size(); i++) {
            if (i > 0) seatNumbersStr.append(", ");
            seatNumbersStr.append(seats.get(i).getSeatNumber());
        }
    }
%>

<jsp:include page="layout/JSPHeader.jsp"/>
<jsp:include page="layout/header.jsp"/>

<div class="min-h-screen bg-gradient-to-br from-red-50 to-rose-50 py-8">
    <div class="container mx-auto px-4 max-w-6xl">
    
        

        <!-- Header -->
        <div class="text-center mb-8">
            <h1 class="text-4xl font-bold text-gray-900 mb-3">Booking Confirmed!</h1>
            <p class="text-lg text-gray-700">Your movie ticket has been successfully booked</p>
        </div>

        <!-- Main Content Grid -->
        <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
            <!-- Left Column - Booking Details -->
            <div class="lg:col-span-2 space-y-6">
            <div class="grid grid-cols-2 gap-6">
            <!-- Booking Details -->
                <div class="bg-white rounded-2xl border-2 border-red-100 p-6">
                    <h3 class="text-xl font-bold text-gray-900 mb-4 flex items-center">
                        <svg class="w-5 h-5 text-red-600 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2"></path>
                        </svg>
                        Booking Details
                    </h3>
                    <div class="space-y-4">
                        <div class="p-3 bg-red-50 rounded-lg border border-red-100">
                            <label class="block text-sm font-medium text-gray-600 mb-1">Booking ID</label>
                            <p class="font-semibold text-gray-900">#<%= booking.getBookingId() %></p>
                        </div>
                        <div class="p-3 bg-red-50 rounded-lg border border-red-100">
                            <label class="block text-sm font-medium text-gray-600 mb-1">Booking Date & Time</label>
                            <p class="font-semibold text-gray-900">
                                <%= booking.getBookingTime() != null ? dateTimeFormat.format(booking.getBookingTime()) : "N/A" %>
                            </p>
                        </div>
                        <div class="p-3 bg-red-50 rounded-lg border border-red-100">
                            <label class="block text-sm font-medium text-gray-600 mb-1">Booking Status</label>
                            <p class="font-semibold <%= statusColor %>">
                                <%= status != null ? status.substring(0,1).toUpperCase() + status.substring(1) : "Unknown" %>
                            </p>
                        </div>
                    </div>
                </div>
            <!-- Payment Information -->
                <div class="bg-white rounded-2xl border-2 border-red-100 p-6">
                    <h3 class="text-xl font-bold text-gray-900 mb-4 flex items-center">
                        <svg class="w-5 h-5 text-red-600 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1"></path>
                        </svg>
                        Payment Information
                    </h3>
                    <div class="space-y-4">
                        <div class="p-3 bg-red-50 rounded-lg border border-red-100">
                            <label class="block text-sm font-medium text-gray-600 mb-1">Payment Method</label>
                            <p class="font-semibold text-gray-900">
                                <%
                                    String paymentMethod = booking.getPaymentMethod();
                                    if (paymentMethod != null) {
                                        if ("kbzpay".equals(paymentMethod)) {
                                            out.print("KBZ Pay");
                                        } else if ("wavepay".equals(paymentMethod)) {
                                            out.print("Wave Pay");
                                        } else {
                                            out.print("Cash");
                                        }
                                    } else {
                                        out.print("Cash");
                                    }
                                %>
                            </p>
                        </div>
                        <div class="p-3 bg-red-50 rounded-lg border border-red-100">
    <label class="block text-sm font-medium text-gray-600 mb-1">Payment Status</label>
    <p class="font-semibold 
        <% 
        if ("cash".equalsIgnoreCase(paymentMethod)) { 
            out.print("text-yellow-600");
        } else { 
            out.print("text-green-600");
        } 
        %>">
        <%
        if ("cash".equalsIgnoreCase(paymentMethod)) {
            out.print("Pending");
        } else {
            out.print("Paid");
        }
        %>
    </p>
</div>
                        <div class="p-4 bg-gradient-to-r from-red-600 to-rose-700 rounded-lg border-2 border-red-500">
                            <label class="block text-sm font-medium text-red-900 mb-1">Total Amount</label>
                            <p class="font-bold text-red-700 text-2xl"><%= booking.getTotalPrice() != null ? booking.getTotalPrice() : "0" %> MMK</p>
                        </div>
                    </div>
                </div>
                
                
            </div>
                <!-- Movie & Showtime Card -->
                <div class="bg-white rounded-2xl border-2 border-red-100">
                    <div class="bg-gradient-to-r from-red-600 to-rose-700 px-6 py-4">
                        <h2 class="text-2xl font-bold text-white">Showtime Details</h2>
                    </div>
                    <div class="p-6">
                        <div class="mb-6 p-6 bg-white rounded-xl border-2 border-red-100">
                            <h3 class="text-xl font-bold text-gray-900 mb-4 flex items-center">
                                <svg class="w-5 h-5 text-red-600 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2"></path>
                                </svg>
                                Booking Summary
                            </h3>
                            <div class="overflow-hidden rounded-lg border border-gray-200">
                                <table class="min-w-full divide-y divide-gray-200">
                                    <tbody class="divide-y divide-gray-200 bg-white">
                                        <tr class="hover:bg-red-50 transition-colors">
                                            <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-600 bg-gray-50 w-1/3">
                                                <div class="flex items-center">
                                                    <svg class="w-4 h-4 mr-2 text-red-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 10l4.553-2.276A1 1 0 0121 8.618v6.764a1 1 0 01-1.447.894L15 14M5 18h8a2 2 0 002-2V8a2 2 0 00-2-2H5a2 2 0 00-2 2v8a2 2 0 002 2z"></path>
                                                    </svg>
                                                    Movie
                                                </div>
                                            </td>
                                            <td class="px-6 py-4 whitespace-nowrap text-sm font-semibold text-gray-900">
                                                <%= movie != null ? movie.getTitle() : "Unknown Movie" %>
                                            </td>
                                        </tr>
                                        <tr class="hover:bg-red-50 transition-colors">
                                            <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-600 bg-gray-50">
                                                <div class="flex items-center">
                                                    <svg class="w-4 h-4 mr-2 text-red-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 8v-4m0 4h4"></path>
                                                    </svg>
                                                    Theater
                                                </div>
                                            </td>
                                            <td class="px-6 py-4 whitespace-nowrap text-sm font-semibold text-gray-900">
                                                <%= theater != null ? theater.getName() : "Unknown Theater" %>
                                            </td>
                                        </tr>
                                        <tr class="hover:bg-red-50 transition-colors">
                                            <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-600 bg-gray-50">
                                                <div class="flex items-center">
                                                    <svg class="w-4 h-4 mr-2 text-red-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z"></path>
                                                    </svg>
                                                    Date
                                                </div>
                                            </td>
                                            <td class="px-6 py-4 whitespace-nowrap text-sm font-semibold text-gray-900">
                                                <%= showtime != null ? dateFormat.format(showtime.getShowDate()) : "-" %>
                                            </td>
                                        </tr>
                                        <tr class="hover:bg-red-50 transition-colors">
                                            <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-600 bg-gray-50">
                                                <div class="flex items-center">
                                                    <svg class="w-4 h-4 mr-2 text-red-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"></path>
                                                    </svg>
                                                    Time
                                                </div>
                                            </td>
                                            <td class="px-6 py-4 whitespace-nowrap text-sm font-semibold text-gray-900">
                                                <%= showtime != null ? showtime.getStartTime() + " - " + showtime.getEndTime() : "-" %>
                                            </td>
                                        </tr>
                                    </tbody>
                                </table>
                            </div>
                        </div>

                        <!-- Seats Information -->
                        <div class="bg-white rounded-xl border-2 border-red-100 p-6">
                            <h3 class="text-xl font-bold text-gray-900 mb-4 flex items-center">
                                <svg class="w-5 h-5 text-red-600 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"></path>
                                </svg>
                                Seats Information
                            </h3>
                            
                            <div class="grid grid-cols-2 gap-4 text-sm">
                                <div class="p-3 bg-red-50 rounded-lg border border-red-100">
                                    <span class="text-gray-600 font-medium">Total Seats:</span>
                                    <span class="font-semibold text-gray-900 block mt-1">
                                        <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-red-100 text-red-800">
                                            <%= totalSeats %> seats
                                        </span>
                                    </span>
                                </div>
                                <div class="p-3 bg-red-50 rounded-lg border border-red-100">
                                    <span class="text-gray-600 font-medium">Seat Numbers:</span>
                                    <span class="font-semibold text-gray-900 block mt-1">
                                        <%= seatNumbersStr.length() > 0 ? seatNumbersStr.toString() : "N/A" %>
                                    </span>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Right Column - User & Payment Info -->
            <div class="space-y-6">
                <!-- User Information -->
                <div class="bg-white rounded-2xl border-2 border-red-100 p-6">
                    <h3 class="text-xl font-bold text-gray-900 mb-4 flex items-center">
                        <svg class="w-5 h-5 text-red-600 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"></path>
                        </svg>
                        Customer Information
                    </h3>
                    <div class="space-y-4">
                        <div class="p-3 bg-red-50 rounded-lg border border-red-100">
                            <label class="block text-sm font-medium text-gray-600 mb-1">Full Name</label>
                            <p class="font-semibold text-gray-900"><%= user.getName() %></p>
                        </div>
                        <div class="p-3 bg-red-50 rounded-lg border border-red-100">
                            <label class="block text-sm font-medium text-gray-600 mb-1">Email</label>
                            <p class="font-semibold text-gray-900"><%= user.getEmail() %></p>
                        </div>
                        <div class="p-3 bg-red-50 rounded-lg border border-red-100">
                            <label class="block text-sm font-medium text-gray-600 mb-1">Phone</label>
                            <p class="font-semibold text-gray-900"><%= user.getPhone() %></p>
                        </div>
                    </div>
                </div>

                

              

                <!-- Quick Scan Code -->
                <div class="bg-white rounded-2xl border-2 border-red-100 p-6 text-center">
                    <h3 class="text-xl font-bold text-gray-900 mb-4 flex items-center justify-center">
                        <svg class="w-5 h-5 text-red-600 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v1m6 11h2m-6 0h-2v4m0-11v3m0 0h.01M12 12h4.01M16 20h4M4 12h4m12 0h.01M5 8h2a1 1 0 001-1V5a1 1 0 00-1-1H5a1 1 0 00-1 1v2a1 1 0 001 1zm12 0h2a1 1 0 001-1V5a1 1 0 00-1-1h-2a1 1 0 00-1 1v2a1 1 0 001 1zM5 20h2a1 1 0 001-1v-2a1 1 0 00-1-1H5a1 1 0 00-1 1v2a1 1 0 001 1z"></path>
                        </svg>
                        Quick Scan Code
                    </h3>
                   <div class="w-40 h-40 bg-white rounded-2xl mx-auto flex items-center justify-center border-2 border-red-200 mb-3">
    <img id="qrImage" 
         src="https://api.qrserver.com/v1/create-qr-code/?size=140x140&data=<%= java.net.URLEncoder.encode(request.getRequestURL() + "?" + request.getQueryString(), "UTF-8") %>" 
         alt="QR Code" 
         class="w-full h-full p-2"
         onerror="this.style.display='none'; document.getElementById('qrFallback').style.display='flex';">
    <div id="qrFallback" class="hidden items-center justify-center w-full h-full">
        <span class="text-sm text-gray-700 text-center font-semibold">Booking<br>#<%= booking.getBookingId() %></span>
    </div>
</div>

<style>
.hidden {
    display: none !important;
}
</style>
                    <p class="text-sm text-gray-500">Show this code at the entrance</p>
                </div>

                <!-- Action Buttons -->
                <div class="space-y-4">
                   <!-- Printable Voucher -->
<div id="voucher" style="visibility:hidden; font-family:Arial,sans-serif; font-size:12px; line-height:1.4; max-width:600px; margin:auto; border:1px solid #000; padding:15px;">
    
    <!-- Company Header -->
    <div style="display:flex; align-items:center; justify-content:space-between; margin-bottom:10px; border-bottom:1px solid #000; padding-bottom:8px;">
        <div style="display:flex; align-items:center;">
            <img src="assets/img/cinema-logo.jpg" alt="Cinema Logo" style="width:50px; height:50px; margin-right:10px;">
            <div>
                <h2 style="margin:0; font-size:16px;">CINEZY Cinema</h2>
                <div style="font-size:11px; line-height:1.3;">
                    <div><strong>Email:</strong> cinezy17@gmail.com</div>
                    <div><strong>Phone:</strong> +95 9780865174</div>
                    <div><strong>Address:</strong> University of Computer Studies Street, Hpa-an</div>
                </div>
            </div>
        </div>
    </div>

    <h3 style="text-align:center; margin:10px 0; font-size:14px; text-transform:uppercase;">Booking Voucher</h3>

    <!-- Customer Information -->
    <div style="margin-bottom:10px;">
        <strong>Customer Name:</strong> <%= user.getName() %><br>
        <strong>Email:</strong> <%= user.getEmail() %><br>
        <strong>Phone:</strong> <%= user.getPhone() %><br>
        <strong>Booking ID:</strong> #<%= booking.getBookingId() %>
    </div>

    <!-- Movie Details Table -->
    <table style="width:100%; border-collapse:collapse; margin-bottom:10px; border:1px solid #000; font-size:12px;">
        <tbody>
            <tr style="background-color:#f9f9f9;">
                <td style="padding:6px; font-weight:bold; border:1px solid #000;">Movie</td>
                <td style="padding:6px; border:1px solid #000;"><%= movie != null ? movie.getTitle() : "N/A" %></td>
                <td style="padding:6px; font-weight:bold; border:1px solid #000;">Theater</td>
                <td style="padding:6px; border:1px solid #000;"><%= theater != null ? theater.getName() : "N/A" %></td>
            </tr>
            <tr>
                <td style="padding:6px; font-weight:bold; border:1px solid #000;">Date</td>
                <td style="padding:6px; border:1px solid #000;"><%= showtime != null ? dateFormat.format(showtime.getShowDate()) : "-" %></td>
                <td style="padding:6px; font-weight:bold; border:1px solid #000;">Time</td>
                <td style="padding:6px; border:1px solid #000;"><%= showtime != null ? showtime.getStartTime() + " - " + showtime.getEndTime() : "-" %></td>
            </tr>
            <tr style="background-color:#f9f9f9;">
                <td style="padding:6px; font-weight:bold; border:1px solid #000;">Seats</td>
                <td colspan="3" style="padding:6px; border:1px solid #000;"><%= seatNumbersStr.length() > 0 ? seatNumbersStr.toString() : "N/A" %></td>
            </tr>
        </tbody>
    </table>

    <!-- Payment Information -->
    <div style="margin-bottom:10px;">
        <strong>Payment Method:</strong> 
        <%
            if ("kbzpay".equals(booking.getPaymentMethod())) out.print("KBZ Pay");
            else if ("wavepay".equals(booking.getPaymentMethod())) out.print("Wave Pay");
            else out.print("Cash");
        %><br>
        <strong>Payment Status:</strong> <%= "cash".equalsIgnoreCase(booking.getPaymentMethod()) ? "Pending" : "Paid" %><br>
        <strong>Total Amount:</strong> <%= booking.getTotalPrice() != null ? booking.getTotalPrice() : "0" %> MMK
    </div>

    <!-- QR Code -->
    <div style="text-align:center; margin-top:15px;">
        <img src="https://api.qrserver.com/v1/create-qr-code/?size=120x120&data=<%= java.net.URLEncoder.encode(request.getRequestURL() + "?" + request.getQueryString(), "UTF-8") %>" 
             alt="QR Code" style="width:120px;height:120px;margin-bottom:5px;"/>
        <div style="font-size:10px;">Show this code at entrance</div>
    </div>
</div>

<!-- Print Button -->
<div class="text-center no-print" style="margin-top:20px;">
    <button onclick="window.print()" style="background-color:#e11d48;color:white;padding:10px 20px;font-size:14px;border:none;border-radius:6px;cursor:pointer;">
        Print Voucher
    </button>
</div>

<style>
#voucher { visibility:hidden; height:0; overflow:hidden; }
@media print {
    body * { visibility: hidden; }
    #voucher, #voucher * { visibility: visible; }
    #voucher { position:absolute; left:0; top:0; width:100%; height:auto; padding:20px; border:2px solid #000; box-sizing:border-box; }
    .no-print { display:none !important; }
}
</style>

                    
                    <a href="myBookings.jsp" class="w-full flex items-center justify-center mt-6 underline text-red-700 font-bold hover:text-red-800 ">
                        <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2"></path>
                        </svg>
                        View All Bookings
                    </a>
                </div>
            </div>
        </div>

        
    </div>
</div>

<style>
@media print {
    .no-print {
        display: none !important;
    }
    body {
        background: white !important;
    }
    #voucher {
        border: 2px solid #000 !important;
    }
}
</style>

<jsp:include page="layout/footer.jsp"/>
<jsp:include page="layout/JSPFooter.jsp"/>