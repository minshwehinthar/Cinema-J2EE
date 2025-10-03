<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<jsp:include page="layout/JSPHeader.jsp" />
<jsp:include page="layout/header.jsp" />


<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/swiper@11/swiper-bundle.min.css" />
<script src="https://cdn.jsdelivr.net/npm/swiper@11/swiper-bundle.min.js"></script>

<section class="">
  <div class="w-full mx-auto">
    <!-- Swiper container -->
    <div class="swiper banner-slider">
      <div class="swiper-wrapper">
        <!-- Slide 1 -->
        <div class="swiper-slide relative ">
          <img src="http://plaza.roadthemes.com/aero/pub/media/Plazathemes/bannerslider/images/b/a/banner7-21.jpg" 
               alt="Slide 1" class="object-contain">
          <div class="absolute inset-0 bg-black/30 flex flex-col justify-center p-6 text-white">
            <h2 class="text-3xl font-bold mb-2">Typi non habent claritatem insitam</h2>
            <h3 class="text-xl mb-2">Speed up your car</h3>
            <p class="mb-4 max-w-lg">Claritas est etiam processus dynamicus, qui sequitur mutationem consuetudium lectorum.</p>
            <div class="flex gap-3">
            <a href="movies.jsp" class="bg-orange-500 border border-orange-500 hover:bg-orange-700 hover:border-orange-700 duration-500 px-4 py-2 rounded inline-block w-[121px]">Buy Ticket</a>
<a href="foods.jsp" class="border border-orange-500 text-orange-500 hover:bg-orange-500 hover:text-white duration-500 px-4 py-2 rounded inline-block w-[117px]">Shop Now</a>
            
            </div>
          </div>
        </div>

        <!-- Slide 2 -->
        <div class="swiper-slide relative">
          <img src="http://plaza.roadthemes.com/aero/pub/media/Plazathemes/bannerslider/images/b/a/banner7-22.jpg" 
               alt="Slide 2" class="object-contain">
          <div class="absolute inset-0 bg-black/30 flex flex-col justify-center p-6 text-white">
            <h2 class="text-3xl font-bold mb-2">Typi non habent claritatem insitam</h2>
            <h3 class="text-xl mb-2">Explore the range</h3>
            <p class="mb-4 max-w-lg">Claritas est etiam processus dynamicus, qui sequitur mutationem consuetudium lectorum.</p>
                    <div class="flex gap-3">
            <a href="movies.jsp" class="bg-orange-500 border border-orange-500 hover:bg-orange-700 hover:border-orange-700 duration-500 px-4 py-2 rounded inline-block w-[121px]">Buy Ticket</a>
<a href="foods.jsp" class="border border-orange-500 text-orange-500 hover:bg-orange-500 hover:text-white duration-500 px-4 py-2 rounded inline-block w-[117px]">Shop Now</a>
            
            </div>
          </div>
        </div>

        <!-- Slide 3 -->
        <div class="swiper-slide relative">
          <img src="http://plaza.roadthemes.com/aero/pub/media/Plazathemes/bannerslider/images/b/a/banner7-23.jpg" 
               alt="Slide 3" class=" object-contain">
          <div class="absolute inset-0 bg-black/30 flex flex-col justify-center p-6 text-white">
            <h2 class="text-3xl font-bold mb-2">Typi non habent claritatem insitam</h2>
            <h3 class="text-xl mb-2">Find your dream car</h3>
            <p class="mb-4 max-w-lg">Claritas est etiam processus dynamicus, qui sequitur mutationem consuetudium lectorum.</p>
                    <div class="flex gap-3">
            <a href="movies.jsp" class="bg-orange-500 border border-orange-500 hover:bg-orange-700 hover:border-orange-700 duration-500 px-4 py-2 rounded inline-block w-[121px]">Buy Ticket</a>
<a href="foods.jsp" class="border border-orange-500 text-orange-500 hover:bg-orange-500 hover:text-white duration-500 px-4 py-2 rounded inline-block w-[117px]">Shop Now</a>
            
            </div>
             </div>
        </div>
      </div>

      <!-- Pagination -->
      <div class="swiper-pagination mt-4"></div>

 
    </div>
  </div>
</section>

<script>
  const bannerSwiper = new Swiper('.banner-slider', {
    slidesPerView: 1,
    spaceBetween: 20,
    loop: true,
    autoplay: {
      delay: 3000,
      disableOnInteraction: false,
    },
    pagination: {
      el: '.swiper-pagination',
      clickable: true,
    },
    navigation: {
      nextEl: '.swiper-button-next',
      prevEl: '.swiper-button-prev',
    },
  });
</script>





<section class="bg-gray-50 py-16">
  <div class="max-w-7xl mx-auto px-6 grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-8">

    <!-- Card 1 -->
    <article class="relative group rounded-xl overflow-hidden shadow-lg">
      <!-- Thumbnail -->
      <img src="https://filmax.themerex.net/wp-content/uploads/2017/12/post-27-copyright-485x665.jpg" 
           alt="Inferno" 
           class="w-full h-[400px] object-cover transition-transform duration-300 group-hover:scale-110">
      <!-- Overlay -->
      <div class="absolute inset-0 bg-black/50 opacity-0 group-hover:opacity-100 transition-opacity"></div>

      <!-- Info -->
      <div class="absolute bottom-4 left-4 right-4 text-white space-y-2">
        <h5 class="text-xl font-semibold"><a href="https://filmax.themerex.net/inferno/" class="hover:underline">Inferno</a></h5>
        <p class="text-sm">Adventure</p>
        <div class="flex gap-4 text-sm">
          <a href="https://player.vimeo.com/video/154709932" target="_blank" class="px-3 py-1 bg-red-600 rounded hover:bg-red-700">Watch Trailer</a>
          <a href="https://filmax.themerex.net/inferno/" class="px-3 py-1 bg-gray-800 rounded hover:bg-gray-900">More Info</a>
        </div>
      </div>
    </article>

    <!-- Card 2 -->
    <article class="relative group rounded-xl overflow-hidden shadow-lg">
      <img src="https://filmax.themerex.net/wp-content/uploads/2017/12/post-25-copyright-485x665.jpg" 
           alt="Band of Brothers" 
           class="w-full h-[400px] object-cover transition-transform duration-300 group-hover:scale-110">
      <div class="absolute inset-0 bg-black/50 opacity-0 group-hover:opacity-100 transition-opacity"></div>

      <div class="absolute bottom-4 left-4 right-4 text-white space-y-2">
        <h5 class="text-xl font-semibold"><a href="https://filmax.themerex.net/band-of-brothers/" class="hover:underline">Band of Brothers</a></h5>
        <p class="text-sm">Adventure</p>
        <div class="flex gap-4 text-sm">
          <a href="https://player.vimeo.com/video/38903952" target="_blank" class="px-3 py-1 bg-red-600 rounded hover:bg-red-700">Watch Trailer</a>
          <a href="https://filmax.themerex.net/band-of-brothers/" class="px-3 py-1 bg-gray-800 rounded hover:bg-gray-900">More Info</a>
        </div>
      </div>
    </article>

    <!-- Card 3 -->
    <article class="relative group rounded-xl overflow-hidden shadow-lg">
      <img src="https://filmax.themerex.net/wp-content/uploads/2017/12/post-29-copyright-485x665.jpg" 
           alt="Gladiator" 
           class="w-full h-[400px] object-cover transition-transform duration-300 group-hover:scale-110">
      <div class="absolute inset-0 bg-black/50 opacity-0 group-hover:opacity-100 transition-opacity"></div>

      <div class="absolute bottom-4 left-4 right-4 text-white space-y-2">
        <h5 class="text-xl font-semibold"><a href="https://filmax.themerex.net/gladiator/" class="hover:underline">Gladiator</a></h5>
        <p class="text-sm">Action • Adventure</p>
        <div class="flex gap-4 text-sm">
          <a href="https://player.vimeo.com/video/154709932" target="_blank" class="px-3 py-1 bg-red-600 rounded hover:bg-red-700">Watch Trailer</a>
          <a href="https://filmax.themerex.net/gladiator/" class="px-3 py-1 bg-gray-800 rounded hover:bg-gray-900">More Info</a>
        </div>
      </div>
    </article>

    <!-- Card 4 -->
    <article class="relative group rounded-xl overflow-hidden shadow-lg">
      <img src="https://filmax.themerex.net/wp-content/uploads/2017/12/post-23-copyright-485x665.jpg" 
           alt="Pirates Bay" 
           class="w-full h-[400px] object-cover transition-transform duration-300 group-hover:scale-110">
      <div class="absolute inset-0 bg-black/50 opacity-0 group-hover:opacity-100 transition-opacity"></div>

      <div class="absolute bottom-4 left-4 right-4 text-white space-y-2">
        <h5 class="text-xl font-semibold"><a href="https://filmax.themerex.net/pirates-bay-2/" class="hover:underline">Pirates Bay</a></h5>
        <p class="text-sm">Action • Adventure</p>
        <div class="flex gap-4 text-sm">
          <a href="https://player.vimeo.com/video/146428114" target="_blank" class="px-3 py-1 bg-red-600 rounded hover:bg-red-700">Watch Trailer</a>
          <a href="https://filmax.themerex.net/pirates-bay-2/" class="px-3 py-1 bg-gray-800 rounded hover:bg-gray-900">More Info</a>
        </div>
      </div>
    </article>

  </div>
</section>

<section class="bg-gray-50 py-16">
  <div class="max-w-6xl mx-auto px-6">
    <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-10 text-center">
      
      <!-- Feature 1 -->
      <div class="bg-white rounded-xl shadow-md p-8 hover:shadow-lg transition">
        <div class="flex justify-center mb-4">
          <span class="w-16 h-16 flex items-center justify-center rounded-full bg-red-100 text-red-600 text-2xl">
            🚚
          </span>
        </div>
        <h3 class="text-xl font-semibold text-gray-800">Free Delivery</h3>
        <p class="text-gray-600 mt-2">
          Nam liber tempor cum soluta nobis <br> eleifend option congue.
        </p>
      </div>

      <!-- Feature 2 -->
      <div class="bg-white rounded-xl shadow-md p-8 hover:shadow-lg transition">
        <div class="flex justify-center mb-4">
          <span class="w-16 h-16 flex items-center justify-center rounded-full bg-green-100 text-green-600 text-2xl">
            💵
          </span>
        </div>
        <h3 class="text-xl font-semibold text-gray-800">Money Guarantee</h3>
        <p class="text-gray-600 mt-2">
          Nam liber tempor cum soluta nobis <br> eleifend option congue.
        </p>
      </div>

      <!-- Feature 3 -->
      <div class="bg-white rounded-xl shadow-md p-8 hover:shadow-lg transition">
        <div class="flex justify-center mb-4">
          <span class="w-16 h-16 flex items-center justify-center rounded-full bg-blue-100 text-blue-600 text-2xl">
            🎧
          </span>
        </div>
        <h3 class="text-xl font-semibold text-gray-800">Online Support</h3>
        <p class="text-gray-600 mt-2">
          Nam liber tempor cum soluta nobis <br> eleifend option congue.
        </p>
      </div>

    </div>
  </div>
</section>



<!-- Testimonials Section -->
<section class="bg-gray-900 py-16">
  <div class="max-w-6xl mx-auto px-6 text-center text-white">
    <h2 class="text-3xl font-bold mb-10">What People Say</h2>

    <!-- Swiper -->
    <div class="swiper testimonials-slider">
      <div class="swiper-wrapper">

        <!-- Slide 1 -->
        <div class="swiper-slide">
          <div class="bg-gray-800 p-6 rounded-xl shadow-lg">
            <img src="https://filmax.themerex.net/wp-content/uploads/2017/12/1test-copyright-105x105.jpg" 
                 alt="Martin Moore" 
                 class="w-20 h-20 rounded-full mx-auto mb-4 object-cover">
            <p class="italic mb-4">“ I appreciate the high quality of your products guys! ”</p>
            <h4 class="font-semibold">Martin Moore</h4>
            <span class="text-sm text-gray-400">Film Expert</span>
          </div>
        </div>

        <!-- Slide 2 -->
        <div class="swiper-slide">
          <div class="bg-gray-800 p-6 rounded-xl shadow-lg">
            <img src="https://filmax.themerex.net/wp-content/uploads/2017/12/2test-copyright-105x105.jpg" 
                 alt="Andrea Garcia" 
                 class="w-20 h-20 rounded-full mx-auto mb-4 object-cover">
            <p class="italic mb-4">“ Everything is great about this website, we liked it. ”</p>
            <h4 class="font-semibold">Andrea Garcia</h4>
            <span class="text-sm text-gray-400">Film Expert</span>
          </div>
        </div>

        <!-- Slide 3 -->
        <div class="swiper-slide">
          <div class="bg-gray-800 p-6 rounded-xl shadow-lg">
            <img src="https://filmax.themerex.net/wp-content/uploads/2017/12/3test-copyright-105x105.jpg" 
                 alt="Mike Stevens" 
                 class="w-20 h-20 rounded-full mx-auto mb-4 object-cover">
            <p class="italic mb-4">“ This was fun for all of my friends. Thank you so much! ”</p>
            <h4 class="font-semibold">Mike Stevens</h4>
            <span class="text-sm text-gray-400">Film Expert</span>
          </div>
        </div>

        <!-- Slide 4 -->
        <div class="swiper-slide">
          <div class="bg-gray-800 p-6 rounded-xl shadow-lg">
            <img src="https://filmax.themerex.net/wp-content/uploads/2018/01/team-11-copyright-105x105.jpg" 
                 alt="Lisa Morrison" 
                 class="w-20 h-20 rounded-full mx-auto mb-4 object-cover">
            <p class="italic mb-4">“ It was so much fun for all of my friends and family. ”</p>
            <h4 class="font-semibold">Lisa Morrison</h4>
            <span class="text-sm text-gray-400">Film Expert</span>
          </div>
        </div>

      </div>

      <!-- Pagination -->
      <div class="swiper-pagination mt-6"></div>
    </div>
  </div>
</section>

<!-- SwiperJS -->
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/swiper@11/swiper-bundle.min.css" />
<script src="https://cdn.jsdelivr.net/npm/swiper@11/swiper-bundle.min.js"></script>

<script>
  const swiper = new Swiper(".testimonials-slider", {
    slidesPerView: 1,
    spaceBetween: 20,
    loop: true,
    autoplay: {
      delay: 3000,
      disableOnInteraction: false,
    },
    pagination: {
      el: ".swiper-pagination",
      clickable: true,
    },
    breakpoints: {
      640: { slidesPerView: 2 },
      1024: { slidesPerView: 3 },
    },
  });
</script>






<section class="max-w-7xl mx-auto px-6 py-12">
  <!-- Tabs -->
  <div class="border-b border-gray-200 mb-8">
    <ul class="flex space-x-6 text-lg font-medium" id="tabs">
      <li>
        <button data-tab="recent" class="tab-btn py-2 border-b-2 border-blue-600 text-blue-600">Recent</button>
      </li>
      <li>
        <button data-tab="popular" class="tab-btn py-2 text-gray-600 hover:text-blue-600">Most Popular</button>
      </li>
      <li>
        <button data-tab="best" class="tab-btn py-2 text-gray-600 hover:text-blue-600">Best</button>
      </li>
      <li>
        <button data-tab="coming" class="tab-btn py-2 text-gray-600 hover:text-blue-600">Coming Soon</button>
      </li>
    </ul>
  </div>

  <!-- Tab Content -->
  <div id="tab-content">
    <!-- Recent -->
    <div id="recent" class="tab-panel grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-6">
      <div class="bg-white rounded-xl overflow-hidden shadow hover:shadow-lg transition">
        <div class="relative">
          <img class="w-full h-72 object-cover" src="https://filmax.themerex.net/wp-content/uploads/2017/12/post-23-copyright-485x598.jpg" alt="Pirates Bay" />
          <div class="absolute inset-0 bg-black bg-opacity-30 opacity-0 hover:opacity-100 flex items-center justify-center transition">
            <a href="https://filmax.themerex.net/pirates-bay/" class="text-white text-lg font-semibold">▶ Watch</a>
          </div>
        </div>
        <div class="p-4">
          <h3 class="text-lg font-bold"><a href="https://filmax.themerex.net/pirates-bay/" class="hover:text-blue-600">Pirates Bay</a></h3>
          <p class="text-sm text-gray-500 mt-1">Fantasy</p>
        </div>
      </div>
    </div>

    <!-- Most Popular -->
    <div id="popular" class="tab-panel hidden grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-6">
      <div class="bg-white rounded-xl overflow-hidden shadow hover:shadow-lg transition">
        <div class="relative">
          <img class="w-full h-72 object-cover" src="https://filmax.themerex.net/wp-content/uploads/2017/12/post-19-copyright-485x598.jpg" alt="The Last Samurai" />
          <div class="absolute inset-0 bg-black bg-opacity-30 opacity-0 hover:opacity-100 flex items-center justify-center transition">
            <a href="https://filmax.themerex.net/the-last-samurai/" class="text-white text-lg font-semibold">▶ Watch</a>
          </div>
        </div>
        <div class="p-4">
          <h3 class="text-lg font-bold"><a href="https://filmax.themerex.net/the-last-samurai/" class="hover:text-blue-600">The Last Samurai</a></h3>
          <p class="text-sm text-gray-500 mt-1">Fantasy</p>
        </div>
      </div>
    </div>

    <!-- Best -->
    <div id="best" class="tab-panel hidden grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-6">
      <p class="text-gray-600">Best movies list here...</p>
    </div>

    <!-- Coming Soon -->
    <div id="coming" class="tab-panel hidden grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-6">
      <p class="text-gray-600">Coming soon list here...</p>
    </div>
  </div>
</section>

<script>
  // Tab switching logic
  const tabs = document.querySelectorAll(".tab-btn");
  const panels = document.querySelectorAll(".tab-panel");

  tabs.forEach(tab => {
    tab.addEventListener("click", () => {
      // Reset active tab
      tabs.forEach(t => t.classList.remove("border-blue-600", "text-blue-600"));
      tabs.forEach(t => t.classList.add("text-gray-600"));

      // Hide all panels
      panels.forEach(panel => panel.classList.add("hidden"));

      // Show clicked tab + panel
      tab.classList.add("border-blue-600", "text-blue-600");
      tab.classList.remove("text-gray-600");
      document.getElementById(tab.dataset.tab).classList.remove("hidden");
    });
  });
</script>
<section class="max-w-6xl mx-auto px-6 py-16">
  <div class="grid grid-cols-1 lg:grid-cols-2 gap-12">
    
    <!-- Left Column -->
    <div>
      <h2 class="text-4xl font-bold leading-tight">
        Robert <br> Simpson
      </h2>
      <blockquote class="mt-4 text-gray-600 italic">
        <p>
          An actor's career filmography is the list of films he or she has appeared in; a director's filmography.
        </p>
        <cite class="block mt-2">
          <a href="/about-us/" class="text-blue-600 hover:underline">
            View Robert's biography
          </a>
        </cite>
      </blockquote>
    </div>

    <!-- Right Column -->
    <div>
      <!-- Tabs -->
      <div class="border-b border-gray-300 mb-6 flex space-x-6">
        <button class="tab-btn pb-2 border-b-2 border-blue-600 font-semibold text-blue-600" data-tab="best">
          Best Films
        </button>
        <button class="tab-btn pb-2 text-gray-600 hover:text-blue-600" data-tab="popular">
          Most Popular
        </button>
        <button class="tab-btn pb-2 text-gray-600 hover:text-blue-600" data-tab="latest">
          Latest
        </button>
      </div>

      <!-- Tab Contents -->
      <div id="tab-best" class="tab-content grid grid-cols-1 sm:grid-cols-3 gap-6">
        <!-- Film Item -->
        <div class="group">
          <div class="relative overflow-hidden rounded-lg">
            <img src="https://filmax.themerex.net/wp-content/uploads/2017/12/post-24-copyright-600x600.jpg" class="w-full h-48 object-cover group-hover:scale-105 transition">
            <div class="absolute inset-0 bg-black/40 flex items-center justify-center opacity-0 group-hover:opacity-100 transition">
              <span class="text-white">▶</span>
            </div>
          </div>
          <h5 class="mt-3 font-semibold">The Last Tales</h5>
          <p class="text-sm text-gray-500">Action, Fantasy</p>
        </div>
        <div class="group">
          <div class="relative overflow-hidden rounded-lg">
            <img src="https://filmax.themerex.net/wp-content/uploads/2017/12/post-23-copyright-600x600.jpg" class="w-full h-48 object-cover group-hover:scale-105 transition">
            <div class="absolute inset-0 bg-black/40 flex items-center justify-center opacity-0 group-hover:opacity-100 transition">
              <span class="text-white">▶</span>
            </div>
          </div>
          <h5 class="mt-3 font-semibold">Pirates Bay</h5>
          <p class="text-sm text-gray-500">Action, Adventure</p>
        </div>
        <div class="group">
          <div class="relative overflow-hidden rounded-lg">
            <img src="https://filmax.themerex.net/wp-content/uploads/2017/12/post-29-copyright-600x600.jpg" class="w-full h-48 object-cover group-hover:scale-105 transition">
            <div class="absolute inset-0 bg-black/40 flex items-center justify-center opacity-0 group-hover:opacity-100 transition">
              <span class="text-white">▶</span>
            </div>
          </div>
          <h5 class="mt-3 font-semibold">Gladiator</h5>
          <p class="text-sm text-gray-500">Action, Adventure</p>
        </div>
      </div>

      <!-- Popular -->
      <div id="tab-popular" class="tab-content hidden grid grid-cols-1 sm:grid-cols-3 gap-6">
        <div>
          <img src="https://via.placeholder.com/300x200" class="rounded-lg w-full h-48 object-cover">
          <h5 class="mt-3 font-semibold">Inception</h5>
          <p class="text-sm text-gray-500">Sci-Fi, Thriller</p>
        </div>
        <div>
          <img src="https://via.placeholder.com/300x200" class="rounded-lg w-full h-48 object-cover">
          <h5 class="mt-3 font-semibold">Titanic</h5>
          <p class="text-sm text-gray-500">Romance, Drama</p>
        </div>
        <div>
          <img src="https://via.placeholder.com/300x200" class="rounded-lg w-full h-48 object-cover">
          <h5 class="mt-3 font-semibold">Avatar</h5>
          <p class="text-sm text-gray-500">Sci-Fi, Action</p>
        </div>
      </div>

      <!-- Latest -->
      <div id="tab-latest" class="tab-content hidden grid grid-cols-1 sm:grid-cols-3 gap-6">
        <div>
          <img src="https://via.placeholder.com/300x200" class="rounded-lg w-full h-48 object-cover">
          <h5 class="mt-3 font-semibold">Oppenheimer</h5>
          <p class="text-sm text-gray-500">Drama, History</p>
        </div>
        <div>
          <img src="https://via.placeholder.com/300x200" class="rounded-lg w-full h-48 object-cover">
          <h5 class="mt-3 font-semibold">Barbie</h5>
          <p class="text-sm text-gray-500">Comedy, Fantasy</p>
        </div>
        <div>
          <img src="https://via.placeholder.com/300x200" class="rounded-lg w-full h-48 object-cover">
          <h5 class="mt-3 font-semibold">John Wick 4</h5>
          <p class="text-sm text-gray-500">Action</p>
        </div>
      </div>
    </div>
  </div>
</section>

<script>
  const tabButtons = document.querySelectorAll(".tab-btn");
  const tabContents = document.querySelectorAll(".tab-content");

  tabButtons.forEach(btn => {
    btn.addEventListener("click", () => {
      const tab = btn.getAttribute("data-tab");

      // Reset buttons
      tabButtons.forEach(b => b.classList.remove("border-blue-600","text-blue-600","font-semibold"));
      btn.classList.add("border-blue-600","text-blue-600","font-semibold");

      // Show/Hide contents
      tabContents.forEach(content => {
        content.classList.add("hidden");
      });
      document.getElementById("tab-" + tab).classList.remove("hidden");
    });
  });
</script>
<section class="max-w-6xl mx-auto px-6 py-16">
  <!-- Title -->
  <div class="text-left mb-12">
    <h2 class="text-4xl font-bold mb-2">Born Today</h2>
    <p class="text-gray-600">Stay tuned for all the latest entertainment news and TV premiers</p>
  </div>

  <!-- Team Grid -->
  <div class="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-5 gap-6">
    <!-- Team Item -->
    <div class="group text-center">
      <div class="relative overflow-hidden rounded-lg">
        <img src="https://filmax.themerex.net/wp-content/uploads/2017/12/team-5-copyright-485x598.jpg" alt="Ryan Smith" class="w-full h-72 object-cover group-hover:scale-105 transition">
        <a href="https://filmax.themerex.net/team/ryan-smith/" class="absolute inset-0"></a>
      </div>
      <h4 class="mt-3 font-semibold"><a href="https://filmax.themerex.net/team/ryan-smith/" class="hover:text-blue-600">Ryan Smith</a></h4>
      <p class="text-gray-500">33 years</p>
    </div>

    <div class="group text-center">
      <div class="relative overflow-hidden rounded-lg">
        <img src="https://filmax.themerex.net/wp-content/uploads/2017/12/team-4-copyright-485x598.jpg" alt="Karen Brown" class="w-full h-72 object-cover group-hover:scale-105 transition">
        <a href="https://filmax.themerex.net/team/karen-brown/" class="absolute inset-0"></a>
      </div>
      <h4 class="mt-3 font-semibold"><a href="https://filmax.themerex.net/team/karen-brown/" class="hover:text-blue-600">Karen Brown</a></h4>
      <p class="text-gray-500">25 years</p>
    </div>

    <div class="group text-center">
      <div class="relative overflow-hidden rounded-lg">
        <img src="https://filmax.themerex.net/wp-content/uploads/2017/12/team-3-copyright-485x598.jpg" alt="Mark Lopez" class="w-full h-72 object-cover group-hover:scale-105 transition">
        <a href="https://filmax.themerex.net/team/mark-lopez/" class="absolute inset-0"></a>
      </div>
      <h4 class="mt-3 font-semibold"><a href="https://filmax.themerex.net/team/mark-lopez/" class="hover:text-blue-600">Mark Lopez</a></h4>
      <p class="text-gray-500">32 years</p>
    </div>

    <div class="group text-center">
      <div class="relative overflow-hidden rounded-lg">
        <img src="https://filmax.themerex.net/wp-content/uploads/2017/12/team-2-copyright-485x598.jpg" alt="Ann Summers" class="w-full h-72 object-cover group-hover:scale-105 transition">
        <a href="https://filmax.themerex.net/team/ann-summers/" class="absolute inset-0"></a>
      </div>
      <h4 class="mt-3 font-semibold"><a href="https://filmax.themerex.net/team/ann-summers/" class="hover:text-blue-600">Ann Summers</a></h4>
      <p class="text-gray-500">27 years</p>
    </div>

    <div class="group text-center">
      <div class="relative overflow-hidden rounded-lg">
        <img src="https://filmax.themerex.net/wp-content/uploads/2017/12/team-1-copyright-485x598.jpg" alt="Sid Johnson" class="w-full h-72 object-cover group-hover:scale-105 transition">
        <a href="https://filmax.themerex.net/team/sid-johnson/" class="absolute inset-0"></a>
      </div>
      <h4 class="mt-3 font-semibold"><a href="https://filmax.themerex.net/team/sid-johnson/" class="hover:text-blue-600">Sid Johnson</a></h4>
      <p class="text-gray-500">28 years</p>
    </div>
  </div>
</section>
<!-- Tailwind Coming Soon Section -->
<section class="bg-gray-900 text-white py-16 overflow-hidden">
  <div class="max-w-6xl mx-auto px-6">
    <!-- Section Header -->
    <header class="text-center mb-12">
      <h2 class="text-3xl font-bold">Coming Soon</h2>
    </header>

    <!-- Main Slides -->
    <div id="slides" class="relative">
      <!-- Slide 0 -->
      <div class="slide flex flex-col lg:flex-row gap-8 opacity-100 transition-all duration-500" data-index="0">
        <div class="relative lg:w-1/2">
          <div class="absolute inset-0 bg-cover bg-center brightness-50" style="background-image: url('https://xenothemes.co.uk/specto/wp-content/uploads/sites/2/2017/07/hero-news.jpg');"></div>
          <div class="relative z-10 p-6 lg:p-12 flex flex-col gap-4">
            <span class="text-orange-400 font-semibold">Fantasy, Sci-fi, Action</span>
            <h3 class="text-2xl lg:text-4xl font-bold">Colliding Planets</h3>
            <div class="flex gap-1 text-yellow-400">
              <i class="fa fa-star"></i>
              <i class="fa fa-star"></i>
              <i class="fa fa-star"></i>
              <i class="fa fa-star"></i>
              <i class="fa fa-star"></i>
            </div>
            <div class="flex items-center gap-2 text-gray-300">
              <i class="fa fa-calendar-o"></i>
              <span>2 October, 2019</span>
            </div>
            <p class="text-gray-200">Claritas est etiam processus dynamicus, qui sequitur mutationem consuetudium lectorum...</p>
            <a href="https://xenothemes.co.uk/specto/movies/colliding-planets/" class="mt-4 inline-block bg-orange-500 hover:bg-orange-600 text-white px-4 py-2 rounded">More Info</a>
          </div>
        </div>
        <div class="lg:w-1/2 flex justify-center items-center">
          <a href="https://youtu.be/d96cjJhvlMA" class="relative group">
            <img src="https://xenothemes.co.uk/specto/wp-content/uploads/sites/2/2017/11/trailer-1-555x335.png" alt="Colliding Planets" class="rounded shadow-lg">
            <i class="fa fa-play absolute inset-0 m-auto text-4xl text-white opacity-80 group-hover:opacity-100"></i>
          </a>
        </div>
      </div>

      <!-- Slide 1 -->
      <div class="slide flex flex-col lg:flex-row gap-8 opacity-0 h-0 overflow-hidden transition-all duration-500" data-index="1">
        <div class="relative lg:w-1/2">
          <div class="absolute inset-0 bg-cover bg-center brightness-50" style="background-image: url('https://xenothemes.co.uk/specto/wp-content/uploads/sites/2/2017/07/hero-single-movie.jpg');"></div>
          <div class="relative z-10 p-6 lg:p-12 flex flex-col gap-4">
            <span class="text-orange-400 font-semibold">Thriller, Horror</span>
            <h3 class="text-2xl lg:text-4xl font-bold">Infinite Vengeance</h3>
            <div class="flex gap-1 text-yellow-400">
              <i class="fa fa-star"></i>
              <i class="fa fa-star"></i>
              <i class="fa fa-star"></i>
              <i class="fa fa-star"></i>
              <i class="fa fa-star text-gray-500"></i>
            </div>
            <div class="flex items-center gap-2 text-gray-300">
              <i class="fa fa-calendar-o"></i>
              <span>17 August, 2017</span>
            </div>
            <p class="text-gray-200">Claritas est etiam processus dynamicus, qui sequitur mutationem consuetudium lectorum...</p>
            <a href="https://xenothemes.co.uk/specto/movies/infinite-vengeance/" class="mt-4 inline-block bg-orange-500 hover:bg-orange-600 text-white px-4 py-2 rounded">More Info</a>
          </div>
        </div>
        <div class="lg:w-1/2 flex justify-center items-center">
          <a href="https://youtu.be/d96cjJhvlMA" class="relative group">
            <img src="https://xenothemes.co.uk/specto/wp-content/uploads/sites/2/2017/07/slide-1-video-555x335.png" alt="Infinite Vengeance" class="rounded shadow-lg">
            <i class="fa fa-play absolute inset-0 m-auto text-4xl text-white opacity-80 group-hover:opacity-100"></i>
          </a>
        </div>
      </div>

      <!-- Add more slides similarly -->
    </div>

    <!-- Thumbnails -->
    <div class="flex gap-4 mt-12 overflow-x-auto" id="thumbnails">
      <div class="thumbnail cursor-pointer opacity-100" data-index="0">
        <img src="https://xenothemes.co.uk/specto/wp-content/uploads/sites/2/2017/07/movie-14.jpg" alt="Colliding Planets" class="w-32 rounded shadow-lg">
        <h5 class="text-sm mt-1">Colliding Planets</h5>
        <span class="text-gray-400 text-xs">2 October, 2019</span>
      </div>
      <div class="thumbnail cursor-pointer opacity-50" data-index="1">
        <img src="https://xenothemes.co.uk/specto/wp-content/uploads/sites/2/2017/07/movie-12.jpg" alt="Infinite Vengeance" class="w-32 rounded shadow-lg">
        <h5 class="text-sm mt-1">Infinite Vengeance</h5>
        <span class="text-gray-400 text-xs">17 August, 2017</span>
      </div>
      <!-- Add more thumbnails -->
    </div>
  </div>
</section>

<!-- Tailwind + JS -->
<script>
const slides = document.querySelectorAll('.slide');
const thumbnails = document.querySelectorAll('.thumbnail');

thumbnails.forEach(thumb => {
  thumb.addEventListener('click', () => {
    const index = thumb.getAttribute('data-index');

    slides.forEach(slide => {
      if(slide.getAttribute('data-index') === index) {
        slide.classList.remove('opacity-0', 'h-0');
        slide.classList.add('opacity-100');
      } else {
        slide.classList.add('opacity-0', 'h-0');
        slide.classList.remove('opacity-100');
      }
    });

    thumbnails.forEach(t => t.classList.remove('opacity-100'));
    thumb.classList.add('opacity-100');
  });
});
</script>
<section class="py-12 px-4 md:px-8">
    <div class="container mx-auto">
        <h1 class="text-3xl md:text-4xl font-bold text-center mb-2 text-gray-800">Movie Schedule</h1>
        <p class="text-center text-gray-600 mb-10">Check showtimes for your favorite movies</p>
        
        <!-- Tabs Navigation -->
        <div class="bg-white rounded-lg shadow-md overflow-hidden mb-8">
            <div class="flex flex-wrap border-b border-gray-200">
                <button class="tab-btn px-4 py-3 font-medium text-gray-600 hover:bg-gray-50 transition-colors" data-tab="mon">Mon</button>
                <button class="tab-btn px-4 py-3 font-medium text-gray-600 hover:bg-gray-50 transition-colors" data-tab="tue">Tue</button>
                <button class="tab-btn px-4 py-3 font-medium text-gray-600 hover:bg-gray-50 transition-colors" data-tab="wed">Wed</button>
                <button class="tab-btn px-4 py-3 font-medium text-gray-600 hover:bg-gray-50 transition-colors" data-tab="thu">Thu</button>
                <button class="tab-btn px-4 py-3 font-medium text-gray-600 hover:bg-gray-50 transition-colors" data-tab="fri">Fri</button>
                <button class="tab-btn px-4 py-3 font-medium text-gray-600 hover:bg-gray-50 transition-colors" data-tab="sat">Sat</button>
                <button class="tab-btn px-4 py-3 font-medium text-gray-600 hover:bg-gray-50 transition-colors" data-tab="sun">Sun</button>
          <div class="ml-auto px-4 py-3 font-medium text-gray-800 md:block" id="today-date">
    <!-- Date will be set by JS -->
</div>
            </div>
            
            <!-- Tab Content -->
            <div class="p-4">
                
                <!-- Monday -->
                <div class="tab-content hidden" id="mon-content">
                    <div class="movie-card bg-white overflow-hidden mb-6">
                        <div class="md:flex">
                            <div class="md:w-1/4 p-4">
                                <img src="https://xenothemes.co.uk/specto/wp-content/uploads/sites/2/2017/11/thumb2-270x340.jpg" alt="Mon Movie 1" class="w-full h-auto rounded-lg">
                            </div>
                            <div class="md:w-3/4 p-4">
                                <span class="text-sm text-gray-500">Action, Adventure</span>
                                <h3 class="text-xl font-bold mt-1 mb-2">Mon Movie 1</h3>
                                <p class="text-gray-700 mb-4">Exciting Monday movie description...</p>
                                <a href="#" class="inline-flex items-center text-red-600 font-medium hover:text-red-800 transition-colors">
                                    Full synopsis <i class="fas fa-arrow-right ml-2"></i>
                                </a>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Tuesday -->
                <div class="tab-content hidden" id="tue-content">
                    <div class="movie-card bg-white overflow-hidden mb-6">
                        <div class="md:flex">
                            <div class="md:w-1/4 p-4">
                                <img src="https://xenothemes.co.uk/specto/wp-content/uploads/sites/2/2017/11/thumb1-270x340.jpg" alt="Tue Movie 1" class="w-full h-auto rounded-lg">
                            </div>
                            <div class="md:w-3/4 p-4">
                                <span class="text-sm text-gray-500">Drama, Thriller</span>
                                <h3 class="text-xl font-bold mt-1 mb-2">Tue Movie 1</h3>
                                <p class="text-gray-700 mb-4">Exciting Tuesday movie description...</p>
                                <a href="#" class="inline-flex items-center text-red-600 font-medium hover:text-red-800 transition-colors">
                                    Full synopsis <i class="fas fa-arrow-right ml-2"></i>
                                </a>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Wednesday (Today) -->
                <div class="tab-content" id="wed-content">
                    <div class="movie-card bg-white overflow-hidden mb-6">
                        <div class="md:flex">
                            <div class="md:w-1/4 p-4">
                                <img src="https://xenothemes.co.uk/specto/wp-content/uploads/sites/2/2017/11/thumb2-270x340.jpg" alt="Locked in" class="w-full h-auto rounded-lg">
                            </div>
                            <div class="md:w-3/4 p-4">
                                <span class="text-sm text-gray-500">Thriller, Horror</span>
                                <h3 class="text-xl font-bold mt-1 mb-2">Locked in</h3>
                                <p class="text-gray-700 mb-4">Claritas est etiam processus dynamicus...</p>
                                <a href="#" class="inline-flex items-center text-red-600 font-medium hover:text-red-800 transition-colors">
                                    Full synopsis <i class="fas fa-arrow-right ml-2"></i>
                                </a>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Thursday -->
                <div class="tab-content hidden" id="thu-content">
                    <div class="movie-card bg-white overflow-hidden mb-6">
                        <div class="md:flex">
                            <div class="md:w-1/4 p-4">
                                <img src="https://xenothemes.co.uk/specto/wp-content/uploads/sites/2/2017/07/movie-7-270x340.jpg" alt="Thu Movie 1" class="w-full h-auto rounded-lg">
                            </div>
                            <div class="md:w-3/4 p-4">
                                <span class="text-sm text-gray-500">Comedy, Family</span>
                                <h3 class="text-xl font-bold mt-1 mb-2">Thu Movie 1</h3>
                                <p class="text-gray-700 mb-4">Exciting Thursday movie description...</p>
                                <a href="#" class="inline-flex items-center text-red-600 font-medium hover:text-red-800 transition-colors">
                                    Full synopsis <i class="fas fa-arrow-right ml-2"></i>
                                </a>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Friday -->
                <div class="tab-content hidden" id="fri-content">
                    <div class="movie-card bg-white overflow-hidden mb-6">
                        <div class="md:flex">
                            <div class="md:w-1/4 p-4">
                                <img src="https://xenothemes.co.uk/specto/wp-content/uploads/sites/2/2017/11/thumb1-270x340.jpg" alt="Fri Movie 1" class="w-full h-auto rounded-lg">
                            </div>
                            <div class="md:w-3/4 p-4">
                                <span class="text-sm text-gray-500">Adventure, Action</span>
                                <h3 class="text-xl font-bold mt-1 mb-2">Fri Movie 1</h3>
                                <p class="text-gray-700 mb-4">Exciting Friday movie description...</p>
                                <a href="#" class="inline-flex items-center text-red-600 font-medium hover:text-red-800 transition-colors">
                                    Full synopsis <i class="fas fa-arrow-right ml-2"></i>
                                </a>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Saturday -->
                <div class="tab-content hidden" id="sat-content">
                    <div class="movie-card bg-white overflow-hidden mb-6">
                        <div class="md:flex">
                            <div class="md:w-1/4 p-4">
                                <img src="https://xenothemes.co.uk/specto/wp-content/uploads/sites/2/2017/07/movie-7-270x340.jpg" alt="Sat Movie 1" class="w-full h-auto rounded-lg">
                            </div>
                            <div class="md:w-3/4 p-4">
                                <span class="text-sm text-gray-500">Horror, Thriller</span>
                                <h3 class="text-xl font-bold mt-1 mb-2">Sat Movie 1</h3>
                                <p class="text-gray-700 mb-4">Exciting Saturday movie description...</p>
                                <a href="#" class="inline-flex items-center text-red-600 font-medium hover:text-red-800 transition-colors">
                                    Full synopsis <i class="fas fa-arrow-right ml-2"></i>
                                </a>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Sunday -->
                <div class="tab-content hidden" id="sun-content">
                    <div class="movie-card bg-white  overflow-hidden mb-6">
                        <div class="md:flex">
                            <div class="md:w-1/4 p-4">
                                <img src="https://xenothemes.co.uk/specto/wp-content/uploads/sites/2/2017/11/thumb2-270x340.jpg" alt="Sun Movie 1" class="w-full h-auto rounded-lg">
                            </div>
                            <div class="md:w-3/4 p-4">
                                <span class="text-sm text-gray-500">Action, Thriller</span>
                                <h3 class="text-xl font-bold mt-1 mb-2">Sun Movie 1</h3>
                                <p class="text-gray-700 mb-4">Exciting Sunday movie description...</p>
                                <a href="#" class="inline-flex items-center text-red-600 font-medium hover:text-red-800 transition-colors">
                                    Full synopsis <i class="fas fa-arrow-right ml-2"></i>
                                </a>
                            </div>
                        </div>
                    </div>
                </div>

            </div>
        </div>
    </div>
</section>

<script>
document.addEventListener('DOMContentLoaded', function() {
    const tabButtons = document.querySelectorAll('.tab-btn');
    const tabContents = document.querySelectorAll('.tab-content');

    tabButtons.forEach(button => {
        button.addEventListener('click', () => {
            // Remove active classes
            tabButtons.forEach(btn => btn.classList.remove('active', 'text-red-600', 'border-b-2', 'border-red-600'));
            tabContents.forEach(content => content.classList.add('hidden')); // hide all

            // Activate clicked button
            button.classList.add('active', 'text-red-600', 'border-b-2', 'border-red-600');

            // Show corresponding content
            const tabId = button.getAttribute('data-tab') + '-content';
            document.getElementById(tabId).classList.remove('hidden');
        });
    });

    // Set initial active state
    document.querySelector('.tab-btn[data-tab="wed"]').classList.add('active', 'text-red-600', 'border-b-2', 'border-red-600');
    document.getElementById('wed-content').classList.remove('hidden');
});
</script>

<script>
document.addEventListener('DOMContentLoaded', function() {
    const tabButtons = document.querySelectorAll('.tab-btn');
    const tabContents = document.querySelectorAll('.tab-content');
    const todayDateElem = document.getElementById('today-date');

    // Days and months
    const dayMap = ['sun','mon','tue','wed','thu','fri','sat'];
    const monthNames = ["January","February","March","April","May","June",
      "July","August","September","October","November","December"];

    const today = new Date();
    const todayDay = dayMap[today.getDay()]; // 'mon', 'tue', ...
    const todayMonth = monthNames[today.getMonth()]; // 'October', etc
    const todayDateNum = today.getDate(); // 1-31

    // Set the date text (capitalized day)
    todayDateElem.textContent = `${todayDay.charAt(0).toUpperCase() + todayDay.slice(1)}, ${todayDateNum} ${todayMonth}`;

    // Tab click logic
    tabButtons.forEach(button => {
        button.addEventListener('click', () => {
            tabButtons.forEach(btn => btn.classList.remove('active', 'text-red-600', 'border-b-2', 'border-red-600'));
            tabContents.forEach(content => content.classList.add('hidden'));

            button.classList.add('active', 'text-red-600', 'border-b-2', 'border-red-600');

            const tabId = button.getAttribute('data-tab') + '-content';
            const content = document.getElementById(tabId);
            if(content) content.classList.remove('hidden');
        });
    });

    // Set initial tab to today
    const todayButton = document.querySelector(`.tab-btn[data-tab="${todayDay}"]`);
    if(todayButton) {
        todayButton.classList.add('active', 'text-red-600', 'border-b-2', 'border-red-600');
        const todayContent = document.getElementById(`${todayDay}-content`);
        if(todayContent) todayContent.classList.remove('hidden');
    }
});
</script>

<jsp:include page="layout/footer.jsp" />
<jsp:include page="layout/JSPFooter.jsp" />
