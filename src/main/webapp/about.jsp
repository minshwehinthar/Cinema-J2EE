<jsp:include page="layout/JSPHeader.jsp"/>
<jsp:include page="layout/header.jsp"/>

<%@ page import="java.util.List" %>
<%@ page import="com.demo.dao.ReviewDAO" %>
<%@ page import="com.demo.model.Review" %>
<%
    // Get real review data using existing DAO methods
    ReviewDAO reviewDao = new ReviewDAO();
    List<Review> allReviews = reviewDao.getAllReviews();
    List<Review> featuredReviews = allReviews.size() > 6 ? allReviews.subList(0, 6) : allReviews;
    
    // Calculate metrics manually since getReviewStatistics() doesn't exist
    int totalReviews = allReviews.size();
    int positiveReviews = 0;
    int totalRating = 0;
    
    for (Review review : allReviews) {
        if ("yes".equals(review.getIsGood())) {
            positiveReviews++;
        }
        totalRating += review.getRating();
    }
    
    double averageRating = totalReviews > 0 ? (double) totalRating / totalReviews : 0;
    int satisfactionRate = totalReviews > 0 ? (positiveReviews * 100) / totalReviews : 0;

    // Defaults for Cinezy Cinema
    String reviewScore = (String) request.getAttribute("reviewScore");
    if (reviewScore == null) reviewScore = String.format("%.1f/5 from %d reviews", averageRating, totalReviews);

    String heroTitle = (String) request.getAttribute("heroTitle");
    if (heroTitle == null) heroTitle = "Experience Cinema Like Never Before";

    String heroDesc = (String) request.getAttribute("heroDescription");
    if (heroDesc == null) heroDesc = "At Cinezy, we bring stories to life with state-of-the-art technology, luxurious comfort, and unforgettable movie experiences for every film lover.";

    String heroImage = (String) request.getAttribute("heroImage");
    if (heroImage == null) heroImage = "https://plus.unsplash.com/premium_photo-1683740128672-7f1a4b824f5e?w=900&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8OXx8Y2luZW1hfGVufDB8fDB8fHww";

    Object userObj = session.getAttribute("user");
    String ctaHref = (userObj == null) ? request.getContextPath() + "/account/sign-in" : request.getContextPath() + "/movies";
%>

<section class="relative bg-gray-50 py-16">
  <div class="mx-auto max-w-7xl px-6 lg:px-8 grid grid-cols-1 lg:grid-cols-2 gap-12 items-center">

    <!-- Left Content -->
    <div class="space-y-6">
      <!-- Reviews -->
      <div class="flex items-center gap-3">
        <div class="flex text-yellow-400">
          <% for(int i = 1; i <= 5; i++) { %>
            <svg xmlns="http://www.w3.org/2000/svg" class="w-5 h-5 fill-current <%= i <= Math.round(averageRating) ? "text-yellow-400" : "text-gray-300" %>" viewBox="0 0 20 20">
              <path d="M10 15l-5.878 3.09 1.122-6.545L.488 6.91l6.564-.955L10 0l2.948 5.955 6.564.955-4.756 4.635 1.122 6.545z"/>
            </svg>
          <% } %>
        </div>
        <span class="text-gray-600 text-lg font-medium"><%= reviewScore %></span>
      </div>

      <!-- Title -->
      <h1 class="text-4xl lg:text-5xl font-bold text-gray-900 leading-tight">
        <%= heroTitle %>
      </h1>

      <!-- Description -->
      <p class="text-lg text-gray-600 max-w-xl">
        <%= heroDesc %>
      </p>

      <!-- Buttons -->
      <div class="flex gap-4 pt-4">
        <a href="movies.jsp" 
           class="inline-flex items-center px-6 py-3 rounded-xl bg-red-600 text-white font-semibold shadow hover:bg-red-700 transition">
          Book Tickets
          <svg xmlns="http://www.w3.org/2000/svg" class="ml-2 h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7"/>
          </svg>
        </a>
        
      </div>
    </div>

    <!-- Right Image -->
    <div class="flex justify-center lg:justify-end">
      <img src="<%= heroImage %>" alt="Cinezy Cinema Experience" class="rounded-2xl shadow-xl max-w-xl w-full object-cover"/>
    </div>

  </div>
</section>

<%
    // Metrics data for Cinezy Cinema
    class Metric {
        String value, title, desc;
        Metric(String v, String t, String d) { value=v; title=t; desc=d; }
    }

    java.util.List<Metric> metrics = new java.util.ArrayList<>();
    metrics.add(new Metric(totalReviews + "+", "Happy Moviegoers", "Real customers who've shared their experiences through our review system."));
    metrics.add(new Metric(satisfactionRate + "%", "Satisfaction Rate", "Based on " + positiveReviews + " positive reviews from our valued cinema guests."));
    metrics.add(new Metric("12", "Premium Screens", "State-of-the-art screens with 4K laser projection and immersive sound technology."));
    metrics.add(new Metric(String.format("%.1f", averageRating), "Average Rating", "Consistent high ratings across picture quality, sound, and comfort."));

    String metricsImage = "https://images.unsplash.com/photo-1595769816263-9b910be24d5f?ixlib=rb-4.0.3&auto=format&fit=crop&w=2070&q=80";
%>

<section class="bg-white py-20">
  <div class="mx-auto max-w-7xl px-6 lg:px-8 grid grid-cols-1 lg:grid-cols-2 gap-16 items-center">

    <!-- Left Image -->
    <div class="flex justify-center lg:justify-start">
      <img src="<%= metricsImage %>" alt="Cinezy Cinema Interior" class="rounded-2xl shadow-xl max-w-md w-full object-cover"/>
    </div>

    <!-- Right Metrics -->
    <div class="grid grid-cols-1 sm:grid-cols-2 gap-10">
      <%
        for(Metric m : metrics) {
      %>
        <div class="bg-gray-50 rounded-xl p-6 shadow hover:shadow-lg transition">
          <div class="text-4xl font-bold text-red-600"><%= m.value %></div>
          <h3 class="text-lg font-semibold text-gray-900 mt-2"><%= m.title %></h3>
          <p class="text-sm text-gray-600 mt-3"><%= m.desc %></p>
        </div>
      <%
        }
      %>
    </div>

  </div>
</section>

<section class="bg-white py-20">
  <div class="max-w-7xl mx-auto px-6 lg:px-8">
    
    <!-- Header -->
    <div class="text-center mx-auto mb-16">
      <h2 class="text-3xl md:text-5xl font-bold text-gray-900">
        Premium Cinema Experience at Cinezy
      </h2>
      <p class="mt-4 text-lg text-gray-600">
        Discover what makes Cinezy the ultimate destination for movie lovers with our exceptional features and services.
      </p>
    </div>

    <!-- Features Grid -->
    <div class="grid grid-cols-1 lg:grid-cols-3 gap-12 items-start">
      
      <!-- Features List -->
      <div class="lg:col-span-2 grid grid-cols-1 sm:grid-cols-2 gap-8">
        
        <!-- Feature Card -->
        <div class="flex gap-4 p-6 bg-gray-50 rounded-xl shadow-sm hover:shadow-md transition">
          <div class="flex-shrink-0 text-red-600 text-3xl">
            <svg xmlns="http://www.w3.org/2000/svg" class="w-8 h-8" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 4v16M17 4v16M3 8h4m10 0h4M3 12h18M3 16h4m10 0h4M4 20h16a1 1 0 001-1V5a1 1 0 00-1-1H4a1 1 0 00-1 1v14a1 1 0 001 1z"/>
            </svg>
          </div>
          <div>
            <h3 class="text-xl font-semibold text-gray-900">4K Laser Projection</h3>
            <p class="mt-2 text-sm text-gray-600">
              Crystal-clear 4K laser projection for the sharpest, most vibrant picture quality available.
            </p>
          </div>
        </div>

        <!-- Feature Card -->
        <div class="flex gap-4 p-6 bg-gray-50 rounded-xl shadow-sm hover:shadow-md transition">
          <div class="flex-shrink-0 text-red-600 text-3xl">
            <svg xmlns="http://www.w3.org/2000/svg" class="w-8 h-8" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15.536 8.464a5 5 0 010 7.072m2.828-9.9a9 9 0 010 12.728M5.586 15.536a5 5 0 001.414 1.414m-2.828-9.9a9 9 0 012.728-2.728"/>
            </svg>
          </div>
          <div>
            <h3 class="text-xl font-semibold text-gray-900">Dolby Atmos Sound</h3>
            <p class="mt-2 text-sm text-gray-600">
              Immersive Dolby Atmos sound system that puts you right in the middle of the action.
            </p>
          </div>
        </div>

        <!-- Feature Card -->
        <div class="flex gap-4 p-6 bg-gray-50 rounded-xl shadow-sm hover:shadow-md transition">
          <div class="flex-shrink-0 text-red-600 text-3xl">
            <svg xmlns="http://www.w3.org/2000/svg" class="w-8 h-8" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 3v4M3 5h4M6 17v4m-2-2h4m5-16l2.286 6.857L21 12l-5.714 2.143L13 21l-2.286-6.857L5 12l5.714-2.143L13 3z"/>
            </svg>
          </div>
          <div>
            <h3 class="text-xl font-semibold text-gray-900">Luxury Recliners</h3>
            <p class="mt-2 text-sm text-gray-600">
              Premium leather recliners with extra legroom and personal cup holders for maximum comfort.
            </p>
          </div>
        </div>

        <!-- Feature Card -->
        <div class="flex gap-4 p-6 bg-gray-50 rounded-xl shadow-sm hover:shadow-md transition">
          <div class="flex-shrink-0 text-red-600 text-3xl">
            <svg xmlns="http://www.w3.org/2000/svg" class="w-8 h-8" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z"/>
            </svg>
          </div>
          <div>
            <h3 class="text-xl font-semibold text-gray-900">Gourmet Snack Bar</h3>
            <p class="mt-2 text-sm text-gray-600">
              Premium snacks, gourmet popcorn, and artisanal beverages for the complete cinema experience.
            </p>
          </div>
        </div>
      </div>

      <!-- Feature Image -->
      <div class="flex justify-center lg:justify-end">
        <img 
          src="https://images.unsplash.com/photo-1560169897-fc0cdbdfa4d5?ixlib=rb-4.0.3&auto=format&fit=crop&w=2072&q=80" 
          alt="Cinezy Cinema Features"
          class="rounded-2xl shadow-xl max-w-sm lg:max-w-md"
        />
      </div>

    </div>
  </div>
</section>

<section class="bg-white py-20">
  <div class="max-w-7xl mx-auto px-6 lg:px-8">
    <!-- Header -->
    <div class="text-center mb-16">
      <h2 class="text-4xl md:text-5xl font-bold text-gray-900">
        Meet the Cinezy Team
      </h2>
      <p class="mt-4 text-lg text-gray-600 mx-auto">
        The passionate movie enthusiasts dedicated to creating magical cinema experiences.
      </p>
    </div>

    <!-- Team Grid -->
    <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-12">
      
      <!-- Team Member -->
      <div class="bg-gray-50 rounded-xl shadow hover:shadow-lg transition overflow-hidden">
        <img class="w-full h-64 object-cover" src="https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?ixlib=rb-4.0.3&auto=format&fit=crop&w=1974&q=80" alt="Alex Morgan">
        <div class="p-6 text-center">
          <h3 class="text-xl font-semibold text-gray-900">Alex Morgan</h3>
          <p class="text-gray-600 text-sm mt-1">Cinema Operations Manager</p>
          <a href="#" class="inline-block mt-3 text-red-600 hover:text-red-800">
            <img src="https://cdn.prod.website-files.com/67721265f59069a5268af325/677ab4ee0e69e77797d0b49f_linkedin%20icon.svg" alt="LinkedIn" class="w-6 h-6 inline-block">
          </a>
        </div>
      </div>

      <!-- Team Member -->
      <div class="bg-gray-50 rounded-xl shadow hover:shadow-lg transition overflow-hidden">
        <img class="w-full h-64 object-cover" src="https://images.unsplash.com/photo-1573497019940-1c28c88b4f3e?q=80&w=1287&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D" alt="Sarah Chen">
        <div class="p-6 text-center">
          <h3 class="text-xl font-semibold text-gray-900">Sarah Chen</h3>
          <p class="text-gray-600 text-sm mt-1">Head of Customer Experience</p>
          <a href="#" class="inline-block mt-3 text-red-600 hover:text-red-800">
            <img src="https://cdn.prod.website-files.com/67721265f59069a5268af325/677ab4ee0e69e77797d0b49f_linkedin%20icon.svg" alt="LinkedIn" class="w-6 h-6 inline-block">
          </a>
        </div>
      </div>

      <!-- Team Member -->
      <div class="bg-gray-50 rounded-xl shadow hover:shadow-lg transition overflow-hidden">
        <img class="w-full h-64 object-cover" src="https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?ixlib=rb-4.0.3&auto=format&fit=crop&w=2070&q=80" alt="Marcus Rodriguez">
        <div class="p-6 text-center">
          <h3 class="text-xl font-semibold text-gray-900">Marcus Rodriguez</h3>
          <p class="text-gray-600 text-sm mt-1">Technical Director</p>
          <a href="#" class="inline-block mt-3 text-red-600 hover:text-red-800">
            <img src="https://cdn.prod.website-files.com/67721265f59069a5268af325/677ab4ee0e69e77797d0b49f_linkedin%20icon.svg" alt="LinkedIn" class="w-6 h-6 inline-block">
          </a>
        </div>
      </div>
      
    </div>
  </div>
</section>

<section class="bg-gray-50 py-20">
  <div class="max-w-7xl mx-auto px-6 lg:px-8">
    
    <!-- Header -->
    <div class="text-center mx-auto mb-12">
      <h2 class="text-4xl md:text-5xl font-bold text-gray-900">
        What Our Movie Lovers Are Saying
      </h2>
      <p class="mt-4 text-lg text-gray-600">
        Hear from our audience about their unforgettable experiences at Cinezy Cinema.
      </p>
    </div>

    <!-- Testimonials Grid -->
    <div class="grid gap-8 sm:grid-cols-2 lg:grid-cols-3">
      <%
        if (featuredReviews.isEmpty()) {
          // Fallback testimonials if no reviews exist
          String[] fallbackTestimonials = {
            "Cinezy has completely transformed my movie-going experience. The 4K projection and Dolby Atmos sound make every film feel like a premiere!",
            "I've been coming to Cinezy for years, and it keeps getting better. The staff is always friendly and the theaters are spotless.",
            "The gourmet snack bar and comfortable seating make Cinezy our go-to cinema for date nights. Absolutely love it!"
          };
          String[] fallbackNames = {"James Wilson", "Emily Parker", "Michael Brown"};
          String[] fallbackRoles = {"Movie Enthusiast", "Film Student", "Regular Customer"};
          
          for(int i = 0; i < 3; i++) {
      %>
            <div class="bg-white rounded-2xl shadow p-6 flex flex-col justify-between">
              <div class="flex items-center gap-2 mb-4">
                <div class="flex text-yellow-400">
                  <% for(int j = 0; j < 5; j++) { %>
                    <svg xmlns="http://www.w3.org/2000/svg" class="w-5 h-5 fill-current" viewBox="0 0 20 20">
                      <path d="M10 15l-5.878 3.09 1.122-6.545L.488 6.91l6.564-.955L10 0l2.948 5.955 6.564.955-4.756 4.635 1.122 6.545z"/>
                    </svg>
                  <% } %>
                </div>
              </div>
              <p class="text-gray-600 text-lg">
                "<%= fallbackTestimonials[i] %>"
              </p>
              <div class="flex items-center mt-6">
                <div class="w-12 h-12 bg-red-500 rounded-full flex items-center justify-center text-white font-bold text-lg">
                  <%= fallbackNames[i].charAt(0) %>
                </div>
                <div class="ml-4">
                  <h3 class="text-lg font-semibold text-gray-900"><%= fallbackNames[i] %></h3>
                  <p class="text-sm text-gray-500"><%= fallbackRoles[i] %></p>
                </div>
              </div>
            </div>
      <%
          }
        } else {
          for(Review review : featuredReviews) {
            String fallbackInitial = review.getUserName() != null && !review.getUserName().isEmpty() ? 
                                    review.getUserName().substring(0, 1).toUpperCase() : "U";
      %>
            <div class="bg-white rounded-2xl shadow p-6 flex flex-col justify-between">
              <div class="flex items-center gap-2 mb-4">
                <div class="flex text-yellow-400">
                  <% for(int i = 1; i <= 5; i++) { %>
                    <svg xmlns="http://www.w3.org/2000/svg" class="w-5 h-5 fill-current <%= i <= review.getRating() ? "text-yellow-400" : "text-gray-300" %>" viewBox="0 0 20 20">
                      <path d="M10 15l-5.878 3.09 1.122-6.545L.488 6.91l6.564-.955L10 0l2.948 5.955 6.564.955-4.756 4.635 1.122 6.545z"/>
                    </svg>
                  <% } %>
                </div>
                <span class="text-gray-500 text-sm"><%= review.getRating() %>/5</span>
              </div>
              <p class="text-gray-600 text-lg">
                "<%= review.getReviewText() %>"
              </p>
              <div class="flex items-center mt-6">
                <% if(review.getUserImage() != null) { %>
                  <img src="<%= review.getUserImage() %>" alt="<%= review.getUserName() %>" class="w-12 h-12 rounded-full object-cover">
                <% } else { %>
                  <div class="w-12 h-12 bg-red-500 rounded-full flex items-center justify-center text-white font-bold text-lg">
                    <%= fallbackInitial %>
                  </div>
                <% } %>
                <div class="ml-4">
                  <h3 class="text-lg font-semibold text-gray-900"><%= review.getUserName() %></h3>
                  <p class="text-sm text-gray-500">
                    <%= "yes".equals(review.getIsGood()) ? "Positive Experience" : "Constructive Feedback" %>
                  </p>
                </div>
              </div>
            </div>
      <%
          }
        }
      %>
    </div>
  </div>
</section>

<jsp:include page="layout/footer.jsp"/>
<jsp:include page="layout/JSPFooter.jsp"/>