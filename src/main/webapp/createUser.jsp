<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.demo.model.User" %>

<%
    // Check logged-in admin
    User user = (User) session.getAttribute("user");
    if (user == null || !"admin".equals(user.getRole())) {
        response.sendRedirect("login.jsp?msg=unauthorized");
        return;
    }

    String msg = request.getParameter("msg");
%>

<jsp:include page="layout/JSPHeader.jsp" />

<div class="flex">
    <jsp:include page="layout/sidebar.jsp" />

    <div class="flex-1 sm:ml-64">
        <jsp:include page="/layout/AdminHeader.jsp" />

        <div class="p-10">
            <h2 class="text-2xl font-bold mb-8">Create User</h2>

            <!-- Toast container -->
            <div id="toastContainer" class="fixed top-5 right-5 z-50"></div>

            <form action="CreateUserServlet" method="post" enctype="multipart/form-data"
                  class="grid grid-cols-1 md:grid-cols-2 gap-6">

                <!-- Column 1 -->
                <div class="flex flex-col gap-4">
                    <label>Name</label>
                    <input type="text" name="name" placeholder="John Doe" required
                           class="p-3 border rounded-lg focus:ring-2 focus:ring-blue-400">

                    <label>Email</label>
                    <input type="email" name="email" placeholder="email@example.com" required
                           class="p-3 border rounded-lg focus:ring-2 focus:ring-blue-400">

                    <label>Phone</label>
                    <input type="text" name="phone" placeholder="+123456789"
                           class="p-3 border rounded-lg focus:ring-2 focus:ring-blue-400">

                    <!-- Image upload -->
                    <div class="flex flex-col gap-2 mt-4">
                        <label>Profile Photo</label>
                        <label for="imageUpload"
                               class="flex items-center gap-2 cursor-pointer bg-gray-100 p-3 rounded-lg hover:bg-gray-200 w-32 justify-center">
                            <i data-feather="camera"></i> Upload
                        </label>
                        <input type="file" name="image" id="imageUpload" class="hidden" accept="image/*">
                        <img id="previewImg" src="#" alt="Preview"
                             class="hidden mt-4 w-32 h-32 object-cover rounded-full border">
                    </div>
                </div>

                <!-- Column 2 -->
                <div class="flex flex-col gap-4">
                    <label>Role</label>
                    <select name="role" required class="p-3 border rounded-lg focus:ring-2 focus:ring-blue-400">
                        <option value="">Select Role</option>
                        <option value="user">User</option>
                        <option value="employee">Employee</option>
                    </select>

                    <label>Password</label>
                    <input type="password" name="password" placeholder="********" required
                           class="p-3 border rounded-lg focus:ring-2 focus:ring-blue-400">

                    <label>Birth Date</label>
                    <input type="date" name="birth_date" class="p-3 border rounded-lg focus:ring-2 focus:ring-blue-400">

                    <label>Gender</label>
                    <select name="gender" class="p-3 border rounded-lg focus:ring-2 focus:ring-blue-400">
                        <option value="">Select Gender</option>
                        <option value="male">Male</option>
                        <option value="female">Female</option>
                        <option value="other">Other</option>
                    </select>

                    <!-- Confirm checkbox & submit -->
                    <div class="mt-6 flex flex-col md:flex-row md:items-center md:justify-between gap-4">
                        <label class="flex items-center gap-2 cursor-pointer">
                            <input type="checkbox" required class="w-5 h-5 text-blue-500 border-gray-300 rounded focus:ring-2 focus:ring-blue-400">
                            <span>Are you sure to create account?</span>
                        </label>

                        <button type="submit"
                                class="bg-blue-500 text-white p-3 px-6 rounded-lg hover:bg-blue-600 transition-colors font-medium">
                            Create User
                        </button>
                    </div>
                </div>
            </form>
        </div>
    </div>
</div>

<script src="https://unpkg.com/feather-icons"></script>
<script>
    feather.replace();

    // preview image
    const fileInput = document.getElementById('imageUpload');
    const previewImg = document.getElementById('previewImg');
    fileInput.addEventListener('change', () => {
        if(fileInput.files.length > 0){
            const reader = new FileReader();
            reader.onload = function(e) {
                previewImg.src = e.target.result;
                previewImg.classList.remove('hidden');
            }
            reader.readAsDataURL(fileInput.files[0]);
        } else {
            previewImg.classList.add('hidden');
        }
    });

    // Toast system
    function showToast(msg,isError=false){
        const container = document.getElementById('toastContainer');
        const div = document.createElement('div');
        div.innerText = msg;
        div.className = `mb-2 px-4 py-2 rounded shadow text-white ${isError?'bg-red-500':'bg-green-500'} animate-fade`;
        container.appendChild(div);
        setTimeout(()=>div.remove(),3000);
    }

    <% if (msg != null) { %>
        showToast("<%= msg %>");
    <% } %>
</script>

<style>
@keyframes fade{
  0%{opacity:0; transform: translateY(-10px);}
  10%{opacity:1; transform: translateY(0);}
  90%{opacity:1;}
  100%{opacity:0; transform: translateY(-10px);}
}
.animate-fade{animation: fade 3s forwards;}
</style>

<jsp:include page="layout/JSPFooter.jsp" />
