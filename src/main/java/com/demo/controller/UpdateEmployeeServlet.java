package com.demo.controller;

import com.demo.dao.UserDAO;
import com.demo.dao.TheaterDAO;
import com.demo.model.User;
import com.demo.model.Theater;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;

import java.io.File;
import java.io.IOException;
import java.sql.Date;
import java.util.ArrayList;
import java.util.Enumeration;
import java.util.List;

@WebServlet("/updateEmployeeWithTheaters")
@MultipartConfig(fileSizeThreshold = 1024*1024, maxFileSize = 5*1024*1024, maxRequestSize = 10*1024*1024)
public class UpdateEmployeeServlet extends HttpServlet {

    private UserDAO userDAO = new UserDAO();
    private TheaterDAO theaterDAO = new TheaterDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        int userId = Integer.parseInt(request.getParameter("id"));
        User existing = userDAO.getUserById(userId);
        if (existing == null) {
            response.sendRedirect("employeeList.jsp?msg=UserNotFound");
            return;
        }

        // Update user info
        User user = new User();
        user.setUserId(userId);
        user.setName(request.getParameter("name"));
        user.setEmail(request.getParameter("email"));
        user.setPhone(request.getParameter("phone"));

        // Password
        String password = request.getParameter("password");
        user.setPassword((password != null && !password.isEmpty()) ? password : existing.getPassword());

        // Birthdate
        String birthDateStr = request.getParameter("birth_date");
        user.setBirthdate((birthDateStr != null && !birthDateStr.isEmpty()) ? java.sql.Date.valueOf(birthDateStr) : existing.getBirthdate());

        // Gender
        String gender = request.getParameter("gender");
        user.setGender((gender != null && !gender.isEmpty()) ? gender : existing.getGender());

        // Preserve role and status
        user.setRole(existing.getRole());
        user.setStatus(existing.getStatus());

        // Profile image
        Part imagePart = request.getPart("image");
        if (imagePart != null && imagePart.getSize() > 0) {
            user.setImage(imagePart.getInputStream().readAllBytes());
            String[] content = imagePart.getContentType().split("/");
            user.setImgtype(content.length > 1 ? content[1] : "png");
        } else {
            user.setImage(existing.getImage());
            user.setImgtype(existing.getImgtype());
        }

        // Update user in DB
        userDAO.updateUser(user);

        // Update theaters
        Enumeration<String> params = request.getParameterNames();
        while (params.hasMoreElements()) {
            String param = params.nextElement();
            if (param.startsWith("theater_id_")) {
                int theaterId = Integer.parseInt(request.getParameter(param));
                Theater theater = theaterDAO.getTheaterById(theaterId);
                if (theater != null) {
                    theater.setName(request.getParameter("theater_name_" + theaterId));
                    theater.setLocation(request.getParameter("theater_location_" + theaterId));

                    Part theaterImagePart = request.getPart("theater_image_" + theaterId);
                    if (theaterImagePart != null && theaterImagePart.getSize() > 0) {
                        theater.setImage(java.util.Base64.getEncoder().encodeToString(theaterImagePart.getInputStream().readAllBytes()));
                        String[] content = theaterImagePart.getContentType().split("/");
                        theater.setImgtype(content.length > 1 ? content[1] : "png");
                    }

                    theaterDAO.updateTheater(theater);
                }
            }
        }

        response.sendRedirect("employees.jsp?msg=UpdatedSuccessfully");
    }
}
