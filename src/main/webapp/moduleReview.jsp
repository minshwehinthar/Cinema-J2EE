<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.util.List"%>
<%@ page import="com.demo.dao.TheaterDAO"%>
<%@ page import="com.demo.model.Theater"%>

<%
    TheaterDAO theaterDAO = new TheaterDAO();
    List<Theater> theaters = theaterDAO.getAllTheaters();
    String contextPath = request.getContextPath();
%>

<jsp:include page="layout/JSPHeader.jsp"></jsp:include>
<jsp:include page="layout/header.jsp"/>

<div class="max-w-7xl mx-auto py-16 px-4 sm:px-6 lg:px-8">
    <h1 class="text-5xl font-bold text-center text-gray-900 mb-12">Choose a Theater</h1>

    <% if (theaters == null || theaters.isEmpty()) { %>
        <p class="text-center text-gray-500 text-lg">No theaters available at the moment.</p>
    <% } else { %>
        <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-8">
            <% for (Theater t : theaters) { %>
            <a href="reviews.jsp?theaterId=<%=t.getTheaterId()%>" 
               class="group bg-gray-50 rounded-xl border border-gray-200 transition-colors hover:bg-gray-100 p-6 flex flex-col items-center text-center">

                <!-- Theater Image -->
                <% if (t.getImage() != null && !t.getImage().isEmpty() && t.getImgtype() != null) { %>
                    <img src="data:<%= t.getImgtype() %>;base64,<%= t.getImage() %>" 
                         alt="<%= t.getName() %>" 
                         class="w-32 h-32 object-cover rounded-full mb-4 border-2 border-gray-200">
                <% } else { %>
                    <div class="w-32 h-32 bg-gray-200 rounded-full mb-4 flex items-center justify-center border-2 border-gray-200">
                        <span class="text-gray-400 text-sm">No Image</span>
                    </div>
                <% } %>

                <!-- Theater Name -->
                <h2 class="text-xl font-semibold text-gray-900 mb-1 group-hover:text-blue-600 transition-colors">
                    <%= t.getName() %>
                </h2>

                <!-- Location -->
                <p class="text-gray-500 text-sm"><%= t.getLocation() %></p>

            </a>
            <% } %>
        </div>
    <% } %>
</div>

<jsp:include page="layout/footer.jsp"/>
<jsp:include page="layout/JSPFooter.jsp"/>
