<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.Connection, java.util.List, java.util.Collections" %>
<%@ page import="com.demo.dao.MyConnection, com.demo.dao.OrderHistoryDAO, com.demo.dao.FoodDAO" %>
<%@ page import="com.demo.dao.UserDAO, com.demo.dao.TheaterDAO" %>
<%@ page import="com.demo.model.OrderHistory, com.demo.model.OrderItemHistory, com.demo.model.FoodItem" %>
<%@ page import="com.demo.model.User, com.demo.model.Theater" %>

<%
Connection conn = null;
List<OrderHistory> allOrders = null;
FoodDAO foodDAO = null;
UserDAO userDAO = new UserDAO();
TheaterDAO theaterDAO = new TheaterDAO();
int pageSize = 5;

try {
    conn = MyConnection.getConnection();
    OrderHistoryDAO orderHistoryDAO = new OrderHistoryDAO(conn);
    foodDAO = new FoodDAO();

    // DELETE HANDLER
    if ("POST".equalsIgnoreCase(request.getMethod()) && request.getParameter("deleteId") != null) {
        int deleteId = Integer.parseInt(request.getParameter("deleteId"));
        boolean deleted = orderHistoryDAO.deleteOrder(deleteId);
        out.print(deleted ? "success" : "fail");
        return;
    }

    allOrders = orderHistoryDAO.getAllOrderHistory();
} catch (Exception e) {
    e.printStackTrace();
    out.println("<p class='text-red-500'>Error: " + e.getMessage() + "</p>");
}

// --- AJAX HANDLER ---
if ("POST".equalsIgnoreCase(request.getMethod()) && "1".equals(request.getParameter("ajax_search"))) {
    String searchQuery = request.getParameter("search");
    String sortField = request.getParameter("sortField");
    String sortOrder = request.getParameter("sortOrder");

    if (searchQuery != null && !searchQuery.trim().isEmpty()) {
        String keyword = searchQuery.toLowerCase();
        final UserDAO finalUserDAO = userDAO;      
        final TheaterDAO finalTheaterDAO = theaterDAO;
        allOrders.removeIf(o -> {
            User user = finalUserDAO.getUserById(o.getUserId());
            Theater theater = finalTheaterDAO.getTheaterById(o.getTheaterId());
            String userName = (user != null ? user.getName().toLowerCase() : "");
            String email = (user != null ? user.getEmail().toLowerCase() : "");
            String theaterName = (theater != null ? theater.getName().toLowerCase() : "");
            return !(String.valueOf(o.getOrderId()).contains(keyword) ||
                     userName.contains(keyword) ||
                     email.contains(keyword) ||
                     theaterName.contains(keyword));
        });
    }

    if (allOrders != null && sortField != null && !sortField.isEmpty()) {
        Collections.sort(allOrders, (o1, o2) -> {
            int result = 0;
            switch(sortField) {
                case "id": result = Integer.compare(o1.getOrderId(), o2.getOrderId()); break;
                case "name":
                    User u1 = userDAO.getUserById(o1.getUserId());
                    User u2 = userDAO.getUserById(o2.getUserId());
                    String n1 = (u1 != null ? u1.getName() : "");
                    String n2 = (u2 != null ? u2.getName() : "");
                    result = n1.compareToIgnoreCase(n2); break;
                case "price": result = Double.compare(o1.getTotalAmount(), o2.getTotalAmount()); break;
            }
            return "desc".equalsIgnoreCase(sortOrder) ? -result : result;
        });
    }

    int currentPage = request.getParameter("page") != null ? Integer.parseInt(request.getParameter("page")) : 1;
    int totalOrders = allOrders.size();
    int start = (currentPage - 1) * pageSize;
    int end = Math.min(start + pageSize, totalOrders);
    List<OrderHistory> pageOrders = (start < end) ? allOrders.subList(start, end) : Collections.emptyList();

    if (pageOrders.isEmpty()) {
        out.print("<tr><td colspan='8' class='px-6 py-8 text-center'><div class='w-16 h-16 mx-auto mb-4 text-gray-300'><svg fill='none' stroke='currentColor' viewBox='0 0 24 24'><path stroke-linecap='round' stroke-linejoin='round' stroke-width='1' d='M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2m-6 9l2 2 4-4'/></svg></div><h3 class='text-lg font-medium text-gray-600 mb-2'>No order history found</h3><p class='text-gray-500'>All orders are processed or try adjusting your search.</p></td></tr>");
    } else {
        for (OrderHistory o : pageOrders) {
            User user = userDAO.getUserById(o.getUserId());
            Theater theater = theaterDAO.getTheaterById(o.getTheaterId());
%>
<tr class="hover:bg-red-50 transition-colors duration-150" id="orderRow<%= o.getOrderId() %>">
    <td class="px-6 py-4">
        <div class="flex items-center space-x-3">
            <div class="w-10 h-10 bg-red-100 rounded-lg flex items-center justify-center">
                <span class="text-red-600 font-bold text-sm">#<%= o.getOrderId() %></span>
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
        <% for (OrderItemHistory item : o.getItems()) {
            FoodItem food = foodDAO.getFoodById(item.getFoodId());
            String img = (food != null && food.getImage() != null) ? food.getImage() : "images/placeholder.png";
        %>
            <div class="flex items-center space-x-3 p-2 bg-gray-50 rounded-lg">
                <img src="<%= img %>" alt="<%= (food != null ? food.getName() : "Food") %>" 
                     class="w-8 h-8 rounded object-cover border border-gray-200"/>
                <div class="flex-1 min-w-0">
                    <div class="text-sm font-medium text-gray-900 truncate"><%= (food != null ? food.getName() : "Food ID " + item.getFoodId()) %></div>
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
        <span class="inline-flex items-center px-3 py-1 rounded-full text-xs font-medium bg-orange-100 text-orange-800 border border-orange-200">
            Picked
        </span>
    </td>
    <td class="px-6 py-4">
        <div class="flex justify-center space-x-3 min-w-[90px]">
            <a href="orderDetails.jsp?orderId=<%= o.getOrderId() %>"
               class="inline-flex items-center justify-center w-10 h-10 text-blue-600 bg-white border border-blue-300 rounded-lg hover:bg-blue-50 hover:border-blue-400 transition-colors duration-200 shadow-sm cursor-pointer"
               title="View Details">
                <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                    <path d="M2.062 12.348a1 1 0 0 1 0-.696 10.75 10.75 0 0 1 19.876 0 1 1 0 0 1 0 .696 10.75 10.75 0 0 1-19.876 0"/>
                    <circle cx="12" cy="12" r="3"/>
                </svg>
            </a>
            <button onclick="deleteOrder(<%= o.getOrderId() %>)"
                    class="inline-flex items-center justify-center w-10 h-10 text-red-600 bg-white border border-red-300 rounded-lg hover:bg-red-50 hover:border-red-400 transition-colors duration-200 shadow-sm cursor-pointer"
                    title="Delete Order">
                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-5 h-5">
                    <path stroke-linecap="round" stroke-linejoin="round" d="m14.74 9-.346 9m-4.788 0L9.26 9m9.968-3.21c.342.052.682.107 1.022.166m-1.022-.165L18.16 19.673a2.25 2.25 0 0 1-2.244 2.077H8.084a2.25 2.25 0 0 1-2.244-2.077L4.772 5.79m14.456 0a48.108 48.108 0 0 0-3.478-.397m-12 .562c.34-.059.68-.114 1.022-.165m0 0a48.11 48.11 0 0 1 3.478-.397m7.5 0v-.916c0-1.18-.91-2.164-2.09-2.201a51.964 51.964 0 0 0-3.32 0c-1.18.037-2.09 1.022-2.09 2.201v.916m7.5 0a48.667 48.667 0 0 0-7.5 0" />
                </svg>
            </button>
        </div>
    </td>
</tr>
<%
        }
    }
    return;
}
%>

<jsp:include page="layout/JSPHeader.jsp" />
<div class="flex">
    <jsp:include page="layout/sidebar.jsp" />
    <div class="flex-1 sm:ml-64">
        <jsp:include page="layout/AdminHeader.jsp" />
        <div class="p-8 max-w-8xl mx-auto">
            
            <!-- Header Section -->
            <div class="flex justify-between items-center mb-6">
                <div>
                <!-- Breadcrumb -->
				<nav class="text-gray-500 text-sm mb-6" aria-label="Breadcrumb">
					<ol class="list-none p-0 inline-flex">
						<li><a href="index.jsp" class="hover:text-red-600">Home</a></li>
						<li><span class="mx-2">/</span></li>

						<li class="flex items-center text-gray-900 font-semibold">Orders History</li>
					</ol>
				</nav>
                    <h1 class="text-2xl font-bold text-gray-900">Order History</h1>
                    <p class="text-gray-600 mt-1">View complete order history and records</p>
                </div>
            </div>

            <!-- Search and Filter -->
            <div class="flex justify-between items-center mb-6">
                <div class="flex space-x-4">
                    <input type="text" id="searchInput" placeholder="Search by ID, Customer, Theater..." 
                           class="px-4 py-2 border border-gray-300 rounded-lg w-80 focus:outline-none ring-transparent "/>
                </div>
                <div class="text-sm text-gray-600">
                    <span class="font-medium"><%= allOrders.size() %></span> total orders
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
                                <th class="px-6 py-4 font-semibold cursor-pointer" onclick="sortTable('name')">
                                    <div class="flex items-center space-x-1">
                                        <span>Customer</span>
                                        <svg class="w-4 h-4 text-gray-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 16V4m0 0L3 8m4-4l4 4m6 0v12m0 0l4-4m-4 4l-4-4"/>
                                        </svg>
                                    </div>
                                </th>
                                <th class="px-6 py-4 font-semibold">Theater</th>
                                <th class="px-6 py-4 font-semibold">Items</th>
                                <th class="px-6 py-4 font-semibold cursor-pointer" onclick="sortTable('price')">
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
                            <%= allOrders.size() %>
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
    fetch('order-history.jsp', {
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

function deleteOrder(orderId){
    if(!confirm('Are you sure you want to delete this order from history?')) return;
    fetch('order-history.jsp', {
        method:'POST',
        headers:{'Content-Type':'application/x-www-form-urlencoded'},
        body:'deleteId='+orderId
    })
    .then(res=>res.text())
    .then(response=>{
        if(response.trim()==='success'){
            showToast("Order #" + orderId + " deleted successfully!");
            loadOrders(currentPage, document.getElementById('searchInput').value);
        } else {
            showToast("Failed to delete order #" + orderId, true);
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
    const totalOrders = <%= allOrders.size() %>;
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

<jsp:include page="layout/JSPFooter.jsp" />