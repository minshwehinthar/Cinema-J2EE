<%@ page import="java.util.List" %>
<%@ page import="com.demo.model.CartItem" %>
<%@ page import="com.demo.model.Theater" %>
<%@ page import="com.demo.model.User" %>
<%@ page import="com.demo.model.Booking" %>
<%@ page import="com.demo.dao.BookingDao" %>
<%@ page import="com.demo.dao.TheaterDAO" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    List<CartItem> cartItems = (List<CartItem>) request.getAttribute("cartItems");
    List<Theater> theaters = (List<Theater>) request.getAttribute("theaters");

    if (cartItems == null) cartItems = new java.util.ArrayList<>();
    if (theaters == null) theaters = new java.util.ArrayList<>();

    double totalAmount = cartItems.stream()
                                  .mapToDouble(c -> c.getFood().getPrice() * c.getQuantity())
                                  .sum();

    // Get user's active booking and corresponding theater
    Booking activeBooking = null;
    Theater userTheater = null;
    try {
        BookingDao bookingDao = new BookingDao();
        List<Booking> userBookings = bookingDao.getBookingsByUserId(user.getUserId());
        
        // Find the first active booking (not cancelled)
        activeBooking = userBookings.stream()
            .filter(booking -> booking != null && !"cancelled".equalsIgnoreCase(booking.getStatus()))
            .findFirst()
            .orElse(null);
            
        if (activeBooking != null) {
            TheaterDAO theaterDAO = new TheaterDAO();
            if (activeBooking.getBookingId() > 0) {
                userTheater = theaterDAO.getTheaterById(activeBooking.getBookingId());
            }
            if (userTheater == null && !theaters.isEmpty()) {
                userTheater = theaters.get(0);
            }
        }
    } catch (Exception e) {
        e.printStackTrace();
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Checkout - Movie Booking System</title>
<script src="https://cdn.tailwindcss.com"></script>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
<style>
    @import url('https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap');
    
    body {
        font-family: 'Inter', sans-serif;
        background: #fefafa;
        min-height: 100vh;
    }
    
    input { 
        border: 1px solid #e5e7eb; 
        transition: all 0.2s ease;
    }
    input:focus { 
        border-color: #dc2626; 
        outline: none; 
        box-shadow: 0 0 0 3px rgba(220, 38, 38, 0.1); 
    }
    .error-text { 
        display: none; 
        color: #dc2626; 
        font-size: 0.875rem; 
        margin-top: 0.25rem; 
    }

    .payment-option { 
        border: 1.5px solid #e5e7eb; 
        transition: all 0.2s ease; 
        cursor: pointer; 
        border-radius: 0.75rem;
        background: white;
    }
    .payment-option.selected { 
        border-color: #dc2626; 
        background: #fef2f2;
        box-shadow: 0 2px 8px rgba(220, 38, 38, 0.1); 
    }

    .theater-card {
        transition: all 0.2s ease;
        border: 1.5px solid transparent;
        background: white;
    }
    .theater-card:hover {
        border-color: #fecaca;
    }
    .theater-card.selected {
        border-color: #dc2626;
        background: #fef2f2;
    }

    .loading-spinner {
        display: none;
    }

    .section-card {
        background: white;
        border-radius: 0.75rem;
        box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
        border: 1px solid #f0f0f0;
    }

    .payment-icon {
        width: 32px;
        height: 32px;
        object-fit: contain;
        border-radius: 6px;
    }
</style>
</head>
<body class="min-h-screen font-sans flex flex-col bg-gray-50">

<!-- Header -->
<jsp:include page="layout/header.jsp"/>

<div class="container mx-auto py-8 px-4 flex-grow max-w-6xl">
    <!-- Progress Steps -->
    <div class="flex justify-center mb-8">
        <div class="flex items-center space-x-4">
            <div class="flex items-center">
                <div class="w-8 h-8 rounded-full bg-green-500 flex items-center justify-center">
                    <i class="fas fa-shopping-cart text-white"></i>
                </div>
                <span class="ml-2 font-medium text-gray-700">Cart</span>
            </div>
            <div class="w-8 h-0.5 bg-green-500"></div>
            <div class="flex items-center">
                <div class="w-8 h-8 rounded-full bg-red-600 text-white flex items-center justify-center">
                    <i class="fas fa-credit-card"></i>
                </div>
                <span class="ml-2 font-medium text-gray-900">Checkout</span>
            </div>
            <div class="w-8 h-0.5 bg-gray-300"></div>
            <div class="flex items-center">
                <div class="w-8 h-8 rounded-full bg-gray-300 flex items-center justify-center">
                    <i class="fas fa-check text-gray-500"></i>
                </div>
                <span class="ml-2 font-medium text-gray-500">Confirmation</span>
            </div>
        </div>
    </div>

    <!-- Main Content -->
    <div class="grid grid-cols-1 lg:grid-cols-3 gap-6 items-start">
        <!-- Checkout Form -->
        <div class="lg:col-span-2 space-y-6">
            <!-- Booking Info Card -->
            <% if (activeBooking != null && userTheater != null) { %>
            <div class="section-card p-4 border-l-4 border-l-green-500">
                <div class="flex items-center justify-between">
                    <div class="flex items-center space-x-2">
                        <div class="w-8 h-8 bg-green-100 rounded-lg flex items-center justify-center">
                            <i class="fas fa-ticket-alt text-green-600"></i>
                        </div>
                        <div>
                            <h3 class="font-semibold text-gray-900">Active Booking</h3>
                            <p class="text-gray-600">Food delivery to your theater</p>
                        </div>
                    </div>
                    <span class="px-2 py-1 bg-green-100 text-green-800 rounded-full font-medium">
                        Confirmed
                    </span>
                </div>
                <div class="mt-2 p-2 bg-gray-50 rounded">
                    <div class="grid grid-cols-2 gap-2">
                        <div>
                            <span class="text-gray-500">Booking ID:</span>
                            <p class="font-semibold">#<%= activeBooking.getBookingId() %></p>
                        </div>
                        <div>
                            <span class="text-gray-500">Theater:</span>
                            <p class="font-semibold"><%= userTheater.getName() %></p>
                        </div>
                    </div>
                </div>
            </div>
            <% } %>

            <!-- Checkout Form -->
            <div class="section-card p-6">
                <h2 class="text-xl font-bold mb-4 text-gray-900">Checkout Details</h2>
                
                <form id="checkoutForm" action="checkout" method="post" class="space-y-6" novalidate>

                    <!-- Personal Information -->
                    <div>
                        <h3 class="text-lg font-semibold mb-3 text-gray-900">Personal Information</h3>
                        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                            <div>
                                <label for="name" class="block font-medium mb-2 text-gray-700">Full Name</label>
                                <input type="text" name="name" id="name" value="<%=user.getName()%>" 
                                       placeholder="Enter your full name"
                                       class="border px-4 py-3 w-full rounded-lg focus:border-red-500" required>
                                <span class="error-text">Please enter your full name</span>
                            </div>
                            <div>
                                <label for="email" class="block font-medium mb-2 text-gray-700">Email Address</label>
                                <input type="email" name="email" id="email" value="<%=user.getEmail()%>" 
                                       placeholder="e.g. john@example.com"
                                       class="border px-4 py-3 w-full rounded-lg focus:border-red-500" required>
                                <span class="error-text">Please enter a valid email address</span>
                            </div>
                        </div>

                        <div class="mt-4">
                            <label for="phone" class="block font-medium mb-2 text-gray-700">Phone Number</label>
                            <input type="tel" name="phone" id="phone" value="<%=user.getPhone()%>" 
                                   placeholder="e.g. +959123456789 or 09123456789"
                                   class="border px-4 py-3 w-full rounded-lg focus:border-red-500" required>
                            <span class="error-text">Please enter a valid Myanmar phone number</span>
                        </div>
                    </div>

                    <!-- Theater Selection -->
                    <div>
                        <h3 class="text-lg font-semibold mb-3 text-gray-900">Theater Selection</h3>
                        
                        <!-- Auto-selected Theater Card -->
                        <% if (activeBooking != null && userTheater != null) { %>
                        <div class="theater-card selected p-4 rounded-lg">
                            <div class="flex items-center justify-between">
                                <div class="flex items-center space-x-3">
                                    <div class="w-8 h-8 bg-red-100 rounded-lg flex items-center justify-center">
                                        <i class="fas fa-film text-red-600"></i>
                                    </div>
                                    <div>
                                        <h4 class="font-semibold text-gray-900"><%= userTheater.getName() %></h4>
                                        <p class="text-gray-600"><%= userTheater.getLocation() %></p>
                                        <p class="text-green-600 font-medium mt-1">
                                            <i class="fas fa-check-circle mr-1"></i>
                                            Auto-selected based on your booking
                                        </p>
                                    </div>
                                </div>
                                <i class="fas fa-check-circle text-red-500"></i>
                            </div>
                        </div>
                        <input type="hidden" name="theaterId" id="theaterIdInput" value="<%= userTheater.getTheaterId() %>" required>
                        
                        <% } else { %>
                        <!-- Manual Theater Selection -->
                        <div class="grid grid-cols-1 md:grid-cols-2 gap-3">
                            <% for(Theater t : theaters) { %>
                                <div class="theater-card p-4 border rounded-lg cursor-pointer"
                                     data-theater-id="<%=t.getTheaterId()%>"
                                     data-theater-name="<%=t.getName()%>"
                                     data-theater-location="<%=t.getLocation()%>">
                                    <div class="flex items-start justify-between">
                                        <div class="flex-1">
                                            <h4 class="font-semibold text-gray-900"><%=t.getName()%></h4>
                                            <p class="text-gray-600 mt-1"><%=t.getLocation()%></p>
                                        </div>
                                    </div>
                                </div>
                            <% } %>
                        </div>
                        <input type="hidden" name="theaterId" id="theaterIdInput" value="" required>
                        <span class="error-text mt-1">Please select a theater for your order</span>
                        <% } %>
                    </div>

                    <!-- Payment Method -->
                    <div>
                        <h3 class="text-lg font-semibold mb-3 text-gray-900">Payment Method</h3>
                        <span id="paymentError" class="error-text mb-2 block">Please select a payment method</span>
                        
                        <div class="grid grid-cols-3 gap-3">
                            <!-- Cash Payment -->
                            <label class="payment-option flex flex-col items-center p-4 border rounded-lg cursor-pointer">
                                <input type="radio" name="paymentMethod" value="cash" class="hidden" required>
                                <img src="assets/img/cash.png" alt="KBZ Pay" class="payment-icon mb-2">
                                <span class="text-gray-700 font-medium text-center">Cash</span>
                                <span class="text-gray-500 mt-1 text-center">Pay at theater</span>
                            </label>
                            
                            <!-- KBZ Pay -->
                            <label class="payment-option flex flex-col items-center p-4 border rounded-lg cursor-pointer">
                                <input type="radio" name="paymentMethod" value="kbz" class="hidden">
                                <img src="assets/img/kpay.png" alt="KBZ Pay" class="payment-icon mb-2">
                                <span class="text-gray-700 font-medium text-center">KBZ Pay</span>
                                <span class="text-gray-500 mt-1 text-center">Mobile Banking</span>
                            </label>
                            
                            <!-- Wave Pay -->
                            <label class="payment-option flex flex-col items-center p-4 border rounded-lg cursor-pointer">
                                <input type="radio" name="paymentMethod" value="wave" class="hidden">
                                <img src="assets/img/wavepay.jpeg" alt="Wave Pay" class="payment-icon mb-2">
                                <span class="text-gray-700 font-medium text-center">Wave Pay</span>
                                <span class="text-gray-500 mt-1 text-center">Digital Wallet</span>
                            </label>
                        </div>
                    </div>

                    <!-- Submit Button -->
                    <button type="submit" id="submitBtn"
                            class="w-full bg-red-600 hover:bg-red-700 text-white py-4 rounded-lg font-semibold transition-all duration-200 flex items-center justify-center mt-6">
                        <i class="fas fa-shopping-bag mr-2"></i>
                        Complete Order - <%= String.format("%.2f", totalAmount) %> MMK
                        <div class="loading-spinner ml-2">
                            <i class="fas fa-spinner fa-spin"></i>
                        </div>
                    </button>

                    
                </form>
            </div>
        </div>

        <!-- Order Summary Sidebar -->
        <div class="lg:col-span-1">
            <div class="sticky top-4 space-y-4">
                <!-- Order Summary -->
                <div class="section-card p-4">
                    <h2 class="text-lg font-bold mb-3 text-gray-900">Order Summary</h2>
                    
                    <% if(cartItems.isEmpty()) { %>
                        <div class="text-center py-4">
                            <i class="fas fa-shopping-cart text-gray-300 text-2xl mb-2"></i>
                            <p class="text-gray-500">Your cart is empty</p>
                        </div>
                    <% } else { %>
                        <div class="space-y-3 max-h-64 overflow-y-auto pr-2">
                            <% for(CartItem c : cartItems) { %>
                                <div class="flex items-center justify-between border-b border-gray-100 pb-2">
                                    <div class="flex items-center gap-2 flex-1">
                                        <img src="<%= c.getFood().getImage() %>" 
                                             alt="<%= c.getFood().getName() %>" 
                                             class="w-10 h-10 rounded object-cover">
                                        <div class="flex-1 min-w-0">
                                            <h4 class="font-semibold text-gray-900"><%= c.getFood().getName() %></h4>
                                            <p class="text-gray-500">Qty: <%= c.getQuantity() %></p>
                                        </div>
                                    </div>
                                    <span class="font-semibold text-gray-900 whitespace-nowrap ml-2">
                                        <%= String.format("%.2f", c.getFood().getPrice() * c.getQuantity()) %> MMK
                                    </span>
                                </div>
                            <% } %>
                        </div>
                        
                        <div class="mt-4 space-y-2 pt-3 border-t border-gray-200">
                            <div class="flex justify-between items-center text-gray-600">
                                <span>Subtotal:</span>
                                <span><%= String.format("%.2f", totalAmount) %> MMK</span>
                            </div>
                            <div class="flex justify-between items-center text-gray-600">
                                <span>Service Fee:</span>
                                <span>200 MMK</span>
                            </div>
                            <div class="flex justify-between items-center font-bold text-gray-900 pt-2 border-t border-gray-200">
                                <span>Total:</span>
                                <span class="text-red-600"><%= String.format("%.2f", totalAmount + 2.00) %> MMK</span>
                            </div>
                        </div>
                    <% } %>
                </div>

                <!-- Order Information -->
                <div class="section-card p-4">
                    <h2 class="text-lg font-bold mb-3 text-gray-900">Order Information</h2>
                    <ul class="space-y-2 text-gray-700">
                        <li class="flex items-start">
                            <i class="fas fa-check-circle text-green-500 mt-0.5 mr-2 flex-shrink-0"></i>
                            <span>Food delivered to your seat before movie starts</span>
                        </li>
                        <li class="flex items-start">
                            <i class="fas fa-check-circle text-green-500 mt-0.5 mr-2 flex-shrink-0"></i>
                            <span>Orders confirmed 2 hours before showtime</span>
                        </li>
                        <li class="flex items-start">
                            <i class="fas fa-check-circle text-green-500 mt-0.5 mr-2 flex-shrink-0"></i>
                            <span>Present booking confirmation at theater</span>
                        </li>
                    </ul>
                    
                    <!-- Support Info -->
                    <div class="mt-4 p-3 bg-red-50 rounded">
                        <div class="flex items-center">
                            <i class="fas fa-headset text-red-500 mr-2"></i>
                            <div>
                                <h4 class="font-semibold text-gray-900">Need Help?</h4>
                                <p class="text-gray-600">+95 9 123 456 789</p>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Footer -->
<jsp:include page="layout/footer.jsp"/>

<script>
document.addEventListener('DOMContentLoaded', () => {
    // Theater selection (only if no active booking)
    <% if (activeBooking == null || userTheater == null) { %>
        const theaterCards = document.querySelectorAll('.theater-card');
        const theaterIdInput = document.getElementById('theaterIdInput');
        theaterCards.forEach(card => {
            card.addEventListener('click', () => {
                theaterCards.forEach(c => c.classList.remove('selected'));
                card.classList.add('selected');
                theaterIdInput.value = card.dataset.theaterId;
                theaterIdInput.nextElementSibling.style.display = 'none';
            });
        });
    <% } %>

    // Payment selection
    const paymentOptions = document.querySelectorAll('.payment-option');
    const paymentError = document.getElementById('paymentError');

    paymentOptions.forEach(option => {
        const input = option.querySelector('input');
        option.addEventListener('click', () => {
            paymentOptions.forEach(o => o.classList.remove('selected'));
            option.classList.add('selected');
            input.checked = true;
            paymentError.style.display = 'none';
        });
    });

    // Form validation and submission
    const form = document.getElementById('checkoutForm');
    const submitBtn = document.getElementById('submitBtn');
    const loadingSpinner = submitBtn.querySelector('.loading-spinner');

    form.addEventListener('submit', function(e) {
        e.preventDefault();
        
        let isValid = true;
        document.querySelectorAll('.error-text').forEach(span => span.style.display = 'none');

        // Name validation
        const name = document.getElementById('name');
        if (name.value.trim() === '') {
            name.nextElementSibling.style.display = 'block';
            isValid = false;
        }

        // Email validation
        const email = document.getElementById('email');
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        if (!emailRegex.test(email.value.trim())) {
            email.nextElementSibling.style.display = 'block';
            isValid = false;
        }

        // Phone validation (Myanmar numbers)
        const phone = document.getElementById('phone');
        const phoneRegex = /^(\+?95|0)9\d{7,9}$/;
        if (!phoneRegex.test(phone.value.trim().replace(/\s+/g, ''))) {
            phone.nextElementSibling.style.display = 'block';
            isValid = false;
        }

        // Theater validation (only if no active booking)
        <% if (activeBooking == null || userTheater == null) { %>
            if (theaterIdInput.value.trim() === '') {
                theaterIdInput.nextElementSibling.style.display = 'block';
                isValid = false;
            }
        <% } %>

        // Payment method validation
        const paymentSelected = Array.from(document.querySelectorAll('input[name="paymentMethod"]')).some(input => input.checked);
        if (!paymentSelected) {
            paymentError.style.display = 'block';
            isValid = false;
        }

        if (isValid) {
            submitBtn.disabled = true;
            loadingSpinner.style.display = 'inline-block';
            submitBtn.querySelector('i').style.display = 'none';
            
            setTimeout(() => {
                form.submit();
            }, 1000);
        } else {
            const firstError = document.querySelector('.error-text[style*="display: block"]');
            if (firstError) {
                firstError.scrollIntoView({ behavior: 'smooth', block: 'center' });
            }
        }
    });

    // Real-time validation
    document.querySelectorAll('input').forEach(input => {
        input.addEventListener('input', function() {
            const errorSpan = this.nextElementSibling;
            if (errorSpan && errorSpan.classList.contains('error-text')) {
                errorSpan.style.display = 'none';
            }
        });
    });

    // Auto-format phone number
    document.getElementById('phone').addEventListener('input', function(e) {
        let value = e.target.value.replace(/\D/g, '');
        if (value.startsWith('95')) {
            value = '+' + value;
        } else if (value.startsWith('09')) {
            value = value;
        }
        e.target.value = value;
    });
});
</script>

</body>
</html>