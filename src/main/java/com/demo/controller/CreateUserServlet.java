package com.demo.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.io.InputStream;
import java.sql.Date;
import java.time.LocalDate;
import java.time.LocalDateTime;

import com.demo.dao.UserDAO;
import com.demo.model.User;

@WebServlet("/CreateUserServlet")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 1,
    maxFileSize = 1024 * 1024 * 10,
    maxRequestSize = 1024 * 1024 * 15
)
public class CreateUserServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        try {
            User user = new User();
            user.setName(request.getParameter("name"));
            user.setEmail(request.getParameter("email"));
            user.setPhone(request.getParameter("phone"));
            user.setRole(request.getParameter("role"));
            user.setPassword(request.getParameter("password")); // optional: hash this

            String birthDateStr = request.getParameter("birth_date");
            if (birthDateStr != null && !birthDateStr.isEmpty()) {
                LocalDate bd = LocalDate.parse(birthDateStr);
                user.setBirthdate(Date.valueOf(bd));
            }

            user.setGender(request.getParameter("gender"));
            user.setStatus("active");
            user.setCreatedAt(LocalDateTime.now().toString());

            // Profile image
            Part filePart = request.getPart("image");
            if (filePart != null && filePart.getSize() > 0) {
                try (InputStream input = filePart.getInputStream()) {
                    byte[] imageBytes = input.readAllBytes();
                    user.setImage(imageBytes);
                    user.setImgtype(filePart.getContentType());
                }
            }

            UserDAO dao = new UserDAO();

            if (dao.existsByEmail(user.getEmail())) {
                response.sendRedirect("createUser.jsp?msg=Email already exists");
                return;
            }

            boolean success = dao.createUser(user);

            if (success) {
                response.sendRedirect("users.jsp?msg=User created successfully");
            } else {
                response.sendRedirect("createUser.jsp?msg=Error creating user");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("createUser.jsp?msg=Exception: " + e.getMessage());
        }
    }
}
