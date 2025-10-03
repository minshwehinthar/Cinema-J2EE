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
<script src="https://cdn.tailwindcss.com"></script>
<link rel="stylesheet"
    href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/7.0.0/css/all.min.css"
    crossorigin="anonymous" referrerpolicy="no-referrer" />
</head>
<body class="bg-white text-gray-900 font-sans">

<jsp:include page="layout/header.jsp" />

<main class="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8 py-16">

  <div class="flex flex-col md:flex-row md:space-x-16 space-y-12 md:space-y-0">

    <!-- Left: Profile Image & Info -->
    <div class="flex flex-col items-center w-full md:w-1/3">
      <div class="relative">
        <img id="profilePreview" src="<%=userImage%>"
             class="w-40 h-40 md:w-48 md:h-48 rounded-full object-cover border-2 border-gray-900"
             alt="Profile">

        <label for="profileImage"
               class="absolute bottom-0 right-0 bg-white rounded-full p-2 border border-gray-300 cursor-pointer hover:bg-gray-100 transition">
          <i class="fa-solid fa-pen text-gray-900"></i>
        </label>
      </div>

      <form action="updateProfileImage" method="post" enctype="multipart/form-data"
            class="w-full mt-4 flex flex-col items-center gap-2">
        <input id="profileImage" type="file" name="profileImage"
               accept="image/*" class="hidden" onchange="previewImage(event)" required>
        <button type="submit"
                class="w-36 py-2 px-4 border border-gray-900 text-gray-900 font-medium rounded hover:bg-gray-900 hover:text-white transition flex justify-center items-center gap-2">
          <i class="fa-solid fa-upload"></i> Upload
        </button>
      </form>

      <div class="mt-8 w-full text-left">
        <ul class="space-y-3">
          <li><span class="font-semibold">Name:</span> <%=user.getName()%></li>
          <li><span class="font-semibold">Email:</span> <%=user.getEmail()%></li>
          <li><span class="font-semibold">Phone:</span> <%=user.getPhone()%></li>
          <li><span class="font-semibold">Birth Date:</span> <%=user.getBirthdate() != null ? user.getBirthdate() : "-" %></li>
          <li><span class="font-semibold">Gender:</span> <%=user.getGender() != null ? user.getGender() : "-" %></li>
          <li><span class="font-semibold">Role:</span> <%=user.getRole() != null ? user.getRole() : "-" %></li>
        </ul>
      </div>
    </div>

    <!-- Right: Editable Profile Info -->
    <div class="flex-1 w-full">
      <h2 class="text-3xl font-bold mb-8 border-b border-gray-300 pb-3">Edit Profile</h2>

      <div class="grid grid-cols-1 md:grid-cols-2 gap-6">

        <!-- Name -->
        <div>
          <label class="block text-gray-900 font-medium mb-1">Name</label>
          <div id="nameDisplay" class="flex justify-between items-center border-b border-gray-300 pb-1">
            <span><%=user.getName()%></span>
            <button onclick="enableEdit('name')" class="text-gray-600 text-sm">Edit</button>
          </div>
          <form id="nameForm" action="profile" method="post" class="hidden mt-2 flex gap-2">
            <input type="hidden" name="field" value="name">
            <input type="text" name="value" value="<%=user.getName()%>" class="border-b border-gray-400 focus:outline-none w-full" required>
            <button type="submit" class="text-gray-900 font-medium">Save</button>
            <button type="button" onclick="cancelEdit('name')" class="text-gray-500 font-medium">Cancel</button>
          </form>
        </div>

        <!-- Email -->
        <div>
          <label class="block text-gray-900 font-medium mb-1">Email</label>
          <div id="emailDisplay" class="flex justify-between items-center border-b border-gray-300 pb-1">
            <span><%=user.getEmail()%></span>
            <button onclick="enableEdit('email')" class="text-gray-600 text-sm">Edit</button>
          </div>
          <form id="emailForm" action="profile" method="post" class="hidden mt-2 flex gap-2">
            <input type="hidden" name="field" value="email">
            <input type="email" name="value" value="<%=user.getEmail()%>" class="border-b border-gray-400 focus:outline-none w-full" required>
            <button type="submit" class="text-gray-900 font-medium">Save</button>
            <button type="button" onclick="cancelEdit('email')" class="text-gray-500 font-medium">Cancel</button>
          </form>
        </div>

        <!-- Phone -->
        <div>
          <label class="block text-gray-900 font-medium mb-1">Phone</label>
          <div id="phoneDisplay" class="flex justify-between items-center border-b border-gray-300 pb-1">
            <span><%=user.getPhone()%></span>
            <button onclick="enableEdit('phone')" class="text-gray-600 text-sm">Edit</button>
          </div>
          <form id="phoneForm" action="profile" method="post" class="hidden mt-2 flex gap-2">
            <input type="hidden" name="field" value="phone">
            <input type="text" name="value" value="<%=user.getPhone()%>" class="border-b border-gray-400 focus:outline-none w-full" required>
            <button type="submit" class="text-gray-900 font-medium">Save</button>
            <button type="button" onclick="cancelEdit('phone')" class="text-gray-500 font-medium">Cancel</button>
          </form>
        </div>

        <!-- Birth Date -->
        <div>
          <label class="block text-gray-900 font-medium mb-1">Birth Date</label>
          <div id="birthDateDisplay" class="flex justify-between items-center border-b border-gray-300 pb-1">
            <span><%=user.getBirthdate() != null ? user.getBirthdate() : ""%></span>
            <button onclick="enableEdit('birthDate')" class="text-gray-600 text-sm">Edit</button>
          </div>
          <form id="birthDateForm" action="profile" method="post" class="hidden mt-2 flex gap-2">
            <input type="hidden" name="field" value="birthdate">
            <input type="date" name="value" value="<%=user.getBirthdate() != null ? user.getBirthdate() : ""%>" class="border-b border-gray-400 focus:outline-none w-full" required>
            <button type="submit" class="text-gray-900 font-medium">Save</button>
            <button type="button" onclick="cancelEdit('birthDate')" class="text-gray-500 font-medium">Cancel</button>
          </form>
        </div>

        <!-- Gender -->
        <div class="md:col-span-2">
          <label class="block text-gray-900 font-medium mb-1">Gender</label>
          <div id="genderDisplay" class="flex justify-between items-center border-b border-gray-300 pb-1">
            <span><%=user.getGender() != null ? user.getGender() : ""%></span>
            <button onclick="enableEdit('gender')" class="text-gray-600 text-sm">Edit</button>
          </div>
          <form id="genderForm" action="profile" method="post" class="hidden mt-2 flex gap-2">
            <input type="hidden" name="field" value="gender">
            <select name="value" class="border-b border-gray-400 focus:outline-none w-full" required>
              <option value="">Select</option>
              <option value="Male" <%= "Male".equals(user.getGender()) ? "selected" : "" %>>Male</option>
              <option value="Female" <%= "Female".equals(user.getGender()) ? "selected" : "" %>>Female</option>
              <option value="Other" <%= "Other".equals(user.getGender()) ? "selected" : "" %>>Other</option>
            </select>
            <button type="submit" class="text-gray-900 font-medium">Save</button>
            <button type="button" onclick="cancelEdit('gender')" class="text-gray-500 font-medium">Cancel</button>
          </form>
        </div>

        <!-- Change Password -->
        <div class="md:col-span-2 mt-6">
          <h3 class="text-gray-900 font-medium mb-2">Change Password</h3>
          <form action="updatePassword" method="post" class="flex flex-col gap-2 w-full max-w-sm">
            <input type="password" name="oldPassword" placeholder="Old Password" class="border-b border-gray-400 focus:outline-none py-1" required>
            <input type="password" name="newPassword" placeholder="New Password" class="border-b border-gray-400 focus:outline-none py-1" required>
            <button type="submit" class="py-2 mt-2 bg-black text-white rounded hover:bg-gray-800 transition">Update Password</button>
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
