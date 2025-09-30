<%@ page import="com.demo.dao.TimeslotDao" %>
<%@ page import="com.demo.model.Timeslot" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="com.demo.dao.TheaterMoviesDao"%>

<jsp:include page="layout/JSPHeader.jsp"></jsp:include>
<jsp:include page="layout/header.jsp"></jsp:include>

<%
    
    Integer theaterId = (Integer) session.getAttribute("theater_id");

    if (theaterId == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    int movieId = Integer.parseInt(request.getParameter("movie_id"));
    TheaterMoviesDao movieDao = new TheaterMoviesDao();
    TimeslotDao slotDao = new TimeslotDao();

    ArrayList<Timeslot> timeslots = slotDao.getTimeslotsByTheater(theaterId);
%>


<section class="bg-gray-50 min-h-screen py-16">
  <div class="container mx-auto px-4">
    <h1 class="text-4xl font-bold mb-8 text-center">Manage Time Slots</h1>

    <!-- Timeslots List -->
    <div class="bg-white p-6 rounded-2xl shadow-lg mb-8 max-w-2xl mx-auto">
      <h2 class="text-xl font-semibold mb-4">Existing Time Slots</h2>

      <%
        if(timeslots.isEmpty()){
      %>
        <p class="text-gray-600">No timeslots added yet.</p>
      <%
        } else {
      %>
        <table class="w-full border-collapse">
          <thead>
            <tr>
              <th class="border px-4 py-2">Start Time</th>
              <th class="border px-4 py-2">End Time</th>
            </tr>
          </thead>
          <tbody>
            <% for(Timeslot t : timeslots){ %>
              <tr>
                <td class="border px-4 py-2"><%= t.getStartTime() %></td>
                <td class="border px-4 py-2"><%= t.getEndTime() %></td>
              </tr>
            <% } %>
          </tbody>
        </table>
      <%
        }
      %>
    </div>

    <!-- Add Timeslot Form -->
    <div class="bg-white p-8 rounded-2xl shadow-lg max-w-lg mx-auto">
      <form action="AddTimeslotServlet" method="post" class="space-y-6">
        <input type="hidden" name="movie_id" value="<%= movieId %>"/>
        
        <div>
          <label class="block mb-2 text-gray-700 font-semibold">Start Time</label>
          <input type="time" name="start_time" required class="w-full px-4 py-2 border rounded-lg"/>
        </div>

        <div>
          <label class="block mb-2 text-gray-700 font-semibold">End Time</label>
          <input type="time" name="end_time" required class="w-full px-4 py-2 border rounded-lg"/>
        </div>

        <button type="submit" class="w-full py-3 bg-indigo-600 text-white font-semibold rounded-lg hover:bg-indigo-700">
          Add Timeslot
        </button>
      </form>
    </div>
  </div>
</section>

<jsp:include page="layout/footer.jsp"></jsp:include>
<jsp:include page="layout/JSPFooter.jsp"></jsp:include>
