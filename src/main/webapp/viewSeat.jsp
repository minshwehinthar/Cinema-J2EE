<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.demo.model.Seat" %>
<%@ page import="com.demo.dao.SeatsDao" %>

<%
    com.demo.model.User user = (com.demo.model.User) session.getAttribute("user");
    if (user == null || !"admin".equals(user.getRole())) {
        response.sendRedirect("login.jsp?msg=unauthorized");
        return;
    }

    Integer theaterId = (Integer) session.getAttribute("theater_id");
    if (theaterId == null) {
        response.sendRedirect("create-theater-admin.jsp?msg=noTheater");
        return;
    }

    // Load seats
    SeatsDao seatDao = new SeatsDao();
    List<Seat> seatsList = seatDao.getSeatsByTheater(theaterId);

    // Sort seats: first by row letter, then by numeric seat number
    seatsList.sort((s1, s2) -> {
        char row1 = s1.getSeatNumber().charAt(0);
        char row2 = s2.getSeatNumber().charAt(0);
        if (row1 != row2) return row1 - row2;

        int num1 = Integer.parseInt(s1.getSeatNumber().substring(1));
        int num2 = Integer.parseInt(s2.getSeatNumber().substring(1));
        return num1 - num2;
    });
%>

<jsp:include page="layout/JSPHeader.jsp"/>
<div class="min-h-screen bg-white">
    <jsp:include page="layout/sidebar.jsp"/>
    <div class="sm:ml-64">
        <jsp:include page="layout/AdminHeader.jsp"/>

        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
            <!-- Header Section -->
            <div class="text-center mb-12">
                
                <h1 class="text-4xl font-bold text-gray-900 mb-3">
                    Theater Layout
                </h1>
                <p class="text-lg text-gray-600 mx-auto">
                    Visual overview of your seating arrangement and capacity
                </p>
            </div>

            <!-- Clean Stats Cards -->
            <div class="grid grid-cols-1 md:grid-cols-4 gap-4 mb-10">
                <div class="bg-white rounded-xl border border-gray-200 p-5">
                    <div class="flex items-center justify-between">
                        <div>
                            <p class="text-sm font-medium text-gray-500 uppercase tracking-wide">Total Seats</p>
                            <p class="text-2xl font-bold text-gray-900 mt-1"><%= seatsList.size() %></p>
                        </div>
                        <div class="p-2 bg-blue-50 rounded-lg">
                            <svg class="w-6 h-6 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z"/>
                            </svg>
                        </div>
                    </div>
                </div>

                <div class="bg-white rounded-xl border border-gray-200 p-5">
                    <div class="flex items-center justify-between">
                        <div>
                            <p class="text-sm font-medium text-gray-500 uppercase tracking-wide">VIP Seats</p>
                            <p class="text-2xl font-bold text-gray-900 mt-1">
                                <%= seatsList.stream().filter(s -> "VIP".equalsIgnoreCase(s.getSeatType())).count() %>
                            </p>
                        </div>
                        <div class="p-2 bg-yellow-50 rounded-lg">
                            <svg class="w-6 h-6 text-yellow-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"/>
                            </svg>
                        </div>
                    </div>
                </div>

                <div class="bg-white rounded-xl border border-gray-200 p-5">
                    <div class="flex items-center justify-between">
                        <div>
                            <p class="text-sm font-medium text-gray-500 uppercase tracking-wide">Couple Seats</p>
                            <p class="text-2xl font-bold text-gray-900 mt-1">
                                <%= seatsList.stream().filter(s -> "COUPLE".equalsIgnoreCase(s.getSeatType())).count() %>
                            </p>
                        </div>
                        <div class="p-2 bg-pink-50 rounded-lg">
                            <svg class="w-6 h-6 text-pink-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4.318 6.318a4.5 4.5 0 000 6.364L12 20.364l7.682-7.682a4.5 4.5 0 00-6.364-6.364L12 7.636l-1.318-1.318a4.5 4.5 0 00-6.364 0z"/>
                            </svg>
                        </div>
                    </div>
                </div>

                <div class="bg-white rounded-xl border border-gray-200 p-5">
                    <div class="flex items-center justify-between">
                        <div>
                            <p class="text-sm font-medium text-gray-500 uppercase tracking-wide">Standard</p>
                            <p class="text-2xl font-bold text-gray-900 mt-1">
                                <%= seatsList.stream().filter(s -> !"VIP".equalsIgnoreCase(s.getSeatType()) && !"COUPLE".equalsIgnoreCase(s.getSeatType())).count() %>
                            </p>
                        </div>
                        <div class="p-2 bg-gray-50 rounded-lg">
                            <svg class="w-6 h-6 text-gray-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z"/>
                            </svg>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Clean Seat Layout Container -->
            <div class="bg-white rounded-2xl border border-gray-200 overflow-hidden">
                <!-- Screen Section -->
                <div class="py-8 px-6 text-center bg-gray-900">
                    <div class="max-w-4xl mx-auto">
                        <div class="h-2 bg-gray-600 rounded-full mb-4"></div>
                        <h3 class="text-xl font-semibold text-white">SCREEN</h3>
                        <p class="text-gray-400 text-sm mt-1">All seats face this direction</p>
                    </div>
                </div>

                <!-- Seat Grid -->
                <div class="p-8">
                    <div id="seatRows" class="max-w-5xl mx-auto space-y-6">
                        <%
                            char lastRow = ' ';
                            List<Seat> rowSeats = new java.util.ArrayList<>();

                            for (Seat seat : seatsList) {
                                char rowLetter = seat.getSeatNumber().charAt(0);

                                if (rowLetter != lastRow) {
                                    if (!rowSeats.isEmpty()) {
                                        out.print("<div class='seat-row flex justify-center gap-3 mb-6'>");
                                        out.print("<div class='row-label w-8 h-8 flex items-center justify-center font-semibold text-gray-700 bg-gray-100 rounded-lg text-sm mr-4'>" + lastRow + "</div>");
                                        for (Seat s : rowSeats) {
                                            String seatClass = "rounded-lg font-medium transition-all duration-200 flex items-center justify-center border ";
                                            
                                            if ("VIP".equalsIgnoreCase(s.getSeatType())) {
                                                seatClass += "bg-yellow-100 border-yellow-200 text-yellow-700 hover:bg-yellow-200 ";
                                            } else if ("COUPLE".equalsIgnoreCase(s.getSeatType())) {
                                                seatClass += "bg-pink-100 border-pink-200 text-pink-700 hover:bg-pink-200 ";
                                            } else {
                                                seatClass += "bg-gray-100 border-gray-200 text-gray-700 hover:bg-gray-200 ";
                                            }

                                            if ("COUPLE".equalsIgnoreCase(s.getSeatType())) {
                                                seatClass += "w-16 h-12 text-xs";
                                            } else {
                                                seatClass += "w-12 h-12 text-sm";
                                            }

                                            out.print("<div class='" + seatClass + "' title='Seat: " + s.getSeatNumber() + " | Type: " + s.getSeatType() + "'>" + 
                                                     s.getSeatNumber().substring(1) + "</div>");
                                        }
                                        out.print("</div>");
                                    }
                                    rowSeats.clear();
                                    lastRow = rowLetter;
                                }
                                rowSeats.add(seat);
                            }

                            // Print last row
                            if (!rowSeats.isEmpty()) {
                                out.print("<div class='seat-row flex justify-center gap-3 mb-6'>");
                                out.print("<div class='row-label w-8 h-8 flex items-center justify-center font-semibold text-gray-700 bg-gray-100 rounded-lg text-sm mr-4'>" + lastRow + "</div>");
                                for (Seat s : rowSeats) {
                                    String seatClass = "rounded-lg font-medium transition-all duration-200 flex items-center justify-center border ";

                                    if ("VIP".equalsIgnoreCase(s.getSeatType())) {
                                        seatClass += "bg-yellow-100 border-yellow-200 text-yellow-700 hover:bg-yellow-200 ";
                                    } else if ("COUPLE".equalsIgnoreCase(s.getSeatType())) {
                                        seatClass += "bg-pink-100 border-pink-200 text-pink-700 hover:bg-pink-200 ";
                                    } else {
                                        seatClass += "bg-gray-100 border-gray-200 text-gray-700 hover:bg-gray-200 ";
                                    }

                                    if ("COUPLE".equalsIgnoreCase(s.getSeatType())) {
                                        seatClass += "w-16 h-12 text-xs";
                                    } else {
                                        seatClass += "w-12 h-12 text-sm";
                                    }

                                    out.print("<div class='" + seatClass + "' title='Seat: " + s.getSeatNumber() + " | Type: " + s.getSeatType() + "'>" + 
                                             s.getSeatNumber().substring(1) + "</div>");
                                }
                                out.print("</div>");
                            }
                        %>
                    </div>

                    <!-- Aisle Indicators -->
                    <div class="max-w-5xl mx-auto mt-10 flex justify-between items-center px-12">
                        <div class="text-center">
                            <div class="w-12 h-1 bg-gray-300 mx-auto mb-2"></div>
                            <span class="text-xs font-medium text-gray-500">AISLE</span>
                        </div>
                        <div class="text-center">
                            <div class="w-12 h-1 bg-gray-300 mx-auto mb-2"></div>
                            <span class="text-xs font-medium text-gray-500">AISLE</span>
                        </div>
                    </div>
                </div>

                <!-- Clean Legend -->
                <div class="bg-gray-50 border-t border-gray-200 px-8 py-6">
                    <div class="max-w-5xl mx-auto">
                        <h4 class="text-base font-semibold text-gray-900 mb-4">Seat Types</h4>
                        <div class="flex flex-wrap gap-6">
                            <div class="flex items-center space-x-3">
                                <div class="w-10 h-10 rounded-lg bg-gray-100 border border-gray-200"></div>
                                <div>
                                    <span class="text-sm font-medium text-gray-700">Standard</span>
                                    <p class="text-xs text-gray-500">Regular seating</p>
                                </div>
                            </div>
                            <div class="flex items-center space-x-3">
                                <div class="w-10 h-10 rounded-lg bg-yellow-100 border border-yellow-200"></div>
                                <div>
                                    <span class="text-sm font-medium text-gray-700">VIP</span>
                                    <p class="text-xs text-gray-500">Premium seating</p>
                                </div>
                            </div>
                            <div class="flex items-center space-x-3">
                                <div class="w-14 h-10 rounded-lg bg-pink-100 border border-pink-200"></div>
                                <div>
                                    <span class="text-sm font-medium text-gray-700">Couple</span>
                                    <p class="text-xs text-gray-500">Double seating</p>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            

        </div>
    </div>
</div>
<jsp:include page="layout/JSPFooter.jsp"/>