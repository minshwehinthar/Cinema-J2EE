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

<div class="min-h-screen bg-white py-12">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <!-- Header Section -->
        <div class="text-center mb-16">
            <h1 class="text-4xl font-bold text-gray-900 mb-4">
                Select Theater
            </h1>
            <p class="text-lg text-gray-600 max-w-2xl mx-auto">
                Choose from our premium theater locations
            </p>
        </div>

        <% if (theaters == null || theaters.isEmpty()) { %>
            <div class="text-center py-16">
                <div class="max-w-md mx-auto">
                    <div class="w-20 h-20 mx-auto mb-4 bg-gray-100 rounded-full flex items-center justify-center">
                        <svg class="w-10 h-10 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M19 11H5m14 0a2 2 0 012 2v6a2 2 0 01-2 2H5a2 2 0 01-2-2v-6a2 2 0 012-2m14 0V9a2 2 0 00-2-2M5 11V9a2 2 0 012-2m0 0V5a2 2 0 012-2h6a2 2 0 012 2v2M7 7h10"></path>
                        </svg>
                    </div>
                    <h3 class="text-xl font-semibold text-gray-700 mb-2">No Theaters Available</h3>
                    <p class="text-gray-500">Please check back later for updates.</p>
                </div>
            </div>
        <% } else { %>
            <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                <% for (Theater t : theaters) { %>
                <a href="reviews.jsp?theaterId=<%=t.getTheaterId()%>" 
                   class="group bg-white rounded-lg border border-gray-200 hover:border-red-300 transition-all duration-200 hover:shadow-md overflow-hidden">
                    
                    <!-- Theater Image -->
                    <div class="h-40 bg-gray-100 overflow-hidden">
                        <% if (t.getImage() != null && !t.getImage().isEmpty() && t.getImgtype() != null) { %>
                            <img src="data:<%= t.getImgtype() %>;base64,<%= t.getImage() %>" 
                                 alt="<%= t.getName() %>" 
                                 class="w-full h-full object-cover transition-transform duration-300 group-hover:scale-105">
                        <% } else { %>
                            <div class="w-full h-full flex items-center justify-center bg-gray-100">
                                <div class="text-center text-gray-400">
                                    <svg class="w-12 h-12 mx-auto mb-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M19 11H5m14 0a2 2 0 012 2v6a2 2 0 01-2 2H5a2 2 0 01-2-2v-6a2 2 0 012-2m14 0V9a2 2 0 00-2-2M5 11V9a2 2 0 012-2m0 0V5a2 2 0 012-2h6a2 2 0 012 2v2M7 7h10"></path>
                                    </svg>
                                    <span class="text-sm">No Image</span>
                                </div>
                            </div>
                        <% } %>
                    </div>

                    <!-- Theater Info -->
                    <div class="p-5">
                        <h2 class="text-xl font-semibold text-gray-900 mb-2 group-hover:text-red-600 transition-colors duration-200">
                            <%= t.getName() %>
                        </h2>
                        
                        <div class="flex items-center text-gray-600 mb-3">
                            <svg class="w-4 h-4 mr-2 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z"/>
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 11a3 3 0 11-6 0 3 3 0 016 0z"/>
                            </svg>
                            <span class="text-sm text-gray-700"><%= t.getLocation() %></span>
                        </div>

                        <div class="flex items-center justify-between mt-4 pt-3 border-t border-gray-100">
                            <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-red-100 text-red-800">
                                Now Open
                            </span>
                            <div class="text-red-600 text-sm font-medium group-hover:text-red-700 transition-colors duration-200 flex items-center">
                                Review
                                <svg class="w-4 h-4 ml-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7"/>
                                </svg>
                            </div>
                        </div>
                    </div>
                </a>
                <% } %>
            </div>
        <% } %>
    </div>
</div>

<jsp:include page="layout/footer.jsp"/>
<jsp:include page="layout/JSPFooter.jsp"/>