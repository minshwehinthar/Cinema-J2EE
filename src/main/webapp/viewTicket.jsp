<%@page import="com.demo.dao.SeatsDao"%>
<%@ page import="com.demo.dao.MoviesDao"%>
<%@ page import="com.demo.dao.TheaterDAO"%>
<%@ page import="com.demo.dao.ShowtimesDao"%>
<%@ page import="com.demo.dao.BookingDao"%>
<%@ page import="com.demo.model.*"%>
<%@ page import="java.text.SimpleDateFormat"%>
<%@ page import="java.util.List"%>
<%@ page import="java.math.BigDecimal"%>
<%@ page contentType="text/html;charset=UTF-8" language="java"%>

<%
User user = (User) session.getAttribute("user");
if (user == null) {
	response.sendRedirect("login.jsp");
	return;
}

Integer bookingId = request.getParameter("bookingId") != null ? Integer.parseInt(request.getParameter("bookingId"))
		: null;

if (bookingId == null) {
	out.println("<h2 style='text-align:center;color:red;margin-top:50px;'>Booking ID not provided!</h2>");
	return;
}

// Fetch Booking
BookingDao bookingDao = new BookingDao();
Booking booking = bookingDao.getBookingById(bookingId);

if (booking == null) {
	out.println("<h2 style='text-align:center;color:red;margin-top:50px;'>Booking not found!</h2>");
	return;
}

// Fetch Showtime
ShowtimesDao showDao = new ShowtimesDao();
Showtime showtime = showDao.getShowtimeDetails(booking.getShowtimeId());

// Movie
MoviesDao moviesDao = new MoviesDao();
Movies movie = showtime != null ? moviesDao.getMovieById(showtime.getMovieId()) : null;

// Theater
TheaterDAO theaterDao = new TheaterDAO();
Theater theater = showtime != null ? theaterDao.getTheaterById(showtime.getTheaterId()) : null;

// Seats
SeatsDao seatDao = new SeatsDao();
List<Seat> seats = seatDao.getSeatsByShowtimeSeatIds(booking.getSelectedSeatIds());

int totalSeats = seats != null ? seats.size() : 0;
StringBuilder seatNumbersStr = new StringBuilder();
if (seats != null) {
	for (int i = 0; i < seats.size(); i++) {
		if (i > 0)
	seatNumbersStr.append(", ");
		seatNumbersStr.append(seats.get(i).getSeatNumber());
	}
}

// Date formats
SimpleDateFormat dateFormat = new SimpleDateFormat("EEEE, MMMM d, yyyy");
SimpleDateFormat timeFormat = new SimpleDateFormat("h:mm a");
SimpleDateFormat dateTimeFormat = new SimpleDateFormat("MMM dd, yyyy 'at' h:mm a");

// Booking status color
String statusColor = "text-yellow-600";
if ("confirmed".equalsIgnoreCase(booking.getStatus()))
	statusColor = "text-green-600";
else if ("cancelled".equalsIgnoreCase(booking.getStatus()))
	statusColor = "text-red-600";
%>

<jsp:include page="layout/JSPHeader.jsp" />
<jsp:include page="layout/header.jsp" />

<div class="min-h-screen bg-gradient-to-br from-red-50 to-rose-50 py-8">
	<div class="container mx-auto px-4 max-w-6xl">
<nav class="text-gray-500 text-sm mb-4" aria-label="Breadcrumb">
			<ol class="list-none p-0 inline-flex">
				<li><a href="home.jsp" class="hover:text-red-600">Home</a></li>
            <li><span class="mx-2">/</span></li>
            <li><a href="myBookings.jsp" class="hover:text-red-600">My Bookings</a></li>
            <li><span class="mx-2">/</span></li>
				<li class="flex items-center text-gray-900 font-semibold">Booking Details
				</li>
			</ol>
		</nav>
		<!-- Header -->
		<div class="text-center mb-8">
			<h1 class="text-4xl font-bold text-gray-900 mb-3">Booking
				Details</h1>
			
		</div>

		<div class="grid grid-cols-1 lg:grid-cols-3 gap-6">

			<!-- Left Column -->
			<div class="lg:col-span-2 space-y-6">

				<!-- Booking Details & Payment -->
				<div class="grid grid-cols-2 gap-6">

					<!-- Booking Details -->
					<div class="bg-white rounded-2xl border-2 border-red-100 p-6">
						<h3 class="text-xl font-bold text-gray-900 mb-4">Booking
							Details</h3>
						<div class="space-y-4">
							<div class="p-3 bg-red-50 rounded-lg border border-red-100">
								<label class="block text-sm text-gray-600 mb-1">Booking
									ID</label>
								<p class="font-semibold text-gray-900">
									#<%=booking.getBookingId()%></p>
							</div>
							<div class="p-3 bg-red-50 rounded-lg border border-red-100">
								<label class="block text-sm text-gray-600 mb-1">Booking
									Time</label>
								<p class="font-semibold text-gray-900">
									<%=booking.getBookingTime() != null ? dateTimeFormat.format(booking.getBookingTime()) : "N/A"%>
								</p>
							</div>
							<div class="p-3 bg-red-50 rounded-lg border border-red-100">
								<label class="block text-sm text-gray-600 mb-1">Status</label>
								<p class="font-semibold <%=statusColor%>">
									<%=booking.getStatus() != null
		? booking.getStatus().substring(0, 1).toUpperCase() + booking.getStatus().substring(1)
		: "Unknown"%>
								</p>
							</div>
						</div>
					</div>

					<!-- Payment Details -->
					<div class="bg-white rounded-2xl border-2 border-red-100 p-6">
						<h3 class="text-xl font-bold text-gray-900 mb-4">Payment
							Information</h3>
						<div class="space-y-4">
							<div class="p-3 bg-red-50 rounded-lg border border-red-100">
								<label class="block text-sm text-gray-600 mb-1">Payment
									Method</label>
								<p class="font-semibold text-gray-900">
									<%
									String paymentMethod = booking.getPaymentMethod();
									if ("kbzpay".equals(paymentMethod))
										out.print("KBZ Pay");
									else if ("wavepay".equals(paymentMethod))
										out.print("Wave Pay");
									else
										out.print("Cash");
									%>
								</p>
							</div>
							<div class="p-3 bg-red-50 rounded-lg border border-red-100">
								<label class="block text-sm text-gray-600 mb-1">Payment
									Status</label>
								<p
									class="font-semibold <%=!"cash".equalsIgnoreCase(paymentMethod) ? "text-green-600" : "text-yellow-600"%>">
									<%=!"cash".equalsIgnoreCase(paymentMethod) ? "Paid" : "Pending"%>
								</p>
							</div>
							<div
								class="p-4 bg-gradient-to-r from-red-600 to-rose-700 rounded-lg border-2 border-red-500">
								<label class="block text-sm text-red-900 mb-1">Total
									Amount</label>
								<p class="font-bold text-red-700 text-2xl">
									<%=booking.getTotalPrice() != null ? booking.getTotalPrice() : "0"%>
									MMK
								</p>
							</div>
						</div>
					</div>

				</div>

				<!-- Movie & Showtime Info -->
				<!-- Movie & Showtime Info - Premium Design -->
<div class="bg-white rounded-3xl shadow-xl border border-red-200 mt-6 p-6">
    <h3 class="text-3xl font-bold text-center text-red-600 mb-8">Showtime Details</h3>

    <div class="grid grid-cols-1 md:grid-cols-2 gap-8">
        <!-- Left Column: Movie Info -->
        <div class="space-y-4">
            <div class="flex items-center gap-3">
                <svg class="w-5 h-5 text-red-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                        d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8v4m0 4v4" />
                </svg>
                <span class="font-semibold text-gray-900 text-lg">Movie: <%= movie != null ? movie.getTitle() : "N/A" %></span>
            </div>

            <div class="flex items-center gap-3">
                <svg class="w-5 h-5 text-red-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                        d="M12 14l9-5-9-5-9 5 9 5z" />
                </svg>
                <span class="text-gray-700"><strong>Duration:</strong> <%= movie != null ? movie.getDuration() : "-" %></span>
            </div>

            <div class="flex items-center gap-3">
                <svg class="w-5 h-5 text-red-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                        d="M12 14l9-5-9-5-9 5 9 5z" />
                </svg>
                <span class="text-gray-700"><strong>Director:</strong> <%= movie != null ? movie.getDirector() : "-" %></span>
            </div>

            <div class="flex items-center gap-3">
                <svg class="w-5 h-5 text-red-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                        d="M3 7v4h18V7H3zm0 6v4h18v-4H3z" />
                </svg>
                <span class="text-gray-700"><strong>Casts:</strong> <%= movie != null ? movie.getCasts() : "-" %></span>
            </div>

            <div class="flex items-center gap-3">
                <svg class="w-5 h-5 text-red-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                        d="M5 3v4h14V3H5zm0 6v12h14V9H5z" />
                </svg>
                <span class="text-gray-700"><strong>Genres:</strong> <%= movie != null ? movie.getGenres() : "-" %></span>
            </div>
        </div>

        <!-- Right Column: Showtime & Theater Info -->
        <div class="space-y-4">
            <div class="flex items-center gap-3">
                <svg class="w-5 h-5 text-red-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                        d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" />
                </svg>
                <span class="text-gray-900 font-semibold">Theater: <%= theater != null ? theater.getName() : "N/A" %></span>
            </div>

            <div class="flex items-center gap-3">
                <svg class="w-5 h-5 text-red-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                        d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
                </svg>
                <span class="text-gray-700"><strong>Date:</strong> <%= showtime != null ? dateFormat.format(showtime.getShowDate()) : "-" %></span>
            </div>

            <div class="flex items-center gap-3">
                <svg class="w-5 h-5 text-red-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                        d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8v4m0 4v4" />
                </svg>
                <span class="text-gray-700"><strong>Time:</strong> <%= showtime != null ? showtime.getStartTime() + " - " + showtime.getEndTime() : "-" %></span>
            </div>

            <div class="flex items-center gap-3">
                <svg class="w-5 h-5 text-red-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                        d="M5 13l4 4L19 7" />
                </svg>
                <span class="text-gray-900 font-semibold">Total Seats: <%= totalSeats %></span>
            </div>

            <div class="flex items-center gap-3">
                <svg class="w-5 h-5 text-red-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                        d="M3 7v4h18V7H3zm0 6v4h18v-4H3z" />
                </svg>
                <span class="text-gray-700"><strong>Seats:</strong> <%= seatNumbersStr.toString() %></span>
            </div>
        </div>
    </div>
</div>


			</div>

			<!-- Right Column: User + QR -->
			<div class="space-y-6">

				<!-- Customer Info -->
				<div class="bg-white rounded-2xl border-2 border-red-100 p-6">
					<h3 class="text-xl font-bold text-gray-900 mb-4">Customer
						Information</h3>
					<p>
						<strong>Name:</strong>
						<%=user.getName()%></p>
					<p>
						<strong>Email:</strong>
						<%=user.getEmail()%></p>
					<p>
						<strong>Phone:</strong>
						<%=user.getPhone()%></p>
				</div>

				<!-- QR Code -->
				<div
					class="bg-white rounded-2xl border-2 border-red-100 p-6 text-center">
					<h3 class="text-xl font-bold text-gray-900 mb-4">QR Code</h3>
					<img
						src="https://api.qrserver.com/v1/create-qr-code/?size=160x160&data=<%=java.net.URLEncoder.encode(request.getRequestURL() + "?" + request.getQueryString(), "UTF-8")%>"
						alt="QR Code" class="mx-auto" />
					<p class="text-sm text-gray-500 mt-2">Show this code at
						entrance</p>
				</div>

				<!-- Print Voucher Button -->
				<div class="text-center">

					<!-- Print Voucher Section -->
					<div class="text-center mb-8">
						<button onclick="window.print()"
							style="background-color: #e11d48; color: white; padding: 10px 20px; font-size: 14px; border: none; border-radius: 6px; cursor: pointer;">
							Print Voucher</button>
					</div>

					<!-- Voucher -->
					<div id="voucher">
						<!-- Company Header -->
						<div
							style="display: flex; align-items: center; justify-content: space-between; margin-bottom: 10px; border-bottom: 1px solid #000; padding-bottom: 8px;">
							<div style="display: flex; align-items: center;">
								<img src="assets/img/cinema-logo.jpg" alt="Cinema Logo"
									style="width: 50px; height: 50px; margin-right: 10px;">
								<div>
									<h2 style="margin: 0; font-size: 16px;">CINEZY Cinema</h2>
									<div style="font-size: 11px; line-height: 1.3;">
										<div>
											<strong>Email:</strong> cinezy17@gmail.com
										</div>
										<div>
											<strong>Phone:</strong> +95 9780865174
										</div>
										<div>
											<strong>Address:</strong> University of Computer Studies
											Street, Hpa-an
										</div>
									</div>
								</div>
							</div>
						</div>

						<h3
							style="text-align: center; margin: 10px 0; font-size: 14px; text-transform: uppercase;">Booking
							Voucher</h3>

						<!-- Customer Information -->
						<div style="margin-bottom: 10px;">
							<strong>Customer Name:</strong>
							<%=user.getName()%><br> <strong>Email:</strong>
							<%=user.getEmail()%><br> <strong>Phone:</strong>
							<%=user.getPhone()%><br> <strong>Booking ID:</strong> #<%=booking.getBookingId()%>
						</div>

						<!-- Movie Details Table -->
						<table
							style="width: 100%; border-collapse: collapse; margin-bottom: 10px; border: 1px solid #000; font-size: 12px;">
							<tbody>
								<tr style="background-color: #f9f9f9;">
									<td
										style="padding: 6px; font-weight: bold; border: 1px solid #000;">Movie</td>
									<td style="padding: 6px; border: 1px solid #000;"><%=movie != null ? movie.getTitle() : "N/A"%></td>
									<td
										style="padding: 6px; font-weight: bold; border: 1px solid #000;">Theater</td>
									<td style="padding: 6px; border: 1px solid #000;"><%=theater != null ? theater.getName() : "N/A"%></td>
								</tr>
								<tr>
									<td
										style="padding: 6px; font-weight: bold; border: 1px solid #000;">Date</td>
									<td style="padding: 6px; border: 1px solid #000;"><%=showtime != null ? dateFormat.format(showtime.getShowDate()) : "-"%></td>
									<td
										style="padding: 6px; font-weight: bold; border: 1px solid #000;">Time</td>
									<td style="padding: 6px; border: 1px solid #000;"><%=showtime != null ? showtime.getStartTime() + " - " + showtime.getEndTime() : "-"%></td>
								</tr>
								<tr style="background-color: #f9f9f9;">
									<td
										style="padding: 6px; font-weight: bold; border: 1px solid #000;">Seats</td>
									<td colspan="3" style="padding: 6px; border: 1px solid #000;"><%=seatNumbersStr.length() > 0 ? seatNumbersStr.toString() : "N/A"%></td>
								</tr>
							</tbody>
						</table>

						<!-- Payment Information -->
						<div style="margin-bottom: 10px;">
							<strong>Payment Method:</strong>
							<%
							if ("kbzpay".equals(booking.getPaymentMethod()))
								out.print("KBZ Pay");
							else if ("wavepay".equals(booking.getPaymentMethod()))
								out.print("Wave Pay");
							else
								out.print("Cash");
							%><br> <strong>Payment Status:</strong>
							<%="cash".equalsIgnoreCase(booking.getPaymentMethod()) ? "Pending" : "Paid"%><br>
							<strong>Total Amount:</strong>
							<%=booking.getTotalPrice() != null ? booking.getTotalPrice() : "0"%>
							MMK
						</div>

						<!-- QR Code -->
						<div style="text-align: center; margin-top: 15px;">
							<img
								src="https://api.qrserver.com/v1/create-qr-code/?size=120x120&data=<%=java.net.URLEncoder.encode(request.getRequestURL() + "?" + request.getQueryString(), "UTF-8")%>"
								alt="QR Code"
								style="width: 120px; height: 120px; margin-bottom: 5px;" />
							<div style="font-size: 10px;">Show this code at entrance</div>
						</div>
					</div>

				</div>
			</div>

			<!-- Print CSS -->
			<!-- Print CSS -->
<style>
/* Hide voucher on screen */
#voucher {
	display: none;
}

/* Print styles */
@media print {
	body * {
		visibility: hidden !important;
	}
	#voucher, #voucher * {
		visibility: visible !important;
	}

	#voucher {
		display: block !important;
		position: absolute;
		left: 0 !important; /* start from left */
		top: 0 !important;
		width: 100% !important;
		
		box-sizing: border-box;
		background: white;
		text-align: left !important; /* left-align all text by default */
	}
	
	/* Keep only the heading centered */
	#voucher h3 {
		text-align: center !important;
	}
	
	/* Tables and other divs left-aligned */
	#voucher table,
	#voucher div {
		text-align: left !important;
	}
}
</style>

		</div>

	</div>

</div>
</div>
</div>

<jsp:include page="layout/footer.jsp" />
<jsp:include page="layout/JSPFooter.jsp" />

<style>
@media print {
	body * {
		visibility: hidden;
	}
	.min-h-screen, .min-h-screen * {
		visibility: visible;
	}
}
</style>
