<%@page import="com.demo.model.Theater"%>
<%@page import="com.demo.model.Movies"%>
<%@page import="java.util.ArrayList"%>
<%@page import="java.util.HashSet"%>

<body class="flex flex-col min-h-screen">
  <jsp:include page="layout/JSPHeader.jsp"></jsp:include>
  <jsp:include page="layout/header.jsp"></jsp:include>

  <%
      // Get movie object passed as request attribute
      Movies movie = (Movies) request.getAttribute("movie");
      ArrayList<Theater> theaters = (ArrayList<Theater>) request.getAttribute("theaters");
      int movieId = (Integer) request.getAttribute("movie_id");

      // Track unique theaters
      HashSet<Integer> shown = new HashSet<>();
  %>

  <!-- Main content -->
  <main class="flex-grow">
    <section class="max-w-8xl mx-auto pt-8 pb-16">
      <div class="container mx-auto">

        <!-- Breadcrumb -->
        <nav class="text-sm mb-6" aria-label="Breadcrumb">
          <ol class="list-reset flex text-gray-600">
            <li><a href="home.jsp" class="hover:text-red-600">Home</a></li>
            <li><span class="mx-2">/</span></li>
            <li><a href="movies.jsp" class="hover:text-red-600">Movies</a></li>
            <li><span class="mx-2">/</span></li>
            <li>
              <a href="moviedetails.jsp?movie_id=<%= movieId %>" class="hover:text-red-600">
                Movie Details
              </a>
            </li>
            <li><span class="mx-2">/</span></li>
            <li class="text-gray-900 font-semibold">Available Theaters</li>
          </ol>
        </nav>

        <!-- Page Title -->
        <h1 class="text-4xl md:text-5xl font-bold mb-12 text-center text-red-600">
          Available Theaters
        </h1>

        <%
            if (theaters == null || theaters.isEmpty()) {
        %>
            <p class="text-center text-gray-500 text-lg">No theaters found for this movie.</p>
        <%
            } else {
        %>

        <!-- Theater Grid -->
        <div class="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-6">
          <% for(Theater t : theaters) { 
               if(shown.contains(t.getTheaterId())) {
                   continue; // skip duplicate theater
               }
               shown.add(t.getTheaterId());
          %>
            <a href="selectShowtimes.jsp?movie_id=<%= movieId %>&theater_id=<%= t.getTheaterId()%>" 
               class="block border border-gray-200 rounded-lg overflow-hidden hover:border-red-600 transition-colors duration-200">

              <!-- Theater Poster -->
              <img src="GetTheatersPosterServlet?theater_id=<%= t.getTheaterId() %>" 
                   alt="<%= t.getName() %>" 
                   class="w-full h-56 object-cover"/>

              <!-- Theater Info -->
              <div class="p-4 text-center">
                <h3 class="font-semibold text-lg text-gray-900 mb-1"><%= t.getName() %></h3>
                <p class="text-gray-600 text-sm"><%= t.getLocation() %></p>
              </div>
            </a>
          <% } %>
        </div>

        <%
            }
        %>
      </div>
    </section>
  </main>

  <!-- Footer -->
  <jsp:include page="layout/footer.jsp"></jsp:include>
  <jsp:include page="layout/JSPFooter.jsp"></jsp:include>
</body>
