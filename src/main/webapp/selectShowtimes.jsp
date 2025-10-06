<%@ page import="java.time.LocalDate" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="com.demo.dao.ShowtimesDao" %>
<%@ page import="com.demo.dao.TimeslotDao" %>
<%@ page import="com.demo.dao.SeatsDao" %>
<%@ page import="com.demo.model.Timeslot" %>
<%@ page import="com.demo.model.Seat" %>

<jsp:include page="layout/JSPHeader.jsp"></jsp:include>
<jsp:include page="layout/header.jsp"></jsp:include>

<%
    String error = null;
    String movieIdParam = request.getParameter("movie_id");
    String theaterIdParam = request.getParameter("theater_id");
    int movieId = 0, theaterId = 0;

    if (movieIdParam == null || theaterIdParam == null) error = "Invalid selection. Please pick a movie and theater first.";
    else {
        try { movieId = Integer.parseInt(movieIdParam); theaterId = Integer.parseInt(theaterIdParam); }
        catch (NumberFormatException e) { error = "Invalid movie or theater ID."; }
    }

    LocalDate startDate = null, endDate = null;
    ShowtimesDao showDao = new ShowtimesDao();
    if (error == null) {
        LocalDate[] dates = showDao.getMovieDates(theaterId, movieId);
        if (dates == null) error = "Movie dates not found for this theater.";
        else { startDate = dates[0]; endDate = dates[1]; }
    }

    SeatsDao seatsDao = new SeatsDao();
    java.util.List<Seat> seatsList = seatsDao.getSeatsByTheater(theaterId);

    // Sort seats by row letter and numeric part for proper numbering
    seatsList.sort((s1, s2) -> {
        char row1 = s1.getSeatNumber().charAt(0);
        char row2 = s2.getSeatNumber().charAt(0);
        if (row1 != row2) return row1 - row2;

        int num1 = Integer.parseInt(s1.getSeatNumber().substring(1));
        int num2 = Integer.parseInt(s2.getSeatNumber().substring(1));
        return num1 - num2;
    });
%>

<section class="bg-gray-50 min-h-screen py-16">
    <div class="container mx-auto px-4">
        <h1 class="text-5xl font-bold mb-12 text-center text-indigo-700">Select Show Date & Timeslot</h1>

        <% if (error != null) { %>
            <p class="text-center text-red-600 text-lg"><%= error %></p>
        <% } else { %>

        <form id="booking-form" action="BookingServlet" method="post" class="space-y-6">
            <input type="hidden" name="movie_id" value="<%= movieId %>">
            <input type="hidden" name="theater_id" value="<%= theaterId %>">
            <input type="hidden" name="slot_id" id="selected-slot-id">
            <input type="hidden" name="show_date" id="selected-date">
            <input type="hidden" name="selected_seats" id="selected-seats">

            <!-- Dates -->
            <div id="dates-container" class="flex flex-wrap gap-4 justify-center mb-6">
                <%
                    LocalDate today = LocalDate.now();
                    LocalDate current = startDate;
                    ArrayList<Timeslot> allSlots = new TimeslotDao().getTimeslotsByTheater(theaterId);
                    boolean hasFutureDates = false;

                    while (!current.isAfter(endDate)) {
                        if (!current.isBefore(today)) { // show today or future
                            ArrayList<Timeslot> assignedSlots = new ArrayList<>();
                            for (Timeslot t : allSlots)
                                if (showDao.isSlotAssigned(theaterId, movieId, t.getSlotId(), current)) assignedSlots.add(t);
                            if (!assignedSlots.isEmpty()) {
                                hasFutureDates = true;
                %>
                    <button type="button" class="date-btn px-6 py-3 rounded-xl border border-indigo-600 bg-white hover:bg-indigo-50 transition"
                        data-date="<%= current %>"><%= current %></button>
                <%      }
                        }
                        current = current.plusDays(1);
                    }

                    if (!hasFutureDates) {
                %>
                    <p class="text-center text-red-600 text-lg">No available dates for this movie.</p>
                <%
                    }
                %>
            </div>

            <!-- Timeslots -->
            <div id="timeslots-container" class="flex flex-wrap justify-center gap-4 mb-6 hidden">
                <%
                    current = startDate;
                    while (!current.isAfter(endDate)) {
                        if (!current.isBefore(today)) {
                            ArrayList<Timeslot> assignedSlots = new ArrayList<>();
                            for (Timeslot t : allSlots)
                                if (showDao.isSlotAssigned(theaterId, movieId, t.getSlotId(), current)) assignedSlots.add(t);
                            for (Timeslot t : assignedSlots) {
                %>
                    <button type="button"
                        class="slot-btn hidden bg-indigo-600 text-white px-6 py-3 rounded-xl shadow hover:bg-indigo-700 transition"
                        data-date="<%= current %>" data-slot-id="<%= t.getSlotId() %>">
                        <%= t.getStartTime() %> - <%= t.getEndTime() %>
                    </button>
                <%      }
                        }
                        current = current.plusDays(1);
                    }
                %>
            </div>

            <!-- Seats -->
            <div id="seats-container" class="hidden mt-6">
                <h2 class="text-xl font-bold mb-4 text-center text-indigo-700">Select Your Seats</h2>
                <div class="seat-plan">
                    <div class="screen-label">SCREEN</div>
                    <div id="seat-rows">
                        <%
                            char lastRow = ' ';
                            ArrayList<Seat> rowSeats = new ArrayList<>();
                            for (Seat seat : seatsList) {
                                char rowLetter = seat.getSeatNumber().charAt(0);
                                if (rowLetter != lastRow) {
                                    if (!rowSeats.isEmpty()) {
                                        out.print("<div class='seat-row'>");
                                        for (Seat s : rowSeats) {
                                            double price = s.getPrice().doubleValue();
                                            String classes = "seat " + (s.getStatus().equals("booked")?"booked":"available") +
                                                             (s.getSeatType().equals("VIP")?" vip":s.getSeatType().equals("Couple")?" couple":"");
                                            // Display numeric part correctly
                                            String displayNumber = s.getSeatNumber().substring(1);
                                            out.print("<button type='button' class='" + classes + "' data-seat='" + s.getSeatNumber() +
                                                      "' data-type='" + s.getSeatType() + "' data-price='" + price + "'" +
                                                      (s.getStatus().equals("booked")?" disabled":"") + ">" + displayNumber + "</button>");
                                        }
                                        out.print("</div>");
                                    }
                                    rowSeats.clear();
                                    lastRow = rowLetter;
                                }
                                rowSeats.add(seat);
                            }
                            if (!rowSeats.isEmpty()) {
                                out.print("<div class='seat-row'>");
                                for (Seat s : rowSeats) {
                                    double price = s.getPrice().doubleValue();
                                    String classes = "seat " + (s.getStatus().equals("booked")?"booked":"available") +
                                                     (s.getSeatType().equals("VIP")?" vip":s.getSeatType().equals("Couple")?" couple":"");
                                    String displayNumber = s.getSeatNumber().substring(1);
                                    out.print("<button type='button' class='" + classes + "' data-seat='" + s.getSeatNumber() +
                                              "' data-type='" + s.getSeatType() + "' data-price='" + price + "'" +
                                              (s.getStatus().equals("booked")?" disabled":"") + ">" + displayNumber + "</button>");
                                }
                                out.print("</div>");
                            }
                        %>
                    </div>
                </div>
            </div>

            <!-- Booking Summary / Sticky Footer -->
            <div id="booking-summary" class="hidden sticky-footer">
                <div class="summary-left">
                    <p id="selected-seat-numbers">Seats: None</p>
                    <p id="total-price">Total Price: 0 MMK</p>
                </div>
                <button type="submit" id="confirm-btn" class="px-6 py-2 bg-indigo-600 text-white rounded-xl hover:bg-indigo-700 transition" disabled>
                    Book Now
                </button>
            </div>

        </form>
        <% } %>
    </div>
</section>

<jsp:include page="layout/footer.jsp"></jsp:include>
<jsp:include page="layout/JSPFooter.jsp"></jsp:include>
