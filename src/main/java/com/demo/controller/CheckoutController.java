package com.demo.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import com.demo.dao.CartDAO;
import com.demo.dao.OrderDAO;
import com.demo.dao.TheaterDAO;
import com.demo.model.CartItem;
import com.demo.model.Order;
import com.demo.model.OrderItem;
import com.demo.model.Theater;
import com.demo.model.User;

@WebServlet("/checkout")
public class CheckoutController extends HttpServlet {

    private final CartDAO cartDAO = new CartDAO();
    private final OrderDAO orderDAO = new OrderDAO();
    private final TheaterDAO theaterDAO = new TheaterDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;
        if(user==null){
            response.sendRedirect("login.jsp?msg=loginRequired");
            return;
        }

        List<CartItem> cartItems = cartDAO.getCartItems(user.getUserId());
        List<Theater> theaters = theaterDAO.getAllTheaters();

        request.setAttribute("cartItems", cartItems!=null ? cartItems : new ArrayList<>());
        request.setAttribute("theaters", theaters!=null ? theaters : new ArrayList<>());
        request.getRequestDispatcher("checkout.jsp").forward(request,response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;
        if(user==null){
            response.sendRedirect("login.jsp?msg=loginRequired");
            return;
        }

        try {
            String name = request.getParameter("name");
            String email = request.getParameter("email");
            String phone = request.getParameter("phone");
            int theaterId = Integer.parseInt(request.getParameter("theaterId"));
            String paymentMethod = request.getParameter("paymentMethod");

            List<CartItem> cartItems = cartDAO.getCartItems(user.getUserId());
            if(cartItems==null || cartItems.isEmpty()){
                response.sendRedirect("checkout.jsp?error=emptycart");
                return;
            }

            // Calculate total
            double total = cartItems.stream().mapToDouble(c -> c.getFood().getPrice() * c.getQuantity()).sum();

            // Prepare Order Items
            List<OrderItem> orderItems = new ArrayList<>();
            for(CartItem c : cartItems){
                OrderItem o = new OrderItem();
                o.setFood(c.getFood());
                o.setQuantity(c.getQuantity());
                o.setPrice(c.getFood().getPrice());
                orderItems.add(o);
            }

            // Store customer info in session
            session.setAttribute("customerName", name);
            session.setAttribute("customerEmail", email);
            session.setAttribute("customerPhone", phone);
            session.setAttribute("cartItemsForPayment", cartItems);
            session.setAttribute("orderItemsForPayment", orderItems);
            session.setAttribute("totalAmountForPayment", total);
            session.setAttribute("selectedTheaterId", theaterId);
            session.setAttribute("selectedPaymentMethod", paymentMethod);

            // Redirect based on payment method
            if("cash".equalsIgnoreCase(paymentMethod)){
                // Cash: place order immediately
                Order order = new Order();
                order.setUserId(user.getUserId());
                order.setTheaterId(theaterId);
                order.setTotalAmount(total);
                order.setPaymentMethod(paymentMethod);
                order.setStatus("completed"); // Cash is instant
                order.setItems(orderItems);

                boolean success = orderDAO.placeOrder(order);
                if(!success){
                    response.sendRedirect("checkout.jsp?error=true");
                    return;
                }

                // Clear cart
                cartDAO.clearCart(user.getUserId());

                // Store in session for order-success page
                session.setAttribute("currentOrder", order);

                response.sendRedirect("order-success.jsp?orderId="+order.getId());
            } else {
                // KPZ/Wave: do NOT store order yet
                response.sendRedirect("payment-scan.jsp");
            }

        } catch(Exception e){
            e.printStackTrace();
            response.sendRedirect("checkout.jsp?error=true");
        }
    }

}
