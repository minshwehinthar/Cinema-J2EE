<%@ page import="java.util.List"%>
<%@ page import="com.demo.model.*"%>
<%@ page import="com.demo.dao.*"%>
<%
    // Session check
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    // Get session data for KPZ/Wave payment
    List<CartItem> cartItems = (List<CartItem>) session.getAttribute("cartItemsForPayment");
    Double totalAmount = (Double) session.getAttribute("totalAmountForPayment");
    String customerName = (String) session.getAttribute("customerName");
    String customerEmail = (String) session.getAttribute("customerEmail");
    String customerPhone = (String) session.getAttribute("customerPhone");
    Integer theaterId = (Integer) session.getAttribute("selectedTheaterId");
    String paymentMethod = (String) session.getAttribute("selectedPaymentMethod");

    if (cartItems == null || cartItems.isEmpty() || totalAmount == null || paymentMethod == null) {
        response.sendRedirect("checkout.jsp");
        return;
    }

    Theater customerTheater = null;
    if (theaterId != null) {
        TheaterDAO theaterDAO = new TheaterDAO();
        customerTheater = theaterDAO.getTheaterById(theaterId);
    }

    // Handle "Simulate Payment" submission
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        Order order = new Order();
        order.setUserId(user.getUserId());
        order.setTheaterId(theaterId != null ? theaterId : 0);
        order.setTotalAmount(totalAmount);
        order.setPaymentMethod(paymentMethod);
        order.setStatus("pending"); // KPZ/Wave
        order.setAdminConfirmed(false);

        List<OrderItem> orderItems = new java.util.ArrayList<>();
        for (CartItem c : cartItems) {
            OrderItem oi = new OrderItem();
            oi.setFood(c.getFood());
            oi.setQuantity(c.getQuantity());
            oi.setPrice(c.getFood().getPrice());
            orderItems.add(oi);
        }
        order.setItems(orderItems);

        OrderDAO orderDAO = new OrderDAO();
        boolean placed = orderDAO.placeOrder(order);

        if (placed) {
            // Clear cart
            CartDAO cartDAO = new CartDAO();
            cartDAO.clearCart(user.getUserId());

            // Remove session payment/cart data
            session.removeAttribute("cartItemsForPayment");
            session.removeAttribute("orderItemsForPayment");
            session.removeAttribute("totalAmountForPayment");
            session.removeAttribute("customerName");
            session.removeAttribute("customerEmail");
            session.removeAttribute("customerPhone");
            session.removeAttribute("selectedTheaterId");
            session.removeAttribute("selectedPaymentMethod");

            // Redirect to order success
            response.sendRedirect("order-success.jsp?orderId=" + order.getId());
            return;
        } else {
            out.println("<h2>Error placing order. Please try again.</h2>");
        }
    }
%>
<jsp:include page="layout/JSPHeader.jsp"/>
<jsp:include page="layout/header.jsp"/>

<div class="bg-gray-50 min-h-screen font-sans flex flex-col items-center py-12">
    <div class="container mx-auto px-4">
        <h1 class="text-4xl font-bold text-center mb-12 text-gray-800">Payment Scan</h1>

        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">

            <!-- Left: Payment & QR -->
            <div class="bg-white rounded-xl p-6 shadow-lg flex flex-col gap-6">
                <!-- User & Order Info -->
                <div class="grid grid-cols-1 gap-2 text-gray-700">
                    <p><strong>Name:</strong> <%=customerName != null ? customerName : user.getName()%></p>
                    <p><strong>Email:</strong> <%=customerEmail != null ? customerEmail : user.getEmail()%></p>
                    <p><strong>Phone:</strong> <%=customerPhone != null ? customerPhone : user.getPhone()%></p>
                    <p><strong>Theater:</strong> <%=customerTheater != null ? customerTheater.getName() + " - " + customerTheater.getLocation() : "Not selected"%></p>
                    <p><strong>Payment Method:</strong> <%=paymentMethod != null ? paymentMethod.toUpperCase() : "Not selected"%></p>
                    <p><strong>Total Amount:</strong> $<%=totalAmount != null ? totalAmount : 0%></p>
                </div>

                <!-- Payment Method Logo -->
                <div class="flex items-center justify-center gap-4">
                    <%
                        if ("Wave".equalsIgnoreCase(paymentMethod)) {
                    %>
                        <img src="assets/img/wavepay.jpeg" alt="Wave Logo" class="w-12 h-12 rounded-full object-contain">
                        <span class="text-gray-700 font-medium">Wavepay</span>
                    <%
                        } else if ("KPZ".equalsIgnoreCase(paymentMethod)) {
                    %>
                        <img src="assets/img/kpay.png" alt="KPZ Logo" class="w-12 h-12 rounded-full object-contain">
                        <span class="text-gray-700 font-medium">Kpay</span>
                    <%
                        } else {
                    %>
                        <span class="text-gray-500 font-medium">Payment method not selected</span>
                    <%
                        }
                    %>
                </div>

                <!-- QR Code & Payment Logo -->
                <div class="flex flex-col items-center">
                    <div class="w-64 h-64 bg-gray-200 rounded-lg flex items-center justify-center mb-4">
                        <%
                            if ("Wave".equalsIgnoreCase(paymentMethod)) {
                        %>
                            <img src="assets/img/wave.png" alt="Wave QR" class="w-full h-full object-contain">
                        <%
                            } else if ("KPZ".equalsIgnoreCase(paymentMethod)) {
                        %>
                            <img src="assets/img/kpz.png" alt="KPZ QR" class="w-full h-full object-contain">
                        <%
                            } else {
                        %>
                            <p class="text-gray-500 text-center">Scan QR Code Here</p>
                        <%
                            }
                        %>
                    </div>
                    <p class="text-gray-500 mb-4 text-center">After scanning, payment will be confirmed automatically.</p>

                    <!-- Simulate Payment -->
                    <form method="post">
                        <button type="submit" class="bg-green-500 hover:bg-green-600 text-white px-6 py-3 rounded-lg font-semibold">
                            Simulate Payment
                        </button>
                    </form>
                </div>
            </div>

            <!-- Right: Order Summary & Rules -->
            <div class="flex flex-col gap-5">
                <!-- Order Summary -->
                <div class="bg-white rounded-xl p-6 shadow-lg overflow-y-auto max-h-[400px]">
                    <h2 class="text-2xl font-semibold mb-4 text-gray-700">Order Summary</h2>
                    <%
                        if (cartItems.isEmpty()) {
                    %>
                        <p class="text-gray-700">Your cart is empty.</p>
                    <%
                        } else {
                    %>
                        <ul class="space-y-4">
                            <%
                                for (CartItem c : cartItems) {
                            %>
                                <li class="flex justify-between items-center border-b border-gray-200 pb-2">
                                    <div class="flex items-center space-x-4">
                                        <img src="<%=c.getFood().getImage()%>" alt="<%=c.getFood().getName()%>" class="w-16 h-16 rounded-lg object-cover">
                                        <span class="font-semibold"><%=c.getFood().getName()%> x <%=c.getQuantity()%></span>
                                    </div>
                                    <span class="font-semibold">$<%=c.getFood().getPrice() * c.getQuantity()%></span>
                                </li>
                            <%
                                }
                            %>
                        </ul>
                        <div class="mt-4 text-right">
                            <p class="text-lg font-bold text-green-600">Total: $<%=totalAmount%></p>
                        </div>
                    <%
                        }
                    %>
                </div>

                <!-- Company Rules -->
                <div class="bg-white rounded-xl p-6 shadow-lg">
                    <h2 class="text-xl font-semibold mb-3 text-gray-700">Company Rules</h2>
                    <ul class="list-disc list-inside text-gray-700 space-y-2 text-sm">
                        <li>All orders must be confirmed before 24 hours of showtime.</li>
                        <li>No refunds are allowed after payment.</li>
                        <li>Please present a valid ID at the theater.</li>
                        <li>Food items are non-refundable and must be consumed on-site.</li>
                        <li>Company reserves the right to modify terms without prior notice.</li>
                    </ul>
                </div>
            </div>

        </div>
    </div>
</div>

<jsp:include page="layout/footer.jsp"/>
