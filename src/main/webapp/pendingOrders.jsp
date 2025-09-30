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

List<Order> allPendingOrders = orderDAO.getPendingOrders();
if ("theateradmin".equals(role)) {
    List<Theater> myTheaters = theaterDAO.getTheatersByUserId(loggedInUserId);
    allPendingOrders.removeIf(o -> myTheaters.stream().noneMatch(t -> t.getTheaterId() == o.getTheaterId()));
} else if (!"admin".equals(role)) {
    allPendingOrders = Collections.emptyList();
}

// --- AJAX HANDLER ---
if("POST".equalsIgnoreCase(request.getMethod())){
    if(request.getParameter("completeOrder") != null){
        int orderId = Integer.parseInt(request.getParameter("orderId"));
        boolean success = orderDAO.markOrderComplete(orderId);
        out.print("{\"success\":" + success + "}");
        return;
    }

    if("1".equals(request.getParameter("ajax_search"))){
        String searchQuery = request.getParameter("search");
        String sortField = request.getParameter("sortField");
        String sortOrder = request.getParameter("sortOrder");
        if(searchQuery != null && !searchQuery.trim().isEmpty()){
            String keyword = searchQuery.toLowerCase();
            allPendingOrders.removeIf(o -> {
                User u = userDAO.getUserById(o.getUserId());
                Theater t = theaterDAO.getTheaterById(o.getTheaterId());
                String userName = (u!=null)?u.getName().toLowerCase():"";
                String email = (u!=null)?u.getEmail().toLowerCase():"";
                String theaterName = (t!=null)?t.getName().toLowerCase():"";
                return !(String.valueOf(o.getId()).contains(keyword) ||
                         userName.contains(keyword) ||
                         email.contains(keyword) ||
                         theaterName.contains(keyword));
            });
        }

        // --- SORTING ---
        if(sortField != null && !sortField.isEmpty()){
            Comparator<Order> comp = Comparator.comparing(Order::getId);
            if("id".equals(sortField)) comp = Comparator.comparing(Order::getId);
            else if("total".equals(sortField)) comp = Comparator.comparing(Order::getTotalAmount);
            else if("customer".equals(sortField)) comp = Comparator.comparing(o -> {
                User u = userDAO.getUserById(o.getUserId());
                return u!=null?u.getName():"";
            });
            else if("theater".equals(sortField)) comp = Comparator.comparing(o -> {
                Theater t = theaterDAO.getTheaterById(o.getTheaterId());
                return t!=null?t.getName():"";
            });

            if("desc".equals(sortOrder)) comp = comp.reversed();
            allPendingOrders.sort(comp);
        }
    }

    int currentPage = request.getParameter("page")!=null?Integer.parseInt(request.getParameter("page")):1;
    int totalOrders = allPendingOrders.size();
    int start = (currentPage-1)*pageSize;
    int end = Math.min(start+pageSize, totalOrders);
    List<Order> pageOrders = (start<end)?allPendingOrders.subList(start,end):List.of();

    if(pageOrders.isEmpty()){
        out.print("<tr><td colspan='7' class='px-6 py-4 text-center text-gray-500'>No orders found.</td></tr>");
    } else {
        for(Order o : pageOrders){
            User user = userDAO.getUserById(o.getUserId());
            Theater theater = theaterDAO.getTheaterById(o.getTheaterId());
%>
<tr class="hover:bg-gray-50" id="orderRow_<%=o.getId()%>">
    <td class="px-6 py-4"><%=o.getId()%></td>
    <td class="px-6 py-4 font-medium text-gray-900">
        <p><%= (user!=null?user.getName():"Unknown") %></p>
        <p class="text-sm text-gray-500"><%= (user!=null?user.getEmail():"") %></p>
        <p class="text-sm text-gray-500"><%= (user!=null?user.getPhone():"") %></p>
    </td>
    <td class="px-6 py-4">
        <p><%= (theater!=null?theater.getName():"Unknown") %></p>
        <p class="text-sm text-gray-500"><%= (theater!=null?theater.getLocation():"") %></p>
    </td>
    <td class="px-6 py-4">
        <ul class="space-y-1">
        <% for(OrderItem item:o.getItems()){ %>
            <li class="flex items-center">
                <img src="<%=item.getFood().getImage()%>" class="w-10 h-10 rounded mr-2"/>
                <span><%=item.getFood().getName()%> x <%=item.getQuantity()%></span>
            </li>
        <% } %>
        </ul>
    </td>
    <td class="px-6 py-4 font-semibold text-green-600">$<%=o.getTotalAmount()%></td>
    <td class="px-6 py-4">
        <span class="px-2 py-1 rounded text-xs font-semibold bg-yellow-100 text-yellow-700">
            <%= o.getStatus() %>
        </span>
    </td>
    <td class="px-6 py-4 text-center flex justify-center space-x-2">
        <button onclick="completeOrder(<%= o.getId() %>)"
                class="bg-green-500 text-white px-3 py-1 rounded hover:bg-green-600 text-sm">
            Complete
        </button>
        <form action="orderDetails.jsp" method="get" style="display:inline-block">
            <input type="hidden" name="orderId" value="<%= o.getId() %>"/>
            <button type="submit" class="bg-blue-500 text-white px-3 py-1 rounded hover:bg-blue-600 text-sm">View Details</button>
        </form>
    </td>
</tr>
<%
        }
    }
    return;
}
%>

<jsp:include page="layout/JSPHeader.jsp"/>
<div class="flex">
    <jsp:include page="layout/sidebar.jsp"/>
    <div class="flex-1 sm:ml-64">
        <jsp:include page="/layout/AdminHeader.jsp"/>
        <div class="p-8">
            <h1 class="text-2xl font-bold mb-6 text-gray-900">Pending Orders</h1>

            <div id="toastContainer" class="fixed top-5 right-5 z-50"></div>

            <div class="flex justify-between items-center mb-4">
                <input type="text" id="searchInput" placeholder="Search by ID, Name, Email..."
                       class="px-4 py-2 border rounded-lg w-80 focus:outline-none focus:ring-2 focus:ring-blue-500"/>
            </div>

            <div class="overflow-x-auto bg-white shadow rounded-lg">
                <table class="min-w-full text-sm text-left">
                    <thead class="bg-gray-100 text-gray-700 uppercase text-xs">
                        <tr>
                            <th class="px-6 py-3 cursor-pointer" onclick="sortTable('id')">Order ID</th>
                            <th class="px-6 py-3 cursor-pointer" onclick="sortTable('customer')">Customer</th>
                            <th class="px-6 py-3 cursor-pointer" onclick="sortTable('theater')">Theater</th>
                            <th class="px-6 py-3">Items</th>
                            <th class="px-6 py-3 cursor-pointer" onclick="sortTable('total')">Total</th>
                            <th class="px-6 py-3">Status</th>
                            <th class="px-6 py-3 text-center">Action</th>
                        </tr>
                    </thead>
                    <tbody id="tableBody"></tbody>
                </table>
            </div>

            <div id="pagination" class="flex justify-center mt-6 space-x-1"></div>
        </div>
    </div>
</div>

<script>
let currentPage = 1;
const pageSize = 5;
let currentSortField = '';
let currentSortOrder = 'asc';

function loadOrders(page=1, query="", sortField=currentSortField, sortOrder=currentSortOrder){
    currentPage = page;
    fetch('pendingOrders.jsp', {
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

function completeOrder(orderId){
    fetch('pendingOrders.jsp',{
        method:'POST',
        headers:{'Content-Type':'application/x-www-form-urlencoded'},
        body:'completeOrder=1&orderId='+orderId
    })
    .then(res=>res.json())
    .then(data=>{
        if(data.success){
            showToast("Order #"+orderId+" completed!");
            loadOrders(currentPage, document.getElementById('searchInput').value);
        } else {
            showToast("Failed to complete order #"+orderId,true);
        }
    });
}

function showToast(msg,isError=false){
    const container = document.getElementById('toastContainer');
    const div = document.createElement('div');
    div.innerText = msg;
    div.className = `mb-2 px-4 py-2 rounded shadow text-white ${isError?'bg-red-500':'bg-green-300'} animate-fade`;
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
    const totalOrders = <%= allPendingOrders.size() %>;
    const totalPages = Math.ceil(totalOrders / pageSize);
    const container = document.getElementById('pagination');
    container.innerHTML = '';

    const prev = document.createElement('a');
    prev.href = "javascript:void(0)";
    prev.innerText = "Prev";
    prev.className = "px-4 py-2 rounded-md border "+(currentPage===1?"bg-gray-200 text-gray-500":"bg-white text-gray-700 hover:bg-blue-100");
    prev.addEventListener('click',()=>{ if(currentPage>1) loadOrders(currentPage-1,searchInput.value); });
    container.appendChild(prev);

    for(let i=1;i<=totalPages;i++){
        const a = document.createElement('a');
        a.href = "javascript:void(0)";
        a.innerText = i;
        a.className = "px-4 py-2 rounded-md border "+(i===currentPage?"bg-blue-600 text-white":"bg-white text-gray-700 hover:bg-blue-100");
        a.addEventListener('click',()=>loadOrders(i,searchInput.value));
        container.appendChild(a);
    }

    const next = document.createElement('a');
    next.href = "javascript:void(0)";
    next.innerText = "Next";
    next.className = "px-4 py-2 rounded-md border "+(currentPage===totalPages?"bg-gray-200 text-gray-500":"bg-white text-gray-700 hover:bg-blue-100");
    next.addEventListener('click',()=>{ if(currentPage<totalPages) loadOrders(currentPage+1,searchInput.value); });
    container.appendChild(next);
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

window.onload = function(){ loadOrders(); }
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
