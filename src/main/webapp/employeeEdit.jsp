<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, com.demo.dao.MyConnection, com.demo.model.User, java.util.Base64"%>

<%
    User admin = (User) session.getAttribute("user");
    if (admin == null || !"admin".equals(admin.getRole())) {
        response.sendRedirect("login.jsp?msg=unauthorized");
        return;
    }

    String empIdParam = request.getParameter("id");
    if (empIdParam == null || empIdParam.isEmpty()) {
        response.sendRedirect("employeeList.jsp");
        return;
    }
    int empId = Integer.parseInt(empIdParam);

    Connection conn = MyConnection.getConnection();
    PreparedStatement psUser = conn.prepareStatement("SELECT * FROM users WHERE user_id=?");
    psUser.setInt(1, empId);
    ResultSet rsUser = psUser.executeQuery();

    if (!rsUser.next()) {
        out.println("<h2>User not found</h2>");
        rsUser.close();
        psUser.close();
        conn.close();
        return;
    }

    String name = rsUser.getString("name");
    String email = rsUser.getString("email");
    String phone = rsUser.getString("phone");
    String birthDate = rsUser.getString("birthdate");
    String gender = rsUser.getString("gender");
    byte[] imageBytes = rsUser.getBytes("image");
    String imgType = rsUser.getString("imgtype");

    String empImage = (imageBytes != null && imageBytes.length > 0) ?
        "data:image/" + (imgType != null ? imgType : "png") + ";base64," + Base64.getEncoder().encodeToString(imageBytes) :
        "https://via.placeholder.com/150?text=No+Image";

    rsUser.close();
    psUser.close();

    PreparedStatement psTheaters = conn.prepareStatement("SELECT * FROM theaters WHERE user_id=? ORDER BY created_at DESC");
    psTheaters.setInt(1, empId);
    ResultSet rsTheaters = psTheaters.executeQuery();
%>

<jsp:include page="layout/JSPHeader.jsp" />
<div class="flex bg-gray-50 min-h-screen">
    <jsp:include page="layout/sidebar.jsp" />
    <div class="flex-1 sm:ml-64">
        <jsp:include page="layout/AdminHeader.jsp" />

        <div class="max-w-4xl mx-auto py-6 px-4">
            <h1 class="text-3xl font-semibold text-gray-800 mb-6">Edit Employee</h1>

            <form action="updateEmployeeWithTheaters" method="post" enctype="multipart/form-data" class="space-y-6">
                <input type="hidden" name="id" value="<%= empId %>">

                <div class="grid md:grid-cols-2 gap-6">
                    <div class="space-y-1">
                        <label class="text-gray-600">Name</label>
                        <input type="text" name="name" value="<%= name %>" class="w-full p-2 rounded focus:outline-none focus:ring-1 focus:ring-blue-400">
                    </div>
                    <div class="space-y-1">
                        <label class="text-gray-600">Email</label>
                        <input type="email" name="email" value="<%= email %>" class="w-full p-2 rounded focus:outline-none focus:ring-1 focus:ring-blue-400">
                    </div>
                    <div class="space-y-1">
                        <label class="text-gray-600">Phone</label>
                        <input type="text" name="phone" value="<%= phone %>" class="w-full p-2 rounded focus:outline-none focus:ring-1 focus:ring-blue-400">
                    </div>
                    <div class="space-y-1">
                        <label class="text-gray-600">Birth Date</label>
                        <input type="date" name="birth_date" value="<%= birthDate %>" class="w-full p-2 rounded focus:outline-none focus:ring-1 focus:ring-blue-400">
                    </div>
                    <div class="space-y-1">
                        <label class="text-gray-600">Gender</label>
                        <select name="gender" class="w-full p-2 rounded focus:outline-none focus:ring-1 focus:ring-blue-400">
                            <option value="Male" <%= "Male".equals(gender) ? "selected" : "" %>>Male</option>
                            <option value="Female" <%= "Female".equals(gender) ? "selected" : "" %>>Female</option>
                            <option value="Other" <%= "Other".equals(gender) ? "selected" : "" %>>Other</option>
                        </select>
                    </div>
                    <div class="space-y-1">
                        <label class="text-gray-600">Password</label>
                        <input type="password" name="password" placeholder="Leave blank to keep current" class="w-full p-2 rounded focus:outline-none focus:ring-1 focus:ring-blue-400">
                    </div>
                    <div class="space-y-1">
                        <label class="text-gray-600">Profile Image</label>
                        <input type="file" name="image" class="w-full p-2 rounded focus:outline-none focus:ring-1 focus:ring-blue-400">
                        <img src="<%= empImage %>" class="mt-2 h-32 w-32 rounded object-cover">
                    </div>
                </div>

                <h2 class="text-2xl font-medium text-gray-800 mt-6 mb-2">Managed Theaters</h2>

                <div class="space-y-4">
                    <%
                        while (rsTheaters.next()) {
                            int theaterId = rsTheaters.getInt("theater_id");
                            String theaterName = rsTheaters.getString("name");
                            String theaterLocation = rsTheaters.getString("location");
                            byte[] theaterImgBytes = rsTheaters.getBytes("image");
                            String theaterImgType = rsTheaters.getString("imgtype");
                            String theaterImage = (theaterImgBytes != null && theaterImgBytes.length > 0) ?
                                "data:image/" + (theaterImgType != null ? theaterImgType : "png") + ";base64," + Base64.getEncoder().encodeToString(theaterImgBytes) :
                                "https://via.placeholder.com/100?text=No+Image";
                    %>
                    <div class="flex flex-col md:flex-row items-center gap-4">
                        <input type="hidden" name="theater_id_<%= theaterId %>" value="<%= theaterId %>">
                        <img src="<%= theaterImage %>" class="h-24 w-24 rounded object-cover">

                        <div class="flex-1 grid md:grid-cols-2 gap-4 w-full">
                            <div class="space-y-1">
                                <label class="text-gray-600">Theater Name</label>
                                <input type="text" name="theater_name_<%= theaterId %>" value="<%= theaterName %>" class="w-full p-2 rounded focus:outline-none focus:ring-1 focus:ring-blue-400">
                            </div>
                            <div class="space-y-1">
                                <label class="text-gray-600">Location</label>
                                <input type="text" name="theater_location_<%= theaterId %>" value="<%= theaterLocation %>" class="w-full p-2 rounded focus:outline-none focus:ring-1 focus:ring-blue-400">
                            </div>
                            <div class="space-y-1 md:col-span-2">
                                <label class="text-gray-600">Image</label>
                                <input type="file" name="theater_image_<%= theaterId %>" class="w-full p-2 rounded focus:outline-none focus:ring-1 focus:ring-blue-400">
                            </div>
                        </div>
                    </div>
                    <% } %>
                </div>

                <div class="mt-6">
                    <button type="submit" class="bg-blue-600 text-white px-6 py-2 rounded hover:bg-blue-700 transition">Update Employee</button>
                </div>
            </form>
        </div>
    </div>
</div>

<%
    rsTheaters.close();
    psTheaters.close();
    conn.close();
%>
<jsp:include page="layout/JSPFooter.jsp" />
