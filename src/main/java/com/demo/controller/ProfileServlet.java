package com.demo.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.Date;

import com.demo.dao.UserDAO;
import com.demo.model.User;

@WebServlet("/profile")
public class ProfileServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Get current user from session
        User user = (User) request.getSession().getAttribute("user");
        if (user == null) {
            response.sendRedirect("login.jsp?msg=loginRequired");
            return;
        }

        request.setAttribute("user", user);
        request.getRequestDispatcher("profile.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User user = (User) request.getSession().getAttribute("user");
        if (user == null) {
            response.sendRedirect("login.jsp?msg=loginRequired");
            return;
        }

        String field = request.getParameter("field"); // name, email, phone, birthdate, gender
        String value = request.getParameter("value");

        UserDAO dao = new UserDAO();
        boolean updated = false;

        try {
            switch (field) {
                case "name":
                    user.setName(value);
                    updated = dao.updateField(user.getUserId(), "name", value);
                    break;
                case "email":
                    user.setEmail(value);
                    updated = dao.updateField(user.getUserId(), "email", value);
                    break;
                case "phone":
                    user.setPhone(value);
                    updated = dao.updateField(user.getUserId(), "phone", value);
                    break;
                case "birthdate":
                    if (value != null && !value.isEmpty()) {
                        Date sqlDate = Date.valueOf(value); // convert string to SQL Date
                        user.setBirthdate(sqlDate);
                    }
                    updated = dao.updateField(user.getUserId(), "birthdate", value);
                    break;
                case "gender":
                    user.setGender(value);
                    updated = dao.updateField(user.getUserId(), "gender", value);
                    break;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        if (updated) {
            request.getSession().setAttribute("user", user); // ✅ update session
            response.sendRedirect("profile.jsp?msg=updated");
        }
 else {
            response.sendRedirect("profile.jsp?msg=error");
        }
    }
}
