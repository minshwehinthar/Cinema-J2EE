<jsp:include page="layout/JSPHeader.jsp" />
<jsp:include page="layout/header.jsp" />

<section class="relative w-full h-[300px]">
  <div class="absolute inset-0 bg-cover bg-center" style="background-image: url('assets/img/faqcinema.jpg');"></div>


  <!-- Overlay -->
  <div class="absolute inset-0 bg-black/30"></div>

  <div class="relative max-w-6xl mx-auto px-6 py-24 text-center">
    <!-- Breadcrumbs -->
    <nav class="text-sm text-gray-200 mb-4" aria-label="Breadcrumb">
      <ol class="inline-flex items-center space-x-2">
        <li>
          <a href="home.jsp" class="hover:text-white">Home</a>
          <span class="mx-2 text-gray-300">/</span>
        </li>
        <li class="text-gray-300" aria-current="page">Our Faqs</li>
      </ol>
    </nav>

    <!-- Page Title -->
    <h1 class="text-4xl md:text-5xl font-bold text-white">Our Faqs</h1>
  </div>
</section>

<section class="max-w-6xl mx-auto px-6 py-16 grid lg:grid-cols-2 gap-12">
  <!-- Left: Image -->
<div class="flex justify-center items-start h-[500px]">
  <img src="assets/img/faqImg.jpg" 
       alt="FAQ Image" 
       class="rounded-xl shadow-lg w-full max-w-md h-full object-cover">
</div>

  <!-- Right: FAQ Items -->
  <div class="space-y-4 flex flex-col justify-center">
    <%-- FAQ Item --%>
    <div class="faq-item border border-gray-100 rounded-xl overflow-hidden">
      <button class="faq-question w-full flex justify-between items-center p-5 bg-gray-50 hover:bg-gray-100 font-semibold text-left">
        What is your return policy?
        <span class="faq-icon transition-transform duration-300">+</span>
      </button>
      <div class="faq-answer max-h-0 overflow-hidden transition-all duration-500 px-5">
        <p class="py-4">We offer a 30-day money-back guarantee on all purchases. If you're not satisfied with our product for any reason.</p>
      </div>
    </div>

    <div class="faq-item border border-gray-100 rounded-xl overflow-hidden">
      <button class="faq-question w-full flex justify-between items-center p-5 bg-gray-50 hover:bg-gray-100 font-semibold text-left">
        How long does it take to receive support?
        <span class="faq-icon transition-transform duration-300">+</span>
      </button>
      <div class="faq-answer max-h-0 overflow-hidden transition-all duration-500 px-5">
        <p class="py-4">Our support team strives to respond to all inquiries within 24 hours. However, response times may vary depending on the volume of requests.</p>
      </div>
    </div>

    <div class="faq-item border border-gray-100 rounded-xl overflow-hidden">
      <button class="faq-question w-full flex justify-between items-center p-5 bg-gray-50 hover:bg-gray-100 font-semibold text-left">
        Is my data secure with your platform?
        <span class="faq-icon transition-transform duration-300">+</span>
      </button>
      <div class="faq-answer max-h-0 overflow-hidden transition-all duration-500 px-5">
        <p class="py-4">Yes, we take data security seriously. Our platform employs industry-standard encryption protocols to safeguard your data.</p>
      </div>
    </div>

    <div class="faq-item border border-gray-100 rounded-xl overflow-hidden">
      <button class="faq-question w-full flex justify-between items-center p-5 bg-gray-50 hover:bg-gray-100 font-semibold text-left">
        Can I cancel my subscription at any time?
        <span class="faq-icon transition-transform duration-300">+</span>
      </button>
      <div class="faq-answer max-h-0 overflow-hidden transition-all duration-500 px-5">
        <p class="py-4">Yes, you can cancel your subscription at any time. Simply log in to your account and navigate to the subscription settings to initiate the cancellation process.</p>
      </div>
    </div>

    <div class="faq-item border border-gray-100 rounded-xl overflow-hidden">
      <button class="faq-question w-full flex justify-between items-center p-5 bg-gray-50 hover:bg-gray-100 font-semibold text-left">
        Do you offer customization options for your products?
        <span class="faq-icon transition-transform duration-300">+</span>
      </button>
      <div class="faq-answer max-h-0 overflow-hidden transition-all duration-500 px-5">
        <p class="py-4">Yes, we offer customization options for certain products. Please contact our sales team to discuss your specific requirements.</p>
      </div>
    </div>



  

  </div>
</section>

<script>
  const faqQuestions = document.querySelectorAll('.faq-question');

  faqQuestions.forEach(question => {
    question.addEventListener('click', () => {
      const parent = question.parentElement;
      const answer = parent.querySelector('.faq-answer');
      const icon = question.querySelector('.faq-icon');

      if(parent.classList.contains('active')) {
        answer.style.maxHeight = null;
        parent.classList.remove('active');
        icon.style.transform = 'rotate(0deg)';
      } else {
        // Close others
        document.querySelectorAll('.faq-item.active').forEach(item => {
          item.classList.remove('active');
          item.querySelector('.faq-answer').style.maxHeight = null;
          item.querySelector('.faq-icon').style.transform = 'rotate(0deg)';
        });

        answer.style.maxHeight = answer.scrollHeight + "px";
        parent.classList.add('active');
        icon.style.transform = 'rotate(45deg)';
      }
    });
  });
</script>

<jsp:include page="layout/footer.jsp" />
<jsp:include page="layout/JSPFooter.jsp" />
