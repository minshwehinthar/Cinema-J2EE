
<jsp:include page="layout/JSPHeader.jsp"/>
<jsp:include page="layout/header.jsp"/>



<%
    // Defaults (can be overridden by servlet/controller)
    String reviewScore = (String) request.getAttribute("reviewScore");
    if (reviewScore == null) reviewScore = "4.97/5 reviews";

    String heroTitle = (String) request.getAttribute("heroTitle");
    if (heroTitle == null) heroTitle = "Discover our journey and what drives us";

    String heroDesc = (String) request.getAttribute("heroDescription");
    if (heroDesc == null) heroDesc = "Founded by data experts, we create cutting-edge SaaS analytics platforms tailored for businesses of all sizes.";

    String heroImage = (String) request.getAttribute("heroImage");
    if (heroImage == null) heroImage = "https://cdn.prod.website-files.com/67721265f59069a5268af325/67853b886028916a22239cbc_about%20hero%203nd%20image.webp";

    Object userObj = session.getAttribute("user");
    String ctaHref = (userObj == null) ? request.getContextPath() + "/account/sign-in" : request.getContextPath() + "/dashboard";
%>

<jsp:include page="layout/JSPHeader.jsp"/>

<section class="relative bg-gray-50 py-16">
  <div class="mx-auto max-w-7xl px-6 lg:px-8 grid grid-cols-1 lg:grid-cols-2 gap-12 items-center">

    <!-- Left Content -->
    <div class="space-y-6">
      <!-- Reviews -->
      <div class="flex items-center gap-3">
        <div class="flex text-yellow-400">
          <svg xmlns="http://www.w3.org/2000/svg" class="w-5 h-5 fill-current" viewBox="0 0 20 20"><path d="M10 15l-5.878 3.09 1.122-6.545L.488 6.91l6.564-.955L10 0l2.948 5.955 6.564.955-4.756 4.635 1.122 6.545z"/></svg>
          <svg xmlns="http://www.w3.org/2000/svg" class="w-5 h-5 fill-current" viewBox="0 0 20 20"><path d="M10 15l-5.878 3.09 1.122-6.545L.488 6.91l6.564-.955L10 0l2.948 5.955 6.564.955-4.756 4.635 1.122 6.545z"/></svg>
          <svg xmlns="http://www.w3.org/2000/svg" class="w-5 h-5 fill-current" viewBox="0 0 20 20"><path d="M10 15l-5.878 3.09 1.122-6.545L.488 6.91l6.564-.955L10 0l2.948 5.955 6.564.955-4.756 4.635 1.122 6.545z"/></svg>
          <svg xmlns="http://www.w3.org/2000/svg" class="w-5 h-5 fill-current" viewBox="0 0 20 20"><path d="M10 15l-5.878 3.09 1.122-6.545L.488 6.91l6.564-.955L10 0l2.948 5.955 6.564.955-4.756 4.635 1.122 6.545z"/></svg>
          <svg xmlns="http://www.w3.org/2000/svg" class="w-5 h-5 fill-current" viewBox="0 0 20 20"><path d="M10 15l-5.878 3.09 1.122-6.545L.488 6.91l6.564-.955L10 0l2.948 5.955 6.564.955-4.756 4.635 1.122 6.545z"/></svg>
        </div>
        <span class="text-gray-600 text-lg font-medium"><%= reviewScore %></span>
      </div>

      <!-- Title -->
      <h1 class="text-4xl lg:text-5xl font-bold text-gray-900 leading-tight">
        <%= heroTitle %>
      </h1>

      <!-- Description -->
      <p class="text-lg text-gray-600 max-w-xl">
        <%= heroDesc %>
      </p>

      <!-- Buttons -->
      <div class="flex gap-4 pt-4">
        <a href="<%= ctaHref %>" 
           class="inline-flex items-center px-6 py-3 rounded-xl bg-blue-600 text-white font-semibold shadow hover:bg-blue-700 transition">
          Get Started
          <svg xmlns="http://www.w3.org/2000/svg" class="ml-2 h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7"/>
          </svg>
        </a>
        <a href="${pageContext.request.contextPath}/account/sign-in"
           class="inline-flex items-center px-6 py-3 rounded-xl border border-gray-300 bg-white text-gray-800 font-semibold shadow hover:bg-gray-100 transition">
          Free Trial
        </a>
      </div>
    </div>

    <!-- Right Image -->
    <div class="flex justify-center lg:justify-end">
      <img src="<%= heroImage %>" alt="About Hero" class="rounded-2xl shadow-xl max-w-lg w-full object-cover"/>
    </div>

  </div>
</section>

<%
    // Metrics data (could also come from database or servlet)
    class Metric {
        String value, title, desc;
        Metric(String v, String t, String d) { value=v; title=t; desc=d; }
    }

    java.util.List<Metric> metrics = new java.util.ArrayList<>();
    metrics.add(new Metric("95%", "Customer satisfaction", "Trusted by millions, our service ensures unparalleled customer satisfaction with dedicated support and innovative solutions tailored to your needs."));
    metrics.add(new Metric("10+", "Innovation & insight", "Driving over a decade of groundbreaking innovations and deep industry insights to empower businesses worldwide."));
    metrics.add(new Metric("$10m", "Efficient financial", "Streamlined processes delivering over $10 million in financial savings and value creation for our clients."));
    metrics.add(new Metric("50m", "Users worldwide", "Serving a global community of over 50 million users, delivering impactful and reliable solutions every day."));

    String metricsImage = "https://cdn.prod.website-files.com/67721265f59069a5268af325/67852df879198be1be0c7adc_intro%20image.webp";
%>

<section class="bg-white py-20">
  <div class="mx-auto max-w-7xl px-6 lg:px-8 grid grid-cols-1 lg:grid-cols-2 gap-16 items-center">

    <!-- Left Image -->
    <div class="flex justify-center lg:justify-start">
      <img src="<%= metricsImage %>" alt="Metrics" class="rounded-2xl shadow-xl max-w-md w-full object-cover"/>
    </div>

    <!-- Right Metrics -->
    <div class="grid grid-cols-1 sm:grid-cols-2 gap-10">
      <%
        for(Metric m : metrics) {
      %>
        <div class="bg-gray-50 rounded-xl p-6 shadow hover:shadow-lg transition">
          <div class="text-4xl font-bold text-blue-600"><%= m.value %></div>
          <h3 class="text-lg font-semibold text-gray-900 mt-2"><%= m.title %></h3>
          <p class="text-sm text-gray-600 mt-3"><%= m.desc %></p>
        </div>
      <%
        }
      %>
    </div>

  </div>
</section>

<section class="bg-white py-20">
  <div class="max-w-7xl mx-auto px-6 lg:px-8">
    
    <!-- Header -->
    <div class="text-center max-w-3xl mx-auto mb-16">
      <h2 class="text-3xl md:text-5xl font-bold text-gray-900">
        Core features that set us apart from the competition
      </h2>
      <p class="mt-4 text-lg text-gray-600">
        Explore our standout features designed to deliver exceptional performance 
        and value, distinguishing us from the competition.
      </p>
    </div>

    <!-- Features Grid -->
    <div class="grid grid-cols-1 lg:grid-cols-3 gap-12 items-start">
      
      <!-- Features List -->
      <div class="lg:col-span-2 grid grid-cols-1 sm:grid-cols-2 gap-8">
        
        <!-- Feature Card -->
        <div class="flex gap-4 p-6 bg-gray-50 rounded-xl shadow-sm hover:shadow-md transition">
          <div class="flex-shrink-0 text-blue-600 text-3xl">
            <!-- Heroicon or custom SVG -->
            <svg xmlns="http://www.w3.org/2000/svg" class="w-8 h-8" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path d="M3 20h18M4 10h16M7 6h10M9 14h6" />
            </svg>
          </div>
          <div>
            <h3 class="text-xl font-semibold text-gray-900">Real-time analytics</h3>
            <p class="mt-2 text-sm text-gray-600">
              Gain actionable insights with our real-time analytics feature.
            </p>
          </div>
        </div>

        <!-- Feature Card -->
        <div class="flex gap-4 p-6 bg-gray-50 rounded-xl shadow-sm hover:shadow-md transition">
          <div class="flex-shrink-0 text-blue-600 text-3xl">
            <svg xmlns="http://www.w3.org/2000/svg" class="w-8 h-8" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path d="M12 4.354a4 4 0 110 7.292 4 4 0 010-7.292zM12 12v8m-6 0h12" />
            </svg>
          </div>
          <div>
            <h3 class="text-xl font-semibold text-gray-900">Mobile accessibility</h3>
            <p class="mt-2 text-sm text-gray-600">
              Manage your finances on the go with our mobile-friendly platform.
            </p>
          </div>
        </div>

        <!-- Feature Card -->
        <div class="flex gap-4 p-6 bg-gray-50 rounded-xl shadow-sm hover:shadow-md transition">
          <div class="flex-shrink-0 text-blue-600 text-3xl">
            <svg xmlns="http://www.w3.org/2000/svg" class="w-8 h-8" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path d="M4 6h16M4 12h16M4 18h16" />
            </svg>
          </div>
          <div>
            <h3 class="text-xl font-semibold text-gray-900">Customizable reports</h3>
            <p class="mt-2 text-sm text-gray-600">
              Streamline your financial processes with automated workflows.
            </p>
          </div>
        </div>

        <!-- Feature Card -->
        <div class="flex gap-4 p-6 bg-gray-50 rounded-xl shadow-sm hover:shadow-md transition">
          <div class="flex-shrink-0 text-blue-600 text-3xl">
            <svg xmlns="http://www.w3.org/2000/svg" class="w-8 h-8" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path d="M12 11c.828 0 1.5-.895 1.5-2s-.672-2-1.5-2-1.5.895-1.5 2 .672 2 1.5 2zM12 13c-2.5 0-4.5 2.015-4.5 4.5V20h9v-2.5c0-2.485-2-4.5-4.5-4.5z" />
            </svg>
          </div>
          <div>
            <h3 class="text-xl font-semibold text-gray-900">Enhanced security</h3>
            <p class="mt-2 text-sm text-gray-600">
              Protect your sensitive financial data with state-of-the-art security measures.
            </p>
          </div>
        </div>
      </div>

      <!-- Feature Image -->
      <div class="flex justify-center lg:justify-end">
        <img 
          src="https://cdn.prod.website-files.com/67721265f59069a5268af325/677810b4186dbf1f9240a1b5_features%20image.webp" 
          alt="Features illustration"
          class="rounded-2xl shadow-xl max-w-sm lg:max-w-md"
        />
      </div>

    </div>
  </div>
</section>
<section class="bg-white py-20">
  <div class="max-w-7xl mx-auto px-6 lg:px-8">
    <!-- Header -->
    <div class="text-center mb-16">
      <h2 class="text-4xl md:text-5xl font-bold text-gray-900">
        Meet the Financer Team
      </h2>
      <p class="mt-4 text-lg text-gray-600 max-w-2xl mx-auto">
        The people behind our innovation, strategy, and growth.
      </p>
    </div>

    <!-- Team Grid -->
    <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-12">
      
      <!-- Team Member -->
      <div class="bg-gray-50 rounded-xl shadow hover:shadow-lg transition overflow-hidden">
        <img class="w-full h-64 object-cover" src="https://cdn.prod.website-files.com/67721265f59069a5268af325/677ab035617aa1aeef37af80_team%20image%201.webp" alt="Amara Okafor">
        <div class="p-6 text-center">
          <h3 class="text-xl font-semibold text-gray-900">Amara Okafor</h3>
          <p class="text-gray-600 text-sm mt-1">Head of Marketing</p>
          <a href="https://www.temlis.com/" target="_blank" class="inline-block mt-3 text-blue-600 hover:text-blue-800">
            <img src="https://cdn.prod.website-files.com/67721265f59069a5268af325/677ab4ee0e69e77797d0b49f_linkedin%20icon.svg" alt="LinkedIn" class="w-6 h-6 inline-block">
          </a>
        </div>
      </div>

      <!-- Team Member -->
      <div class="bg-gray-50 rounded-xl shadow hover:shadow-lg transition overflow-hidden">
        <img class="w-full h-64 object-cover" src="https://cdn.prod.website-files.com/67721265f59069a5268af325/677ab035115e12eff602a83f_team%20image%202.webp" alt="Jakob George">
        <div class="p-6 text-center">
          <h3 class="text-xl font-semibold text-gray-900">Jakob George</h3>
          <p class="text-gray-600 text-sm mt-1">Head of Finance</p>
          <a href="https://www.temlis.com/" target="_blank" class="inline-block mt-3 text-blue-600 hover:text-blue-800">
            <img src="https://cdn.prod.website-files.com/67721265f59069a5268af325/677ab4ee0e69e77797d0b49f_linkedin%20icon.svg" alt="LinkedIn" class="w-6 h-6 inline-block">
          </a>
        </div>
      </div>

      <!-- Team Member -->
      <div class="bg-gray-50 rounded-xl shadow hover:shadow-lg transition overflow-hidden">
        <img class="w-full h-64 object-cover" src="https://cdn.prod.website-files.com/67721265f59069a5268af325/677ab035afc0ef4f9d9683e6_team%20image%203.webp" alt="Leila Khatami">
        <div class="p-6 text-center">
          <h3 class="text-xl font-semibold text-gray-900">Leila Khatami</h3>
          <p class="text-gray-600 text-sm mt-1">Accountant</p>
          <a href="https://www.temlis.com/" target="_blank" class="inline-block mt-3 text-blue-600 hover:text-blue-800">
            <img src="https://cdn.prod.website-files.com/67721265f59069a5268af325/677ab4ee0e69e77797d0b49f_linkedin%20icon.svg" alt="LinkedIn" class="w-6 h-6 inline-block">
          </a>
        </div>
      </div>

      <!-- More team members can be added the same way -->
      
    </div>
  </div>
</section>
<section class="bg-gray-50 py-20">
  <div class="max-w-7xl mx-auto px-6 lg:px-8">
    
    <!-- Header -->
    <div class="text-center max-w-2xl mx-auto mb-12">
      <h2 class="text-4xl md:text-5xl font-bold text-gray-900">
        What Our Clients Are Saying
      </h2>
      <p class="mt-4 text-lg text-gray-600">
        Our users love how Advisora simplifies their processes and streamlines operations.
      </p>
    </div>

    <!-- Testimonials Grid -->
    <div class="grid gap-8 sm:grid-cols-2 lg:grid-cols-3">
      
      <!-- Card -->
      <div class="bg-white rounded-2xl shadow p-6 flex flex-col justify-between">
        <p class="text-gray-600 text-lg">
          “Advisora has completely transformed the way I manage my finances. With its intuitive interface and powerful features, I now have better control and visibility into my expenses and investments. Highly recommend it!”
        </p>
        <div class="flex items-center mt-6">
          <img src="https://cdn.prod.website-files.com/67721265f59069a5268af325/67785a398d421f0cd02666a8_testimonials%20user%201.webp" alt="User" class="w-12 h-12 rounded-full object-cover">
          <div class="ml-4">
            <h3 class="text-lg font-semibold text-gray-900">William Parker</h3>
            <p class="text-sm text-gray-500">CFO at BrightPath</p>
          </div>
        </div>
      </div>

      <!-- Card -->
      <div class="bg-white rounded-2xl shadow p-6 flex flex-col justify-between">
        <p class="text-gray-600 text-lg">
          “I've been using Advisora for years now, and I can't imagine managing my finances without it. From tracking expenses to creating budgets, Advisora has simplified every aspect of my financial life.”
        </p>
        <div class="flex items-center mt-6">
          <img src="https://cdn.prod.website-files.com/67721265f59069a5268af325/67785a39ab3a84e8587a7acd_testimonials%20user%202.webp" alt="User" class="w-12 h-12 rounded-full object-cover">
          <div class="ml-4">
            <h3 class="text-lg font-semibold text-gray-900">Michael Carter</h3>
            <p class="text-sm text-gray-500">Freelance Web Developer</p>
          </div>
        </div>
      </div>

      <!-- Card -->
      <div class="bg-white rounded-2xl shadow p-6 flex flex-col justify-between">
        <p class="text-gray-600 text-lg">
          “Advisora has been a game-changer for our business. With its comprehensive financial management tools, we've been able to streamline processes and make more informed decisions. The support team is also top-notch.”
        </p>
        <div class="flex items-center mt-6">
          <img src="https://cdn.prod.website-files.com/67721265f59069a5268af325/67785a3937e2049e3aa1ef9a_testimonials%20user%203.webp" alt="User" class="w-12 h-12 rounded-full object-cover">
          <div class="ml-4">
            <h3 class="text-lg font-semibold text-gray-900">John Spencer</h3>
            <p class="text-sm text-gray-500">Manager at GlobeSync</p>
          </div>
        </div>
      </div>

      <!-- Add more cards if needed... -->
      
    </div>
  </div>
</section>
<section class="py-16 bg-gray-50">
  <div class="max-w-7xl mx-auto px-6 lg:px-8">
    
    <!-- Header -->
    <div class="text-center max-w-2xl mx-auto mb-12">
      <h2 class="text-4xl font-bold tracking-tight text-gray-900 sm:text-5xl">
        Discover the latest blogs
      </h2>
      <p class="mt-4 text-lg text-gray-600">
        Stay informed with the latest health and wellness insights from our experts.
      </p>
    </div>

    <!-- Blog Grid -->
    <div class="grid gap-8 sm:grid-cols-2 lg:grid-cols-3">
      
      <!-- Blog Card -->
      <a href="#" class="group block rounded-2xl overflow-hidden shadow-sm hover:shadow-lg transition duration-300 bg-white">
        <div class="aspect-w-16 aspect-h-9">
          <img 
            src="https://cdn.prod.website-files.com/67721265f59069a5268af347/6778668556a2e86e20b6112b_blog%20thumbnail.webp"
            alt="Blog thumbnail"
            class="w-full h-full object-cover group-hover:scale-105 transition-transform duration-500"
          >
        </div>
        <div class="p-6">
          <h3 class="text-xl font-semibold text-gray-900 group-hover:text-indigo-600">
            The Ultimate Guide to Budgeting in 2024
          </h3>
          <p class="mt-3 text-gray-600 text-sm">
            Master the art of budgeting with our comprehensive guide. Learn how to create a budget that works for you, optimize your spending, and achieve your financial goals this year.
          </p>
        </div>
      </a>

      <!-- Blog Card -->
      <a href="#" class="group block rounded-2xl overflow-hidden shadow-sm hover:shadow-lg transition duration-300 bg-white">
        <div class="aspect-w-16 aspect-h-9">
          <img 
            src="https://cdn.prod.website-files.com/67721265f59069a5268af347/6778693054f080d2a033ad01_blog%20thumbnail.webp"
            alt="Blog thumbnail"
            class="w-full h-full object-cover group-hover:scale-105 transition-transform duration-500"
          >
        </div>
        <div class="p-6">
          <h3 class="text-xl font-semibold text-gray-900 group-hover:text-indigo-600">
            Top Investment Strategies for Long-Term Growth
          </h3>
          <p class="mt-3 text-gray-600 text-sm">
            Discover the best investment strategies to build and sustain your wealth over time. From stocks to bonds.
          </p>
        </div>
      </a>

      <!-- Blog Card -->
      <a href="#" class="group block rounded-2xl overflow-hidden shadow-sm hover:shadow-lg transition duration-300 bg-white">
        <div class="aspect-w-16 aspect-h-9">
          <img 
            src="https://cdn.prod.website-files.com/67721265f59069a5268af347/677869f58437826b2f3372d6_blog%20thumbnail.webp"
            alt="Blog thumbnail"
            class="w-full h-full object-cover group-hover:scale-105 transition-transform duration-500"
          >
        </div>
        <div class="p-6">
          <h3 class="text-xl font-semibold text-gray-900 group-hover:text-indigo-600">
            Understanding Cryptocurrency: What You Need to Know
          </h3>
          <p class="mt-3 text-gray-600 text-sm">
            Cryptocurrency continues to make headlines, but what does it mean for your finances? Get a clear understanding of the risks.
          </p>
        </div>
      </a>

    </div>

    <!-- Button -->
    <div class="mt-12 text-center">
      <a href="/blog" 
         class="inline-flex items-center gap-2 px-6 py-3 rounded-full text-white bg-indigo-600 hover:bg-indigo-700 transition duration-300 shadow-md">
        See More
        <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7"/>
        </svg>
      </a>
    </div>

  </div>
</section>

	<jsp:include page="layout/footer.jsp"/>
	<jsp:include page="layout/JSPFooter.jsp"/>
