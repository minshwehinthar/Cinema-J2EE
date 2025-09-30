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
        out.print("<tr><td colspan='8' class='px-6 py-4 text-center text-gray-500'>No orders found.</td></tr>");
    } else {
        for (OrderHistory o : pageOrders) {
            User user = userDAO.getUserById(o.getUserId());
            Theater theater = theaterDAO.getTheaterById(o.getTheaterId());
%>
<tr id="orderRow<%= o.getOrderId() %>" class="hover:bg-gray-50">
    <td class="px-6 py-4"><%= o.getOrderId() %></td>
    <td class="px-6 py-4 font-medium text-gray-900">
        <p><%= (user != null ? user.getName() : "Unknown") %></p>
        <p class="text-sm text-gray-500"><%= (user != null ? user.getEmail() : "") %></p>
        <p class="text-sm text-gray-500"><%= (user != null ? user.getPhone() : "") %></p>
    </td>
    <td class="px-6 py-4">
        <p><%= (theater != null ? theater.getName() : "Unknown") %></p>
        <p class="text-sm text-gray-500"><%= (theater != null ? theater.getLocation() : "") %></p>
    </td>
    <td class="px-6 py-4">
        <ul class="space-y-1">
        <% for (OrderItemHistory item : o.getItems()) {
            FoodItem food = foodDAO.getFoodById(item.getFoodId());
            String img = (food != null && food.getImage() != null) ? food.getImage() : "images/placeholder.png";
        %>
            <li class="flex items-center">
                <img src="<%= img %>" class="w-10 h-10 rounded mr-2"/>
                <span><%= (food != null ? food.getName() : "Food ID " + item.getFoodId()) %> x <%= item.getQuantity() %></span>
            </li>
        <% } %>
        </ul>
    </td>
    <td class="px-6 py-4 font-semibold text-green-600">$<%= o.getTotalAmount() %></td>
    <td class="px-6 py-4"><%= o.getPaymentMethod() %></td>
    <td class="px-6 py-4">
        <span class="px-2 py-1 rounded text-xs font-semibold bg-orange-100 text-orange-700">
            Picked
        </span>
    </td>
    <td class="px-6 py-4 text-center">
        <button onclick="deleteOrder(<%= o.getOrderId() %>)"
                class="bg-red-500 text-white px-3 py-1 rounded hover:bg-red-600 text-sm">
            Delete
        </button>
        <form action="orderDetails.jsp" method="get" style="display:inline-block">
            <input type="hidden" name="orderId" value="<%= o.getId() %>"/>
            <button type="submit" class="bg-blue-500 text-white px-3 py-1 rounded hover:bg-blue-600 text-sm">
                View Details
            </button>
        </form>
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
            <h1 class="text-2xl font-bold mb-6 text-gray-900">Order History</h1>

            <div class="flex justify-start mb-4">
                <input type="text" id="searchInput" placeholder="Search by ID, Customer, Theater..."
                       class="px-4 py-2 border rounded-lg w-80 focus:outline-none focus:ring-2 focus:ring-blue-500"/>
            </div>

            <div class="overflow-x-auto bg-white shadow rounded-lg">
                <table class="min-w-full text-sm text-left">
                    <thead class="bg-gray-100 text-gray-700 uppercase text-xs">
                        <tr>
                            <th class="px-6 py-3 cursor-pointer" onclick="sortTable('id')">Order ID</th>
                            <th class="px-6 py-3 cursor-pointer" onclick="sortTable('name')">Customer</th>
                            <th class="px-6 py-3">Theater</th>
                            <th class="px-6 py-3">Items</th>
                            <th class="px-6 py-3 cursor-pointer" onclick="sortTable('price')">Total</th>
                            <th class="px-6 py-3">Payment</th>
                            <th class="px-6 py-3">Status</th>
                            <th class="px-6 py-3 text-center">Action</th>
                        </tr>
                    </thead>
                    <tbody id="tableBody"></tbody>
                </table>
            </div>

            <div class="flex justify-center mt-6 space-x-1" id="pagination"></div>
        </div>
    </div>
</div>

<script>
let currentPage = 1;
let currentSortField = '';
let currentSortOrder = 'asc';
const pageSize = 5;

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
    if(!confirm('Are you sure you want to delete this order?')) return;
    fetch('order-history.jsp', {
        method:'POST',
        headers:{'Content-Type':'application/x-www-form-urlencoded'},
        body:'deleteId='+orderId
    })
    .then(res=>res.text())
    .then(response=>{
        if(response.trim()==='success'){
            loadOrders(currentPage, document.getElementById('searchInput').value);
        } else alert("Failed to delete order.");
    });
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

<jsp:include page="layout/JSPFooter.jsp" />
