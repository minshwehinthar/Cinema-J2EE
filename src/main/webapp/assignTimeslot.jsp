<%@page import="com.demo.dao.ShowtimesDao"%>
<%@page import="com.demo.dao.TimeslotDao"%>
<%@page import="com.demo.model.Timeslot"%>
<%@page import="java.time.LocalDate"%>
<%@page import="java.util.ArrayList"%>

<<script src="https://cdn.jsdelivr.net/npm/@tailwindcss/browser@4"></script>
<link href="https://cdn.jsdelivr.net/npm/flowbite@3.1.2/dist/flowbite.min.css" rel="stylesheet" />
<script src="https://cdn.jsdelivr.net/npm/flowbite@3.1.2/dist/flowbite.min.js"></script>


<section class="bg-gray-50 min-h-screen py-12">
  <div class="container mx-auto px-4">
    <h1 class="text-3xl font-bold mb-10 text-center text-indigo-700">
      Assign Time Slots for Movie
    </h1>

<%
    Integer theaterId = (Integer) session.getAttribute("theater_id");
    int movieId = Integer.parseInt(request.getParameter("movie_id"));

    ShowtimesDao showDao = new ShowtimesDao();
    TimeslotDao slotDao = new TimeslotDao();

    LocalDate[] dates = showDao.getMovieDates(theaterId, movieId);
    if (dates == null) {
%>
    <p class="text-center text-red-600">Movie dates not found. Pick movie again.</p>
<%
    } else {
        LocalDate start = dates[0];
        LocalDate end = dates[1];

        String msg = request.getParameter("msg");
        if ("no_selection".equals(msg)) {
%>
        <p class="text-center text-yellow-600 font-semibold mb-4">No timeslots selected for any date.</p>
<%
        }
%>

    <form action="AssignTimeslotServlet" method="post" class="space-y-6">
      <input type="hidden" name="movie_id" value="<%= movieId %>"/>

      <div class="grid md:grid-cols-2 lg:grid-cols-3 gap-6">
        <%
          LocalDate current = start;
          while (!current.isAfter(end)) {
              ArrayList<Timeslot> allSlots = slotDao.getTimeslotsByTheater(theaterId);
              ArrayList<Timeslot> freeSlots = showDao.getFreeTimeslotsForDate(theaterId, current, allSlots);

              if (freeSlots.isEmpty()) {
        %>
          <div class="bg-white border border-gray-200 shadow rounded-xl p-6 text-center">
            <h2 class="font-bold text-lg text-red-600"><%= current %></h2>
            <p class="text-gray-500 mt-3">No free slots available</p>
          </div>
        <%
              } else {
        %>
          <div class="bg-white border border-gray-200 shadow rounded-xl p-6">
            <h2 class="font-bold text-lg text-indigo-700 mb-3"><%= current %></h2>
            <select name="slot_<%= current %>" class="w-full border rounded-lg p-2">
              <option value="">-- Select Slot --</option>
              <% for (Timeslot t : freeSlots) { %>
                  <option value="<%= t.getSlotId() %>">
                    <%= t.getStartTime() %> - <%= t.getEndTime() %>
                  </option>
              <% } %>
            </select>
          </div>
        <%
              }
              current = current.plusDays(1);
          }
        %>
      </div>

      <div class="text-center">
        <button type="submit"
          class="mt-8 px-8 py-3 bg-indigo-600 text-white text-lg font-semibold rounded-xl hover:bg-indigo-700 transition">
          Save Assigned Timeslots
        </button>
      </div>
    </form>

<%
    }
%>
  </div>
</section>
