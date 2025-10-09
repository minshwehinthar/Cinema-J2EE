<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.time.LocalDate"%>
<%@ page import="java.util.List"%>
<%@ page import="com.demo.dao.ShowtimesDao"%>
<%@ page import="com.demo.dao.SeatsDao"%>
<%@ page import="com.demo.model.Seat"%>
<%@ page import="com.demo.model.ShowtimeSeat"%>
<%@ page import="com.demo.model.Timeslot"%>

<jsp:include page="layout/JSPHeader.jsp"/>
<jsp:include page="layout/header.jsp"/>

<%
String movieIdParam = request.getParameter("movie_id");
String theaterIdParam = request.getParameter("theater_id");
int movieId = 0, theaterId = 0;
String error = null;

if(movieIdParam == null || theaterIdParam == null){
    error = "Invalid selection. Please pick a movie and theater first.";
} else {
    try {
        movieId = Integer.parseInt(movieIdParam);
        theaterId = Integer.parseInt(theaterIdParam);
    } catch(NumberFormatException e){
        error = "Invalid movie or theater ID.";
    }
}

ShowtimesDao showDao = new ShowtimesDao();
SeatsDao seatsDao = new SeatsDao();
LocalDate startDate = null, endDate = null;

if(error == null){
    LocalDate[] dates = showDao.getMovieDates(theaterId, movieId);
    if(dates == null) error = "Movie dates not found for this theater.";
    else { startDate = dates[0]; endDate = dates[1]; }
}
%>

<section class="bg-white min-h-screen py-8">
    <div class="container mx-auto px-13 max-w-6xl">
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
            <li>
              <a href="GetMovieTheatersServlet?movie_id=<%= movieId %>" class="hover:text-red-600">
                Available Theaters
              </a>
            </li>
            <li><span class="mx-2">/</span></li>
            <li class="text-gray-900 font-semibold">Seat</li>
          </ol>
        </nav>
        <!-- Page Header -->
        <div class="text-center mb-8">
            <h1 class="text-4xl font-bold text-gray-900 mb-3">Select Your Seats</h1>
            <p class="text-gray-600 text-lg">Choose your preferred date, time, and seats</p>
        </div>

        <% if(error != null){ %>
            <div class="bg-red-50 border-l-4 border-red-500 rounded-lg p-4 max-w-2xl mx-auto mb-8">
                <div class="flex items-center">
                    <div class="flex-shrink-0">
                        <svg class="h-5 w-5 text-red-400" viewBox="0 0 20 20" fill="currentColor">
                            <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z" clip-rule="evenodd"/>
                        </svg>
                    </div>
                    <div class="ml-3">
                        <p class="text-red-700"><%= error %></p>
                    </div>
                </div>
            </div>
        <% } else { %>

        <form id="booking-form" action="CheckOutBookingServlet" method="post">
            <input type="hidden" name="movieId" value="<%= movieId %>">
            <input type="hidden" name="theaterId" value="<%= theaterId %>">
            <input type="hidden" name="slotId" id="selected-slot-id">
            <input type="hidden" name="showDate" id="selected-date">
            <input type="hidden" name="selectedSeats" id="selected-seats">
            <input type="hidden" name="selectedSeatIds" id="selected-seat-ids">
            <input type="hidden" name="showtimeId" id="selected-showtime-id">
            <input type="hidden" name="totalPrice" id="total-price-input">
            
            <!-- Seat Prices -->
            <div class="mb-6 flex justify-center">
                <div class="flex gap-5">
                    <%
                        List<Seat> allSeats = seatsDao.getSeatsByTheater(theaterId);
                        java.util.Set<String> seatTypesPrinted = new java.util.HashSet<>();
                        for(Seat s : allSeats){
                            if(!seatTypesPrinted.contains(s.getSeatType())){
                                String bgColor = "bg-gray-50";
                                String borderColor = "border-gray-200";
                                String iconColor = "text-gray-600";

                                if(s.getSeatType().equalsIgnoreCase("VIP")) { 
                                    bgColor = "bg-yellow-50"; 
                                    borderColor = "border-yellow-400"; 
                                    iconColor = "text-yellow-600";
                                }
                                else if(s.getSeatType().equalsIgnoreCase("Couple")) { 
                                    bgColor = "bg-pink-50"; 
                                    borderColor = "border-pink-400"; 
                                    iconColor = "text-pink-600";
                                }
                                else if(s.getSeatType().equalsIgnoreCase("Normal")) { 
                                    bgColor = "bg-green-50"; 
                                    borderColor = "border-green-400"; 
                                    iconColor = "text-green-600";
                                }
                    %>
                    <div class="flex flex-col items-center justify-center p-5 rounded-2xl border-2 <%= borderColor %> shadow hover:shadow-lg transition-all duration-300 <%= bgColor %>">
                        <div class="<%= iconColor %> mb-2">
                            <% if(s.getSeatType().equalsIgnoreCase("Couple")) { %>
                                <!-- Sofa Icon for Couple Seats -->
                                <svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="lucide lucide-sofa">
                                    <path d="M20 9V6a2 2 0 0 0-2-2H6a2 2 0 0 0-2 2v3"/>
                                    <path d="M2 11v5a2 2 0 0 0 2 2h16a2 2 0 0 0 2-2v-5a2 2 0 0 0-4 0v2H6v-2a2 2 0 0 0-4 0Z"/>
                                    <path d="M4 18v2"/>
                                    <path d="M20 18v2"/>
                                    <path d="M12 4v9"/>
                                </svg>
                            <% } else { %>
                                <!-- Armchair Icon for Normal and VIP Seats -->
                                <svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="lucide lucide-armchair">
                                    <path d="M19 9V6a2 2 0 0 0-2-2H7a2 2 0 0 0-2 2v3"/>
                                    <path d="M3 16a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-5a2 2 0 0 0-4 0v1.5a.5.5 0 0 1-.5.5h-9a.5.5 0 0 1-.5-.5V11a2 2 0 0 0-4 0z"/>
                                    <path d="M5 18v2"/>
                                    <path d="M19 18v2"/>
                                </svg>
                            <% } %>
                        </div>
                        <span class="text-gray-800 font-semibold text-center text-lg"><%= s.getSeatType() %></span>
                        <span class="text-red-600 font-bold mt-2 text-center text-lg"><%= s.getPrice() %> MMK</span>
                    </div>
                    <%
                                seatTypesPrinted.add(s.getSeatType());
                            }
                        }
                    %>
                </div>
            </div>

            <!-- Selection Steps -->
            <div class="flex flex-col space-y-6">
                <!-- Date Selection -->
                <div class="">
                    <div id="dates-container" class="flex flex-wrap gap-4 justify-center">
                        <%
                            LocalDate today = LocalDate.now();
                            LocalDate current = startDate;
                            boolean hasFutureDates = false;

                            while(!current.isAfter(endDate)){
                                if(!current.isBefore(today)){
                                    List<Timeslot> assignedSlots = showDao.getAssignedTimeslots(theaterId, movieId, current);
                                    if(!assignedSlots.isEmpty()){
                                        hasFutureDates = true;
                        %>
                        <button type="button" class="date-btn flex items-center justify-center gap-3 px-6 py-4 bg-white rounded-xl border-2 border-gray-200 hover:border-red-500 text-gray-700 font-medium transition-all duration-200 min-w-[180px] hover:shadow-md group" data-date="<%= current %>">
                            <div class="text-sm font-semibold text-gray-500 group-hover:text-red-600"><%= current.getDayOfWeek().toString().substring(0,3) %></div>
                            <div class="text-xl font-bold text-gray-900 group-hover:text-red-700"><%= current.getDayOfMonth() %></div>
                            <div class="text-xs text-gray-400 group-hover:text-red-600"><%= current.getMonth().toString().substring(0,3) %></div>
                        </button>
                        <%      }
                                }
                                current = current.plusDays(1);
                            }
                            if(!hasFutureDates){ %>
                                <p class="text-red-600 font-medium text-lg col-span-3 py-8">No available dates for this movie.</p>
                        <% } %>
                    </div>
                </div>

                <!-- Timeslot Selection -->
                <div id="timeslots-container" >
                    <div class="flex flex-wrap justify-center gap-4">
                        <%
                            current = startDate;
                            while(!current.isAfter(endDate)){
                                if(!current.isBefore(today)){
                                    List<Timeslot> assignedSlots = showDao.getAssignedTimeslots(theaterId, movieId, current);
                                    for(Timeslot t : assignedSlots){
                                        int showtimeId = showDao.getShowtimeId(theaterId, movieId, t.getSlotId(), current);
                        %>
                        <button type="button" class="slot-btn px-8 py-4 bg-white rounded-xl border-2 border-gray-200 hover:border-red-500 text-gray-700 font-medium transition-all duration-200 hidden hover:shadow-md group"
                                data-date="<%= current %>"
                                data-slot-id="<%= t.getSlotId() %>"
                                data-showtime-id="<%= showtimeId %>">
                            <div class="font-semibold text-lg text-gray-900 group-hover:text-red-700"><%= t.getStartTime() %></div>
                        </button>
                        <%      }
                                }
                                current = current.plusDays(1);
                            } %>
                    </div>
                </div>

                <!-- Main Content Grid -->
                <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
                    <!-- Seat Layout -->
                    <div class="lg:col-span-2">
                        <div id="seat-container">
                        <%
                            current = startDate;
                            while(!current.isAfter(endDate)){
                                if(!current.isBefore(today)){
                                    List<Timeslot> assignedSlots = showDao.getAssignedTimeslots(theaterId, movieId, current);
                                    for(Timeslot t : assignedSlots){
                                        int showtimeId = showDao.getShowtimeId(theaterId, movieId, t.getSlotId(), current);
                                        List<ShowtimeSeat> seatsList = seatsDao.getSeatsByShowtime(showtimeId);
                        %>
                            <div class="seat-rows hidden seats-for-<%= showtimeId %>">
                                <!-- Screen -->
                                <div class="mb-6">
                                    <div class="bg-gray-900 text-white text-center mx-auto max-w-2xl rounded-t-xl font-bold shadow-xl py-2">
                                        SCREEN
                                    </div>
                                </div>

                                <!-- Seat Grid -->
                                <div class="flex justify-center">
                                    <div class="seat-plan space-y-2 max-w-4xl">
                                    <%
                                        char lastRow = ' ';
                                        List<ShowtimeSeat> rowSeats = new java.util.ArrayList<>();
                                        for(ShowtimeSeat ss : seatsList){
                                            Seat s = ss.getSeat();
                                            char rowLetter = s.getSeatNumber().charAt(0);

                                            if(rowLetter != lastRow){
                                                if(!rowSeats.isEmpty()){
                                                    out.print("<div class='seat-row flex items-center gap-1 justify-center mb-2'>");
                                                    out.print("<div class='row-label w-8 h-8 flex items-center justify-center font-bold text-gray-700 bg-white rounded-lg border border-gray-300 shadow-sm mr-2'>" + lastRow + "</div>");
                                                    for(ShowtimeSeat rs : rowSeats){
                                                        Seat seatObj = rs.getSeat();
                                                        String seatClass = "seat group relative flex items-center justify-center transition-all duration-200 cursor-pointer ";
                                                        
                                                        // Base styling
                                                        if(rs.getStatus().equals("booked")) {
                                                            seatClass += "opacity-50 cursor-not-allowed ";
                                                        } else {
                                                            seatClass += "hover:scale-110 ";
                                                        }

                                                        // Size based on seat type
                                                        if(seatObj.getSeatType().equals("Couple")) {
                                                            seatClass += "w-12 h-12 ";
                                                        } else {
                                                            seatClass += "w-10 h-10 ";
                                                        }

                                                        out.print("<button type='button' class='"+seatClass+"' data-seat='"+seatObj.getSeatNumber()+"' data-seatid='"+rs.getId()+"' data-type='"+seatObj.getSeatType()+"' data-price='"+seatObj.getPrice()+"' data-status='"+rs.getStatus()+"'>");
                                                        
                                                     // Seat icon with color based on type and status
                                                        String iconColor = "text-gray-400";
                                                        if(rs.getStatus().equals("booked")) {
                                                            iconColor = "text-gray-400";
                                                        } else if(seatObj.getSeatType().equals("VIP")) {
                                                            iconColor = "text-yellow-600";
                                                        } else if(seatObj.getSeatType().equals("Couple")) {
                                                            iconColor = "text-pink-600";
                                                        } else {
                                                            iconColor = "text-green-600";
                                                        }
                                                        
                                                        if(seatObj.getSeatType().equals("Couple")) {
                                                            out.print("<svg xmlns='http://www.w3.org/2000/svg' width='24' height='24' viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2' stroke-linecap='round' stroke-linejoin='round' class='lucide lucide-sofa "+iconColor+"'><path d='M20 9V6a2 2 0 0 0-2-2H6a2 2 0 0 0-2 2v3'/><path d='M2 11v5a2 2 0 0 0 2 2h16a2 2 0 0 0 2-2v-5a2 2 0 0 0-4 0v2H6v-2a2 2 0 0 0-4 0Z'/><path d='M4 18v2'/><path d='M20 18v2'/><path d='M12 4v9'/></svg>");
                                                        } else {
                                                            out.print("<svg xmlns='http://www.w3.org/2000/svg' width='24' height='24' viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2' stroke-linecap='round' stroke-linejoin='round' class='lucide lucide-armchair "+iconColor+"'><path d='M19 9V6a2 2 0 0 0-2-2H7a2 2 0 0 0-2 2v3'/><path d='M3 16a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-5a2 2 0 0 0-4 0v1.5a.5.5 0 0 1-.5.5h-9a.5.5 0 0 1-.5-.5V11a2 2 0 0 0-4 0z'/><path d='M5 18v2'/><path d='M19 18v2'/></svg>");
                                                        }
                                                        
                                                        // Hover tooltip for seat number - positioned closer
                                                        out.print("<div class='absolute -top-6 left-1/2 transform -translate-x-1/2 bg-gray-900 text-white text-xs font-medium px-2 py-1 rounded opacity-0 group-hover:opacity-100 transition-opacity duration-200 pointer-events-none z-10 whitespace-nowrap'>");
                                                        out.print(seatObj.getSeatNumber());
                                                        out.print("</div>");
                                                        
                                                        out.print("</button>");
                                                    }
                                                    out.print("</div>");
                                                }
                                                rowSeats.clear();
                                                lastRow = rowLetter;
                                            }
                                            rowSeats.add(ss);
                                        }

                                        if(!rowSeats.isEmpty()){
                                            out.print("<div class='seat-row flex items-center gap-1 justify-center mb-2'>");
                                            out.print("<div class='row-label w-8 h-8 flex items-center justify-center font-bold text-gray-700 bg-white rounded-lg border border-gray-300 shadow-sm mr-2'>" + lastRow + "</div>");
                                            for(ShowtimeSeat rs : rowSeats){
                                                Seat seatObj = rs.getSeat();
                                                String seatClass = "seat group relative flex items-center justify-center transition-all duration-200 cursor-pointer ";
                                                
                                                // Base styling
                                                if(rs.getStatus().equals("booked")) {
                                                    seatClass += "opacity-50 cursor-not-allowed ";
                                                } else {
                                                    seatClass += "hover:scale-110 ";
                                                }

                                                // Size based on seat type
                                                if(seatObj.getSeatType().equals("Couple")) {
                                                    seatClass += "w-14 h-14 ";
                                                } else {
                                                    seatClass += "w-10 h-10 ";
                                                }

                                                out.print("<button type='button' class='"+seatClass+"' data-seat='"+seatObj.getSeatNumber()+"' data-seatid='"+rs.getId()+"' data-type='"+seatObj.getSeatType()+"' data-price='"+seatObj.getPrice()+"' data-status='"+rs.getStatus()+"'>");
                                                
                                                // Seat icon with color based on type and status
                                                String iconColor = "text-gray-400";
                                                if(rs.getStatus().equals("booked")) {
                                                    iconColor = "text-gray-400";
                                                } else if(seatObj.getSeatType().equals("VIP")) {
                                                    iconColor = "text-yellow-600";
                                                } else if(seatObj.getSeatType().equals("Couple")) {
                                                    iconColor = "text-pink-600";
                                                } else {
                                                    iconColor = "text-green-600";
                                                }
                                                
                                                if(seatObj.getSeatType().equals("Couple")) {
                                                    out.print("<svg xmlns='http://www.w3.org/2000/svg' width='24' height='24' viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2' stroke-linecap='round' stroke-linejoin='round' class='lucide lucide-sofa "+iconColor+"'><path d='M20 9V6a2 2 0 0 0-2-2H6a2 2 0 0 0-2 2v3'/><path d='M2 11v5a2 2 0 0 0 2 2h16a2 2 0 0 0 2-2v-5a2 2 0 0 0-4 0v2H6v-2a2 2 0 0 0-4 0Z'/><path d='M4 18v2'/><path d='M20 18v2'/><path d='M12 4v9'/></svg>");
                                                } else {
                                                    out.print("<svg xmlns='http://www.w3.org/2000/svg' width='20' height='20' viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2' stroke-linecap='round' stroke-linejoin='round' class='lucide lucide-armchair "+iconColor+"'><path d='M19 9V6a2 2 0 0 0-2-2H7a2 2 0 0 0-2 2v3'/><path d='M3 16a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-5a2 2 0 0 0-4 0v1.5a.5.5 0 0 1-.5.5h-9a.5.5 0 0 1-.5-.5V11a2 2 0 0 0-4 0z'/><path d='M5 18v2'/><path d='M19 18v2'/></svg>");
                                                }
                                                
                                                // Hover tooltip for seat number - positioned closer
                                                out.print("<div class='absolute -top-6 left-1/2 transform -translate-x-1/2 bg-gray-900 text-white text-xs font-medium px-2 py-1 rounded opacity-0 group-hover:opacity-100 transition-opacity duration-200 pointer-events-none z-10 whitespace-nowrap'>");
                                                out.print(seatObj.getSeatNumber());
                                                out.print("</div>");
                                                
                                                out.print("</button>");
                                            }
                                            out.print("</div>");
                                        }
                                    %>
                                    </div>
                                </div>
                                
                                <!-- Seat Legend -->
                                <div class="seat-legend grid grid-cols-5 gap-4 mt-6 p-4 bg-gray-50 rounded-xl border border-gray-200">
                                    <div class="flex flex-col items-center gap-2">
                                        <div class="w-10 h-10 flex items-center justify-center">
                                            <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="lucide lucide-armchair text-green-600">
                                                <path d="M19 9V6a2 2 0 0 0-2-2H7a2 2 0 0 0-2 2v3"/>
                                                <path d="M3 16a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-5a2 2 0 0 0-4 0v1.5a.5.5 0 0 1-.5.5h-9a.5.5 0 0 1-.5-.5V11a2 2 0 0 0-4 0z"/>
                                                <path d="M5 18v2"/>
                                                <path d="M19 18v2"/>
                                            </svg>
                                        </div>
                                        <span class="text-gray-700 text-sm font-medium">Normal</span>
                                    </div>
                                    <div class="flex flex-col items-center gap-2">
                                        <div class="w-10 h-10 flex items-center justify-center">
                                            <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="lucide lucide-armchair text-yellow-600">
                                                <path d="M19 9V6a2 2 0 0 0-2-2H7a2 2 0 0 0-2 2v3"/>
                                                <path d="M3 16a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-5a2 2 0 0 0-4 0v1.5a.5.5 0 0 1-.5.5h-9a.5.5 0 0 1-.5-.5V11a2 2 0 0 0-4 0z"/>
                                                <path d="M5 18v2"/>
                                                <path d="M19 18v2"/>
                                            </svg>
                                        </div>
                                        <span class="text-gray-700 text-sm font-medium">VIP</span>
                                    </div>
                                    <div class="flex flex-col items-center gap-2">
                                        <div class="w-12 h-12 flex items-center justify-center">
                                            <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="lucide lucide-sofa text-pink-600">
                                                <path d="M20 9V6a2 2 0 0 0-2-2H6a2 2 0 0 0-2 2v3"/>
                                                <path d="M2 11v5a2 2 0 0 0 2 2h16a2 2 0 0 0 2-2v-5a2 2 0 0 0-4 0v2H6v-2a2 2 0 0 0-4 0Z"/>
                                                <path d="M4 18v2"/>
                                                <path d="M20 18v2"/>
                                                <path d="M12 4v9"/>
                                            </svg>
                                        </div>
                                        <span class="text-gray-700 text-sm font-medium">Couple</span>
                                    </div>
                                    <div class="flex flex-col items-center gap-2">
                                        <div class="w-10 h-10 flex items-center justify-center">
                                            <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="lucide lucide-armchair text-blue-600">
                                                <path d="M19 9V6a2 2 0 0 0-2-2H7a2 2 0 0 0-2 2v3"/>
                                                <path d="M3 16a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-5a2 2 0 0 0-4 0v1.5a.5.5 0 0 1-.5.5h-9a.5.5 0 0 1-.5-.5V11a2 2 0 0 0-4 0z"/>
                                                <path d="M5 18v2"/>
                                                <path d="M19 18v2"/>
                                            </svg>
                                        </div>
                                        <span class="text-gray-700 text-sm font-medium">Selected</span>
                                    </div>
                                   <div class="flex flex-col items-center gap-2">
                                        <div class="w-10 h-10 flex items-center justify-center opacity-50">
                                            <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="lucide lucide-armchair text-gray-400">
                                                <path d="M19 9V6a2 2 0 0 0-2-2H7a2 2 0 0 0-2 2v3"/>
                                                <path d="M3 16a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-5a2 2 0 0 0-4 0v1.5a.5.5 0 0 1-.5.5h-9a.5.5 0 0 1-.5-.5V11a2 2 0 0 0-4 0z"/>
                                                <path d="M5 18v2"/>
                                                <path d="M19 18v2"/>
                                            </svg>
                                        </div>
                                        <span class="text-gray-700 text-sm font-medium">Booked</span>
                                    </div>
                                </div>
                            </div>
                        <%      }
                                }
                                current = current.plusDays(1);
                            } %>
                        </div>
                    </div>

                   <!-- Booking Summary -->
<div class="lg:col-span-1">
    <div id="booking-summary" class="bg-white rounded-2xl p-6 border border-gray-200 sticky top-6 ">
        <h2 class="text-2xl font-bold text-gray-900 mb-6 text-center border-b border-gray-200 pb-4">Booking Summary</h2>

        <!-- Selected Seats & Total -->
        <div class="space-y-4 mb-6 bg-red-50 rounded-xl p-4 border border-red-200">
            <div class="text-center">
                <p class="text-gray-600 text-sm mb-1">Selected Seats</p>
                <p id="selected-seat-numbers" class="text-xl font-bold text-red-700">None</p>
            </div>
            <div class="text-center pt-3 border-t border-red-200">
                <p class="text-gray-600 text-sm mb-1">Total Price</p>
                <p id="total-price" class="text-2xl font-bold text-red-600">0 MMK</p>
            </div>
        </div>

        <button type="submit" id="confirm-btn" class="w-full px-6 py-4 bg-red-600 rounded-lg text-white active:bg-red-700 hover:bg-red-700 transition-all duration-200 disabled:bg-gray-400 disabled:cursor-not-allowed font-bold text-lg">
            Proceed to Checkout
        </button>
    </div>
</div>

            </div>
        </form>
        <% } %>
    </div>
</section>

<script>
const datesContainer = document.getElementById('dates-container');
const timeslotsContainer = document.getElementById('timeslots-container');
const seatContainer = document.getElementById('seat-container');
const summaryBox = document.getElementById('booking-summary');
const selectedSeatsInput = document.getElementById('selected-seats');
const selectedSeatIdsInput = document.getElementById('selected-seat-ids');
const totalPriceInput = document.getElementById('total-price-input');
const selectedSeatNumbersElem = document.getElementById('selected-seat-numbers');
const totalPriceElem = document.getElementById('total-price');
const confirmBtn = document.getElementById('confirm-btn');
const selectedSlotInput = document.getElementById('selected-slot-id');
const selectedDateInput = document.getElementById('selected-date');
const selectedShowtimeIdInput = document.getElementById('selected-showtime-id');

function hideAllSeats() {
    seatContainer.querySelectorAll('.seat-rows').forEach(div => div.classList.add('hidden'));
}

function resetSelections() {
    selectedSeatsInput.value = '';
    selectedSeatIdsInput.value = '';
    totalPriceInput.value = 0;
    selectedSeatNumbersElem.textContent = 'None';
    totalPriceElem.textContent = '0 MMK';
    confirmBtn.disabled = true;
    
    document.querySelectorAll('.seat').forEach(seat => {
        if(seat.dataset.status !== 'booked') {
            // Reset to original state - no background, just icon color change
            seat.classList.remove('scale-110');
            const svg = seat.querySelector('svg');
            
            // Restore original colors based on seat type
            const type = seat.dataset.type;
            
            svg.classList.remove('text-blue-600', 'text-white');
            
            if(type === 'VIP') {
                svg.classList.add('text-yellow-600');
            } else if(type === 'Couple') {
                svg.classList.add('text-pink-600');
            } else {
                svg.classList.add('text-green-600');
            }
        }
    });
}

datesContainer.querySelectorAll('.date-btn').forEach(btn => {
    btn.addEventListener('click', () => {
        datesContainer.querySelectorAll('.date-btn').forEach(b => {
            b.classList.remove('border-red-500', 'bg-red-50', 'text-red-700', 'shadow-md');
        });
        btn.classList.add('border-red-500', 'bg-red-50', 'text-red-700', 'shadow-md');

        const selectedDate = btn.dataset.date;
        timeslotsContainer.querySelectorAll('.slot-btn').forEach(slotBtn => {
            if(slotBtn.dataset.date === selectedDate) slotBtn.classList.remove('hidden');
            else slotBtn.classList.add('hidden');
        });
        
        timeslotsContainer.classList.remove('hidden');
        selectedDateInput.value = selectedDate;

        hideAllSeats();
        summaryBox.classList.add('hidden');
        resetSelections();
    });
});

timeslotsContainer.querySelectorAll('.slot-btn').forEach(btn => {
    btn.addEventListener('click', () => {
        timeslotsContainer.querySelectorAll('.slot-btn').forEach(b => {
            b.classList.remove('border-red-500', 'bg-red-50', 'text-red-700', 'shadow-md');
        });
        btn.classList.add('border-red-500', 'bg-red-50', 'text-red-700', 'shadow-md');

        const showtimeId = btn.dataset.showtimeId;
        hideAllSeats();
        const seatDiv = seatContainer.querySelector('.seats-for-' + showtimeId);
        if(seatDiv) seatDiv.classList.remove('hidden');

        selectedSlotInput.value = btn.dataset.slotId;
        selectedShowtimeIdInput.value = showtimeId;

        summaryBox.classList.remove('hidden');
        resetSelections();
        attachSeatEvents(seatDiv);
    });
});

function attachSeatEvents(container){
    if(!container) return;
    
    container.querySelectorAll('.seat').forEach(seatBtn => {
        if(seatBtn.dataset.status === 'booked') {
            seatBtn.classList.add('cursor-not-allowed');
            seatBtn.style.pointerEvents = 'none';
            return;
        }
        
        seatBtn.addEventListener('click', () => {
            if(seatBtn.dataset.status === 'booked') return;

            const isSelected = seatBtn.querySelector('svg').classList.contains('text-blue-600');
            const svg = seatBtn.querySelector('svg');
            
            if(isSelected) {
                // Deselect - return to original color
                seatBtn.classList.remove('scale-110');
                svg.classList.remove('text-blue-600');
                
                // Restore original color based on seat type
                const type = seatBtn.dataset.type;
                if(type === 'VIP') {
                    svg.classList.add('text-yellow-600');
                } else if(type === 'Couple') {
                    svg.classList.add('text-pink-600');
                } else {
                    svg.classList.add('text-green-600');
                }
            } else {
                // Select - change to blue color
                seatBtn.classList.add('scale-110');
                svg.classList.remove('text-yellow-600', 'text-pink-600', 'text-green-600');
                svg.classList.add('text-blue-600');
            }

            updateBookingSummary(container);
        });
    });
}

function updateBookingSummary(container) {
    const selectedSeats = Array.from(container.querySelectorAll('.seat'))
        .filter(seat => seat.querySelector('svg').classList.contains('text-blue-600') && seat.dataset.status !== 'booked');
    
    const seatNumbers = selectedSeats.map(s => s.dataset.seat).join(', ');
    const seatIds = selectedSeats.map(s => s.dataset.seatid).join(',');
    const totalPrice = selectedSeats.reduce((sum, s) => sum + parseInt(s.dataset.price || 0), 0);

    selectedSeatsInput.value = seatNumbers;
    selectedSeatIdsInput.value = seatIds;
    totalPriceInput.value = totalPrice;

    selectedSeatNumbersElem.textContent = seatNumbers || 'None';
    totalPriceElem.textContent = totalPrice + ' MMK';
    confirmBtn.disabled = !selectedSeats.length;
}
</script>

<jsp:include page="layout/footer.jsp"/>