<%@ page import="com.demo.dao.MoviesDao" %>
<%@ page import="com.demo.dao.TheaterDAO" %>
<%@ page import="com.demo.dao.ShowtimesDao" %>
<%@ page import="com.demo.model.Movies" %>
<%@ page import="com.demo.model.Theater" %>
<%@ page import="com.demo.model.User" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // Session check
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    // Get parameters from booking confirmation
    String paymentMethod = request.getParameter("paymentMethod");
    Integer showtimeId = null;
    Double totalPrice = null;
    String[] seatIds = null;

    try {
        showtimeId = Integer.parseInt(request.getParameter("showtimeId"));
        totalPrice = Double.parseDouble(request.getParameter("totalPrice"));
        seatIds = request.getParameterValues("seatIds");
    } catch (Exception e) {
        response.sendRedirect("bookingConfirmation.jsp?error=invalid_data");
        return;
    }

    if (paymentMethod == null || showtimeId == null || seatIds == null) {
        response.sendRedirect("bookingConfirmation.jsp?error=missing_data");
        return;
    }

    // Store in session for BookTicketServlet
    session.setAttribute("paymentShowtimeId", showtimeId);
    session.setAttribute("paymentTotalPrice", totalPrice);
    session.setAttribute("paymentSeatIds", seatIds);
    session.setAttribute("paymentMethod", paymentMethod);

    // Fetch movie and theater details for display
    Integer movieId = (Integer) session.getAttribute("bookingMovieId");
    Integer theaterId = (Integer) session.getAttribute("bookingTheaterId");
    String showDate = (String) session.getAttribute("bookingShowDate");
    String selectedSeats = (String) session.getAttribute("bookingSelectedSeats");

    MoviesDao moviesDao = new MoviesDao();
    Movies movie = moviesDao.getMovieById(movieId);
    String movieTitle = movie != null ? movie.getTitle() : "Unknown Movie";

    TheaterDAO theaterDao = new TheaterDAO();
    Theater theater = theaterDao.getTheaterById(theaterId);
    String theaterName = theater != null ? theater.getName() : "Unknown Theater";

    ShowtimesDao showDao = new ShowtimesDao();
    String showTimeStr = showDao.getShowtimeById(showtimeId);
%>

<jsp:include page="layout/JSPHeader.jsp"/>
<jsp:include page="layout/header.jsp"/>

<div class="min-h-screen bg-gradient-to-br from-red-50 to-rose-50 py-8">
    <div class="container mx-auto px-13 max-w-6xl">
    <!-- Breadcrumb -->
        <nav class="text-sm mb-6" aria-label="Breadcrumb">
          <ol class="list-reset flex text-gray-600">
            <li><a href="home.jsp" class="hover:text-red-600">Home</a></li>
            <li><span class="mx-2">/</span></li>
            <li><a href="movies.jsp" class="hover:text-red-600">Movies</a></li>
            <li><span class="mx-2">/</span></li>
            <li>
              <a href="moviedetails.jsp?movie_id=<%= movieId %>" class="hover:text-red-600">
                Movie Details
              </a>
            </li>
                        <li><span class="mx-2">/</span></li>
            <li>
              <a href="GetMovieTheatersServlet?movie_id=<%= movieId %>" class="hover:text-red-600">
                Available Theaters
              </a>
            </li>
            <li><span class="mx-2">/</span></li>
            <li><a href="selectShowtimes.jsp?movie_id=<%= movieId %>&theater_id=<%= theaterId %>" class="hover:text-red-600">Seat</a></li>
            <li><span class="mx-2">/</span></li>
            <li><a href="bookingConfirmation.jsp" class="hover:text-red-600">Booking</a></li>
                <li><span class="mx-2">/</span></li>
                <li class="flex items-center text-gray-900 font-semibold">Payment</li>
          </ol>
        </nav>
        

        <!-- Header -->
        <div class="text-center mb-12">
            <h1 class="text-4xl font-bold text-gray-900 mb-3">Payment Scan</h1>
            <p class="text-lg text-gray-700 mx-auto">Complete your payment to confirm booking</p>
        </div>

        <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
            <!-- Left Column - Payment & QR -->
            <div class="lg:col-span-2 space-y-6">
                <!-- Payment Card -->
                <div class="bg-white rounded-2xl border-2 border-red-100 overflow-hidden">
                    <div class="bg-gradient-to-r from-red-600 to-rose-700 pt-6 px-6 pb-3">
                        <h2 class="text-2xl font-bold text-red-900">Payment Details</h2>
                    </div>
                    <div class="p-6 ">
                        <!-- Booking Info -->
                        
<div>
<div class="grid grid-cols-2 gap-4">
    <div>
    <div class="mb-3">
                                    <h3 class="text-lg font-semibold mb-2 text-red-700">Total Amount</h3>
                                    <p class="text-3xl font-bold text-red-900"><%= totalPrice %> MMK <span class="text-red-700 text-xs mt-2">Including all taxes and fees</span></p>
                                    
                                </div>
    <div class=" mb-6 p-6 bg-white rounded-xl border-2 border-red-100 shadow-sm">
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
                        <%= movieTitle %>
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
                        <%= theaterName %>
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
                        <%= showDate %>
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
                        <%= showTimeStr %>
                    </td>
                </tr>
                <tr class="hover:bg-red-50 transition-colors">
                    <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-600 bg-gray-50">
                        <div class="flex items-center">
                            <svg class="w-4 h-4 mr-2 text-red-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"></path>
                            </svg>
                            Seats
                        </div>
                    </td>
                    <td class="px-6 py-4 whitespace-nowrap text-sm font-semibold text-gray-900">
                        <%= selectedSeats %>
                    </td>
                </tr>
                <tr class="hover:bg-red-50 transition-colors">
                    <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-600 bg-gray-50">
                        <div class="flex items-center">
                            <svg class="w-4 h-4 mr-2 text-red-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z"></path>
                            </svg>
                            Total Seats
                        </div>
                    </td>
                    <td class="px-6 py-4 whitespace-nowrap text-sm font-semibold text-gray-900">
                        <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-red-100 text-red-800">
                            <%= seatIds.length %> seats
                        </span>
                    </td>
                </tr>
            </tbody>
        </table>
    </div>
</div>
       
    </div>
    <div >
         <!-- Payment Method Display -->
                        <div class="flex items-center justify-center gap-4 mb-6 p-4 ">
                            <%
                                if ("kbzpay".equalsIgnoreCase(paymentMethod)) {
                            %>
                                <div class="w-16 h-16 rounded-xl flex items-center justify-center border-2 border-white shadow-lg">
                                    <img src="assets/img/kpay.png" alt="KBZ Pay" class="w-10 h-10 rounded-lg">
                                </div>
                                <div>
                                    <span class="text-gray-700 font-bold text-xl">KBZ Pay</span>
                                    <p class="text-sm text-gray-600">Digital Payment</p>
                                </div>
                            <%
                                } else if ("wavepay".equalsIgnoreCase(paymentMethod)) {
                            %>
                                <div class="w-16 h-16  rounded-xl flex items-center justify-center border-2 border-white shadow-lg">
                                    <img src="assets/img/wavepay.jpeg" alt="Wave Pay" class="w-10 h-10 rounded-lg">
                                </div>
                                <div>
                                    <span class="text-gray-700 font-bold text-xl">Wave Pay</span>
                                    <p class="text-sm text-gray-600">Digital Payment</p>
                                </div>
                            <%
                                } else {
                            %>
                                <div class="w-16 h-16 bg-white rounded-xl flex items-center justify-center border-2 border-red-200 shadow-lg">
                                    <img src="assets/img/cash.png" alt="Cash" class="w-10 h-10 rounded-lg">
                                </div>
                                <div>
                                    <span class="text-gray-700 font-bold text-xl">Cash Payment</span>
                                    <p class="text-sm text-gray-600">Pay at Counter</p>
                                </div>
                            <%
                                }
                            %>
                        </div>
                                                <!-- QR Code Section -->
                        <div class="flex flex-col items-center">
                            <!-- Total Amount -->
                            <div class="w-full max-w-md">
                                
                            </div>

                            <!-- QR Code -->
                            <div class="w-72 h-72 bg-white border-2 border-red-200 rounded-2xl flex items-center justify-center mb-6 shadow-lg">
                                <%
                                    if ("kbzpay".equalsIgnoreCase(paymentMethod)) {
                                %>
                                    <img src="assets/img/kpz.png" alt="KBZ Pay QR" class="w-full h-full object-contain p-4">
                                <%
                                    } else if ("wavepay".equalsIgnoreCase(paymentMethod)) {
                                %>
                                    <img src="assets/img/wave.png" alt="Wave Pay QR" class="w-full h-full object-contain p-4">
                                <%
                                    } else {
                                %>
                                    <div class="text-center text-gray-500 p-6">
                                        <div class="w-20 h-20 bg-red-100 rounded-full flex items-center justify-center mx-auto mb-4 border-2 border-red-200">
                                            <svg class="w-10 h-10 text-red-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z"></path>
                                            </svg>
                                        </div>
                                        <p class="text-lg font-semibold text-gray-700">Cash Payment</p>
                                        <p class="text-sm text-gray-600 mt-2">Pay at counter</p>
                                    </div>
                                <%
                                    }
                                %>
                            </div>

                            <!-- Instructions -->
                            <p class="text-gray-600 mb-6 text-center text-sm max-w-md">
                                <%
                                    if (!"cash".equalsIgnoreCase(paymentMethod)) {
                                %>
                                    Scan the QR code with your mobile banking app to complete payment. Your booking will be confirmed automatically upon successful payment.
                                <%
                                    } else {
                                %>
                                    Please proceed to the theater counter to complete your cash payment. Show your booking details to the staff.
                                <%
                                    }
                                %>
                            </p>

                            <!-- Payment Completion Button -->
                            <form action="BookTicketServlet" method="post" class="w-full max-w-md">
                                <input type="hidden" name="showtimeId" value="<%= showtimeId %>">
                                <input type="hidden" name="totalPrice" value="<%= totalPrice %>">
                                <input type="hidden" name="paymentMethod" value="<%= paymentMethod %>">
                                <% for(String seatId : seatIds) { %>
                                    <input type="hidden" name="seatIds" value="<%= seatId %>">
                                <% } %>
                                
                                <button type="submit" class="w-full bg-red-700 hover:bg-red-800 text-white py-2 rounded-xl font-semibold text-lg transition-all transform  border-2 border-red-600">
                                    <div class="flex items-center justify-center gap-3">
                                        <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path>
                                        </svg>
                                        <%
                                            if ("cash".equalsIgnoreCase(paymentMethod)) {
                                        %>
                                            Confirm Cash Payment
                                        <%
                                            } else {
                                        %>
                                            Simulate Payment Completion
                                        <%
                                            }
                                        %>
                                    </div>
                                </button>
                            </form>
                        </div>
                    </div>
                    </div>
                </div>
                        
    </div>
    
</div>
                       

            </div>

            <!-- Right Column - User Info & Instructions -->
            <div class="space-y-6">
                <!-- User Information -->
                <div class="bg-white rounded-2xl border-2 border-red-100 p-6">
                    <h3 class="text-lg font-bold text-gray-900 mb-4 flex items-center">
                        <svg class="w-5 h-5 text-red-600 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"></path>
                        </svg>
                        Your Information
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

                <!-- Payment Instructions -->
                <div class="bg-white rounded-2xl border-2 border-red-100 p-6">
                    <h3 class="text-lg font-bold text-gray-900 mb-4 flex items-center">
                        <svg class="w-5 h-5 text-red-600 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z"></path>
                        </svg>
                        Payment Instructions
                    </h3>
                    <div class="space-y-3 text-sm text-gray-700">
                        <%
                            if ("kbzpay".equalsIgnoreCase(paymentMethod)) {
                        %>
                            <div class="flex items-start space-x-2 p-2 bg-red-50 rounded-lg border border-red-100">
                                <div class="w-5 h-5 bg-blue-100 rounded-full flex items-center justify-center flex-shrink-0 mt-0.5 border border-blue-200">
                                    <span class="text-blue-600 text-xs font-bold">1</span>
                                </div>
                                <p>Open KBZ Pay app on your phone</p>
                            </div>
                            <div class="flex items-start space-x-2 p-2 bg-red-50 rounded-lg border border-red-100">
                                <div class="w-5 h-5 bg-blue-100 rounded-full flex items-center justify-center flex-shrink-0 mt-0.5 border border-blue-200">
                                    <span class="text-blue-600 text-xs font-bold">2</span>
                                </div>
                                <p>Tap on 'Scan & Pay'</p>
                            </div>
                            <div class="flex items-start space-x-2 p-2 bg-red-50 rounded-lg border border-red-100">
                                <div class="w-5 h-5 bg-blue-100 rounded-full flex items-center justify-center flex-shrink-0 mt-0.5 border border-blue-200">
                                    <span class="text-blue-600 text-xs font-bold">3</span>
                                </div>
                                <p>Scan the QR code above</p>
                            </div>
                            <div class="flex items-start space-x-2 p-2 bg-red-50 rounded-lg border border-red-100">
                                <div class="w-5 h-5 bg-blue-100 rounded-full flex items-center justify-center flex-shrink-0 mt-0.5 border border-blue-200">
                                    <span class="text-blue-600 text-xs font-bold">4</span>
                                </div>
                                <p>Confirm the amount and complete payment</p>
                            </div>
                        <%
                            } else if ("wavepay".equalsIgnoreCase(paymentMethod)) {
                        %>
                            <div class="flex items-start space-x-2 p-2 bg-red-50 rounded-lg border border-red-100">
                                <div class="w-5 h-5 bg-yellow-100 rounded-full flex items-center justify-center flex-shrink-0 mt-0.5 border border-yellow-200">
                                    <span class="text-yellow-600 text-xs font-bold">1</span>
                                </div>
                                <p>Open Wave Pay app on your phone</p>
                            </div>
                            <div class="flex items-start space-x-2 p-2 bg-red-50 rounded-lg border border-red-100">
                                <div class="w-5 h-5 bg-yellow-100 rounded-full flex items-center justify-center flex-shrink-0 mt-0.5 border border-yellow-200">
                                    <span class="text-yellow-600 text-xs font-bold">2</span>
                                </div>
                                <p>Tap on 'Scan to Pay'</p>
                            </div>
                            <div class="flex items-start space-x-2 p-2 bg-red-50 rounded-lg border border-red-100">
                                <div class="w-5 h-5 bg-yellow-100 rounded-full flex items-center justify-center flex-shrink-0 mt-0.5 border border-yellow-200">
                                    <span class="text-yellow-600 text-xs font-bold">3</span>
                                </div>
                                <p>Scan the QR code above</p>
                            </div>
                            <div class="flex items-start space-x-2 p-2 bg-red-50 rounded-lg border border-red-100">
                                <div class="w-5 h-5 bg-yellow-100 rounded-full flex items-center justify-center flex-shrink-0 mt-0.5 border border-yellow-200">
                                    <span class="text-yellow-600 text-xs font-bold">4</span>
                                </div>
                                <p>Enter your PIN to confirm payment</p>
                            </div>
                        <%
                            } else {
                        %>
                            <div class="flex items-start space-x-2 p-2 bg-red-50 rounded-lg border border-red-100">
                                <div class="w-5 h-5 bg-green-100 rounded-full flex items-center justify-center flex-shrink-0 mt-0.5 border border-green-200">
                                    <span class="text-green-600 text-xs font-bold">1</span>
                                </div>
                                <p>Proceed to the theater counter</p>
                            </div>
                            <div class="flex items-start space-x-2 p-2 bg-red-50 rounded-lg border border-red-100">
                                <div class="w-5 h-5 bg-green-100 rounded-full flex items-center justify-center flex-shrink-0 mt-0.5 border border-green-200">
                                    <span class="text-green-600 text-xs font-bold">2</span>
                                </div>
                                <p>Show your booking details</p>
                            </div>
                            <div class="flex items-start space-x-2 p-2 bg-red-50 rounded-lg border border-red-100">
                                <div class="w-5 h-5 bg-green-100 rounded-full flex items-center justify-center flex-shrink-0 mt-0.5 border border-green-200">
                                    <span class="text-green-600 text-xs font-bold">3</span>
                                </div>
                                <p>Pay the total amount in cash</p>
                            </div>
                            <div class="flex items-start space-x-2 p-2 bg-red-50 rounded-lg border border-red-100">
                                <div class="w-5 h-5 bg-green-100 rounded-full flex items-center justify-center flex-shrink-0 mt-0.5 border border-green-200">
                                    <span class="text-green-600 text-xs font-bold">4</span>
                                </div>
                                <p>Collect your payment receipt</p>
                            </div>
                        <%
                            }
                        %>
                    </div>
                </div>

                <!-- Company Rules -->
                <div class="bg-white rounded-2xl border-2 border-red-100 p-6">
                    <h3 class="text-lg font-bold text-gray-900 mb-4 flex items-center">
                        <svg class="w-5 h-5 text-red-600 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"></path>
                        </svg>
                        Booking Rules
                    </h3>
                    <ul class="list-disc list-inside text-gray-700 space-y-2 text-sm">
                        <li>Payment must be completed within 15 minutes</li>
                        <li>No refunds are allowed after payment confirmation</li>
                        <li>Please present your booking confirmation at the theater</li>
                        <li>Seats are reserved until showtime</li>
                        <li>Company reserves the right to modify terms without prior notice</li>
                    </ul>
                </div>

                
            </div>
        </div>
    </div>
</div>

<jsp:include page="layout/footer.jsp"/>
<jsp:include page="layout/JSPFooter.jsp"/>