package com.demo.controller;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.WebServlet;
import java.io.IOException;
import com.demo.dao.SeatPriceDao;
import java.util.Enumeration;

@WebServlet("/UpdateSeatPriceServlet")
public class UpdateSeatPriceServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        SeatPriceDao dao = new SeatPriceDao();

        Enumeration<String> paramNames = request.getParameterNames();
        while (paramNames.hasMoreElements()) {
            String param = paramNames.nextElement();
            if (param.startsWith("price_")) {
                int priceId = Integer.parseInt(param.replace("price_", ""));
                double price = Double.parseDouble(request.getParameter(param));
                dao.updatePrice(priceId, price);
            }
        }

        // Updated redirect to the renamed JSP
        response.sendRedirect("manageSeatPrice.jsp?msg=updated");
    }
}
