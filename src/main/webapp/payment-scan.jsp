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

<div class="min-h-screen bg-gradient-to-br from-red-50 to-rose-50 py-8">
    <div class="container mx-auto px-4 max-w-6xl">
        <!-- Breadcrumb -->
        <nav class="text-sm mb-6" aria-label="Breadcrumb">
            <ol class="list-reset flex text-gray-600">
                <li><a href="home.jsp" class="hover:text-red-600">Home</a></li>
                <li><span class="mx-2">/</span></li>
                <li><a href="foods.jsp" class="hover:text-red-600">Foods</a></li>
                <li><span class="mx-2">/</span></li>
                <li><a href="cart.jsp" class="hover:text-red-600">Cart</a></li>
                <li><span class="mx-2">/</span></li>
                <li><a href="checkout.jsp" class="hover:text-red-600">Checkout</a></li>
                <li><span class="mx-2">/</span></li>
                <li class="flex items-center text-gray-900 font-semibold">Payment</li>
            </ol>
        </nav>

        <!-- Header -->
        <div class="text-center mb-12">
            <h1 class="text-4xl font-bold text-gray-900 mb-3">Payment Scan</h1>
            <p class="text-lg text-gray-700 mx-auto">Complete your payment to confirm order</p>
        </div>

        <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
            <!-- Left Column - Payment & QR -->
            <div class="lg:col-span-2 space-y-6">
                <!-- Payment Card -->
                <div class="bg-white rounded-2xl border-2 border-red-100 overflow-hidden">
                    <div class="bg-gradient-to-r from-red-600 to-rose-700 pt-6 px-6 pb-3">
                        <h2 class="text-2xl font-bold text-white">Payment Details</h2>
                    </div>
                    <div class="p-6">
                        <!-- Order Info -->
                        <div class="grid grid-cols-2 gap-4">
                            <div>
                                <div class="mb-3">
                                    <h3 class="text-lg font-semibold mb-2 text-red-700">Total Amount</h3>
                                    <p class="text-3xl font-bold text-red-900">$<%=totalAmount%> <span class="text-red-700 text-xs mt-2">Including all taxes and fees</span></p>
                                </div>
                                <div class="mb-6 p-6 bg-white rounded-xl border-2 border-red-100 shadow-sm">
                                    <h3 class="text-xl font-bold text-gray-900 mb-4 flex items-center">
                                        <svg class="w-5 h-5 text-red-600 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2"></path>
                                        </svg>
                                        Order Summary
                                    </h3>
                                    <div class="overflow-hidden rounded-lg border border-gray-200">
                                        <table class="min-w-full divide-y divide-gray-200">
                                            <tbody class="divide-y divide-gray-200 bg-white">
                                                <tr class="hover:bg-red-50 transition-colors">
                                                    <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-600 bg-gray-50 w-1/3">
                                                        <div class="flex items-center">
                                                            <svg class="w-4 h-4 mr-2 text-red-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"></path>
                                                            </svg>
                                                            Name
                                                        </div>
                                                    </td>
                                                    <td class="px-6 py-4 whitespace-nowrap text-sm font-semibold text-gray-900">
                                                        <%=customerName != null ? customerName : user.getName()%>
                                                    </td>
                                                </tr>
                                                <tr class="hover:bg-red-50 transition-colors">
                                                    <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-600 bg-gray-50">
                                                        <div class="flex items-center">
                                                            <svg class="w-4 h-4 mr-2 text-red-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"></path>
                                                            </svg>
                                                            Email
                                                        </div>
                                                    </td>
                                                    <td class="px-6 py-4 whitespace-nowrap text-sm font-semibold text-gray-900">
                                                        <%=customerEmail != null ? customerEmail : user.getEmail()%>
                                                    </td>
                                                </tr>
                                                <tr class="hover:bg-red-50 transition-colors">
                                                    <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-600 bg-gray-50">
                                                        <div class="flex items-center">
                                                            <svg class="w-4 h-4 mr-2 text-red-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 5a2 2 0 012-2h3.28a1 1 0 01.948.684l1.498 4.493a1 1 0 01-.502 1.21l-2.257 1.13a11.042 11.042 0 005.516 5.516l1.13-2.257a1 1 0 011.21-.502l4.493 1.498a1 1 0 01.684.949V19a2 2 0 01-2 2h-1C9.716 21 3 14.284 3 6V5z"></path>
                                                            </svg>
                                                            Phone
                                                        </div>
                                                    </td>
                                                    <td class="px-6 py-4 whitespace-nowrap text-sm font-semibold text-gray-900">
                                                        <%=customerPhone != null ? customerPhone : user.getPhone()%>
                                                    </td>
                                                </tr>
                                                <tr class="hover:bg-red-50 transition-colors">
                                                    <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-600 bg-gray-50">
                                                        <div class="flex items-center">
                                                            <svg class="w-4 h-4 mr-2 text-red-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 8v-4m0 4h4"></path>
                                                            </svg>
                                                            Theater
                                                        </div>
                                                    </td>
                                                    <td class="px-6 py-4 whitespace-nowrap text-sm font-semibold text-gray-900">
                                                        <%=customerTheater != null ? customerTheater.getName() + " - " + customerTheater.getLocation() : "Not selected"%>
                                                    </td>
                                                </tr>
                                                <tr class="hover:bg-red-50 transition-colors">
                                                    <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-600 bg-gray-50">
                                                        <div class="flex items-center">
                                                            <svg class="w-4 h-4 mr-2 text-red-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 9V7a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2m2 4h10a2 2 0 002-2v-6a2 2 0 00-2-2H9a2 2 0 00-2 2v6a2 2 0 002 2zm7-5a2 2 0 11-4 0 2 2 0 014 0z"></path>
                                                            </svg>
                                                            Payment Method
                                                        </div>
                                                    </td>
                                                    <td class="px-6 py-4 whitespace-nowrap text-sm font-semibold text-gray-900">
                                                        <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-red-100 text-red-800">
                                                            <%=paymentMethod != null ? paymentMethod.toUpperCase() : "Not selected"%>
                                                        </span>
                                                    </td>
                                                </tr>
                                            </tbody>
                                        </table>
                                    </div>
                                </div>
                            </div>
                            <div>
                                <!-- Payment Method Display -->
                                <div class="flex items-center justify-center gap-4 mb-6 p-4">
                                    <%
                                        if ("Wave".equalsIgnoreCase(paymentMethod)) {
                                    %>
                                        <div class="w-16 h-16 rounded-xl flex items-center justify-center border-2 border-white shadow-lg">
                                            <img src="assets/img/wavepay.jpeg" alt="Wave Pay" class="w-10 h-10 rounded-lg">
                                        </div>
                                        <div>
                                            <span class="text-gray-700 font-bold text-xl">Wave Pay</span>
                                            <p class="text-sm text-gray-600">Digital Payment</p>
                                        </div>
                                    <%
                                        } else if ("KPZ".equalsIgnoreCase(paymentMethod)) {
                                    %>
                                        <div class="w-16 h-16 rounded-xl flex items-center justify-center border-2 border-white shadow-lg">
                                            <img src="assets/img/kpay.png" alt="KBZ Pay" class="w-10 h-10 rounded-lg">
                                        </div>
                                        <div>
                                            <span class="text-gray-700 font-bold text-xl">KBZ Pay</span>
                                            <p class="text-sm text-gray-600">Digital Payment</p>
                                        </div>
                                    <%
                                        } else {
                                    %>
                                        <div class="w-16 h-16 bg-white rounded-xl flex items-center justify-center border-2 border-red-200 shadow-lg">
                                            <img src="assets/img/cash.png" alt="Cash" class="w-10 h-10 rounded-lg">
                                        </div>
                                        <div>
                                            <span class="text-gray-700 font-bold text-xl">Cash Payment</span>
                                            <p class="text-sm text-gray-600">Pay at Counter</p>
                                        </div>
                                    <%
                                        }
                                    %>
                                </div>
                                
                                <!-- QR Code Section -->
                                <div class="flex flex-col items-center">
                                    <!-- QR Code -->
                                    <div class="w-72 h-72 bg-white border-2 border-red-200 rounded-2xl flex items-center justify-center mb-6 shadow-lg">
                                        <%
                                            if ("Wave".equalsIgnoreCase(paymentMethod)) {
                                        %>
                                            <img src="assets/img/wave.png" alt="Wave QR" class="w-full h-full object-contain p-4">
                                        <%
                                            } else if ("KPZ".equalsIgnoreCase(paymentMethod)) {
                                        %>
                                            <img src="assets/img/kpz.png" alt="KPZ QR" class="w-full h-full object-contain p-4">
                                        <%
                                            } else {
                                        %>
                                            <div class="text-center text-gray-500 p-6">
                                                <div class="w-20 h-20 bg-red-100 rounded-full flex items-center justify-center mx-auto mb-4 border-2 border-red-200">
                                                    <svg class="w-10 h-10 text-red-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z"></path>
                                                    </svg>
                                                </div>
                                                <p class="text-lg font-semibold text-gray-700">Cash Payment</p>
                                                <p class="text-sm text-gray-600 mt-2">Pay at counter</p>
                                            </div>
                                        <%
                                            }
                                        %>
                                    </div>

                                    <!-- Instructions -->
                                    <p class="text-gray-600 mb-6 text-center text-sm max-w-md">
                                        <%
                                            if (!"cash".equalsIgnoreCase(paymentMethod)) {
                                        %>
                                            Scan the QR code with your mobile banking app to complete payment. Your order will be confirmed automatically upon successful payment.
                                        <%
                                            } else {
                                        %>
                                            Please proceed to the theater counter to complete your cash payment. Show your order details to the staff.
                                        <%
                                            }
                                        %>
                                    </p>

                                    <!-- Payment Completion Button -->
                                    <form method="post" class="w-full max-w-md">
                                        <button type="submit" class="w-full bg-red-700 hover:bg-red-800 text-white py-2 rounded-xl font-semibold text-lg transition-all transform border-2 border-red-600">
                                            <div class="flex items-center justify-center gap-3">
                                                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path>
                                                </svg>
                                                <%
                                                    if ("cash".equalsIgnoreCase(paymentMethod)) {
                                                %>
                                                    Confirm Cash Payment
                                                <%
                                                    } else {
                                                %>
                                                    Simulate Payment Completion
                                                <%
                                                    }
                                                %>
                                            </div>
                                        </button>
                                    </form>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Right Column - Order Summary & Instructions -->
            <div class="space-y-6">
                <!-- Order Summary -->
                <div class="bg-white rounded-2xl border-2 border-red-100 p-6">
                    <h3 class="text-lg font-bold text-gray-900 mb-4 flex items-center">
                        <svg class="w-5 h-5 text-red-600 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2"></path>
                        </svg>
                        Order Summary
                    </h3>
                    <div class="overflow-y-auto max-h-[400px]">
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
                                            <div>
                                                <span class="font-semibold block"><%=c.getFood().getName()%></span>
                                                <span class="text-gray-600 text-sm">x <%=c.getQuantity()%></span>
                                            </div>
                                        </div>
                                        <span class="font-semibold">$<%=c.getFood().getPrice() * c.getQuantity()%></span>
                                    </li>
                                <%
                                    }
                                %>
                            </ul>
                            <div class="mt-4 text-right pt-4 border-t border-gray-200">
                                <p class="text-lg font-bold text-red-600">Total: $<%=totalAmount%></p>
                            </div>
                        <%
                            }
                        %>
                    </div>
                </div>

                <!-- Payment Instructions -->
                <div class="bg-white rounded-2xl border-2 border-red-100 p-6">
                    <h3 class="text-lg font-bold text-gray-900 mb-4 flex items-center">
                        <svg class="w-5 h-5 text-red-600 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z"></path>
                        </svg>
                        Payment Instructions
                    </h3>
                    <div class="space-y-3 text-sm text-gray-700">
                        <%
                            if ("KPZ".equalsIgnoreCase(paymentMethod)) {
                        %>
                            <div class="flex items-start space-x-2 p-2 bg-red-50 rounded-lg border border-red-100">
                                <div class="w-5 h-5 bg-blue-100 rounded-full flex items-center justify-center flex-shrink-0 mt-0.5 border border-blue-200">
                                    <span class="text-blue-600 text-xs font-bold">1</span>
                                </div>
                                <p>Open KBZ Pay app on your phone</p>
                            </div>
                            <div class="flex items-start space-x-2 p-2 bg-red-50 rounded-lg border border-red-100">
                                <div class="w-5 h-5 bg-blue-100 rounded-full flex items-center justify-center flex-shrink-0 mt-0.5 border border-blue-200">
                                    <span class="text-blue-600 text-xs font-bold">2</span>
                                </div>
                                <p>Tap on 'Scan & Pay'</p>
                            </div>
                            <div class="flex items-start space-x-2 p-2 bg-red-50 rounded-lg border border-red-100">
                                <div class="w-5 h-5 bg-blue-100 rounded-full flex items-center justify-center flex-shrink-0 mt-0.5 border border-blue-200">
                                    <span class="text-blue-600 text-xs font-bold">3</span>
                                </div>
                                <p>Scan the QR code above</p>
                            </div>
                            <div class="flex items-start space-x-2 p-2 bg-red-50 rounded-lg border border-red-100">
                                <div class="w-5 h-5 bg-blue-100 rounded-full flex items-center justify-center flex-shrink-0 mt-0.5 border border-blue-200">
                                    <span class="text-blue-600 text-xs font-bold">4</span>
                                </div>
                                <p>Confirm the amount and complete payment</p>
                            </div>
                        <%
                            } else if ("Wave".equalsIgnoreCase(paymentMethod)) {
                        %>
                            <div class="flex items-start space-x-2 p-2 bg-red-50 rounded-lg border border-red-100">
                                <div class="w-5 h-5 bg-yellow-100 rounded-full flex items-center justify-center flex-shrink-0 mt-0.5 border border-yellow-200">
                                    <span class="text-yellow-600 text-xs font-bold">1</span>
                                </div>
                                <p>Open Wave Pay app on your phone</p>
                            </div>
                            <div class="flex items-start space-x-2 p-2 bg-red-50 rounded-lg border border-red-100">
                                <div class="w-5 h-5 bg-yellow-100 rounded-full flex items-center justify-center flex-shrink-0 mt-0.5 border border-yellow-200">
                                    <span class="text-yellow-600 text-xs font-bold">2</span>
                                </div>
                                <p>Tap on 'Scan to Pay'</p>
                            </div>
                            <div class="flex items-start space-x-2 p-2 bg-red-50 rounded-lg border border-red-100">
                                <div class="w-5 h-5 bg-yellow-100 rounded-full flex items-center justify-center flex-shrink-0 mt-0.5 border border-yellow-200">
                                    <span class="text-yellow-600 text-xs font-bold">3</span>
                                </div>
                                <p>Scan the QR code above</p>
                            </div>
                            <div class="flex items-start space-x-2 p-2 bg-red-50 rounded-lg border border-red-100">
                                <div class="w-5 h-5 bg-yellow-100 rounded-full flex items-center justify-center flex-shrink-0 mt-0.5 border border-yellow-200">
                                    <span class="text-yellow-600 text-xs font-bold">4</span>
                                </div>
                                <p>Enter your PIN to confirm payment</p>
                            </div>
                        <%
                            } else {
                        %>
                            <div class="flex items-start space-x-2 p-2 bg-red-50 rounded-lg border border-red-100">
                                <div class="w-5 h-5 bg-green-100 rounded-full flex items-center justify-center flex-shrink-0 mt-0.5 border border-green-200">
                                    <span class="text-green-600 text-xs font-bold">1</span>
                                </div>
                                <p>Proceed to the theater counter</p>
                            </div>
                            <div class="flex items-start space-x-2 p-2 bg-red-50 rounded-lg border border-red-100">
                                <div class="w-5 h-5 bg-green-100 rounded-full flex items-center justify-center flex-shrink-0 mt-0.5 border border-green-200">
                                    <span class="text-green-600 text-xs font-bold">2</span>
                                </div>
                                <p>Show your order details</p>
                            </div>
                            <div class="flex items-start space-x-2 p-2 bg-red-50 rounded-lg border border-red-100">
                                <div class="w-5 h-5 bg-green-100 rounded-full flex items-center justify-center flex-shrink-0 mt-0.5 border border-green-200">
                                    <span class="text-green-600 text-xs font-bold">3</span>
                                </div>
                                <p>Pay the total amount in cash</p>
                            </div>
                            <div class="flex items-start space-x-2 p-2 bg-red-50 rounded-lg border border-red-100">
                                <div class="w-5 h-5 bg-green-100 rounded-full flex items-center justify-center flex-shrink-0 mt-0.5 border border-green-200">
                                    <span class="text-green-600 text-xs font-bold">4</span>
                                </div>
                                <p>Collect your payment receipt</p>
                            </div>
                        <%
                            }
                        %>
                    </div>
                </div>

                <!-- Company Rules -->
                <div class="bg-white rounded-2xl border-2 border-red-100 p-6">
                    <h3 class="text-lg font-bold text-gray-900 mb-4 flex items-center">
                        <svg class="w-5 h-5 text-red-600 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"></path>
                        </svg>
                        Company Rules
                    </h3>
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
<jsp:include page="layout/JSPFooter.jsp"/>