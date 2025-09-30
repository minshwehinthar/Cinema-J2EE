package com.demo.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

import com.demo.dao.FoodDAO;
import com.demo.model.FoodItem;
@WebServlet("/foods")
public class FoodsServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        String idParam = request.getParameter("id");

        if("details".equals(action) && idParam != null) {
            int id = Integer.parseInt(idParam);
            FoodDAO dao = new FoodDAO();
            FoodItem food = dao.getFoodById(id); // DB မှာ id နဲ့ fetch

            request.setAttribute("food", food);
            request.getRequestDispatcher("food-details.jsp").forward(request, response);
            return; // important: return after forward
        }

        // default: show all foods
        FoodDAO dao = new FoodDAO();
        List<FoodItem> foods = dao.getAllFoods();
        request.setAttribute("foods", foods);
        request.getRequestDispatcher("foods.jsp").forward(request, response);
    }
}

