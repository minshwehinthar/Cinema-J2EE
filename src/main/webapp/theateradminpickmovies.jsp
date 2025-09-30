<%@ page import="com.demo.model.Movies" %>
<%@ page import="com.demo.dao.TheaterMoviesDao" %>
<%@ page import="java.util.ArrayList" %>

<script src="https://cdn.jsdelivr.net/npm/@tailwindcss/browser@4"></script>
<link href="https://cdn.jsdelivr.net/npm/flowbite@3.1.2/dist/flowbite.min.css" rel="stylesheet" />
<script src="https://cdn.jsdelivr.net/npm/flowbite@3.1.2/dist/flowbite.min.js"></script>


<section class="bg-gray-50 min-h-screen py-16">
  <div class="container mx-auto px-4">
    <h1 class="text-5xl font-bold mb-12 text-center text-indigo-700">Pick Movies for Your Theater</h1>

    <%
      String msg = request.getParameter("msg");
      if ("nofreeslot".equals(msg)) {
    %>
    <div class="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded relative mb-6" role="alert">
      <strong class="font-bold">No available timeslots!</strong>
      <span class="block sm:inline">All time slots for the selected dates are full. Please adjust the schedule or add more slots.</span>
    </div>
    <%
      }
    %>

    <%
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
    <div class="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-8">
      <%
        for (Movies m : moviesList) {
            String movieStatus = m.getStatus() != null ? m.getStatus() : "now-showing";
      %>
      <div class="bg-white rounded-2xl shadow-lg overflow-hidden p-4 flex flex-col items-center">
        <img src="GetMoviesPosterServlet?movie_id=<%= m.getMovie_id() %>" 
             alt="<%= m.getTitle() %> Poster" 
             class="w-full h-72 object-cover rounded-xl mb-2"/>

        <h3 class="font-bold text-lg text-center mb-2"><%= m.getTitle() %></h3>

        <div class="mb-2">
          <span class="px-3 py-1 text-xs font-semibold rounded-md uppercase <%= "now-showing".equalsIgnoreCase(movieStatus) ? "bg-green-600 text-white" : "bg-red-600 text-white" %>">
            <%= movieStatus.equals("now-showing") ? "Now Showing" : "Coming Soon" %>
          </span>
        </div>

        <form action="PickMovieServlet" method="post" class="w-full flex flex-col gap-2">
          <input type="hidden" name="movie_id" value="<%= m.getMovie_id() %>"/>
          <input type="hidden" name="status" value="<%= movieStatus %>"/>

          <% if ("now-showing".equalsIgnoreCase(movieStatus)) { %>
              <label class="font-medium text-gray-700">Start Date</label>
              <input type="date" name="start_date" class="border rounded-lg p-2 w-full" required
                     min="<%= java.time.LocalDate.now() %>" 
                     max="<%= java.time.LocalDate.now().plusWeeks(4) %>">

              <label class="font-medium text-gray-700">End Date</label>
              <input type="date" name="end_date" class="border rounded-lg p-2 w-full" required
                     min="<%= java.time.LocalDate.now() %>" 
                     max="<%= java.time.LocalDate.now().plusWeeks(4) %>">
          <% } else { %>
             <%---  <p class="text-gray-500 italic text-center">Coming Soon movie no dates required.</p>--%>
          <% } %>

          <button type="submit" class="mt-2 py-2 px-4 bg-indigo-600 text-white rounded-xl hover:bg-indigo-700 transition">
              Pick Movie
          </button>
        </form>
      </div>
      <% } %>
    </div>
    <%
        }
      }
    %>
  </div>
</section>

<script>
function validateDates(form) {
    const start = new Date(form.start_date?.value);
    const end = new Date(form.end_date?.value);
    if (form.start_date && form.end_date && start > end) {
        alert("Start Date must be before End Date!");
        return false;
    }
    return true;
}
</script>


