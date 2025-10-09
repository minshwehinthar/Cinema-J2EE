<%@ page import="java.util.List"%>
<%@ page import="com.demo.model.CartItem"%>
<%@ page import="com.demo.model.User"%>
<%@ page import="com.demo.model.Booking"%>
<%@ page import="com.demo.dao.BookingDao"%>
<%
User user = (User) session.getAttribute("user");
List<CartItem> cartItems = (List<CartItem>) request.getAttribute("cartItems");
double totalAmount = (request.getAttribute("totalAmount") != null)
    ? (Double) request.getAttribute("totalAmount") : 0.0;

int totalQuantity = 0;
if(cartItems != null){
    for(CartItem c : cartItems){
        totalQuantity += c.getQuantity();
    }
}

// Check if user has active booking
boolean hasActiveBooking = false;
try {
    if (user != null) {
        BookingDao bookingDao = new BookingDao();
        List<Booking> userBookings = bookingDao.getBookingsByUserId(user.getUserId());
        
        // Find the first active booking (not cancelled)
        Booking activeBooking = userBookings.stream()
            .filter(booking -> booking != null && !"cancelled".equalsIgnoreCase(booking.getStatus()))
            .findFirst()
            .orElse(null);
            
        hasActiveBooking = (activeBooking != null);
    }
} catch (Exception e) {
    e.printStackTrace();
}
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>My Cart - Food Ordering</title>
<script src="https://cdn.tailwindcss.com"></script>
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
<style>
    @import url('https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap');
    
    body {
        font-family: 'Inter', sans-serif;
    }
    
    .cart-item {
        transition: all 0.2s ease;
    }
    
    .quantity-btn {
        transition: all 0.15s ease;
    }
    
    .empty-cart-illustration {
        background: linear-gradient(135deg, #fef2f2 0%, #fecaca 100%);
    }
    
    .checkout-disabled {
        opacity: 0.7;
        cursor: not-allowed;
    }
    
    .checkout-disabled:hover {
        transform: none !important;
        box-shadow: none !important;
    }
    
    .booking-required {
        background: linear-gradient(135deg, #fef2f2 0%, #fed7d7 100%);
        border: 1px solid #fecaca;
    }
</style>
</head>
<body class="bg-white font-sans min-h-screen flex flex-col">

  <!-- Header -->
  <jsp:include page="layout/header.jsp"/>

  <!-- Main Content -->
  <main class="flex-grow max-w-6xl mx-auto py-8 px-4 sm:px-6 lg:px-8 w-full">
    <!-- Page Header -->
    <div class="text-center mb-12">
      <h1 class="text-3xl font-bold text-gray-900 mb-2">Your Cart</h1>
      <p class="text-gray-500">Review your items before checkout</p>
    </div>

    <div class="grid grid-cols-1 lg:grid-cols-3 gap-8 items-start">
      <!-- Cart Items Section -->
      <div class="lg:col-span-2">
        <!-- Cart Header -->
        <div class="flex items-center justify-between mb-6">
          <h2 class="text-xl font-semibold text-gray-900">
            Cart Items <span class="text-gray-500 font-normal">(<%= (cartItems != null) ? cartItems.size() : 0 %>)</span>
          </h2>
          <span class="px-3 py-1 bg-red-100 text-red-700 rounded-full text-sm font-medium">
            <%= totalQuantity %> items
          </span>
        </div>

        <!-- Cart Items -->
        <div class="space-y-4">
          <% if(cartItems == null || cartItems.isEmpty()){ %>
            <!-- Empty Cart State -->
            <div class="text-center py-16 px-6">
              <div class="max-w-sm mx-auto">
                <div class="empty-cart-illustration w-32 h-32 mx-auto mb-6 rounded-full flex items-center justify-center">
                  <svg class="w-16 h-16 text-red-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M3 3h2l.4 2M7 13h10l4-8H5.4M7 13L5.4 5M7 13l-2.293 2.293c-.63.63-.184 1.707.707 1.707H17m0 0a2 2 0 100 4 2 2 0 000-4zm-8 2a2 2 0 11-4 0 2 2 0 014 0z"></path>
                  </svg>
                </div>
                <h3 class="text-xl font-semibold text-gray-900 mb-2">Your cart is empty</h3>
                <p class="text-gray-500 mb-6">Add some delicious items to get started</p>
                <a href="foods.jsp" class="inline-flex items-center px-5 py-3 bg-red-600 hover:bg-red-700 text-white font-medium rounded-lg transition-colors shadow-lg hover:shadow-xl transform hover:scale-105 transition-all">
                  <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6"></path>
                  </svg>
                  Browse Menu
                </a>
              </div>
            </div>
          <% } else { 
                 for(CartItem c : cartItems) {
                   double lineTotal = c.getQuantity() * c.getFood().getPrice();
            %>
              <!-- Cart Item -->
              <div class="cart-item bg-white rounded-xl p-6 border border-gray-200 hover:border-red-300 transition-all shadow-sm hover:shadow-md">
                <div class="flex items-start gap-4">
                  <!-- Product Image -->
                  <div class="flex-shrink-0">
                    <img src="<%=c.getFood().getImage()%>" alt="<%=c.getFood().getName()%>" 
                         class="w-20 h-20 object-cover rounded-lg bg-gray-100">
                  </div>
                  
                  <!-- Product Details -->
                  <div class="flex-grow min-w-0">
                    <div class="flex items-start justify-between mb-3">
                      <div class="min-w-0 flex-1">
                        <h3 class="font-semibold text-gray-900 text-lg truncate"><%=c.getFood().getName()%></h3>
                        <p class="text-red-600 font-medium mt-1"><%=c.getFood().getPrice() %> MMK</p>
                      </div>
                      <div class="text-right ml-4">
                        <p class="text-lg font-semibold text-gray-900"><%=String.format("%.2f", lineTotal)%> MMK</p>
                      </div>
                    </div>
                    
                    <!-- Quantity Controls -->
                    <div class="flex items-center justify-between">
                      <form action="cart" method="get" class="flex items-center gap-2">
                        <input type="hidden" name="action" value="update">
                        <input type="hidden" name="cartId" value="<%=c.getId()%>">
                        <button type="submit" name="quantity" value="<%=c.getQuantity()-1%>" 
                                class="quantity-btn w-8 h-8 flex items-center justify-center bg-red-100 hover:bg-red-600 hover:text-white rounded-lg font-medium transition-colors">
                          -
                        </button>
                        <span class="w-8 text-center px-2 py-1 text-gray-700 font-medium">
                          <%=c.getQuantity()%>
                        </span>
                        <button type="submit" name="quantity" value="<%=c.getQuantity()+1%>" 
                                class="quantity-btn w-8 h-8 flex items-center justify-center bg-red-100 hover:bg-red-600 hover:text-white rounded-lg font-medium transition-colors">
                          +
                        </button>
                      </form>
                      
                      <!-- Remove Button -->
                      <a href="cart?action=remove&cartId=<%=c.getId()%>" 
                         class="flex items-center gap-1 text-gray-500 hover:text-red-600 font-medium transition-colors text-sm">
                        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"></path>
                        </svg>
                        Remove
                      </a>
                    </div>
                  </div>
                </div>
              </div>
            <% } } %>
          </div>
        </div>

      <!-- Order Summary -->
      <div class="lg:col-span-1">
        <div class="bg-white rounded-xl border border-gray-200 sticky top-6 shadow-lg">
          <!-- Summary Header -->
          <div class="px-6 py-4 border-b border-gray-200 bg-red-50 rounded-t-xl">
            <h2 class="text-lg font-semibold text-gray-900">Order Summary</h2>
          </div>
          
          <!-- Summary Content -->
          <div class="p-6">
            <!-- Summary Items -->
            <div class="space-y-3 mb-6">
              <div class="flex justify-between items-center">
                <span class="text-gray-600">Items:</span>
                <span class="font-medium text-gray-900"><%= (cartItems != null) ? cartItems.size() : 0 %></span>
              </div>
              
              <div class="flex justify-between items-center">
                <span class="text-gray-600">Quantity:</span>
                <span class="font-medium text-gray-900"><%= totalQuantity %></span>
              </div>
              
              <div class="flex justify-between items-center">
                <span class="text-gray-600">Subtotal:</span>
                <span class="font-medium text-gray-900"><%=String.format("%.2f", totalAmount)%> MMK</span>
              </div>
              
              <div class="flex justify-between items-center">
                <span class="text-gray-600">Shipping:</span>
                <span class="font-medium text-red-600">FREE</span>
              </div>
            </div>
            
            <!-- Divider -->
            <div class="border-t border-gray-200 my-4"></div>
            
            <!-- Total -->
            <div class="flex justify-between items-center mb-6">
              <span class="text-lg font-semibold text-gray-900">Total:</span>
              <span class="text-xl font-bold text-red-600"><%=String.format("%.2f", totalAmount)%> MMK</span>
            </div>
            
            <!-- Checkout Button -->
            <% if(cartItems != null && !cartItems.isEmpty()) { %>
              <% if(hasActiveBooking) { %>
                <!-- Checkout enabled for users with active booking -->
                <a href="checkout" 
                   class="w-full bg-red-600 hover:bg-red-700 text-white text-center font-semibold py-3 px-6 rounded-lg transition-colors block mb-3 transform hover:scale-[1.02] transition-transform shadow-lg hover:shadow-xl">
                  Proceed to Checkout
                </a>
              <% } else { %>
                <!-- Checkout disabled for users without active booking -->
                <button id="checkoutBtnDisabled"
                   class="w-full bg-red-400 text-white text-center font-semibold py-3 px-6 rounded-lg block mb-3 checkout-disabled cursor-not-allowed shadow-md">
                  <div class="flex items-center justify-center">
                    <i class="fas fa-lock mr-2"></i>
                    Checkout Locked
                  </div>
                </button>
                
                <!-- Booking Required Notice -->
                <div class="booking-required rounded-lg p-4 mb-4 text-center">
                  <div class="flex items-center justify-center mb-2">
                    <i class="fas fa-ticket-alt text-red-500 mr-2"></i>
                    <span class="text-red-700 font-medium">Movie Booking Required</span>
                  </div>
                  <p class="text-red-600 text-sm">Book a movie first to proceed with checkout</p>
                </div>
              <% } %>
            <% } %>
            
            <!-- Continue Shopping -->
            <a href="foods.jsp" class="block text-center text-gray-600 hover:text-red-600 font-medium transition-colors text-sm mb-4">
              <i class="fas fa-arrow-left mr-2"></i>Continue Shopping
            </a>
            
            <!-- Book Movie Button (shown when no active booking) -->
            <% if(!hasActiveBooking && (cartItems != null && !cartItems.isEmpty())) { %>
            <div class="mt-4 pt-4 border-t border-gray-200">
              <a href="movies.jsp" 
                 class="w-full bg-red-500 hover:bg-red-600 text-white text-center font-medium py-3 px-6 rounded-lg transition-colors block transform hover:scale-[1.02] transition-transform shadow-lg hover:shadow-xl">
                <div class="flex items-center justify-center">
                  <i class="fas fa-film mr-2"></i>
                  Book a Movie First
                </div>
              </a>
            </div>
            <% } %>
          </div>
        </div>
      </div>
    </div>
  </main>

  <!-- Footer -->
  <jsp:include page="layout/footer.jsp"/>

  <script>
  document.addEventListener('DOMContentLoaded', function() {
      // Checkout button click handler for users without active booking
      const checkoutBtnDisabled = document.getElementById('checkoutBtnDisabled');
      if (checkoutBtnDisabled) {
          checkoutBtnDisabled.addEventListener('click', function(e) {
              e.preventDefault();
              
              Swal.fire({
                  icon: 'info',
                  title: 'Movie Booking Required',
                  html: `
                      <div class="text-center">
                          
                          
                          <p class="text-gray-600 mb-4">
                              To complete your food order, you need to have a movie booking. 
                              This ensures your food is ready when you arrive for your movie experience.
                          </p>
                      </div>
                  `,
                  showCancelButton: true,
                  confirmButtonText: 'Book a Movie',
                  cancelButtonText: 'View My Bookings',
                  confirmButtonColor: '#dc2626',
                  cancelButtonColor: '#6b7280',
                  focusConfirm: false,
                  customClass: {
                      popup: 'rounded-2xl',
                      confirmButton: 'px-6 py-2 rounded-lg',
                      cancelButton: 'px-6 py-2 rounded-lg'
                  }
              }).then((result) => {
                  if (result.isConfirmed) {
                      // Redirect to movies page
                      window.location.href = 'movies.jsp';
                  } else if (result.dismiss === Swal.DismissReason.cancel) {
                      // Redirect to bookings page
                      window.location.href = 'myBookings.jsp';
                  }
              });
          });
      }
      
      // Also handle the case where someone might try to access checkout URL directly
      const checkoutLinks = document.querySelectorAll('a[href="checkout"]');
      checkoutLinks.forEach(link => {
          link.addEventListener('click', function(e) {
              // If for some reason the user doesn't have active booking but the link is enabled
              const hasActiveBooking = <%= hasActiveBooking %>;
              if (!hasActiveBooking) {
                  e.preventDefault();
                  
                  Swal.fire({
                      icon: 'warning',
                      title: 'Booking Required',
                      html: `
                          <div class="text-center">
                              <div class="w-16 h-16 bg-red-100 rounded-full flex items-center justify-center mx-auto mb-4">
                                  <i class="fas fa-exclamation-triangle text-red-500 text-2xl"></i>
                              </div>
                              <p class="text-gray-600 mb-4">
                                  You need a movie booking to access the checkout page.
                              </p>
                          </div>
                      `,
                      confirmButtonText: 'Book a Movie',
                      confirmButtonColor: '#dc2626',
                      customClass: {
                          popup: 'rounded-2xl',
                          confirmButton: 'px-6 py-2 rounded-lg'
                      }
                  }).then((result) => {
                      if (result.isConfirmed) {
                          window.location.href = 'movies.jsp';
                      }
                  });
              }
          });
      });
  });
  </script>

</body>
</html>