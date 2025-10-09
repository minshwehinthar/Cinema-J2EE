<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*,com.demo.dao.MyConnection,com.demo.model.User"%>

<%
User user = (User) session.getAttribute("user");
if (user == null || !"admin".equals(user.getRole())) {
    response.sendRedirect("login.jsp?msg=unauthorized");
    return;
}

int pageSize = 5;

// --- AJAX delete or search handling ---
if("POST".equalsIgnoreCase(request.getMethod())) {

    // --- Delete employee ---
    if("1".equals(request.getParameter("ajax_delete"))) {
        String userIdParam = request.getParameter("user_id");
        if(userIdParam != null && !userIdParam.isEmpty()) {
            try(Connection conn = MyConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement("DELETE FROM users WHERE user_id=?")) {
                ps.setInt(1, Integer.parseInt(userIdParam));
                int rows = ps.executeUpdate();
                out.print(rows>0?"deleted":"notfound");
            } catch(Exception e) {
                e.printStackTrace();
                out.print("error");
            }
        } else { out.print("error"); }
        return;
    }

    // --- Get total count only ---
    if("1".equals(request.getParameter("get_total_count"))) {
        String searchQuery = request.getParameter("search");
        Connection conn = MyConnection.getConnection();
        String sql = "SELECT COUNT(*) as total FROM users u LEFT JOIN theaters t ON u.user_id = t.user_id WHERE u.role='theateradmin'";
        
        if(searchQuery != null && !searchQuery.trim().isEmpty()) {
            sql += " AND (u.name LIKE ? OR u.email LIKE ? OR u.phone LIKE ?)";
        }
        
        PreparedStatement ps = conn.prepareStatement(sql);
        if(searchQuery != null && !searchQuery.trim().isEmpty()){
            String q="%"+searchQuery+"%";
            ps.setString(1, q);
            ps.setString(2, q);
            ps.setString(3, q);
        }
        
        ResultSet rs = ps.executeQuery();
        if(rs.next()) {
            out.print(rs.getInt("total"));
        } else {
            out.print("0");
        }
        rs.close(); ps.close(); conn.close();
        return;
    }

    // --- AJAX search / sort / pagination ---
    String searchQuery = request.getParameter("search");
    String sortField = request.getParameter("sortField");
    String sortOrder = request.getParameter("sortOrder");
    int currentPage = request.getParameter("page")!=null ? Integer.parseInt(request.getParameter("page")) : 1;

    Connection conn = MyConnection.getConnection();
    String sql = "SELECT u.*, t.name AS theater_name FROM users u LEFT JOIN theaters t ON u.user_id = t.user_id WHERE u.role='theateradmin'";

    if(searchQuery != null && !searchQuery.trim().isEmpty()) {
        sql += " AND (u.name LIKE ? OR u.email LIKE ? OR u.phone LIKE ?)";
    }

    if(sortField != null && !sortField.isEmpty()) {
        switch(sortField){
            case "id": sql+=" ORDER BY u.user_id "+("desc".equals(sortOrder)?"DESC":"ASC"); break;
            case "name": sql+=" ORDER BY u.name "+("desc".equals(sortOrder)?"DESC":"ASC"); break;
            case "email": sql+=" ORDER BY u.email "+("desc".equals(sortOrder)?"DESC":"ASC"); break;
            case "phone": sql+=" ORDER BY u.phone "+("desc".equals(sortOrder)?"DESC":"ASC"); break;
            case "status": sql+=" ORDER BY u.status "+("desc".equals(sortOrder)?"DESC":"ASC"); break;
            default: sql+=" ORDER BY u.user_id ASC";
        }
    } else { sql+=" ORDER BY u.user_id ASC"; }

    PreparedStatement ps = conn.prepareStatement(sql, ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_READ_ONLY);
    if(searchQuery != null && !searchQuery.trim().isEmpty()){
        String q="%"+searchQuery+"%";
        ps.setString(1, q);
        ps.setString(2, q);
        ps.setString(3, q);
    }

    ResultSet rs = ps.executeQuery();
    rs.last();
    int totalRows = rs.getRow();
    int totalPages = (int)Math.ceil(totalRows/(double)pageSize);
    int start = (currentPage-1)*pageSize;
    int rowNum = start+1;

    String paginationOnly = request.getParameter("pagination_only");
    if("1".equals(paginationOnly)){
        // --- Only return pagination HTML ---
        out.print("<div class='flex justify-center space-x-1 mt-4'>");
        out.print("<button onclick='loadEmployees("+Math.max(1,currentPage-1)+")' class='px-3 py-1 border rounded "+(currentPage==1?"bg-gray-200 text-gray-500":"bg-white") +"'>Prev</button>");
        for(int i=1;i<=totalPages;i++){
            out.print("<button onclick='loadEmployees("+i+")' class='px-3 py-1 border rounded "+(i==currentPage?"bg-blue-600 text-white":"bg-white") +"'>"+i+"</button>");
        }
        out.print("<button onclick='loadEmployees("+Math.min(totalPages,currentPage+1)+")' class='px-3 py-1 border rounded "+(currentPage==totalPages?"bg-gray-200 text-gray-500":"bg-white") +"'>Next</button>");
        out.print("</div>");
        rs.close(); ps.close(); conn.close();
        return;
    }

    if(totalRows == 0){
        out.print("<tr><td colspan='7' class='px-6 py-8 text-center'><div class='w-16 h-16 mx-auto mb-4 text-gray-300'><svg fill='none' stroke='currentColor' viewBox='0 0 24 24'><path stroke-linecap='round' stroke-linejoin='round' stroke-width='1' d='M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z'/></svg></div><h3 class='text-lg font-medium text-gray-600 mb-2'>No employees found</h3><p class='text-gray-500'>Try adjusting your search or filter to find what you're looking for.</p></td></tr>");
    } else {
        rs.beforeFirst();
        int index=0;
        while(rs.next()){
            if(index++ < start) continue;
            if(index-1 >= start+pageSize) break;
%>
<tr class="hover:bg-red-50 transition-colors duration-150" id="row_<%=rs.getInt("user_id")%>">
    <td class="px-6 py-4">
        <div class="flex items-center space-x-3">
            <div class="w-10 h-10 bg-red-100 rounded-lg flex items-center justify-center">
                <span class="text-red-600 font-bold text-sm">#<%= rowNum++ %></span>
            </div>
        </div>
    </td>
    <td class="px-6 py-4">
        <div class="font-medium text-gray-900"><%= rs.getString("name") %></div>
    </td>
    <td class="px-6 py-4">
        <div class="text-gray-900"><%= rs.getString("email") %></div>
    </td>
    <td class="px-6 py-4">
        <div class="text-gray-900"><%= rs.getString("phone") %></div>
    </td>
    <td class="px-6 py-4">
        <div class="text-gray-900"><%= rs.getString("theater_name") != null ? rs.getString("theater_name") : "-" %></div>
    </td>
    <td class="px-6 py-4">
        <span class="inline-flex items-center px-3 py-1 rounded-full text-xs font-medium border <%= "active".equals(rs.getString("status")) 
            ? "bg-green-100 text-green-800 border-green-200"
            : "bg-red-100 text-red-800 border-red-200"%>">
            <%= rs.getString("status") %>
        </span>
    </td>
    <td class="px-6 py-4">
        <div class="flex justify-center space-x-3 min-w-[90px]">
            <!-- Edit Button -->
            <a href="employeeEdit.jsp?id=<%=rs.getInt("user_id")%>" 
               class="inline-flex items-center justify-center w-10 h-10 text-blue-600 bg-white border border-blue-300 rounded-lg hover:bg-blue-50 hover:border-blue-400 transition-colors duration-200 shadow-sm cursor-pointer"
               title="Edit Employee">
                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-5 h-5">
                    <path stroke-linecap="round" stroke-linejoin="round" d="m16.862 4.487 1.687-1.688a1.875 1.875 0 1 1 2.652 2.652L10.582 16.07a4.5 4.5 0 0 1-1.897 1.13L6 18l.8-2.685a4.5 4.5 0 0 1 1.13-1.897l8.932-8.931Zm0 0L19.5 7.125M18 14v4.75A2.25 2.25 0 0 1 15.75 21H5.25A2.25 2.25 0 0 1 3 18.75V8.25A2.25 2.25 0 0 1 5.25 6H10" />
                </svg>
            </a>
            
            <!-- Details Button -->
            <a href="employeeDetails.jsp?id=<%=rs.getInt("user_id")%>" 
               class="inline-flex items-center justify-center w-10 h-10 text-gray-600 bg-white border border-gray-300 rounded-lg hover:bg-gray-50 hover:border-gray-400 transition-colors duration-200 shadow-sm cursor-pointer"
               title="View Details">
                <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                    <path d="M2.062 12.348a1 1 0 0 1 0-.696 10.75 10.75 0 0 1 19.876 0 1 1 0 0 1 0 .696 10.75 10.75 0 0 1-19.876 0"/>
                    <circle cx="12" cy="12" r="3"/>
                </svg>
            </a>
            
            <!-- View Seats Button -->
            <%
                int theaterId = new com.demo.dao.UserDAO().getTheaterIdByUserId(rs.getInt("user_id"));
                if(theaterId > 0) {
            %>
            <a href="setTheaterSession?theater_id=<%=theaterId%>" 
               class="inline-flex items-center justify-center w-10 h-10 text-purple-600 bg-white border border-purple-300 rounded-lg hover:bg-purple-50 hover:border-purple-400 transition-colors duration-200 shadow-sm cursor-pointer"
               title="View Seats">
                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-5 h-5">
                    <path stroke-linecap="round" stroke-linejoin="round" d="M3.75 6A2.25 2.25 0 016 3.75h2.25A2.25 2.25 0 0110.5 6v2.25a2.25 2.25 0 01-2.25 2.25H6a2.25 2.25 0 01-2.25-2.25V6zM3.75 15.75A2.25 2.25 0 016 13.5h2.25a2.25 2.25 0 012.25 2.25V18a2.25 2.25 0 01-2.25 2.25H6A2.25 2.25 0 013.75 18v-2.25zM13.5 6a2.25 2.25 0 012.25-2.25H18A2.25 2.25 0 0120.25 6v2.25A2.25 2.25 0 0118 10.5h-2.25a2.25 2.25 0 01-2.25-2.25V6zM13.5 15.75a2.25 2.25 0 012.25-2.25H18a2.25 2.25 0 012.25 2.25V18A2.25 2.25 0 0118 20.25h-2.25A2.25 2.25 0 0113.5 18v-2.25z"/>
                </svg>
            </a>
            <% } %>
            
            <!-- Delete Button -->
            <button onclick="deleteEmployee(<%=rs.getInt("user_id")%>)"
                    class="inline-flex items-center justify-center w-10 h-10 text-red-600 bg-white border border-red-300 rounded-lg hover:bg-red-50 hover:border-red-400 transition-colors duration-200 shadow-sm cursor-pointer"
                    title="Delete Employee">
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

    rs.close(); ps.close(); conn.close();
    return;
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
                    <h1 class="text-2xl font-bold text-gray-900">Employees Management</h1>
                    <p class="text-gray-600 mt-1">Manage theater admin employees and their assigned theaters</p>
                </div>
            </div>

            <!-- Search and Filter -->
            <div class="flex justify-between items-center mb-6">
                <div class="flex space-x-4">
                    <input type="text" id="searchInput" placeholder="Search employees..." 
                           class="px-4 py-2 border border-gray-300 rounded-lg w-80 focus:outline-none ring-transparent "/>
                </div>
                <a href="create-theater-admin.jsp" class="bg-red-600 text-white px-4 py-2 rounded-lg hover:bg-red-700 transition-colors duration-200 shadow-sm">
                    + Add New Employee
                </a>
            </div>

            <!-- Employees Table -->
            <div class="bg-white shadow rounded-lg border border-gray-200 overflow-hidden">
                <div class="overflow-x-auto">
                    <table class="min-w-full text-sm text-left">
                        <thead class="bg-red-50 text-gray-900 uppercase text-xs">
                            <tr>
                                <th class="px-6 py-4 font-semibold cursor-pointer" onclick="sortTable('id')">
                                    <div class="flex items-center space-x-1">
                                        <span>#</span>
                                        <svg class="w-4 h-4 text-gray-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 16V4m0 0L3 8m4-4l4 4m6 0v12m0 0l4-4m-4 4l-4-4"/>
                                        </svg>
                                    </div>
                                </th>
                                <th class="px-6 py-4 font-semibold cursor-pointer" onclick="sortTable('name')">
                                    <div class="flex items-center space-x-1">
                                        <span>Name</span>
                                        <svg class="w-4 h-4 text-gray-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 16V4m0 0L3 8m4-4l4 4m6 0v12m0 0l4-4m-4 4l-4-4"/>
                                        </svg>
                                    </div>
                                </th>
                                <th class="px-6 py-4 font-semibold cursor-pointer" onclick="sortTable('email')">
                                    <div class="flex items-center space-x-1">
                                        <span>Email</span>
                                        <svg class="w-4 h-4 text-gray-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 16V4m0 0L3 8m4-4l4 4m6 0v12m0 0l4-4m-4 4l-4-4"/>
                                        </svg>
                                    </div>
                                </th>
                                <th class="px-6 py-4 font-semibold cursor-pointer" onclick="sortTable('phone')">
                                    <div class="flex items-center space-x-1">
                                        <span>Phone</span>
                                        <svg class="w-4 h-4 text-gray-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 16V4m0 0L3 8m4-4l4 4m6 0v12m0 0l4-4m-4 4l-4-4"/>
                                        </svg>
                                    </div>
                                </th>
                                <th class="px-6 py-4 font-semibold">Theater</th>
                                <th class="px-6 py-4 font-semibold cursor-pointer" onclick="sortTable('status')">
                                    <div class="flex items-center space-x-1">
                                        <span>Status</span>
                                        <svg class="w-4 h-4 text-gray-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 16V4m0 0L3 8m4-4l4 4m6 0v12m0 0l4-4m-4 4l-4-4"/>
                                        </svg>
                                    </div>
                                </th>
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
                        Total <span class="shadow-sm px-3 py-2 rounded border border-gray-200 mx-2" id="totalEmployees">
                            0
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
                        <button id="prevBtn" onclick="loadEmployees(currentPage - 1)"
                            class="flex opacity-50 cursor-not-allowed items-center justify-center px-4 h-10 text-base font-medium text-gray-500 bg-white border border-gray-300 rounded-l-lg border-r-0">
                            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7" />
                            </svg>
                        </button>
                        
                        <!-- Next Button -->
                        <button id="nextBtn" onclick="loadEmployees(currentPage + 1)"
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
let totalEmployees = 0;
let totalPages = 1;

function loadEmployees(page=1, query=document.getElementById('searchInput').value, sortField=currentSortField, sortOrder=currentSortOrder){
    currentPage = page;
    
    // Load table data
    fetch('employees.jsp',{
        method:'POST',
        headers:{'Content-Type':'application/x-www-form-urlencoded'},
        body:'search='+encodeURIComponent(query)+'&page='+page+'&sortField='+sortField+'&sortOrder='+sortOrder
    }).then(res=>res.text()).then(html=>{
        document.getElementById('tableBody').innerHTML = html;
        updateTotalCount();
        updatePaginationInfo();
    });
}

function updateTotalCount() {
    const query = document.getElementById('searchInput').value;
    
    fetch('employees.jsp', {
        method: 'POST',
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: 'search=' + encodeURIComponent(query) + '&get_total_count=1'
    }).then(res => res.text()).then(total => {
        totalEmployees = parseInt(total);
        document.getElementById('totalEmployees').textContent = totalEmployees;
        
        // Calculate total pages
        totalPages = Math.ceil(totalEmployees / pageSize);
        updatePaginationInfo();
    });
}

function updatePaginationInfo() {
    document.getElementById('currentPage').textContent = currentPage;
    document.getElementById('totalPages').textContent = totalPages;
    
    // Update button states
    const prevBtn = document.getElementById('prevBtn');
    const nextBtn = document.getElementById('nextBtn');
    
    if (currentPage <= 1) {
        prevBtn.classList.add('opacity-50', 'cursor-not-allowed');
        prevBtn.classList.remove('hover:bg-gray-50', 'hover:border-gray-400');
    } else {
        prevBtn.classList.remove('opacity-50', 'cursor-not-allowed');
        prevBtn.classList.add('hover:bg-gray-50', 'hover:border-gray-400');
    }
    
    if (currentPage >= totalPages) {
        nextBtn.classList.add('opacity-50', 'cursor-not-allowed');
        nextBtn.classList.remove('hover:bg-gray-50', 'hover:border-gray-400');
    } else {
        nextBtn.classList.remove('opacity-50', 'cursor-not-allowed');
        nextBtn.classList.add('hover:bg-gray-50', 'hover:border-gray-400');
    }
}

function deleteEmployee(userId){
    if(!confirm("Are you sure to delete this employee?")) return;
    fetch('employees.jsp',{
        method:'POST',
        headers:{'Content-Type':'application/x-www-form-urlencoded'},
        body:'ajax_delete=1&user_id='+userId
    }).then(res=>res.text()).then(res=>{
        if(res.trim()==="deleted"){ 
            showToast("Employee deleted successfully!"); 
            loadEmployees(currentPage); 
        }
        else if(res.trim()==="notfound"){ 
            showToast("Employee not found", true); 
        }
        else{ 
            showToast("Something went wrong", true); 
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

document.getElementById('searchInput').addEventListener('input', debounce(function(){ 
    loadEmployees(1, this.value); 
},500));

function sortTable(field){
    if(currentSortField===field) currentSortOrder=currentSortOrder==='asc'?'desc':'asc';
    else { currentSortField=field; currentSortOrder='asc'; }
    loadEmployees(1, document.getElementById('searchInput').value, currentSortField, currentSortOrder);
}

function debounce(func, delay){
    let timer;
    return function(...args){ clearTimeout(timer); timer=setTimeout(()=>func.apply(this,args),delay); };
}

function handleLimitChange() {
    const select = document.getElementById('recordsPerPage');
    pageSize = parseInt(select.value);
    loadEmployees(1, document.getElementById('searchInput').value);
}

window.onload=function(){ 
    loadEmployees(); 
    document.getElementById('recordsPerPage').value = pageSize;
}
</script>

<style>
@keyframes fade{0%{opacity:0;transform:translateY(-10px);}10%{opacity:1;transform:translateY(0);}90%{opacity:1;}100%{opacity:0;transform:translateY(-10px);}}
.animate-fade{animation:fade 3s forwards;}
</style>

<jsp:include page="layout/JSPFooter.jsp"/>