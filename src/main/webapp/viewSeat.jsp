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
<div class="min-h-screen bg-gray-50">
    <jsp:include page="layout/sidebar.jsp"/>
    <div class="sm:ml-64">
        <jsp:include page="layout/AdminHeader.jsp"/>

        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
            <!-- Header Section -->
            <div class="text-center mb-12">
                <h1 class="text-3xl font-bold text-gray-900 mb-3">Seat Layout</h1>
            </div>

            <!-- Stats Cards -->
            <div class="grid grid-cols-2 md:grid-cols-4 gap-4 mb-10">
                <div class="bg-white rounded-xl shadow-sm p-5 border border-gray-100">
                    <div class="flex items-center">
                        <div class="p-2 bg-blue-50 rounded-lg mr-4">
                            <svg class="w-5 h-5 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2H6a2 2 0 01-2-2V6zM14 6a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2h-2a2 2 0 01-2-2V6zM4 16a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2H6a2 2 0 01-2-2v-2zM14 16a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2h-2a2 2 0 01-2-2v-2z"/>
                            </svg>
                        </div>
                        <div>
                            <p class="text-xs font-medium text-gray-500 uppercase tracking-wide">Total Seats</p>
                            <p class="text-xl font-semibold text-gray-900"><%= seatsList.size() %></p>
                        </div>
                    </div>
                </div>

                <div class="bg-white rounded-xl shadow-sm p-5 border border-gray-100">
                    <div class="flex items-center">
                        <div class="p-2 bg-green-50 rounded-lg mr-4">
                            <svg class="w-5 h-5 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"/>
                            </svg>
                        </div>
                        <div>
                            <p class="text-xs font-medium text-gray-500 uppercase tracking-wide">Available</p>
                            <%
                                long availableSeats = seatsList.stream().filter(s -> !"booked".equalsIgnoreCase(s.getStatus())).count();
                            %>
                            <p class="text-xl font-semibold text-gray-900"><%= availableSeats %></p>
                        </div>
                    </div>
                </div>

                <div class="bg-white rounded-xl shadow-sm p-5 border border-gray-100">
                    <div class="flex items-center">
                        <div class="p-2 bg-red-50 rounded-lg mr-4">
                            <svg class="w-5 h-5 text-red-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/>
                            </svg>
                        </div>
                        <div>
                            <p class="text-xs font-medium text-gray-500 uppercase tracking-wide">Booked</p>
                            <%
                                long bookedSeats = seatsList.stream().filter(s -> "booked".equalsIgnoreCase(s.getStatus())).count();
                            %>
                            <p class="text-xl font-semibold text-gray-900"><%= bookedSeats %></p>
                        </div>
                    </div>
                </div>

                <div class="bg-white rounded-xl shadow-sm p-5 border border-gray-100">
                    <div class="flex items-center">
                        <div class="p-2 bg-purple-50 rounded-lg mr-4">
                            <svg class="w-5 h-5 text-purple-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z"/>
                            </svg>
                        </div>
                        <div>
                            <p class="text-xs font-medium text-gray-500 uppercase tracking-wide">Occupancy</p>
                            <%
                                double occupancy = seatsList.isEmpty() ? 0 : (bookedSeats * 100.0 / seatsList.size());
                            %>
                            <p class="text-xl font-semibold text-gray-900"><%= String.format("%.1f", occupancy) %>%</p>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Seat Layout Container -->
            <div class="bg-white rounded-2xl shadow-sm overflow-hidden border border-gray-200">
                <!-- Screen Section -->
                <div class=" py-6 px-6 text-center">
                    <div class="max-w-4xl mx-auto">
                        <div class="h-2 bg-gray-600 rounded-full mb-3"></div>
                        <h3 class="text-xl font-medium text-gray-800">Screen</h3>
                    </div>
                </div>

                <!-- Seat Grid -->
                <div class="p-6">
                    <div id="seatRows" class="max-w-4xl mx-auto space-y-5">
                        <%
                            char lastRow = ' ';
                            List<Seat> rowSeats = new java.util.ArrayList<>();

                            for (Seat seat : seatsList) {
                                char rowLetter = seat.getSeatNumber().charAt(0);

                                if (rowLetter != lastRow) {
                                    if (!rowSeats.isEmpty()) {
                                        out.print("<div class='seat-row flex justify-center gap-2 mb-5'>");
                                        out.print("<div class='row-label w-6 flex items-center justify-center font-medium text-gray-600 text-sm mr-3'>" + lastRow + "</div>");
                                        for (Seat s : rowSeats) {
                                            String seatClass = "rounded-lg font-medium transition-all duration-150 flex items-center justify-center ";
                                            
                                            if ("booked".equalsIgnoreCase(s.getStatus())) {
                                                seatClass += "bg-gray-300 text-gray-500 cursor-not-allowed ";
                                            } else {
                                                if ("VIP".equalsIgnoreCase(s.getSeatType())) {
                                                    seatClass += "bg-yellow-400 text-white hover:bg-yellow-500 ";
                                                } else if ("COUPLE".equalsIgnoreCase(s.getSeatType())) {
                                                    seatClass += "bg-pink-400 text-white hover:bg-pink-500 ";
                                                } else {
                                                    seatClass += "bg-gray-400 text-white hover:bg-gray-500 ";
                                                }
                                            }

                                            if ("COUPLE".equalsIgnoreCase(s.getSeatType())) {
                                                seatClass += "w-14 h-10 text-xs";
                                            } else {
                                                seatClass += "w-10 h-10 text-sm";
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
                                out.print("<div class='seat-row flex justify-center gap-2 mb-5'>");
                                out.print("<div class='row-label w-6 flex items-center justify-center font-medium text-gray-600 text-sm mr-3'>" + lastRow + "</div>");
                                for (Seat s : rowSeats) {
                                    String seatClass = "rounded-lg font-medium transition-all duration-150 flex items-center justify-center ";
                                    
                                    if ("booked".equalsIgnoreCase(s.getStatus())) {
                                        seatClass += "bg-gray-300 text-gray-500 cursor-not-allowed ";
                                    } else {
                                        if ("VIP".equalsIgnoreCase(s.getSeatType())) {
                                            seatClass += "bg-yellow-400 text-white hover:bg-yellow-500 ";
                                        } else if ("COUPLE".equalsIgnoreCase(s.getSeatType())) {
                                            seatClass += "bg-pink-400 text-white hover:bg-pink-500 ";
                                        } else {
                                            seatClass += "bg-gray-400 text-white hover:bg-gray-500 ";
                                        }
                                    }

                                    if ("COUPLE".equalsIgnoreCase(s.getSeatType())) {
                                        seatClass += "w-14 h-10 text-xs";
                                    } else {
                                        seatClass += "w-10 h-10 text-sm";
                                    }

                                    out.print("<div class='" + seatClass + "' title='Seat: " + s.getSeatNumber() + " | Type: " + s.getSeatType() + "'>" + 
                                             s.getSeatNumber().substring(1) + "</div>");
                                }
                                out.print("</div>");
                            }
                        %>
                    </div>

                    <!-- Aisle Indicators -->
                    <div class="max-w-4xl mx-auto mt-8 flex justify-between items-center px-10">
                        <div class="text-center">
                            <div class="w-12 h-1 bg-gray-300 mx-auto mb-1"></div>
                            <span class="text-xs text-gray-500">AISLE</span>
                        </div>
                        <div class="text-center">
                            <div class="w-12 h-1 bg-gray-300 mx-auto mb-1"></div>
                            <span class="text-xs text-gray-500">AISLE</span>
                        </div>
                    </div>
                </div>

                <!-- Legend -->
                <div class="bg-gray-50 border-t border-gray-200 px-6 py-5">
                    <div class="max-w-4xl mx-auto">
                        <h4 class="text-base font-medium text-gray-900 mb-3">Seat Types</h4>
                        <div class="flex flex-wrap gap-4">
                            <div class="flex items-center space-x-2">
                                <div class="w-8 h-8 rounded-lg bg-gray-400"></div>
                                <span class="text-sm text-gray-700">Standard</span>
                            </div>
                            <div class="flex items-center space-x-2">
                                <div class="w-8 h-8 rounded-lg bg-yellow-400"></div>
                                <span class="text-sm text-gray-700">VIP</span>
                            </div>
                            <div class="flex items-center space-x-2">
                                <div class="w-10 h-8 rounded-lg bg-pink-400"></div>
                                <span class="text-sm text-gray-700">Couple</span>
                            </div>
                            <div class="flex items-center space-x-2">
                                <div class="w-8 h-8 rounded-lg bg-gray-300"></div>
                                <span class="text-sm text-gray-700">Booked</span>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Action Buttons -->
            <div class="mt-8 flex justify-center gap-3">
                <button onclick="window.print()" 
                        class="px-5 py-2.5 bg-white border border-gray-300 rounded-lg text-gray-700 font-medium hover:bg-gray-50 transition-colors duration-200 flex items-center gap-2 text-sm">
                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" 
                              d="M17 17h2a2 2 0 002-2v-4a2 2 0 00-2-2H5a2 2 0 00-2 2v4a2 2 0 002 2h2m2 4h6a2 2 0 002-2v-4a2 2 0 00-2-2H9a2 2 0 00-2 2v4a2 2 0 002 2zm8-12V5a2 2 0 00-2-2H9a2 2 0 00-2 2v4h10z"/>
                    </svg>
                    Print
                </button>

                <button onclick="window.location.href='editSeatLayout.jsp?theater_id=<%=theaterId%>'" 
                        class="px-5 py-2.5 bg-blue-600 rounded-lg text-white font-medium hover:bg-blue-700 transition-colors duration-200 flex items-center gap-2 text-sm">
                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" 
                              d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"/>
                    </svg>
                    Edit Seats
                </button>
            </div>

        </div>
    </div>
</div>
<jsp:include page="layout/JSPFooter.jsp"/>
