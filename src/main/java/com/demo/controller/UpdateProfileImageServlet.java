package com.demo.controller;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.StandardCopyOption;

import com.demo.dao.UserDAO;
import com.demo.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;

@WebServlet("/updateProfileImage")
@MultipartConfig
public class UpdateProfileImageServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        User user = (User) request.getSession().getAttribute("user");
        if (user == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        Part filePart = request.getPart("profileImage");
        if (filePart != null && filePart.getSize() > 0) {

            // Read bytes
            byte[] imageBytes = filePart.getInputStream().readAllBytes();

            // Update DB
            UserDAO dao = new UserDAO();
            user.setImage(imageBytes); // update model
            dao.updateUser(user); // full update to save byte[] image

            // Update session
            request.getSession().setAttribute("user", user);
        }

        response.sendRedirect("profile.jsp");
    }
}
