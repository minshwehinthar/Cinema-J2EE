<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    com.demo.model.User user = (com.demo.model.User) session.getAttribute("user");
    if (user == null || !"admin".equals(user.getRole())) {
        response.sendRedirect("login.jsp?msg=unauthorized");
        return;
    }

    Integer theaterId = (Integer) session.getAttribute("theater_id");
    if (theaterId == null) {
        response.sendRedirect("create-theater-admin.jsp?msg=noTheater");
        return;
    }
%>

<jsp:include page="layout/JSPHeader.jsp"/>
<div class="flex min-h-screen">
    <jsp:include page="layout/sidebar.jsp"/>
    <div class="flex-1 sm:ml-64">
        <jsp:include page="layout/AdminHeader.jsp"/>

        <div class="max-w-2xl mx-auto mt-10 p-8 bg-white shadow-lg rounded-xl">
            <h2 class="text-2xl font-bold mb-6 text-center">Add Seats for Theater</h2>

            <form action="AddSeatsServlet" method="post" class="space-y-4">
                <input type="hidden" name="theater_id" value="<%= theaterId %>"/>

                <label>Seats per Row:</label>
                <input type="number" name="seatsPerRow" min="1" value="8" required />

                <label>Normal Rows:</label>
                <input type="number" name="normalRows" min="0" value="2" required />

                <label>VIP Rows:</label>
                <input type="number" name="vipRows" min="0" value="2" required />

                <label>Couple Rows:</label>
                <input type="number" name="coupleRows" min="0" value="1" required />

                <label>Seats in Couple Row (1 seat = 2 columns):</label>
                <input type="number" name="coupleSeats" min="1" value="4" required />

                <button type="submit"
                        class="w-full bg-blue-500 text-white py-3 rounded-lg hover:bg-blue-600">
                    Add Seats
                </button>
            </form>
        </div>
    </div>
</div>
<jsp:include page="layout/JSPFooter.jsp"/>