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

        <div class="p-8 max-w-8xl mx-auto">
            <!-- Breadcrumb -->
            <nav class="text-sm text-gray-500 mb-6" aria-label="Breadcrumb">
                <ol class="flex items-center space-x-2">
                    <li><a href="index.jsp" class="hover:text-red-600 transition-colors">Home</a></li>
                    <li>/</li>
                    <li class="text-gray-700 font-medium">Manage Timeslots</li>
                </ol>
            </nav>

            <!-- Header Section -->
            <div class="flex justify-between items-center mb-8">
                <div>
                    <h1 class="text-2xl font-bold text-gray-900">Timeslots Management</h1>
                    <p class="text-gray-600 mt-1">Manage show timings for your theater</p>
                </div>
            </div>

            <!-- Two Column Layout -->
            <div class="grid grid-cols-1 lg:grid-cols-2 gap-8 items-start">
                
                <!-- Left Column: Add Timeslot Form -->
                <div class="bg-white shadow rounded-lg border border-gray-200 overflow-hidden sticky top-6 self-start">
                    <div class="px-6 py-4 border-b border-gray-200 bg-red-50">
                        <h2 class="text-lg font-semibold text-red-800">Add New Timeslot</h2>
                    </div>
                    <div class="p-6">
                        <form action="AddTimeslotServlet" method="post" class="space-y-6">
                            <input type="hidden" name="theaterId" value="<%=theaterId%>">

                            <div class="space-y-4">
                                <div>
                                    <label class="block text-sm font-medium text-gray-700 mb-2">Start Time</label>
                                    <div class="relative">
                                        <input type="time" name="startTime" required
                                            class="w-full border border-gray-300 rounded-lg px-4 py-3 pr-12 focus:outline-none focus:ring-2 focus:ring-red-500 focus:border-red-500 transition-colors duration-200">
                                        <!-- Clock Icon -->
                                        <svg xmlns="http://www.w3.org/2000/svg" 
                                            class="absolute right-4 top-3.5 w-5 h-5 text-gray-400 pointer-events-none" 
                                            fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" 
                                                d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
                                        </svg>
                                    </div>
                                </div>

                                <div>
                                    <label class="block text-sm font-medium text-gray-700 mb-2">End Time</label>
                                    <div class="relative">
                                        <input type="time" name="endTime" required
                                            class="w-full border border-gray-300 rounded-lg px-4 py-3 pr-12 focus:outline-none focus:ring-2 focus:ring-red-500 focus:border-red-500 transition-colors duration-200">
                                        <!-- Clock Icon -->
                                        <svg xmlns="http://www.w3.org/2000/svg" 
                                            class="absolute right-4 top-3.5 w-5 h-5 text-gray-400 pointer-events-none" 
                                            fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" 
                                                d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
                                        </svg>
                                    </div>
                                </div>
                            </div>

                            <button type="submit"
                                class="w-full bg-red-600 text-white font-medium px-4 py-3 rounded-lg hover:bg-red-700 transition-colors duration-200 shadow-sm flex items-center justify-center space-x-2">
                                <svg xmlns="http://www.w3.org/2000/svg" class="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" />
                                </svg>
                                <span>Add Timeslot</span>
                            </button>
                        </form>
                    </div>
                </div>

                <!-- Right Column: Existing Timeslots Table -->
                <div class="bg-white shadow rounded-lg border border-gray-200 overflow-hidden">
                    <div class="px-6 py-4 border-b border-gray-200 bg-red-50">
                        <div class="flex items-center justify-between">
                            <h2 class="text-lg font-semibold text-red-800">Existing Timeslots</h2>
                            <span class="bg-red-100 text-red-800 text-sm font-medium px-3 py-1 rounded-full border border-red-200">
                                <%= timeslots.size() %> timeslots
                            </span>
                        </div>
                    </div>
                    <div class="overflow-x-auto">
                        <% if (timeslots.isEmpty()) { %>
                            <div class="text-center py-12">
                                <div class="w-16 h-16 mx-auto mb-4 text-gray-300">
                                    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
                                    </svg>
                                </div>
                                <h3 class="text-lg font-medium text-gray-600 mb-2">No timeslots found</h3>
                                <p class="text-gray-500">Add your first timeslot to get started</p>
                            </div>
                        <% } else { %>
                            <table class="min-w-full text-sm text-left">
                                <thead class="bg-red-50 text-gray-900 uppercase text-xs">
                                    <tr>
                                        <th class="px-6 py-4 font-semibold">#</th>
                                        <th class="px-6 py-4 font-semibold text-right">Start Time</th>
                                        <th class="px-6 py-4 font-semibold text-right">End Time</th>
                                        <th class="px-6 py-4 font-semibold text-center">Actions</th>
                                    </tr>
                                </thead>
                                <tbody class="divide-y divide-gray-100">
                                    <% int index = 1; %>
                                    <% for (Timeslot t : timeslots) { %>
                                    <tr class="hover:bg-red-50 transition-colors duration-150">
                                        <td class="px-6 py-4">
                                            <div class="flex items-center space-x-3">
                                                <div class="w-8 h-8 bg-red-100 rounded-lg flex items-center justify-center">
                                                    <span class="text-red-600 font-bold text-sm"><%= index++ %></span>
                                                </div>
                                            </div>
                                        </td>

                                        <td class="px-6 py-4">
                                            <form action="UpdateTimeslotServlet" method="post" class="flex justify-end">
                                                <input type="hidden" name="slotId" value="<%= t.getSlotId() %>">
                                                <div class="relative max-w-[140px]">
                                                    <input type="time" name="startTime" value="<%= t.getStartTime() %>"
                                                        class="w-full border border-gray-300 rounded-lg px-3 py-2 pr-10 focus:outline-none focus:ring-2 focus:ring-red-500 focus:border-red-500 transition-colors duration-200 text-right"
                                                        required>
                                                    <!-- Clock Icon -->
                                                    <svg xmlns="http://www.w3.org/2000/svg" 
                                                        class="absolute right-3 top-2 w-4 h-4 text-gray-400 pointer-events-none" 
                                                        fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" 
                                                            d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
                                                    </svg>
                                                </div>
                                        </td>

                                        <td class="px-6 py-4">
                                            <div class="relative max-w-[110px] ml-auto">
                                                <input type="time" name="endTime" value="<%= t.getEndTime() %>"
                                                    class="w-full border border-gray-300 rounded-lg px-3 py-2 pr-10 focus:outline-none focus:ring-2 focus:ring-red-500 focus:border-red-500 transition-colors duration-200 text-right"
                                                    required>
                                                <!-- Clock Icon -->
                                                <svg xmlns="http://www.w3.org/2000/svg" 
                                                    class="absolute right-3 top-2 w-4 h-4 text-gray-400 pointer-events-none" 
                                                    fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" 
                                                        d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
                                                </svg>
                                            </div>
                                        </td>

                                        <td class="px-6 py-4">
                                            <div class="flex justify-center space-x-3">
                                                <button type="submit"
                                                    class="inline-flex items-center justify-center w-10 h-10 text-blue-600 bg-white border border-blue-300 rounded-lg hover:bg-blue-50 hover:border-blue-400 transition-colors duration-200 shadow-sm cursor-pointer"
                                                    title="Update Timeslot">
                                                    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-5 h-5">
                                                        <path stroke-linecap="round" stroke-linejoin="round" d="m16.862 4.487 1.687-1.688a1.875 1.875 0 1 1 2.652 2.652L10.582 16.07a4.5 4.5 0 0 1-1.897 1.13L6 18l.8-2.685a4.5 4.5 0 0 1 1.13-1.897l8.932-8.931Zm0 0L19.5 7.125M18 14v4.75A2.25 2.25 0 0 1 15.75 21H5.25A2.25 2.25 0 0 1 3 18.75V8.25A2.25 2.25 0 0 1 5.25 6H10" />
                                                    </svg>
                                                </button>
                                            </form>
                                            <form action="DeleteTimeslotServlet" method="post" class="inline">
                                                <input type="hidden" name="slotId" value="<%= t.getSlotId() %>">
                                                <button type="submit"
                                                    class="inline-flex items-center justify-center w-10 h-10 text-red-600 bg-white border border-red-300 rounded-lg hover:bg-red-50 hover:border-red-400 transition-colors duration-200 shadow-sm cursor-pointer"
                                                    title="Delete Timeslot"
                                                    onclick="return confirm('Are you sure you want to delete this timeslot?')">
                                                    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-5 h-5">
                                                        <path stroke-linecap="round" stroke-linejoin="round" d="m14.74 9-.346 9m-4.788 0L9.26 9m9.968-3.21c.342.052.682.107 1.022.166m-1.022-.165L18.16 19.673a2.25 2.25 0 0 1-2.244 2.077H8.084a2.25 2.25 0 0 1-2.244-2.077L4.772 5.79m14.456 0a48.108 48.108 0 0 0-3.478-.397m-12 .562c.34-.059.68-.114 1.022-.165m0 0a48.11 48.11 0 0 1 3.478-.397m7.5 0v-.916c0-1.18-.91-2.164-2.09-2.201a51.964 51.964 0 0 0-3.32 0c-1.18.037-2.09 1.022-2.09 2.201v.916m7.5 0a48.667 48.667 0 0 0-7.5 0" />
                                                    </svg>
                                                </button>
                                            </form>
                                        </div>
                                        </td>
                                    </tr>
                                    <% } %>
                                </tbody>
                            </table>
                        <% } %>
                    </div>
                </div>
            </div>
        </div>

        <!-- Toast Alert -->
        <% if (msg != null) { %>
        <div id="toast" class="fixed top-5 right-5 z-50">
            <div class="bg-green-500 text-white px-6 py-3 rounded-lg shadow-lg animate-slideIn flex items-center space-x-3">
                <svg xmlns="http://www.w3.org/2000/svg" class="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
                </svg>
                <span class="font-medium"><%= msg %></span>
            </div>
        </div>
        <script>
            setTimeout(() => {
                const toast = document.getElementById('toast');
                if (toast) {
                    toast.classList.remove('animate-slideIn');
                    toast.classList.add('animate-fadeOut');
                    setTimeout(() => { if (toast) toast.remove(); }, 1000);
                }
            }, 4000);
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