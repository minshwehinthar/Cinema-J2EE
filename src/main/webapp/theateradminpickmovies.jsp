<%@ page import="com.demo.model.Movies" %>
<%@ page import="com.demo.dao.TheaterMoviesDao" %>
<%@ page import="java.util.ArrayList" %>

<jsp:include page="layout/JSPHeader.jsp"/>
<div class="flex min-h-screen bg-gray-100">

    <!-- Sidebar -->
    <jsp:include page="layout/sidebar.jsp"/>

    <!-- Main Content -->
    <div class="flex-1 sm:ml-64">
        <jsp:include page="layout/AdminHeader.jsp"/>
        <div class="p-8">

            <!-- Page Title -->
            <h1 class="text-4xl font-bold mb-8 text-indigo-700 text-center">Pick Movies for Your Theater</h1>

            <div class="max-w-7xl mx-auto">

                <%-- Alert Message --%>
                <%
                    String msg = request.getParameter("msg");
                    if ("nofreeslot".equals(msg)) {
                %>
                <div class="bg-red-100 border border-red-400 text-red-700 px-6 py-4 rounded mb-6 shadow text-center">
                    <strong class="font-bold">No available timeslots!</strong>
                    <span class="block sm:inline">All time slots for the selected dates are full. Please adjust the schedule or add more slots.</span>
                </div>
                <%
                    }

                    Integer theaterId = (Integer) session.getAttribute("theater_id");
                    if (theaterId == null) {
                %>
                <p class="text-center text-red-600 text-lg">Theater not found. Please login again.</p>
                <%
                    } else {
                        TheaterMoviesDao dao = new TheaterMoviesDao();
                        ArrayList<Movies> moviesList = dao.getAvailableMoviesForTheater(theaterId);

                        if (moviesList.isEmpty()) {
                %>
                <p class="text-center text-gray-700 text-lg">No movies available to pick. All movies are already added.</p>
                <%
                        } else {
                %>

                <!-- Movie Grid -->
                <div class="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-8">

                    <% for (Movies m : moviesList) {
                        String movieStatus = m.getStatus() != null ? m.getStatus() : "now-showing";
                    %>
                    <div class="bg-white rounded-2xl shadow-lg overflow-hidden flex flex-col hover:shadow-2xl transition duration-300">

                        <!-- Poster -->
                        <img src="GetMoviesPosterServlet?movie_id=<%= m.getMovie_id() %>" 
                             alt="<%= m.getTitle() %> Poster" 
                             class="w-full h-72 object-cover"/>

                        <!-- Movie Info -->
                        <div class="p-4 flex flex-col flex-1 justify-between">

                            <div class="mb-4 text-center">
                                <h3 class="font-bold text-lg"><%= m.getTitle() != null ? m.getTitle() : "Unknown" %></h3>
                                <span class="px-3 py-1 mt-2 inline-block text-xs font-semibold rounded-md uppercase 
                                            <%= "now-showing".equalsIgnoreCase(movieStatus) ? "bg-green-600 text-white" : "bg-red-600 text-white" %>">
                                    <%= movieStatus.equals("now-showing") ? "Now Showing" : "Coming Soon" %>
                                </span>
                            </div>

                         

                            <!-- Pick Movie Form -->
                            <form action="PickMovieServlet" method="post" class="flex flex-col gap-2" onsubmit="return validateDates(this)">
                                <input type="hidden" name="movie_id" value="<%= m.getMovie_id() %>"/>
                                <input type="hidden" name="status" value="<%= movieStatus %>"/>

                                <% if ("now-showing".equalsIgnoreCase(movieStatus)) { %>
                                <div class="flex flex-col gap-2">
                                    <label class="font-medium text-gray-700">Start Date</label>
                                    <input type="date" name="start_date" class="border rounded-lg p-2 w-full" required
                                           min="<%= java.time.LocalDate.now() %>" 
                                           max="<%= java.time.LocalDate.now().plusWeeks(4) %>">

                                    <label class="font-medium text-gray-700 mt-2">End Date</label>
                                    <input type="date" name="end_date" class="border rounded-lg p-2 w-full" required
                                           min="<%= java.time.LocalDate.now() %>" 
                                           max="<%= java.time.LocalDate.now().plusWeeks(4) %>">
                                </div>
                                <% } %>

                                <button type="submit" class="mt-4 py-2 px-4 bg-indigo-600 text-white rounded-xl hover:bg-indigo-700 transition font-medium">
                                    Pick Movie
                                </button>
                            </form>

                        </div>
                    </div>
                    <% } %>

                </div>
                <%
                        }
                    }
                %>

            </div>
        </div>
    </div>
</div>

<script>
function validateDates(form) {
    if(form.start_date && form.end_date){
        const start = new Date(form.start_date.value);
        const end = new Date(form.end_date.value);
        if(start > end){
            alert("Start Date must be before End Date!");
            return false;
        }
    }
    return true;
}
</script>
<jsp:include page="layout/JSPFooter.jsp"/>
