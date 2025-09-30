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

    if(totalRows == 0){
        out.print("<tr><td colspan='7' class='px-6 py-4 text-center text-gray-500'>No item found.</td></tr>");
    } else {
        rs.beforeFirst();
        int index=0;
        while(rs.next()){
            if(index++ < start) continue;
            if(index-1 >= start+pageSize) break;
%>
<tr class="hover:bg-gray-50">
    <td class="px-6 py-4"><%= rowNum++ %></td>
    <td class="px-6 py-4 font-medium text-gray-900"><%= rs.getString("name") %></td>
    <td class="px-6 py-4"><%= rs.getString("email") %></td>
    <td class="px-6 py-4"><%= rs.getString("phone") %></td>
    <td class="px-6 py-4"><%= rs.getString("theater_name") != null ? rs.getString("theater_name") : "-" %></td>
    <td class="px-6 py-4">
        <span class="<%="active".equals(rs.getString("status")) 
            ? "bg-green-500 text-white text-xs px-2 py-1 rounded-full"
            : "bg-red-500 text-white text-xs px-2 py-1 rounded-full"%>">
            <%= rs.getString("status") %>
        </span>
    </td>
    <td class="px-6 py-4 text-center flex justify-center space-x-2">
    <a href="employeeEdit.jsp?id=<%=rs.getInt("user_id")%>" 
       class="p-2 bg-gray-100 rounded hover:bg-gray-200" 
       title="Edit Employee">
        <i class="fa fa-pencil text-gray-600"></i>
    </a>
        <a href="employeeDetails.jsp?id=<%=rs.getInt("user_id")%>" class="p-2 bg-gray-100 rounded hover:bg-gray-200">
            <i class="fa fa-pencil text-gray-600"></i>
        </a>
        <button class="delete-btn p-2 bg-gray-100 rounded hover:bg-red-100" data-id="<%=rs.getInt("user_id")%>">
            <i class="fa fa-trash text-red-600"></i>
        </button>
    </td>
</tr>
<%
        }
    }

    rs.close(); ps.close(); conn.close();

    // --- pagination footer ---
    out.print("<tr><td colspan='7' class='px-6 py-4 text-center'>");
    out.print("<div class='flex justify-center space-x-1'>");
    out.print("<button onclick='loadEmployees("+Math.max(1,currentPage-1)+")' class='px-3 py-1 border rounded "+(currentPage==1?"bg-gray-200 text-gray-500":"bg-white") +"'>Prev</button>");
    for(int i=1;i<=totalPages;i++){
        out.print("<button onclick='loadEmployees("+i+")' class='px-3 py-1 border rounded "+(i==currentPage?"bg-blue-600 text-white":"bg-white") +"'>"+i+"</button>");
    }
    out.print("<button onclick='loadEmployees("+Math.min(totalPages,currentPage+1)+")' class='px-3 py-1 border rounded "+(currentPage==totalPages?"bg-gray-200 text-gray-500":"bg-white") +"'>Next</button>");
    out.print("</div></td></tr>");
    return;
}
%>

<jsp:include page="layout/JSPHeader.jsp" />
<div class="flex">
    <jsp:include page="layout/sidebar.jsp" />
    <div class="flex-1 sm:ml-64">
        <jsp:include page="/layout/AdminHeader.jsp" />
        <div class="p-8">
            <h1 class="text-2xl font-bold mb-6 text-gray-900">Employees Management</h1>

            <div class="flex justify-between items-center mb-4">
                <input type="text" id="searchInput" placeholder="Search employees..." class="px-4 py-2 border rounded-lg w-72 focus:outline-none focus:ring-2 focus:ring-blue-500"/>
                <a href="create-theater-admin.jsp" class="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-lg">
                    + Add New Employee
                </a>
            </div>

            <div class="overflow-x-auto bg-white shadow rounded-lg">
                <table class="min-w-full text-sm text-left">
                    <thead class="bg-gray-100 text-gray-700 uppercase text-xs">
                        <tr>
                            <th class="px-6 py-3 cursor-pointer" onclick="sortTable('id')">#</th>
                            <th class="px-6 py-3 cursor-pointer" onclick="sortTable('name')">Name</th>
                            <th class="px-6 py-3 cursor-pointer" onclick="sortTable('email')">Email</th>
                            <th class="px-6 py-3 cursor-pointer" onclick="sortTable('phone')">Phone</th>
                            <th class="px-6 py-3">Theater</th>
                            <th class="px-6 py-3 cursor-pointer" onclick="sortTable('status')">Status</th>
                            <th class="px-6 py-3 text-center">Action</th>
                        </tr>
                    </thead>
                    <tbody id="tableBody"></tbody>
                </table>
            </div>

        </div>
    </div>
</div>

<div id="toast" class="fixed top-5 right-5 z-50 hidden transition-transform transform">
    <div id="toast-message" class="px-4 py-3 rounded shadow text-white"></div>
</div>

<script>
let currentPage = 1, currentSortField='', currentSortOrder='asc';

function loadEmployees(page=1, query=document.getElementById('searchInput').value, sortField=currentSortField, sortOrder=currentSortOrder){
    currentPage=page;
    fetch('employees.jsp',{
        method:'POST',
        headers:{'Content-Type':'application/x-www-form-urlencoded'},
        body:'search='+encodeURIComponent(query)+'&page='+page+'&sortField='+sortField+'&sortOrder='+sortOrder
    }).then(res=>res.text()).then(html=>{
        document.getElementById('tableBody').innerHTML = html;
        attachDeleteEvents();
    });
}

function attachDeleteEvents(){
    document.querySelectorAll('.delete-btn').forEach(btn=>{
        btn.onclick=function(){
            if(!confirm("Are you sure to delete this employee?")) return;
            const userId=this.dataset.id;
            fetch('employees.jsp',{
                method:'POST',
                headers:{'Content-Type':'application/x-www-form-urlencoded'},
                body:'ajax_delete=1&user_id='+userId
            }).then(res=>res.text()).then(res=>{
                if(res.trim()==="deleted"){ showToast("Deleted successfully","success"); loadEmployees(currentPage); }
                else if(res.trim()==="notfound"){ showToast("Not found","warning"); }
                else{ showToast("Something went wrong","error"); }
            });
        }
    });
}

function showToast(msg,type){
    const t=document.getElementById('toast'), m=document.getElementById('toast-message');
    m.textContent=msg;
    m.className="px-4 py-3 rounded shadow text-white "+(type==="success"?"bg-green-500":type==="warning"?"bg-yellow-500":"bg-red-500");
    t.classList.remove('hidden'); setTimeout(()=>t.classList.add('hidden'),3000);
}

document.getElementById('searchInput').addEventListener('input', debounce(function(){ loadEmployees(1,this.value); },500));

function sortTable(field){
    if(currentSortField===field) currentSortOrder=currentSortOrder==='asc'?'desc':'asc';
    else { currentSortField=field; currentSortOrder='asc'; }
    loadEmployees(1, document.getElementById('searchInput').value, currentSortField, currentSortOrder);
}

function debounce(func, delay){
    let timer;
    return function(...args){ clearTimeout(timer); timer=setTimeout(()=>func.apply(this,args),delay); };
}

window.onload=function(){ loadEmployees(); }
</script>

<jsp:include page="layout/JSPFooter.jsp"/>
