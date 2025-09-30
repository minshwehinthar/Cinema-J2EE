<%@ page import="com.demo.dao.SeatPriceDao" %>
<%@ page import="java.util.ArrayList" %>

<jsp:include page="layout/JSPHeader.jsp"></jsp:include>
<jsp:include page="layout/header.jsp"></jsp:include>

<section class="bg-gray-50 min-h-screen py-16">
  <div class="container mx-auto px-4 max-w-lg">

    <h1 class="text-4xl font-bold text-indigo-700 mb-8 text-center">Add Seats</h1>

    <% 
        String msg = request.getParameter("msg");
        if ("success".equals(msg)) { 
    %>
        <div class="bg-green-100 border border-green-400 text-green-700 px-4 py-3 rounded mb-6 text-center">
            Seats added successfully!
        </div>
    <% } else if ("error".equals(msg)) { %>
        <div class="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded mb-6 text-center">
            Error occurred while adding seats. Please try again.
        </div>
    <% } %>

    <form action="AddSeatsServlet" method="post" class="bg-white p-6 rounded-2xl shadow-lg space-y-4">

        <input type="hidden" name="theater_id" value="<%= session.getAttribute("theater_id") %>">

        <div>
            <label class="font-medium text-gray-700">Seat Type</label>
            <select name="seat_type" class="border rounded-lg p-2 w-full" required>
                <%
                    SeatPriceDao priceDao = new SeatPriceDao();
                    ArrayList<String> seatTypes = priceDao.getAllSeatTypes(); // returns ["Normal","VIP","Couple"]
                    for(String type : seatTypes) {
                %>
                    <option value="<%= type %>"><%= type %></option>
                <%
                    }
                %>
            </select>
        </div>

        <div>
            <label class="font-medium text-gray-700">Rows (e.g., A,B,C)</label>
            <input type="text" name="rows" placeholder="A,B,C" class="border rounded-lg p-2 w-full" required>
        </div>

        <div>
            <label class="font-medium text-gray-700">Seats per Row</label>
            <input type="number" name="seats_per_row" min="1" max="20" class="border rounded-lg p-2 w-full" required>
        </div>

        <button type="submit" class="w-full py-3 bg-indigo-600 text-white rounded-xl hover:bg-indigo-700 transition font-semibold">
            Add Seats
        </button>

    </form>
  </div>
</section>

<jsp:include page="layout/footer.jsp"></jsp:include>
<jsp:include page="layout/JSPFooter.jsp"></jsp:include>
