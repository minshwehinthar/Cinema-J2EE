package com.demo.controller;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import jakarta.servlet.ServletException;
import java.io.IOException;

import com.demo.dao.ReviewDAO;
import com.demo.model.User;

@WebServlet("/review")
public class ReviewServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        if(user == null) { response.sendRedirect("login.jsp"); return; }

        ReviewDAO dao = new ReviewDAO();
        String action = request.getParameter("action");

        try {
            int theaterId = Integer.parseInt(request.getParameter("theaterId"));

            if("delete".equals(action)) {
                int reviewId = Integer.parseInt(request.getParameter("reviewId"));
                dao.deleteReviewById(reviewId, user.getUserId());
            } else if("edit".equals(action)) {
                int reviewId = Integer.parseInt(request.getParameter("reviewId"));
                String reviewText = request.getParameter("reviewText");
                String isGood = request.getParameter("isGood");
                int rating = Integer.parseInt(request.getParameter("rating"));
                dao.updateReview(reviewId, user.getUserId(), reviewText.trim(), isGood, rating);
            } else { // add review
                String reviewText = request.getParameter("reviewText");
                String isGood = request.getParameter("isGood");
                int rating = Integer.parseInt(request.getParameter("rating"));
                dao.addReview(user.getUserId(), theaterId, reviewText.trim(), isGood, rating);
            }

            response.sendRedirect("reviews.jsp?theaterId=" + theaterId + "#reviews");
        } catch(Exception e){
            e.printStackTrace();
            response.sendRedirect("reviews.jsp?msg=error");
        }
    }
}
