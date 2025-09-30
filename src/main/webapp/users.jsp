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
                out.print("<tr><td colspan='6' class='px-6 py-4 text-center text-gray-500'>No users found.</td></tr>");
            } else {
                for(Map<String,Object> u:pageUsers){
%>
<tr class="hover:bg-gray-50" id="row_<%=u.get("id")%>">
    <td class="px-6 py-4"><%=u.get("id")%></td>
    <td class="px-6 py-4 font-medium text-gray-900"><%=u.get("name")%></td>
    <td class="px-6 py-4"><%=u.get("email")%></td>
    <td class="px-6 py-4"><%=u.get("phone")%></td>
    <td class="px-6 py-4">
        <span class="<%="active".equals(u.get("status"))?"bg-green-500 text-white text-xs px-2 py-1 rounded-full":"bg-red-500 text-white text-xs px-2 py-1 rounded-full"%>">
            <%=u.get("status")%>
        </span>
    </td>
    <td class="px-6 py-4 text-center flex justify-center space-x-2">
        <a href="userDetails.jsp?id=<%=u.get("id")%>" class="p-2 bg-gray-100 rounded hover:bg-gray-200">
            <i class="fa fa-pencil text-gray-600"></i>
        </a>
        <button class="delete-btn p-2 bg-gray-100 rounded hover:bg-red-100" onclick="deleteUser(<%=u.get("id")%>)">
            <i class="fa fa-trash text-red-600"></i>
        </button>
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
        <div class="p-8">
        <!-- Breadcrumb -->
        <div class="max-w-8xl mx-auto pb-4">
            <nav class="text-sm text-gray-500 mb-4" aria-label="Breadcrumb">
                <ol class="flex items-center space-x-2">
                    <li><a href="index.jsp" class="hover:underline">Home</a></li>
                    
                    <li>/</li>
                    <li class="text-gray-700">Users List</li>
                </ol>
            </nav>
        </div>
            <h1 class="text-2xl font-bold mb-6 text-gray-900">Users Management</h1>

            <div id="toastContainer" class="fixed top-5 right-5 z-50"></div>

            <div class="flex justify-between items-center mb-4">
                <input type="text" id="searchInput" placeholder="Search users..."
                       class="px-4 py-2 border rounded-lg w-72 focus:outline-none focus:ring-2 focus:ring-blue-500"/>
                <a href="createUser.jsp" class="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-lg">
                    + Add New User
                </a>
            </div>

            <div class="overflow-x-auto bg-white shadow rounded-lg">
                <table class="min-w-full text-sm text-left">
                    <thead class="bg-gray-100 text-gray-700 uppercase text-xs">
                        <tr>
                            <th class="px-6 py-3 cursor-pointer" onclick="sortTable('id')">ID</th>
                            <th class="px-6 py-3 cursor-pointer" onclick="sortTable('name')">Name</th>
                            <th class="px-6 py-3 cursor-pointer" onclick="sortTable('email')">Email</th>
                            <th class="px-6 py-3 cursor-pointer" onclick="sortTable('phone')">Phone</th>
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
let currentPage=1;
const pageSize=5;
let currentSortField='';
let currentSortOrder='asc';

function loadUsers(page=1,query="",sortField=currentSortField,sortOrder=currentSortOrder){
    currentPage=page;
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
    const totalUsers=<%=allUsers.size()%>;
    const totalPages=Math.ceil(totalUsers/pageSize);
    const c=document.getElementById('pagination');
    c.innerHTML='';

    const prev=document.createElement('a');
    prev.href="javascript:void(0)";
    prev.innerText="Prev";
    prev.className="px-4 py-2 rounded-md border "+(currentPage===1?"bg-gray-200 text-gray-500":"bg-white text-gray-700 hover:bg-blue-100");
    prev.addEventListener('click',()=>{ if(currentPage>1) loadUsers(currentPage-1,searchInput.value); });
    c.appendChild(prev);

    for(let i=1;i<=totalPages;i++){
        const a=document.createElement('a');
        a.href="javascript:void(0)";
        a.innerText=i;
        a.className="px-4 py-2 rounded-md border "+(i===currentPage?"bg-blue-600 text-white":"bg-white text-gray-700 hover:bg-blue-100");
        a.addEventListener('click',()=>loadUsers(i,searchInput.value));
        c.appendChild(a);
    }

    const next=document.createElement('a');
    next.href="javascript:void(0)";
    next.innerText="Next";
    next.className="px-4 py-2 rounded-md border "+(currentPage===totalPages?"bg-gray-200 text-gray-500":"bg-white text-gray-700 hover:bg-blue-100");
    next.addEventListener('click',()=>{ if(currentPage<totalPages) loadUsers(currentPage+1,searchInput.value); });
    c.appendChild(next);
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

window.onload=function(){ loadUsers(); }
</script>

<style>
@keyframes fade{0%{opacity:0;transform:translateY(-10px);}10%{opacity:1;transform:translateY(0);}90%{opacity:1;}100%{opacity:0;transform:translateY(-10px);}}
.animate-fade{animation:fade 3s forwards;}
</style>

<jsp:include page="layout/JSPFooter.jsp"/>
