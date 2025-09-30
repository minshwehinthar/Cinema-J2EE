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
            out.println("<tr><td colspan='7' class='px-6 py-4 text-center text-gray-500'>No orders found.</td></tr>");
        } else {
            for(Map<String,Object> order: orders){
                String status = (String) order.get("status");
                String statusColor = "text-gray-700";
                if("pending".equalsIgnoreCase(status)) statusColor="text-yellow-700 font-semibold";
                else if("completed".equalsIgnoreCase(status)) statusColor="text-green-600 font-semibold";
                else if("picked".equalsIgnoreCase(status)) statusColor="text-blue-600 font-semibold";
%>
<tr class="hover:bg-gray-50">
    <td class="px-6 py-4"><%=order.get("id")%></td>
    <td class="px-6 py-4 font-medium text-gray-900"><%=order.get("theater_name")%></td>
    <td class="px-6 py-4"><%=order.get("created_at")%></td>
    <td class="px-6 py-4"><%=order.get("payment_method")%></td>
    <td class="px-6 py-4"><span class="<%=statusColor%>"><%=status.toUpperCase()%></span></td>
    <td class="px-6 py-4 text-right font-semibold text-green-600"><%=order.get("total_amount")%></td>
    <td class="px-6 py-4 text-center">
        <a href="order-details.jsp?orderId=<%=order.get("id")%>" 
           class="bg-blue-500 text-white px-3 py-1 rounded hover:bg-blue-600 text-sm">View</a>
    </td>
</tr>
<%          } %>
<input type="hidden" id="totalPages" value="<%=totalPages%>"/>
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

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>My Orders</title>
<script src="https://cdn.tailwindcss.com"></script>
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

<main class="max-w-6xl mx-auto py-12 px-4 w-full">
  <h1 class="text-3xl font-bold text-center mb-8 text-gray-800">My Orders</h1>

  <!-- Filters -->
  <div class="flex flex-wrap justify-between mb-8 gap-4 items-center">
    <!-- Category Buttons -->
    <div class="flex gap-3 rounded-lg">
  <button class="statusBtn px-5 py-2 rounded-lg border border-transparent hover:border-blue-300 hover:bg-blue-50 transition" data-status="all">All</button>
  <button class="statusBtn px-5 py-2 rounded-lg border border-transparent hover:border-blue-300 hover:bg-blue-50 transition" data-status="pending">Pending</button>
  <button class="statusBtn px-5 py-2 rounded-lg border border-transparent hover:border-blue-300 hover:bg-blue-50 transition" data-status="completed">Completed</button>
  <button class="statusBtn px-5 py-2 rounded-lg border border-transparent hover:border-blue-300 hover:bg-blue-50 transition" data-status="picked">Picked</button>
</div>


    <!-- Search -->
    <div class="relative w-64">
      <input type="text" id="searchInput" placeholder="Search orders..."
        class="w-full px-4 py-2 border rounded-lg focus:ring-2 focus:ring-blue-500 focus:outline-none shadow-sm">
    </div>
  </div>

  <!-- Table -->
  <div class="overflow-x-auto bg-white shadow rounded-lg">
    <table class="min-w-full text-sm text-left">
      <thead class="bg-gray-100 text-gray-700 uppercase text-xs">
        <tr>
          <th class="px-6 py-3 cursor-pointer sort" data-field="id">Order ID</th>
          <th class="px-6 py-3 cursor-pointer sort" data-field="theater_name">Theater</th>
          <th class="px-6 py-3 cursor-pointer sort" data-field="created_at">Ordered At</th>
          <th class="px-6 py-3 cursor-pointer sort" data-field="payment_method">Payment</th>
          <th class="px-6 py-3 cursor-pointer sort" data-field="status">Status</th>
          <th class="px-6 py-3 cursor-pointer sort text-right" data-field="total_amount">Total</th>
          <th class="px-6 py-3 text-center">Action</th>
        </tr>
      </thead>
      <tbody id="ordersContainer"></tbody>
    </table>
  </div>

  <!-- Pagination -->
  <div id="pagination" class="flex justify-center mt-8 gap-2"></div>
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

function highlightStatusButton() {
	  document.querySelectorAll('.statusBtn').forEach(btn => {
	    if (btn.getAttribute('data-status') === currentStatus) {
	      btn.classList.add('border-blue-500', 'bg-blue-50', 'text-blue-600', 'font-medium');
	      btn.classList.remove('border-transparent');
	    } else {
	      btn.classList.remove('border-blue-500', 'bg-blue-50', 'text-blue-600', 'font-medium');
	      btn.classList.add('border-transparent');
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
      renderPagination();
    });
}

function renderPagination() {
    const totalPages = parseInt(document.getElementById("totalPages")?.value) || 1;
    pagination.innerHTML = '';
    pagination.classList.add('flex', 'justify-center', 'gap-2', 'flex-wrap');

    // Previous button
    let prevBtn = document.createElement('button');
    prevBtn.textContent = "Previous";
    prevBtn.disabled = (currentPage === 1);
    prevBtn.className = prevBtn.disabled 
        ? "px-4 py-2 rounded-md bg-gray-200 text-gray-400 cursor-not-allowed transition" 
        : "px-4 py-2 rounded-md bg-gray-100 hover:bg-blue-100 text-gray-700 transition";
    prevBtn.addEventListener('click', () => {
        if(currentPage > 1) {
            currentPage--;
            loadOrders();
        }
    });
    pagination.appendChild(prevBtn);

    // Page numbers
    for(let i=1; i<=totalPages; i++){
        let btn = document.createElement('button');
        btn.textContent = i;
        btn.className = (i === currentPage) 
            ? "px-4 py-2 rounded-md bg-blue-600 text-white font-medium shadow" 
            : "px-4 py-2 rounded-md bg-gray-100 text-gray-700 hover:bg-blue-100 transition";
        btn.addEventListener('click', () => { 
            currentPage = i; 
            loadOrders(); 
        });
        pagination.appendChild(btn);
    }

    // Next button
    let nextBtn = document.createElement('button');
    nextBtn.textContent = "Next";
    nextBtn.disabled = (currentPage === totalPages);
    nextBtn.className = nextBtn.disabled 
        ? "px-4 py-2 rounded-md bg-gray-200 text-gray-400 cursor-not-allowed transition" 
        : "px-4 py-2 rounded-md bg-gray-100 hover:bg-blue-100 text-gray-700 transition";
    nextBtn.addEventListener('click', () => {
        if(currentPage < totalPages) {
            currentPage++;
            loadOrders();
        }
    });
    pagination.appendChild(nextBtn);
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

window.onload = loadOrders;
</script>
</body>
</html>
