package com.demo.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import com.demo.dao.OrderDAO;
import com.demo.model.CartItem;
import com.demo.model.Order;
import com.demo.model.OrderItem;
import com.demo.model.User;

@WebServlet("/PaymentServlet")
public class PaymentServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        if (user == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String payment = request.getParameter("payment");
        int theaterId = 0;
        try {
            theaterId = Integer.parseInt(request.getParameter("theaterId"));
        } catch (NumberFormatException e) {
            response.sendRedirect("cart.jsp?msg=invalidTheater");
            return;
        }

        // Get cart items from session
        List<CartItem> cartItems = (List<CartItem>) session.getAttribute("cartItems");
        if (cartItems == null || cartItems.isEmpty()) {
            response.sendRedirect("cart.jsp?msg=emptyCart");
            return;
        }

        // Prepare order items and calculate total
        double totalAmount = 0;
        List<OrderItem> orderItems = new ArrayList<>();
        for (CartItem c : cartItems) {
            double price = c.getFood().getPrice();
            int quantity = c.getQuantity();
            totalAmount += price * quantity;

            OrderItem oi = new OrderItem();
            oi.setFood(c.getFood());
            oi.setQuantity(quantity);
            oi.setPrice(price);
            orderItems.add(oi);
        }

        // Create Order object
        Order order = new Order();
        order.setUserId(user.getUserId()); // use your User model's userId
        order.setTheaterId(theaterId);
        order.setPaymentMethod(payment);
        order.setStatus("pending");
        order.setTotalAmount(totalAmount);
        order.setItems(orderItems);

        // Place order
        OrderDAO orderDAO = new OrderDAO();
        boolean placed = orderDAO.placeOrder(order); // your original method

        if (placed) {
            session.removeAttribute("cartItems"); // clear cart after order
            response.sendRedirect("order-success.jsp?orderId=" + order.getId());
        } else {
            response.getWriter().println("Payment failed, please try again.");
        }
    }
}
