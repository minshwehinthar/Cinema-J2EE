<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="com.demo.dao.OrderDAO" %>
<%@ page import="com.demo.dao.UserDAO" %>
<%@ page import="com.demo.dao.TheaterDAO" %>
<%@ page import="com.demo.model.Order" %>
<%@ page import="com.demo.model.OrderItem" %>
<%@ page import="com.demo.model.User" %>
<%@ page import="com.demo.model.Theater" %>

<%
    User loggedInUser = (User) session.getAttribute("user");
    if (loggedInUser == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    String role = loggedInUser.getRole();
    int loggedInUserId = loggedInUser.getUserId();

    int orderId = 0;
    try {
        orderId = Integer.parseInt(request.getParameter("orderId"));
    } catch(Exception e) {
        out.println("<p>Invalid order ID.</p>");
        return;
    }

    OrderDAO orderDAO = new OrderDAO();
    UserDAO userDAO = new UserDAO();
    TheaterDAO theaterDAO = new TheaterDAO();

    Order order = orderDAO.getOrderById(orderId);
    if(order == null) {
        out.println("<p>Order not found.</p>");
        return;
    }

    if(!"admin".equals(role) && !"theateradmin".equals(role) && order.getUserId() != loggedInUserId) {
        out.println("<p>You do not have permission to view this order.</p>");
        return;
    }
    if("theateradmin".equals(role)) {
        List<Theater> myTheaters = theaterDAO.getTheatersByUserId(loggedInUserId);
        boolean hasAccess = myTheaters.stream().anyMatch(t -> t.getTheaterId() == order.getTheaterId());
        if(!hasAccess) {
            out.println("<p>You do not have permission to view this order.</p>");
            return;
        }
    }

    User orderUser = userDAO.getUserById(order.getUserId());
    Theater orderTheater = theaterDAO.getTheaterById(order.getTheaterId());
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Order Details - #<%= order.getId() %></title>
<script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-gray-50 font-sans min-h-screen flex flex-col">

<jsp:include page="layout/header.jsp"></jsp:include>

<div class="flex-grow max-w-6xl mx-auto py-12 px-4">

    <h1 class="text-3xl font-bold mb-8 text-gray-800 text-center">Order Details (#<%= order.getId() %>)</h1>

    <div class="grid grid-cols-1 lg:grid-cols-3 gap-8 items-start">
        <!-- Left Column -->
        <div class="space-y-6">
            <!-- Customer Info -->
            <div class="bg-white rounded-lg shadow p-6 border">
                <h2 class="text-lg font-semibold mb-3 text-gray-700">Customer Info</h2>
                <p class="text-gray-600"><strong>Name:</strong> <%= orderUser.getName() %></p>
                <p class="text-gray-600"><strong>Email:</strong> <%= orderUser.getEmail() %></p>
                <p class="text-gray-600"><strong>Phone:</strong> <%= orderUser.getPhone() %></p>
            </div>

            <!-- Theater Info -->
            <div class="bg-white rounded-lg shadow p-6 border">
                <h2 class="text-lg font-semibold mb-3 text-gray-700">Theater Info</h2>
                <p class="text-gray-600"><strong>Name:</strong> <%= orderTheater.getName() %></p>
                <p class="text-gray-600"><strong>Location:</strong> <%= orderTheater.getLocation() %></p>
            </div>

            <!-- Order Info -->
            <div class="bg-white rounded-lg shadow p-6 border">
                <h2 class="text-lg font-semibold mb-3 text-gray-700">Order Info</h2>
                <p><strong>Status:</strong> 
                    <span class="<%= "pending".equalsIgnoreCase(order.getStatus()) ? "text-yellow-600 font-semibold" :
                                  "completed".equalsIgnoreCase(order.getStatus()) ? "text-green-600 font-semibold" :
                                  "picked".equalsIgnoreCase(order.getStatus()) ? "text-blue-600 font-semibold" : "text-gray-700" %>">
                        <%= order.getStatus().toUpperCase() %>
                    </span>
                </p>
                <p><strong>Payment:</strong> <%= order.getPaymentMethod() %></p>
                <p><strong>Total:</strong> <span class="text-green-600 font-medium"><%= order.getTotalAmount() %> MMK</span></p>
            </div>
        </div>

        <!-- Right Column: Table -->
        <div class="lg:col-span-2 bg-white rounded-lg shadow border overflow-x-auto">
            <table class="w-full text-left table-auto">
                <thead class="bg-gray-100 text-gray-700 uppercase text-sm sticky top-0 z-10">
                    <tr>
                        <th class="py-3 px-4">Food Item</th>
                        <th class="py-3 px-4">Image</th>
                        <th class="py-3 px-4">Quantity</th>
                        <th class="py-3 px-4 text-right">Price (MMK)</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-gray-200">
                <% for(OrderItem item: order.getItems()) { %>
                    <tr class="hover:bg-gray-50 transition">
                        <td class="py-3 px-4 font-medium text-gray-800"><%= item.getFood().getName() %></td>
                        <td class="py-3 px-4">
                            <img src="<%= item.getFood().getImage() %>" class="h-12 w-12 object-cover rounded"/>
                        </td>
                        <td class="py-3 px-4"><%= item.getQuantity() %></td>
                        <td class="py-3 px-4 text-right text-green-600 font-medium"><%= item.getPrice() %></td>
                    </tr>
                <% } %>
                </tbody>
            </table>
        </div>
    </div>
</div>

<jsp:include page="layout/footer.jsp"></jsp:include>

</body>
</html>
