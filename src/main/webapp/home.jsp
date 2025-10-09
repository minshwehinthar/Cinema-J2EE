<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="com.demo.dao.*" %>
<%@ page import="com.demo.model.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.time.LocalDate" %>
<%
MoviesDao moviesDao = new MoviesDao();
TheaterMoviesDao theaterMoviesDao = new TheaterMoviesDao();
TheaterDAO theaterDAO = new TheaterDAO();
ReviewDAO reviewDAO = new ReviewDAO();
FoodDAO foodDAO = new FoodDAO();

// Fetch data from database
ArrayList<Movies> allMovies = moviesDao.getAllMovies();
ArrayList<Movies> pickedMovies = theaterMoviesDao.getMoviesPickedByTheaters();
ArrayList<Movies> comingSoonMovies = theaterMoviesDao.getComingSoonMovies();
List<Theater> allTheaters = theaterDAO.getAllTheaters();
List<Review> allReviews = reviewDAO.getAllReviews();
List<FoodItem> allFoods = foodDAO.getAllFoods();

// Create filtered lists for better organization
List<Movies> nowShowingMovies = new ArrayList<>();
List<Movies> comingSoonMoviesList = new ArrayList<>();

// Debug: Check what's in pickedMovies
System.out.println("=== DEBUG: All picked movies ===");
for (Movies movie : pickedMovies) {
    System.out.println("Movie: " + movie.getTitle() + " | Status: " + movie.getStatus());
}

// Filter movies properly
for (Movies movie : pickedMovies) {
    if ("now-showing".equalsIgnoreCase(movie.getStatus())) {
        nowShowingMovies.add(movie);
    } else if ("coming-soon".equalsIgnoreCase(movie.getStatus())) {
        comingSoonMoviesList.add(movie);
    }
}

System.out.println("Now showing count: " + nowShowingMovies.size());
System.out.println("Coming soon count: " + comingSoonMoviesList.size());
%>

<jsp:include page="layout/JSPHeader.jsp" />
<jsp:include page="layout/header.jsp" />

<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/swiper@11/swiper-bundle.min.css" />
<script src="https://cdn.jsdelivr.net/npm/swiper@11/swiper-bundle.min.js"></script>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

<!-- Banner Section -->
<section class="">
  <div class="w-full mx-auto">
    <div class="swiper banner-slider">
      <div class="swiper-wrapper">
        <!-- Slide 1 -->
        <div class="swiper-slide relative">
        <img src="https://images.unsplash.com/photo-1731004270606-d39d246c1e01?q=80&w=2670&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D" 
               alt="Slide 1" class="object-cover w-full h-[800px] overflow-hidden">
          
          <div class="absolute inset-0 bg-black/30 flex flex-col justify-center p-20 text-white">
            <h2 class="text-5xl font-bold mb-8">Experience the Magic of Cinema</h2>
            <h3 class="text-xl mb-2">Blockbuster Movies Await</h3>
            <p class="mb-4 max-w-lg">Book your tickets now and enjoy the latest blockbusters in our premium theaters with state-of-the-art sound and projection.</p>
            <div class="flex gap-3">
              <a href="movies.jsp" class="bg-red-600 border border-red-600 hover:bg-red-700 hover:border-red-700 duration-500 px-4 py-2 rounded inline-block w-[121px]">Buy Ticket</a>
              <a href="foods.jsp" class="border border-red-600 text-red-600 hover:bg-red-600 hover:text-white duration-500 px-4 py-2 rounded inline-block w-[117px]">Shop Now</a>
            </div>
          </div>
        </div>

        <!-- Slide 2 -->
        <div class="swiper-slide relative">
          <img src="https://images.unsplash.com/photo-1517604931442-7e0c8ed2963c?q=80&w=2670&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D" 
               alt="Slide 2" class="object-cover w-full h-[800px] overflow-hidden">
          <div class="absolute inset-0 bg-black/30 flex flex-col justify-center p-20 text-white">
            <h2 class="text-5xl font-bold mb-8">Premium Cinema Experience</h2>
            <h3 class="text-xl mb-2">Comfort & Luxury Combined</h3>
            <p class="mb-4 max-w-lg">Enjoy our recliner seats, Dolby Atmos sound, and crystal-clear 4K projection for an unforgettable movie experience.</p>
            <div class="flex gap-3">
              <a href="movies.jsp" class="bg-red-600 border border-red-600 hover:bg-red-700 hover:border-red-700 duration-500 px-4 py-2 rounded inline-block w-[121px]">Buy Ticket</a>
              <a href="foods.jsp" class="border border-red-600 text-red-600 hover:bg-red-600 hover:text-white duration-500 px-4 py-2 rounded inline-block w-[117px]">Shop Now</a>
            </div>          </div>
        </div>

        <!-- Slide 3 -->
        <div class="swiper-slide relative">
          <img src="https://plus.unsplash.com/premium_photo-1681487691813-347cdd6f453c?w=900&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1yZWxhdGVkfDE4fHx8ZW58MHx8fHx8" 
               alt="Slide 3" class="object-cover w-full h-[800px] overflow-hidden">
          <div class="absolute inset-0 bg-black/30 flex flex-col justify-center p-20 text-white">
            <h2 class="text-5xl font-bold mb-8">Delicious Snacks & Drinks</h2>
            <h3 class="text-xl mb-2">Complete Your Movie Night</h3>
            <p class="mb-4 max-w-lg">From classic popcorn to gourmet snacks, we have everything you need to make your movie experience perfect.</p>
            <div class="flex gap-3">
              <a href="movies.jsp" class="bg-red-600 border border-red-600 hover:bg-red-700 hover:border-red-700 duration-500 px-4 py-2 rounded inline-block w-[121px]">Buy Ticket</a>
              <a href="foods.jsp" class="border border-red-600 text-red-600 hover:bg-red-600 hover:text-white duration-500 px-4 py-2 rounded inline-block w-[117px]">Shop Now</a>
            </div>
          </div>
        </div>
      </div>
      <div class="swiper-pagination mt-4"></div>
    </div>
  </div>
</section>

<script>
  const bannerSwiper = new Swiper('.banner-slider', {
    slidesPerView: 1,
    spaceBetween: 20,
    loop: true,
    autoplay: { delay: 3000, disableOnInteraction: false },
    pagination: { el: '.swiper-pagination', clickable: true },
  });
</script>

<!-- ✅ FIXED "Now Showing" Section - Only shows "now-showing" movies -->
<section class="bg-gray-50 py-16">
  <div class="max-w-7xl mx-auto px-6">
    <h2 class="text-3xl font-bold text-center mb-12">Now Showing</h2>
    <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-8">
      <%
      int movieCount = 0;
      for (Movies movie : nowShowingMovies) {
          if (movieCount >= 4) break;
      %>
      <div class="movie-card group relative overflow-hidden rounded-xl shadow-md border border-gray-200 hover:shadow-lg transition-shadow duration-300">
        <a href="moviedetails.jsp?movie_id=<%= movie.getMovie_id() %>" class="block relative">
          <img src="GetMoviesPosterServlet?movie_id=<%= movie.getMovie_id() %>"
               class="w-full aspect-[2/3] object-cover transition-transform duration-300 group-hover:scale-105" 
               alt="<%= movie.getTitle() %>" />
          <div class="absolute bottom-0 left-0  bg-black/40 backdrop-blur-xs w-full bg-gradient-to-t from-black/80 to-transparent p-4 opacity-0 group-hover:opacity-100 transition-opacity duration-300">
            <h3 class="text-white font-bold text-lg truncate"><%= movie.getTitle() %></h3>
            <p class="text-gray-300 text-sm truncate"><%= movie.getDuration() %> • <%= movie.getGenres() != null ? movie.getGenres() : "Movie" %></p>
            <p class="text-gray-200 text-xs mt-2 line-clamp-3">
              <%= (movie.getSynopsis() != null && !movie.getSynopsis().trim().isEmpty()) ? 
                  (movie.getSynopsis().length() > 100 ? movie.getSynopsis().substring(0, 100) + "..." : movie.getSynopsis()) 
                  : "No synopsis available." %>
            </p>
            <span class="inline-block mt-3 px-3 py-1 text-xs font-semibold rounded-full uppercase bg-green-500 text-white">
              Now Showing
            </span>
          </div>
        </a>
      </div>
      <%
          movieCount++;
      }
      
      // Show message if no now showing movies
      if (nowShowingMovies.isEmpty()) {
      %>
        <div class="col-span-4 text-center py-12">
          <div class="bg-white rounded-xl shadow-md p-8 max-w-md mx-auto">
            <div class="text-6xl mb-4">🎬</div>
            <h3 class="text-xl font-semibold text-gray-800 mb-2">No Movies Currently Showing</h3>
            <p class="text-gray-600">Check back soon for upcoming movies!</p>
            <a href="movies.jsp" class="mt-4 inline-block bg-blue-600 hover:bg-blue-700 text-white px-6 py-2 rounded-lg transition duration-300">
              Browse All Movies
            </a>
          </div>
        </div>
      <%
      }
      %>
    </div>
    
    <div class="text-center mx-auto mt-6 text-red-600 font-bold hover:text-red-700">
      -<a href="movies.jsp" class="underline duration-500 px-4 py-2 rounded inline-block"> View All </a>-
     </div>
  </div>
</section>

<!-- ✅ COMING SOON Section -->
<section class="bg-white py-16">
  <div class="max-w-7xl mx-auto px-6">
    <h2 class="text-3xl font-bold text-center mb-12">Coming Soon</h2>
    <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-8">
      <%
      int comingSoonCount = 0;
      for (Movies movie : comingSoonMoviesList) {
          if (comingSoonCount >= 4) break;
      %>
      <div class="movie-card group relative overflow-hidden rounded-xl shadow-md border border-gray-200 hover:shadow-lg transition-shadow duration-300">
        <a href="moviedetails.jsp?movie_id=<%= movie.getMovie_id() %>" class="block relative">
          <img src="GetMoviesPosterServlet?movie_id=<%= movie.getMovie_id() %>"
               class="w-full aspect-[2/3] object-cover transition-transform duration-300 group-hover:scale-105" 
               alt="<%= movie.getTitle() %>" />
          <div class="absolute bottom-0 left-0  bg-black/40 backdrop-blur-xs w-full bg-gradient-to-t from-black/80 to-transparent p-4 opacity-0 group-hover:opacity-100 transition-opacity duration-300">
            <h3 class="text-white font-bold text-lg truncate"><%= movie.getTitle() %></h3>
            <p class="text-gray-300 text-sm truncate"><%= movie.getDuration() %> • <%= movie.getGenres() != null ? movie.getGenres() : "Movie" %></p> 
            <p class="text-gray-200 text-xs mt-2 line-clamp-3">
              <%= (movie.getSynopsis() != null && !movie.getSynopsis().trim().isEmpty()) ? 
                  (movie.getSynopsis().length() > 100 ? movie.getSynopsis().substring(0, 100) + "..." : movie.getSynopsis()) 
                  : "No synopsis available." %>
            </p>
            <span class="inline-block mt-3 px-3 py-1 text-xs font-semibold rounded-full uppercase bg-orange-400 text-white">
              Coming Soon
            </span>
          </div>
        </a>
      </div>
      <%
          comingSoonCount++;
      }
      
      // Show message if no coming soon movies
      if (comingSoonMoviesList.isEmpty()) {
      %>
        <div class="col-span-4 text-center py-12">
          <div class="bg-gray-50 rounded-xl shadow-md p-8 max-w-md mx-auto">
            <div class="text-6xl mb-4">📅</div>
            <h3 class="text-xl font-semibold text-gray-800 mb-2">No Upcoming Movies</h3>
            <p class="text-gray-600">New movies will be announced soon!</p>
          </div>
        </div>
      <%
      }
      %>
    </div>
    
    <div class="text-center mx-auto mt-6 text-red-600 font-bold hover:text-red-700">
      -<a href="movies.jsp" class="underline duration-500 px-4 py-2 rounded inline-block"> View All </a>-
     </div>
  </div>
</section>

<!-- OUR THEATERS Section - Modern White Design -->
<section class="bg-white py-16">
  <div class="max-w-7xl mx-auto px-6">
    <h2 class="text-3xl font-bold text-center mb-12 text-gray-900">Our Theaters</h2>

    <div class="swiper theaters-slider">
      <div class="swiper-wrapper">
        <%
        int theaterCount = 0;
        for (Theater t : allTheaters) {
            if (theaterCount >= 6) break;
        %>
<div class="swiper-slide">
  <div class="block border border-gray-200 rounded-lg overflow-hidden hover:border-red-600 transition-colors duration-200">

    <!-- Theater Poster -->
    <div class="overflow-hidden">
      <img src="GetTheatersPosterServlet?theater_id=<%= t.getTheaterId() %>" 
           alt="<%= t.getName() %>" 
           class="w-full h-56 object-cover transform transition-transform duration-300 hover:scale-105"/>
    </div>

    <!-- Theater Info -->
    <div class="p-4 text-center">
      <h3 class="font-semibold text-lg text-gray-900 mb-1"><%= t.getName() %></h3>
      <p class="text-gray-600 text-sm"><%= t.getLocation() != null ? t.getLocation() : "City Center" %></p>
    </div>

  </div>
</div>

        <%
            theaterCount++;
        }
        
        if (allTheaters.isEmpty()) {
        %>
        <div class="swiper-slide">
          <div class="bg-white rounded-xl shadow-lg border border-gray-200 p-6 text-center h-full">
            
            <h3 class="text-xl font-bold text-gray-800 mb-2">No Theaters Available</h3>
            <p class="text-gray-600 mb-4">Our theater locations will be updated soon.</p>
            <div class="bg-gray-100 text-gray-500 py-2 px-4 rounded-lg font-semibold">
              Coming Soon
            </div>
          </div>
        </div>
        <%
        }
        %>
      </div>

      <!-- Pagination -->
      <div class="swiper-pagination mt-6"></div>
    </div>
  </div>
</section>


<script>
  // Initialize theaters slider
  const theatersSwiper = new Swiper(".theaters-slider", {
    slidesPerView: 1,
    spaceBetween: 20,
    loop: true,
    autoplay: { delay: 3500, disableOnInteraction: false },
    pagination: { el: ".swiper-pagination", clickable: true },
    breakpoints: { 
      640: { slidesPerView: 2 }, 
      1024: { slidesPerView: 3 } 
    },
  });
</script>

<!-- 🍕 POPULAR FOOD ITEMS Section - Dynamic from Database -->
<section class="food-category-section bg-gradient-to-br from-orange-50 to-red-50 py-16 relative">
  <!-- Decorative Shapes -->
  <div class="absolute top-10 left-10 w-20 h-20 opacity-20">
    <span class="text-6xl">🍅</span>
  </div>
  <div class="absolute bottom-10 right-10 w-24 h-24 opacity-20 rotate-45">
    <span class="text-6xl">🍔</span>
  </div>
  <div class="absolute top-1/4 right-20 w-16 h-16 opacity-15">
    <span class="text-5xl">🥤</span>
  </div>
  
  <div class="container max-w-7xl mx-auto px-6 relative z-10">
    <div class="row flex flex-wrap items-center mb-12">
      <div class="col-md-7 col-9">
        <div class="section-title">
          <span class="text-red-600 font-semibold text-lg uppercase tracking-wider block mb-2 wow fadeInUp">
            Delicious, Every Bite Tastes Amazing
          </span>
          <h2 class="text-4xl font-bold text-gray-800 wow fadeInUp" data-wow-delay=".3s">
            Popular Food Items
          </h2>
        </div>
      </div>
      <!-- <div class="col-md-5 ps-0 col-3 text-end wow fadeInUp" data-wow-delay=".5s">
        <div class="array-button flex gap-3 justify-end">
          <button class="food-items-prev w-12 h-12 bg-white rounded-full shadow-md hover:shadow-lg transition-shadow duration-300 flex items-center justify-center text-orange-600 hover:bg-orange-600 hover:text-white">
            <i class="fas fa-arrow-left"></i>
          </button>
          <button class="food-items-next w-12 h-12 bg-white rounded-full shadow-md hover:shadow-lg transition-shadow duration-300 flex items-center justify-center text-orange-600 hover:bg-orange-600 hover:text-white">
            <i class="fas fa-arrow-right"></i>
          </button>
        </div>
      </div> -->
    </div>
    
    <div class="swiper food-items-slider">
      <div class="swiper-wrapper">
        <%
        int foodDisplayCount = 0;
        for(FoodItem food : allFoods) {
            if(foodDisplayCount >= 12) break; // Limit to 12 items for display
            
            // Get appropriate emoji based on food type
            String foodEmoji = "🍽️";
            if (food.getFoodType() != null) {
                switch(food.getFoodType().toLowerCase()) {
                    case "popcorn": foodEmoji = "🍿"; break;
                    case "pizza": foodEmoji = "🍕"; break;
                    case "burger": foodEmoji = "🍔"; break;
                    case "french fries": foodEmoji = "🍟"; break;
                    case "soft drinks": foodEmoji = "🥤"; break;
                    case "ice cream": foodEmoji = "🍦"; break;
                    case "hot dogs": foodEmoji = "🌭"; break;
                    case "nachos": foodEmoji = "🌮"; break;
                    case "candy": foodEmoji = "🍬"; break;
                    case "coffee": foodEmoji = "☕"; break;
                    case "sandwich": foodEmoji = "🥪"; break;
                    case "cookie": foodEmoji = "🍪"; break;
                    case "donut": foodEmoji = "🍩"; break;
                    case "cake": foodEmoji = "🍰"; break;
                }
            }
        %>
        <div class="swiper-slide">
          <div class="food-item-card bg-white rounded-2xl  hover:bg-red-50 transition-all duration-300 transform hover:scale-95 border border-gray-100">
            <!-- Rating Badge -->
            
            
            <!-- Food Image Container -->
            <div class="food-item-image relative h-48 bg-gradient-to-br from-orange-100 to-red-100 flex items-center justify-center p-6">
              <!-- Decorative Elements -->
              <div class="absolute top-2 left-2 w-8 h-8 opacity-20">
                <span class="text-2xl">🌿</span>
              </div>
              <div class="absolute bottom-2 right-2 w-8 h-8 opacity-20 rotate-45">
                <span class="text-2xl">🌿</span>
              </div>
              
              <!-- Food Image or Emoji -->
              <div class="relative z-10 text-center w-full h-full flex items-center justify-center">
                <% if(food.getImage() != null && !food.getImage().isEmpty()) { %>
                  <img src="<%= food.getImage() %>" 
                       alt="<%= food.getName() %>" 
                       class="max-w-full max-h-32 object-contain transform hover:scale-110 transition-transform duration-300">
                <% } else { %>
                  <div class="text-6xl transform hover:scale-110 transition-transform duration-300">
                    <%= foodEmoji %>
                  </div>
                <% } %>
              </div>
              
              <!-- Floating Shape -->
              <div class="absolute bottom-0 left-0 w-full h-4 bg-white/30 rounded-t-full"></div>
            </div>
            
            <!-- Content Section -->
            <div class="food-item-content text-center p-6 relative">
              <!-- Food Type Badge -->
              <div class="absolute -top-6 left-1/2 transform -translate-x-1/2">
                <span class="bg-orange-500 text-white px-3 py-1 rounded-full text-xs font-semibold shadow-md">
                  <%= food.getFoodType() != null ? food.getFoodType() : "Snack" %>
                </span>
              </div>
              
              <h3 class="text-xl font-bold text-gray-800 mt-4 mb-2 truncate">
                <a href="foods.jsp" class="hover:text-orange-600 transition-colors duration-300">
                  <%= food.getName() %>
                </a>
              </h3>
              
              <p class="text-gray-600 text-sm mb-3 line-clamp-2">
                <%= food.getDescription() != null && !food.getDescription().trim().isEmpty() ? 
                    food.getDescription() : "Delicious snack perfect for your movie experience." %>
              </p>
              
              <div class="flex justify-between items-center mb-4">
                <span class="text-2xl font-bold text-red-600">$<%= String.format("%.2f", food.getPrice()) %></span>
                <div class="flex items-center text-sm text-gray-500">
                  <i class="fas fa-fire text-orange-500 mr-1"></i>
                  <span>Popular</span>
                </div>
              </div>
              
            
            </div>
          </div>
        </div>
        <%
            foodDisplayCount++;
        } 
        
        // If no food items found in database, show some sample items
        if (allFoods.isEmpty()) {
          String[][] sampleFoods = {
            {"Classic Popcorn", "Popcorn", "4.5", "5.99", "Buttery and salty classic movie popcorn", "🍿"},
            {"Pepperoni Pizza", "Pizza", "4.8", "12.99", "Freshly baked pizza with pepperoni and cheese", "🍕"},
            {"Cheeseburger", "Burger", "4.6", "8.99", "Juicy beef patty with cheese and fresh veggies", "🍔"},
            {"Coca Cola", "Soft Drinks", "4.3", "3.99", "Refreshing cold Coca Cola", "🥤"},
            {"Chocolate Ice Cream", "Ice Cream", "4.7", "4.99", "Creamy chocolate ice cream", "🍦"},
            {"Nachos Supreme", "Nachos", "4.4", "7.99", "Crispy nachos with cheese and jalapeños", "🌮"}
          };
          
          for(int i = 0; i < sampleFoods.length; i++) {
            String foodName = sampleFoods[i][0];
            String foodType = sampleFoods[i][1];
            String rating = sampleFoods[i][2];
            String price = sampleFoods[i][3];
            String description = sampleFoods[i][4];
            String emoji = sampleFoods[i][5];
        %>
        <div class="swiper-slide">
          <div class="food-item-card bg-white rounded-2xl shadow-lg hover:shadow-xl transition-all duration-300 transform hover:-translate-y-2 border border-gray-100">
            <!-- Rating Badge -->
            <div class="absolute top-4 right-4 z-20">
              <span class="bg-white/90 backdrop-blur-sm px-3 py-1 rounded-full text-sm font-semibold text-yellow-700 shadow-sm flex items-center gap-1">
                <i class="fas fa-star text-yellow-500 text-xs"></i>
                <%= rating %>
              </span>
            </div>
            
            <!-- Food Image Container -->
            <div class="food-item-image relative h-48 bg-gradient-to-br from-orange-100 to-red-100 flex items-center justify-center p-6">
              <!-- Decorative Elements -->
              <div class="absolute top-2 left-2 w-8 h-8 opacity-20">
                <span class="text-2xl">🌿</span>
              </div>
              <div class="absolute bottom-2 right-2 w-8 h-8 opacity-20 rotate-45">
                <span class="text-2xl">🌿</span>
              </div>
              
              <!-- Food Emoji -->
              <div class="relative z-10 text-center">
                <div class="text-6xl transform hover:scale-110 transition-transform duration-300">
                  <%= emoji %>
                </div>
              </div>
              
              <!-- Floating Shape -->
              <div class="absolute bottom-0 left-0 w-full h-4 bg-white/30 rounded-t-full"></div>
            </div>
            
            <!-- Content Section -->
            <div class="food-item-content text-center p-6 relative">
              <!-- Food Type Badge -->
              <div class="absolute -top-6 left-1/2 transform -translate-x-1/2">
                <span class="bg-orange-500 text-white px-3 py-1 rounded-full text-xs font-semibold shadow-md">
                  <%= foodType %>
                </span>
              </div>
              
              <h3 class="text-xl font-bold text-gray-800 mt-4 mb-2">
                <a href="foods.jsp" class="hover:text-orange-600 transition-colors duration-300">
                  <%= foodName %>
                </a>
              </h3>
              
              <p class="text-gray-600 text-sm mb-3">
                <%= description %>
              </p>
              
              <div class="flex justify-between items-center mb-4">
                <span class="text-2xl font-bold text-red-600">$<%= price %></span>
                <div class="flex items-center text-sm text-gray-500">
                  <i class="fas fa-fire text-orange-500 mr-1"></i>
                  <span>Popular</span>
                </div>
              </div>
              
             
            </div>
          </div>
        </div>
        <%
          }
        }
        %>
      </div>
      
      <!-- Pagination -->
      <div class="swiper-pagination mt-8"></div>
    </div>
     <div class="text-center mx-auto mt-6 text-red-600 font-bold hover:text-red-700">
      -<a href="foods.jsp" class="underline duration-500 px-4 py-2 rounded inline-block"> Shop Now </a>-
     </div>
  </div>
  
</section>

<script>
  // Initialize food items slider
  const foodItemsSwiper = new Swiper(".food-items-slider", {
    slidesPerView: 1,
    spaceBetween: 30,
    loop: true,
    autoplay: {
      delay: 4000,
      disableOnInteraction: false,
    },
    pagination: {
      el: ".swiper-pagination",
      clickable: true,
    },
    navigation: {
      nextEl: ".food-items-next",
      prevEl: ".food-items-prev",
    },
    breakpoints: {
      480: {
        slidesPerView: 2,
        spaceBetween: 20,
      },
      768: {
        slidesPerView: 3,
        spaceBetween: 25,
      },
      1024: {
        slidesPerView: 4,
        spaceBetween: 30,
      },
    },
  });
</script>



<!-- Features -->
<section class="bg-white py-16">
  <div class="max-w-6xl mx-auto px-6 grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-10 text-center">
    <div class="bg-white rounded-xl shadow-md p-8 hover:shadow-lg transition-shadow duration-300 border border-gray-100">
      <div class="flex justify-center mb-4">
        <span class="w-16 h-16 flex items-center justify-center rounded-full bg-red-100 text-red-600 text-2xl">
         <i class="fa-regular fa-address-card"></i>
        </span>
      </div>
      <h3 class="text-xl font-semibold text-gray-800 mb-3">Easy Booking</h3>
      <p class="text-gray-600">Quick and hassle-free online ticket booking with instant confirmation and secure payment.</p>
    </div>
    
    <div class="bg-white rounded-xl shadow-md p-8 hover:shadow-lg transition-shadow duration-300 border border-gray-100">
      <div class="flex justify-center mb-4">
        <span class="w-16 h-16 flex items-center justify-center rounded-full bg-green-100 text-green-600 text-2xl">
          <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-6">
  <path stroke-linecap="round" stroke-linejoin="round" d="M6.75 2.994v2.25m10.5-2.25v2.25m-14.252 13.5V7.491a2.25 2.25 0 0 1 2.25-2.25h13.5a2.25 2.25 0 0 1 2.25 2.25v11.251m-18 0a2.25 2.25 0 0 0 2.25 2.25h13.5a2.25 2.25 0 0 0 2.25-2.25m-18 0v-7.5a2.25 2.25 0 0 1 2.25-2.25h13.5a2.25 2.25 0 0 1 2.25 2.25v7.5m-6.75-6h2.25m-9 2.25h4.5m.002-2.25h.005v.006H12v-.006Zm-.001 4.5h.006v.006h-.006v-.005Zm-2.25.001h.005v.006H9.75v-.006Zm-2.25 0h.005v.005h-.006v-.005Zm6.75-2.247h.005v.005h-.005v-.005Zm0 2.247h.006v.006h-.006v-.006Zm2.25-2.248h.006V15H16.5v-.005Z" />
</svg>
          
        </span>
      </div>
      <h3 class="text-xl font-semibold text-gray-800 mb-3">Multiple Showtimes</h3>
      <p class="text-gray-600">Flexible scheduling with showtimes throughout the day to fit your busy schedule.</p>
    </div>
    
    <div class="bg-white rounded-xl shadow-md p-8 hover:shadow-lg transition-shadow duration-300 border border-gray-100">
      <div class="flex justify-center mb-4">
        <span class="w-16 h-16 flex items-center justify-center rounded-full bg-blue-100 text-blue-600 text-2xl">
          <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-6">
  <path stroke-linecap="round" stroke-linejoin="round" d="M3.375 19.5h17.25m-17.25 0a1.125 1.125 0 0 1-1.125-1.125M3.375 19.5h1.5C5.496 19.5 6 18.996 6 18.375m-3.75 0V5.625m0 12.75v-1.5c0-.621.504-1.125 1.125-1.125m18.375 2.625V5.625m0 12.75c0 .621-.504 1.125-1.125 1.125m1.125-1.125v-1.5c0-.621-.504-1.125-1.125-1.125m0 3.75h-1.5A1.125 1.125 0 0 1 18 18.375M20.625 4.5H3.375m17.25 0c.621 0 1.125.504 1.125 1.125M20.625 4.5h-1.5C18.504 4.5 18 5.004 18 5.625m3.75 0v1.5c0 .621-.504 1.125-1.125 1.125M3.375 4.5c-.621 0-1.125.504-1.125 1.125M3.375 4.5h1.5C5.496 4.5 6 5.004 6 5.625m-3.75 0v1.5c0 .621.504 1.125 1.125 1.125m0 0h1.5m-1.5 0c-.621 0-1.125.504-1.125 1.125v1.5c0 .621.504 1.125 1.125 1.125m1.5-3.75C5.496 8.25 6 7.746 6 7.125v-1.5M4.875 8.25C5.496 8.25 6 8.754 6 9.375v1.5m0-5.25v5.25m0-5.25C6 5.004 6.504 4.5 7.125 4.5h9.75c.621 0 1.125.504 1.125 1.125m1.125 2.625h1.5m-1.5 0A1.125 1.125 0 0 1 18 7.125v-1.5m1.125 2.625c-.621 0-1.125.504-1.125 1.125v1.5m2.625-2.625c.621 0 1.125.504 1.125 1.125v1.5c0 .621-.504 1.125-1.125 1.125M18 5.625v5.25M7.125 12h9.75m-9.75 0A1.125 1.125 0 0 1 6 10.875M7.125 12C6.504 12 6 12.504 6 13.125m0-2.25C6 11.496 5.496 12 4.875 12M18 10.875c0 .621-.504 1.125-1.125 1.125M18 10.875c0 .621.504 1.125 1.125 1.125m-2.25 0c.621 0 1.125.504 1.125 1.125m-12 5.25v-5.25m0 5.25c0 .621.504 1.125 1.125 1.125h9.75c.621 0 1.125-.504 1.125-1.125m-12 0v-1.5c0-.621-.504-1.125-1.125-1.125M18 18.375v-5.25m0 5.25v-1.5c0-.621.504-1.125 1.125-1.125M18 13.125v1.5c0 .621.504 1.125 1.125 1.125M18 13.125c0-.621.504-1.125 1.125-1.125M6 13.125v1.5c0 .621-.504 1.125-1.125 1.125M6 13.125C6 12.504 5.496 12 4.875 12m-1.5 0h1.5m-1.5 0c-.621 0-1.125.504-1.125 1.125v1.5c0 .621.504 1.125 1.125 1.125M19.125 12h1.5m0 0c.621 0 1.125.504 1.125 1.125v1.5c0 .621-.504 1.125-1.125 1.125m-17.25 0h1.5m14.25 0h1.5" />
</svg>
          
        </span>
      </div>
      <h3 class="text-xl font-semibold text-gray-800 mb-3">Premium Experience</h3>
      <p class="text-gray-600">State-of-the-art sound systems, comfortable seating, and crystal-clear projection quality.</p>
    </div>
  </div>
</section>

<%
// Create a map of theater IDs to theater names
Map<Integer, String> theaterNameMap = new HashMap<>();
for (Theater theater : allTheaters) {
    theaterNameMap.put(theater.getTheaterId(), theater.getName());
}
%>

<!-- Testimonials -->
<section class="bg-gray-900 py-16">
  <div class="max-w-6xl mx-auto px-6 text-center text-white">
    <h2 class="text-3xl font-bold mb-10">What People Say</h2>
    <div class="swiper testimonials-slider">
      <div class="swiper-wrapper">
        <%
        int reviewCount = 0;
        for(Review review : allReviews) {
            if(reviewCount >= 6) break;
        %>
        <div class="swiper-slide">
          <div class="bg-gray-800 p-6 rounded-xl shadow-lg border border-gray-700 h-full">
            <% if(review.getUserImage() != null && !review.getUserImage().isEmpty()) { %>
                <img src="<%= review.getUserImage() %>" alt="<%= review.getUserName() %>" class="w-20 h-20 rounded-full mx-auto mb-4 object-cover border-2 border-blue-500">
            <% } else { %>
                <div class="w-20 h-20 rounded-full mx-auto mb-4 bg-gradient-to-br from-blue-500 to-purple-600 flex items-center justify-center text-white text-2xl font-bold border-2 border-blue-400">
                    <%= review.getUserName().substring(0, 1).toUpperCase() %>
                </div>
            <% } %>
            <div class="flex justify-center mb-3">
              <% 
              int rating = (int) Math.round(review.getRating());
              for(int i = 1; i <= 5; i++) { 
              %>
                <span class="text-<%= i <= rating ? "yellow" : "gray" %>-400 text-sm">★</span>
              <% } %>
            </div>
            <p class="italic mb-4 text-gray-300">"<%= review.getReviewText() %>"</p>
            <h4 class="font-semibold text-white"><%= review.getUserName() %></h4>
            <span class="text-sm text-gray-400">
                <%= theaterNameMap.get(review.getTheaterId()) != null ? 
                    theaterNameMap.get(review.getTheaterId()) : 
                    "Theater #" + review.getTheaterId() %>
            </span>
          </div>
        </div>
        <%
            reviewCount++;
        }
        
        if (allReviews.isEmpty()) {
        %>
        <div class="swiper-slide">
          <div class="bg-gray-800 p-6 rounded-xl shadow-lg border border-gray-700 h-full">
            <div class="w-20 h-20 rounded-full mx-auto mb-4 bg-gray-700 flex items-center justify-center text-gray-400 text-2xl">
                👤
            </div>
            <p class="italic mb-4 text-gray-400">"Be the first to share your experience with us!"</p>
            <h4 class="font-semibold text-gray-300">No Reviews Yet</h4>
            <span class="text-sm text-gray-500">Share your thoughts after your visit</span>
          </div>
        </div>
        <%
        }
        %>
      </div>
      <div class="swiper-pagination mt-6"></div>
    </div>
  </div>
</section>

<script>
  const swiper = new Swiper(".testimonials-slider", {
    slidesPerView: 1,
    spaceBetween: 20,
    loop: true,
    autoplay: { delay: 4000, disableOnInteraction: false },
    pagination: { el: ".swiper-pagination", clickable: true },
    breakpoints: { 
      640: { slidesPerView: 1 }, 
      768: { slidesPerView: 2 },
      1024: { slidesPerView: 3 } 
    },
  });
</script>



<script>
  // Tab switching logic
  const tabs = document.querySelectorAll(".tab-btn");
  const panels = document.querySelectorAll(".tab-panel");

  tabs.forEach(btn => {
    btn.addEventListener("click", () => {
      // Remove active styles from all tabs
      tabs.forEach(b => {
        b.classList.remove("border-blue-600", "text-blue-600", "font-semibold");
        b.classList.add("text-gray-600");
      });
      
      // Hide all panels
      panels.forEach(p => p.classList.add("hidden"));
      
      // Activate clicked tab
      btn.classList.add("border-blue-600", "text-blue-600", "font-semibold");
      btn.classList.remove("text-gray-600");
      
      // Show corresponding panel
      document.getElementById(btn.dataset.tab).classList.remove("hidden");
    });
  });
</script>

<jsp:include page="layout/footer.jsp" />