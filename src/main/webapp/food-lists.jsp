<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, com.demo.dao.FoodDAO, com.demo.model.User"%>

<%
User user = (User) session.getAttribute("user");
if(user==null || !"admin".equals(user.getRole())){
    response.sendRedirect("login.jsp?msg=unauthorized");
    return;
}

boolean ajax = "XMLHttpRequest".equals(request.getHeader("X-Requested-With"));
int pageSize = 5;
FoodDAO dao = new FoodDAO();
List<Map<String,Object>> allFoods = dao.getAllFoodsMap();

//--- AJAX DELETE ---
String action = request.getParameter("action");
if ("delete".equals(action) && ajax) {
 response.setContentType("application/json");
 String idParam = request.getParameter("id");
 boolean success = false;

 if (idParam != null) {
     try {
         int id = Integer.parseInt(idParam);
         success = dao.deleteFood(id); // call DAO delete method
     } catch (NumberFormatException e) {
         e.printStackTrace();
     } catch (Exception e) {
         e.printStackTrace();
     }
 }

 out.print("{\"success\":" + success + "}");
 return;
}


// --- AJAX SEARCH + SORT + PAGINATION ---
if("POST".equalsIgnoreCase(request.getMethod()) && ajax){
    String searchQuery = request.getParameter("search");
    String sortField = request.getParameter("sortField");
    String sortOrder = request.getParameter("sortOrder");
    int currentPage = request.getParameter("page") != null ? Integer.parseInt(request.getParameter("page")) : 1;

    // --- SEARCH ---
    if(searchQuery != null && !searchQuery.trim().isEmpty()){
        String keyword = searchQuery.toLowerCase();
        allFoods.removeIf(f -> !(f.get("id").toString().contains(keyword)
                               || f.get("name").toString().toLowerCase().contains(keyword)
                               || f.get("food_type").toString().toLowerCase().contains(keyword)));
    }

    // --- SORT ---
    if(sortField != null && !sortField.isEmpty()){
        Comparator<Map<String,Object>> comp = Comparator.comparing(f -> (Comparable)f.get("id"));
        if("name".equals(sortField)) comp = Comparator.comparing(f -> (String)f.get("name"));
        else if("price".equals(sortField)) comp = Comparator.comparing(f -> (Double)f.get("price"));
        else if("type".equals(sortField)) comp = Comparator.comparing(f -> (String)f.get("food_type"));
        else if("rating".equals(sortField)) comp = Comparator.comparing(f -> (Double)f.get("rating"));
        if("desc".equals(sortOrder)) comp = comp.reversed();
        allFoods.sort(comp);
    }

    // --- PAGINATION ---
    int total = allFoods.size();
    int start = (currentPage - 1) * pageSize;
    int end = Math.min(start + pageSize, total);
    List<Map<String,Object>> pageFoods = (start < end) ? allFoods.subList(start, end) : List.of();

    if(pageFoods.isEmpty()){
        out.print("<tr><td colspan='7' class='px-6 py-4 text-center text-gray-500'>No food items found.</td></tr>");
    } else {
        int rowNum = start + 1;
        for(Map<String,Object> f : pageFoods){
%>
<tr class="hover:bg-gray-50" id="foodRow_<%=f.get("id")%>">
   <td class="px-6 py-4"><%= f.get("id") %></td>
   <td class="px-6 py-4">
        <img src="<%= f.get("image")!=null?f.get("image"):"assets/img/cart_empty.png" %>" 
             alt="Food Image" class="w-12 h-12 rounded object-cover" />
   </td>
   <td class="px-6 py-4 font-medium text-gray-900"><%= f.get("name") %></td>
   <td class="px-6 py-4">$<%= f.get("price") %></td>
   <td class="px-6 py-4 capitalize"><%= f.get("food_type") %></td>
   <td class="px-6 py-4"><%= f.get("rating") %> ⭐</td>
   <td class="px-6 py-4 text-center flex justify-center space-x-2">
        <a href="editFood.jsp?id=<%= f.get("id") %>" class="p-2 bg-gray-100 rounded hover:bg-gray-200">
            <i class="fa fa-pencil text-gray-600"></i>
        </a>
        <button onclick="deleteFood(<%= f.get("id") %>)" class="p-2 bg-gray-100 rounded hover:bg-red-100">
            <i class="fa fa-trash text-red-600"></i>
        </button>
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
            <h1 class="text-2xl font-bold mb-6 text-gray-900">Food Management</h1>

            <div id="toastContainer" class="fixed top-5 right-5 z-50"></div>

            <div class="flex justify-between items-center mb-4">
                <input type="text" id="searchInput" placeholder="Search foods..."
                       class="px-4 py-2 border rounded-lg w-72 focus:outline-none focus:ring-2 focus:ring-blue-500"/>
                <a href="add-food.jsp" class="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-lg">+ Add New Food</a>
            </div>

            <div class="overflow-x-auto bg-white shadow rounded-lg">
                <table class="min-w-full text-sm text-left">
                    <thead class="bg-gray-100 text-gray-700 uppercase text-xs">
                        <tr>
                            <th class="px-6 py-3 cursor-pointer" onclick="sortTable('id')">ID</th>
                            <th class="px-6 py-3">Image</th>
                            <th class="px-6 py-3 cursor-pointer" onclick="sortTable('name')">Name</th>
                            <th class="px-6 py-3 cursor-pointer" onclick="sortTable('price')">Price</th>
                            <th class="px-6 py-3 cursor-pointer" onclick="sortTable('type')">Type</th>
                            <th class="px-6 py-3 cursor-pointer" onclick="sortTable('rating')">Rating</th>
                            <th class="px-6 py-3 text-center">Action</th>
                        </tr>
                    </thead>
                    <tbody id="foodTableBody"></tbody>
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

function loadFoods(page=1, query="", sortField=currentSortField, sortOrder=currentSortOrder){
    currentPage = page;
    fetch('food-lists.jsp', {
        method:'POST',
        headers:{'X-Requested-With':'XMLHttpRequest','Content-Type':'application/x-www-form-urlencoded'},
        body:'search='+encodeURIComponent(query)+'&page='+page+'&sortField='+sortField+'&sortOrder='+sortOrder
    })
    .then(res=>res.text())
    .then(html=>{
        document.getElementById('foodTableBody').innerHTML = html;
        renderPagination(query);
    });
}

function deleteFood(id){
    if(!confirm("Are you sure you want to delete this food item?")) return;
    fetch("food-lists.jsp?action=delete&id="+id, {headers:{'X-Requested-With':'XMLHttpRequest'}})
    .then(res => res.json())
    .then(data => {
        if(data.success){
            showToast("Food item deleted successfully!");
            loadFoods(currentPage, document.getElementById('searchInput').value);
        } else {
            showToast("Failed to delete food item.", true);
        }
    })
    .catch(err => {
        console.error(err);
        showToast("Error occurred while deleting.", true);
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
searchInput.addEventListener('input', debounce(function(){
    loadFoods(1,this.value,currentSortField,currentSortOrder);
},500));

function debounce(func, delay){
    let timer;
    return function(...args){ clearTimeout(timer); timer = setTimeout(()=>func.apply(this,args),delay); }
}

function sortTable(field){
    if(currentSortField===field) currentSortOrder = (currentSortOrder==='asc')?'desc':'asc';
    else { currentSortField = field; currentSortOrder = 'asc'; }
    loadFoods(1, searchInput.value, currentSortField, currentSortOrder);
}

function renderPagination(query=""){
    fetch('food-lists.jsp', {
        method:'POST',
        headers:{'X-Requested-With':'XMLHttpRequest','Content-Type':'application/x-www-form-urlencoded'},
        body:'search='+encodeURIComponent(query)
    })
    .then(res=>res.text())
    .then(html=>{
        // Compute total rows from hidden count
        const totalRows = <%= allFoods.size() %>;
        const totalPages = Math.ceil(totalRows/pageSize);
        const container = document.getElementById('pagination');
        container.innerHTML = '';

        const prev = document.createElement('a');
        prev.href="javascript:void(0)";
        prev.innerText="Prev";
        prev.className="px-4 py-2 rounded-md border "+(currentPage===1?"bg-gray-200 text-gray-500":"bg-white text-gray-700 hover:bg-blue-100");
        prev.addEventListener('click',()=>{ if(currentPage>1) loadFoods(currentPage-1,searchInput.value); });
        container.appendChild(prev);

        for(let i=1;i<=totalPages;i++){
            const a=document.createElement('a');
            a.href="javascript:void(0)";
            a.innerText=i;
            a.className="px-4 py-2 rounded-md border "+(i===currentPage?"bg-blue-600 text-white":"bg-white text-gray-700 hover:bg-blue-100");
            a.addEventListener('click',()=>loadFoods(i,searchInput.value));
            container.appendChild(a);
        }

        const next=document.createElement('a');
        next.href="javascript:void(0)";
        next.innerText="Next";
        next.className="px-4 py-2 rounded-md border "+(currentPage===totalPages?"bg-gray-200 text-gray-500":"bg-white text-gray-700 hover:bg-blue-100");
        next.addEventListener('click',()=>{ if(currentPage<totalPages) loadFoods(currentPage+1,searchInput.value); });
        container.appendChild(next);
    });
}

window.onload = function(){ loadFoods(); }
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
