<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>User Login</title>
<script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-gray-100 flex items-center justify-center min-h-screen">

<!-- Toast Notification -->
<div id="toast" class="fixed top-5 right-5 hidden bg-red-500 text-white px-4 py-2 rounded-lg shadow-lg"></div>

<div class="w-full max-w-md bg-white p-8 rounded-2xl shadow-md">
    <h2 class="text-2xl font-bold text-center text-gray-700 mb-6">Golden Gate Cinema Login</h2>

    <form id="loginForm" action="login" method="post" class="space-y-4">

        <!-- Email -->
        <div>
            <label class="block text-gray-600 mb-1">Email</label>
            <input type="text" name="email" id="email"
                   class="w-full border border-gray-300 rounded-lg px-3 py-2 focus:outline-none">
            <p class="text-red-500 text-sm mt-1 hidden" id="emailEmptyError">⚠ Email is required.</p>
            <p class="text-red-500 text-sm mt-1 hidden" id="emailInvalidError">⚠ Email must include @</p>
        </div>

        <!-- Password -->
        <div>
            <label class="block text-gray-600 mb-1">Password</label>
            <input type="password" name="password" id="password"
                   class="w-full border border-gray-300 rounded-lg px-3 py-2 focus:outline-none">
            <p class="text-red-500 text-sm mt-1 hidden" id="passwordEmptyError">⚠ Password is required.</p>
            <p class="text-red-500 text-sm mt-1 hidden" id="passwordLengthError">⚠ Password must be at least 6 characters.</p>
        </div>

        <!-- Submit -->
        <button type="submit" class="w-full bg-blue-500 hover:bg-blue-600 text-white font-semibold py-2 px-4 rounded-lg">
            Login
        </button>
    </form>

    <p class="mt-4 text-center text-gray-600">
        Don’t have an account? <a href="register.jsp" class="text-blue-500 hover:underline">Register</a>
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

    const email = document.getElementById("email");
    const password = document.getElementById("password");

    const emailEmptyError = document.getElementById("emailEmptyError");
    const emailInvalidError = document.getElementById("emailInvalidError");
    const passwordEmptyError = document.getElementById("passwordEmptyError");
    const passwordLengthError = document.getElementById("passwordLengthError");

    [email, password].forEach(input => input.classList.remove("border-red-500"));
    [emailEmptyError, emailInvalidError, passwordEmptyError, passwordLengthError].forEach(p => p.classList.add("hidden"));

    // Email
    if (email.value.trim() === "") {
        emailEmptyError.classList.remove("hidden");
        email.classList.add("border-red-500");
        valid = false;
    } else if (!email.value.includes("@")) {
        emailInvalidError.classList.remove("hidden");
        email.classList.add("border-red-500");
        valid = false;
    }

    // Password
    if (password.value.trim() === "") {
        passwordEmptyError.classList.remove("hidden");
        password.classList.add("border-red-500");
        valid = false;
    } else if (password.value.length < 6) {
        passwordLengthError.classList.remove("hidden");
        password.classList.add("border-red-500");
        valid = false;
    }

    return valid;
}

// Submit
document.getElementById("loginForm").addEventListener("submit", function(e){
    if(!validateForm()){
        e.preventDefault();
        const firstError = document.querySelector(".border-red-500");
        if(firstError) firstError.focus();
    }
});

// Show backend messages
const msg = new URLSearchParams(window.location.search).get("msg");
if(msg === "invalid") showToast("Invalid email or password!");
else if(msg === "success") showToast("Registration successful! Please login.", "bg-green-500");
else if(msg === "logout") showToast("Logged out successfully.", "bg-green-500");
</script>

</body>
</html>
