<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.demo.model.User" %>
<%@ page import="java.util.Base64"%>
<%
    // Get the logged-in user from session
    User user = (User) session.getAttribute("user");

    // Only allow admin or theater_admin
    if (user == null || 
       (!"admin".equals(user.getRole()) && !"theateradmin".equals(user.getRole()))) {
        response.sendRedirect("login.jsp?msg=unauthorized");
        return; // stop rendering the rest of the page
    }
    
    String userImage;
    if (user.getImage() != null && user.getImage().length > 0) {
        try {
            String base64 = Base64.getEncoder().encodeToString(user.getImage());
            String type = (user.getImgtype() != null && !user.getImgtype().trim().isEmpty()) 
                ? user.getImgtype().replace("image/", "").toLowerCase() 
                : "png";
                
            userImage = "data:image/" + type + ";base64," + base64;
            
            // Debug: Check if base64 is valid
            System.out.println("Image type: " + type);
            System.out.println("Base64 length: " + base64.length());
            
        } catch (Exception e) {
            System.err.println("Error encoding image: " + e.getMessage());
            userImage = "assets/img/user.png";
        }
    } else {
        userImage = "assets/img/user.png"; 
    }
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Admin Profile</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet"
        href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/7.0.0/css/all.min.css"
        crossorigin="anonymous" referrerpolicy="no-referrer" />
</head>
<body class="bg-white text-gray-900 font-sans">

<jsp:include page="layout/JSPHeader.jsp"/>

<div class="flex min-h-screen">
    <!-- Sidebar -->
    <jsp:include page="layout/sidebar.jsp"/>

    <!-- Main content -->
    <div class="flex-1 sm:ml-64">
        <!-- Admin Header -->
        <jsp:include page="layout/AdminHeader.jsp"/>

        <div class="p-8">
            <!-- Toast Notification -->
            <div id="toast" class="fixed top-5 right-5 hidden bg-red-600 text-white px-4 py-2 rounded-lg z-50 transition-all duration-300"></div>

            <main class="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
                <div class="flex flex-col md:flex-row md:space-x-16 space-y-12 md:space-y-0">

                    <!-- Left: Profile Image & Info -->
                    <div class="flex flex-col items-center w-full md:w-2/5">
                        <div class="relative mb-6">
                            <img id="profilePreview" src="<%=userImage%>"
                                class="w-40 h-40 md:w-48 md:h-48 rounded-full object-cover border-2 border-gray-300"
                                alt="Profile">

                            <label for="profileImage"
                                class="absolute bottom-0 right-0 bg-white rounded-full p-2 border border-gray-300 cursor-pointer hover:bg-gray-100 transition">
                                <i class="fa-solid fa-pen text-gray-900"></i>
                            </label>
                        </div>

                        <form action="updateProfileImage" method="post" enctype="multipart/form-data"
                            class="w-full mb-8 flex flex-col items-center gap-2">
                            <input id="profileImage" type="file" name="profileImage"
                                accept="image/*" class="hidden" onchange="previewImage(event)" required>
                            <button type="submit"
                                class="w-36 py-2 px-4 border border-red-700 text-white bg-red-700 font-medium rounded hover:bg-red-900 transition flex justify-center items-center gap-2">
                                <i class="fa-solid fa-upload"></i> Upload
                            </button>
                        </form>

                        <div class="w-full text-left">
                            <h3 class="text-xl font-bold text-gray-800 mb-4 pb-2 border-b border-gray-300">Profile Details</h3>
                            
                            <table class="w-full">
                                <tbody class="divide-y divide-gray-200">
                                    <tr class="hover:bg-red-50 transition-colors duration-150">
                                        <td class="py-3 px-4 font-semibold text-gray-700 w-1/3">Name:</td>
                                        <td class="py-3 px-4 text-gray-600"><%=user.getName()%></td>
                                    </tr>
                                    <tr class="hover:bg-red-50 transition-colors duration-150">
                                        <td class="py-3 px-4 font-semibold text-gray-700">Email:</td>
                                        <td class="py-3 px-4 text-gray-600"><%=user.getEmail()%></td>
                                    </tr>
                                    <tr class="hover:bg-red-50 transition-colors duration-150">
                                        <td class="py-3 px-4 font-semibold text-gray-700">Phone:</td>
                                        <td class="py-3 px-4 text-gray-600"><%=user.getPhone()%></td>
                                    </tr>
                                    <tr class="hover:bg-red-50 transition-colors duration-150">
                                        <td class="py-3 px-4 font-semibold text-gray-700">Birth Date:</td>
                                        <td class="py-3 px-4 text-gray-600"><%=user.getBirthdate() != null ? user.getBirthdate() : "-" %></td>
                                    </tr>
                                    <tr class="hover:bg-red-50 transition-colors duration-150">
                                        <td class="py-3 px-4 font-semibold text-gray-700">Gender:</td>
                                        <td class="py-3 px-4 text-gray-600"><%=user.getGender() != null ? user.getGender() : "-" %></td>
                                    </tr>
                                    <tr class="hover:bg-red-50 transition-colors duration-150">
                                        <td class="py-3 px-4 font-semibold text-gray-700">Role:</td>
                                        <td class="py-3 px-4 text-gray-600"><%=user.getRole() != null ? user.getRole() : "-" %></td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>
                    </div>

                    <!-- Right: Editable Profile Info -->
                    <div class="flex-1 w-full">
                        <h2 class="text-3xl font-bold mb-8 border-b border-gray-300 pb-3">Edit Profile</h2>

                        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">

                            <!-- Name -->
                            <div>
                                <label class="block text-gray-700 font-medium mb-2">Name</label>
                                <div id="nameDisplay" class="flex justify-between items-center border-b border-gray-300 pb-1">
                                    <span class="text-gray-600"><%=user.getName()%></span>
                                    <button onclick="enableEdit('name')" class="text-red-600 hover:text-red-700 text-sm transition-colors duration-200">
                                        Edit
                                    </button>
                                </div>
                                <form id="nameForm" action="profile" method="post" class="hidden mt-2 flex gap-2">
                                    <input type="hidden" name="field" value="name">
                                    <input type="text" name="value" value="<%=user.getName()%>" 
                                        class="border-b border-gray-400 focus:outline-none focus:border-red-500 w-full transition-colors duration-200" required>
                                    <button type="submit" class="text-red-600 hover:text-red-700 font-medium">Save</button>
                                    <button type="button" onclick="cancelEdit('name')" class="text-gray-500 hover:text-gray-700 font-medium">Cancel</button>
                                </form>
                            </div>

                            <!-- Email -->
                            <div>
                                <label class="block text-gray-700 font-medium mb-2">Email</label>
                                <div id="emailDisplay" class="flex justify-between items-center border-b border-gray-300 pb-1">
                                    <span class="text-gray-600"><%=user.getEmail()%></span>
                                    <button onclick="enableEdit('email')" class="text-red-600 hover:text-red-700 text-sm transition-colors duration-200">
                                        Edit
                                    </button>
                                </div>
                                <form id="emailForm" action="profile" method="post" class="hidden mt-2 flex gap-2">
                                    <input type="hidden" name="field" value="email">
                                    <input type="email" name="value" value="<%=user.getEmail()%>" 
                                        class="border-b border-gray-400 focus:outline-none focus:border-red-500 w-full transition-colors duration-200" required>
                                    <button type="submit" class="text-red-600 hover:text-red-700 font-medium">Save</button>
                                    <button type="button" onclick="cancelEdit('email')" class="text-gray-500 hover:text-gray-700 font-medium">Cancel</button>
                                </form>
                            </div>

                            <!-- Phone -->
                            <div>
                                <label class="block text-gray-700 font-medium mb-2">Phone</label>
                                <div id="phoneDisplay" class="flex justify-between items-center border-b border-gray-300 pb-1">
                                    <span class="text-gray-600"><%=user.getPhone()%></span>
                                    <button onclick="enableEdit('phone')" class="text-red-600 hover:text-red-700 text-sm transition-colors duration-200">
                                        Edit
                                    </button>
                                </div>
                                <form id="phoneForm" action="profile" method="post" class="hidden mt-2 flex gap-2">
                                    <input type="hidden" name="field" value="phone">
                                    <input type="text" name="value" value="<%=user.getPhone()%>" 
                                        class="border-b border-gray-400 focus:outline-none focus:border-red-500 w-full transition-colors duration-200" required>
                                    <button type="submit" class="text-red-600 hover:text-red-700 font-medium">Save</button>
                                    <button type="button" onclick="cancelEdit('phone')" class="text-gray-500 hover:text-gray-700 font-medium">Cancel</button>
                                </form>
                            </div>

                            <!-- Birth Date -->
                            <div>
                                <label class="block text-gray-700 font-medium mb-2">Birth Date</label>
                                <div id="birthDateDisplay" class="flex justify-between items-center border-b border-gray-300 pb-1">
                                    <span class="text-gray-600"><%=user.getBirthdate() != null ? user.getBirthdate() : "Not set"%></span>
                                    <button onclick="enableEdit('birthDate')" class="text-red-600 hover:text-red-700 text-sm transition-colors duration-200">
                                        Edit
                                    </button>
                                </div>
                                <form id="birthDateForm" action="profile" method="post" class="hidden mt-2 flex gap-2">
                                    <input type="hidden" name="field" value="birthdate">
                                    <input type="date" name="value" value="<%=user.getBirthdate() != null ? user.getBirthdate() : ""%>" 
                                        class="border-b border-gray-400 focus:outline-none focus:border-red-500 w-full transition-colors duration-200" required>
                                    <button type="submit" class="text-red-600 hover:text-red-700 font-medium">Save</button>
                                    <button type="button" onclick="cancelEdit('birthDate')" class="text-gray-500 hover:text-gray-700 font-medium">Cancel</button>
                                </form>
                            </div>

                            <!-- Gender -->
                            <div class="md:col-span-2">
                                <label class="block text-gray-700 font-medium mb-2">Gender</label>
                                <div id="genderDisplay" class="flex justify-between items-center border-b border-gray-300 pb-1">
                                    <span class="text-gray-600"><%=user.getGender() != null ? user.getGender() : "Not set"%></span>
                                    <button onclick="enableEdit('gender')" class="text-red-600 hover:text-red-700 text-sm transition-colors duration-200">
                                        Edit
                                    </button>
                                </div>
                                <form id="genderForm" action="profile" method="post" class="hidden mt-2 flex gap-2">
                                    <input type="hidden" name="field" value="gender">
                                    <select name="value" class="border-b border-gray-400 focus:outline-none focus:border-red-500 w-full transition-colors duration-200" required>
                                        <option value="">Select Gender</option>
                                        <option value="Male" <%= "Male".equals(user.getGender()) ? "selected" : "" %>>Male</option>
                                        <option value="Female" <%= "Female".equals(user.getGender()) ? "selected" : "" %>>Female</option>
                                        <option value="Other" <%= "Other".equals(user.getGender()) ? "selected" : "" %>>Other</option>
                                    </select>
                                    <button type="submit" class="text-red-600 hover:text-red-700 font-medium">Save</button>
                                    <button type="button" onclick="cancelEdit('gender')" class="text-gray-500 hover:text-gray-700 font-medium">Cancel</button>
                                </form>
                            </div>

                            <!-- Change Password -->
                            <div class="mt-8 pt-6 border-t border-gray-300 md:col-span-2">
                                <h3 class="text-gray-700 font-medium mb-4">Change Password</h3>
                                <form action="updatePassword" method="post" class="flex flex-col gap-4 w-full max-w-sm">
                                    <!-- Current Password Field -->
                                    <div class="relative">
                                        <input type="password" name="oldPassword" id="oldPassword" placeholder="Current Password" 
                                            class="w-full border-b border-gray-400 focus:outline-none focus:border-red-500 py-2 pr-10 transition-colors duration-200" required>
                                        <!-- Password Toggle Button -->
                                        <button type="button" id="toggleOldPassword" 
                                                class="absolute inset-y-0 right-0 flex items-center text-gray-600 hover:text-gray-800 transition-colors duration-200">
                                            <!-- Eye icon (visible state) -->
                                            <svg id="eyeIconOld" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="h-5 w-5">
                                                <path stroke-linecap="round" stroke-linejoin="round" d="M2.036 12.322a1.012 1.012 0 0 1 0-.639C3.423 7.51 7.36 4.5 12 4.5c4.638 0 8.573 3.007 9.963 7.178.07.207.07.431 0 .639C20.577 16.49 16.64 19.5 12 19.5c-4.638 0-8.573-3.007-9.963-7.178Z" />
                                                <path stroke-linecap="round" stroke-linejoin="round" d="M15 12a3 3 0 1 1-6 0 3 3 0 0 1 6 0Z" />
                                            </svg>
                                            
                                            <!-- Eye slash icon (hidden state) -->
                                            <svg id="eyeSlashIconOld" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="h-5 w-5 hidden">
                                                <path stroke-linecap="round" stroke-linejoin="round" d="M3.98 8.223A10.477 10.477 0 0 0 1.934 12C3.226 16.338 7.244 19.5 12 19.5c.993 0 1.953-.138 2.863-.395M6.228 6.228A10.451 10.451 0 0 1 12 4.5c4.756 0 8.773 3.162 10.065 7.498a10.522 10.522 0 0 1-4.293 5.774M6.228 6.228 3 3m3.228 3.228 3.65 3.65m7.894 7.894L21 21m-3.228-3.228-3.65-3.65m0 0a3 3 0 1 0-4.243-4.243m4.242 4.242L9.88 9.88" />
                                            </svg>
                                        </button>
                                    </div>

                                    <!-- New Password Field -->
                                    <div class="relative">
                                        <input type="password" name="newPassword" id="newPassword" placeholder="New Password" 
                                            class="w-full border-b border-gray-400 focus:outline-none focus:border-red-500 py-2 pr-10 transition-colors duration-200" required>
                                        <!-- Password Toggle Button -->
                                        <button type="button" id="toggleNewPassword" 
                                                class="absolute inset-y-0 right-0 flex items-center text-gray-600 hover:text-gray-800 transition-colors duration-200">
                                            <!-- Eye icon (visible state) -->
                                            <svg id="eyeIconNew" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="h-5 w-5">
                                                <path stroke-linecap="round" stroke-linejoin="round" d="M2.036 12.322a1.012 1.012 0 0 1 0-.639C3.423 7.51 7.36 4.5 12 4.5c4.638 0 8.573 3.007 9.963 7.178.07.207.07.431 0 .639C20.577 16.49 16.64 19.5 12 19.5c-4.638 0-8.573-3.007-9.963-7.178Z" />
                                                <path stroke-linecap="round" stroke-linejoin="round" d="M15 12a3 3 0 1 1-6 0 3 3 0 0 1 6 0Z" />
                                            </svg>
                                            
                                            <!-- Eye slash icon (hidden state) -->
                                            <svg id="eyeSlashIconNew" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="h-5 w-5 hidden">
                                                <path stroke-linecap="round" stroke-linejoin="round" d="M3.98 8.223A10.477 10.477 0 0 0 1.934 12C3.226 16.338 7.244 19.5 12 19.5c.993 0 1.953-.138 2.863-.395M6.228 6.228A10.451 10.451 0 0 1 12 4.5c4.756 0 8.773 3.162 10.065 7.498a10.522 10.522 0 0 1-4.293 5.774M6.228 6.228 3 3m3.228 3.228 3.65 3.65m7.894 7.894L21 21m-3.228-3.228-3.65-3.65m0 0a3 3 0 1 0-4.243-4.243m4.242 4.242L9.88 9.88" />
                                            </svg>
                                        </button>
                                    </div>

                                    <button type="submit" class="w-full bg-red-700 hover:bg-red-800 text-white font-semibold py-3 px-4 rounded-lg transition-all duration-200 transform">
                                        Update Password
                                    </button>
                                </form>
                            </div>
                        </div>
                    </div>
                </div>
            </main>
        </div>
    </div>
</div>

<jsp:include page="layout/JSPFooter.jsp"/>

<script>
function showToast(message, color) {
    const toast = document.getElementById("toast");
    toast.textContent = message;
    
    // Set default color if not provided
    if (!color) {
        color = "bg-red-600";
    }
    
    // Fixed: Use string concatenation instead of template literals
    toast.className = "fixed top-5 right-5 " + color + " text-white px-4 py-2 rounded-lg z-50 transition-all duration-300";
    toast.style.display = "block";
    setTimeout(function() { 
        toast.style.display = "none"; 
    }, 3000);
}

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
    reader.onload = function(e) { 
        document.getElementById('profilePreview').src = e.target.result; 
    };
    reader.readAsDataURL(event.target.files[0]);
}

function setupPasswordToggle(passwordId, toggleId, eyeIconId) {
    const toggleBtn = document.getElementById(toggleId);
    if (toggleBtn) {
        toggleBtn.addEventListener('click', function() {
            const passwordInput = document.getElementById(passwordId);
            const eyeIcon = document.getElementById(eyeIconId);
            
            if (passwordInput.type === 'password') {
                passwordInput.type = 'text';
                eyeIcon.classList.add('hidden');
                if (eyeIcon.nextElementSibling) {
                    eyeIcon.nextElementSibling.classList.remove('hidden');
                }
            } else {
                passwordInput.type = 'password';
                eyeIcon.classList.remove('hidden');
                if (eyeIcon.nextElementSibling) {
                    eyeIcon.nextElementSibling.classList.add('hidden');
                }
            }
        });
    }
}

// Initialize password toggles
document.addEventListener('DOMContentLoaded', function() {
    setupPasswordToggle('oldPassword', 'toggleOldPassword', 'eyeIconOld');
    setupPasswordToggle('newPassword', 'toggleNewPassword', 'eyeIconNew');
    
    // Show backend messages - FIXED: Check if message exists
    const urlParams = new URLSearchParams(window.location.search);
    const msg = urlParams.get('msg');
    
    if(msg === 'updated') {
        showToast('Profile updated successfully!', 'bg-green-500');
    } else if(msg === 'image_updated') {
        showToast('Profile image updated successfully!', 'bg-green-500');
    } else if(msg === 'password_updated') {
        showToast('Password updated successfully!', 'bg-green-500');
    } else if(msg === 'error') {
        showToast('An error occurred. Please try again.', 'bg-red-600');
    } else if(msg === 'invalid_password') {
        showToast('Current password is incorrect.', 'bg-red-600');
    }
});
</script></body>
</html>