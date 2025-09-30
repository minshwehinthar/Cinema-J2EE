<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, com.demo.dao.MyConnection, com.demo.model.User, java.util.Base64"%>

<%
    // -------------------------
    // Admin session check
    // -------------------------
    User admin = (User) session.getAttribute("user");
    if (admin == null || !"admin".equals(admin.getRole())) {
        response.sendRedirect("login.jsp?msg=unauthorized");
        return;
    }

    // -------------------------
    // Get employee ID
    // -------------------------
    String empIdParam = request.getParameter("id");
    if (empIdParam == null || empIdParam.isEmpty()) {
        response.sendRedirect("employeeList.jsp");
        return;
    }
    int empId = Integer.parseInt(empIdParam);

    // -------------------------
    // DB connection & user query
    // -------------------------
    Connection conn = MyConnection.getConnection();
    PreparedStatement psUser = conn.prepareStatement("SELECT * FROM users WHERE user_id=?");
    psUser.setInt(1, empId);
    ResultSet rsUser = psUser.executeQuery();

    if (!rsUser.next()) {
        out.println("<h2 class='text-red-500 text-center mt-10'>User not found</h2>");
        rsUser.close();
        psUser.close();
        conn.close();
        return;
    }

    String name = rsUser.getString("name");
    String email = rsUser.getString("email");
    String phone = rsUser.getString("phone");
    String role = rsUser.getString("role");
    String status = rsUser.getString("status");
    String gender = rsUser.getString("gender");
    String birthDate = rsUser.getString("birthdate");
    byte[] imageBytes = rsUser.getBytes("image"); // store bytes
    String imgType = rsUser.getString("imgtype"); // e.g., png/jpg
    String createdAt = rsUser.getString("created_at");
    String updatedAt = ""; 

    rsUser.close();
    psUser.close();

    // -------------------------
    // Query theaters managed by user
    // -------------------------
    PreparedStatement psTheaters = conn.prepareStatement(
        "SELECT * FROM theaters WHERE user_id=? ORDER BY created_at DESC"
    );
    psTheaters.setInt(1, empId);
    ResultSet rsTheaters = psTheaters.executeQuery();

    // -------------------------
    // Prepare Base64 image string
    // -------------------------
    String empImage;
    if (imageBytes != null && imageBytes.length > 0) {
        String base64 = Base64.getEncoder().encodeToString(imageBytes);
        empImage = "data:image/" + (imgType != null ? imgType : "png") + ";base64," + base64;
    } else {
        // default placeholder
        empImage = "https://via.placeholder.com/150?text=No+Image";
    }
%>

<jsp:include page="layout/JSPHeader.jsp" />
<div class="flex">
    <jsp:include page="layout/sidebar.jsp" />
    <div class="flex-1 sm:ml-64">
        <jsp:include page="layout/AdminHeader.jsp" />

        <!-- Breadcrumb -->
        <div class="max-w-8xl mx-auto px-6 py-6">
            <nav class="text-sm text-gray-500 mb-4" aria-label="Breadcrumb">
                <ol class="flex items-center space-x-2">
                    <li><a href="index.jsp" class="hover:underline">Home</a></li>
                    <li>/</li>
                    <li><a href="employees.jsp" class="hover:underline">Employee List</a></li>
                    <li>/</li>
                    <li class="text-gray-700">Employee Details</li>
                </ol>
            </nav>
        </div>

        <!-- Main Content -->
        <div class="max-w-7xl mx-auto py-4 px-6">
            <h1 class="text-3xl font-bold text-gray-900 mb-10">Employee Details</h1>

            <div class="md:flex md:space-x-12">
                <!-- Left: User Info -->
                <div class="md:w-1/2 flex flex-col space-y-4">
                    <img src="<%= empImage %>" 
                         alt="Profile Image" 
                         class="h-48 w-48 rounded-full object-cover mb-6">

                    <div class="grid grid-cols-2 gap-4 text-gray-700">
                        <div class="font-medium">Name:</div><div><%= name %></div>
                        <div class="font-medium">Email:</div><div><%= email %></div>
                        <div class="font-medium">Phone:</div><div><%= phone %></div>
                        <div class="font-medium">Role:</div><div><%= role %></div>
                        <div class="font-medium">Status:</div><div><%= status %></div>
                        <div class="font-medium">Gender:</div><div><%= gender != null ? gender : "-" %></div>
                        <div class="font-medium">Birth Date:</div><div><%= birthDate != null ? birthDate : "-" %></div>
                        <div class="font-medium">Created At:</div><div><%= createdAt %></div>
                        <div class="font-medium">Updated At:</div><div><%= updatedAt.isEmpty() ? "-" : updatedAt %></div>
                    </div>
                </div>

                <!-- Right: Theaters -->
                <div class="md:w-1/2 mt-10 md:mt-0 flex flex-col space-y-6">
                    <h2 class="text-2xl font-semibold text-gray-900 mb-4">Managed Theaters</h2>
                    <%
                        boolean hasTheaters = false;
                        while (rsTheaters.next()) {
                            hasTheaters = true;
                            String theaterName = rsTheaters.getString("name");
                            String theaterLocation = rsTheaters.getString("location");
                            String theaterCreatedAt = rsTheaters.getString("created_at");
                            byte[] theaterImgBytes = rsTheaters.getBytes("image");
                            String theaterImgType = rsTheaters.getString("imgtype");
                            String theaterImage;
                            if (theaterImgBytes != null && theaterImgBytes.length > 0) {
                                String base64 = Base64.getEncoder().encodeToString(theaterImgBytes);
                                theaterImage = "data:image/" + (theaterImgType != null ? theaterImgType : "png") + ";base64," + base64;
                            } else {
                                theaterImage = "https://via.placeholder.com/100?text=No+Image";
                            }
                    %>
                    <div class="flex items-start space-x-4">
                        <img src="<%= theaterImage %>" alt="Theater Image" class="h-24 w-24 rounded object-cover">
                        <div class="text-gray-700">
                            <div class="font-medium text-lg"><%= theaterName %></div>
                            <div class="text-sm">Location: <%= theaterLocation %></div>
                            <div class="text-sm">Created At: <%= theaterCreatedAt %></div>
                        </div>
                    </div>
                    <% } %>

                    <% if (!hasTheaters) { %>
                        <p class="text-gray-500">This user does not manage any theaters.</p>
                    <% } %>
                </div>
            </div>
        </div>
    </div>
</div>

<%
    rsTheaters.close();
    psTheaters.close();
    conn.close();
%>
<jsp:include page="layout/JSPFooter.jsp" />
