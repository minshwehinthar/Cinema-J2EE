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
        boolean success = false;
        
        if (filePart != null && filePart.getSize() > 0) {
            try {
                // Read bytes
                byte[] imageBytes = filePart.getInputStream().readAllBytes();
                
                // Get image type
                String imageType = filePart.getContentType();
                
                // Update DB
                UserDAO dao = new UserDAO();
                user.setImage(imageBytes); // update model
                user.setImgtype(imageType); // set image type
                success = dao.updateUser(user); // full update to save byte[] image

                // Update session if successful
                if (success) {
                    request.getSession().setAttribute("user", user);
                }
            } catch (Exception e) {
                e.printStackTrace();
                success = false;
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
            response.sendRedirect(redirectUrl + "image_updated");
        } else {
            response.sendRedirect(redirectUrl + "error");
        }
    }
}