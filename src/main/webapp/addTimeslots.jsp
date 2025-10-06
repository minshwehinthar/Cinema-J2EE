<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="com.demo.model.User, com.demo.model.Timeslot" %>
<%@ page import="com.demo.dao.TimeslotDao, com.demo.dao.UserDAO" %>

<%
    User user = (User) session.getAttribute("user");
    if (user == null || !"theateradmin".equals(user.getRole())) {
        response.sendRedirect("login.jsp?msg=unauthorized");
        return;
    }

    UserDAO userDAO = new UserDAO();
    TimeslotDao timeslotDao = new TimeslotDao();

    Integer theaterId = userDAO.getTheaterIdByUserId(user.getUserId());
    ArrayList<Timeslot> timeslots = timeslotDao.getTimeslotsByTheater(theaterId);

    String msg = request.getParameter("msg");
%>

<jsp:include page="layout/JSPHeader.jsp"/>

<div class="flex min-h-screen bg-white">
    <!-- Sidebar -->
    <jsp:include page="layout/sidebar.jsp"/>

    <!-- Main Content -->
    <div class="flex-1 sm:ml-64">
        <jsp:include page="layout/AdminHeader.jsp"/>

       <div class="p-6">
       <!-- Breadcrumb -->
		<nav class="text-gray-500 text-sm mb-4" aria-label="Breadcrumb">
			<ol class="list-none p-0 inline-flex">
				<li><a href="index.jsp" class="hover:text-red-600">Home</a></li>
            <li><span class="mx-2">/</span></li>
            
            
				<li class="flex items-center text-gray-900 font-semibold">Add Timeslot
				</li>
			</ol>
		</nav>
       	 <h1 class="text-3xl font-bold text-gray-600 mb-8">Manage Timeslots</h1>

        <!-- Two Column Layout -->
        <div class="grid grid-cols-1 lg:grid-cols-2 gap-8 items-start">
            
            <!-- Left Column: Add Timeslot Form -->
            <div class="bg-white rounded-2xl p-6 border border-red-100 sticky top-6 self-start">
                <h2 class="text-xl font-semibold text-gray-900 mb-5 border-b border-red-200 pb-2">Add New Timeslot</h2>
                <form action="AddTimeslotServlet" method="post" class="space-y-4">
                    <input type="hidden" name="theaterId" value="<%=theaterId%>">

                    <div>
                        <label class="block text-gray-600 mb-1 font-medium">Start Time</label>
                        <div class="relative">
                            <input type="time" name="startTime" required
                                class="w-full border border-gray-300 rounded-lg px-3 py-2 pr-10 focus:outline-none focus:ring-2 focus:ring-red-400">
                            <!-- Clock Icon (Right side) -->
                            <svg xmlns="http://www.w3.org/2000/svg" 
                                class="absolute right-3 top-2.5 w-5 h-5 text-gray-500 pointer-events-none" 
                                fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" 
                                    d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
                            </svg>
                        </div>
                    </div>

                    <div>
                        <label class="block text-gray-600 mb-1 font-medium">End Time</label>
                        <div class="relative">
                            <input type="time" name="endTime" required
                                class="w-full border border-gray-300 rounded-lg px-3 py-2 pr-10 focus:outline-none focus:ring-2 focus:ring-red-400">
                            <!-- Clock Icon (Right side) -->
                            <svg xmlns="http://www.w3.org/2000/svg" 
                                class="absolute right-3 top-2.5 w-5 h-5 text-gray-500 pointer-events-none" 
                                fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" 
                                    d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
                            </svg>
                        </div>
                    </div>

                    <button type="submit"
                        class="w-full bg-red-600 text-white font-semibold px-4 py-2 rounded-lg hover:bg-red-700 transition duration-200">
                        + Add Timeslot
                    </button>
                </form>
            </div>

            <!-- Right Column: Existing Timeslots Table -->
            <div class="bg-white rounded-2xl p-6 border border-red-100 overflow-auto max-h-[80vh]">
                <h2 class="text-xl font-semibold text-gray-900 mb-5 border-b border-red-200 pb-2">Existing Timeslots</h2>

                <div class="overflow-x-auto">
                    <table class="min-w-full text-sm text-left text-gray-700">
                        <thead class="bg-red-50 text-red-700 uppercase text-xs font-semibold">
                            <tr>
                                <th class="px-4 py-2">Slot ID</th>
                                <th class="px-4 py-2">Start Time</th>
                                <th class="px-4 py-2">End Time</th>
                                <th class="px-4 py-2 text-center">Actions</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-gray-200">
    <% int index = 1; %>
    <% for (Timeslot t : timeslots) { %>
    <tr class="hover:bg-red-50 transition">
        <!-- Show index instead of actual slotId -->
        <td class="px-4 py-2"><%= index++ %></td>

        <td class="px-4 py-2">
            <form action="UpdateTimeslotServlet" method="post" 
                  class="flex flex-col sm:flex-row sm:items-center sm:space-x-2">
                <input type="hidden" name="slotId" value="<%= t.getSlotId() %>">
                <div class="relative w-full sm:w-auto">
                    <input type="time" name="startTime" value="<%= t.getStartTime() %>"
                        class="border border-gray-300 rounded-lg px-2 py-1 pr-8 focus:outline-none focus:ring-2 focus:ring-red-300 w-full"
                        required>
                    <!-- Clock Icon -->
                    <svg xmlns="http://www.w3.org/2000/svg" 
                        class="absolute right-2 top-1.5 w-4 h-4 text-gray-500 pointer-events-none" 
                        fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" 
                            d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
                    </svg>
                </div>
        </td>

        <td class="px-4 py-2">
            <div class="relative w-full sm:w-auto">
                <input type="time" name="endTime" value="<%= t.getEndTime() %>"
                    class="border border-gray-300 rounded-lg px-2 py-1 pr-8 focus:outline-none focus:ring-2 focus:ring-red-300 w-full"
                    required>
                <!-- Clock Icon -->
                <svg xmlns="http://www.w3.org/2000/svg" 
                    class="absolute right-2 top-1.5 w-4 h-4 text-gray-500 pointer-events-none" 
                    fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" 
                        d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
                </svg>
            </div>
        </td>

        <td class="px-4 py-2 flex space-x-2 justify-center">
            <button type="submit"
                class="bg-red-500 text-white px-3 py-1 rounded-lg hover:bg-red-600 transition duration-200">
                Update
            </button>
        </form>
        <form action="DeleteTimeslotServlet" method="post">
            <input type="hidden" name="slotId" value="<%= t.getSlotId() %>">
            <button type="submit"
                class="bg-gray-300 text-gray-700 px-3 py-1 rounded-lg hover:bg-gray-400 transition duration-200">
                Delete
            </button>
        </form>
        </td>
    </tr>
    <% } %>
</tbody>

                    </table>
                </div>
            </div>
        </div>
       </div>

        <!-- Toast Alert -->
        <% if (msg != null) { %>
        <div id="toast"
            class="fixed bottom-5 right-5 bg-red-600 text-white px-4 py-2 rounded-lg shadow-lg animate-slideIn">
            <%= msg %>
        </div>
        <script>
            setTimeout(() => {
                const toast = document.getElementById('toast');
                if (toast) toast.classList.add('animate-fadeOut');
                setTimeout(() => { if (toast) toast.remove(); }, 1000);
            }, 3000);
        </script>
        <% } %>

        <style>
            @keyframes slideIn {
                0% { transform: translateX(100%); opacity: 0; }
                100% { transform: translateX(0); opacity: 1; }
            }
            @keyframes fadeOut {
                0% { opacity: 1; }
                100% { opacity: 0; }
            }
            .animate-slideIn { animation: slideIn 0.5s ease-out forwards; }
            .animate-fadeOut { animation: fadeOut 1s ease-out forwards; }
        </style>
    </div>
</div>

<jsp:include page="layout/JSPFooter.jsp"/>
