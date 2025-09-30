<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*,com.demo.model.User,com.demo.dao.MyConnection" %>
<%
    User currentUser = (User) session.getAttribute("user");
    if (currentUser == null || !"admin".equals(currentUser.getRole())) {
        response.sendRedirect("login.jsp");
        return;
    }

    String idParam = request.getParameter("id");
    if (idParam != null) {
        int userId = Integer.parseInt(idParam);

        try {
            Connection conn = MyConnection.getConnection();
            PreparedStatement ps = conn.prepareStatement("DELETE FROM users WHERE id=?");
            ps.setInt(1, userId);
            int result = ps.executeUpdate();

            ps.close();
            conn.close();

            if(result > 0) {
                response.sendRedirect("employees.jsp?msg=User+deleted+successfully");
            } else {
                response.sendRedirect("employees.jsp?msg=User+not+found");
            }
        } catch(Exception e) {
            e.printStackTrace();
            response.sendRedirect("employees.jsp?msg=Error+occurred");
        }
    } else {
        response.sendRedirect("employees.jsp?msg=Invalid+user+ID");
    }
%>
