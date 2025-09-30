<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.demo.model.User, com.demo.dao.FoodDAO, com.demo.model.FoodItem" %>
<%
    // Check if user is admin
    User user = (User) session.getAttribute("user");
    if (user == null || !"admin".equals(user.getRole())) {
        response.sendRedirect("login.jsp?msg=unauthorized");
        return;
    }

    // Get food item by id using DAO
    int id = 0;
    try { id = Integer.parseInt(request.getParameter("id")); } 
    catch (Exception e) { response.sendRedirect("food-lists.jsp"); return; }

    FoodDAO dao = new FoodDAO();
    FoodItem food = dao.getFoodById(id);
    if (food == null) {
        response.sendRedirect("food-lists.jsp");
        return;
    }
%>

<jsp:include page="layout/JSPHeader.jsp" />

<div class="flex">
    <jsp:include page="layout/sidebar.jsp" />

    <div class="flex-1 sm:ml-64">
        <jsp:include page="/layout/AdminHeader.jsp" />

        <div class="p-6 md:p-8">
            <!-- Breadcrumb -->
            <nav class="text-sm text-gray-500 mb-4" aria-label="Breadcrumb">
                <ol class="inline-flex items-center space-x-1 md:space-x-3">
                    <li><a href="index.jsp" class="text-gray-700 hover:text-gray-900">Home</a></li>
                    <li>/</li>
                    <li><a href="food-lists.jsp" class="text-gray-700 hover:text-gray-900">Food Management</a></li>
                    <li>/</li>
                    <li class="text-gray-500">Edit Food</li>
                </ol>
            </nav>

            <h1 class="text-3xl font-bold mb-6 text-gray-900">Edit Food Item</h1>

            <form action="<%= request.getContextPath() %>/updateFood" method="post" enctype="multipart/form-data"
      class="grid grid-cols-1 md:grid-cols-2 gap-6">


                <input type="hidden" name="id" value="<%= food.getId() %>"/>

                <!-- Left Column -->
                <div class="space-y-4">
                    <div>
                        <label class="block text-gray-700 font-semibold mb-1">Name</label>
                        <input type="text" name="name" value="<%= food.getName() %>" required
                               class="w-full px-4 py-2 border rounded focus:outline-none focus:ring-2 focus:ring-blue-500"/>
                    </div>

                    <div>
                        <label class="block text-gray-700 font-semibold mb-1">Description</label>
                        <textarea name="description" rows="5"
                                  class="w-full px-4 py-2 border rounded focus:outline-none focus:ring-2 focus:ring-blue-500"><%= food.getDescription() %></textarea>
                    </div>

                    <div>
                        <label class="block text-gray-700 font-semibold mb-1">Food Type</label>
                        <input type="text" name="food_type" value="<%= food.getFoodType() %>" required
                               class="w-full px-4 py-2 border rounded focus:outline-none focus:ring-2 focus:ring-blue-500"/>
                    </div>
                </div>

                <!-- Right Column -->
                <div class="space-y-4">
                    <div>
                        <label class="block text-gray-700 font-semibold mb-1">Price ($)</label>
                        <input type="number" step="0.01" name="price" value="<%= food.getPrice() %>" required
                               class="w-full px-4 py-2 border rounded focus:outline-none focus:ring-2 focus:ring-blue-500"/>
                    </div>

                    <div>
                        <label class="block text-gray-700 font-semibold mb-1">Rating</label>
                        <input type="number" step="0.1" min="0" max="5" name="rating" value="<%= food.getRating() %>"
                               class="w-full px-4 py-2 border rounded focus:outline-none focus:ring-2 focus:ring-blue-500"/>
                    </div>

                    <div>
                        <label class="block text-gray-700 font-semibold mb-1">Current Image</label>
                        <img src="<%= food.getImage() != null && !food.getImage().isEmpty() ? food.getImage() : "assets/img/cart_empty.png" %>" 
                             alt="Food Image" class="w-32 h-32 rounded object-cover mb-2"/>
                        <input type="file" name="image" class="w-full"/>
                    </div>

                    <!-- Buttons -->
                    <div class="flex justify-end mt-4 md:col-span-2">
                        <a href="food-lists.jsp" class="px-5 py-2 border rounded hover:bg-gray-100 mr-3">Cancel</a>
                        <button type="submit" class="px-5 py-2 bg-blue-600 text-white rounded hover:bg-blue-700">Update Food</button>
                    </div>
                </div>
            </form>
        </div>
    </div>
</div>

<jsp:include page="layout/JSPFooter.jsp" />
