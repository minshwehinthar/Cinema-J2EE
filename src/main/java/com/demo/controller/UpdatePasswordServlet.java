package com.demo.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

import com.demo.dao.UserDAO;
import com.demo.model.User;

@WebServlet("/updatePassword")
public class UpdatePasswordServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User user = (User) request.getSession().getAttribute("user");
        if (user == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String oldPassword = request.getParameter("oldPassword");
        String newPassword = request.getParameter("newPassword");

        UserDAO dao = new UserDAO();
        boolean success = false;

        // Use correct getter for userId
        if (user.getPassword().equals(oldPassword)) {
            success = dao.updatePassword(user.getUserId(), newPassword); // DAO method already exists
            if (success) {
                user.setPassword(newPassword);
                request.getSession().setAttribute("user", user);
            }
        }

        // Determine redirect URL based on user role
        String redirectUrl;
        if ("admin".equals(user.getRole()) || "theateradmin".equals(user.getRole())) {
            redirectUrl = "admin-profile.jsp?msg=";
        } else {
            redirectUrl = "profile.jsp?msg=";
        }

        if (success) {
            response.sendRedirect(redirectUrl + "password_updated");
        } else {
            response.sendRedirect(redirectUrl + "invalid_password");
        }
    }
}