package com.demo.controller;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import com.demo.dao.TimeslotDao;

@WebServlet("/AddTimeslotServlet")
public class AddTimeslotServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        Integer theaterId = (Integer) session.getAttribute("theater_id"); 

        if(theaterId == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String startTime = request.getParameter("start_time");
        String endTime = request.getParameter("end_time");

        TimeslotDao dao = new TimeslotDao();

        if(!dao.isTimeslotAvailable(theaterId, startTime, endTime)) {
            response.sendRedirect("addTimeslots.jsp?msg=overlap");
            return;
        }

        int row = dao.addTimeslot(theaterId, startTime, endTime);
        if(row > 0) {
            response.sendRedirect("addTimeslots.jsp?msg=success");
        } else {
            response.sendRedirect("addTimeslots.jsp?msg=error");
        }

    }
}
