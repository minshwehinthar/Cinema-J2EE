<%@ page import="java.time.LocalDate" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="com.demo.dao.ShowtimesDao" %>
<%@ page import="com.demo.dao.TimeslotDao" %>
<%@ page import="com.demo.model.Timeslot" %>

<jsp:include page="layout/JSPHeader.jsp"></jsp:include>
<jsp:include page="layout/header.jsp"></jsp:include>

<%
    String error = null;
    String movieIdParam = request.getParameter("movie_id");
    String theaterIdParam = request.getParameter("theater_id");
    int movieId = 0;
    int theaterId = 0;

    if (movieIdParam == null || theaterIdParam == null) {
        error = "Invalid selection. Please pick a movie and theater first.";
    } else {
        try {
            movieId = Integer.parseInt(movieIdParam);
            theaterId = Integer.parseInt(theaterIdParam);
        } catch (NumberFormatException e) {
            error = "Invalid movie or theater ID.";
        }
    }

    LocalDate startDate = null;
    LocalDate endDate = null;
    ShowtimesDao showDao = new ShowtimesDao();
    if (error == null) {
        LocalDate[] dates = showDao.getMovieDates(theaterId, movieId);
        if (dates == null) {
            error = "Movie dates not found for this theater.";
        } else {
            startDate = dates[0];
            endDate = dates[1];
        }
    }
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
                    LocalDate current = startDate;
                    ArrayList<Timeslot> allSlots = new TimeslotDao().getTimeslotsByTheater(theaterId);
                    while (!current.isAfter(endDate)) {
                        ArrayList<Timeslot> assignedSlots = new ArrayList<>();
                        for (Timeslot t : allSlots) {
                            if (showDao.isSlotAssigned(theaterId, movieId, t.getSlotId(), current)) {
                                assignedSlots.add(t);
                            }
                        }
                        if (!assignedSlots.isEmpty()) {
                %>
                    <button type="button" class="date-btn px-6 py-3 rounded-xl border border-indigo-600 bg-white hover:bg-indigo-50 transition" data-date="<%= current %>">
                        <%= current %>
                    </button>
                <%
                        }
                        current = current.plusDays(1);
                    }
                %>
            </div>

            <!-- Timeslots -->
            <div id="timeslots-container" class="flex flex-wrap justify-center gap-4 mb-6 hidden">
                <%
                    current = startDate;
                    while (!current.isAfter(endDate)) {
                        ArrayList<Timeslot> assignedSlots = new ArrayList<>();
                        for (Timeslot t : allSlots) {
                            if (showDao.isSlotAssigned(theaterId, movieId, t.getSlotId(), current)) {
                                assignedSlots.add(t);
                            }
                        }
                        for (Timeslot t : assignedSlots) {
                %>
                    <button type="button"
                        class="slot-btn hidden bg-indigo-600 text-white px-6 py-3 rounded-xl shadow hover:bg-indigo-700 transition"
                        data-date="<%= current %>" data-slot-id="<%= t.getSlotId() %>">
                        <%= t.getStartTime() %> - <%= t.getEndTime() %>
                    </button>
                <%
                        }
                        current = current.plusDays(1);
                    }
                %>
            </div>

            <!-- Seats -->
            <div id="seats-container" class="hidden mt-6">
                <h2 class="text-xl font-bold mb-4 text-center text-indigo-700">Select Your Seats</h2>
                <div class="grid grid-cols-8 gap-2 justify-center" id="seats-grid">
                    <% for(char row='A'; row<='D'; row++) {
                        for(int col=1; col<=8; col++) { %>
                            <button type="button" class="seat bg-gray-300 p-4 rounded" data-seat="<%= row %><%= col %>">
                                <%= row %><%= col %>
                            </button>
                    <% }} %>
                </div>
            </div>

            <div class="text-center mt-6">
                <button type="submit" id="confirm-btn" class="px-8 py-3 bg-indigo-600 text-white rounded-xl hover:bg-indigo-700 transition" disabled>
                    Book Now
                </button>
            </div>
        </form>

        <script>
            const dates = document.querySelectorAll('.date-btn');
            const timeslots = document.querySelectorAll('.slot-btn');
            const timeslotsContainer = document.getElementById('timeslots-container');
            const seatsContainer = document.getElementById('seats-container');
            const seatsGrid = document.getElementById('seats-grid');
            const selectedDateInput = document.getElementById('selected-date');
            const selectedSlotInput = document.getElementById('selected-slot-id');
            const selectedSeatsInput = document.getElementById('selected-seats');
            const confirmBtn = document.getElementById('confirm-btn');

            // Click date
            dates.forEach(dateBtn => {
                dateBtn.addEventListener('click', () => {
                    const date = dateBtn.dataset.date;
                    selectedDateInput.value = date;

                    // Highlight selected date
                    dates.forEach(d => d.classList.remove('bg-indigo-600','text-white'));
                    dateBtn.classList.add('bg-indigo-600','text-white');

                    // Show timeslots container and timeslots for this date
                    timeslotsContainer.classList.remove('hidden');
                    seatsContainer.classList.add('hidden'); // hide seats until slot selected
                    timeslots.forEach(slot => {
                        slot.classList.remove('bg-indigo-800');
                        if (slot.dataset.date === date) {
                            slot.classList.remove('hidden');
                        } else {
                            slot.classList.add('hidden');
                        }
                    });

                    // Reset selection
                    selectedSlotInput.value = '';
                    selectedSeatsInput.value = '';
                    confirmBtn.disabled = true;
                });
            });

            // Click timeslot
            timeslots.forEach(slotBtn => {
                slotBtn.addEventListener('click', () => {
                    // Highlight selected slot
                    timeslots.forEach(s => s.classList.remove('bg-indigo-800'));
                    slotBtn.classList.add('bg-indigo-800');

                    selectedSlotInput.value = slotBtn.dataset.slotId;

                    // Show seats
                    seatsContainer.classList.remove('hidden');

                    // Reset seats selection
                    seatsGrid.querySelectorAll('.seat').forEach(seat => seat.classList.remove('selected'));
                    selectedSeatsInput.value = '';
                    confirmBtn.disabled = true;

                    // Seat click logic
                    seatsGrid.querySelectorAll('.seat').forEach(seat => {
                        seat.addEventListener('click', () => {
                            seat.classList.toggle('selected');
                            const selectedSeats = Array.from(seatsGrid.querySelectorAll('.seat.selected')).map(s => s.dataset.seat);
                            selectedSeatsInput.value = selectedSeats.join(',');
                            confirmBtn.disabled = selectedSeats.length === 0;
                        });
                    });
                });
            });
        </script>

        <% } %>
    </div>
</section>

<jsp:include page="layout/footer.jsp"></jsp:include>
<jsp:include page="layout/JSPFooter.jsp"></jsp:include>
