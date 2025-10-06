<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.demo.dao.TheaterDAO" %>
<%@ page import="com.demo.dao.SeatPriceDao" %>
<%@ page import="com.demo.model.Theater" %>
<%@ page import="com.demo.model.SeatPrice" %>
<%@ page import="com.demo.model.User" %>
<%@ page import="java.util.List" %>

<%
    // Get the logged-in user from session
    User user = (User) session.getAttribute("user");

    // Only allow admin or theater_admin
    if (user == null || 
       (!"admin".equals(user.getRole()) && !"theateradmin".equals(user.getRole()))) {
        response.sendRedirect("login.jsp?msg=unauthorized");
        return;
    }

    // Load theaters and seat prices
    TheaterDAO theaterDao = new TheaterDAO();
    List<Theater> theaters = theaterDao.getAllTheaters();

    SeatPriceDao seatPriceDao = new SeatPriceDao();
    List<SeatPrice> seatPrices = seatPriceDao.getAllSeatPrices();
%>

<jsp:include page="layout/JSPHeader.jsp"/>

<div class="flex min-h-screen">
    <!-- Sidebar -->
    <jsp:include page="layout/sidebar.jsp"/>

    <!-- Main content -->
    <div class="flex-1 sm:ml-64">
        <!-- Admin Header -->
        <jsp:include page="layout/AdminHeader.jsp"/>

        <!-- Page Content -->
        <div class="p-8">
            <div class="container mx-auto mt-6 p-6 bg-white rounded shadow-lg max-w-lg">
                <h2 class="text-2xl font-bold mb-6 text-center text-red-600">Create Seats</h2>

                <form action="CreateSeatsServlet" method="post" class="space-y-4">
                    <!-- Theater Selection -->
                    <div>
                        <label class="block mb-1 font-semibold text-gray-700">Select Theater</label>
                        <select name="theater_id" required
                                class="w-full border border-gray-300 p-2 rounded focus:outline-none focus:ring-2 focus:ring-red-500">
                            <option value="">--Select Theater--</option>
                            <% for (Theater theater : theaters) { %>
                                <option value="<%= theater.getTheaterId() %>"><%= theater.getName() %></option>
                            <% } %>
                        </select>
                    </div>

                    <!-- Seat Number Input -->
                    <div>
                        <label class="block mb-1 font-semibold text-gray-700">Seat Number</label>
                        <input type="text" name="seat_number" placeholder="E.g., A1" required
                               class="w-full border border-gray-300 p-2 rounded focus:outline-none focus:ring-2 focus:ring-red-500"/>
                    </div>

                    <!-- Seat Type / Price Selection -->
                    <div>
                        <label class="block mb-1 font-semibold text-gray-700">Seat Type & Price</label>
                        <select name="price_id" required
                                class="w-full border border-gray-300 p-2 rounded focus:outline-none focus:ring-2 focus:ring-red-500">
                            <option value="">--Select Seat Type--</option>
                            <% for (SeatPrice sp : seatPrices) { %>
                                <option value="<%= sp.getPriceId() %>">
                                    <%= sp.getSeatType() %> - $<%= sp.getPrice() %>
                                </option>
                            <% } %>
                        </select>
                    </div>

                    <!-- Submit Button -->
                    <div class="text-center">
                        <button type="submit"
                                class="bg-red-600 text-white font-semibold px-6 py-2 rounded hover:bg-red-700 transition">
                            Create Seat
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>

<jsp:include page="layout/JSPFooter.jsp"/>
