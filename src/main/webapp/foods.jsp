<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List"%>
<%@ page import="com.demo.model.FoodItem"%>
<%@ page import="com.demo.dao.FoodDAO"%>

<jsp:include page="layout/JSPHeader.jsp"/>

<body class="flex flex-col min-h-screen bg-gray-50 font-sans">

  <!-- Header -->
  <jsp:include page="layout/header.jsp"/>

  <!-- Main Content -->
  <main class="flex-grow container mx-auto px-4 py-12">

    <!-- Page Title -->
    <h1 class="text-4xl font-extrabold text-center text-gray-800 mb-12">Our Menu</h1>

    <!-- Food Grid -->
    <div class="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-8">
      <%
        FoodDAO dao = new FoodDAO();
        List<FoodItem> foods = dao.getAllFoods();
        if (foods != null && !foods.isEmpty()) {
          for (FoodItem f : foods) {
      %>

      <!-- Food Card -->
      <div class="bg-white rounded-2xl overflow-hidden flex flex-col shadow-sm">

        <!-- Image -->
        <div class="flex justify-center items-center h-52 p-4">
          <img src="<%=f.getImage()%>" alt="<%=f.getName()%>" class="max-h-full object-contain">
        </div>

        <!-- Content -->
        <div class="p-5 flex flex-col flex-grow">

          <!-- Price -->
          <p class="text-gray-600 text-sm mb-1">
            From <span class="font-semibold text-gray-900">$<%=f.getPrice()%></span>
          </p>

          <!-- Food Name -->
          <h2 class="text-lg font-semibold text-gray-900 mb-2 line-clamp-1"><%=f.getName()%></h2>

          <!-- Rating -->
          <div class="flex items-center mb-2">
            <% 
              int fullStars = (int) f.getRating(); 
              boolean halfStar = (f.getRating() - fullStars) >= 0.5;
              int emptyStars = 5 - fullStars - (halfStar ? 1 : 0);

              for(int i=0; i<fullStars; i++) { %>
                <svg xmlns="http://www.w3.org/2000/svg" class="w-4 h-4 text-yellow-400" viewBox="0 0 20 20" fill="currentColor">
                  <path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.286 3.974a1 1 0 00.95.69h4.178c.969 0 1.371 1.24.588 1.81l-3.385 2.46a1 1 0 00-.364 1.118l1.287 3.974c.3.921-.755 1.688-1.54 1.118l-3.385-2.46a1 1 0 00-1.176 0l-3.385 2.46c-.785.57-1.84-.197-1.54-1.118l1.287-3.974a1 1 0 00-.364-1.118L2.097 9.401c-.783-.57-.38-1.81.588-1.81h4.178a1 1 0 00.95-.69l1.286-3.974z"/>
                </svg>
            <% } 
              if(halfStar) { %>
                <svg xmlns="http://www.w3.org/2000/svg" class="w-4 h-4 text-yellow-400" viewBox="0 0 20 20" fill="currentColor">
                  <path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.286 3.974a1 1 0 00.95.69h4.178c.969 0 1.371 1.24.588 1.81l-3.385 2.46a1 1 0 00-.364 1.118l1.287 3.974c.3.921-.755 1.688-1.54 1.118l-3.385-2.46a1 1 0 00-.588-.236V2.927z"/>
                </svg>
            <% } 
              for(int i=0; i<emptyStars; i++) { %>
                <svg xmlns="http://www.w3.org/2000/svg" class="w-4 h-4 text-gray-300" viewBox="0 0 20 20" fill="currentColor">
                  <path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.286 3.974a1 1 0 00.95.69h4.178c.969 0 1.371 1.24.588 1.81l-3.385 2.46a1 1 0 00-.364 1.118l1.287 3.974c.3.921-.755 1.688-1.54 1.118l-3.385-2.46a1 1 0 00-1.176 0l-3.385 2.46c-.785.57-1.84-.197-1.54-1.118l1.287-3.974a1 1 0 00-.364-1.118L2.097 9.401c-.783-.57-.38-1.81.588-1.81h4.178a1 1 0 00.95-.69l1.286-3.974z"/>
                </svg>
            <% } %>
          </div>

          <!-- Description -->
          <p class="text-gray-500 text-sm mb-4 line-clamp-2"><%=f.getDescription()%></p>

          <!-- Button -->
          <div class="mt-auto">
            <a href="foods?action=details&id=<%=f.getId()%>"
               class="block w-full text-center border border-gray-300 hover:border-gray-400 text-gray-800 font-medium text-sm py-2 rounded-lg transition">
              View Details
            </a>
          </div>
        </div>
      </div>

      <%
          }
        } else {
      %>
        <p class="col-span-full text-center text-gray-500 text-lg">No food items found!</p>
      <% } %>
    </div>
  </main>

  <!-- Footer -->
  <footer class="bg-white text-gray-700">
    <jsp:include page="layout/footer.jsp"/>
  </footer>

</body>

<jsp:include page="layout/JSPFooter.jsp"/>
