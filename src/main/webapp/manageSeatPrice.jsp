<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.demo.model.User" %>
<%@ page import="com.demo.dao.SeatPriceDao" %>
<%@ page import="com.demo.model.SeatPrice" %>
<%@ page import="java.util.ArrayList" %>
<%
    // Get the logged-in user from session
    User user = (User) session.getAttribute("user");

    // Only allow admin or theater_admin
    if (user == null || 
       (!"admin".equals(user.getRole()) && !"theateradmin".equals(user.getRole()))) {
        response.sendRedirect("login.jsp?msg=unauthorized");
        return; // stop rendering the rest of the page
    }
    
    SeatPriceDao dao = new SeatPriceDao();
    ArrayList<SeatPrice> prices = dao.getAllSeatPrices();
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Seat Price Management</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        .red-gradient {
            background: linear-gradient(135deg, #dc2626 0%, #b91c1c 100%);
        }
        .red-light {
            background-color: #fef2f2;
        }
        .red-border {
            border-color: #dc2626;
        }
        .red-shadow {
            box-shadow: 0 4px 6px -1px rgba(220, 38, 38, 0.1), 0 2px 4px -1px rgba(220, 38, 38, 0.06);
        }
        .seat-card {
            transition: all 0.3s ease;
        }
        .seat-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05);
        }
        .price-input:focus {
            border-color: #dc2626;
            ring-color: #dc2626;
        }
    </style>
</head>
<body class="bg-gray-50">
    <!-- Header -->
    <jsp:include page="layout/JSPHeader.jsp"/>
    
    <!-- Main Layout -->
    <div class="flex min-h-screen">
        <!-- Sidebar -->
        <jsp:include page="layout/sidebar.jsp"/>

        <!-- Main content -->
        <div class="flex-1 sm:ml-64">
            <!-- Admin Header -->
            <jsp:include page="layout/AdminHeader.jsp"/>

            <div class="p-8">
                <!-- Page Header -->
                <div class="mb-8">
                    <h1 class="text-3xl font-bold text-gray-900">Seat Price Management</h1>
                    <p class="text-gray-600 mt-2">Manage and update ticket prices for different seat types</p>
                </div>
                
                <!-- Stats Cards -->
                <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
                    <div class="bg-white rounded-xl shadow p-6 border-l-4 border-red-500">
                        <div class="flex items-center">
                            <div class="rounded-full bg-red-100 p-3 mr-4">
                                <i class="fas fa-couch text-red-600 text-xl"></i>
                            </div>
                            <div>
                                <p class="text-sm font-medium text-gray-600">Seat Types</p>
                                <p class="text-2xl font-bold text-gray-900"><%= prices.size() %></p>
                            </div>
                        </div>
                    </div>
                    
                    <div class="bg-white rounded-xl shadow p-6 border-l-4 border-red-500">
                        <div class="flex items-center">
                            <div class="rounded-full bg-red-100 p-3 mr-4">
                                <i class="fas fa-dollar-sign text-red-600 text-xl"></i>
                            </div>
                            <div>
                                <p class="text-sm font-medium text-gray-600">Average Price</p>
                                <%
                                    double total = 0;
                                    for (SeatPrice sp : prices) {
                                        total += sp.getPrice().doubleValue();
                                    }
                                    double avgPrice = total / prices.size();
                                %>
                                <p class="text-2xl font-bold text-gray-900">$<%= String.format("%.2f", avgPrice) %></p>
                            </div>
                        </div>
                    </div>
                    
                    <div class="bg-white rounded-xl shadow p-6 border-l-4 border-red-500">
                        <div class="flex items-center">
                            <div class="rounded-full bg-red-100 p-3 mr-4">
                                <i class="fas fa-sync-alt text-red-600 text-xl"></i>
                            </div>
                            <div>
                                <p class="text-sm font-medium text-gray-600">Last Updated</p>
                                <p class="text-2xl font-bold text-gray-900">Today</p>
                            </div>
                        </div>
                    </div>
                </div>
                
                <!-- Seat Price Cards -->
                <div class="bg-white rounded-xl shadow-lg overflow-hidden red-shadow">
                    <div class="red-gradient px-6 py-4">
                        <h2 class="text-xl font-bold text-white">Seat Types & Pricing</h2>
                        <p class="text-red-100">Update prices for each seat category</p>
                    </div>
                    
                    <form action="UpdateSeatPriceServlet" method="post" class="p-6">
                        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                            <%
                                for (SeatPrice sp : prices) {
                            %>
                            <div class="seat-card bg-white border border-gray-200 rounded-lg p-5 hover:border-red-300">
                                <div class="flex justify-between items-start mb-4">
                                    <div>
                                        <h3 class="font-bold text-lg text-gray-800"><%= sp.getSeatType() %></h3>
                                        <p class="text-sm text-gray-500 mt-1">Seat Category</p>
                                    </div>
                                    <div class="rounded-full bg-red-100 p-2">
                                        <i class="fas fa-couch text-red-600"></i>
                                    </div>
                                </div>
                                
                                <div class="mt-4">
                                    <label class="block text-sm font-medium text-gray-700 mb-1">Price ($)</label>
                                    <div class="relative">
                                        <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                                            <span class="text-gray-500 sm:text-sm">$</span>
                                        </div>
                                        <input type="hidden" name="priceId" value="<%= sp.getPriceId() %>">
                                        <input type="number" step="0.01" name="price_<%= sp.getPriceId() %>" 
                                               value="<%= sp.getPrice() %>" 
                                               class="price-input pl-7 border border-gray-300 rounded-lg py-2 px-3 block w-full focus:ring-red-500 focus:border-red-500">
                                    </div>
                                </div>
                                
                                <div class="mt-4 flex justify-between items-center">
                                    <span class="text-xs text-gray-500">ID: <%= sp.getPriceId() %></span>
                                    <span class="text-xs font-medium px-2 py-1 rounded-full 
                                                <%= sp.getPrice().doubleValue() > avgPrice ? "bg-red-100 text-red-800" : "bg-green-100 text-green-800" %>">
                                        <%= sp.getPrice().doubleValue() > avgPrice ? "Premium" : "Standard" %>
                                    </span>
                                </div>
                            </div>
                            <% } %>
                        </div>
                        
                        <div class="mt-8 pt-6 border-t border-gray-200 flex justify-end">
                            <button type="reset" class="mr-4 px-6 py-2 border border-gray-300 rounded-lg text-gray-700 hover:bg-gray-50 transition">
                                Reset Changes
                            </button>
                            <button type="submit" class="px-6 py-2 bg-red-600 text-white rounded-lg hover:bg-red-700 transition flex items-center">
                                <i class="fas fa-save mr-2"></i> Save All Prices
                            </button>
                        </div>
                    </form>
                </div>
                
                <!-- Help Section -->
                <div class="mt-8 bg-red-50 border border-red-200 rounded-xl p-6">
                    <div class="flex">
                        <div class="flex-shrink-0">
                            <i class="fas fa-info-circle text-red-500 text-xl"></i>
                        </div>
                        <div class="ml-3">
                            <h3 class="text-sm font-medium text-red-800">Pricing Guidelines</h3>
                            <div class="mt-2 text-sm text-red-700">
                                <p>• Consider market rates and competitor pricing when updating seat prices</p>
                                <p>• Premium seats should be priced 20-50% higher than standard seats</p>
                                <p>• Changes will take effect immediately for new bookings</p>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <jsp:include page="layout/JSPFooter.jsp"/>
</body>
</html>