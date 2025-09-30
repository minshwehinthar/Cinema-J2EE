<%@ page import="java.util.List" %>
<%@ page import="com.demo.model.CartItem" %>
<%@ page import="com.demo.model.Theater" %>
<%@ page import="com.demo.model.User" %>
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
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Checkout</title>
<script src="https://cdn.tailwindcss.com"></script>
<style>
input { border-color: #d1d5db; }
input:focus { border-color: #3b82f6; outline: none; box-shadow: 0 0 4px rgba(59,130,246,0.5); }
.error-text { display: none; color: #ef4444; font-size: 0.875rem; margin-top: 0.25rem; }

.payment-option { border-color: #d1d5db; transition: all 0.2s; cursor: pointer; }
.payment-option img { transition: transform 0.2s; }
.payment-option.selected { border-color: #3b82f6; box-shadow: 0 0 8px rgba(59,130,246,0.5); transform: scale(1.05); }
.payment-option:hover { transform: scale(1.03); }

.dropdown { position: relative; }
.dropdown-btn { cursor: pointer; }
.dropdown-list { display: none; position: absolute; top: 100%; left: 0; right: 0; z-index: 10; max-height: 200px; overflow-y: auto; background: white; border: 1px solid #d1d5db; border-radius: 0.5rem; box-shadow: 0 2px 8px rgba(0,0,0,0.1); }
.dropdown-list div { padding: 0.5rem 1rem; cursor: pointer; transition: background 0.2s; }
.dropdown-list div:hover { background: #f3f4f6; }
</style>
</head>
<body class="bg-gray-50 min-h-screen font-sans flex flex-col">

<!-- Header -->
<jsp:include page="layout/header.jsp"/>

<div class="container mx-auto py-12 px-4 flex-grow">
    <h1 class="text-4xl font-bold text-center mb-12 text-gray-800">Checkout</h1>
    <div class="grid grid-cols-1 md:grid-cols-5 gap-6 items-start">

        <!-- Checkout Form -->
        <div class="md:col-span-3 bg-white rounded-2xl p-6 shadow-md w-full mx-auto">
            <form id="checkoutForm" action="checkout" method="post" class="space-y-5" novalidate>

                <!-- Name & Email -->
                <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <div>
                        <label for="name" class="block font-medium mb-1 text-gray-700">Name</label>
                        <input type="text" name="name" id="name" value="<%=user.getName()%>" 
                               placeholder="Enter your full name"
                               class="border px-3 py-2 w-full rounded-lg" required>
                        <span class="error-text">Name is required.</span>
                    </div>
                    <div>
                        <label for="email" class="block font-medium mb-1 text-gray-700">Email</label>
                        <input type="email" name="email" id="email" value="<%=user.getEmail()%>" 
                               placeholder="e.g. john@example.com"
                               class="border px-3 py-2 w-full rounded-lg" required>
                        <span class="error-text">Please enter a valid email.</span>
                    </div>
                </div>

                <!-- Phone -->
                <div>
                    <label for="phone" class="block font-medium mb-1 text-gray-700">Phone</label>
                    <input type="tel" name="phone" id="phone" value="<%=user.getPhone()%>" 
                           placeholder="e.g. +959123456789 or 09123456789"
                           class="border px-3 py-2 w-full rounded-lg" required>
                    <span class="error-text">Enter a valid Myanmar phone number.</span>
                </div>

                <!-- Theater Selection -->
                <div class="dropdown">
                    <label class="block font-medium mb-1 text-gray-700">Select Theater</label>
                    <div id="dropdownBtn" class="dropdown-btn border px-3 py-2 rounded-lg flex justify-between items-center">
                        <span id="selectedTheater">Choose a theater</span>
                        <svg class="w-5 h-5 text-gray-500" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" d="M19 9l-7 7-7-7"></path>
                        </svg>
                    </div>
                    <div id="dropdownList" class="dropdown-list">
                        <% for(Theater t : theaters) { %>
                            <div data-id="<%=t.getTheaterId()%>"><%=t.getName()%> - <%=t.getLocation()%></div>
                        <% } %>
                    </div>
                    <input type="hidden" name="theaterId" id="theaterIdInput" required>
                    <span class="error-text">Please select a theater.</span>
                </div>

                <!-- Payment Method -->
                <div>
                    <label class="block font-medium mb-2 text-gray-700">Payment Method</label>
                    <span id="paymentError" class="error-text">Please select a payment method.</span>
                    <div class="flex gap-3 flex-wrap mt-1">
                        <label class="payment-option flex flex-col items-center p-2 border rounded-lg w-24 cursor-pointer">
                            <input type="radio" name="paymentMethod" value="cash" class="hidden" required>
                            <img src="assets/img/cash.png" alt="Cash" class="w-12 h-12 mb-1">
                            <span class="text-gray-700 text-sm">Cash</span>
                        </label>
                        <label class="payment-option flex flex-col items-center p-2 border rounded-lg w-24 cursor-pointer">
                            <input type="radio" name="paymentMethod" value="kpz" class="hidden">
                            <img src="assets/img/kpay.png" alt="KPZ" class="w-12 h-12 mb-1">
                            <span class="text-gray-700 text-sm">KPZ</span>
                        </label>
                        <label class="payment-option flex flex-col items-center p-2 border rounded-lg w-24 cursor-pointer">
                            <input type="radio" name="paymentMethod" value="wave" class="hidden">
                            <img src="assets/img/wavepay.jpeg" alt="Wave" class="w-12 h-12 mb-1">
                            <span class="text-gray-700 text-sm">Wave</span>
                        </label>
                    </div>
                </div>

                <button type="submit" 
                        class="w-full bg-blue-600 hover:bg-blue-700 text-white py-3 rounded-lg font-semibold transition-all">
                    Place Order
                </button>
            </form>
        </div>

        <!-- Right: Order Summary + Rules -->
        <div class="md:col-span-2 flex flex-col gap-5">
            <div class="bg-white rounded-2xl p-6 max-h-[400px] overflow-y-auto shadow-md">
                <h2 class="text-2xl font-semibold mb-4 text-gray-700">Order Summary</h2>
                <% if(cartItems.isEmpty()) { %>
                    <p class="text-gray-700">Your cart is empty.</p>
                <% } else { %>
                    <ul class="space-y-4">
                        <% for(CartItem c : cartItems) { %>
                            <li class="flex items-center justify-between border-b pb-2">
                                <div class="flex items-center gap-3">
                                    <img src="<%= c.getFood().getImage() %>" alt="<%= c.getFood().getName() %>" class="w-12 h-12 rounded-lg object-cover">
                                    <span><%= c.getFood().getName() %> x <%= c.getQuantity() %></span>
                                </div>
                                <span>$<%= c.getFood().getPrice() * c.getQuantity() %></span>
                            </li>
                        <% } %>
                    </ul>
                    <div class="mt-4 text-right">
                        <p class="text-lg font-bold text-green-600">Total: $<%= totalAmount %></p>
                    </div>
                <% } %>
            </div>
            <div class="bg-white rounded-2xl p-6 shadow-md">
                <h2 class="text-xl font-semibold mb-3 text-gray-700">Company Rules</h2>
                <ul class="list-disc list-inside text-gray-700 space-y-2 text-sm">
                    <li>All orders must be confirmed before 24 hours of showtime.</li>
                    <li>No refunds are allowed after payment.</li>
                    <li>Please present a valid ID at the theater.</li>
                    <li>Food items are non-refundable and must be consumed on-site.</li>
                    <li>Company reserves the right to modify terms without prior notice.</li>
                </ul>
            </div>
        </div>
    </div>
</div>

<!-- Footer -->
<jsp:include page="layout/footer.jsp"/>

<script>
// Payment selection & custom dropdown
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

const dropdownBtn = document.getElementById('dropdownBtn');
const dropdownList = document.getElementById('dropdownList');
const selectedTheater = document.getElementById('selectedTheater');
const theaterInput = document.getElementById('theaterIdInput');

dropdownBtn.addEventListener('click', () => {
    dropdownList.style.display = dropdownList.style.display === 'block' ? 'none' : 'block';
});

dropdownList.querySelectorAll('div').forEach(item => {
    item.addEventListener('click', () => {
        selectedTheater.textContent = item.textContent;
        theaterInput.value = item.dataset.id;
        dropdownList.style.display = 'none';
        theaterInput.nextElementSibling.style.display = 'none';
    });
});

document.addEventListener('click', (e) => {
    if(!dropdownBtn.contains(e.target) && !dropdownList.contains(e.target)){
        dropdownList.style.display = 'none';
    }
});

const form = document.getElementById('checkoutForm');
form.addEventListener('submit', function(e){
    let valid = true;
    document.querySelectorAll('.error-text').forEach(span => span.style.display='none');

    if(document.getElementById('name').value.trim()===''){ document.getElementById('name').nextElementSibling.style.display='block'; valid=false; }
    if(!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(document.getElementById('email').value.trim())){ document.getElementById('email').nextElementSibling.style.display='block'; valid=false; }
    if(!/^(\+?95|0)9\d{7,9}$/.test(document.getElementById('phone').value.trim())){ document.getElementById('phone').nextElementSibling.style.display='block'; valid=false; }
    if(theaterInput.value.trim()===''){ theaterInput.nextElementSibling.style.display='block'; valid=false; }
    if(!Array.from(document.querySelectorAll('input[name="paymentMethod"]')).some(i=>i.checked)){ paymentError.style.display='block'; valid=false; }

    if(!valid){ e.preventDefault(); window.scrollTo({top:0, behavior:'smooth'});}
});
</script>

</body>
</html>
