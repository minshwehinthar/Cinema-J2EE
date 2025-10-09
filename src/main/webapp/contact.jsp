<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<jsp:include page="layout/JSPHeader.jsp" />
<jsp:include page="layout/header.jsp" />

<section class="bg-gray-50 py-16">
	<div
		class="max-w-6xl mx-auto px-6 grid grid-cols-1 lg:grid-cols-2 gap-12">
		<!-- Left Column: Info + Form -->
		<div class="space-y-8">
			<!-- Contact Info -->
			<div class="space-y-4">
				<div>
					<p class="text-sm font-medium text-gray-500">Email</p>
					<p class="text-lg font-semibold text-gray-800">cinezy17@gmail.com</p>
				</div>
				<div>
					<p class="text-sm font-medium text-gray-500">Phone</p>
					<p class="text-lg font-semibold text-gray-800">+959780865174</p>
				</div>
				<div>
					<p class="text-sm font-medium text-gray-500">Office</p>
					<p class="text-lg font-semibold text-gray-800">University of Computer Stuides, Hpa-an, Kayin State</p>
				</div>
			</div>
			<!-- Contact Form -->
			<form action="#" method="POST" class="space-y-6">
				<div>
					<label for="name" class="block text-sm font-medium text-gray-700">Full
						name</label> <input type="text" id="name" name="name" required
						class="mt-2 block w-full rounded-md border-gray-300 focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm p-3 bg-white" />
				</div>
				<div>
					<label for="email" class="block text-sm font-medium text-gray-700">Email
						address</label> <input type="email" id="email" name="email" required
						class="mt-2 block w-full rounded-md border-gray-300 focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm p-3 bg-white" />
				</div>
				<div>
					<label for="message"
						class="block text-sm font-medium text-gray-700">Message</label>
					<textarea id="message" name="message" rows="5" required
						class="mt-2 block w-full rounded-md border-gray-300 focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm p-3 bg-white"></textarea>
				</div>
				<button type="submit"
					class="inline-flex justify-center rounded-md bg-indigo-600 px-6 py-3 text-sm font-semibold text-white shadow hover:bg-indigo-700 transition">
					Send Message</button>
			</form>
		</div>
		<!-- Right Column: Map -->
		<div class="w-full h-full min-h-[450px]">
			<iframe 
        src="https://www.google.com/maps/embed?pb=!1m18!1m12!1m3!1d3818.7914305922754!2d97.59359387610498!3d16.836699983959676!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x30c2c63bf4d73df9%3A0x786f61bd777d5fa6!2sUCSH%20(HpaAn)!5e0!3m2!1sen!2smm!4v1759307170386!5m2!1sen!2smm" 
        width="100%" height="100%" style="border:0;" allowfullscreen="" loading="lazy">
      </iframe>
		</div>
	</div>
</section>
<jsp:include page="layout/footer.jsp" />
<jsp:include page="layout/JSPFooter.jsp" />