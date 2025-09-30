<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.demo.dao.FoodDAO" %>
<%@ page import="com.demo.model.User" %>

<%
    // Check logged-in admin
    User user = (User) session.getAttribute("user");
    if (user == null || !"admin".equals(user.getRole())) {
        response.sendRedirect("login.jsp?msg=unauthorized");
        return;
    }

    String idParam = request.getParameter("id");
    if (idParam != null) {
        try {
            int id = Integer.parseInt(idParam);
            FoodDAO dao = new FoodDAO();
            boolean deleted = dao.deleteFood(id);

            if (deleted) {
                response.sendRedirect("food-lists.jsp?msg=deleted");
            } else {
                response.sendRedirect("food-lists.jsp?msg=error");
            }
        } catch (NumberFormatException e) {
            response.sendRedirect("food-lists.jsp?msg=invalid");
        }
    } else {
        response.sendRedirect("food-lists.jsp?msg=missing");
    }
%>
