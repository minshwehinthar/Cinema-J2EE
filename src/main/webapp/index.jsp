<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.demo.model.User" %>
<%
    // Get the logged-in user from session
    User user = (User) session.getAttribute("user");

    // Only allow admin or theater_admin
    if (user == null || 
       (!"admin".equals(user.getRole()) && !"theateradmin".equals(user.getRole()))) {
        response.sendRedirect("login.jsp?msg=unauthorized");
        return; // stop rendering the rest of the page
    }
%>

<jsp:include page="layout/JSPHeader.jsp"/>

<div class="flex min-h-screen">
    <!-- Sidebar -->
    <jsp:include page="layout/sidebar.jsp"/>

    <!-- Main content -->
    <div class="flex-1 sm:ml-64">
        <!-- Admin Header -->
        <jsp:include page="layout/AdminHeader.jsp"/>

        <div class="p-8">
            <!-- Dashboard modules -->
            <jsp:include page="components/DashboardModule.jsp"/>
        </div>
    </div>
</div>

<jsp:include page="layout/JSPFooter.jsp"/>
