<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="com.demo.dao.OrderDAO" %>
<%@ page import="com.demo.dao.UserDAO" %>
<%@ page import="com.demo.dao.TheaterDAO" %>
<%@ page import="com.demo.model.Order" %>
<%@ page import="com.demo.model.OrderItem" %>
<%@ page import="com.demo.model.User" %>
<%@ page import="com.demo.model.Theater" %>


<%
User loggedInUser = (User) session.getAttribute("user");
String role = (loggedInUser != null) ? loggedInUser.getRole() : "";
int loggedInUserId = (loggedInUser != null) ? loggedInUser.getUserId() : -1;

int pageSize = 5;

OrderDAO orderDAO = new OrderDAO();
UserDAO userDAO = new UserDAO();
TheaterDAO theaterDAO = new TheaterDAO();

// --- Fetch completed orders ---
List<Order> allCompletedOrders = orderDAO.getCompletedOrders();

// Role-based filtering
if ("theateradmin".equals(role)) {
    List<Theater> myTheaters = theaterDAO.getTheatersByUserId(loggedInUserId);
    allCompletedOrders.removeIf(o -> myTheaters.stream().noneMatch(t -> t.getTheaterId() == o.getTheaterId()));
} else if (!"admin".equals(role)) {
    allCompletedOrders = Collections.emptyList();
}

// --- AJAX HANDLER ---
if ("POST".equalsIgnoreCase(request.getMethod())) {

    // Pick/Confirm order
    if (request.getParameter("pickOrder") != null) {
        int orderId = Integer.parseInt(request.getParameter("orderId"));
        boolean success = orderDAO.pickOrder(orderId);

        // --- SEND EMAIL TO CUSTOMER ---
        if (success) {
        	Order completedOrder = orderDAO.getOrderById(orderId);
            User customer = userDAO.getUserById(completedOrder.getUserId());

            if(customer != null && customer.getEmail() != null && !customer.getEmail().isEmpty()){
                String to = customer.getEmail();
                String subject = "Your Order #" + orderId + " has been completed!";
                
                StringBuilder body = new StringBuilder();
                body.append("Dear ").append(customer.getName()).append(",\n\n")
                    .append("We are happy to inform you that your order #").append(orderId)
                    .append(" has been successfully completed.\n\n")
                    .append("Order Summary:\n");

                for(OrderItem item : completedOrder.getItems()){
                    body.append("- ").append(item.getFood().getName())
                        .append(" x ").append(item.getQuantity()).append("\n");
                }

                body.append("\nTotal Amount: MMK ").append(completedOrder.getTotalAmount()).append("\n\n")
                    .append("Thank you for ordering with us!\n")
                    .append("Have a great day!\n\n")
                    .append("Best regards,\nCinezy Cinema Team");

                // Send the email
                com.demo.util.EmailUtil.sendEmail(to, subject, body.toString());
            }
        }

        response.setContentType("application/json");
        out.print("{\"success\":" + success + "}");
        return;
    }

    // AJAX search + sort + pagination
    if ("1".equals(request.getParameter("ajax_search"))) {
        String searchQuery = request.getParameter("search");
        String sortField = request.getParameter("sortField");
        String sortOrder = request.getParameter("sortOrder");
        int currentPage = request.getParameter("page") != null ? Integer.parseInt(request.getParameter("page")) : 1;

        // --- SEARCH ---
        if (searchQuery != null && !searchQuery.trim().isEmpty()) {
            String keyword = searchQuery.toLowerCase();
            allCompletedOrders.removeIf(o -> {
                User u = userDAO.getUserById(o.getUserId());
                Theater t = theaterDAO.getTheaterById(o.getTheaterId());
                String userName = (u != null) ? u.getName().toLowerCase() : "";
                String email = (u != null) ? u.getEmail().toLowerCase() : "";
                String theaterName = (t != null) ? t.getName().toLowerCase() : "";
                return !(String.valueOf(o.getId()).contains(keyword) ||
                        userName.contains(keyword) ||
                        email.contains(keyword) ||
                        theaterName.contains(keyword));
            });
        }

        // --- SORT ---
        if (sortField != null && !sortField.isEmpty()) {
            Comparator<Order> comp = Comparator.comparing(Order::getId);
            if ("id".equals(sortField)) comp = Comparator.comparing(Order::getId);
            else if ("total".equals(sortField)) comp = Comparator.comparing(Order::getTotalAmount);
            else if ("user".equals(sortField)) comp = Comparator.comparing(o -> {
                User u = userDAO.getUserById(o.getUserId());
                return u != null ? u.getName() : "";
            });
            else if ("theater".equals(sortField)) comp = Comparator.comparing(o -> {
                Theater t = theaterDAO.getTheaterById(o.getTheaterId());
                return t != null ? t.getName() : "";
            });

            if ("desc".equals(sortOrder)) comp = comp.reversed();
            allCompletedOrders.sort(comp);
        }

        // --- PAGINATION ---
        int totalOrders = allCompletedOrders.size();
        int start = (currentPage - 1) * pageSize;
        int end = Math.min(start + pageSize, totalOrders);
        List<Order> pageOrders = (start < end) ? allCompletedOrders.subList(start, end) : List.of();

        if (pageOrders.isEmpty()) {
            out.print("<tr><td colspan='8' class='px-6 py-8 text-center'><div class='w-16 h-16 mx-auto mb-4 text-gray-300'><svg fill='none' stroke='currentColor' viewBox='0 0 24 24'><path stroke-linecap='round' stroke-linejoin='round' stroke-width='1' d='M9 12.75L11.25 15 15 9.75M21 12a9 9 0 11-18 0 9 9 0 0118 0z'/></svg></div><h3 class='text-lg font-medium text-gray-600 mb-2'>No completed orders found</h3><p class='text-gray-500'>All orders are processed or try adjusting your search.</p></td></tr>");
        } else {
            for (Order o : pageOrders) {
                User user = userDAO.getUserById(o.getUserId());
                Theater theater = theaterDAO.getTheaterById(o.getTheaterId());
%>
<tr class="hover:bg-red-50 transition-colors duration-150" id="row-<%= o.getId() %>">
    <td class="px-6 py-4">
        <div class="flex items-center space-x-3">
            <div class="w-10 h-10 bg-red-100 rounded-lg flex items-center justify-center">
                <span class="text-red-600 font-bold text-sm">#<%= o.getId() %></span>
            </div>
        </div>
    </td>
    <td class="px-6 py-4">
        <div class="font-medium text-gray-900"><%= (user != null ? user.getName() : "Unknown") %></div>
        <div class="text-sm text-gray-500"><%= (user != null ? user.getEmail() : "") %></div>
        <div class="text-sm text-gray-500"><%= (user != null ? user.getPhone() : "") %></div>
    </td>
    <td class="px-6 py-4">
        <div class="font-medium text-gray-900"><%= (theater != null ? theater.getName() : "Unknown") %></div>
        <div class="text-sm text-gray-500"><%= (theater != null ? theater.getLocation() : "") %></div>
    </td>
    <td class="px-6 py-4">
        <div class="space-y-2 max-w-xs">
        <% for (OrderItem item : o.getItems()) { %>
            <div class="flex items-center space-x-3 p-2 bg-gray-50 rounded-lg">
                <img src="<%= item.getFood().getImage() %>" alt="<%= item.getFood().getName() %>"
                     class="w-8 h-8 rounded object-cover border border-gray-200"/>
                <div class="flex-1 min-w-0">
                    <div class="text-sm font-medium text-gray-900 truncate"><%= item.getFood().getName() %></div>
                    <div class="text-xs text-gray-500">Qty: <%= item.getQuantity() %></div>
                </div>
            </div>
        <% } %>
        </div>
    </td>
    <td class="px-6 py-4">
        <div class="font-semibold text-red-600">$<%= o.getTotalAmount() %></div>
    </td>
    <td class="px-6 py-4">
        <span class="inline-flex items-center px-3 py-1 rounded-full text-xs font-medium bg-purple-100 text-purple-800 border border-purple-200 capitalize">
            <%= o.getPaymentMethod() %>
        </span>
    </td>
    <td class="px-6 py-4">
        <span class="inline-flex items-center px-3 py-1 rounded-full text-xs font-medium bg-green-100 text-green-800 border border-green-200">
            <%= o.getStatus() %>
        </span>
    </td>
    <td class="px-6 py-4">
        <div class="flex justify-center space-x-3 min-w-[90px]">
            <button onclick="pickOrder(<%= o.getId() %>)"
                    class="inline-flex items-center justify-center w-10 h-10 text-green-600 bg-white border border-green-300 rounded-lg hover:bg-green-50 hover:border-green-400 transition-colors duration-200 shadow-sm cursor-pointer"
                    title="Pick / Confirm Order">
                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-5 h-5">
                    <path stroke-linecap="round" stroke-linejoin="round" d="m4.5 12.75 6 6 9-13.5" />
                </svg>
            </button>
            <a href="orderDetails.jsp?orderId=<%= o.getId() %>"
               class="inline-flex items-center justify-center w-10 h-10 text-blue-600 bg-white border border-blue-300 rounded-lg hover:bg-blue-50 hover:border-blue-400 transition-colors duration-200 shadow-sm cursor-pointer"
               title="View Details">
                <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                    <path d="M2.062 12.348a1 1 0 0 1 0-.696 10.75 10.75 0 0 1 19.876 0 1 1 0 0 1 0 .696 10.75 10.75 0 0 1-19.876 0"/>
                    <circle cx="12" cy="12" r="3"/>
                </svg>
            </a>
        </div>
    </td>
</tr>
<%
            }
        }
        return;
    }
}
%>

<jsp:include page="layout/JSPHeader.jsp" />
<div class="flex">
    <jsp:include page="layout/sidebar.jsp" />
    <div class="flex-1 sm:ml-64">
        <jsp:include page="/layout/AdminHeader.jsp" />
        <div class="p-8 max-w-8xl mx-auto">
            
            <!-- Header Section -->
            <div class="flex justify-between items-center mb-6">
                <div>
                    <h1 class="text-2xl font-bold text-gray-900">Completed Orders</h1>
                    <p class="text-gray-600 mt-1">View and manage completed food orders</p>
                </div>
            </div>

            <!-- Search and Filter -->
            <div class="flex justify-between items-center mb-6">
                <div class="flex space-x-4">
                    <input type="text" id="searchInput" placeholder="Search by ID, Name, Email, Theater..." 
                           class="px-4 py-2 border border-gray-300 rounded-lg w-80 focus:outline-none ring-transparent "/>
                </div>
                <div class="text-sm text-gray-600">
                    <span class="font-medium"><%= allCompletedOrders.size() %></span> completed orders
                </div>
            </div>

            <!-- Orders Table -->
            <div class="bg-white shadow rounded-lg border border-gray-200 overflow-hidden">
                <div class="overflow-x-auto">
                    <table class="min-w-full text-sm text-left">
                        <thead class="bg-red-50 text-gray-900 uppercase text-xs">
                            <tr>
                                <th class="px-6 py-4 font-semibold cursor-pointer" onclick="sortTable('id')">
                                    <div class="flex items-center space-x-1">
                                        <span>Order ID</span>
                                        <svg class="w-4 h-4 text-gray-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 16V4m0 0L3 8m4-4l4 4m6 0v12m0 0l4-4m-4 4l-4-4"/>
                                        </svg>
                                    </div>
                                </th>
                                <th class="px-6 py-4 font-semibold cursor-pointer" onclick="sortTable('user')">
                                    <div class="flex items-center space-x-1">
                                        <span>Customer</span>
                                        <svg class="w-4 h-4 text-gray-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 16V4m0 0L3 8m4-4l4 4m6 0v12m0 0l4-4m-4 4l-4-4"/>
                                        </svg>
                                    </div>
                                </th>
                                <th class="px-6 py-4 font-semibold cursor-pointer" onclick="sortTable('theater')">
                                    <div class="flex items-center space-x-1">
                                        <span>Theater</span>
                                        <svg class="w-4 h-4 text-gray-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 16V4m0 0L3 8m4-4l4 4m6 0v12m0 0l4-4m-4 4l-4-4"/>
                                        </svg>
                                    </div>
                                </th>
                                <th class="px-6 py-4 font-semibold">Items</th>
                                <th class="px-6 py-4 font-semibold cursor-pointer" onclick="sortTable('total')">
                                    <div class="flex items-center space-x-1">
                                        <span>Total</span>
                                        <svg class="w-4 h-4 text-gray-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 16V4m0 0L3 8m4-4l4 4m6 0v12m0 0l4-4m-4 4l-4-4"/>
                                        </svg>
                                    </div>
                                </th>
                                <th class="px-6 py-4 font-semibold">Payment</th>
                                <th class="px-6 py-4 font-semibold">Status</th>
                                <th class="px-6 py-4 font-semibold text-center">Actions</th>
                            </tr>
                        </thead>
                        <tbody id="tableBody" class="divide-y divide-gray-100"></tbody>
                    </table>
                </div>
            </div>

            <!-- Pagination -->
            <div class="flex mt-6 justify-between items-center">
                <!-- Left Section: Total and Row -->
                <div class="flex items-center gap-4">
                    <div class="text-sm text-gray-700">
                        Total <span class="shadow-sm px-3 py-2 rounded border border-gray-200 mx-2" id="totalOrders">
                            <%= allCompletedOrders.size() %>
                        </span>
                    </div>
                    <div class="flex items-center gap-2">
                        <span class="text-sm text-gray-700">Row</span>
                        <select id="recordsPerPage" onchange="handleLimitChange()"
                            class="bg-gray-50 border border-gray-300 text-gray-900 text-xs rounded-lg focus:border-red-500 block w-full p-2.5"
                            style="appearance: none; -webkit-appearance: none; -moz-appearance: none; background-image: none;">
                            <option value="5" selected>5</option>
                            <option value="10">10</option>
                            <option value="15">15</option>
                            <option value="20">20</option>
                        </select>
                    </div>
                </div>
                
                <!-- Right Section: Page Info and Navigation -->
                <div class="flex items-center gap-0">
                    <div class="text-sm text-gray-700 mr-4">
                        Page <span class="shadow-sm px-3 py-2 rounded border border-gray-200 mx-2" id="currentPage">1</span> of <span class="shadow-sm px-3 py-2 rounded border border-gray-200 mx-2" id="totalPages">1</span>
                    </div>
                    
                    <!-- Navigation Buttons - No space between -->
                    <div class="flex gap-0">
                        <!-- Previous Button -->
                        <button id="prevBtn"
                            class="flex opacity-50 cursor-not-allowed items-center justify-center px-4 h-10 text-base font-medium text-gray-500 bg-white border border-gray-300 rounded-l-lg border-r-0">
                            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7" />
                            </svg>
                        </button>
                        
                        <!-- Next Button -->
                        <button id="nextBtn"
                            class="flex opacity-50 cursor-not-allowed items-center justify-center px-4 h-10 text-base font-medium text-gray-500 bg-white border border-gray-300 rounded-r-lg">
                            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" />
                            </svg>
                        </button>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<div id="toastContainer" class="fixed top-5 right-5 z-50"></div>

<script>
let currentPage = 1;
let pageSize = 5;
let currentSortField = '';
let currentSortOrder = 'asc';

function loadOrders(page=1, query="", sortField=currentSortField, sortOrder=currentSortOrder){
    currentPage = page;
    fetch('completedOrders.jsp', {
        method: 'POST',
        headers: {'Content-Type':'application/x-www-form-urlencoded'},
        body: 'ajax_search=1&search=' + encodeURIComponent(query) +
              '&page=' + page +
              '&sortField=' + sortField +
              '&sortOrder=' + sortOrder
    })
    .then(res => res.text())
    .then(html => {
        document.getElementById('tableBody').innerHTML = html;
        renderPagination();
    });
}

function pickOrder(orderId){
    if(!confirm("Are you sure you want to pick/confirm this order?")) return;
    
    fetch('completedOrders.jsp', {
        method:'POST',
        headers:{'Content-Type':'application/x-www-form-urlencoded'},
        body:'pickOrder=1&orderId='+orderId
    })
    .then(res=>res.json())
    .then(data=>{
        if(data.success){
            showToast("Order #"+orderId+" picked successfully!");
            loadOrders(currentPage, searchInput.value, currentSortField, currentSortOrder);
        } else {
            showToast("Failed to pick order #"+orderId,true);
        }
    });
}

function showToast(msg,isError=false){
    const container = document.getElementById('toastContainer');
    const div = document.createElement('div');
    div.innerText = msg;
    div.className = `mb-2 px-4 py-2 rounded shadow text-white ${isError?'bg-red-500':'bg-green-500'} animate-fade`;
    container.appendChild(div);
    setTimeout(()=>div.remove(),3000);
}

const searchInput = document.getElementById('searchInput');
searchInput.addEventListener('input',debounce(function(){
    loadOrders(1,this.value,currentSortField,currentSortOrder);
},500));

function debounce(func,delay){
    let timer;
    return function(...args){
        clearTimeout(timer);
        timer = setTimeout(()=>func.apply(this,args),delay);
    }
}

function renderPagination(){
    const totalOrders = <%= allCompletedOrders.size() %>;
    const totalPages = Math.ceil(totalOrders / pageSize);
    
    // Update page info
    document.getElementById('currentPage').textContent = currentPage;
    document.getElementById('totalPages').textContent = totalPages;
    document.getElementById('totalOrders').textContent = totalOrders;
    
    // Update prev/next buttons
    const prevBtn = document.getElementById('prevBtn');
    const nextBtn = document.getElementById('nextBtn');
    
    if(currentPage <= 1) {
        prevBtn.classList.add('opacity-50', 'cursor-not-allowed');
        prevBtn.classList.remove('hover:bg-gray-100', 'hover:text-gray-700');
    } else {
        prevBtn.classList.remove('opacity-50', 'cursor-not-allowed');
        prevBtn.classList.add('hover:bg-gray-100', 'hover:text-gray-700');
    }
    
    if(currentPage >= totalPages) {
        nextBtn.classList.add('opacity-50', 'cursor-not-allowed');
        nextBtn.classList.remove('hover:bg-gray-100', 'hover:text-gray-700');
    } else {
        nextBtn.classList.remove('opacity-50', 'cursor-not-allowed');
        nextBtn.classList.add('hover:bg-gray-100', 'hover:text-gray-700');
    }
    
    // Add event listeners
    prevBtn.onclick = () => {
        if(currentPage > 1) {
            loadOrders(currentPage - 1, searchInput.value);
        }
    };
    
    nextBtn.onclick = () => {
        if(currentPage < totalPages) {
            loadOrders(currentPage + 1, searchInput.value);
        }
    };
}

function handleLimitChange() {
    const select = document.getElementById('recordsPerPage');
    pageSize = parseInt(select.value);
    loadOrders(1, searchInput.value);
}

// --- SORT FUNCTION ---
function sortTable(field){
    if(currentSortField===field){
        currentSortOrder = (currentSortOrder==='asc')?'desc':'asc';
    } else {
        currentSortField = field;
        currentSortOrder = 'asc';
    }
    loadOrders(1, searchInput.value, currentSortField, currentSortOrder);
}

window.onload = function(){ 
    loadOrders(); 
    document.getElementById('recordsPerPage').value = pageSize;
}
</script>

<style>
@keyframes fade{
  0%{opacity:0; transform: translateY(-10px);}
  10%{opacity:1; transform: translateY(0);}
  90%{opacity:1;}
  100%{opacity:0; transform: translateY(-10px);}
}
.animate-fade{animation: fade 3s forwards;}
</style>

<jsp:include page="layout/JSPFooter.jsp"/>