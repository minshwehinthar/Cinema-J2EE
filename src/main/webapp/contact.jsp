<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Cinezy Contact</title>
    <script src="https://cdn.tailwindcss.com"></script>
</head>

<body class="bg-blue-100 text-gray-900 font-sans min-h-screen flex flex-col">

 <header class="bg-blue-800 p-2 shadow-lg">
        <nav class="flex justify-between items-center container mx-auto">
            <div class="logo text-white text-sm font-semibold">
                <a href="#">Cinezy</a>
            </div>
            <ul class="flex space-x-4 text-white text-xs">
                <li><a href="#" class="hover:text-yellow-300">Home</a></li>
                <li><a href="#" class="hover:text-yellow-300">Movies</a></li>
                <li><a href="#" class="hover:text-yellow-300">Cinemas</a></li>
                <li><a href="#" class="hover:text-yellow-300">Food</a></li>
                <li><a href="#" class="hover:text-yellow-300">FAQ</a></li>
                <li><a href="#" class="hover:text-yellow-300">Reviews</a></li>
                <li><a href="AboutUs.jsp" class="hover:text-yellow-300">About us</a></li>
                <li><a href="Contact.jsp" class="hover:text-yellow-300">Contact</a></li>
            </ul>
            <div class="user-profile flex items-center space-x-2">
                <img src="profile.jpg" alt="Profile" class="w-8 h-8 rounded-full">
                <span class="text-white text-xs">Shin</span>
                <a href="#" class="text-yellow-300 hover:text-yellow-400 text-xs">Logout</a>
            </div>
        </nav>
    </header>
    
    <main class="max-w-6xl mx-auto mt-0 px-4 pt-10 pb-10">
    <div class="grid md:grid-cols-2 gap-8">
      
      
      <div class="bg-blue rounded-2xl border border-white/10 shadow-2xl p-8">
        <h1 class="text-4xl font-extrabold text-gray-800 mb-4">Contact Us</h1>
        <p class="text-gray-700 mb-6">
          Need support, want to report a bug, or discuss a partnership?  
          Send us a message and our team will get back to you as soon as possible.You can also reach us through the following contact methods:
        </p>
          <ul class="space-y-4">
                <li class="flex items-center text-gray-700">
                    <span class="text-xl mr-3">📞</span>
                    <span class="text-lg">+1 (800) 123-4567</span>
                </li>
                <li class="flex items-center text-gray-700">
                    <span class="text-xl mr-3">✉️</span>
                    <span class="text-lg">support@Cinezy.com</span>
                </li>
                <li class="flex items-center text-gray-700">
                    <span class="text-xl mr-3">📍</span>
                    <span class="text-lg">123 Cinema Street, Hpa-an, Myanmar</span>
                    </li>
                    </ul>
      </div>

      
      <div class="bg-blue rounded-2xl border border-white/10 shadow-2xl p-8">
        <form id="contactForm" class="space-y-4" novalidate>
          <div class="grid md:grid-cols-2 gap-4">
            <div>
              <label for="name" class="block text-sm font-semibold mb-1">Name </label>
              <input id="name" name="name" required placeholder="Name"
                class="w-full p-3 rounded-lg bg-black/60 border border-gray-600 focus:border-cyan-400 focus:ring-2 focus:ring-cyan-400 outline-none"/>
            </div>
            <div>
              <label for="email" class="block text-sm font-semibold mb-1">Email </label>
              <input id="email" name="email" type="email" required placeholder="user@email.com"
                class="w-full p-3 rounded-lg bg-black/60 border border-gray-600 focus:border-cyan-400 focus:ring-2 focus:ring-cyan-400 outline-none"/>
            </div>
          </div>
          <div>
            <label for="subject" class="block text-sm font-semibold mb-1">Subject </label>


<input id="subject" name="subject" required placeholder="Bug report / Partnership / Other"
              class="w-full p-3 rounded-lg bg-black/60 border border-gray-600 focus:border-cyan-400 focus:ring-2 focus:ring-cyan-400 outline-none"/>
          </div>
          <div>
            <label for="message" class="block text-sm font-semibold mb-1">Message </label>
            <textarea id="message" name="message" required rows="5" placeholder="Write your message here..."
              class="w-full p-3 rounded-lg bg-black/60 border border-gray-600 focus:border-cyan-400 focus:ring-2 focus:ring-cyan-400 outline-none"></textarea>
          </div>
          <button type="submit"
            class="w-full py-3 rounded-lg font-bold text-black bg-blue-500 shadow-lg hover:scale-[1.02] transition">
            Send Message
          </button>
          <p id="status" class="text-sm text-center mt-2"></p>
        </form>
      </div>

    </div>
  </main>

        
<footer class="bg-blue-800 text-white p-4 mt-auto">
        <div class="container mx-auto flex justify-between items-center">
            <div class="text-center text-sm">
                <p>© 2025 Cinezy. All rights reserved.</p>
                <p>Your ultimate movie companion — discover films, share reviews, and <br>
                 connect with cinema lovers worldwide.</p>
            </div>
            <div class="space-x-6 text-center text-sm">
                <a href="#" class="text-white hover:text-yellow-300">Home</a>
                <a href="#" class="text-white hover:text-yellow-300">Movies</a>
                <a href="#" class="text-white hover:text-yellow-300">Cinemas</a>
                <a href="#" class="text-white hover:text-yellow-300">Food</a>
                <a href="#" class="text-white hover:text-yellow-300">FAQ</a>
            </div>
        </div>
    </footer>

</body>

</html>