<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*,java.util.*,com.demo.dao.MyConnection,com.demo.model.User"%>

<%
    // Check login and admin role
    User user = (User) session.getAttribute("user");
    if (user == null || !"admin".equals(user.getRole())) {
        response.sendRedirect("login.jsp?msg=unauthorized");
        return;
    }

    int pageSize = 5;
    List<Map<String,Object>> allUsers = new ArrayList<>();

    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    try {
        conn = MyConnection.getConnection();
        ps = conn.prepareStatement("SELECT * FROM users WHERE role='user'");
        rs = ps.executeQuery();
        while(rs.next()){
            Map<String,Object> u = new HashMap<>();
            u.put("id", rs.getInt("user_id"));
            u.put("name", rs.getString("name"));
            u.put("email", rs.getString("email"));
            u.put("phone", rs.getString("phone"));
            u.put("status", rs.getString("status"));
            allUsers.add(u);
        }
    } finally {
        if(rs!=null) rs.close();
        if(ps!=null) ps.close();
        if(conn!=null) conn.close();
    }

    // --- AJAX HANDLER ---
    if("POST".equalsIgnoreCase(request.getMethod())){
        if("1".equals(request.getParameter("ajax_delete"))){
            int userId = Integer.parseInt(request.getParameter("user_id"));
            Connection connDel = null;
            PreparedStatement psDel = null;
            try{
                connDel = MyConnection.getConnection();
                psDel = connDel.prepareStatement("DELETE FROM users WHERE user_id=?");
                psDel.setInt(1,userId);
                int rows = psDel.executeUpdate();
                out.print(rows>0?"deleted":"notfound");
            }catch(Exception e){ e.printStackTrace(); out.print("error"); }
            finally{ if(psDel!=null) psDel.close(); if(connDel!=null) connDel.close(); }
            return;
        }

        if("1".equals(request.getParameter("ajax_search"))){
            String searchQuery = request.getParameter("search");
            String sortField = request.getParameter("sortField");
            String sortOrder = request.getParameter("sortOrder");

            if(searchQuery!=null && !searchQuery.trim().isEmpty()){
                String keyword = searchQuery.toLowerCase();
                allUsers.removeIf(u -> {
                    String name=((String)u.get("name")).toLowerCase();
                    String email=((String)u.get("email")).toLowerCase();
                    String phone=((String)u.get("phone")).toLowerCase();
                    return !(String.valueOf(u.get("id")).contains(keyword) ||
                             name.contains(keyword) ||
                             email.contains(keyword) ||
                             phone.contains(keyword));
                });
            }

            // --- SORTING ---
            if(sortField!=null && !sortField.isEmpty()){
                Comparator<Map<String,Object>> comp = Comparator.comparing(m->(Integer)m.get("id"));
                if("id".equals(sortField)) comp = Comparator.comparing(m->(Integer)m.get("id"));
                else if("name".equals(sortField)) comp = Comparator.comparing(m->(String)m.get("name"));
                else if("email".equals(sortField)) comp = Comparator.comparing(m->(String)m.get("email"));
                else if("phone".equals(sortField)) comp = Comparator.comparing(m->(String)m.get("phone"));
                if("desc".equals(sortOrder)) comp = comp.reversed();
                allUsers.sort(comp);
            }

            int currentPage = request.getParameter("page")!=null?Integer.parseInt(request.getParameter("page")):1;
            int totalUsers = allUsers.size();
            int start = (currentPage-1)*pageSize;
            int end = Math.min(start+pageSize,totalUsers);
            List<Map<String,Object>> pageUsers = (start<end)?allUsers.subList(start,end):List.of();

            if(pageUsers.isEmpty()){
                out.print("<tr><td colspan='6' class='px-6 py-8 text-center'><div class='w-16 h-16 mx-auto mb-4 text-gray-300'><svg fill='none' stroke='currentColor' viewBox='0 0 24 24'><path stroke-linecap='round' stroke-linejoin='round' stroke-width='1' d='M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197m13.5-9a2.5 2.5 0 11-5 0 2.5 2.5 0 015 0z'/></svg></div><h3 class='text-lg font-medium text-gray-600 mb-2'>No users found</h3><p class='text-gray-500'>Try adjusting your search or filter to find what you're looking for.</p></td></tr>");
            } else {
                for(Map<String,Object> u:pageUsers){
%>
<tr class="hover:bg-red-50 transition-colors duration-150" id="row_<%=u.get("id")%>">
    <td class="px-6 py-4">
        <div class="flex items-center space-x-3">
            <div class="w-10 h-10 bg-red-100 rounded-lg flex items-center justify-center">
                <span class="text-red-600 font-bold text-sm">#<%=u.get("id")%></span>
            </div>
        </div>
    </td>
    <td class="px-6 py-4">
        <div class="font-medium text-gray-900"><%=u.get("name")%></div>
    </td>
    <td class="px-6 py-4">
        <div class="text-gray-900"><%=u.get("email")%></div>
    </td>
    <td class="px-6 py-4">
        <div class="text-gray-900"><%=u.get("phone")%></div>
    </td>
    <td class="px-6 py-4">
        <span class="inline-flex items-center px-3 py-1 rounded-full text-xs font-medium border <%= "active".equals(u.get("status"))?"bg-green-100 text-green-800 border-green-200":"bg-red-100 text-red-800 border-red-200" %>">
            <%=u.get("status")%>
        </span>
    </td>
    <td class="px-6 py-4">
        <div class="flex justify-center space-x-3 min-w-[90px]">
            <a href="userDetails.jsp?id=<%=u.get("id")%>" 
               class="inline-flex items-center justify-center w-10 h-10 text-blue-600 bg-white border border-blue-300 rounded-lg hover:bg-blue-50 hover:border-blue-400 transition-colors duration-200 shadow-sm cursor-pointer">
                <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                    <path d="M2.062 12.348a1 1 0 0 1 0-.696 10.75 10.75 0 0 1 19.876 0 1 1 0 0 1 0 .696 10.75 10.75 0 0 1-19.876 0"/>
                    <circle cx="12" cy="12" r="3"/>
                </svg>
            </a>
            <button onclick="deleteUser(<%=u.get("id")%>)"
                    class="inline-flex items-center justify-center w-10 h-10 text-red-600 bg-white border border-red-300 rounded-lg hover:bg-red-50 hover:border-red-400 transition-colors duration-200 shadow-sm cursor-pointer">
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
    }
%>

<jsp:include page="layout/JSPHeader.jsp"/>
<div class="flex">
    <jsp:include page="layout/sidebar.jsp"/>
    <div class="flex-1 sm:ml-64">
        <jsp:include page="/layout/AdminHeader.jsp"/>
        <div class="p-8 max-w-8xl mx-auto">
            
            <!-- Breadcrumb -->
            <div class="pb-4">
                <nav class="text-sm text-gray-500 mb-4" aria-label="Breadcrumb">
                    <ol class="flex items-center space-x-2">
                        <li><a href="index.jsp" class="hover:underline">Home</a></li>
                        <li>/</li>
                        <li class="text-gray-700">Users List</li>
                    </ol>
                </nav>
            </div>

            <!-- Header Section -->
            <div class="flex justify-between items-center mb-6">
                <div>
                    <h1 class="text-2xl font-bold text-gray-900">Users Management</h1>
                    <p class="text-gray-600 mt-1">Manage all user accounts and their status</p>
                </div>
            </div>

            <!-- Search and Filter -->
            <div class="flex justify-between items-center mb-6">
                <div class="flex space-x-4">
                    <input type="text" id="searchInput" placeholder="Search users..." 
                           class="px-4 py-2 border border-gray-300 rounded-lg w-80 focus:outline-none ring-transparent "/>
                </div>
                <a href="createUser.jsp" class="bg-red-600 text-white px-4 py-2 rounded-lg hover:bg-red-700 transition-colors duration-200 shadow-sm">
                    + Add New User
                </a>
            </div>

            <!-- Users Table -->
            <div class="bg-white shadow rounded-lg border border-gray-200 overflow-hidden">
                <div class="overflow-x-auto">
                    <table class="min-w-full text-sm text-left">
                        <thead class="bg-red-50 text-gray-900 uppercase text-xs">
                            <tr>
                                <th class="px-6 py-4 font-semibold cursor-pointer" onclick="sortTable('id')">
                                    <div class="flex items-center space-x-1">
                                        <span>ID</span>
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
                        Total <span class="shadow-sm px-3 py-2 rounded border border-gray-200 mx-2" id="totalUsers">
                            <%= allUsers.size() %>
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

function loadUsers(page=1, query="", sortField=currentSortField, sortOrder=currentSortOrder){
    currentPage = page;
    fetch('users.jsp',{
        method:'POST',
        headers:{'Content-Type':'application/x-www-form-urlencoded'},
        body:'ajax_search=1&search='+encodeURIComponent(query)+
             '&page='+page+
             '&sortField='+sortField+
             '&sortOrder='+sortOrder
    }).then(res=>res.text())
    .then(html=>{
        document.getElementById('tableBody').innerHTML=html;
        renderPagination();
    });
}

function deleteUser(userId){
    if(!confirm("Are you sure to delete this user?")) return;
    fetch('users.jsp',{
        method:'POST',
        headers:{'Content-Type':'application/x-www-form-urlencoded'},
        body:'ajax_delete=1&user_id='+userId
    }).then(res=>res.text())
    .then(res=>{
        if(res.trim()==="deleted"){
            showToast("User deleted successfully!");
            loadUsers(currentPage,document.getElementById('searchInput').value);
        } else {
            showToast("Delete failed!",true);
        }
    });
}

function showToast(msg,isError=false){
    const c=document.getElementById('toastContainer');
    const d=document.createElement('div');
    d.innerText=msg;
    d.className=`mb-2 px-4 py-2 rounded shadow text-white ${isError?'bg-red-500':'bg-green-500'} animate-fade`;
    c.appendChild(d);
    setTimeout(()=>d.remove(),3000);
}

const searchInput=document.getElementById('searchInput');
searchInput.addEventListener('input',debounce(function(){
    loadUsers(1,this.value,currentSortField,currentSortOrder);
},500));

function debounce(func,delay){let t;return function(...a){clearTimeout(t);t=setTimeout(()=>func.apply(this,a),delay);} }

function renderPagination(){
    const totalUsers = <%= allUsers.size() %>;
    const totalPages = Math.ceil(totalUsers / pageSize);
    
    // Update page info
    document.getElementById('currentPage').textContent = currentPage;
    document.getElementById('totalPages').textContent = totalPages;
    document.getElementById('totalUsers').textContent = totalUsers;
    
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
            loadUsers(currentPage - 1, searchInput.value);
        }
    };
    
    nextBtn.onclick = () => {
        if(currentPage < totalPages) {
            loadUsers(currentPage + 1, searchInput.value);
        }
    };
}

function handleLimitChange() {
    const select = document.getElementById('recordsPerPage');
    pageSize = parseInt(select.value);
    loadUsers(1, searchInput.value);
}

function sortTable(field){
    if(currentSortField===field){
        currentSortOrder=(currentSortOrder==='asc')?'desc':'asc';
    } else {
        currentSortField=field;
        currentSortOrder='asc';
    }
    loadUsers(1,searchInput.value,currentSortField,currentSortOrder);
}

window.onload=function(){ 
    loadUsers(); 
    document.getElementById('recordsPerPage').value = pageSize;
}
</script>

<style>
@keyframes fade{0%{opacity:0;transform:translateY(-10px);}10%{opacity:1;transform:translateY(0);}90%{opacity:1;}100%{opacity:0;transform:translateY(-10px);}}
.animate-fade{animation:fade 3s forwards;}
</style>

<jsp:include page="layout/JSPFooter.jsp"/>