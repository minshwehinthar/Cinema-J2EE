package com.demo.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

import com.demo.dao.CartDAO;
import com.demo.model.CartItem;
import com.demo.model.User;

@WebServlet("/cart")
public class CartServlet extends HttpServlet {
    private CartDAO cartDAO = new CartDAO();

    private User getSessionUser(HttpServletRequest request) {
        HttpSession session = request.getSession();
        return (User) session.getAttribute("user");
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User user = getSessionUser(request);
        if (user == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        // Handle remove/update actions safely
        String action = request.getParameter("action");
        if (action != null) {
            try {
                int cartId = Integer.parseInt(request.getParameter("cartId"));
                switch (action) {
                    case "remove":
                        cartDAO.removeItem(cartId);
                        break;
                    case "update":
                        int quantity = Integer.parseInt(request.getParameter("quantity"));
                        if (quantity < 1) quantity = 1;
                        cartDAO.updateQuantity(cartId, quantity);
                        break;
                }
            } catch (NumberFormatException e) {
                e.printStackTrace();
            }
            response.sendRedirect("cart");
            return;
        }

        List<CartItem> cartItems = cartDAO.getCartItems(user.getUserId()); // fixed getter
        double totalAmount = cartItems.stream().mapToDouble(CartItem::getTotalPrice).sum();

        int cartCount = cartDAO.getCartCount(user.getUserId()); // fixed getter
        request.getSession().setAttribute("cartCount", cartCount);

        request.setAttribute("cartItems", cartItems);
        request.setAttribute("totalAmount", totalAmount);
        request.getRequestDispatcher("cart.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User user = getSessionUser(request);
        if (user == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        try {
            int foodId = Integer.parseInt(request.getParameter("food_id"));
            int quantity = Integer.parseInt(request.getParameter("quantity"));
            if (quantity < 1) quantity = 1;

            cartDAO.addToCart(user.getUserId(), foodId, quantity); // fixed getter

            int cartCount = cartDAO.getCartCount(user.getUserId()); // fixed getter
            request.getSession().setAttribute("cartCount", cartCount);

        } catch (NumberFormatException e) {
            e.printStackTrace();
        }

        // Redirect back to the current food details page
        response.sendRedirect("foods?action=details&id=" + request.getParameter("food_id"));
    }
}
