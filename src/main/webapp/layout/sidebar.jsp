<%@ page import="com.demo.model.User" %>
<%@ page import="java.util.Base64"%>
<%
    User user = (User) session.getAttribute("user");
    String role = (user != null) ? user.getRole() : "";
    
    // Get current page to determine active state
    String currentPage = request.getRequestURI();
    String pageName = currentPage.substring(currentPage.lastIndexOf("/") + 1);
%>

<aside id="logo-sidebar" 
       class="fixed top-0 left-0 z-40 w-64 h-screen transition-transform -translate-x-full sm:translate-x-0" 
       aria-label="Sidebar">

   <div class="h-full px-3 py-4 overflow-y-auto bg-white border-r border-gray-200 flex flex-col">
      
      <!-- Logo with red theme -->
      <a href="index.jsp" class="flex items-center px-2.5 mb-8">
         <img src="assets/img/cinema-logo.jpg" class="h-8 w-8 mr-2" alt="Cinema Logo"/>
         <span class="self-center text-xl font-bold text-red-700">CINEZY</span>
      </a>

      <!-- Menu -->
      <ul class="space-y-1 font-medium flex-1">

         <!-- Dashboard: visible to all roles -->
         <li>
            <a href="index.jsp" class="flex items-center p-3 text-gray-700 rounded-lg hover:bg-red-50 hover:text-red-700 transition-all duration-200 <%= "index.jsp".equals(pageName) ? "bg-red-50 text-red-700 border-r-2 border-red-600" : "" %>">
               <i class="fa-solid fa-chart-line w-5 h-5 <%= "index.jsp".equals(pageName) ? "text-red-600" : "text-gray-500" %>"></i>
               <span class="ms-3 font-medium">Dashboard</span>
            </a>
         </li>

         <!-- Booking List: visible to all roles -->
         <li>
            <a href="adminBookings.jsp" class="flex items-center p-3 text-gray-700 rounded-lg hover:bg-red-50 hover:text-red-700 transition-all duration-200 <%= "adminBookings.jsp".equals(pageName) ? "bg-red-50 text-red-700 border-r-2 border-red-600" : "" %>">
               <i class="fa-solid fa-ticket w-5 h-5 <%= "adminBookings.jsp".equals(pageName) ? "text-red-600" : "text-gray-500" %>"></i>
               <span class="ms-3 font-medium">Booking List</span>
            </a>
         </li>

         <% if("admin".equalsIgnoreCase(role)) { %>
            <!-- Movies (Admin only) -->
            <li>
               <a href="moviesList.jsp" class="flex items-center p-3 text-gray-700 rounded-lg hover:bg-red-50 hover:text-red-700 transition-all duration-200 <%= "moviesList.jsp".equals(pageName) ? "bg-red-50 text-red-700 border-r-2 border-red-600" : "" %>">
                  <i class="fa-solid fa-film w-5 h-5 <%= "moviesList.jsp".equals(pageName) ? "text-red-600" : "text-gray-500" %>"></i>
                  <span class="ms-3 font-medium">Movies</span>
               </a>
            </li>

            <!-- Food List (Admin only) -->
            <li>
               <a href="food-lists.jsp" class="flex items-center p-3 text-gray-700 rounded-lg hover:bg-red-50 hover:text-red-700 transition-all duration-200 <%= "food-lists.jsp".equals(pageName) ? "bg-red-50 text-red-700 border-r-2 border-red-600" : "" %>">
                  <i class="fa-solid fa-burger w-5 h-5 <%= "food-lists.jsp".equals(pageName) ? "text-red-600" : "text-gray-500" %>"></i>
                  <span class="ms-3 font-medium">Food List</span>
               </a>
            </li>

            <!-- Users (Admin only) -->
            <li>
               <a href="users.jsp" class="flex items-center p-3 text-gray-700 rounded-lg hover:bg-red-50 hover:text-red-700 transition-all duration-200 <%= "users.jsp".equals(pageName) ? "bg-red-50 text-red-700 border-r-2 border-red-600" : "" %>">
                  <i class="fa-solid fa-users w-5 h-5 <%= "users.jsp".equals(pageName) ? "text-red-600" : "text-gray-500" %>"></i>
                  <span class="ms-3 font-medium">Users</span>
               </a>
            </li>

            <!-- Theaters (Admin only) -->
            <li>
               <a href="employees.jsp" class="flex items-center p-3 text-gray-700 rounded-lg hover:bg-red-50 hover:text-red-700 transition-all duration-200 <%= "employees.jsp".equals(pageName) ? "bg-red-50 text-red-700 border-r-2 border-red-600" : "" %>">
                  <i class="fa-solid fa-user-tie w-5 h-5 <%= "employees.jsp".equals(pageName) ? "text-red-600" : "text-gray-500" %>"></i>
                  <span class="ms-3 font-medium">Theaters</span>
               </a>
            </li>
            
            <!-- Seat Price (Admin only) -->
            <li>
               <a href="manageSeatPrice.jsp" class="flex items-center p-3 text-gray-700 rounded-lg hover:bg-red-50 hover:text-red-700 transition-all duration-200 <%= "manageSeatPrice.jsp".equals(pageName) ? "bg-red-50 text-red-700 border-r-2 border-red-600" : "" %>">
                  <i class="fa-solid fa-couch w-5 h-5 <%= "manageSeatPrice.jsp".equals(pageName) ? "text-red-600" : "text-gray-500" %>"></i>
                  <span class="ms-3 font-medium">Seat Price</span>
               </a>
            </li>
            
         <% } %>
         
         <% if("theateradmin".equalsIgnoreCase(role)) { %>
            <!-- Time Management (Theater Admin only) -->
            <li>
               <a href="addTimeslots.jsp" class="flex items-center p-3 text-gray-700 rounded-lg hover:bg-red-50 hover:text-red-700 transition-all duration-200 <%= "addTimeslots.jsp".equals(pageName) ? "bg-red-50 text-red-700 border-r-2 border-red-600" : "" %>">
                  <i class="fa-solid fa-clock w-5 h-5 <%= "addTimeslots.jsp".equals(pageName) ? "text-red-600" : "text-gray-500" %>"></i>
                  <span class="ms-3 font-medium">Time Slots</span>
               </a>
            </li>
            
            <!-- Movie Selection (Theater Admin only) -->
            <li>
               <a href="theateradminpickmovies.jsp" class="flex items-center p-3 text-gray-700 rounded-lg hover:bg-red-50 hover:text-red-700 transition-all duration-200 <%= "theateradminpickmovies.jsp".equals(pageName) ? "bg-red-50 text-red-700 border-r-2 border-red-600" : "" %>">
                  <i class="fa-solid fa-film w-5 h-5 <%= "theateradminpickmovies.jsp".equals(pageName) ? "text-red-600" : "text-gray-500" %>"></i>
                  <span class="ms-3 font-medium">Select Movies</span>
               </a>
            </li>
         <% } %>

         <!-- Order Management Section -->
         <li class="pt-4 mt-4 border-t border-gray-200">
            <span class="px-3 text-xs font-semibold text-gray-500 uppercase tracking-wider">Order Management</span>
         </li>
         
         <!-- Pending Orders -->
         <li>
            <a href="pendingOrders.jsp" class="flex items-center p-3 text-gray-700 rounded-lg hover:bg-red-50 hover:text-red-700 transition-all duration-200 <%= "pendingOrders.jsp".equals(pageName) ? "bg-red-50 text-red-700 border-r-2 border-red-600" : "" %>">
               <i class="fa-solid fa-clock w-5 h-5 <%= "pendingOrders.jsp".equals(pageName) ? "text-red-600" : "text-gray-500" %>"></i>
               <span class="ms-3 font-medium">Pending Orders</span>

            </a>
         </li>
         
         <!-- Completed Orders -->
         <li>
            <a href="completedOrders.jsp" class="flex items-center p-3 text-gray-700 rounded-lg hover:bg-red-50 hover:text-red-700 transition-all duration-200 <%= "completedOrders.jsp".equals(pageName) ? "bg-red-50 text-red-700 border-r-2 border-red-600" : "" %>">
               <i class="fa-solid fa-check-circle w-5 h-5 <%= "completedOrders.jsp".equals(pageName) ? "text-red-600" : "text-gray-500" %>"></i>
               <span class="ms-3 font-medium">Completed Orders</span>
            </a>
         </li>
         
         <!-- Order History -->
         <li>
            <a href="order-history.jsp" class="flex items-center p-3 text-gray-700 rounded-lg hover:bg-red-50 hover:text-red-700 transition-all duration-200 <%= "order-history.jsp".equals(pageName) ? "bg-red-50 text-red-700 border-r-2 border-red-600" : "" %>">
               <i class="fa-solid fa-history w-5 h-5 <%= "order-history.jsp".equals(pageName) ? "text-red-600" : "text-gray-500" %>"></i>
               <span class="ms-3 font-medium">Order History</span>
            </a>
         </li>

      </ul>

<!-- User Profile & Logout Section -->
<div class="mt-auto pt-4 border-t border-gray-200">
    <!-- User Profile -->
    <a href="<%= "admin".equalsIgnoreCase(role) || "theateradmin".equalsIgnoreCase(role) ? "admin-profile.jsp" : "profile.jsp" %>" 
        class="flex items-center p-3 mb-2 text-gray-700 rounded-lg hover:bg-red-50 hover:text-red-700 transition-all duration-200 <%= ("admin-profile.jsp".equals(pageName) || "profile.jsp".equals(pageName)) ? "bg-red-50 text-red-700" : "" %>">
        
        <div class="flex-shrink-0 w-8 h-8 bg-red-100 rounded-full flex items-center justify-center overflow-hidden">
            <% if(user.getImage() != null && user.getImage().length > 0) { 
                String base64 = Base64.getEncoder().encodeToString(user.getImage());
                String type = (user.getImgtype() != null && !user.getImgtype().trim().isEmpty()) 
                    ? user.getImgtype().replace("image/", "").toLowerCase() 
                    : "png";
                String userImage = "data:image/" + type + ";base64," + base64;
            %>
                <img src="<%= userImage %>" 
                     alt="Profile" 
                     class="w-full h-full object-cover">
            <% } else { %>
                <i class="fa-solid fa-user text-red-600 text-sm"></i>
            <% } %>
        </div>
        
        <div class="ms-3">
            <div class="text-sm font-medium text-gray-900"><%= user != null ? user.getName() : "User" %></div>
            <div class="text-xs text-gray-500 capitalize"><%= role %></div>
        </div>
    </a>
    
    <!-- Logout -->
    <a href="logout" class="flex items-center p-3 text-red-600 rounded-lg hover:bg-red-100 transition-all duration-200">
        <i class="fa-solid fa-right-from-bracket w-5 h-5"></i>
        <span class="ms-3 font-medium">Logout</span>
    </a>
</div>
   </div>
</aside>

<!-- Mobile menu button (if needed elsewhere in your layout) -->
<button data-drawer-target="logo-sidebar" data-drawer-toggle="logo-sidebar" aria-controls="logo-sidebar" 
        type="button" class="inline-flex items-center p-2 mt-2 ms-3 text-sm text-gray-500 rounded-lg sm:hidden hover:bg-gray-100 focus:outline-none focus:ring-2 focus:ring-gray-200">
   <span class="sr-only">Open sidebar</span>
   <svg class="w-6 h-6" aria-hidden="true" fill="currentColor" viewBox="0 0 20 20" xmlns="http://www.w3.org/2000/svg">
      <path clip-rule="evenodd" fill-rule="evenodd" d="M2 4.75A.75.75 0 012.75 4h14.5a.75.75 0 010 1.5H2.75A.75.75 0 012 4.75zm0 10.5a.75.75 0 01.75-.75h7.5a.75.75 0 010 1.5h-7.5a.75.75 0 01-.75-.75zM2 10a.75.75 0 01.75-.75h14.5a.75.75 0 010 1.5H2.75A.75.75 0 012 10z"></path>
   </svg>
</button>