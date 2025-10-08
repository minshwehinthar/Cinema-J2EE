<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.demo.model.User" %>
<%@ page import="java.util.Base64" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    // Prepare profile image
    String profileImage;
    if (user.getImage() != null && user.getImage().length > 0) {
        String base64Image = Base64.getEncoder().encodeToString(user.getImage());
        profileImage = "data:image/" + user.getImgtype() + ";base64," + base64Image;
    } else {
        profileImage = "assets/default-avatar.png";
    }
%>
<jsp:include page="JSPHeader.jsp"/>

<!-- Top Navbar -->
<div class="bg-white shadow-sm border-b border-gray-200 px-6 py-3 flex justify-between items-center">
    <!-- Logo / Branding -->
    <div class="flex items-center gap-2">
        <img src="assets/img/cinema-logo.jpg" alt="Logo" class="w-10 h-10">
        <span class="text-lg font-semibold text-gray-700">CINEZY</span>
    </div>

    <!-- Right Section -->
    <div class="flex items-center gap-6 relative">
        <!-- User Info -->
        <div class="hidden sm:block text-right">
            <h1 class="text-sm font-medium text-gray-800"><%= user.getName() %></h1>
            <p class="text-xs text-gray-500"><%= user.getEmail() %></p>
        </div>

        <!-- Profile Dropdown -->
        <div class="relative">
            <!-- Profile Button -->
            <button id="profileBtn" class="flex items-center focus:outline-none">
                <img class="w-11 h-11 object-cover rounded-full transition duration-200 hover:ring-sky-600" 
                     src="<%= profileImage %>" 
                     alt="Profile"/>
            </button>

            <!-- Dropdown Menu -->
            <div id="profileMenu" class="absolute right-0 mt-2 w-48 bg-white border border-gray-200 rounded-lg shadow-lg hidden">
                <a href="./admin-profile.jsp" class="block px-4 py-2 text-sm text-gray-700 hover:bg-sky-50">Profile</a>
                <a href="./logout" class="block px-4 py-2 text-sm text-red-600 hover:bg-red-50">Logout</a>
            </div>
        </div>
    </div>
</div>

<!-- JS for toggle -->
<script>
    const profileBtn = document.getElementById("profileBtn");
    const profileMenu = document.getElementById("profileMenu");

    profileBtn.addEventListener("click", () => {
        profileMenu.classList.toggle("hidden");
    });

    // Close dropdown when clicking outside
    document.addEventListener("click", (e) => {
        if (!profileBtn.contains(e.target) && !profileMenu.contains(e.target)) {
            profileMenu.classList.add("hidden");
        }
    });
</script>
