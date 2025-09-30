<%@ page import="java.util.List" %>
<%@ page import="com.demo.dao.OrderDAO" %>
<%@ page import="com.demo.dao.UserDAO" %>
<%@ page import="com.demo.dao.TheaterDAO" %>
<%@ page import="com.demo.model.Order" %>
<%@ page import="com.demo.model.OrderItem" %>
<%@ page import="com.demo.model.User" %>
<%@ page import="com.demo.model.Theater" %>
<%@ page import="java.util.stream.Collectors" %>

<%
    OrderDAO orderDAO = new OrderDAO();
    UserDAO userDAO = new UserDAO();
    TheaterDAO theaterDAO = new TheaterDAO();

    // Mark order as Completed
    String completeId = request.getParameter("completeId");
    if(completeId != null && !completeId.isEmpty()){
        int orderId = Integer.parseInt(completeId);
        orderDAO.completeOrder(orderId); // updates status to completed
    }

    // Pick / Confirm (move completed order to history)
    String confirmId = request.getParameter("confirmId");
    if(confirmId != null && !confirmId.isEmpty()){
        int orderId = Integer.parseInt(confirmId);
        orderDAO.confirmOrder(orderId); // moves to order_history
    }

    // Pagination settings
    int pageSize = 5; // orders per page
    int pendingPage = request.getParameter("pendingPage") != null ? Integer.parseInt(request.getParameter("pendingPage")) : 1;
    int completedPage = request.getParameter("completedPage") != null ? Integer.parseInt(request.getParameter("completedPage")) : 1;

    // Get all orders
    List<Order> orders = orderDAO.getAllOrders();
    
    // Split pending and completed orders
    List<Order> pendingOrders = orders.stream().filter(o -> "pending".equals(o.getStatus())).collect(Collectors.toList());
    List<Order> completedOrders = orders.stream().filter(o -> "completed".equals(o.getStatus())).collect(Collectors.toList());

    // Calculate pagination
    int pendingTotalPages = (int)Math.ceil(pendingOrders.size() * 1.0 / pageSize);
    int completedTotalPages = (int)Math.ceil(completedOrders.size() * 1.0 / pageSize);

    int pendingStart = (pendingPage - 1) * pageSize;
    int pendingEnd = Math.min(pendingStart + pageSize, pendingOrders.size());
    List<Order> pendingPageOrders = pendingOrders.subList(pendingStart, pendingEnd);

    int completedStart = (completedPage - 1) * pageSize;
    int completedEnd = Math.min(completedStart + pageSize, completedOrders.size());
    List<Order> completedPageOrders = completedOrders.subList(completedStart, completedEnd);
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Admin Orders Panel</title>
<script src="https://cdn.tailwindcss.com"></script>
<script>
function confirmPick(form){
    if(confirm("Confirm picking this order?")){
        setTimeout(function(){
            form.submit(); 
        }, 5000);
        return false;
    }
    return false;
}

function showTab(tab){
    document.getElementById('pendingTab').classList.add('hidden');
    document.getElementById('completedTab').classList.add('hidden');
    document.getElementById(tab).classList.remove('hidden');
    document.getElementById('btnPending').classList.remove('bg-blue-600', 'text-white');
    document.getElementById('btnCompleted').classList.remove('bg-blue-600', 'text-white');
    if(tab === 'pendingTab'){
        document.getElementById('btnPending').classList.add('bg-blue-600', 'text-white');
    } else {
        document.getElementById('btnCompleted').classList.add('bg-blue-600', 'text-white');
    }
}
</script>
</head>
<body class="bg-gray-100">
<div class="container mx-auto py-10">

<h1 class="text-4xl font-bold mb-6 text-center">Admin Orders Panel</h1>

<!-- Tabs -->
<div class="flex justify-center mb-6 space-x-4">
    <button id="btnPending" onclick="showTab('pendingTab')" class="px-4 py-2 border rounded bg-blue-600 text-white">Pending Orders</button>
    <button id="btnCompleted" onclick="showTab('completedTab')" class="px-4 py-2 border rounded">Completed Orders</button>
</div>

<!-- ================= Pending Orders ================= -->
<div id="pendingTab">
<% if(pendingOrders.isEmpty()){ %>
    <p class="text-gray-600 text-center">No pending orders.</p>
<% } else { %>
<table class="w-full bg-white rounded-xl border border-gray-200 mb-4">
    <thead>
        <tr class="text-left border-b bg-gray-100">
            <th class="px-4 py-2">Order ID</th>
            <th class="px-4 py-2">Customer</th>
            <th class="px-4 py-2">Theater</th>
            <th class="px-4 py-2">Items</th>
            <th class="px-4 py-2">Total</th>
            <th class="px-4 py-2">Action</th>
        </tr>
    </thead>
    <tbody>
    <% for(Order o : pendingPageOrders){
        User user = userDAO.getUserById(o.getUserId());
        Theater theater = theaterDAO.getTheaterById(o.getTheaterId());
    %>
        <tr class="border-b hover:bg-gray-50">
            <td class="px-4 py-2"><%= o.getId() %></td>
            <td class="px-4 py-2">
                <p class="font-semibold"><%=user.getName()%></p>
                <p class="text-sm text-gray-600"><%=user.getEmail()%></p>
                <p class="text-sm text-gray-600"><%=user.getPhone()%></p>
            </td>
            <td class="px-4 py-2">
                <p class="font-semibold"><%=theater.getName()%></p>
                <p class="text-sm text-gray-600"><%=theater.getLocation()%></p>
            </td>
            <td class="px-4 py-2">
                <ul class="space-y-1">
                <% for(OrderItem item : o.getItems()){ %>
                    <li class="flex items-center">
                        <img src="<%=item.getFood().getImage()%>" alt="<%=item.getFood().getName()%>" class="w-10 h-10 rounded mr-2">
                        <span><%=item.getFood().getName()%> x <%=item.getQuantity()%></span>
                    </li>
                <% } %>
                </ul>
            </td>
            <td class="px-4 py-2 font-semibold text-green-600">$<%= o.getTotalAmount()%></td>
            <td class="px-4 py-2">
                <form method="get" style="display:inline-block">
                    <input type="hidden" name="completeId" value="<%= o.getId() %>">
                    <input type="hidden" name="pendingPage" value="<%= pendingPage %>">
                    <button type="submit" class="bg-blue-500 text-white px-3 py-1 rounded hover:bg-blue-600 text-sm">
                        Completed
                    </button>
                </form>
            </td>
        </tr>
    <% } %>
    </tbody>
</table>

<!-- Pagination -->
<div class="flex justify-center space-x-2 mb-6">
    <% for(int i=1; i<=pendingTotalPages; i++){ %>
        <form method="get" style="display:inline-block">
            <input type="hidden" name="pendingPage" value="<%= i %>">
            <button type="submit" class="px-3 py-1 border rounded <%= (i==pendingPage) ? "bg-blue-600 text-white" : "bg-white" %>"><%= i %></button>
        </form>
    <% } %>
</div>
<% } %>
</div>

<!-- ================= Completed Orders ================= -->
<div id="completedTab" class="hidden">
<% if(completedOrders.isEmpty()){ %>
    <p class="text-gray-600 text-center">No completed orders.</p>
<% } else { %>
<table class="w-full bg-white rounded-xl border border-gray-200 mb-4">
    <thead>
        <tr class="text-left border-b bg-gray-100">
            <th class="px-4 py-2">Order ID</th>
            <th class="px-4 py-2">Customer</th>
            <th class="px-4 py-2">Theater</th>
            <th class="px-4 py-2">Items</th>
            <th class="px-4 py-2">Total</th>
            <th class="px-4 py-2">Action</th>
        </tr>
    </thead>
    <tbody>
    <% for(Order o : completedPageOrders){
        User user = userDAO.getUserById(o.getUserId());
        Theater theater = theaterDAO.getTheaterById(o.getTheaterId());
    %>
        <tr class="border-b hover:bg-gray-50">
            <td class="px-4 py-2"><%= o.getId() %></td>
            <td class="px-4 py-2">
                <p class="font-semibold"><%=user.getName()%></p>
                <p class="text-sm text-gray-600"><%=user.getEmail()%></p>
                <p class="text-sm text-gray-600"><%=user.getPhone()%></p>
            </td>
            <td class="px-4 py-2">
                <p class="font-semibold"><%=theater.getName()%></p>
                <p class="text-sm text-gray-600"><%=theater.getLocation()%></p>
            </td>
            <td class="px-4 py-2">
                <ul class="space-y-1">
                <% for(OrderItem item : o.getItems()){ %>
                    <li class="flex items-center">
                        <img src="<%=item.getFood().getImage()%>" alt="<%=item.getFood().getName()%>" class="w-10 h-10 rounded mr-2">
                        <span><%=item.getFood().getName()%> x <%=item.getQuantity()%></span>
                    </li>
                <% } %>
                </ul>
            </td>
            <td class="px-4 py-2 font-semibold text-green-600">$<%= o.getTotalAmount() %></td>
            <td class="px-4 py-2">
                <form method="get" onsubmit="return confirmPick(this)" style="display:inline-block">
                    <input type="hidden" name="confirmId" value="<%= o.getId() %>">
                    <input type="hidden" name="completedPage" value="<%= completedPage %>">
                    <button type="submit" class="bg-green-500 text-white px-3 py-1 rounded hover:bg-green-600 text-sm">
                        Pick / Confirm
                    </button>
                </form>
            </td>
        </tr>
    <% } %>
    </tbody>
</table>

<!-- Pagination -->
<div class="flex justify-center space-x-2 mb-6">
    <% for(int i=1; i<=completedTotalPages; i++){ %>
        <form method="get" style="display:inline-block">
            <input type="hidden" name="completedPage" value="<%= i %>">
            <button type="submit" class="px-3 py-1 border rounded <%= (i==completedPage) ? "bg-blue-600 text-white" : "bg-white" %>"><%= i %></button>
        </form>
    <% } %>
</div>
<% } %>
</div>

<script>
    // Show pending by default
    showTab('pendingTab');
</script>

</div>
</body>
</html>
