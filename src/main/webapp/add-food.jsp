<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.demo.model.User" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null || !"admin".equals(user.getRole())) {
        response.sendRedirect("login.jsp?msg=unauthorized");
        return;
    }
%>

<script src="https://unpkg.com/feather-icons"></script>

<jsp:include page="layout/JSPHeader.jsp" />

<div class="flex min-h-screen">
    <!-- Sidebar -->
    <jsp:include page="layout/sidebar.jsp" />

    <!-- Main content -->
    <div class="flex-1 sm:ml-64">
        <jsp:include page="/layout/AdminHeader.jsp" />

        <div class="flex justify-center mt-6">
            <div class="w-full max-w-7xl">
                <h2 class="text-3xl font-bold mb-10 text-center">➕ Add New Food</h2>

                <% String msg = request.getParameter("msg"); %>
                <% if ("success".equals(msg)) { %>
                    <p class="text-green-600 mb-6 text-center font-semibold">✅ Food added successfully!</p>
                <% } else if ("error".equals(msg)) { %>
                    <p class="text-red-600 mb-6 text-center font-semibold">❌ Error adding food. Try again.</p>
                <% } %>

                <form action="add-food" method="post" enctype="multipart/form-data"
                      class="grid grid-cols-1 md:grid-cols-2 gap-8">

                    <!-- Column 1: Food Info -->
                    <div class="flex flex-col gap-6">
                        <label class="font-medium text-gray-700">Food Name</label>
                        <input type="text" name="name" placeholder="Burger"
                               class="p-4 border rounded-lg focus:ring-2 focus:ring-blue-400" required>

                        <label class="font-medium text-gray-700">Price</label>
                        <input type="number" name="price" step="0.01" placeholder="5.99"
                               class="p-4 border rounded-lg focus:ring-2 focus:ring-blue-400" required>

                        <label class="font-medium text-gray-700">Food Type</label>
                        <select name="food_type"
                                class="p-4 border rounded-lg focus:ring-2 focus:ring-blue-400" required>
                            <option value="snack">Snack</option>
                            <option value="drink">Drink</option>
                        </select>

                        <label class="font-medium text-gray-700">Description</label>
                        <textarea name="description" rows="3" placeholder="Delicious and fresh..."
                                  class="p-4 border rounded-lg focus:ring-2 focus:ring-blue-400"></textarea>
                    </div>

                    <!-- Column 2: Image & Rating -->
<div class="flex flex-col gap-6 items-center">

    <!-- Rating Stars -->
    <div class="w-full flex justify-end items-center gap-2">
        <label class="font-medium text-gray-700 mr-4">Rating:</label>
        <input type="hidden" name="rating" id="ratingInput" value="0">
        <div id="starContainer" class="flex gap-1 text-3xl">
            <span class="cursor-pointer" data-value="1">★</span>
            <span class="cursor-pointer" data-value="2">★</span>
            <span class="cursor-pointer" data-value="3">★</span>
            <span class="cursor-pointer" data-value="4">★</span>
            <span class="cursor-pointer" data-value="5">★</span>
        </div>
    </div>

    <!-- Image preview -->
    <div class="w-full flex justify-center">
        <img id="previewImg" src="assets/img/cart_empty.png" alt="Preview"
             class="w-64 h-64 object-cover rounded-xl border shadow-md">
    </div>

    <!-- Image Upload -->
    <div class="w-full flex justify-center">
        <label for="imageUpload"
               class="flex items-center gap-2 cursor-pointer bg-gray-100 p-3 rounded-lg hover:bg-gray-200 transition-colors">
            <i data-feather="camera"></i> Upload Image
        </label>
        <input type="file" name="image" id="imageUpload" class="hidden" accept="image/*" required>
    </div>

    <!-- Submit button -->
    <div class="w-full flex justify-center">
        <button type="submit"
                class="bg-blue-500 text-white p-3 px-8 rounded-lg hover:bg-blue-600 transition-colors font-medium mt-4">
            Add Food
        </button>
    </div>

</div>


                </form>
            </div>
        </div>

        <script>
            feather.replace();

            // Image preview
            const fileInput = document.getElementById('imageUpload');
            const previewImg = document.getElementById('previewImg');
            fileInput.addEventListener('change', () => {
                if(fileInput.files.length > 0){
                    const reader = new FileReader();
                    reader.onload = e => {
                        previewImg.src = e.target.result;
                    }
                    reader.readAsDataURL(fileInput.files[0]);
                } else {
                    previewImg.src = 'assets/img/cart_empty.png';
                }
            });

            // Star rating
            const stars = document.querySelectorAll("#starContainer span");
            const ratingInput = document.getElementById("ratingInput");
            stars.forEach(star => {
                star.addEventListener("click", () => {
                    const rating = star.getAttribute("data-value");
                    ratingInput.value = rating;
                    stars.forEach(s => {
                        s.style.color = s.getAttribute("data-value") <= rating ? "gold" : "gray";
                    });
                });
            });
        </script>

    </div>
</div>

<jsp:include page="layout/JSPFooter.jsp" />
