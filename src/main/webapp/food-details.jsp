<%@ page import="com.demo.model.FoodItem,com.demo.model.User,com.demo.dao.FoodDAO,java.util.List" %>
<%@ page contentType="text/html; charset=UTF-8" %>
<jsp:include page="layout/JSPHeader.jsp"/>

<!-- Header -->
<jsp:include page="layout/header.jsp"/>

<!-- Main Content -->
<main class="w-full px-4 py-8 max-w-6xl mx-auto">
  <%
    FoodItem food = (FoodItem) request.getAttribute("food");
    User user = (User) session.getAttribute("user");
    
    // Get related foods directly from DAO
    FoodDAO foodDAO = new FoodDAO();
    List<FoodItem> allFoods = foodDAO.getAllFoods();
    List<FoodItem> relatedFoods = allFoods.stream()
        .filter(f -> f.getId() != food.getId())
        .limit(4)
        .collect(java.util.stream.Collectors.toList());
  %>

  <% if(food == null){ %>
    <div class="w-full flex justify-center py-12">
      <div class="text-center">
        <svg xmlns="http://www.w3.org/2000/svg" class="h-16 w-16 mx-auto text-red-500 mb-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.964-.833-2.732 0L4.082 16.5c-.77.833.192 2.5 1.732 2.5z" />
        </svg>
        <p class="text-gray-700 text-lg">
          Food item not found!
        </p>
      </div>
    </div>
  <% } else { %>

  <div class="flex flex-col lg:flex-row gap-8">
    <!-- Food Image - Left Column -->
    <div class="lg:w-1/2 w-full">
      <div class="mt-5">
        <div class="h-[400px] lg:h-[500px] overflow-hidden rounded-2xl bg-white flex items-center justify-center">
          <img src="<%=food.getImage()%>" 
               alt="<%=food.getName()%>" 
               class="w-full h-full object-contain transition-transform duration-500 hover:scale-105">
        </div>
        
        
      </div>
    </div>

    <!-- Food Info - Right Column -->
    <div class="lg:w-1/2 w-full flex flex-col space-y-6">
      <!-- Name & Type -->
      <div class="space-y-2">
        <span class="inline-block px-3 py-1 text-xs text-red-600 uppercase font-medium tracking-wider bg-red-50 rounded-full">
          <%=food.getFoodType()%>
        </span>
        <h1 class="text-2xl md:text-3xl font-bold text-gray-900"><%=food.getName()%></h1>
      </div>

      <!-- Rating & Price -->
      <div class="flex flex-col sm:flex-row sm:items-center justify-between py-4 border-b border-gray-200 gap-4">
        <div class="flex items-center gap-2">
          <%
            double rating = food.getRating();
            int fullStars = (int) rating;
            boolean halfStar = (rating - fullStars) >= 0.5;
            int emptyStars = 5 - fullStars - (halfStar ? 1 : 0);
          %>
          <div class="flex items-center gap-1">
            <% for(int i=0; i<fullStars; i++) { %>
              <svg class="w-5 h-5 text-red-500" fill="currentColor" viewBox="0 0 20 20">
                <path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.286 3.957a1 1 0 00.95.69h4.162c.969 0 1.371 1.24.588 1.81l-3.37 2.448a1 1 0 00-.364 1.118l1.287 3.957c.3.921-.755 1.688-1.54 1.118l-3.37-2.448a1 1 0 00-1.176 0l-3.37 2.448c-.784.57-1.838-.197-1.539-1.118l1.286-3.957a1 1 0 00-.364-1.118L2.034 9.384c-.783-.57-.38-1.81.588-1.81h4.162a1 1 0 00.95-.69l1.286-3.957z"/>
              </svg>
            <% } %>
            <% if(halfStar) { %>
              <svg class="w-5 h-5 text-red-500" fill="currentColor" viewBox="0 0 20 20">
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
          </div>
         
          
        </div>
        <p class="text-red-600 font-bold text-2xl"><%=food.getPrice()%> MMK</p>
      </div>

      <!-- Description -->
      <div class="py-2">
        <h2 class="text-lg font-semibold text-gray-800 mb-3">Description</h2>
        <p class="text-gray-600 leading-relaxed"><%=food.getDescription()%></p>
      </div>

      

      <!-- Shipping -->
      <div class="py-2">
        <h2 class="text-lg font-semibold text-gray-800 mb-3">Shipping Info</h2>
        <div class="flex items-start gap-3 text-gray-600 leading-relaxed">
          <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 text-green-500 mt-0.5 flex-shrink-0" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
          </svg>
          <p>Available for dine-in, takeaway, or cinema delivery. Freshly prepared!</p>
        </div>
        <div class="flex items-start gap-3 text-gray-600 leading-relaxed">
          <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 text-green-500 mt-0.5 flex-shrink-0" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
          </svg>
          <p>Preparation Time 15-20 mins</p>
        </div>
      </div>

      <!-- Quantity + Add to Cart -->
      <div class=" mt-4">
        <form id="addToCartForm" action="cart" method="post" class="flex flex-col sm:flex-row items-center gap-4">
          <input type="hidden" name="food_id" value="<%=food.getId()%>">
          <input type="hidden" name="quantity" id="qtyInput" value="1">

          <!-- Quantity Selector -->
          <div class="flex items-center border border-gray-300 rounded-lg px-4 py-3 gap-4 bg-white shadow-sm">
            <button type="button" onclick="updateQty(-1)" class="quantity-btn text-gray-700 text-lg font-medium w-6 h-6 flex items-center justify-center rounded-full hover:bg-red-100 transition-colors">−</button>
            <span id="qtyDisplay" class="w-8 text-center text-gray-800 font-medium text-lg">1</span>
            <button type="button" onclick="updateQty(1)" class="quantity-btn text-gray-700 text-lg font-medium w-6 h-6 flex items-center justify-center rounded-full hover:bg-red-100 transition-colors">+</button>
          </div>

          <button type="submit" class="bg-red-600 hover:bg-red-700 text-white font-medium py-3 px-8 rounded-lg transition w-full sm:w-auto shadow-md flex items-center justify-center gap-2">
            <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 3h2l.4 2M7 13h10l4-8H5.4M7 13L5.4 5M7 13l-2.293 2.293c-.63.63-.184 1.707.707 1.707H17m0 0a2 2 0 100 4 2 2 0 000-4zm-8 2a2 2 0 11-4 0 2 2 0 014 0z" />
            </svg>
            Add to Cart
          </button>
        </form>
      </div>
    </div>
  </div>

  <!-- You May Also Like Section -->
  <% if (relatedFoods != null && !relatedFoods.isEmpty()) { %>
  <section class="mt-16 border-t border-gray-200 pt-12">
    <div class="flex items-center justify-between mb-8">
      <h2 class="text-2xl font-bold text-gray-900">You May Also Like</h2>
      <a href="foods?action=list" class="text-red-600 hover:text-red-700 font-medium flex items-center gap-1">
        View All
        <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" />
        </svg>
      </a>
    </div>

    <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
      <%
        for(FoodItem relatedFood : relatedFoods) {
      %>
        <div class="bg-white rounded-2xl overflow-hidden flex flex-col shadow-sm border border-gray-100 hover:shadow-md transition-shadow duration-300">
          <!-- Image -->
          <div class="flex justify-center items-center h-48 p-4 bg-white">
            <img src="<%=relatedFood.getImage()%>" 
                 alt="<%=relatedFood.getName()%>" 
                 class="max-h-full object-contain hover:scale-105 transition-transform duration-300">
          </div>

          <!-- Content -->
          <div class="p-5 flex flex-col flex-grow">
            <!-- Price -->
            <p class="text-gray-600 text-sm mb-1">
              <span class="font-semibold text-gray-900"><%=relatedFood.getPrice()%> MMK</span>
            </p>

            <!-- Food Name -->
            <h2 class="text-lg font-semibold text-gray-900 mb-2 line-clamp-1 hover:text-red-600 transition-colors">
              <a href="foods?action=details&id=<%=relatedFood.getId()%>">
                <%=relatedFood.getName()%>
              </a>
            </h2>

            <!-- Rating -->
            <div class="flex items-center mb-2">
              <% 
                double relatedRating = relatedFood.getRating();
                int relatedFullStars = (int) relatedRating;
                boolean relatedHalfStar = (relatedRating - relatedFullStars) >= 0.5;
                int relatedEmptyStars = 5 - relatedFullStars - (relatedHalfStar ? 1 : 0);

                for(int i=0; i<relatedFullStars; i++) { %>
                  <svg xmlns="http://www.w3.org/2000/svg" class="w-4 h-4 text-yellow-400" viewBox="0 0 20 20" fill="currentColor">
                    <path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.286 3.974a1 1 0 00.95.69h4.178c.969 0 1.371 1.24.588 1.81l-3.385 2.46a1 1 0 00-.364 1.118l1.287 3.974c.3.921-.755 1.688-1.54 1.118l-3.385-2.46a1 1 0 00-1.176 0l-3.385 2.46c-.785.57-1.84-.197-1.54-1.118l1.287-3.974a1 1 0 00-.364-1.118L2.097 9.401c-.783-.57-.38-1.81.588-1.81h4.178a1 1 0 00.95-.69l1.286-3.974z"/>
                  </svg>
              <% } 
                if(relatedHalfStar) { %>
                  <svg xmlns="http://www.w3.org/2000/svg" class="w-4 h-4 text-yellow-400" viewBox="0 0 20 20" fill="currentColor">
                    <path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.286 3.974a1 1 0 00.95.69h4.178c.969 0 1.371 1.24.588 1.81l-3.385 2.46a1 1 0 00-.364 1.118l1.287 3.974c.3.921-.755 1.688-1.54 1.118l-3.385-2.46a1 1 0 00-.588-.236V2.927z"/>
                  </svg>
              <% } 
                for(int i=0; i<relatedEmptyStars; i++) { %>
                  <svg xmlns="http://www.w3.org/2000/svg" class="w-4 h-4 text-gray-300" viewBox="0 0 20 20" fill="currentColor">
                    <path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.286 3.974a1 1 0 00.95.69h4.178c.969 0 1.371 1.24.588 1.81l-3.385 2.46a1 1 0 00-.364 1.118l1.287 3.974c.3.921-.755 1.688-1.54 1.118l-3.385-2.46a1 1 0 00-1.176 0l-3.385 2.46c-.785.57-1.84-.197-1.54-1.118l1.287-3.974a1 1 0 00-.364-1.118L2.097 9.401c-.783-.57-.38-1.81.588-1.81h4.178a1 1 0 00.95-.69l1.286-3.974z"/>
                  </svg>
              <% } %>
              
            </div>

            <!-- Description -->
            <p class="text-gray-500 text-sm mb-4 line-clamp-2"><%=relatedFood.getFoodType()%></p>

            <!-- Button -->
            <div class="mt-auto">
              <a href="foods?action=details&id=<%=relatedFood.getId()%>"
                 class="block w-full text-center border border-gray-300 hover:border-red-300 hover:bg-red-50 text-gray-800 hover:text-red-700 font-medium text-sm py-2 rounded-lg transition">
                View Details
              </a>
            </div>
          </div>
        </div>
      <% } %>
    </div>
  </section>
  <% } %>

  <% } %>
</main>

<!-- Footer -->
<jsp:include page="layout/footer.jsp"/>

<!-- SweetAlert CDN -->
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

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
      Swal.fire({
        title: 'Login Required',
        text: 'Please login to add items to your cart.',
        icon: 'warning',
        confirmButtonColor: '#dc2626',
        confirmButtonText: 'Go to Login',
        showCancelButton: true,
        cancelButtonText: 'Cancel'
      }).then((result) => {
        if (result.isConfirmed) {
          window.location.href = "login.jsp";
        }
      });
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
      Swal.fire({
        title: 'Success!',
        text: 'Item added to cart successfully!',
        icon: 'success',
        confirmButtonColor: '#dc2626',
        confirmButtonText: 'OK'
      });
      
      const cartCountElem = document.getElementById('cartCount');
      if(cartCountElem) {
        let currentCount = parseInt(cartCountElem.textContent) || 0;
        cartCountElem.textContent = currentCount + quantity;
      }
    })
    .catch(err => {
      console.error(err);
      Swal.fire({
        title: 'Error!',
        text: 'Failed to add item to cart.',
        icon: 'error',
        confirmButtonColor: '#dc2626',
        confirmButtonText: 'OK'
      });
    });
  });
</script>

<!-- Footer -->
<jsp:include page="layout/JSPFooter.jsp"/>