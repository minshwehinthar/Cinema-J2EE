<%@ page import="java.util.List"%>
<%@ page import="com.demo.model.*"%>
<%@ page import="com.demo.dao.*"%>
<%@ page import="java.text.SimpleDateFormat"%>
<%
OrderDAO orderDAO = new OrderDAO();
TheaterDAO theaterDAO = new TheaterDAO();
UserDAO userDAO = new UserDAO();

// Get orderId from request
String orderIdParam = request.getParameter("orderId");
if (orderIdParam == null) {
	response.sendRedirect("index.jsp");
	return;
}

int orderId = Integer.parseInt(orderIdParam);
Order order = orderDAO.getOrderById(orderId);
if (order == null) {
	response.sendRedirect("index.jsp");
	return;
}

Theater theater = theaterDAO.getTheaterById(order.getTheaterId());
SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
String orderDateTime = sdf.format(order.getCreatedAt());

// Get customer info: prioritize logged-in User
User user = (User) session.getAttribute("user");

String customerName = null;
String customerEmail = null;
String customerPhone = null;

if (user != null) {
	customerName = user.getName();
	customerEmail = user.getEmail();
	customerPhone = user.getPhone();
} else {
	// Fallback: checkout form session data
	customerName = (String) session.getAttribute("customerName");
	customerEmail = (String) session.getAttribute("customerEmail");
	customerPhone = (String) session.getAttribute("customerPhone");
}

// Default if still null
if (customerName == null)
	customerName = "Not provided";
if (customerEmail == null)
	customerEmail = "Not provided";
if (customerPhone == null)
	customerPhone = "Not provided";
%>
<jsp:include page="layout/JSPHeader.jsp" />
<jsp:include page="layout/header.jsp" />

<div class="min-h-screen bg-gradient-to-br from-red-50 to-rose-50 py-8">
	<div class="container mx-auto px-4 max-w-6xl">

		<!-- Breadcrumb -->
		<nav class="text-sm mb-6" aria-label="Breadcrumb">
			<ol class="list-reset flex text-gray-600">
				<li><a href="home.jsp" class="hover:text-red-600">Home</a></li>
				<li><span class="mx-2">/</span></li>
				<li><a href="foods.jsp" class="hover:text-red-600">Foods</a></li>
				<li><span class="mx-2">/</span></li>
				<li><a href="cart.jsp" class="hover:text-red-600">Cart</a></li>
				<li><span class="mx-2">/</span></li>
				<li><a href="checkout.jsp" class="hover:text-red-600">Checkout</a></li>
				<li><span class="mx-2">/</span></li>
				<li class="flex items-center text-gray-900 font-semibold">Order
					Success</li>
			</ol>
		</nav>

		<!-- Success Header -->
		<div class="text-center mb-12">

			<h1 class="text-4xl font-bold text-gray-900 mb-3">Order Placed
				Successfully!</h1>
			<p class="text-gray-700 text-lg  mx-auto">
				Thank you for your purchase, <span
					class="font-semibold text-red-700"><%=customerName%></span>! Your
				order has been confirmed and will be ready for pickup.
			</p>
		</div>

		<div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
			<!-- Left: Order & Customer Info -->
			<div class="lg:col-span-2 space-y-6">

				<!-- Order Status Card -->
				<div
					class="bg-white rounded-2xl border-2 border-red-100 p-6 shadow-sm">
					<div
						class="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4">
						<div>
							<h2 class="text-xl font-bold text-gray-900 mb-2">Order
								Confirmation</h2>
							<p class="text-gray-700">
								Order ID: <span class="font-semibold text-red-700">#<%=order.getId()%></span>
							</p>
							<p class="text-gray-500 text-sm mt-1">
								Placed on:
								<%=orderDateTime%></p>
						</div>
						<div class="flex flex-col items-end gap-2">
							<span
								class="px-4 py-2 rounded-full text-sm font-semibold bg-gradient-to-r from-green-100 to-emerald-100 text-green-800 border border-green-200">
								<%=order.getStatus()%>
							</span>
							<%
							if ("pending".equalsIgnoreCase(order.getStatus())) {
							%>
							<span class="text-xs text-gray-500">Awaiting admin
								confirmation</span>
							<%
							}
							%>
						</div>
					</div>
				</div>

				<!-- Customer & Theater Info -->
				<div
					class="bg-white rounded-2xl border-2 border-red-100 p-6 shadow-sm">
					<h3 class="text-lg font-bold text-gray-900 mb-4 flex items-center">
						<svg class="w-5 h-5 text-red-600 mr-2" fill="none"
							stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round"
								stroke-linejoin="round" stroke-width="2"
								d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path>
                        </svg>
						Order Details
					</h3>
					<div class="grid grid-cols-1 md:grid-cols-2 gap-6">
						<!-- Customer Info -->
						<div class="space-y-4">
							<h4 class="font-semibold text-gray-700 mb-3 text-red-700">Customer
								Information</h4>
							<div class="p-3 bg-red-50 rounded-lg border border-red-100">
								<label class="block text-sm font-medium text-gray-600 mb-1">Full
									Name</label>
								<p class="font-semibold text-gray-900"><%=customerName%></p>
							</div>
							<div class="p-3 bg-red-50 rounded-lg border border-red-100">
								<label class="block text-sm font-medium text-gray-600 mb-1">Email
									Address</label>
								<p class="font-semibold text-gray-900"><%=customerEmail%></p>
							</div>
							<div class="p-3 bg-red-50 rounded-lg border border-red-100">
								<label class="block text-sm font-medium text-gray-600 mb-1">Phone
									Number</label>
								<p class="font-semibold text-gray-900"><%=customerPhone%></p>
							</div>
						</div>

						<!-- Theater Info -->
						<div class="space-y-4">
							<h4 class="font-semibold text-gray-700 mb-3 text-red-700">Pickup
								Location</h4>
							<div class="p-3 bg-red-50 rounded-lg border border-red-100">
								<label class="block text-sm font-medium text-gray-600 mb-1">Theater</label>
								<p class="font-semibold text-gray-900"><%=theater.getName()%></p>
							</div>
							<div class="p-3 bg-red-50 rounded-lg border border-red-100">
								<label class="block text-sm font-medium text-gray-600 mb-1">Location</label>
								<p class="font-semibold text-gray-900"><%=theater.getLocation()%></p>
							</div>
							<div class="p-3 bg-red-50 rounded-lg border border-red-100">
								<label class="block text-sm font-medium text-gray-600 mb-1">Pickup
									Instructions</label>
								<p class="text-sm text-gray-700">Present your order
									confirmation at the concession counter</p>
							</div>
						</div>
					</div>
				</div>

				<!-- Order Items -->
				<div
					class="bg-white rounded-2xl border-2 border-red-100 p-6 shadow-sm">
					<h3 class="text-lg font-bold text-gray-900 mb-4 flex items-center">
						<svg class="w-5 h-5 text-red-600 mr-2" fill="none"
							stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round"
								stroke-linejoin="round" stroke-width="2"
								d="M16 11V7a4 4 0 00-8 0v4M5 9h14l1 12H4L5 9z"></path>
                        </svg>
						Items Purchased
					</h3>
					<div class="space-y-4">
						<%
						for (OrderItem item : order.getItems()) {
						%>
						<div
							class="flex justify-between items-center p-4 bg-red-50 rounded-xl border border-red-100 hover:bg-red-100 transition-colors">
							<div class="flex items-center gap-4">
								<img src="<%=item.getFood().getImage()%>"
									alt="<%=item.getFood().getName()%>"
									class="w-16 h-16 rounded-xl object-cover border-2 border-white shadow-sm">
								<div>
									<p class="text-gray-800 font-semibold"><%=item.getFood().getName()%></p>
									<p class="text-gray-600 text-sm">
										Quantity: <span class="font-medium"><%=item.getQuantity()%></span>
									</p>
									<p class="text-gray-600 text-sm">
										Unit Price: $<span class="font-medium"><%=item.getPrice()%></span>
									</p>
								</div>
							</div>
							<div class="text-right">
								<p class="font-bold text-red-700 text-lg">
									$<%=item.getPrice() * item.getQuantity()%></p>
							</div>
						</div>
						<%
						}
						%>
					</div>
				</div>
			</div>

			<!-- Right: Payment Summary -->
			<div class="space-y-6">
				<!-- Payment Summary -->
				<div
					class="bg-white rounded-2xl border-2 border-red-100 p-6 shadow-sm h-fit sticky top-20">
					<h3 class="text-xl font-bold text-gray-900 mb-6 flex items-center">
						<svg class="w-5 h-5 text-red-600 mr-2" fill="none"
							stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round"
								stroke-linejoin="round" stroke-width="2"
								d="M17 9V7a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2m2 4h10a2 2 0 002-2v-6a2 2 0 00-2-2H9a2 2 0 00-2 2v6a2 2 0 002 2zm7-5a2 2 0 11-4 0 2 2 0 014 0z"></path>
                        </svg>
						Payment Summary
					</h3>

					<div class="space-y-4 mb-6">
						<div
							class="flex justify-between items-center pb-3 border-b border-gray-200">
							<span class="text-gray-700">Items (<%=order.getItems().size()%>)
							</span> <span class="font-semibold text-gray-900">$<%=order.getTotalAmount()%></span>
						</div>
						<div
							class="flex justify-between items-center pb-3 border-b border-gray-200">
							<span class="text-gray-700">Payment Method</span> <span
								class="font-semibold text-gray-900 capitalize"> <%
 if ("KPZ".equalsIgnoreCase(order.getPaymentMethod())) {
 %> <span
								class="inline-flex items-center gap-1"> <img
									src="assets/img/kpay.png" alt="KBZ Pay" class="w-5 h-5 rounded">
									KBZ Pay
							</span> <%
 } else if ("Wave".equalsIgnoreCase(order.getPaymentMethod())) {
 %> <span
								class="inline-flex items-center gap-1"> <img
									src="assets/img/wavepay.jpeg" alt="Wave Pay"
									class="w-5 h-5 rounded"> Wave Pay
							</span> <%
 } else {
 %> <%=order.getPaymentMethod()%> <%
 }
 %>
							</span>
						</div>
						<div
							class="flex justify-between items-center pt-3 border-t border-gray-200">
							<span class="text-lg font-bold text-gray-900">Total Amount</span>
							<span class="text-2xl font-bold text-red-700">$<%=order.getTotalAmount()%></span>
						</div>
					</div>

					<!-- Action Buttons -->
					<div class="space-y-3">
						<a href="foods.jsp"
							class="w-full bg-red-700 hover:bg-red-800 text-white px-6 py-3 rounded-xl font-semibold transition-all duration-200 flex items-center justify-center gap-2 border-2 border-red-600">
							<svg class="w-5 h-5" fill="none" stroke="currentColor"
								viewBox="0 0 24 24">
                                <path stroke-linecap="round"
									stroke-linejoin="round" stroke-width="2"
									d="M3 3h2l.4 2M7 13h10l4-8H5.4M7 13L5.4 5M7 13l-2.293 2.293c-.63.63-.184 1.707.707 1.707H17m0 0a2 2 0 100 4 2 2 0 000-4zm-8 2a2 2 0 11-4 0 2 2 0 014 0z"></path>
                            </svg> Continue Shopping →
						</a>

						<!-- Printable Voucher -->
						<div class="text-center">
							<button onclick="window.print()"
								class="w-full bg-white hover:bg-gray-50 text-red-700 px-6 py-3 rounded-xl font-semibold transition-all duration-200 flex items-center justify-center gap-2 border-2 border-red-200">
								<svg class="w-5 h-5" fill="none" stroke="currentColor"
									viewBox="0 0 24 24">
                                    <path stroke-linecap="round"
										stroke-linejoin="round" stroke-width="2"
										d="M17 17h2a2 2 0 002-2v-4a2 2 0 00-2-2H5a2 2 0 00-2 2v4a2 2 0 002 2h2m2 4h6a2 2 0 002-2v-4a2 2 0 00-2-2H9a2 2 0 00-2 2v4a2 2 0 002 2zm8-12V5a2 2 0 00-2-2H9a2 2 0 00-2 2v4h10z"></path>
                                </svg>
								Print Receipt
							</button>
						</div>
					</div>
				</div>

				<!-- Quick Scan Code -->
				<div
					class="bg-white rounded-2xl border-2 border-red-100 p-6 text-center">
					<h3
						class="text-lg font-bold text-gray-900 mb-4 flex items-center justify-center">
						<svg class="w-5 h-5 text-red-600 mr-2" fill="none"
							stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round"
								stroke-linejoin="round" stroke-width="2"
								d="M12 4v1m6 11h2m-6 0h-2v4m0-11v3m0 0h.01M12 12h4.01M16 20h4M4 12h4m12 0h.01M5 8h2a1 1 0 001-1V5a1 1 0 00-1-1H5a1 1 0 00-1 1v2a1 1 0 001 1zm12 0h2a1 1 0 001-1V5a1 1 0 00-1-1h-2a1 1 0 00-1 1v2a1 1 0 001 1zM5 20h2a1 1 0 001-1v-2a1 1 0 00-1-1H5a1 1 0 00-1 1v2a1 1 0 001 1z"></path>
                        </svg>
						Quick Scan Code
					</h3>
					<div
						class="w-40 h-40 bg-white rounded-2xl mx-auto flex items-center justify-center border-2 border-red-200 mb-3">
						<img id="qrImage"
							src="https://api.qrserver.com/v1/create-qr-code/?size=140x140&data=<%=java.net.URLEncoder.encode("OrderID:" + order.getId() + "|Customer:" + customerName, "UTF-8")%>"
							alt="QR Code" class="w-full h-full p-2"
							onerror="this.style.display='none'; document.getElementById('qrFallback').style.display='flex';">
						<div id="qrFallback"
							class="hidden items-center justify-center w-full h-full">
							<span class="text-sm text-gray-700 text-center font-semibold">Order<br>#<%=order.getId()%></span>
						</div>
					</div>
					<p class="text-sm text-gray-500">Show this code for pickup</p>
				</div>
			</div>
		</div>

		<!-- Printable Receipt (Hidden until print) -->
		<!-- Printable Receipt (Hidden on screen, visible when printing) -->
		<div id="printableReceipt"
			style="visibility: hidden; font-family: Arial, sans-serif; font-size: 12px; line-height: 1.4; max-width: 600px; margin: auto; border: 1px solid #000; padding: 15px;">

			<!-- Company Header -->
			<div
				style="display: flex; align-items: center; justify-content: space-between; margin-bottom: 10px; border-bottom: 1px solid #000; padding-bottom: 8px;">
				<div style="display: flex; align-items: center;">
					<img src="assets/img/cinema-logo.jpg" alt="Cinema Logo"
						style="width: 50px; height: 50px; margin-right: 10px;">
					<div>
						<h2 style="margin: 0; font-size: 16px;">CINEZY Cinema</h2>
						<div style="font-size: 11px; line-height: 1.3;">
							<div>
								<strong>Email:</strong> cinezy17@gmail.com
							</div>
							<div>
								<strong>Phone:</strong> +95 9780865174
							</div>
							<div>
								<strong>Address:</strong> University of Computer Studies Street,
								Hpa-an
							</div>
						</div>
					</div>
				</div>
			</div>

			<h3
				style="text-align: center; margin: 10px 0; font-size: 14px; text-transform: uppercase;">Food
				Order Receipt</h3>

			<!-- Customer Information -->
			<div style="margin-bottom: 10px;">
				<strong>Customer Name:</strong>
				<%=customerName%><br> <strong>Email:</strong>
				<%=customerEmail%><br> <strong>Phone:</strong>
				<%=customerPhone%><br> <strong>Order ID:</strong> #<%=order.getId()%>
			</div>

			<!-- Order Items Table -->
			<table
				style="width: 100%; border-collapse: collapse; margin-bottom: 10px; border: 1px solid #000; font-size: 12px;">
				<tbody>
					<tr style="background-color: #f9f9f9;">
						<td
							style="padding: 6px; font-weight: bold; border: 1px solid #000;">Item
							Name</td>
						<td style="padding: 6px; border: 1px solid #000;" colspan="3">Food
							Order</td>
					</tr>
					<%
					for (OrderItem item : order.getItems()) {
					%>
					<tr>
						<td
							style="padding: 6px; font-weight: bold; border: 1px solid #000;"><%=item.getFood().getName()%></td>
						<td style="padding: 6px; border: 1px solid #000;">Qty: <%=item.getQuantity()%></td>
						<td style="padding: 6px; border: 1px solid #000;">Price: $<%=item.getPrice()%></td>
						<td style="padding: 6px; border: 1px solid #000;">Total: $<%=item.getPrice() * item.getQuantity()%></td>
					</tr>
					<%
					}
					%>
					<tr style="background-color: #f9f9f9;">
						<td
							style="padding: 6px; font-weight: bold; border: 1px solid #000;">Grand
							Total</td>
						<td style="padding: 6px; border: 1px solid #000;" colspan="3">$<%=order.getTotalAmount()%></td>
					</tr>
				</tbody>
			</table>

			<!-- Pickup Information -->
			<table
				style="width: 100%; border-collapse: collapse; margin-bottom: 10px; border: 1px solid #000; font-size: 12px;">
				<tbody>
					<tr style="background-color: #f9f9f9;">
						<td
							style="padding: 6px; font-weight: bold; border: 1px solid #000;">Theater</td>
						<td style="padding: 6px; border: 1px solid #000;"><%=theater != null ? theater.getName() : "N/A"%></td>
						<td
							style="padding: 6px; font-weight: bold; border: 1px solid #000;">Location</td>
						<td style="padding: 6px; border: 1px solid #000;"><%=theater != null ? theater.getLocation() : "N/A"%></td>
					</tr>
				</tbody>
			</table>

			<!-- Payment Information -->
			<div style="margin-bottom: 10px;">
				<strong>Payment Method:</strong>
				<%
				String paymentMethod = order.getPaymentMethod();
				if ("KPZ".equalsIgnoreCase(paymentMethod)) {
					out.print("KBZ Pay");
				} else if ("Wave".equalsIgnoreCase(paymentMethod)) {
					out.print("Wave Pay");
				} else {
					out.print(paymentMethod);
				}
				%><br> <strong>Payment Status:</strong>
				<%
				if ("pending".equalsIgnoreCase(order.getStatus())) {
					out.print("Pending");
				} else {
					out.print("Paid");
				}
				%><br> <strong>Total Amount:</strong> $<%=order.getTotalAmount()%>
			</div>

			<!-- QR Code - FIXED -->
			<div style="text-align: center; margin-top: 15px;">
				<img
					src="https://api.qrserver.com/v1/create-qr-code/?size=120x120&data=ORDER-<%=order.getId()%>-<%=java.net.URLEncoder.encode(customerName, "UTF-8")%>"
					alt="QR Code"
					style="width: 120px; height: 120px; margin-bottom: 5px; display: block; margin-left: auto; margin-right: auto;" />
				<div style="font-size: 10px;">Show this receipt at counter</div>
			</div>
		</div>


		<style>
@media print {
	@page {
		margin: 0.5in;
	}
	body * {
		visibility: hidden;
	}
	#printableReceipt, #printableReceipt * {
		visibility: visible;
	}
	#printableReceipt {
		position: absolute;
		left: 0;
		top: 0;
		width: 100%;
		height: auto;
	}
	.no-print {
		display: none !important;
	}
}

.no-print {
	display: block;
}
</style>

		<script>
function printReceipt() {
    // Make the receipt visible before printing
    const receipt = document.getElementById('printableReceipt');
    receipt.style.visibility = 'visible';
    receipt.style.display = 'block';
    
    window.print();
    
    // Hide it again after printing
    setTimeout(() => {
        receipt.style.visibility = 'hidden';
        receipt.style.display = 'none';
    }, 100);
}
</script>
	</div>
</div>

<%
// Optional: clear checkout session info
session.removeAttribute("customerName");
session.removeAttribute("customerEmail");
session.removeAttribute("customerPhone");
%>

<jsp:include page="layout/footer.jsp" />