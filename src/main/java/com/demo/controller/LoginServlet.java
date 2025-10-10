package com.demo.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

import com.demo.dao.UserDAO;
import com.demo.model.User;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String email = request.getParameter("email");
        String password = request.getParameter("password");

        UserDAO dao = new UserDAO();
        User user = dao.login(email, password);

        if (user != null) {
            // Update status to active
            dao.updateStatus(email, "active");

            // Save user in session
            HttpSession session = request.getSession();
            session.setAttribute("user", user);

            // Check if there's a pending booking redirect from CheckOutBookingServlet
            String redirectURL = (String) session.getAttribute("redirectAfterLogin");
            
            // Debug logging
            System.out.println("=== LOGIN SERVLET DEBUG ===");
            System.out.println("redirectAfterLogin from session: " + redirectURL);
            
            // Check if there are pending booking attributes
            boolean hasPendingBooking = session.getAttribute("pendingBookingMovieId") != null;
            System.out.println("Has pending booking: " + hasPendingBooking);
            
            // If coming from booking flow, redirect back to CheckOutBookingServlet
            if (redirectURL != null && redirectURL.equals("CheckOutBookingServlet")) {
                System.out.println("Redirecting back to CheckOutBookingServlet for booking processing");
                session.removeAttribute("redirectAfterLogin"); // clear it after use
                response.sendRedirect("CheckOutBookingServlet");
                return;
            }
            
            // If no specific redirect, check for pending booking data
            if (hasPendingBooking && redirectURL == null) {
                System.out.println("Found pending booking data, redirecting to CheckOutBookingServlet");
                response.sendRedirect("CheckOutBookingServlet");
                return;
            }
            
            session.removeAttribute("redirectAfterLogin"); // clear it after use

            // Determine role-based default if no redirect URL
            String role = user.getRole();
            if (redirectURL == null || redirectURL.isEmpty()) {
                if ("admin".equals(role)) {
                    redirectURL = "index.jsp";
                } else if ("theateradmin".equals(role)) {
                    int theaterId = dao.getTheaterIdByUserId(user.getUserId());
                    session.setAttribute("theater_id", theaterId);
                    redirectURL = "index.jsp";
                } else {
                    redirectURL = "home.jsp";
                }
            }

            System.out.println("Final redirect URL: " + redirectURL);
            // Redirect to saved or default page
            response.sendRedirect(redirectURL);

        } else {
            // Invalid login
            response.sendRedirect("login.jsp?msg=invalid");
        }
    }
}