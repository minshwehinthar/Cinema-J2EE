<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="com.demo.model.User"%>
<%
    User user = (User) session.getAttribute("user");
    String username = (user != null) ? user.getName() : "Guest";
    String email = (user != null && user.getEmail() != null) ? user.getEmail() : "Viewer";
%>
<script src="${pageContext.request.contextPath}/assets/js/movies1.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/movies2.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/moviedetails1.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/seat-script.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/booking.js"></script> 

<!-- Footer -->
<footer class="backdrop-blur-sm shadow-sm bg-white text-gray-800">
    <div class="container mx-auto p-6">
        <div class="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-4 gap-10">

            <!-- Brand -->
            <div>
                <h2 class="text-2xl font-bold tracking-tight"><img src="assets/img/cinema-logo.jpg" alt="Logo" class="w-12 h-12">J-Seven</h2>
                <p class="mt-4 text-sm text-gray-600 leading-relaxed">
                    Your ultimate movie companion — discover films, share reviews, and connect with cinema lovers worldwide.
                </p>
                <div class="flex space-x-4 mt-6">
                    <a href="#" class="text-gray-500 hover:text-indigo-600 transition"><i data-lucide="facebook"></i></a>
                    <a href="#" class="text-gray-500 hover:text-indigo-600 transition"><i data-lucide="twitter"></i></a>
                    <a href="#" class="text-gray-500 hover:text-indigo-600 transition"><i data-lucide="instagram"></i></a>
                    <a href="#" class="text-gray-500 hover:text-indigo-600 transition"><i data-lucide="youtube"></i></a>
                </div>
            </div>

            <!-- Quick Links -->
            <div>
                <h3 class="text-base font-semibold mb-4">Quick Links</h3>
                <ul class="space-y-3 text-sm">
                    <li><a href="index.jsp" class="hover:text-indigo-600 transition">Home</a></li>
                    <li><a href="movies.jsp" class="hover:text-indigo-600 transition">Movies</a></li>
                    <li><a href="cinemas.jsp" class="hover:text-indigo-600 transition">Cinemas</a></li>
                    <li><a href="food.jsp" class="hover:text-indigo-600 transition">Food</a></li>
                    <li><a href="faq.jsp" class="hover:text-indigo-600 transition">FAQ</a></li>
                </ul>
            </div>

            <!-- User Center -->
            <div>
                <h3 class="text-base font-semibold mb-4">User Center</h3>
                <ul class="space-y-3 text-sm">
                <li><a href="reviews.jsp" class="hover:text-indigo-600 transition">Reviews</a></li>
                        
                    <%
                        if (user != null) { // show links only for logged-in users
                    %>
                        <li><a href="chat.jsp" class="hover:text-indigo-600 transition">Chat</a></li>
                        <li><a href="profile.jsp" class="hover:text-indigo-600 transition">My Profile</a></li>
                        <li><a href="logout" class="text-red-600 hover:text-red-800 transition">Logout</a></li>
                    <%
                        } else { // show login/register links for guests
                    %>
                        <li><a href="login.jsp" class="hover:text-indigo-600 transition">Login</a></li>
                        <li><a href="register.jsp" class="hover:text-indigo-600 transition">Register</a></li>
                    <%
                        }
                    %>
                </ul>
            </div>

            <!-- Contact -->
            <div>
                <h3 class="text-base font-semibold mb-4">Contact</h3>
                <ul class="space-y-3 text-sm">
                    <li>Email: <a href="mailto:support@cineflow.com" class="hover:text-indigo-600 transition">support@cineflow.com</a></li>
                    <li>Phone: +95 912 345 678</li>
                    <li><a href="contact.jsp" class="hover:text-indigo-600 transition">Contact Form</a></li>
                </ul>
            </div>

        </div>

        <!-- Divider -->
        <div class="border-t mt-12 pt-6 flex flex-col md:flex-row justify-between items-center text-sm text-gray-500">
            <p>© <%=java.time.Year.now()%> CineFlow. All rights reserved.</p>
            <p>
                Signed in as <span class="font-medium text-gray-800"><%=username%></span> (<%=email%>)
            </p>
        </div>
    </div>
</footer>

<script>
    lucide.createIcons(); // activate lucide icons
</script>
<jsp:include page="JSPFooter.jsp"/>
