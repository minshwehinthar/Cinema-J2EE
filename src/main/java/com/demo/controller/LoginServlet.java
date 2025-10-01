package com.demo.controller;

import com.demo.dao.UserDAO;
import com.demo.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.time.LocalDateTime;

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

            // Redirect based on role
            String role = user.getRole();
            if ("admin".equals(role) || "theateradmin".equals(role)) {
                response.sendRedirect("index.jsp"); // Admin / theater admin dashboard
            } else {
                response.sendRedirect("index-user.jsp"); // Regular user dashboard
            }

        } else {
            // Invalid login
            response.sendRedirect("login.jsp?msg=invalid");
        }
    }
}
