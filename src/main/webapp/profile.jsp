<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="com.demo.model.User"%>
<%@ page import="java.util.Base64"%>
<%
User user = (User) session.getAttribute("user");
if (user == null) {
    response.sendRedirect("login.jsp");
    return;
}

// Convert image byte[] to Base64
String userImage;
if (user.getImage() != null && user.getImage().length > 0) {
    String base64 = Base64.getEncoder().encodeToString(user.getImage());
    String type = (user.getImgtype() != null ? user.getImgtype() : "png");
    userImage = "data:image/" + type + ";base64," + base64;
} else {
    userImage = "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAOEAAADhCAMAAAAJbSJIAAA..."; // default avatar
}
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>My Profile</title>
<link rel="stylesheet"
    href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/7.0.0/css/all.min.css"
    integrity="sha512-DxV+EoADOkOygM4IR9yXP8Sb2qwgidEmeqAEmDKIOfPRQZOWbXCzLC6vjbZyy0vPisbH2SyW27+ddLVCN+OMzQ=="
    crossorigin="anonymous" referrerpolicy="no-referrer" />
<script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-gray-50 text-gray-800">

<jsp:include page="layout/header.jsp" />

<main class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">

    <div class="flex flex-col md:flex-row gap-10">

        <!-- Left: Profile Image & Upload -->
        <div
            class="flex flex-col items-center space-y-6 relative w-full md:w-1/3 rounded-xl p-6 bg-white shadow-sm">
            
            <div class="relative">
                <img id="profilePreview" src="<%=userImage%>"
                    class="w-48 h-48 rounded-full object-cover border-2 border-sky-300"
                    alt="Profile">
                
                <!-- Pencil Button -->
                <label for="profileImage"
                    class="absolute bottom-2 right-2 bg-white border border-gray-300 rounded-full h-8 w-8 flex items-center justify-center cursor-pointer hover:bg-sky-100">
                    <i class="fa-solid fa-pen"></i>
                </label>
            </div>

            <!-- Upload Form -->
            <form action="updateProfileImage" method="post" enctype="multipart/form-data"
                class="w-full flex flex-col items-center gap-2">
                <input id="profileImage" type="file" name="profileImage"
                    accept="image/*" class="hidden" onchange="previewImage(event)" required>
                <button type="submit"
                    class="py-2 px-4 bg-sky-500 text-white font-medium rounded hover:bg-sky-600 transition">
                    <i class="fa-solid fa-upload"></i> Upload
                </button>
            </form>

            <!-- User Info Table -->
            <div class="w-full mt-4 overflow-x-auto">
                <table class="min-w-full bg-white rounded-lg shadow-inner text-gray-700">
                    <tbody>
                        <tr class="border-b">
                            <td class="px-4 py-2 font-medium">Name</td>
                            <td class="px-4 py-2"><%=user.getName()%></td>
                        </tr>
                        <tr class="border-b">
                            <td class="px-4 py-2 font-medium">Email</td>
                            <td class="px-4 py-2"><%=user.getEmail()%></td>
                        </tr>
                        <tr class="border-b">
                            <td class="px-4 py-2 font-medium">Phone</td>
                            <td class="px-4 py-2"><%=user.getPhone()%></td>
                        </tr>
                        <tr class="border-b">
                            <td class="px-4 py-2 font-medium">Birth Date</td>
                            <td class="px-4 py-2"><%=user.getBirthdate() != null ? user.getBirthdate() : "-" %></td>
                        </tr>
                        <tr class="border-b">
                            <td class="px-4 py-2 font-medium">Gender</td>
                            <td class="px-4 py-2"><%=user.getGender() != null ? user.getGender() : "-" %></td>
                        </tr>
                        <tr>
                            <td class="px-4 py-2 font-medium">Role</td>
                            <td class="px-4 py-2"><%=user.getRole() != null ? user.getRole() : "-" %></td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </div>

        <!-- Right: Profile Editable Info -->
        <div class="flex-1 w-full md:w-2/3">
            <h2 class="text-3xl font-bold text-sky-700 mb-4">My Profile</h2>

            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">

                <!-- Name -->
                <div class="col-span-1">
                    <label class="block text-sky-600 font-medium">Name</label>
                    <div id="nameDisplay" class="flex justify-between items-center p-2 border rounded">
                        <span><%=user.getName()%></span>
                        <button onclick="enableEdit('name')" class="text-sky-500 text-sm">Edit</button>
                    </div>
                    <form id="nameForm" action="profile" method="post" class="hidden mt-2 flex gap-2">
                        <input type="hidden" name="field" value="name">
                        <input type="text" name="value" value="<%=user.getName()%>" class="border p-1 rounded w-full" required>
                        <button type="submit" class="text-green-600">Save</button>
                        <button type="button" onclick="cancelEdit('name')" class="text-gray-600">Cancel</button>
                    </form>
                </div>

                <!-- Email -->
                <div class="col-span-1">
                    <label class="block text-sky-600 font-medium">Email</label>
                    <div id="emailDisplay" class="flex justify-between items-center p-2 border rounded">
                        <span><%=user.getEmail()%></span>
                        <button onclick="enableEdit('email')" class="text-sky-500 text-sm">Edit</button>
                    </div>
                    <form id="emailForm" action="profile" method="post" class="hidden mt-2 flex gap-2">
                        <input type="hidden" name="field" value="email">
                        <input type="email" name="value" value="<%=user.getEmail()%>" class="border p-1 rounded w-full" required>
                        <button type="submit" class="text-green-600">Save</button>
                        <button type="button" onclick="cancelEdit('email')" class="text-gray-600">Cancel</button>
                    </form>
                </div>

                <!-- Phone -->
                <div class="col-span-1">
                    <label class="block text-sky-600 font-medium">Phone</label>
                    <div id="phoneDisplay" class="flex justify-between items-center p-2 border rounded">
                        <span><%=user.getPhone()%></span>
                        <button onclick="enableEdit('phone')" class="text-sky-500 text-sm">Edit</button>
                    </div>
                    <form id="phoneForm" action="profile" method="post" class="hidden mt-2 flex gap-2">
                        <input type="hidden" name="field" value="phone">
                        <input type="text" name="value" value="<%=user.getPhone()%>" class="border p-1 rounded w-full" required>
                        <button type="submit" class="text-green-600">Save</button>
                        <button type="button" onclick="cancelEdit('phone')" class="text-gray-600">Cancel</button>
                    </form>
                </div>

                <!-- Birth Date -->
                <div class="col-span-1">
                    <label class="block text-sky-600 font-medium">Birth Date</label>
                    <div id="birthDateDisplay" class="flex justify-between items-center p-2 border rounded">
                        <span><%=user.getBirthdate() != null ? user.getBirthdate() : ""%></span>
                        <button onclick="enableEdit('birthDate')" class="text-sky-500 text-sm">Edit</button>
                    </div>
                    <form id="birthDateForm" action="profile" method="post" class="hidden mt-2 flex gap-2">
                        <input type="hidden" name="field" value="birthdate">
                        <input type="date" name="value" value="<%=user.getBirthdate() != null ? user.getBirthdate() : ""%>" class="border p-1 rounded w-full" required>
                        <button type="submit" class="text-green-600">Save</button>
                        <button type="button" onclick="cancelEdit('birthDate')" class="text-gray-600">Cancel</button>
                    </form>
                </div>

                <!-- Gender -->
                <div class="col-span-1 md:col-span-2">
                    <label class="block text-sky-600 font-medium">Gender</label>
                    <div id="genderDisplay" class="flex justify-between items-center p-2 border rounded">
                        <span><%=user.getGender() != null ? user.getGender() : ""%></span>
                        <button onclick="enableEdit('gender')" class="text-sky-500 text-sm">Edit</button>
                    </div>
                    <form id="genderForm" action="profile" method="post" class="hidden mt-2 flex gap-2">
                        <input type="hidden" name="field" value="gender">
                        <select name="value" class="border p-1 rounded w-full" required>
                            <option value="">Select</option>
                            <option value="Male" <%= "Male".equals(user.getGender()) ? "selected" : "" %>>Male</option>
                            <option value="Female" <%= "Female".equals(user.getGender()) ? "selected" : "" %>>Female</option>
                            <option value="Other" <%= "Other".equals(user.getGender()) ? "selected" : "" %>>Other</option>
                        </select>
                        <button type="submit" class="text-green-600">Save</button>
                        <button type="button" onclick="cancelEdit('gender')" class="text-gray-600">Cancel</button>
                    </form>
                </div>

                <!-- Change Password -->
                <div class="col-span-1 md:col-span-2">
                    <h3 class="text-sky-600 font-medium">Change Password</h3>
                    <form action="updatePassword" method="post" class="flex flex-col gap-2 mt-2">
                        <input type="password" name="oldPassword" placeholder="Old Password" class="border p-1 rounded w-72" required>
                        <input type="password" name="newPassword" placeholder="New Password" class="border p-1 rounded w-72" required>
                        <button type="submit" class="py-2 px-4 w-72 bg-red-500 text-white rounded hover:bg-red-600 transition">Update Password</button>
                    </form>
                </div>

            </div>
        </div>
    </div>
</main>

<jsp:include page="layout/footer.jsp" />

<script>
function enableEdit(field) {
    document.getElementById(field + 'Display').classList.add('hidden');
    document.getElementById(field + 'Form').classList.remove('hidden');
}
function cancelEdit(field) {
    document.getElementById(field + 'Form').classList.add('hidden');
    document.getElementById(field + 'Display').classList.remove('hidden');
}
function previewImage(event) {
    const reader = new FileReader();
    reader.onload = e => document.getElementById('profilePreview').src = e.target.result;
    reader.readAsDataURL(event.target.files[0]);
}
</script>

</body>
</html>
