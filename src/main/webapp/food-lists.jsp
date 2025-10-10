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
        out.print("<tr><td colspan='7' class='px-6 py-8 text-center'><div class='w-16 h-16 mx-auto mb-4 text-gray-300'><svg fill='none' stroke='currentColor' viewBox='0 0 24 24'><path stroke-linecap='round' stroke-linejoin='round' stroke-width='1' d='M12 3v1m0 16v1m9-9h-1M4 12H3m15.364 6.364l-.707-.707M6.343 6.343l-.707-.707m12.728 0l-.707.707M6.343 17.657l-.707.707M16 12a4 4 0 11-8 0 4 4 0 018 0z'/></svg></div><h3 class='text-lg font-medium text-gray-600 mb-2'>No food items found</h3><p class='text-gray-500'>Try adjusting your search or filter to find what you're looking for.</p></td></tr>");
    } else {
        int rowNum = start + 1;
        for(Map<String,Object> f : pageFoods){
%>
<tr class="hover:bg-red-50 transition-colors duration-150" id="foodRow_<%=f.get("id")%>">
    <td class="px-6 py-4">
        <div class="flex items-center space-x-3">
            <div class="w-10 h-10 bg-red-100 rounded-lg flex items-center justify-center">
                <span class="text-red-600 font-bold text-sm">#<%= f.get("id") %></span>
            </div>
        </div>
    </td>
    <td class="px-6 py-4">
        <img src="<%= f.get("image")!=null?f.get("image"):"assets/img/cart_empty.png" %>" 
             alt="Food Image" class="w-12 h-12 rounded-lg object-cover border border-gray-200" />
    </td>
    <td class="px-6 py-4">
        <div class="font-medium text-gray-900"><%= f.get("name") %></div>
    </td>
    <td class="px-6 py-4">
        <div class="font-semibold text-red-600">$<%= f.get("price") %></div>
    </td>
    <td class="px-6 py-4">
        <span class="inline-flex items-center px-3 py-1 rounded-full text-xs font-medium bg-blue-100 text-blue-800 border border-blue-200 capitalize">
            <%= f.get("food_type") %>
        </span>
    </td>
    <td class="px-6 py-4">
        <div class="flex items-center space-x-1">
            <span class="font-medium text-gray-900"><%= f.get("rating") %></span>
            <svg class="w-4 h-4 text-yellow-500" fill="currentColor" viewBox="0 0 20 20">
                <path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z"/>
            </svg>
        </div>
    </td>
    <td class="px-6 py-4">
        <div class="flex justify-center space-x-3 min-w-[90px]">
            <a href="editFood.jsp?id=<%= f.get("id") %>" 
               class="inline-flex items-center justify-center w-10 h-10 text-blue-600 bg-white border border-blue-300 rounded-lg hover:bg-blue-50 hover:border-blue-400 transition-colors duration-200 shadow-sm cursor-pointer">
                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-5 h-5">
                    <path stroke-linecap="round" stroke-linejoin="round" d="m16.862 4.487 1.687-1.688a1.875 1.875 0 1 1 2.652 2.652L10.582 16.07a4.5 4.5 0 0 1-1.897 1.13L6 18l.8-2.685a4.5 4.5 0 0 1 1.13-1.897l8.932-8.931Zm0 0L19.5 7.125M18 14v4.75A2.25 2.25 0 0 1 15.75 21H5.25A2.25 2.25 0 0 1 3 18.75V8.25A2.25 2.25 0 0 1 5.25 6H10" />
                </svg>
            </a>
            <button onclick="deleteFood(<%= f.get("id") %>)" 
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
%>

<jsp:include page="layout/JSPHeader.jsp"/>
<div class="flex">
    <jsp:include page="layout/sidebar.jsp"/>
    <div class="flex-1 sm:ml-64">
        <jsp:include page="/layout/AdminHeader.jsp"/>
        <div class="p-8 max-w-8xl mx-auto">
            
            <!-- Header Section -->
            <div class="flex justify-between items-center mb-6">
            
                <div>
                <!-- Breadcrumb -->
				<nav class="text-gray-500 text-sm mb-6" aria-label="Breadcrumb">
					<ol class="list-none p-0 inline-flex">
						<li><a href="index.jsp" class="hover:text-red-600">Home</a></li>
						<li><span class="mx-2">/</span></li>

						<li class="flex items-center text-gray-900 font-semibold">Food Management</li>
					</ol>
				</nav>
                    <h1 class="text-2xl font-bold text-gray-900">Food Management</h1>
                    <p class="text-gray-600 mt-1">Manage all food items and their details</p>
                </div>
            </div>

            <!-- Search and Filter -->
            <div class="flex justify-between items-center mb-6">
                <div class="flex space-x-4">
                    <input type="text" id="searchInput" placeholder="Search foods..." 
                           class="px-4 py-2 border border-gray-300 rounded-lg w-80 focus:outline-none ring-transparent "/>
                </div>
                <a href="add-food.jsp" class="bg-red-600 text-white px-4 py-2 rounded-lg hover:bg-red-700 transition-colors duration-200 shadow-sm">+ Add New Food</a>
            </div>

            <!-- Food Items Table -->
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
                                <th class="px-6 py-4 font-semibold">Image</th>
                                <th class="px-6 py-4 font-semibold cursor-pointer" onclick="sortTable('name')">
                                    <div class="flex items-center space-x-1">
                                        <span>Name</span>
                                        <svg class="w-4 h-4 text-gray-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 16V4m0 0L3 8m4-4l4 4m6 0v12m0 0l4-4m-4 4l-4-4"/>
                                        </svg>
                                    </div>
                                </th>
                                <th class="px-6 py-4 font-semibold cursor-pointer" onclick="sortTable('price')">
                                    <div class="flex items-center space-x-1">
                                        <span>Price</span>
                                        <svg class="w-4 h-4 text-gray-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 16V4m0 0L3 8m4-4l4 4m6 0v12m0 0l4-4m-4 4l-4-4"/>
                                        </svg>
                                    </div>
                                </th>
                                <th class="px-6 py-4 font-semibold cursor-pointer" onclick="sortTable('type')">
                                    <div class="flex items-center space-x-1">
                                        <span>Type</span>
                                        <svg class="w-4 h-4 text-gray-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 16V4m0 0L3 8m4-4l4 4m6 0v12m0 0l4-4m-4 4l-4-4"/>
                                        </svg>
                                    </div>
                                </th>
                                <th class="px-6 py-4 font-semibold cursor-pointer" onclick="sortTable('rating')">
                                    <div class="flex items-center space-x-1">
                                        <span>Rating</span>
                                        <svg class="w-4 h-4 text-gray-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 16V4m0 0L3 8m4-4l4 4m6 0v12m0 0l4-4m-4 4l-4-4"/>
                                        </svg>
                                    </div>
                                </th>
                                <th class="px-6 py-4 font-semibold text-center">Actions</th>
                            </tr>
                        </thead>
                        <tbody id="foodTableBody" class="divide-y divide-gray-100"></tbody>
                    </table>
                </div>
            </div>

            <!-- Pagination -->
            <div class="flex mt-6 justify-between items-center">
                <!-- Left Section: Total and Row -->
                <div class="flex items-center gap-4">
                    <div class="text-sm text-gray-700">
                        Total <span class="shadow-sm px-3 py-2 rounded border border-gray-200 mx-2" id="totalFoods">
                            <%= allFoods.size() %>
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
        renderPagination();
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

function renderPagination(){
    const totalFoods = <%= allFoods.size() %>;
    const totalPages = Math.ceil(totalFoods / pageSize);
    
    // Update page info
    document.getElementById('currentPage').textContent = currentPage;
    document.getElementById('totalPages').textContent = totalPages;
    document.getElementById('totalFoods').textContent = totalFoods;
    
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
            loadFoods(currentPage - 1, searchInput.value);
        }
    };
    
    nextBtn.onclick = () => {
        if(currentPage < totalPages) {
            loadFoods(currentPage + 1, searchInput.value);
        }
    };
}

function handleLimitChange() {
    const select = document.getElementById('recordsPerPage');
    pageSize = parseInt(select.value);
    loadFoods(1, searchInput.value);
}

window.onload = function(){ 
    loadFoods(); 
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

<jsp:include page="layout/JSPFooter.jsp"/>