<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, com.demo.dao.MyConnection, com.demo.model.User"%>

<%
    User user = (User) session.getAttribute("user");
    if(user == null || !"admin".equals(user.getRole())){
        response.sendRedirect("login.jsp?msg=unauthorized");
        return;
    }

    String idParam = request.getParameter("id");
    if(idParam == null || idParam.isEmpty()){
        response.sendRedirect("users.jsp");
        return;
    }

    int userId = Integer.parseInt(idParam);

    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    try {
        conn = MyConnection.getConnection();
        ps = conn.prepareStatement("SELECT * FROM users WHERE user_id=?");
        ps.setInt(1, userId);
        rs = ps.executeQuery();

        if(!rs.next()){
            response.sendRedirect("users.jsp");
            return;
        }
%>

<jsp:include page="layout/JSPHeader.jsp" />
<div class="flex bg-gray-50 min-h-screen">
    <jsp:include page="layout/sidebar.jsp" />
    <div class="flex-1 sm:ml-64">
        <jsp:include page="/layout/AdminHeader.jsp" />
        <div class="container mx-auto px-6 py-8">
 <!-- Breadcrumb -->
        <div class="max-w-8xl mx-auto pb-4">
            <nav class="text-sm text-gray-500 mb-4" aria-label="Breadcrumb">
                <ol class="flex items-center space-x-2">
                    <li><a href="index.jsp" class="hover:underline">Home</a></li>
                    <li>/</li>
                    <li><a href="users.jsp" class="hover:underline">Users List</a></li>
                    <li>/</li>
                    <li class="text-gray-700">Users Details</li>
                </ol>
            </nav>
        </div>
            <!-- Header -->
            <div class="mb-4 flex flex-col md:flex-row items-start md:items-center justify-between gap-4">
                <h1 class="text-3xl font-bold text-gray-900">User Details</h1>
                
            </div>

         

            <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">

                <!-- User Profile -->
                <div class="flex flex-col items-center space-y-4 p-6 bg-white rounded-xl shadow-sm">
                    <%
                        String img = rs.getString("image");
                    %>
                    <img src="<%= (img != null && !img.isEmpty()) ? img : "https://via.placeholder.com/150" %>"
                         alt="User Image"
                         class="w-36 h-36 object-cover rounded-full border-2 border-blue-400">
                    <h2 class="text-2xl font-semibold text-gray-900 text-center"><%= rs.getString("name") %></h2>

                    <table class="w-full text-gray-700 mt-2">
                        <tbody class="divide-y divide-gray-100">
                            <tr>
                                <td class="font-medium py-2">Email:</td>
                                <td class="py-2"><%= rs.getString("email") %></td>
                            </tr>
                            <tr>
                                <td class="font-medium py-2">Phone:</td>
                                <td class="py-2"><%= rs.getString("phone") != null ? rs.getString("phone") : "N/A" %></td>
                            </tr>
                            <tr>
                                <td class="font-medium py-2">Role:</td>
                                <td class="py-2 capitalize"><%= rs.getString("role") %></td>
                            </tr>
                            <tr>
                                <td class="font-medium py-2">Status:</td>
                                <td class="py-2 <%= "active".equals(rs.getString("status")) ? "text-green-600" : "text-red-600" %> font-semibold">
                                    <%= rs.getString("status") %>
                                </td>
                            </tr>
                            <tr>
                                <td class="font-medium py-2">Created At:</td>
                                <td class="py-2"><%= rs.getTimestamp("created_at") != null ? rs.getTimestamp("created_at") : "N/A" %></td>
                            </tr>
                        </tbody>
                    </table>
                </div>

                <!-- Detailed Info -->
                <div class="lg:col-span-2 bg-white p-6 rounded-xl shadow-sm flex flex-col justify-between">
                    <div>
                        <h2 class="text-xl font-bold text-gray-900 mb-4 border-b border-gray-200 pb-2">Detailed Information</h2>
                        <div class="grid grid-cols-2 gap-4 text-gray-700">
                            <div><strong>ID:</strong> <%= rs.getInt("user_id") %></div>
                            <div><strong>Gender:</strong> <span class="capitalize"><%= rs.getString("gender") != null ? rs.getString("gender") : "N/A" %></span></div>
                            <div><strong>Birth Date:</strong> <%= rs.getDate("birth_date") != null ? rs.getDate("birth_date") : "N/A" %></div>
                            <div><strong>Updated At:</strong> <%= rs.getTimestamp("updated_at") != null ? rs.getTimestamp("updated_at") : "N/A" %></div>
                            <div><strong>Last Login:</strong> <%= rs.getTimestamp("last_login") != null ? rs.getTimestamp("last_login") : "Never" %></div>
                        </div>
                    </div>

                    <!-- Actions -->
                    <div class="mt-6 flex gap-4">
                        <a href="users.jsp" class="px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white rounded-lg transition">Back</a>
                        <a href="deleteUser.jsp?id=<%= rs.getInt("user_id") %>" 
                           onclick="return confirm('Are you sure you want to delete this user?');" 
                           class="px-4 py-2 bg-red-600 hover:bg-red-700 text-white rounded-lg transition">Delete User</a>
                    </div>
                </div>

            </div>
        </div>
    </div>
</div>
<jsp:include page="layout/JSPFooter.jsp" />

<%
    } catch(Exception e){
        e.printStackTrace();
    } finally{
        if(rs != null) rs.close();
        if(ps != null) ps.close();
        if(conn != null) conn.close();
    }
%>
