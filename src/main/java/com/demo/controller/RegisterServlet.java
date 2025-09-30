package com.demo.controller;

import com.demo.dao.UserDAO;
import com.demo.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.Date;

@WebServlet("/register")
public class RegisterServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");

        if (!password.equals(confirmPassword)) {
            response.sendRedirect("register.jsp?msg=fail");
            return;
        }

        User user = new User();
        user.setName(request.getParameter("name"));
        user.setEmail(request.getParameter("email"));
        user.setPassword(password);
        user.setPhone(request.getParameter("phone"));
        user.setRole("user");

        UserDAO dao = new UserDAO();
        boolean result = dao.register(user);

        if (result) response.sendRedirect("login.jsp?msg=success");
        else response.sendRedirect("register.jsp?msg=fail");
    }
}
