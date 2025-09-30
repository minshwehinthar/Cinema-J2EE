<%@ page import="com.demo.dao.SeatPriceDao" %>
<%@ page import="com.demo.model.SeatPrice" %>
<%@ page import="java.util.ArrayList" %>

<jsp:include page="layout/JSPHeader.jsp"></jsp:include>
<jsp:include page="layout/header.jsp"></jsp:include>

<section class="bg-gray-50 min-h-screen py-16">
    <div class="container mx-auto px-4">
        <h1 class="text-4xl font-bold mb-8 text-center text-indigo-700">Manage Seat Prices</h1>

        <%
            SeatPriceDao dao = new SeatPriceDao();
            ArrayList<SeatPrice> prices = dao.getAllSeatPrices();
        %>

        <form action="UpdateSeatPriceServlet" method="post" class="space-y-4 max-w-lg mx-auto bg-white p-8 rounded-xl shadow-lg">
            <%
                for (SeatPrice sp : prices) {
            %>
            <div class="flex items-center justify-between">
                <label class="font-medium text-gray-700"><%= sp.getSeatType() %></label>
                <input type="hidden" name="priceId" value="<%= sp.getPriceId() %>">
                <input type="number" step="0.01" name="price_<%= sp.getPriceId() %>" value="<%= sp.getPrice() %>" class="border rounded-lg p-2 w-32 text-right">
            </div>
            <% } %>
            <button type="submit" class="mt-4 w-full py-2 px-4 bg-indigo-600 text-white rounded-xl hover:bg-indigo-700 transition">Save Prices</button>
        </form>
    </div>
</section>

<jsp:include page="layout/footer.jsp"></jsp:include>
<jsp:include page="layout/JSPFooter.jsp"></jsp:include>
