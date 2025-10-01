<%@ page import="com.demo.model.Movies" %>
<%@ page import="com.demo.dao.TheaterMoviesDao" %>
<%@ page import="java.util.ArrayList" %>

<jsp:include page="layout/JSPHeader.jsp"></jsp:include>
<jsp:include page="layout/header.jsp"></jsp:include>

<section class="bg-blueGray-50 min-h-screen py-12">
    <div class="flex">
        <!-- Sidebar -->
        <div class="w-64 bg-white shadow-lg min-h-screen p-6">
            <nav>
                <ul class="space-y-4">
                    <li>
                        <button class="nav-btn w-full text-left py-3 px-4 rounded-lg font-medium bg-indigo-600 text-white transition ease-in-out duration-200" data-filter="all">All Movies</button>
                    </li>
                    <li>
                        <button class="nav-btn w-full text-left py-3 px-4 rounded-lg font-medium text-gray-700 hover:bg-indigo-100 transition ease-in-out duration-200" data-filter="now-showing">Now Showing</button>
                    </li>
                    <li>
                        <button class="nav-btn w-full text-left py-3 px-4 rounded-lg font-medium text-gray-700 hover:bg-indigo-100 transition ease-in-out duration-200" data-filter="coming-soon">Coming Soon</button>
                    </li>
                </ul>
            </nav>
        </div>

        <!-- Movies Grid -->
        <div class="flex-1 p-8">
            <div class="mb-8">
                <h1 class="text-5xl font-bold font-heading leading-tight mb-4">Movies</h1>
            </div>

            <div class="movie-grid grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-6">
                <%
                    TheaterMoviesDao dao = new TheaterMoviesDao();
                    ArrayList<Movies> moviesList = dao.getMoviesPickedByTheaters();

                    for(Movies m : moviesList) {
                        String status = m.getStatus(); // could be null
                        boolean isNowShowing = "now-showing".equalsIgnoreCase(status);
                        boolean isComingSoon = "coming-soon".equalsIgnoreCase(status);

                        String statusClass = isNowShowing ? "bg-green-600" : (isComingSoon ? "bg-red-600" : "bg-gray-500");
                %>
                <div class="movie-card relative bg-white rounded-xl shadow-lg overflow-hidden transform transition duration-300 hover:scale-105" data-status="<%= status != null ? status : "" %>">
                    <div class="absolute top-3 left-3 z-10">
                        <span class="<%= statusClass %> text-white px-3 py-1 text-xs font-semibold rounded-md uppercase">
                            <%= status != null ? status : "Unknown" %>
                        </span>
                    </div>

                    <a href="moviedetails.jsp?movie_id=<%= m.getMovie_id() %>">
                        <img src="GetMoviesPosterServlet?movie_id=<%= m.getMovie_id() %>" class="w-full h-96 object-cover"/>
                    </a>

                    <div class="p-4">
                        <h3 class="font-bold text-lg truncate"><%= m.getTitle() != null ? m.getTitle() : "Untitled" %></h3>
                    </div>
                </div>
                <% } %>
            </div>
        </div>
    </div>
</section>

<jsp:include page="layout/footer.jsp"></jsp:include>
<jsp:include page="layout/JSPFooter.jsp"></jsp:include>