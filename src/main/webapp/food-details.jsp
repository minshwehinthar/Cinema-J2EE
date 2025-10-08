<%@ page import="com.demo.model.FoodItem,com.demo.model.User" %>
<%@ page contentType="text/html; charset=UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Food Details</title>
  <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-gray-50 font-sans min-h-screen flex flex-col">

  <!-- Header -->
  <jsp:include page="layout/header.jsp"/>

  <!-- Main Content -->
  <main class="flex-1 flex flex-col md:flex-row items-start justify-center w-full px-4 md:px-0 py-12 gap-12 max-w-6xl mx-auto">

    <%
      FoodItem food = (FoodItem) request.getAttribute("food");
      User user = (User) session.getAttribute("user");
    %>

    <% if(food == null){ %>
      <p class="text-red-500 text-center text-xl w-full">
        Food item not found!
      </p>
    <% } else { %>

    <!-- Food Image -->
    <div class="md:w-1/2 w-full h-[400px] md:h-[500px] overflow-hidden rounded-lg bg-gray-100 flex items-center justify-center">
      <img src="<%=food.getImage()%>" 
           alt="<%=food.getName()%>" 
           class="w-full h-full object-cover">
    </div>

    <!-- Food Info -->
    <div class="md:w-1/2 flex flex-col space-y-6">

      <!-- Name & Type -->
      <div class="space-y-1">
        <span class="text-sm text-green-600 uppercase font-semibold tracking-wider">
          <%=food.getFoodType()%>
        </span>
        <h1 class="text-3xl md:text-4xl font-bold text-gray-900"><%=food.getName()%></h1>
      </div>

      <!-- Rating & Price -->
      <div class="flex items-center gap-4">
        <div class="flex items-center gap-1">
          <%
            double rating = food.getRating();
            int fullStars = (int) rating;
            boolean halfStar = (rating - fullStars) >= 0.5;
            int emptyStars = 5 - fullStars - (halfStar ? 1 : 0);
          %>
          <% for(int i=0; i<fullStars; i++) { %>
            <svg class="w-5 h-5 text-yellow-400" fill="currentColor" viewBox="0 0 20 20">
              <path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.286 3.957a1 1 0 00.95.69h4.162c.969 0 1.371 1.24.588 1.81l-3.37 2.448a1 1 0 00-.364 1.118l1.287 3.957c.3.921-.755 1.688-1.54 1.118l-3.37-2.448a1 1 0 00-1.176 0l-3.37 2.448c-.784.57-1.838-.197-1.539-1.118l1.286-3.957a1 1 0 00-.364-1.118L2.034 9.384c-.783-.57-.38-1.81.588-1.81h4.162a1 1 0 00.95-.69l1.286-3.957z"/>
            </svg>
          <% } %>
          <% if(halfStar) { %>
            <svg class="w-5 h-5 text-yellow-400" fill="currentColor" viewBox="0 0 20 20">
              <defs>
                <linearGradient id="half">
                  <stop offset="50%" stop-color="currentColor"/>
                  <stop offset="50%" stop-color="transparent"/>
                </linearGradient>
              </defs>
              <path fill="url(#half)" d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.286 3.957a1 1 0 00.95.69h4.162c.969 0 1.371 1.24.588 1.81l-3.37 2.448a1 1 0 00-.364 1.118l1.287 3.957c.3.921-.755 1.688-1.54 1.118l-3.37-2.448a1 1 0 00-1.176 0l-3.37 2.448c-.784.57-1.838-.197-1.539-1.118l1.286-3.957a1 1 0 00-.364-1.118L2.034 9.384c-.783-.57-.38-1.81.588-1.81h4.162a1 1 0 00.95-.69l1.286-3.957z"/>
            </svg>
          <% } %>
          <% for(int i=0; i<emptyStars; i++) { %>
            <svg class="w-5 h-5 text-gray-300" fill="currentColor" viewBox="0 0 20 20">
              <path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.286 3.957a1 1 0 00.95.69h4.162c.969 0 1.371 1.24.588 1.81l-3.37 2.448a1 1 0 00-.364 1.118l1.287 3.957c.3.921-.755 1.688-1.54 1.118l-3.37-2.448a1 1 0 00-1.176 0l-3.37 2.448c-.784.57-1.838-.197-1.539-1.118l1.286-3.957a1 1 0 00-.364-1.118L2.034 9.384c-.783-.57-.38-1.81.588-1.81h4.162a1 1 0 00.95-.69l1.286-3.957z"/>
            </svg>
          <% } %>
          <span class="text-gray-700 text-sm ml-1"><%=String.format("%.1f", rating) %>/5</span>
        </div>
        <p class="text-green-600 font-bold text-2xl"><%=food.getPrice()%> MMK</p>
      </div>

      <!-- Description -->
      <div>
        <h2 class="text-lg font-semibold text-gray-800 mb-1">Description</h2>
        <p class="text-gray-700 leading-relaxed"><%=food.getDescription()%></p>
      </div>

      <!-- Shipping -->
      <div>
        <h2 class="text-lg font-semibold text-gray-800 mb-1">Shipping Info</h2>
        <p class="text-gray-700 leading-relaxed">
          Available for dine-in, takeaway, or cinema delivery. Freshly prepared!
        </p>
      </div>

      <!-- Quantity + Add to Cart -->
      <form id="addToCartForm" action="cart" method="post" class="flex flex-col sm:flex-row items-center gap-4 mt-4">
        <input type="hidden" name="food_id" value="<%=food.getId()%>">
        <input type="hidden" name="quantity" id="qtyInput" value="1">

        <!-- Quantity Selector -->
        <div class="flex items-center border border-gray-300 rounded-full px-3 py-1 gap-2">
          <button type="button" onclick="updateQty(-1)" class="text-gray-700 text-xl font-bold">−</button>
          <span id="qtyDisplay" class="w-6 text-center text-gray-800 font-medium">1</span>
          <button type="button" onclick="updateQty(1)" class="text-gray-700 text-xl font-bold">+</button>
        </div>

        <button type="submit" class="bg-red-700 hover:bg-red-900 text-white font-medium py-2 px-6 rounded-full transition">
          Add to Cart
        </button>
      </form>

    </div>

    <% } %>
  </main>

  <!-- Footer -->
  <jsp:include page="layout/footer.jsp"/>

  <script>
    let quantity = 1;
    const qtyDisplay = document.getElementById('qtyDisplay');
    const qtyInput = document.getElementById('qtyInput');
    const addToCartForm = document.getElementById('addToCartForm');

    function updateQty(change) {
      quantity = Math.max(1, quantity + change);
      qtyDisplay.textContent = quantity;
      qtyInput.value = quantity;
    }

    addToCartForm.addEventListener('submit', function(e) {
      e.preventDefault();
      const isLoggedIn = <%= (user != null) ? "true" : "false" %>;
      if (!isLoggedIn) {
        alert("Please login to add items to your cart.");
        window.location.href = "login.jsp";
        return;
      }

      qtyInput.value = quantity;
      const formData = new FormData(addToCartForm);

      fetch('cart', {
        method: 'POST',
        body: new URLSearchParams(formData)
      })
      .then(response => response.text())
      .then(data => {
        alert("Item added to cart successfully!");
        const cartCountElem = document.getElementById('cartCount');
        if(cartCountElem) {
          let currentCount = parseInt(cartCountElem.textContent) || 0;
          cartCountElem.textContent = currentCount + quantity;
        }
      })
      .catch(err => {
        console.error(err);
        alert("Failed to add item to cart.");
      });
    });
  </script>

</body>
</html>
