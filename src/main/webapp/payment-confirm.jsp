
<%@ page import="java.util.List" %>
<%@ page import="com.demo.model.User, com.demo.model.CartItem, com.demo.model.Order, com.demo.model.OrderItem" %>
<%@ page import="com.demo.dao.OrderDAO, com.demo.dao.CartDAO" %>
<%
    // Ensure user is logged in
    User user = (User) session.getAttribute("user");
    if(user == null){
        response.sendRedirect("login.jsp");
        return;
    }

    // Get cart/session data for payment
    List<CartItem> cartItems = (List<CartItem>) session.getAttribute("cartItemsForPayment");
    Double totalAmount = (Double) session.getAttribute("totalAmountForPayment");
    String customerName = (String) session.getAttribute("customerName");
    String customerEmail = (String) session.getAttribute("customerEmail");
    String customerPhone = (String) session.getAttribute("customerPhone");
    Integer theaterId = (Integer) session.getAttribute("selectedTheaterId");
    String paymentMethod = (String) session.getAttribute("selectedPaymentMethod");

    if(cartItems == null || cartItems.isEmpty() || totalAmount == null || paymentMethod == null){
        response.sendRedirect("checkout.jsp");
        return;
    }

    // Create Order
    Order order = new Order();
    order.setUserId(user.getUserId());
    order.setTheaterId(theaterId != null ? theaterId : 0);
    order.setTotalAmount(totalAmount);
    order.setPaymentMethod(paymentMethod);
    order.setStatus("pending"); // KPZ/Wave payment
    order.setAdminConfirmed(false);

    // Convert CartItems to OrderItems
    List<OrderItem> orderItems = new java.util.ArrayList<>();
    for(CartItem c : cartItems){
        OrderItem oi = new OrderItem();
        oi.setFood(c.getFood());
        oi.setQuantity(c.getQuantity());
        oi.setPrice(c.getFood().getPrice());
        orderItems.add(oi);
    }
    order.setItems(orderItems);

    // Save order to DB
    OrderDAO orderDAO = new OrderDAO();
    boolean placed = orderDAO.placeOrder(order);

    if(placed){
        // Clear session cart/payment data
        session.removeAttribute("cartItemsForPayment");
        session.removeAttribute("orderItemsForPayment");
        session.removeAttribute("totalAmountForPayment");
        session.removeAttribute("customerName");
        session.removeAttribute("customerEmail");
        session.removeAttribute("customerPhone");
        session.removeAttribute("selectedTheaterId");
        session.removeAttribute("selectedPaymentMethod");

        // Redirect to order-success page
        response.sendRedirect("order-success.jsp?orderId=" + order.getId());
    } else {
        out.println("<h2>Error placing order. Please try again.</h2>");
    }
%>
