<%@page import="com.demo.model.Theater"%>
<%@page import="java.util.ArrayList"%>

<jsp:include page="layout/JSPHeader.jsp"></jsp:include>
<jsp:include page="layout/header.jsp"></jsp:include>

<section class="bg-gray-50 min-h-screen py-16">
  <div class="container mx-auto px-4">
    <h1 class="text-5xl font-bold mb-12 text-center text-indigo-700">Available Theaters</h1>

    <%
        ArrayList<Theater> theaters = (ArrayList<Theater>) request.getAttribute("theaters");
        int movieId = (Integer) request.getAttribute("movie_id");
        if (theaters == null || theaters.isEmpty()) {
    %>
        <p class="text-center text-gray-600 text-lg">No theaters found for this movie.</p>
    <%
        } else {
    %>

    <div class="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-8">
      <% for(Theater t : theaters) { %>
        <a href="selectShowtimes.jsp?movie_id=<%= movieId %>&theater_id=<%= t.getTheaterId()%>" 
           class="bg-white rounded-2xl shadow-lg overflow-hidden transform transition duration-300 hover:scale-105 hover:shadow-xl block">

          <!-- Theater Poster -->
          <img src="GetTheatersPosterServlet?theater_id=<%= t.getTheaterId() %>" 
               alt="<%= t.getName() %>" 
               class="w-full h-56 object-cover rounded-t-2xl"/>

          <!-- Theater Info -->
          <div class="p-4 text-center">
            <h3 class="font-bold text-lg text-gray-800"><%= t.getName() %></h3>
            <p class="text-gray-600"><%= t.getLocation() %></p>
          </div>
        </a>
      <% } %>
    </div>

    <%
        }
    %>
  </div>
</section>

<jsp:include page="layout/footer.jsp"></jsp:include>
<jsp:include page="layout/JSPFooter.jsp"></jsp:include>
