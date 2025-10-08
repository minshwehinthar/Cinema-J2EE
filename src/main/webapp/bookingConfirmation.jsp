<%@ page import="com.demo.dao.MoviesDao" %>
<%@ page import="com.demo.dao.TheaterDAO" %>
<%@ page import="com.demo.dao.ShowtimesDao" %>
<%@ page import="com.demo.model.Movies" %>
<%@ page import="com.demo.model.Theater" %>
<%@ page import="com.demo.model.User" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.text.SimpleDateFormat" %>

<%
    // Get user from session
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    // Get booking data from session
    Integer movieId = (Integer) session.getAttribute("bookingMovieId");
    Integer theaterId = (Integer) session.getAttribute("bookingTheaterId");
    Integer showtimeId = (Integer) session.getAttribute("bookingShowtimeId");
    String showDate = (String) session.getAttribute("bookingShowDate");
    String selectedSeats = (String) session.getAttribute("bookingSelectedSeats");
    String[] seatIds = (String[]) session.getAttribute("bookingSelectedSeatIds");
    Double totalPrice = (Double) session.getAttribute("bookingTotalPrice");

    if (movieId == null || theaterId == null || showtimeId == null || seatIds == null) {
        out.println("<h2 class='text-red-600 text-center mt-10'>Booking data not found!</h2>");
        return;
    }

    // Fetch movie and theater details
    MoviesDao moviesDao = new MoviesDao();
    Movies movie = moviesDao.getMovieById(movieId);
    String movieTitle = movie != null ? movie.getTitle() : "Unknown Movie";

    TheaterDAO theaterDao = new TheaterDAO();
    Theater theater = theaterDao.getTheaterById(theaterId);
    String theaterName = theater != null ? theater.getName() : "Unknown Theater";

    ShowtimesDao showDao = new ShowtimesDao();
    String showTimeStr = showDao.getShowtimeById(showtimeId);

    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
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
				<li class="flex items-center text-gray-900 font-semibold">Booking
				</li>
			</ol>
          </ol>
        </nav>
        
   
        <!-- Header -->
        <div class="text-center mb-12">
            <!-- <div class="inline-flex items-center justify-center w-16 h-16 bg-red-100 rounded-full mb-4 border-2 border-red-200">
                <svg class="w-8 h-8 text-red-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path>
                </svg>
            </div> -->
            <h1 class="text-4xl font-bold text-gray-900 mb-3">Complete Your Booking</h1>
            <p class="text-lg text-gray-700  mx-auto">Review your details and proceed to secure payment</p>
        </div>

        <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
            <!-- Left Column - Booking Summary -->
            <div class="lg:col-span-2 space-y-6">
                <!-- Movie & Showtime Card -->
                <div class="bg-white rounded-2xl border-2 border-red-100 overflow-hidden">
                    <div class="bg-gradient-to-r from-red-600 to-rose-700 pt-6 px-6 pb-3">
                        <h2 class="text-2xl font-bold">Showtime Details</h2>
                    </div>
                    <div class="px-6 pb-6">
                        <div class="flex items-start space-x-6">
                            <div class="flex-1">
                                <h3 class="text-lg font-bold text-red-900 mb-2">Movie Title - <%= movieTitle %></h3>
                                <div class="grid grid-cols-1 md:grid-cols-2 gap-4 mt-4">
                                    <div class="flex items-center space-x-3 p-3 bg-red-50 rounded-lg border border-red-100">
                                        <div class="w-10 h-10 bg-red-100 rounded-lg flex items-center justify-center border border-red-200">
                                            <svg class="w-5 h-5 text-red-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 8v-4m0 4h4"></path>
                                            </svg>
                                        </div>
                                        <div>
                                            <p class="text-sm text-gray-600">Theater</p>
                                            <p class="font-semibold text-gray-900"><%= theaterName %></p>
                                        </div>
                                    </div>
                                    <div class="flex items-center space-x-3 p-3 bg-red-50 rounded-lg border border-red-100">
                                        <div class="w-10 h-10 bg-red-100 rounded-lg flex items-center justify-center border border-red-200">
                                            <svg class="w-5 h-5 text-red-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z"></path>
                                            </svg>
                                        </div>
                                        <div>
                                            <p class="text-sm text-gray-600">Date & Time</p>
                                            <p class="font-semibold text-gray-900"><%= showDate %> • <%= showTimeStr %></p>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Seats & User Info -->
                <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                    <!-- Seats Information -->
                    <div class="bg-white rounded-2xl border-2 border-red-100 p-6">
                        <h3 class="text-lg font-bold text-gray-900 mb-4 flex items-center">
                            <svg class="w-5 h-5 text-red-600 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"></path>
                            </svg>
                            Selected Seats
                        </h3>
                        <div class="bg-red-50 rounded-xl p-4 border border-red-100">
                            <div class="text-center">
                                <p class="text-2xl font-bold text-red-700"><%= selectedSeats %></p>
                                <p class="text-sm text-red-600 mt-1"><%= seatIds.length %> seats selected</p>
                            </div>
                        </div>
                    </div>

                    <!-- User Information -->
                    <div class="bg-white rounded-2xl border-2 border-red-100 p-6">
                        <h3 class="text-lg font-bold text-gray-900 mb-4 flex items-center">
                            <svg class="w-5 h-5 text-red-600 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"></path>
                            </svg>
                            Your Information
                        </h3>
                        <div class="space-y-3">
                            <div class="p-2 bg-red-50 rounded-lg border border-red-100">
                                <p class="text-sm text-gray-600">Full Name</p>
                                <p class="font-semibold text-gray-900"><%= user.getName() %></p>
                            </div>
                            <div class="p-2 bg-red-50 rounded-lg border border-red-100">
                                <p class="text-sm text-gray-600">Email</p>
                                <p class="font-semibold text-gray-900"><%= user.getEmail() %></p>
                            </div>
                            <div class="p-2 bg-red-50 rounded-lg border border-red-100">
                                <p class="text-sm text-gray-600">Phone</p>
                                <p class="font-semibold text-gray-900"><%= user.getPhone() %></p>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Booking Rules -->
                <div class="bg-white rounded-2xl border-2 border-red-100 p-6">
                    <h3 class="text-lg font-bold text-gray-900 mb-4 flex items-center">
                        <svg class="w-5 h-5 text-red-600 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"></path>
                        </svg>
                        Important Information
                    </h3>
                    <div class="grid grid-cols-1 md:grid-cols-2 gap-4 text-sm text-gray-600">
                        <div class="flex items-start space-x-2 p-2 bg-red-50 rounded-lg border border-red-100">
                            <div class="w-5 h-5 bg-green-100 rounded-full flex items-center justify-center flex-shrink-0 mt-0.5 border border-green-200">
                                <svg class="w-3 h-3 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path>
                                </svg>
                            </div>
                            <p>Confirm booking 24 hours before showtime</p>
                        </div>
                        <div class="flex items-start space-x-2 p-2 bg-red-50 rounded-lg border border-red-100">
                            <div class="w-5 h-5 bg-red-100 rounded-full flex items-center justify-center flex-shrink-0 mt-0.5 border border-red-200">
                                <svg class="w-3 h-3 text-red-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
                                </svg>
                            </div>
                            <p>No refunds after payment confirmation</p>
                        </div>
                        <div class="flex items-start space-x-2 p-2 bg-red-50 rounded-lg border border-red-100">
                            <div class="w-5 h-5 bg-blue-100 rounded-full flex items-center justify-center flex-shrink-0 mt-0.5 border border-blue-200">
                                <svg class="w-3 h-3 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path>
                                </svg>
                            </div>
                            <p>Present valid ID at theater entrance</p>
                        </div>
                        <div class="flex items-start space-x-2 p-2 bg-red-50 rounded-lg border border-red-100">
                            <div class="w-5 h-5 bg-amber-100 rounded-full flex items-center justify-center flex-shrink-0 mt-0.5 border border-amber-200">
                                <svg class="w-3 h-3 text-amber-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"></path>
                                </svg>
                            </div>
                            <p>Terms subject to change without notice</p>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Right Column - Payment & Actions -->
            <div class="space-y-6">
                <!-- Total Price Card -->
                <div class="bg-gradient-to-br from-red-600 to-rose-700 rounded-2xl p-6 text-white relative overflow-hidden border-2 border-red-500">
                    <div class="absolute top-0 right-0 w-24 h-24 bg-white bg-opacity-10 rounded-full -mr-6 -mt-6"></div>
                    <div class="relative z-10">
                        <h3 class="text-lg font-semibold mb-2 text-red-900">Total Amount</h3>
                        <p class="text-3xl text-red-700 font-bold mb-2" id="total-price-display"><%= totalPrice %> MMK</p>
                        <div class="text-red-900 text-sm">
                            <p>Including all taxes and service fees</p>
                        </div>
                    </div>
                </div>

                <!-- Payment Methods -->
                <div class="bg-white rounded-2xl border-2 border-red-100 p-6">
                    <h3 class="text-xl font-bold text-gray-900 mb-4">Choose Payment</h3>
                    <span id="paymentError" class="error-text" style="display: none;">Please select a payment method.</span>
                    
                    <div class="grid grid-cols-3 gap-3 mt-4">
                        <!-- KBZ Pay -->
                        <label class="payment-option group flex flex-col items-center p-4 border-2 border-red-200 rounded-xl w-full cursor-pointer transition-all hover:border-red-500 hover:bg-red-50">
                            <input type="radio" name="paymentMethod" value="kbzpay" class="hidden" required>
                            <div class="w-12 h-12 bg-blue-800 rounded-lg flex items-center justify-center mb-3 group-hover:scale-110 transition-transform border border-white">
                                 <img class="rounded-lg" src="assets/img/kpay.png"/>
                            </div>
                            <span class="text-gray-700 text-sm font-medium group-hover:text-gray-900">KBZ Pay</span>
                        </label>

                        <!-- Wave Pay -->
                        <label class="payment-option group flex flex-col items-center p-4 border-2 border-red-200 rounded-xl w-full cursor-pointer transition-all hover:border-red-500 hover:bg-red-50">
                            <input type="radio" name="paymentMethod" value="wavepay" class="hidden">
                            <div class="w-12 h-12 bg-yellow-400 rounded-lg flex items-center justify-center mb-3 group-hover:scale-110 transition-transform border border-white">
                                <img class="rounded-lg" src="assets/img/wavepay.jpeg"/>
                            </div>
                            <span class="text-gray-700 text-sm font-medium group-hover:text-gray-900">Wave Pay</span>
                        </label>

                        <!-- Cash Payment -->
                        <label class="payment-option group flex flex-col items-center p-4 border-2 border-red-200 rounded-xl w-full cursor-pointer transition-all hover:border-red-500 hover:bg-red-50">
                            <input type="radio" name="paymentMethod" value="cash" class="hidden">
                            <div class="w-12 h-12 rounded-lg bg-white flex items-center justify-center mb-3 group-hover:scale-110 transition-transform border border-white">
                                 <img class="rounded-lg" src="assets/img/cash.png"/>
                            </div>
                            <span class="text-gray-700 text-sm font-medium group-hover:text-gray-900">Cash</span>
                        </label>
                    </div>
                </div>

                <!-- Action Buttons -->
                <div class="space-y-4">
                    <!-- Hidden form for digital payments -->
                    <form id="paymentForm" action="PaymentScanForBooking.jsp" method="post" class="hidden">
                        <input type="hidden" name="showtimeId" value="<%= showtimeId %>">
                        <input type="hidden" name="totalPrice" value="<%= totalPrice %>">
                        <input type="hidden" name="paymentMethod" id="selectedPaymentMethodInput" value="">
                        <% for(String seatId : seatIds) { %>
                            <input type="hidden" name="seatIds" value="<%= seatId %>">
                        <% } %>
                    </form>

                    <!-- Hidden form for cash payments -->
                    <form id="cashForm" action="BookTicketServlet" method="post" class="hidden">
                        <input type="hidden" name="showtimeId" value="<%= showtimeId %>">
                        <input type="hidden" name="totalPrice" value="<%= totalPrice %>">
                        <input type="hidden" name="paymentMethod" value="cash">
                        <% for(String seatId : seatIds) { %>
                            <input type="hidden" name="seatIds" value="<%= seatId %>">
                        <% } %>
                    </form>

                    <button type="button" id="proceedToPaymentBtn" 
                            class="w-full bg-red-700  py-4 px-6 rounded-xl font-semibold text-lg transition-all transform hover:bg-red-800 text-white hover:border-red-800 disabled:opacity-50 disabled:cursor-not-allowed disabled:transform-none border-2 border-red-600" 
                            disabled>
                        <div class="flex items-center justify-center gap-3">
                            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path>
                            </svg>
                            <span id="proceedText">Proceed to Payment</span>
                        </div>
                    </button>

                   

                </div>
            </div>
        </div>
    </div>
</div>

<style>
.payment-option {
    border-color: #fecaca;
    transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
    cursor: pointer;
}

.payment-option.selected {
    border-color: #ef4444;
    background-color: #fef2f2;
    transform: translateY(-2px);
    border-width: 2px;
}

.payment-option:hover:not(.selected) {
    transform: translateY(-1px);
}

.error-text {
    color: #ef4444;
    font-size: 0.875rem;
    margin-top: 0.25rem;
    display: block;
}
</style>

<script>
// Simple payment handling without any external dependencies
document.addEventListener('DOMContentLoaded', function() {
    console.log('=== Payment Script Loaded ===');
    console.log('Seats:', '<%= selectedSeats %>');
    console.log('Number of seats:', <%= seatIds.length %>);
    
    const paymentOptions = document.querySelectorAll('.payment-option');
    const proceedBtn = document.getElementById('proceedToPaymentBtn');
    const proceedText = document.getElementById('proceedText');
    const selectedPaymentInput = document.getElementById('selectedPaymentMethodInput');
    const paymentForm = document.getElementById('paymentForm');
    const cashForm = document.getElementById('cashForm');
    const paymentError = document.getElementById('paymentError');

    // Auto-select first payment method
    if (paymentOptions.length > 0) {
        const firstOption = paymentOptions[0];
        const firstInput = firstOption.querySelector('input');
        firstOption.classList.add('selected');
        firstInput.checked = true;
        selectedPaymentInput.value = firstInput.value;
        proceedBtn.disabled = false;
        console.log('Auto-selected payment:', firstInput.value);
    }

    // Payment selection
    paymentOptions.forEach(option => {
        option.addEventListener('click', function() {
            const input = this.querySelector('input');
            console.log('Payment selected:', input.value);
            
            // Remove selected class from all options
            paymentOptions.forEach(opt => opt.classList.remove('selected'));
            
            // Add selected class to clicked option
            this.classList.add('selected');
            input.checked = true;
            selectedPaymentInput.value = input.value;
            proceedBtn.disabled = false;
            paymentError.style.display = 'none';
            
            // Update button text
            if (input.value === 'cash') {
                proceedText.textContent = 'Confirm Booking';
            } else {
                proceedText.textContent = 'Proceed to Payment';
            }
        });
    });

    // Proceed to payment
    proceedBtn.addEventListener('click', function() {
        console.log('Proceed button clicked');
        
        if (!selectedPaymentInput.value) {
            console.log('No payment method selected');
            paymentError.style.display = 'block';
            return;
        }

        console.log('Processing payment:', selectedPaymentInput.value);
        
        if (selectedPaymentInput.value === 'cash') {
            cashForm.submit();
        } else {
            paymentForm.submit();
        }
    });

    console.log('Payment system ready');
});
</script>

<jsp:include page="layout/footer.jsp"/>
<jsp:include page="layout/JSPFooter.jsp"/>