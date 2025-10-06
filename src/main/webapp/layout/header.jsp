<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.demo.model.User"%>
<%@ page import="com.demo.dao.CartDAO"%>
<%@ page import="java.util.*"%>

<%
User user = (User) session.getAttribute("user");
String username = "Guest";
String email = "Viewer";
String userImage = "assets/img/user.png";
int cartCount = 0;

if(user != null) {
    if(user.getName() != null) username = user.getName();
    if(user.getEmail() != null) email = user.getEmail();
    if(user.getImage() != null && user.getImage().length > 0) {
        userImage = "data:image/" + user.getImgtype() + ";base64," 
                    + Base64.getEncoder().encodeToString(user.getImage());
    }

    CartDAO cartDAO = new CartDAO();
    cartCount = cartDAO.getCartItems(user.getUserId()).size();
}

// get current page
String currentPage = request.getRequestURI();
%>

<header class="sticky top-0 z-50 bg-white shadow-md">
    <div class="container mx-auto px-4 sm:px-6 lg:px-8">
        <nav class="flex items-center justify-between h-16">
            <!-- Logo -->
            <a href="home.jsp" class="flex items-center gap-2">
                <img src="assets/img/cinema-logo.jpg" alt="Logo" class="w-12 h-12">
                <div class="flex flex-col leading-tight">
                    <span class="font-semibold text-gray-900">J-Seven</span>
                    <span class="text-xs text-gray-500">Movies & Cinemas</span>
                </div>
            </a>

            <!-- Desktop Navigation Links -->
            <div class="hidden lg:flex lg:space-x-6">
                <a href="home.jsp" class="relative pb-1 text-sm font-medium transition-all duration-200 
                   <%= currentPage.endsWith("home.jsp") ? "text-red-600 after:absolute after:left-0 after:bottom-0 after:w-full after:h-[2px] after:bg-red-600" : "text-gray-900 hover:text-red-600" %>">
                   Home
                </a>
                <a href="movies.jsp" class="relative pb-1 text-sm font-medium transition-all duration-200 
                   <%= currentPage.endsWith("movies.jsp") ? "text-red-600 after:absolute after:left-0 after:bottom-0 after:w-full after:h-[2px] after:bg-red-600" : "text-gray-900 hover:text-red-600" %>">
                   Movies
                </a>
                <a href="movie-list-user.jsp" class="relative pb-1 text-sm font-medium transition-all duration-200 
                   <%= currentPage.endsWith("movie-list-user.jsp") ? "text-red-600 after:absolute after:left-0 after:bottom-0 after:w-full after:h-[2px] after:bg-red-600" : "text-gray-900 hover:text-red-600" %>">
                   Movie Lists
                </a>
                <a href="foods.jsp" class="relative pb-1 text-sm font-medium transition-all duration-200 
                   <%= currentPage.endsWith("foods.jsp") ? "text-red-600 after:absolute after:left-0 after:bottom-0 after:w-full after:h-[2px] after:bg-red-600" : "text-gray-900 hover:text-red-600" %>">
                   Food
                </a>
                <a href="faq.jsp" class="relative pb-1 text-sm font-medium transition-all duration-200 
                   <%= currentPage.endsWith("faq.jsp") ? "text-red-600 after:absolute after:left-0 after:bottom-0 after:w-full after:h-[2px] after:bg-red-600" : "text-gray-900 hover:text-red-600" %>">
                   FAQ
                </a>
                <a href="reviews.jsp" class="relative pb-1 text-sm font-medium transition-all duration-200 
                   <%= currentPage.endsWith("moduleReview.jsp") ? "text-red-600 after:absolute after:left-0 after:bottom-0 after:w-full after:h-[2px] after:bg-red-600" : "text-gray-900 hover:text-red-600" %>">
                   Reviews
                </a>
                <a href="about.jsp" class="relative pb-1 text-sm font-medium transition-all duration-200 
                   <%= currentPage.endsWith("about.jsp") ? "text-red-600 after:absolute after:left-0 after:bottom-0 after:w-full after:h-[2px] after:bg-red-600" : "text-gray-900 hover:text-red-600" %>">
                   About us
                </a>
                <a href="contact.jsp" class="relative pb-1 text-sm font-medium transition-all duration-200 
                   <%= currentPage.endsWith("contact.jsp") ? "text-red-600 after:absolute after:left-0 after:bottom-0 after:w-full after:h-[2px] after:bg-red-600" : "text-gray-900 hover:text-red-600" %>">
                   Contact
                </a>
            </div>

            <!-- Right Section -->
            <div class="flex items-center gap-4">
                <% if(user != null) { %>
                <!-- User Dropdown & Cart -->
                <div class="hidden lg:flex items-center gap-3 relative">
                    <div class="flex flex-col text-right">
                        <span class="text-sm font-medium text-gray-900"><%= username %></span>
                        <span class="text-xs text-gray-500"><%= email %></span>
                    </div>

                    <!-- Profile Dropdown -->
                    <div class="relative">
                        <button id="profileBtn" class="flex items-center focus:outline-none">
                            <img class="w-11 h-11 object-cover rounded-full transition duration-200" 
                                 src="<%= userImage %>" alt="Profile"/>
                        </button>
                        <div id="profileMenu" class="absolute right-0 mt-2 w-48 bg-white border border-gray-200 rounded-lg shadow-lg hidden flex-col z-50">
                            <a href="profile.jsp" class="block px-4 py-2 text-sm text-gray-900 hover:bg-gray-100 transition">Profile</a>
                            <a href="user-orders.jsp" class="block px-4 py-2 text-sm text-gray-900 hover:bg-gray-100 transition">My Orders</a>
                            <a href="logout" class="block px-4 py-2 text-sm text-red-600 hover:bg-red-50 transition">Logout</a>
                        </div>
                    </div>

                    <!-- Cart Icon -->
                    <a href="cart?action=view" class="relative flex items-center justify-center p-2 rounded-full hover:bg-gray-100 transition">
                        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-6 h-6">
                            <path stroke-linecap="round" stroke-linejoin="round" d="M2.25 3h1.386c.51 0 .955.343 1.087.835l.383 1.437M7.5 14.25a3 3 0 0 0-3 3h15.75m-12.75-3h11.218c1.121-2.3 2.1-4.684 2.924-7.138a60.114 60.114 0 0 0-16.536-1.84M7.5 14.25 5.106 5.272M6 20.25a.75.75 0 1 1-1.5 0 .75.75 0 0 1 1.5 0Zm12.75 0a.75.75 0 1 1-1.5 0 .75.75 0 0 1 1.5 0Z"/>
                        </svg>
                         <% if(cartCount>0){ %>
                            <span id="cartCount" class="absolute -top-1 -right-1 bg-red-500 text-white text-xs font-bold px-1.5 py-0.5 rounded-full"><%= cartCount %></span>
                         <% } %>
                    </a>
                </div>
                <% } else { %>
                <div class="hidden lg:flex items-center gap-2">
                    <a href="login.jsp" class="px-4 py-2 text-sm font-medium text-gray-900 border border-gray-300 rounded hover:bg-gray-100 hover:text-black transition">Login</a>
                    <a href="register.jsp" class="px-4 py-2 text-sm font-medium text-white bg-black rounded hover:bg-gray-800 transition">Get Started</a>
                </div>
                <% } %>

                <!-- Mobile Toggle -->
                <button type="button" class="lg:hidden p-2 rounded-md hover:bg-gray-100" onclick="toggleMenu()">
                    <svg class="w-6 h-6 text-gray-900" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16"/>
                    </svg>
                </button>
            </div>
        </nav>
    </div>

    <!-- Mobile Menu -->
    <div id="mobileMenu" class="hidden lg:hidden border-t w-full bg-white shadow-md">
        <div class="flex flex-col px-4 py-3 space-y-2">
            <a href="home.jsp" class="text-sm font-medium transition 
               <%= currentPage.endsWith("home.jsp") ? "text-red-600 border-l-4 border-red-600 pl-2" : "text-gray-900 hover:text-red-600" %>">Home</a>
            <a href="movies.jsp" class="text-sm font-medium transition 
               <%= currentPage.endsWith("movies.jsp") ? "text-red-600 border-l-4 border-red-600 pl-2" : "text-gray-900 hover:text-red-600" %>">Movies</a>
            <a href="movie-list-user.jsp" class="text-sm font-medium transition 
               <%= currentPage.endsWith("movie-list-user.jsp") ? "text-red-600 border-l-4 border-red-600 pl-2" : "text-gray-900 hover:text-red-600" %>">Movie Lists</a>
            <a href="foods.jsp" class="text-sm font-medium transition 
               <%= currentPage.endsWith("foods.jsp") ? "text-red-600 border-l-4 border-red-600 pl-2" : "text-gray-900 hover:text-red-600" %>">Food</a>
            <a href="faq.jsp" class="text-sm font-medium transition 
               <%= currentPage.endsWith("faq.jsp") ? "text-red-600 border-l-4 border-red-600 pl-2" : "text-gray-900 hover:text-red-600" %>">FAQ</a>
            <a href="reviews.jsp" class="text-sm font-medium transition 
               <%= currentPage.endsWith("moduleReview.jsp") ? "text-red-600 border-l-4 border-red-600 pl-2" : "text-gray-900 hover:text-red-600" %>">Reviews</a>
            <a href="about.jsp" class="text-sm font-medium transition 
               <%= currentPage.endsWith("about.jsp") ? "text-red-600 border-l-4 border-red-600 pl-2" : "text-gray-900 hover:text-red-600" %>">About us</a>
            <a href="contact.jsp" class="text-sm font-medium transition 
               <%= currentPage.endsWith("contact.jsp") ? "text-red-600 border-l-4 border-red-600 pl-2" : "text-gray-900 hover:text-red-600" %>">Contact</a>

            <% if(user != null) { %>
                <a href="profile.jsp" class="text-sm font-medium text-gray-900 hover:text-red-600 transition">Profile</a>
                <a href="user-orders.jsp" class="text-sm font-medium text-gray-900 hover:text-red-600 transition">My Orders</a>
                <a href="logout" class="text-sm font-medium text-red-600 hover:text-red-800 transition">Logout</a>
                <a href="cart?action=view" class="text-sm font-medium text-gray-900 hover:text-red-600 transition">
                    My Cart <% if(cartCount>0){ %>(<span id="cartCountMobile"><%=cartCount%></span>)<% } %>
                </a>
            <% } else { %>
                <a href="login.jsp" class="text-sm font-medium text-gray-900 hover:text-red-600 transition">Login</a>
                <a href="register.jsp" class="text-sm font-medium text-white bg-black rounded hover:bg-gray-800 transition">Get Started</a>
            <% } %>
        </div>
    </div>
</header>

<script>
function toggleMenu() {
    document.getElementById("mobileMenu").classList.toggle("hidden");
}

const profileBtn = document.getElementById("profileBtn");
const profileMenu = document.getElementById("profileMenu");

if(profileBtn){
    profileBtn.addEventListener("click", () => {
        profileMenu.classList.toggle("hidden");
    });
    document.addEventListener("click", (e) => {
        if(!profileBtn.contains(e.target) && !profileMenu.contains(e.target)){
            profileMenu.classList.add("hidden");
        }
    });
}

function updateCartCount(newCount){
    const desktopCount = document.getElementById("cartCount");
    const mobileCount = document.getElementById("cartCountMobile");
    if(desktopCount) desktopCount.textContent = newCount;
    if(mobileCount) mobileCount.textContent = newCount;
}
</script>
