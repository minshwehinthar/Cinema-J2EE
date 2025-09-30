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
        <jsp:include page="layout/AdminHeader.jsp" />

        <div class="flex justify-center mt-6">
            <div class="w-full max-w-7xl">
                <h2 class="text-3xl font-bold mb-10 text-center">Create Theater & Admin</h2>

                <form action="CreateTheaterServlet" method="post" enctype="multipart/form-data"
                      class="grid grid-cols-1 md:grid-cols-2 gap-8">

                    <!-- Column 1: Theater Info -->
                    <div class="flex flex-col gap-6">

                        <label class="font-medium text-gray-700">Theater Name</label>
                        <input type="text" name="theater_name" placeholder="Golden Gate Cinema"
                               class="p-4 border rounded-lg focus:ring-2 focus:ring-blue-400" required>

                        <label class="font-medium text-gray-700">Street / ရပ်ကွက်</label>
                        <input type="text" name="street" placeholder="Main Street"
                               class="p-4 border rounded-lg focus:ring-2 focus:ring-blue-400" required>

                        <label class="font-medium text-gray-700">Township / State / Country</label>
                        <input type="text" name="full_location" placeholder="Downtown, Yangon, Myanmar"
                               class="p-4 border rounded-lg focus:ring-2 focus:ring-blue-400" required>

                        <!-- Theater Image -->
                        <div class="flex flex-col gap-3 mt-4">
                            <label class="font-medium text-gray-700">Theater Image</label>
                            <label for="theaterImageUpload"
                                   class="flex items-center gap-3 cursor-pointer bg-gray-100 p-4 rounded-lg hover:bg-gray-200 w-36 justify-center">
                                <i data-feather="camera"></i> Upload
                            </label>
                            <input type="file" name="image" id="theaterImageUpload" class="hidden" accept="image/*">

                            <img id="previewTheaterImg" src="#" alt="Preview"
                                 class="hidden mt-4 w-48 h-48 object-cover rounded border">
                        </div>
                    </div>

                    <!-- Column 2: Admin Info -->
                    <div class="flex flex-col gap-6">

                        <label class="font-medium text-gray-700">Username</label>
                        <input type="text" name="username" placeholder="admin"
                               class="p-4 border rounded-lg focus:ring-2 focus:ring-blue-400" required>

                        <label class="font-medium text-gray-700">Email</label>
                        <input type="email" name="email" placeholder="admin@example.com"
                               class="p-4 border rounded-lg focus:ring-2 focus:ring-blue-400" required>

                        <label class="font-medium text-gray-700">Phone</label>
                        <input type="text" name="phone" placeholder="+95 123456789"
                               class="p-4 border rounded-lg focus:ring-2 focus:ring-blue-400">

                        <label class="font-medium text-gray-700">Password</label>
                        <input type="password" name="password" placeholder="********"
                               class="p-4 border rounded-lg focus:ring-2 focus:ring-blue-400" required>

                        <!-- Admin Image -->
                        <div class="flex flex-col gap-3 mt-4">
                            <label class="font-medium text-gray-700">Admin Image</label>
                            <label for="adminImageUpload"
                                   class="flex items-center gap-3 cursor-pointer bg-gray-100 p-4 rounded-lg hover:bg-gray-200 w-36 justify-center">
                                <i data-feather="camera"></i> Upload
                            </label>
                            <input type="file" name="admin_image" id="adminImageUpload" class="hidden" accept="image/*">

                            <img id="previewAdminImg" src="#" alt="Preview"
                                 class="hidden mt-4 w-48 h-48 object-cover rounded border">
                        </div>

                        <div class="mt-10 flex flex-col md:flex-row md:items-center md:justify-between gap-4">
                            <label class="flex items-center gap-3 text-gray-700 cursor-pointer">
                                <input type="checkbox" required
                                       class="w-5 h-5 text-blue-500 border-gray-300 rounded focus:ring-2 focus:ring-blue-400">
                                <span>Confirm creation of theater & admin</span>
                            </label>

                            <button type="submit"
                                    class="bg-blue-500 text-white p-4 px-8 rounded-lg hover:bg-blue-600 transition-colors font-medium">
                                Create Theater
                            </button>
                        </div>
                    </div>

                </form>
            </div>
        </div>

        <script>
            feather.replace(); // Replace feather icons

            // Theater Image Preview
            const theaterFileInput = document.getElementById('theaterImageUpload');
            const previewTheaterImg = document.getElementById('previewTheaterImg');
            theaterFileInput.addEventListener('change', () => {
                if(theaterFileInput.files.length > 0){
                    const reader = new FileReader();
                    reader.onload = function(e) {
                        previewTheaterImg.src = e.target.result;
                        previewTheaterImg.classList.remove('hidden');
                    }
                    reader.readAsDataURL(theaterFileInput.files[0]);
                } else {
                    previewTheaterImg.classList.add('hidden');
                }
            });

            // Admin Image Preview
            const adminFileInput = document.getElementById('adminImageUpload');
            const previewAdminImg = document.getElementById('previewAdminImg');
            adminFileInput.addEventListener('change', () => {
                if(adminFileInput.files.length > 0){
                    const reader = new FileReader();
                    reader.onload = function(e) {
                        previewAdminImg.src = e.target.result;
                        previewAdminImg.classList.remove('hidden');
                    }
                    reader.readAsDataURL(adminFileInput.files[0]);
                } else {
                    previewAdminImg.classList.add('hidden');
                }
            });
        </script>

    </div>
</div>

<jsp:include page="layout/JSPFooter.jsp" />
