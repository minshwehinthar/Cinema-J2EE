package com.demo.controller;

import java.io.File;
import java.io.IOException;
import com.demo.dao.FoodDAO;
import com.demo.model.FoodItem;
import com.demo.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;

@WebServlet("/updateFood")
@MultipartConfig(fileSizeThreshold = 1024 * 1024 * 2,
                 maxFileSize = 1024 * 1024 * 10,
                 maxRequestSize = 1024 * 1024 * 50)
public class UpdateFoodServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        if (user == null || !"admin".equals(user.getRole())) {
            response.sendRedirect("login.jsp?msg=unauthorized");
            return;
        }

        request.setCharacterEncoding("UTF-8");

        try {
            int id = Integer.parseInt(request.getParameter("id"));
            String name = request.getParameter("name");
            String description = request.getParameter("description");
            String foodType = request.getParameter("food_type");
            double price = Double.parseDouble(request.getParameter("price"));
            double rating = Double.parseDouble(request.getParameter("rating"));

            // Handle file upload
            Part filePart = request.getPart("image");
            String fileName = null;
            if (filePart != null && filePart.getSize() > 0) {
                fileName = System.currentTimeMillis() + "_" + filePart.getSubmittedFileName();
                String uploadPath = getServletContext().getRealPath("/") + "uploads/";
                File uploadDir = new File(uploadPath);
                if (!uploadDir.exists()) uploadDir.mkdirs();
                filePart.write(uploadPath + fileName);
                fileName = "uploads/" + fileName;
            }

            // Get current food item
            FoodDAO dao = new FoodDAO();
            FoodItem currentFood = dao.getFoodById(id);
            if (currentFood == null) {
                response.sendRedirect("food-lists.jsp?msg=notfound");
                return;
            }

            if (fileName == null || fileName.isEmpty()) {
                fileName = currentFood.getImage();
            }

            // Update food object
            FoodItem food = new FoodItem();
            food.setId(id);
            food.setName(name);
            food.setDescription(description);
            food.setFoodType(foodType);
            food.setPrice(price);
            food.setRating(rating);
            food.setImage(fileName);

            boolean updated = dao.updateFood(food);

            if (updated) {
                response.sendRedirect("food-lists.jsp?msg=updated");
            } else {
                response.sendRedirect("editFood.jsp?id=" + id + "&msg=error");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("editFood.jsp?msg=error");
        }
    }
}
