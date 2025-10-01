<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="jakarta.servlet.http.HttpSession" %>

<jsp:include page="layout/JSPHeader.jsp"></jsp:include>
<jsp:include page="layout/header.jsp"></jsp:include>

<%
    
    Integer theaterId = (Integer) session.getAttribute("theater_id");

    if(theaterId == null){
        response.sendRedirect("login.jsp");
        return;
    }

    String msg = request.getParameter("msg");
%>

<section class="bg-gray-50 min-h-screen py-16">
  <div class="container mx-auto px-4">
    <h1 class="text-4xl font-bold mb-8 text-center text-indigo-700">Add Time Slots for Your Theater</h1>

    <% if("success".equals(msg)) { %>
        <p class="text-green-600 text-center mb-4">Timeslot added successfully!</p>
    <% } else if("error".equals(msg)) { %>
        <p class="text-red-600 text-center mb-4">Error adding timeslot. Try again!</p>
    <% } else if("overlap".equals(msg)) { %>
        <p class="text-red-600 text-center mb-4">Timeslot overlaps with existing slot!</p>
    <% } %>

    <div class="bg-white p-8 rounded-2xl shadow-lg max-w-lg mx-auto">
      <form action="AddTimeslotServlet" method="post" class="space-y-6">

        <div>
          <label class="block mb-2 text-gray-700 font-semibold">Start Time</label>
          <input type="time" name="start_time" required
                 class="w-full px-4 py-2 border rounded-lg"/>
        </div>

        <div>
          <label class="block mb-2 text-gray-700 font-semibold">End Time</label>
          <input type="time" name="end_time" required
                 class="w-full px-4 py-2 border rounded-lg"/>
        </div>

        <button type="submit"
                class="w-full py-3 bg-indigo-600 text-white font-semibold rounded-lg hover:bg-indigo-700 transition">
          Add Timeslot
        </button>
      </form>
    </div>
  </div>
</section>

<jsp:include page="layout/footer.jsp"></jsp:include>
<jsp:include page="layout/JSPFooter.jsp"></jsp:include>