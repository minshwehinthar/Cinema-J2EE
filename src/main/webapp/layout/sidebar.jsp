<aside id="logo-sidebar" 
       class="fixed top-0 left-0 z-40 w-64 h-screen transition-transform -translate-x-full sm:translate-x-0" 
       aria-label="Sidebar">

   <div class="h-full px-3 py-4 overflow-y-auto bg-white border-r border-gray-200 flex flex-col">
      
      <!-- Logo -->
      <a href="index.jsp" class="flex items-center px-2.5 mb-8">
         <img src="assets/img/cinema-logo.jpg" class="h-8 w-8 mr-2" alt="Cinema Logo"/>
         <span class="self-center text-xl font-semibold text-gray-800">J-Seven</span>
      </a>

      <!-- Menu -->
      <ul class="space-y-2 font-medium flex-1">
         <li>
            <a href="index.jsp" class="flex items-center p-2 text-gray-700 rounded-lg hover:bg-sky-100 hover:text-sky-700">
               <i class="fa-solid fa-chart-line w-5 h-5 text-gray-500 group-hover:text-sky-700"></i>
               <span class="ms-3">Dashboard</span>
            </a>
         </li>

         <li>
            <a href="booked.jsp" class="flex items-center p-2 text-gray-700 rounded-lg hover:bg-sky-100 hover:text-sky-700">
               <i class="fa-solid fa-ticket w-5 h-5 text-gray-500 group-hover:text-sky-700"></i>
               <span class="ms-3">Booking List</span>
            </a>
         </li>

         <li>
            <a href="food-lists.jsp" class="flex items-center p-2 text-gray-700 rounded-lg hover:bg-sky-100 hover:text-sky-700">
               <i class="fa-solid fa-burger w-5 h-5 text-gray-500 group-hover:text-sky-700"></i>
               <span class="ms-3">Food List</span>
            </a>
         </li>

         <li>
            <a href="users.jsp" class="flex items-center p-2 text-gray-700 rounded-lg hover:bg-sky-100 hover:text-sky-700">
               <i class="fa-solid fa-users w-5 h-5 text-gray-500 group-hover:text-sky-700"></i>
               <span class="ms-3">Users</span>
            </a>
         </li>

         <li>
            <a href="employees.jsp" class="flex items-center p-2 text-gray-700 rounded-lg hover:bg-sky-100 hover:text-sky-700">
               <i class="fa-solid fa-user-tie w-5 h-5 text-gray-500 group-hover:text-sky-700"></i>
               <span class="ms-3">Theaters</span>
            </a>
         </li>
         <li>
            <a href="pendingOrders.jsp" class="flex items-center p-2 text-gray-700 rounded-lg hover:bg-sky-100 hover:text-sky-700">
               <i class="fa-solid fa-user-tie w-5 h-5 text-gray-500 group-hover:text-sky-700"></i>
               <span class="ms-3">Order Pending</span>
            </a>
         </li>
         <li>
            <a href="completedOrders.jsp" class="flex items-center p-2 text-gray-700 rounded-lg hover:bg-sky-100 hover:text-sky-700">
               <i class="fa-solid fa-user-tie w-5 h-5 text-gray-500 group-hover:text-sky-700"></i>
               <span class="ms-3">Order Completed</span>
            </a>
         </li>
         <li>
            <a href="order-history.jsp" class="flex items-center p-2 text-gray-700 rounded-lg hover:bg-sky-100 hover:text-sky-700">
               <i class="fa-solid fa-user-tie w-5 h-5 text-gray-500 group-hover:text-sky-700"></i>
               <span class="ms-3">Order History</span>
            </a>
         </li>
      </ul>

      <!-- Logout (sticks at bottom) -->
      <div class="mt-auto">
         <a href="logout" class="flex items-center p-2 text-red-600 rounded-lg hover:bg-red-100">
            <i class="fa-solid fa-right-from-bracket w-5 h-5"></i>
            <span class="ms-3">Logout</span>
         </a>
      </div>

   </div>
</aside>
