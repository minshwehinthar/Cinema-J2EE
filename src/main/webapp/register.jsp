<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>User Register</title>
<script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-gray-100 flex flex-col items-center justify-center min-h-screen">

<!-- Toast Notification -->
<div id="toast" class="fixed top-5 right-5 hidden bg-red-500 text-white px-4 py-2 rounded-lg shadow-lg"></div>

<h1 class="text-3xl font-bold mb-5">Golden Gate Cinema</h1>

<div class="w-full max-w-md bg-white p-8 rounded-2xl shadow-md">
	<h1 class="text-3xl font-bold mb-5 text-center">Golden Gate Cinema</h1>

    <form id="registerForm" action="register" method="post" class="space-y-4">

        <!-- Name -->
        <div>
            <label class="block text-gray-600 mb-1">Name</label>
            <input type="text" name="name" id="name" class="w-full border border-gray-300 rounded-lg px-3 py-2 focus:outline-none">
            <p class="text-red-500 text-sm mt-1 hidden" id="nameError">⚠ Name is required.</p>
        </div>

        <!-- Email -->
        <div>
            <label class="block text-gray-600 mb-1">Email</label>
            <input type="text" name="email" id="email" class="w-full border border-gray-300 rounded-lg px-3 py-2 focus:outline-none">
            <p class="text-red-500 text-sm mt-1 hidden" id="emailEmptyError">⚠ Email is required.</p>
            <p class="text-red-500 text-sm mt-1 hidden" id="emailInvalidError">⚠ Email must include @</p>
        </div>

        <!-- Phone -->
        <div>
            <label class="block text-gray-600 mb-1">Phone</label>
            <input type="text" name="phone" id="phone" class="w-full border border-gray-300 rounded-lg px-3 py-2 focus:outline-none">
            <p class="text-red-500 text-sm mt-1 hidden" id="phoneEmptyError">⚠ Phone is required.</p>
            <p class="text-red-500 text-sm mt-1 hidden" id="phoneInvalidError">⚠ Phone must be numbers only.</p>
        </div>

        <!-- Password -->
        <div>
            <label class="block text-gray-600 mb-1">Password</label>
            <input type="password" name="password" id="password" class="w-full border border-gray-300 rounded-lg px-3 py-2 focus:outline-none">
            <p class="text-red-500 text-sm mt-1 hidden" id="passwordError">⚠ Password must be at least 6 characters</p>
        </div>

        <!-- Confirm Password -->
        <div>
            <label class="block text-gray-600 mb-1">Confirm Password</label>
            <input type="password" name="confirmPassword" id="confirmPassword" class="w-full border border-gray-300 rounded-lg px-3 py-2 focus:outline-none">
            <p class="text-red-500 text-sm mt-1 hidden" id="confirmError">⚠ Passwords do not match</p>
        </div>

        <!-- Submit -->
        <button type="submit" class="w-full bg-blue-500 hover:bg-blue-600 text-white font-semibold py-2 px-4 rounded-lg">
            Register
        </button>

    </form>

    <p class="mt-4 text-center text-gray-600">
        Already have an account? <a href="login.jsp" class="text-blue-500 hover:underline">Login</a>
    </p>
</div>

<script>
function showToast(message, color = "bg-red-500") {
    const toast = document.getElementById("toast");
    toast.textContent = message;
    toast.className = `fixed top-5 right-5 ${color} px-4 py-2 rounded-lg shadow-lg`;
    toast.style.display = "block";
    setTimeout(() => { toast.style.display = "none"; }, 3000);
}

// Validation
function validateForm() {
    let valid = true;

    const name = document.getElementById("name");
    const email = document.getElementById("email");
    const phone = document.getElementById("phone");
    const password = document.getElementById("password");
    const confirmPassword = document.getElementById("confirmPassword");

    const nameError = document.getElementById("nameError");
    const emailEmptyError = document.getElementById("emailEmptyError");
    const emailInvalidError = document.getElementById("emailInvalidError");
    const phoneEmptyError = document.getElementById("phoneEmptyError");
    const phoneInvalidError = document.getElementById("phoneInvalidError");
    const passwordError = document.getElementById("passwordError");
    const confirmError = document.getElementById("confirmError");

    // Reset
    [name, email, phone, password, confirmPassword].forEach(i => i.classList.remove("border-red-500"));
    [nameError, emailEmptyError, emailInvalidError, phoneEmptyError, phoneInvalidError, passwordError, confirmError].forEach(p => p.classList.add("hidden"));

    if (name.value.trim() === "") { nameError.classList.remove("hidden"); name.classList.add("border-red-500"); valid=false; }
    if (email.value.trim() === "") { emailEmptyError.classList.remove("hidden"); email.classList.add("border-red-500"); valid=false; }
    else if (!email.value.includes("@")) { emailInvalidError.classList.remove("hidden"); email.classList.add("border-red-500"); valid=false; }
    if (phone.value.trim() === "") { phoneEmptyError.classList.remove("hidden"); phone.classList.add("border-red-500"); valid=false; }
    else if (!/^\d+$/.test(phone.value.trim())) { phoneInvalidError.classList.remove("hidden"); phone.classList.add("border-red-500"); valid=false; }
    if (password.value.length < 6) { passwordError.classList.remove("hidden"); password.classList.add("border-red-500"); valid=false; }
    if (password.value !== confirmPassword.value) { confirmError.classList.remove("hidden"); confirmPassword.classList.add("border-red-500"); valid=false; }

    return valid;
}

// Submit
document.getElementById("registerForm").addEventListener("submit", function(e) {
    if (!validateForm()) { e.preventDefault(); const firstError = document.querySelector(".border-red-500"); if(firstError) firstError.focus(); }
});

// Backend messages
const msg = new URLSearchParams(window.location.search).get("msg");
if(msg==="exists") showToast("Email already exists!");
else if(msg==="success") showToast("Registration Successful!", "bg-green-500");
else if(msg==="fail") showToast("Registration Failed!");
</script>

</body>
</html>
