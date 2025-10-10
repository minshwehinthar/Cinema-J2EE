<%@ page import="java.sql.*, java.util.*" %>
<%@ page import="com.demo.model.User" %>
<%@ page import="com.demo.dao.MyConnection" %>
<%
User user = (User) session.getAttribute("user");
if(user == null){
    response.sendRedirect("login.jsp");
    return;
}
int userId = user.getUserId(); 
%>

<%-- AJAX-only rendering --%>
<%
if(request.getParameter("ajax") != null){
    String filterStatus = request.getParameter("status") != null ? request.getParameter("status") : "all";
    String searchQuery = request.getParameter("search") != null ? request.getParameter("search") : "";
    String sortField = request.getParameter("sortField") != null ? request.getParameter("sortField") : "created_at";
    String sortOrder = request.getParameter("sortOrder") != null ? request.getParameter("sortOrder") : "desc";
    int pageSize = 5;
    int currentPageParam = request.getParameter("page") != null ? Integer.parseInt(request.getParameter("page")) : 1;
    int offset = (currentPageParam -1)*pageSize;

    Connection conn = null;
    PreparedStatement psOrder = null;
    ResultSet rsOrder = null;
    List<Map<String,Object>> orders = new ArrayList<>();
    int totalOrders = 0;
    int totalPages = 0;

    try{
        conn = MyConnection.getConnection();

        // Count total
        String sqlCount = "SELECT COUNT(*) FROM orders o JOIN theaters t ON o.theater_id = t.theater_id " +
                          "WHERE o.user_id=? AND (o.status LIKE ? OR ?='all') AND (CAST(o.id AS CHAR) LIKE ? OR t.name LIKE ?)";
        psOrder = conn.prepareStatement(sqlCount);
        psOrder.setInt(1, userId);
        psOrder.setString(2, filterStatus.equals("all")?"%":filterStatus);
        psOrder.setString(3, filterStatus);
        psOrder.setString(4, "%"+searchQuery+"%");
        psOrder.setString(5, "%"+searchQuery+"%");
        rsOrder = psOrder.executeQuery();
        if(rsOrder.next()) totalOrders = rsOrder.getInt(1);
        rsOrder.close();
        psOrder.close();

        // Fetch
        String sqlOrder = "SELECT o.id, o.total_amount, o.payment_method, o.status, o.created_at, t.name AS theater_name " +
                          "FROM orders o JOIN theaters t ON o.theater_id = t.theater_id " +
                          "WHERE o.user_id=? AND (o.status LIKE ? OR ?='all') AND (CAST(o.id AS CHAR) LIKE ? OR t.name LIKE ?) " +
                          "ORDER BY " + sortField + " " + sortOrder +
                          " LIMIT ? OFFSET ?";

        psOrder = conn.prepareStatement(sqlOrder);
        psOrder.setInt(1, userId);
        psOrder.setString(2, filterStatus.equals("all")?"%":filterStatus);
        psOrder.setString(3, filterStatus);
        psOrder.setString(4, "%"+searchQuery+"%");
        psOrder.setString(5, "%"+searchQuery+"%");
        psOrder.setInt(6, pageSize);
        psOrder.setInt(7, offset);
        rsOrder = psOrder.executeQuery();

        while(rsOrder.next()){
            Map<String,Object> order = new HashMap<>();
            order.put("id", rsOrder.getInt("id"));
            order.put("total_amount", rsOrder.getDouble("total_amount"));
            order.put("payment_method", rsOrder.getString("payment_method"));
            order.put("status", rsOrder.getString("status"));
            order.put("created_at", rsOrder.getTimestamp("created_at"));
            order.put("theater_name", rsOrder.getString("theater_name"));
            orders.add(order);
        }

        totalPages = (int)Math.ceil((double)totalOrders/pageSize);

        // Render rows
        if(orders.isEmpty()){
            out.println("<tr><td colspan='7' class='px-6 py-8 text-center'><div class='w-16 h-16 mx-auto mb-4 text-gray-300'><svg fill='none' stroke='currentColor' viewBox='0 0 24 24'><path stroke-linecap='round' stroke-linejoin='round' stroke-width='1' d='M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2m-6 9l2 2 4-4'/></svg></div><h3 class='text-lg font-medium text-gray-600 mb-2'>No orders found</h3><p class='text-gray-500'>Try adjusting your filters or search to find what you're looking for.</p></td></tr>");
        } else {
            for(Map<String,Object> order: orders){
                String status = (String) order.get("status");
                String statusClass = "";
                if("pending".equalsIgnoreCase(status)) {
                    statusClass = "bg-yellow-100 text-yellow-800 border-yellow-200";
                } else if("completed".equalsIgnoreCase(status)) {
                    statusClass = "bg-green-100 text-green-800 border-green-200";
                } else if("picked".equalsIgnoreCase(status)) {
                    statusClass = "bg-blue-100 text-blue-800 border-blue-200";
                } else {
                    statusClass = "bg-gray-100 text-gray-800 border-gray-200";
                }
%>
<tr class="hover:bg-red-50 transition-colors duration-150">
    <td class="px-6 py-4">
        <div class="flex items-center space-x-3">
            <div class="w-10 h-10 bg-red-100 rounded-lg flex items-center justify-center">
                <span class="text-red-600 font-bold text-sm">#<%=order.get("id")%></span>
            </div>
        </div>
    </td>
    <td class="px-6 py-4">
        <div class="font-medium text-gray-900"><%=order.get("theater_name")%></div>
    </td>
    <td class="px-6 py-4">
        <div class="text-gray-900"><%=order.get("created_at")%></div>
    </td>
    <td class="px-6 py-4">
        <span class="inline-flex items-center px-3 py-1 rounded-full text-xs font-medium bg-purple-100 text-purple-800 border border-purple-200 capitalize">
            <%=order.get("payment_method")%>
        </span>
    </td>
    <td class="px-6 py-4">
        <span class="inline-flex items-center px-3 py-1 rounded-full text-xs font-medium border <%=statusClass%>">
            <%=status.toUpperCase()%>
        </span>
    </td>
    <td class="px-6 py-4 text-right">
        <div class="font-semibold text-red-600">$<%=order.get("total_amount")%></div>
    </td>
    <td class="px-6 py-4">
        <div class="flex justify-center">
            <a href="order-details.jsp?orderId=<%=order.get("id")%>" 
               class="inline-flex items-center justify-center w-10 h-10 text-blue-600 bg-white border border-blue-300 rounded-lg hover:bg-blue-50 hover:border-blue-400 transition-colors duration-200 shadow-sm cursor-pointer"
               title="View Order Details">
                <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                    <path d="M2.062 12.348a1 1 0 0 1 0-.696 10.75 10.75 0 0 1 19.876 0 1 1 0 0 1 0 .696 10.75 10.75 0 0 1-19.876 0"/>
                    <circle cx="12" cy="12" r="3"/>
                </svg>
            </a>
        </div>
    </td>
</tr>
<%          } %>
<input type="hidden" id="totalPages" value="<%=totalPages%>"/>
<input type="hidden" id="totalOrders" value="<%=totalOrders%>"/>
<%
        }
    } catch(Exception e){
        out.println("<tr><td colspan='7' class='text-red-500'>Error: "+e.getMessage()+"</td></tr>");
    } finally{
        if(rsOrder!=null) rsOrder.close();
        if(psOrder!=null) psOrder.close();
        if(conn!=null) conn.close();
    }
    return;
}
%>

<jsp:include page="layout/JSPHeader.jsp"/>

<style>
/* Sticky footer */
body {
  display: flex;
  flex-direction: column;
  min-height: 100vh;
}
main {
  flex: 1;
}
</style>
</head>
<body class="bg-white font-sans">
<jsp:include page="layout/header.jsp"></jsp:include>

<main class="max-w-8xl mx-auto py-8 px-4 w-full">
<!-- Breadcrumb -->
		<nav class="text-gray-500 text-sm mb-4" aria-label="Breadcrumb">
			<ol class="list-none p-0 inline-flex">
				<li><a href="home.jsp" class="hover:text-red-600">Home</a></li>
            <li><span class="mx-2">/</span></li>
            
				<li class="flex items-center text-gray-900 font-semibold">My Orders
				</li>
			</ol>
		</nav>
    <!-- Header Section -->
    <div class="flex justify-between items-center mb-8">
        <div>
            <h1 class="text-2xl font-bold text-gray-900">My Orders</h1>
            <p class="text-gray-600 mt-1">View and manage your food orders</p>
        </div>
    </div>

    <!-- Filters and Search -->
    <div class="flex justify-between items-center mb-6">
        <!-- Status Filter -->
        <div class="flex gap-2">
            <button class="statusBtn px-4 py-2 rounded-lg border border-gray-300 bg-white text-gray-700 hover:bg-gray-50 hover:border-gray-400 transition-colors duration-200 text-sm font-medium" data-status="all">All Orders</button>
            <button class="statusBtn px-4 py-2 rounded-lg border border-gray-300 bg-white text-gray-700 hover:bg-gray-50 hover:border-gray-400 transition-colors duration-200 text-sm font-medium" data-status="pending">Pending</button>
            <button class="statusBtn px-4 py-2 rounded-lg border border-gray-300 bg-white text-gray-700 hover:bg-gray-50 hover:border-gray-400 transition-colors duration-200 text-sm font-medium" data-status="completed">Completed</button>
            <button class="statusBtn px-4 py-2 rounded-lg border border-gray-300 bg-white text-gray-700 hover:bg-gray-50 hover:border-gray-400 transition-colors duration-200 text-sm font-medium" data-status="picked">Picked</button>
        </div>

        <!-- Search -->
        <div class="relative">
            <input type="text" id="searchInput" placeholder="Search orders..." 
                   class="px-4 py-2 border border-gray-300 rounded-lg w-80 focus:outline-none ring-transparent text-sm"/>
        </div>
    </div>

    <!-- Orders Table -->
    <div class="bg-white shadow rounded-lg border border-gray-200 overflow-hidden">
        <div class="overflow-x-auto">
            <table class="min-w-full text-sm text-left">
                <thead class="bg-red-50 text-gray-900 uppercase text-xs">
                    <tr>
                        <th class="px-6 py-4 font-semibold cursor-pointer sort" data-field="id">
                            <div class="flex items-center space-x-1">
                                <span>Order ID</span>
                                <svg class="w-4 h-4 text-gray-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 16V4m0 0L3 8m4-4l4 4m6 0v12m0 0l4-4m-4 4l-4-4"/>
                                </svg>
                            </div>
                        </th>
                        <th class="px-6 py-4 font-semibold cursor-pointer sort" data-field="theater_name">
                            <div class="flex items-center space-x-1">
                                <span>Theater</span>
                                <svg class="w-4 h-4 text-gray-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 16V4m0 0L3 8m4-4l4 4m6 0v12m0 0l4-4m-4 4l-4-4"/>
                                </svg>
                            </div>
                        </th>
                        <th class="px-6 py-4 font-semibold cursor-pointer sort" data-field="created_at">
                            <div class="flex items-center space-x-1">
                                <span>Ordered At</span>
                                <svg class="w-4 h-4 text-gray-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 16V4m0 0L3 8m4-4l4 4m6 0v12m0 0l4-4m-4 4l-4-4"/>
                                </svg>
                            </div>
                        </th>
                        <th class="px-6 py-4 font-semibold">Payment</th>
                        <th class="px-6 py-4 font-semibold cursor-pointer sort" data-field="status">
                            <div class="flex items-center space-x-1">
                                <span>Status</span>
                                <svg class="w-4 h-4 text-gray-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 16V4m0 0L3 8m4-4l4 4m6 0v12m0 0l4-4m-4 4l-4-4"/>
                                </svg>
                            </div>
                        </th>
                        <th class="px-6 py-4 font-semibold cursor-pointer sort text-right" data-field="total_amount">
                            <div class="flex items-center space-x-1 justify-end">
                                <span>Total</span>
                                <svg class="w-4 h-4 text-gray-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 16V4m0 0L3 8m4-4l4 4m6 0v12m0 0l4-4m-4 4l-4-4"/>
                                </svg>
                            </div>
                        </th>
                        <th class="px-6 py-4 font-semibold text-center">Action</th>
                    </tr>
                </thead>
                <tbody id="ordersContainer" class="divide-y divide-gray-100"></tbody>
            </table>
        </div>
    </div>

    <!-- Pagination -->
    <div class="flex mt-6 justify-between items-center">
        <!-- Left Section: Total and Row -->
        <div class="flex items-center gap-4">
            <div class="text-sm text-gray-700">
                Total <span class="shadow-sm px-3 py-2 rounded border border-gray-200 mx-2" id="totalOrdersDisplay">0</span>
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
                Page <span class="shadow-sm px-3 py-2 rounded border border-gray-200 mx-2" id="currentPage">1</span> of <span class="shadow-sm px-3 py-2 rounded border border-gray-200 mx-2" id="totalPagesDisplay">1</span>
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
</main>

<!-- Sticky footer -->
<jsp:include page="layout/footer.jsp"></jsp:include>

<script>
const ordersContainer = document.getElementById('ordersContainer');
const pagination = document.getElementById('pagination');
let currentStatus = 'all';
let currentSearch = '';
let sortField = 'created_at';
let sortOrder = 'desc';
let currentPage = 1;
let pageSize = 5;

function highlightStatusButton() {
    document.querySelectorAll('.statusBtn').forEach(btn => {
        if (btn.getAttribute('data-status') === currentStatus) {
            btn.classList.add('border-red-500', 'bg-red-50', 'text-red-600', 'font-medium');
            btn.classList.remove('border-gray-300', 'bg-white', 'text-gray-700');
        } else {
            btn.classList.remove('border-red-500', 'bg-red-50', 'text-red-600', 'font-medium');
            btn.classList.add('border-gray-300', 'bg-white', 'text-gray-700');
        }
    });
}

function loadOrders() {
    highlightStatusButton();
    const params = new URLSearchParams({
        ajax: 1,
        status: currentStatus,
        search: currentSearch,
        sortField: sortField,
        sortOrder: sortOrder,
        page: currentPage
    });
    fetch('user-orders.jsp?' + params.toString())
        .then(res => res.text())
        .then(html => {
            ordersContainer.innerHTML = html;
            updatePaginationInfo();
            renderPagination();
        });
}

function updatePaginationInfo() {
    const totalPages = parseInt(document.getElementById("totalPages")?.value) || 1;
    const totalOrders = parseInt(document.getElementById("totalOrders")?.value) || 0;
    
    document.getElementById('currentPage').textContent = currentPage;
    document.getElementById('totalPagesDisplay').textContent = totalPages;
    document.getElementById('totalOrdersDisplay').textContent = totalOrders;
}

function renderPagination() {
    const totalPages = parseInt(document.getElementById("totalPages")?.value) || 1;
    
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
            currentPage--;
            loadOrders();
        }
    };
    
    nextBtn.onclick = () => {
        if(currentPage < totalPages) {
            currentPage++;
            loadOrders();
        }
    };
}

function handleLimitChange() {
    const select = document.getElementById('recordsPerPage');
    pageSize = parseInt(select.value);
    currentPage = 1;
    loadOrders();
}

// Filters
document.querySelectorAll('.statusBtn').forEach(btn=>{
    btn.addEventListener('click', ()=>{
        currentStatus = btn.getAttribute('data-status');
        currentPage = 1;
        loadOrders();
    });
});

document.getElementById('searchInput').addEventListener('input', e=>{
    currentSearch = e.target.value;
    currentPage = 1;
    loadOrders();
});

// Sorting
document.querySelectorAll('.sort').forEach(th=>{
    th.addEventListener('click', ()=>{
        let field = th.getAttribute('data-field');
        if(sortField===field){
            sortOrder = sortOrder==='asc'?'desc':'asc';
        } else {
            sortField = field;
            sortOrder = 'asc';
        }
        currentPage = 1;
        loadOrders();
    });
});

window.onload = function() { 
    loadOrders(); 
    document.getElementById('recordsPerPage').value = pageSize;
};
</script>
</body>
</html>