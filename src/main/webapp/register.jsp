<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>User Register</title>
<script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="flex items-center justify-center min-h-screen">

<!-- Toast Notification -->
<div id="toast" class="fixed top-5 right-5 hidden bg-red-600 text-white px-4 py-2 rounded-lg"></div>

<div class="w-full bg-white flex justify-center gap-20 items-center overflow-hidden">
    
    <!-- Left Column - Centered Content -->
    <div class="w-1/2 flex items-center justify-end p-8">
        <div class="text-center text-white">
            <img class="h-[500px]" src="https://images.unsplash.com/photo-1710988486897-e933e4b0f72c?q=80&w=1335&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D"/>
        </div>
    </div>

    <!-- Right Column - Centered Form -->
    <div class="w-1/2 p-12 flex items-center">
        <div class="w-full max-w-sm">
            <div class="flex justify-center items-center mb-8">
                <img class="w-20 mr-4" src="assets/img/cinema-logo.jpg"/>
                <a href="home.jsp" class="text-3xl font-bold text-gray-800">CINEZY Cinema</a>
            </div>
            
            <form id="registerForm" action="register" method="post" class="space-y-6">

                <!-- Name -->
                <div>
                    <label class="block text-gray-700 mb-2 font-medium">Full Name</label>
                    <input type="text" name="name" id="name"
                           class="w-full border border-gray-300 rounded-lg px-4 py-3 focus:outline-none focus:ring-2 focus:ring-red-500 focus:border-transparent transition-all duration-200">
                    <p class="text-red-600 text-sm mt-1 hidden" id="nameEmptyError">⚠ Name is required.</p>
                </div>

                <!-- Email -->
                <div>
                    <label class="block text-gray-700 mb-2 font-medium">Email Address</label>
                    <input type="text" name="email" id="email"
                           class="w-full border border-gray-300 rounded-lg px-4 py-3 focus:outline-none focus:ring-2 focus:ring-red-500 focus:border-transparent transition-all duration-200">
                    <p class="text-red-600 text-sm mt-1 hidden" id="emailEmptyError">⚠ Email is required.</p>
                    <p class="text-red-600 text-sm mt-1 hidden" id="emailInvalidError">⚠ Email must include @gmail.com</p>
                </div>

                <!-- Phone -->
                <div>
                    <label class="block text-gray-700 mb-2 font-medium">Phone Number</label>
                    <input type="text" name="phone" id="phone"
                           class="w-full border border-gray-300 rounded-lg px-4 py-3 focus:outline-none focus:ring-2 focus:ring-red-500 focus:border-transparent transition-all duration-200">
                    <p class="text-red-600 text-sm mt-1 hidden" id="phoneEmptyError">⚠ Phone is required.</p>
                    <p class="text-red-600 text-sm mt-1 hidden" id="phoneInvalidError">⚠ Phone must be numbers only.</p>
                </div>

                <!-- Password -->
                <div class="relative">
                    <label class="block text-gray-700 mb-2 font-medium">Password</label>
                    <div class="relative">
                        <input type="password" name="password" id="password"
                               class="w-full border border-gray-300 rounded-lg px-4 py-3 pr-10 focus:outline-none focus:ring-2 focus:ring-red-500 focus:border-transparent transition-all duration-200">
                        <!-- Password Toggle Button -->
                        <button type="button" id="togglePassword" 
                                class="absolute inset-y-0 right-0 pr-3 flex items-center text-gray-600 hover:text-gray-800 transition-colors duration-200">
                            <!-- Eye icon (visible state) -->
                            <svg id="eyeIcon" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="h-5 w-5">
                                <path stroke-linecap="round" stroke-linejoin="round" d="M2.036 12.322a1.012 1.012 0 0 1 0-.639C3.423 7.51 7.36 4.5 12 4.5c4.638 0 8.573 3.007 9.963 7.178.07.207.07.431 0 .639C20.577 16.49 16.64 19.5 12 19.5c-4.638 0-8.573-3.007-9.963-7.178Z" />
                                <path stroke-linecap="round" stroke-linejoin="round" d="M15 12a3 3 0 1 1-6 0 3 3 0 0 1 6 0Z" />
                            </svg>
                            
                            <!-- Eye slash icon (hidden state) -->
                            <svg id="eyeSlashIcon" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="h-5 w-5 hidden">
                                <path stroke-linecap="round" stroke-linejoin="round" d="M3.98 8.223A10.477 10.477 0 0 0 1.934 12C3.226 16.338 7.244 19.5 12 19.5c.993 0 1.953-.138 2.863-.395M6.228 6.228A10.451 10.451 0 0 1 12 4.5c4.756 0 8.773 3.162 10.065 7.498a10.522 10.522 0 0 1-4.293 5.774M6.228 6.228 3 3m3.228 3.228 3.65 3.65m7.894 7.894L21 21m-3.228-3.228-3.65-3.65m0 0a3 3 0 1 0-4.243-4.243m4.242 4.242L9.88 9.88" />
                            </svg>
                        </button>
                    </div>
                    <p class="text-red-600 text-sm mt-1 hidden" id="passwordEmptyError">⚠ Password is required.</p>
                    <p class="text-red-600 text-sm mt-1 hidden" id="passwordLengthError">⚠ Password must be at least 6 characters.</p>
                </div>

                <!-- Confirm Password -->
                <div class="relative">
                    <label class="block text-gray-700 mb-2 font-medium">Confirm Password</label>
                    <div class="relative">
                        <input type="password" name="confirmPassword" id="confirmPassword"
                               class="w-full border border-gray-300 rounded-lg px-4 py-3 pr-10 focus:outline-none focus:ring-2 focus:ring-red-500 focus:border-transparent transition-all duration-200">
                        <!-- Confirm Password Toggle Button -->
                        <button type="button" id="toggleConfirmPassword" 
                                class="absolute inset-y-0 right-0 pr-3 flex items-center text-gray-600 hover:text-gray-800 transition-colors duration-200">
                            <!-- Eye icon (visible state) -->
                            <svg id="eyeIconConfirm" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="h-5 w-5">
                                <path stroke-linecap="round" stroke-linejoin="round" d="M2.036 12.322a1.012 1.012 0 0 1 0-.639C3.423 7.51 7.36 4.5 12 4.5c4.638 0 8.573 3.007 9.963 7.178.07.207.07.431 0 .639C20.577 16.49 16.64 19.5 12 19.5c-4.638 0-8.573-3.007-9.963-7.178Z" />
                                <path stroke-linecap="round" stroke-linejoin="round" d="M15 12a3 3 0 1 1-6 0 3 3 0 0 1 6 0Z" />
                            </svg>
                            
                            <!-- Eye slash icon (hidden state) -->
                            <svg id="eyeSlashIconConfirm" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="h-5 w-5 hidden">
                                <path stroke-linecap="round" stroke-linejoin="round" d="M3.98 8.223A10.477 10.477 0 0 0 1.934 12C3.226 16.338 7.244 19.5 12 19.5c.993 0 1.953-.138 2.863-.395M6.228 6.228A10.451 10.451 0 0 1 12 4.5c4.756 0 8.773 3.162 10.065 7.498a10.522 10.522 0 0 1-4.293 5.774M6.228 6.228 3 3m3.228 3.228 3.65 3.65m7.894 7.894L21 21m-3.228-3.228-3.65-3.65m0 0a3 3 0 1 0-4.243-4.243m4.242 4.242L9.88 9.88" />
                            </svg>
                        </button>
                    </div>
                    <p class="text-red-600 text-sm mt-1 hidden" id="confirmPasswordEmptyError">⚠ Confirm Password is required.</p>
                    <p class="text-red-600 text-sm mt-1 hidden" id="confirmPasswordMatchError">⚠ Passwords do not match.</p>
                </div>

                <!-- Submit -->
                <button type="submit" class="w-full bg-red-700 hover:bg-red-800 text-white font-semibold py-3 px-4 rounded-lg transition-all duration-200 transform">
                    Register
                </button>
            </form>

            <p class="mt-6 text-center text-gray-600">
                Already have an account? 
                <a href="login.jsp" class="text-red-500 hover:text-red-600 font-medium transition-colors duration-200">Login here</a>
            </p>
        </div>
    </div>
</div>

<script>
function showToast(message, color = "bg-red-600") {
    const toast = document.getElementById("toast");
    toast.textContent = message;
    toast.className = `fixed top-5 right-5 ${color} px-4 py-2 rounded-lg`;
    toast.style.display = "block";
    setTimeout(() => { toast.style.display = "none"; }, 3000);
}

// Password visibility toggle for password field
document.getElementById('togglePassword').addEventListener('click', function() {
    const passwordInput = document.getElementById('password');
    const eyeIcon = document.getElementById('eyeIcon');
    
    if (passwordInput.type === 'password') {
        passwordInput.type = 'text';
        // Eye with slash icon
        eyeIcon.innerHTML = `
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13.875 18.825A10.05 10.05 0 0112 19c-4.478 0-8.268-2.943-9.543-7a9.97 9.97 0 011.563-3.029m5.858.908a3 3 0 114.243 4.243M9.878 9.878l4.242 4.242M9.88 9.88l-3.29-3.29m7.532 7.532l3.29 3.29M3 3l3.59 3.59m0 0A9.953 9.953 0 0112 5c4.478 0 8.268 2.943 9.543 7a10.025 10.025 0 01-4.132 5.411m0 0L21 21" />
        `;
    } else {
        passwordInput.type = 'password';
        // Regular eye icon
        eyeIcon.innerHTML = `
            <path d="M10 12a2 2 0 100-4 2 2 0 000 4z" />
            <path fill-rule="evenodd" d="M.458 10C1.732 5.943 5.522 3 10 3s8.268 2.943 9.542 7c-1.274 4.057-5.064 7-9.542 7S1.732 14.057.458 10zM14 10a4 4 0 11-8 0 4 4 0 018 0z" clip-rule="evenodd" />
        `;
    }
});

// Password visibility toggle for confirm password field
document.getElementById('toggleConfirmPassword').addEventListener('click', function() {
    const confirmPasswordInput = document.getElementById('confirmPassword');
    const eyeIconConfirm = document.getElementById('eyeIconConfirm');
    
    if (confirmPasswordInput.type === 'password') {
        confirmPasswordInput.type = 'text';
        // Eye with slash icon
        eyeIconConfirm.innerHTML = `
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13.875 18.825A10.05 10.05 0 0112 19c-4.478 0-8.268-2.943-9.543-7a9.97 9.97 0 011.563-3.029m5.858.908a3 3 0 114.243 4.243M9.878 9.878l4.242 4.242M9.88 9.88l-3.29-3.29m7.532 7.532l3.29 3.29M3 3l3.59 3.59m0 0A9.953 9.953 0 0112 5c4.478 0 8.268 2.943 9.543 7a10.025 10.025 0 01-4.132 5.411m0 0L21 21" />
        `;
    } else {
        confirmPasswordInput.type = 'password';
        // Regular eye icon
        eyeIconConfirm.innerHTML = `
            <path d="M10 12a2 2 0 100-4 2 2 0 000 4z" />
            <path fill-rule="evenodd" d="M.458 10C1.732 5.943 5.522 3 10 3s8.268 2.943 9.542 7c-1.274 4.057-5.064 7-9.542 7S1.732 14.057.458 10zM14 10a4 4 0 11-8 0 4 4 0 018 0z" clip-rule="evenodd" />
        `;
    }
});

// Validation
function validateForm() {
    let valid = true;

    const name = document.getElementById('name');
    const email = document.getElementById('email');
    const phone = document.getElementById('phone');
    const password = document.getElementById('password');
    const confirmPassword = document.getElementById('confirmPassword');

    const nameEmptyError = document.getElementById('nameEmptyError');
    const emailEmptyError = document.getElementById('emailEmptyError');
    const emailInvalidError = document.getElementById('emailInvalidError');
    const phoneEmptyError = document.getElementById('phoneEmptyError');
    const phoneInvalidError = document.getElementById('phoneInvalidError');
    const passwordEmptyError = document.getElementById('passwordEmptyError');
    const passwordLengthError = document.getElementById('passwordLengthError');
    const confirmPasswordEmptyError = document.getElementById('confirmPasswordEmptyError');
    const confirmPasswordMatchError = document.getElementById('confirmPasswordMatchError');

    // Reset styles and errors
    [name, email, phone, password, confirmPassword].forEach(input => input.classList.remove('border-red-500'));
    [nameEmptyError, emailEmptyError, emailInvalidError, phoneEmptyError, phoneInvalidError, 
     passwordEmptyError, passwordLengthError, confirmPasswordEmptyError, confirmPasswordMatchError]
     .forEach(p => p.classList.add('hidden'));

    // Name validation
    if (name.value.trim() === '') {
        nameEmptyError.classList.remove('hidden');
        name.classList.add('border-red-500');
        valid = false;
    }

    // Email validation (use proper Gmail RegExp)
    const emailRegExp = /^[a-zA-Z0-9._%+-]+@gmail\.com$/;
    if (email.value.trim() === '') {
        emailEmptyError.classList.remove('hidden');
        email.classList.add('border-red-500');
        valid = false;
    } else if (!emailRegExp.test(email.value.trim())) {
        emailInvalidError.classList.remove('hidden');
        email.classList.add('border-red-500');
        valid = false;
    }

    // Phone validation (only digits)
    if (phone.value.trim() === '') {
        phoneEmptyError.classList.remove('hidden');
        phone.classList.add('border-red-500');
        valid = false;
    } else if (!/^[0-9]+$/.test(phone.value.trim())) {
        phoneInvalidError.classList.remove('hidden');
        phone.classList.add('border-red-500');
        valid = false;
    }

    // Password validation (min 6 chars + at least 1 letter and 1 number)
    const passwordRegExp = /^(?=.*[A-Za-z])(?=.*\d).{6,}$/;
    if (password.value.trim() === '') {
        passwordEmptyError.classList.remove('hidden');
        password.classList.add('border-red-500');
        valid = false;
    } else if (!passwordRegExp.test(password.value)) {
        passwordLengthError.textContent = "⚠ Password must be at least 6 characters, include letters, numbers and special characters.";
        passwordLengthError.classList.remove('hidden');
        password.classList.add('border-red-500');
        valid = false;
    }

    // Confirm Password validation
    if (confirmPassword.value.trim() === '') {
        confirmPasswordEmptyError.classList.remove('hidden');
        confirmPassword.classList.add('border-red-500');
        valid = false;
    } else if (password.value !== confirmPassword.value) {
        confirmPasswordMatchError.classList.remove('hidden');
        confirmPassword.classList.add('border-red-500');
        valid = false;
    }

    return valid;
}

// Submit
document.getElementById('registerForm').addEventListener('submit', function(e){
    if(!validateForm()){
        e.preventDefault();
        const firstError = document.querySelector('.border-red-500');
        if(firstError) firstError.focus();
    }
});

// Show backend messages
const msg = new URLSearchParams(window.location.search).get('msg');
if(msg === 'exists') showToast('Email already exists!');
else if(msg === 'success') showToast('Registration successful! Please login.', 'bg-green-500');
else if(msg === 'fail') showToast('Registration Failed!');
</script>

</body>
</html>