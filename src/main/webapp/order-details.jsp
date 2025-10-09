<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="com.demo.dao.OrderDAO" %>
<%@ page import="com.demo.dao.UserDAO" %>
<%@ page import="com.demo.dao.TheaterDAO" %>
<%@ page import="com.demo.model.Order" %>
<%@ page import="com.demo.model.OrderItem" %>
<%@ page import="com.demo.model.User" %>
<%@ page import="com.demo.model.Theater" %>
<%@ page import="java.text.SimpleDateFormat" %>

<%
    User loggedInUser = (User) session.getAttribute("user");
    if (loggedInUser == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    String role = loggedInUser.getRole();
    int loggedInUserId = loggedInUser.getUserId();

    int orderId = 0;
    try {
        orderId = Integer.parseInt(request.getParameter("orderId"));
    } catch(Exception e) {
        out.println("<p>Invalid order ID.</p>");
        return;
    }

    OrderDAO orderDAO = new OrderDAO();
    UserDAO userDAO = new UserDAO();
    TheaterDAO theaterDAO = new TheaterDAO();

    Order order = orderDAO.getOrderById(orderId);
    if(order == null) {
        out.println("<p>Order not found.</p>");
        return;
    }

    if(!"admin".equals(role) && !"theateradmin".equals(role) && order.getUserId() != loggedInUserId) {
        out.println("<p>You do not have permission to view this order.</p>");
        return;
    }
    if("theateradmin".equals(role)) {
        List<Theater> myTheaters = theaterDAO.getTheatersByUserId(loggedInUserId);
        boolean hasAccess = myTheaters.stream().anyMatch(t -> t.getTheaterId() == order.getTheaterId());
        if(!hasAccess) {
            out.println("<p>You do not have permission to view this order.</p>");
            return;
        }
    }

    User orderUser = userDAO.getUserById(order.getUserId());
    Theater orderTheater = theaterDAO.getTheaterById(order.getTheaterId());
    
    // Status color
    String statusColor = "text-yellow-600";
    if ("completed".equalsIgnoreCase(order.getStatus())) statusColor = "text-green-600";
    else if ("picked".equalsIgnoreCase(order.getStatus())) statusColor = "text-blue-600";
    else if ("cancelled".equalsIgnoreCase(order.getStatus())) statusColor = "text-red-600";
    
    // Fixed Date Format
    SimpleDateFormat sdf = new SimpleDateFormat("MMM dd, yyyy 'at' hh:mm a");
    String orderDateTime = "";
    try {
        orderDateTime = sdf.format(order.getCreatedAt());
    } catch (Exception e) {
        // Fallback format if there's any issue
        SimpleDateFormat fallbackFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
        orderDateTime = fallbackFormat.format(order.getCreatedAt());
    }
    
    // QR Code Data - Create meaningful data that can be scanned
    String qrData = "FOODORDER:" + order.getId() + 
                   "|CUSTOMER:" + orderUser.getName() + 
                   "|THEATER:" + orderTheater.getName() + 
                   "|AMOUNT:$" + order.getTotalAmount() + 
                   "|ITEMS:" + order.getItems().size() +
                   "|STATUS:" + order.getStatus();
    String encodedQRData = java.net.URLEncoder.encode(qrData, "UTF-8");
%>

<jsp:include page="layout/JSPHeader.jsp"/>
<jsp:include page="layout/header.jsp"/>

<div class="min-h-screen bg-gradient-to-br from-red-50 to-rose-50 py-8">
    <div class="container mx-auto px-4 max-w-6xl">
<!-- Breadcrumb -->
		<nav class="text-gray-500 text-sm mb-4" aria-label="Breadcrumb">
			<ol class="list-none p-0 inline-flex">
				<li><a href="home.jsp" class="hover:text-red-600">Home</a></li>
            <li><span class="mx-2">/</span></li>
            <li><a href="user-orders.jsp" class="hover:text-red-600">My Orders</a></li>
            <li><span class="mx-2">/</span></li>
				<li class="flex items-center text-gray-900 font-semibold">Order Details
				</li>
			</ol>
		</nav>
        <!-- Header -->
        <div class="text-center mb-8">
            <h1 class="text-4xl font-bold text-gray-900 mb-3">Food Order Details</h1>
            <p class="text-lg text-gray-700">Order #<%= order.getId() %></p>
        </div>

        <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
            <!-- Left Column -->
            <div class="lg:col-span-2 space-y-6">
                <!-- Order Details & Payment -->
                <div class="grid grid-cols-2 gap-6">
                    <!-- Order Details -->
                    <div class="bg-white rounded-2xl border-2 border-red-100 p-6">
                        <h3 class="text-xl font-bold text-gray-900 mb-4">Order Details</h3>
                        <div class="space-y-4">
                            <div class="p-3 bg-red-50 rounded-lg border border-red-100">
                                <label class="block text-sm text-gray-600 mb-1">Order ID</label>
                                <p class="font-semibold text-gray-900">#<%= order.getId() %></p>
                            </div>
                            <div class="p-3 bg-red-50 rounded-lg border border-red-100">
                                <label class="block text-sm text-gray-600 mb-1">Order Time</label>
                                <p class="font-semibold text-gray-900"><%= orderDateTime %></p>
                            </div>
                            <div class="p-3 bg-red-50 rounded-lg border border-red-100">
                                <label class="block text-sm text-gray-600 mb-1">Status</label>
                                <p class="font-semibold <%= statusColor %>">
                                    <%= order.getStatus().toUpperCase() %>
                                </p>
                            </div>
                        </div>
                    </div>

                    <!-- Payment Details -->
                    <div class="bg-white rounded-2xl border-2 border-red-100 p-6">
                        <h3 class="text-xl font-bold text-gray-900 mb-4">Payment Information</h3>
                        <div class="space-y-4">
                            <div class="p-3 bg-red-50 rounded-lg border border-red-100">
                                <label class="block text-sm text-gray-600 mb-1">Payment Method</label>
                                <p class="font-semibold text-gray-900">
                                    <%
                                        String paymentMethod = order.getPaymentMethod();
                                        if ("KPZ".equalsIgnoreCase(paymentMethod)) {
                                            out.print("KBZ Pay");
                                        } else if ("Wave".equalsIgnoreCase(paymentMethod)) {
                                            out.print("Wave Pay");
                                        } else {
                                            out.print(paymentMethod);
                                        }
                                    %>
                                </p>
                            </div>
                            <div class="p-3 bg-red-50 rounded-lg border border-red-100">
                                <label class="block text-sm text-gray-600 mb-1">Payment Status</label>
                                <p class="font-semibold <%= "pending".equalsIgnoreCase(order.getStatus()) ? "text-yellow-600" : "text-green-600" %>">
                                    <%= "pending".equalsIgnoreCase(order.getStatus()) ? "Pending" : "Paid" %>
                                </p>
                            </div>
                            <div class="p-4 bg-gradient-to-r from-red-600 to-rose-700 rounded-lg border-2 border-red-500">
                                <label class="block text-sm text-red-900 mb-1">Total Amount</label>
                                <p class="font-bold text-red-700 text-2xl">$<%= order.getTotalAmount() %></p>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Order Items Table -->
                <div class="bg-white rounded-2xl border-2 border-red-100 p-6">
                    <h3 class="text-xl font-bold text-gray-900 mb-4">Order Items</h3>
                    <div class="overflow-x-auto">
                        <table class="w-full text-left">
                            <thead class="bg-red-50 text-gray-700 uppercase text-sm">
                                <tr>
                                    <th class="py-3 px-4 font-semibold">Food Item</th>
                                    <th class="py-3 px-4 font-semibold">Image</th>
                                    <th class="py-3 px-4 font-semibold">Quantity</th>
                                    <th class="py-3 px-4 font-semibold text-right">Price</th>
                                    <th class="py-3 px-4 font-semibold text-right">Total</th>
                                </tr>
                            </thead>
                            <tbody class="divide-y divide-gray-200">
                            <% for(OrderItem item: order.getItems()) { %>
                                <tr class="hover:bg-red-50 transition">
                                    <td class="py-3 px-4 font-medium text-gray-800"><%= item.getFood().getName() %></td>
                                    <td class="py-3 px-4">
                                        <img src="<%= item.getFood().getImage() %>" 
                                             alt="<%= item.getFood().getName() %>"
                                             class="h-12 w-12 object-cover rounded-lg border border-red-100"/>
                                    </td>
                                    <td class="py-3 px-4 text-gray-700"><%= item.getQuantity() %></td>
                                    <td class="py-3 px-4 text-right text-gray-700">$<%= item.getPrice() %></td>
                                    <td class="py-3 px-4 text-right text-green-600 font-semibold">$<%= item.getPrice() * item.getQuantity() %></td>
                                </tr>
                            <% } %>
                            </tbody>
                            <tfoot class="bg-red-50">
                                <tr>
                                    <td colspan="4" class="py-3 px-4 font-bold text-right text-gray-800">Grand Total:</td>
                                    <td class="py-3 px-4 text-right font-bold text-red-700 text-lg">$<%= order.getTotalAmount() %></td>
                                </tr>
                            </tfoot>
                        </table>
                    </div>
                </div>
            </div>

            <!-- Right Column -->
            <div class="space-y-6">
                <!-- Customer Information -->
                <div class="bg-white rounded-2xl border-2 border-red-100 p-6">
                    <h3 class="text-xl font-bold text-gray-900 mb-4">Customer Information</h3>
                    <div class="space-y-4">
                        <div class="p-3 bg-red-50 rounded-lg border border-red-100">
                            <label class="block text-sm text-gray-600 mb-1">Full Name</label>
                            <p class="font-semibold text-gray-900"><%= orderUser.getName() %></p>
                        </div>
                        <div class="p-3 bg-red-50 rounded-lg border border-red-100">
                            <label class="block text-sm text-gray-600 mb-1">Email</label>
                            <p class="font-semibold text-gray-900"><%= orderUser.getEmail() %></p>
                        </div>
                        <div class="p-3 bg-red-50 rounded-lg border border-red-100">
                            <label class="block text-sm text-gray-600 mb-1">Phone</label>
                            <p class="font-semibold text-gray-900"><%= orderUser.getPhone() %></p>
                        </div>
                    </div>
                </div>

                <!-- Theater Information -->
                <div class="bg-white rounded-2xl border-2 border-red-100 p-6">
                    <h3 class="text-xl font-bold text-gray-900 mb-4">Pickup Location</h3>
                    <div class="space-y-4">
                        <div class="p-3 bg-red-50 rounded-lg border border-red-100">
                            <label class="block text-sm text-gray-600 mb-1">Theater</label>
                            <p class="font-semibold text-gray-900"><%= orderTheater.getName() %></p>
                        </div>
                        <div class="p-3 bg-red-50 rounded-lg border border-red-100">
                            <label class="block text-sm text-gray-600 mb-1">Location</label>
                            <p class="font-semibold text-gray-900"><%= orderTheater.getLocation() %></p>
                        </div>
                        <div class="p-3 bg-red-50 rounded-lg border border-red-100">
                            <label class="block text-sm text-gray-600 mb-1">Pickup Instructions</label>
                            <p class="text-sm text-gray-700">Present order confirmation at concession counter</p>
                        </div>
                    </div>
                </div>

                <!-- QR Code -->
                <div class="bg-white rounded-2xl border-2 border-red-100 p-6 text-center">
                    <h3 class="text-xl font-bold text-gray-900 mb-4">QR Code</h3>
                    <div class="w-48 h-48 bg-white rounded-2xl mx-auto flex items-center justify-center border-2 border-red-200 mb-3 p-2">
                        <img src="https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=<%= encodedQRData %>" 
                             alt="QR Code" 
                             class="w-full h-full object-contain"
                             onerror="this.style.display='none'; document.getElementById('qrFallback').style.display='flex';" />
                        <div id="qrFallback" class="hidden items-center justify-center w-full h-full">
                            <div class="text-center">
                                <div class="font-bold text-red-700 text-sm">ORDER #<%= order.getId() %></div>
                                <div class="text-xs text-gray-600 mt-2">Scan for verification</div>
                            </div>
                        </div>
                    </div>
                    <p class="text-sm text-gray-500">Scan this QR code for order verification</p>
                    <p class="text-xs text-gray-400 mt-1">Contains: Order ID, Customer, Theater & Amount</p>
                </div>

                <!-- Print Button -->
                <div class="text-center">
                    <button onclick="printReceipt()" 
                            class="w-full bg-red-700 hover:bg-red-800 text-white px-6 py-3 rounded-xl font-semibold transition-all duration-200 border-2 border-red-600">
                        🖨️ Print Receipt
                    </button>
                </div>
            </div>
        </div>

        <!-- Printable Receipt -->
        <div id="printableReceipt" style="display: none; font-family: Arial, sans-serif; font-size: 12px; line-height: 1.4; width: 100%; border: 1px solid #000; padding: 10px; margin: 0; position: absolute; top: 0; left: 0;">
            <!-- Company Header -->
            <div style="display:flex; align-items:center; justify-content:space-between; margin-bottom:8px; border-bottom:1px solid #000; padding-bottom:6px;">
                <div style="display:flex; align-items:center;">
                    <div style="width:50px; height:50px; background:#000; color:white; display:flex; align-items:center; justify-content:center; margin-right:10px; font-weight:bold; font-size:10px;">
                        CINEZY
                    </div>
                    <div>
                        <h2 style="margin:0; font-size:16px;">CINEZY CINEMA</h2>
                        <div style="font-size:11px; line-height:1.3;">
                            <div><strong>Email:</strong> cinezy17@gmail.com</div>
                            <div><strong>Phone:</strong> +95 9780865174</div>
                            <div><strong>Address:</strong> University of Computer Studies Street, Hpa-an</div>
                        </div>
                    </div>
                </div>
            </div>

            <h3 style="text-align:center; margin:8px 0; font-size:14px; text-transform:uppercase;">Food Order Receipt</h3>

            <!-- Customer Information -->
            <div style="margin-bottom:8px;">
                <strong>Customer Name:</strong> <%= orderUser.getName() %><br>
                <strong>Email:</strong> <%= orderUser.getEmail() %><br>
                <strong>Phone:</strong> <%= orderUser.getPhone() %><br>
                <strong>Order ID:</strong> #<%= order.getId() %><br>
                <strong>Order Date:</strong> <%= orderDateTime %>
            </div>

            <!-- Order Items Table -->
            <table style="width:100%; border-collapse:collapse; margin-bottom:8px; border:1px solid #000; font-size:12px;">
                <thead>
                    <tr style="background-color:#f9f9f9;">
                        <td style="padding:6px; font-weight:bold; border:1px solid #000; width:40%;">Item Name</td>
                        <td style="padding:6px; font-weight:bold; border:1px solid #000; width:20%; text-align:center;">Quantity</td>
                        <td style="padding:6px; font-weight:bold; border:1px solid #000; width:20%; text-align:right;">Unit Price</td>
                        <td style="padding:6px; font-weight:bold; border:1px solid #000; width:20%; text-align:right;">Total</td>
                    </tr>
                </thead>
                <tbody>
                    <% for(OrderItem item: order.getItems()) { %>
                    <tr>
                        <td style="padding:6px; border:1px solid #000;"><%= item.getFood().getName() %></td>
                        <td style="padding:6px; border:1px solid #000; text-align:center;"><%= item.getQuantity() %></td>
                        <td style="padding:6px; border:1px solid #000; text-align:right;">$<%= item.getPrice() %></td>
                        <td style="padding:6px; border:1px solid #000; text-align:right;">$<%= item.getPrice() * item.getQuantity() %></td>
                    </tr>
                    <% } %>
                    <tr style="background-color:#f9f9f9;">
                        <td colspan="3" style="padding:6px; font-weight:bold; border:1px solid #000; text-align:right;">Grand Total:</td>
                        <td style="padding:6px; font-weight:bold; border:1px solid #000; text-align:right;">$<%= order.getTotalAmount() %></td>
                    </tr>
                </tbody>
            </table>

            <!-- Pickup Information -->
            <table style="width:100%; border-collapse:collapse; margin-bottom:8px; border:1px solid #000; font-size:12px;">
                <tbody>
                    <tr style="background-color:#f9f9f9;">
                        <td style="padding:6px; font-weight:bold; border:1px solid #000;">Theater</td>
                        <td style="padding:6px; border:1px solid #000;"><%= orderTheater.getName() %></td>
                        <td style="padding:6px; font-weight:bold; border:1px solid #000;">Location</td>
                        <td style="padding:6px; border:1px solid #000;"><%= orderTheater.getLocation() %></td>
                    </tr>
                </tbody>
            </table>

            <!-- Payment Information -->
            <div style="margin-bottom:8px;">
                <strong>Payment Method:</strong> 
                <%
                    if ("KPZ".equalsIgnoreCase(order.getPaymentMethod())) {
                        out.print("KBZ Pay");
                    } else if ("Wave".equalsIgnoreCase(order.getPaymentMethod())) {
                        out.print("Wave Pay");
                    } else {
                        out.print(order.getPaymentMethod());
                    }
                %><br>
                <strong>Payment Status:</strong> 
                <%
                    if ("pending".equalsIgnoreCase(order.getStatus())) {
                        out.print("Pending");
                    } else {
                        out.print("Paid");
                    }
                %><br>
                <strong>Total Amount:</strong> $<%= order.getTotalAmount() %>
            </div>

            <!-- QR Code for Print -->
            <div style="text-align:center; margin-top:12px;">
                <div style="width:120px; height:120px; border:1px solid #000; display:inline-flex; align-items:center; justify-content:center; margin-bottom:5px;">
                    <div style="text-align:center;">
                        <div style="font-weight:bold; font-size:11px;">ORDER #<%= order.getId() %></div>
                        <div style="font-size:10px; margin-top:5px; color:#666;">SCAN TO VERIFY</div>
                        <div style="font-size:8px; color:#999; margin-top:2px;">CINEZY CINEMA</div>
                    </div>
                </div>
                <div style="font-size:10px;">Show this receipt at counter</div>
            </div>
        </div>
    </div>
</div>

<style>
@media print {
    @page {
        margin: 0;
        size: auto;
    }
    
    body {
        margin: 0;
        padding: 0;
    }
    
    body * {
        visibility: hidden;
        margin: 0;
        padding: 0;
    }
    
    #printableReceipt, #printableReceipt * {
        visibility: visible;
        margin: 0;
    }
    
    #printableReceipt {
        position: absolute;
        left: 0;
        top: 0;
        width: 100%;
        height: 100%;
        border: 1px solid #000 !important;
        padding: 10px;
        box-sizing: border-box;
    }
    
    .no-print {
        display: none !important;
    }
}

.no-print {
    display: block;
}

#printableReceipt {
    display: none;
}

.hidden {
    display: none !important;
}
</style>

<script>
function printReceipt() {
    const receipt = document.getElementById('printableReceipt');
    receipt.style.display = 'block';
    
    window.print();
    
    setTimeout(() => {
        receipt.style.display = 'none';
    }, 100);
}

// QR code fallback handling
document.addEventListener('DOMContentLoaded', function() {
    const qrImage = document.querySelector('#printableReceipt img');
    if (qrImage) {
        qrImage.onerror = function() {
            const qrFallback = document.getElementById('qrFallback');
            if (qrFallback) {
                qrFallback.style.display = 'flex';
            }
        };
    }
});
</script>

<jsp:include page="layout/footer.jsp"/>