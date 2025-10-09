<%@ page import="java.util.List" %>
<%@ page import="com.demo.model.*" %>
<%@ page import="com.demo.dao.*" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    OrderDAO orderDAO = new OrderDAO();
    TheaterDAO theaterDAO = new TheaterDAO();
    UserDAO userDAO = new UserDAO();

    // Get orderId from request
    String orderIdParam = request.getParameter("orderId");
    if(orderIdParam == null){
        response.sendRedirect("index.jsp");
        return;
    }

    int orderId = Integer.parseInt(orderIdParam);
    Order order = orderDAO.getOrderById(orderId);
    if(order == null){
        response.sendRedirect("index.jsp");
        return;
    }

    Theater theater = theaterDAO.getTheaterById(order.getTheaterId());
    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
    String orderDateTime = sdf.format(order.getCreatedAt());

    // Get customer info: prioritize logged-in User
    User user = (User) session.getAttribute("user");

    String customerName = null;
    String customerEmail = null;
    String customerPhone = null;

    if(user != null){
        customerName = user.getName();
        customerEmail = user.getEmail();
        customerPhone = user.getPhone();
    } else {
        // Fallback: checkout form session data
        customerName = (String) session.getAttribute("customerName");
        customerEmail = (String) session.getAttribute("customerEmail");
        customerPhone = (String) session.getAttribute("customerPhone");
    }

    // Default if still null
    if(customerName == null) customerName = "Not provided";
    if(customerEmail == null) customerEmail = "Not provided";
    if(customerPhone == null) customerPhone = "Not provided";
%>
<jsp:include page="layout/JSPHeader.jsp"/>
<jsp:include page="layout/header.jsp"/>

<div class="bg-gray-100 py-12 font-sans">
    <div class="max-w-5xl mx-auto px-4">

        <div class="text-center mb-12">
            <h1 class="text-4xl font-extrabold text-gray-900 mb-3">Order Placed Successfully!</h1>
            <p class="text-gray-500 text-lg">Thank you for your purchase, <%=customerName%>!</p>
        </div>

        <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">

            <!-- Left: Order & Customer Info -->
            <div class="lg:col-span-2 space-y-6">

                <div class="bg-white p-6 rounded-3xl shadow-md flex justify-between items-center">
                    <div>
                        <p class="text-gray-700 font-semibold">Order ID: <span class="text-gray-900"><%=order.getId()%></span></p>
                        <p class="text-gray-500 text-sm mt-1">Placed: <%=orderDateTime%></p>
                    </div>
                    <span class="px-4 py-1 rounded-full text-sm font-medium bg-green-100 text-green-800">
                        <%=order.getStatus()%>
                    </span>
                </div>

                <div class="bg-white p-6 rounded-3xl shadow-md flex flex-col sm:flex-row gap-6">
                    <div class="flex-1">
                        <h3 class="font-semibold text-gray-700 mb-3">Customer Info</h3>
                        <p><strong>Name:</strong> <%=customerName%></p>
                        <p><strong>Email:</strong> <%=customerEmail%></p>
                        <p><strong>Phone:</strong> <%=customerPhone%></p>
                    </div>
                    <div class="flex-1">
                        <h3 class="font-semibold text-gray-700 mb-3">Theater Info</h3>
                        <p><strong>Name:</strong> <%=theater.getName()%></p>
                        <p><strong>Location:</strong> <%=theater.getLocation()%></p>
                    </div>
                </div>

                <div class="bg-white p-6 rounded-3xl shadow-md">
                    <h3 class="font-semibold text-gray-700 mb-4 text-lg">Items Purchased</h3>
                    <ul class="divide-y divide-gray-200">
                        <% for (OrderItem item : order.getItems()) { %>
                            <li class="flex justify-between items-center py-4">
                                <div class="flex items-center gap-4">
                                    <img src="<%=item.getFood().getImage()%>" alt="<%=item.getFood().getName()%>" class="w-16 h-16 rounded-xl object-cover">
                                    <div>
                                        <p class="text-gray-800 font-medium"><%=item.getFood().getName()%></p>
                                        <p class="text-gray-500 text-sm">Quantity: <%=item.getQuantity()%></p>
                                    </div>
                                </div>
                                <p class="font-semibold text-gray-700">$<%=item.getPrice() * item.getQuantity()%></p>
                            </li>
                        <% } %>
                    </ul>
                </div>
            </div>

            <!-- Right: Payment Summary -->
            <div class="bg-white p-6 rounded-3xl shadow-md h-fit sticky top-20">
                <h3 class="text-2xl font-bold text-gray-800 mb-6">Payment Summary</h3>
                <div class="flex justify-between text-gray-700 mb-4">
                    <span>Items:</span>
                    <span><%=order.getItems().size()%></span>
                </div>
                <div class="flex justify-between text-gray-700 mb-4">
                    <span>Payment Method:</span>
                    <span class="capitalize"><%=order.getPaymentMethod()%></span>
                </div>
                <div class="flex justify-between text-gray-900 font-bold text-lg border-t border-gray-200 pt-4">
                    <span>Total:</span>
                    <span>$<%=order.getTotalAmount()%></span>
                </div>
                <a href="foods.jsp" 
                   class="block mt-6 w-full text-center bg-blue-600 hover:bg-blue-700 text-white px-6 py-3 rounded-2xl shadow-lg font-semibold transition duration-200">
                   Continue Shopping →
                </a>
            </div>

        </div>
    </div>
</div>

<%
    // Optional: clear checkout session info
    session.removeAttribute("customerName");
    session.removeAttribute("customerEmail");
    session.removeAttribute("customerPhone");
%>

<jsp:include page="layout/footer.jsp"/>
