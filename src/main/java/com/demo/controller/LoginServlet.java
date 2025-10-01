package com.demo.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.time.LocalDateTime;

import com.demo.dao.UserDAO;
import com.demo.model.User;

/**
 * Servlet implementation class LoginServlet
 */
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
            if ("admin".equals(role)) {
                response.sendRedirect("index.jsp"); // Admin 
            } else if("theateradmin".equals(role)) {
            		int theaterId = dao.getTheaterIdByUserId(user.getUserId());
                session.setAttribute("theater_id", theaterId);
            		response.sendRedirect("theateradminpickmovies.jsp");
            }else {
                response.sendRedirect("index-user.jsp"); // Regular user dashboard
            }

        } else {
            // Invalid login
            response.sendRedirect("login.jsp?msg=invalid");
        }
    }
}