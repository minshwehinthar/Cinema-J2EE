package com.demo.controller;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/setTheaterSession")
public class SetTheaterSessionServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String theaterIdParam = request.getParameter("theater_id");
        if (theaterIdParam != null) {
            int theaterId = Integer.parseInt(theaterIdParam);
            HttpSession session = request.getSession();
            session.setAttribute("theater_id", theaterId);
        }
        // redirect to viewSeat.jsp after setting session
        response.sendRedirect("viewSeat.jsp");
    }
}
