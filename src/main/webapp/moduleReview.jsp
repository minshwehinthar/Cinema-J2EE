<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.util.List"%>
<%@ page import="com.demo.dao.TheaterDAO"%>
<%@ page import="com.demo.model.Theater"%>

<%
    TheaterDAO theaterDAO = new TheaterDAO();
    List<Theater> theaters = theaterDAO.getAllTheaters();
    String contextPath = request.getContextPath(); // Handles app context path
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Select Theater</title>
<script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-gray-50 font-sans">

<jsp:include page="layout/header.jsp"/>

<div class="max-w-6xl mx-auto py-12 px-4">
    <h1 class="text-4xl font-bold text-center text-gray-800 mb-10">Choose a Theater</h1>

    <% if (theaters == null || theaters.isEmpty()) { %>
        <p class="text-center text-gray-500">No theaters available.</p>
    <% } else { %>
        <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
            <% for (Theater t : theaters) { %>
            <a href="reviews.jsp?theaterId=<%=t.getTheaterId()%>" 
               class="group bg-white rounded-xl shadow-md hover:shadow-xl transition duration-300 p-6 flex flex-col items-center text-center border border-gray-100">

                <!-- Theater Image -->
                <% if (t.getImage() != null && !t.getImage().isEmpty()) { %>
                    <img src="<%= contextPath + "/" + t.getImage() %>" 
                         alt="<%= t.getName() %>" 
                         class="w-32 h-32 object-cover rounded-full mb-4">
                <% } else { %>
                    <div class="w-32 h-32 bg-gray-200 rounded-full mb-4 flex items-center justify-center">
                        <span class="text-gray-400">No Image</span>
                    </div>
                <% } %>

                <!-- Theater Name -->
                <h2 class="text-xl font-semibold text-gray-900 mb-2 group-hover:text-blue-600 transition duration-300">
                    <%= t.getName() %>
                </h2>

                <!-- Location -->
                <p class="text-gray-500 text-sm mb-2"><%= t.getLocation() %></p>

            </a>
            <% } %>
        </div>
    <% } %>
</div>

<jsp:include page="layout/footer.jsp"/>
</body>
</html>
 