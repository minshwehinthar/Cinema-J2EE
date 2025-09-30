<%@ page import="java.util.List" %>
<%@ page import="com.demo.dao.OrderDAO" %>
<%@ page import="com.demo.dao.UserDAO" %>
<%@ page import="com.demo.dao.TheaterDAO" %>
<%@ page import="com.demo.model.Order" %>
<%@ page import="com.demo.model.OrderItem" %>
<%@ page import="com.demo.model.User" %>
<%@ page import="com.demo.model.Theater" %>

<%
    String orderIdParam = request.getParameter("orderId");
    if(orderIdParam == null){
        response.sendRedirect("pendingOrders.jsp");
        return;
    }

    int orderId = Integer.parseInt(orderIdParam);
    OrderDAO orderDAO = new OrderDAO();
    UserDAO userDAO = new UserDAO();
    TheaterDAO theaterDAO = new TheaterDAO();

    Order order = orderDAO.getOrderById(orderId);
    if(order == null){
        response.sendRedirect("pendingOrders.jsp");
        return;
    }

    User user = userDAO.getUserById(order.getUserId());
    Theater theater = theaterDAO.getTheaterById(order.getTheaterId());

    String backUrl = request.getParameter("from");
    if (backUrl == null || backUrl.isEmpty()) {
        backUrl = "pendingOrders.jsp";
    }
%>

<jsp:include page="layout/JSPHeader.jsp" />
<div class="flex">
    <jsp:include page="layout/sidebar.jsp" />
    <div class="flex-1 sm:ml-64 bg-gray-50 min-h-screen">
        <jsp:include page="/layout/AdminHeader.jsp" />
<!-- Breadcrumb -->
        <div class="max-w-8xl mx-auto px-8 py-8">
            <nav class="text-sm text-gray-500 mb-4" aria-label="Breadcrumb">
                <ol class="flex items-center space-x-2">
                    <li><a href="index.jsp" class="hover:underline">Home</a></li>
                    <li>/</li>
                    <li><a href="users.jsp" class="hover:underline">Users List</a></li>
                    <li>/</li>
                    <li class="text-gray-700">Users Details</li>
                </ol>
            </nav>
        </div>
        <div class="px-8 max-w-8xl mx-auto grid grid-cols-1 lg:grid-cols-3 gap-8">
        
            
            <!-- Left Column: Customer & Theater Info -->
            <div class="flex flex-col gap-6">
                <div class="bg-white rounded-xl shadow-md p-6">
                    <h2 class="text-xl font-semibold mb-3 text-gray-700">Customer Info</h2>
                    <p class="text-gray-600"><strong>Name:</strong> <%= user.getName() %></p>
                    <p class="text-gray-600"><strong>Email:</strong> <%= user.getEmail() %></p>
                    <p class="text-gray-600"><strong>Phone:</strong> <%= user.getPhone() %></p>
                </div>
                <div class="bg-white rounded-xl shadow-md p-6">
                    <h2 class="text-xl font-semibold mb-3 text-gray-700">Theater Info</h2>
                    <p class="text-gray-600"><strong>Name:</strong> <%= theater.getName() %></p>
                    <p class="text-gray-600"><strong>Location:</strong> <%= theater.getLocation() %></p>
                </div>
            </div>

            <!-- Right Column: Order Items -->
            <div class="lg:col-span-2 bg-white rounded-xl shadow-md p-6">
            
                <h2 class="text-xl font-semibold mb-4 text-gray-700">Order Items</h2>
                <ul class="divide-y divide-gray-200">
                    <% for(OrderItem item : order.getItems()){ %>
                        <li class="flex items-center py-3">
                            <img src="<%= item.getFood().getImage() %>" alt="<%= item.getFood().getName() %>" class="w-14 h-14 rounded-lg mr-4 object-cover">
                            <div class="flex-1">
                                <p class="font-medium text-gray-800"><%= item.getFood().getName() %></p>
                                <p class="text-gray-500 text-sm">Quantity: <%= item.getQuantity() %></p>
                            </div>
                            <span class="font-semibold text-green-600">$<%= item.getFood().getPrice() %></span>
                        </li>
                    <% } %>
                </ul>

                <div class="mt-6 space-y-2">
                    <div class="flex justify-between items-center">
                        <span class="font-semibold text-gray-700">Status:</span>
                        <span class="px-3 py-1 rounded-full text-sm font-semibold <%= "Completed".equals(order.getStatus()) ? "bg-green-100 text-green-700" : "bg-blue-100 text-blue-700" %>"><%= order.getStatus() %></span>
                    </div>
                    <div class="flex justify-between items-center">
                        <span class="font-semibold text-gray-700">Payment:</span>
                        <span class="text-gray-900 font-medium"><%= order.getPaymentMethod() %></span>
                    </div>
                    <div class="flex justify-between items-center">
                        <span class="font-semibold text-gray-700">Total:</span>
                        <span class="text-green-600 font-bold text-lg">$<%= order.getTotalAmount() %></span>
                    </div>
                </div>
            </div>

        </div>
    </div>
</div>
<jsp:include page="layout/JSPFooter.jsp" />
