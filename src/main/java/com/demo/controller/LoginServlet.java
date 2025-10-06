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

            // Get saved redirect URL (if any)
            String redirectURL = (String) session.getAttribute("redirectAfterLogin");
            session.removeAttribute("redirectAfterLogin"); // clear it after use

            // Determine role-based default if no redirect URL
            String role = user.getRole();
            if (redirectURL == null || redirectURL.isEmpty()) {
                if ("admin".equals(role)) {
                    redirectURL = "index.jsp";
                } else if ("theateradmin".equals(role)) {
                    int theaterId = dao.getTheaterIdByUserId(user.getUserId());
                    session.setAttribute("theater_id", theaterId);
                    redirectURL = "theateradminpickmovies.jsp";
                } else {
                    redirectURL = "index-user.jsp";
                }
            }

            // Redirect to saved or default page
            response.sendRedirect(redirectURL);

        } else {
            // Invalid login
            response.sendRedirect("login.jsp?msg=invalid");
        }
    }
}
