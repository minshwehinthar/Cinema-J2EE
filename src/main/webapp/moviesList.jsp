<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="com.demo.dao.MoviesDao" %>
<%@ page import="com.demo.model.Movies" %>

<%
    int pageSize = 5;
    MoviesDao moviesDAO = new MoviesDao();
    List<Movies> allMovies = moviesDAO.getAllMovies();

    // --- AJAX HANDLER ---
    if("POST".equalsIgnoreCase(request.getMethod())){
        if("deleteMovie".equals(request.getParameter("action"))){
            int movieId = Integer.parseInt(request.getParameter("movieId"));
            boolean success = moviesDAO.deleteMovie(movieId);
            out.print("{\"success\":" + success + "}");
            return;
        }

        if("1".equals(request.getParameter("ajax_search"))){
            String searchQuery = request.getParameter("search");
            String sortField = request.getParameter("sortField");
            String sortOrder = request.getParameter("sortOrder");

            if(searchQuery != null && !searchQuery.trim().isEmpty()){
                String keyword = searchQuery.toLowerCase();
                allMovies.removeIf(m -> 
                    !(m.getTitle().toLowerCase().contains(keyword) ||
                      (m.getDirector()!=null && m.getDirector().toLowerCase().contains(keyword)) ||
                      (m.getGenres()!=null && m.getGenres().toLowerCase().contains(keyword)))
                );
            }

            // --- SORTING ---
            if(sortField != null && !sortField.isEmpty()){
                Comparator<Movies> comp = Comparator.comparing(Movies::getMovie_id);
                if("title".equals(sortField)) comp = Comparator.comparing(Movies::getTitle);
                else if("director".equals(sortField)) comp = Comparator.comparing(m -> m.getDirector()!=null?m.getDirector():"");
                else if("status".equals(sortField)) comp = Comparator.comparing(Movies::getStatus);

                if("desc".equals(sortOrder)) comp = comp.reversed();
                allMovies.sort(comp);
            }
        }

        int currentPage = request.getParameter("page")!=null?Integer.parseInt(request.getParameter("page")):1;
        int totalMovies = allMovies.size();
        int start = (currentPage-1)*pageSize;
        int end = Math.min(start+pageSize, totalMovies);
        List<Movies> pageMovies = (start<end)?allMovies.subList(start,end):List.of();

        if(pageMovies.isEmpty()){
            out.print("<tr><td colspan='7' class='px-6 py-8 text-center'><div class='w-16 h-16 mx-auto mb-4 text-gray-300'><svg fill='none' stroke='currentColor' viewBox='0 0 24 24'><path stroke-linecap='round' stroke-linejoin='round' stroke-width='1' d='M19 11H5m14 0a2 2 0 012 2v6a2 2 0 01-2 2H5a2 2 0 01-2-2v-6a2 2 0 012-2m14 0V9a2 2 0 00-2-2M5 11V9a2 2 0 012-2m0 0V5a2 2 0 012-2h6a2 2 0 012 2v2M7 7h10'/></svg></div><h3 class='text-lg font-medium text-gray-600 mb-2'>No movies found</h3><p class='text-gray-500'>Try adjusting your search or filter to find what you're looking for.</p></td></tr>");
        } else {
            for(Movies m : pageMovies){
%>
<tr class="hover:bg-red-50 transition-colors duration-150" id="movieRow_<%=m.getMovie_id()%>">
    <td class="px-6 py-4">
        <div class="flex items-center space-x-3">
            <div class="w-10 h-10 bg-red-100 rounded-lg flex items-center justify-center">
                <span class="text-red-600 font-bold text-sm">#<%=m.getMovie_id()%></span>
            </div>
        </div>
    </td>
    <td class="px-6 py-4">
        <div class="font-medium text-gray-900"><%= m.getTitle() %></div>
        <div class="text-sm text-gray-500"><%= m.getDuration() %></div>
    </td>
    <td class="px-6 py-4"><%= (m.getDirector()!=null?m.getDirector():"") %></td>
    <td class="px-6 py-4"><%= (m.getGenres()!=null?m.getGenres():"") %></td>
    <td class="px-6 py-4">
        <span class="inline-flex items-center px-3 py-1 rounded-full text-xs font-medium border <%= "now-showing".equals(m.getStatus())?"bg-green-100 text-green-800 border-green-200":"bg-yellow-100 text-yellow-800 border-yellow-200" %>">
            <%= m.getStatus() %>
        </span>
    </td>
    <td class="px-6 py-4">
        <div class="flex justify-center space-x-3 min-w-[90px]">
            <a href="MoviesDetails.jsp?id=<%= m.getMovie_id() %>" 
               class="inline-flex items-center justify-center w-10 h-10 text-gray-600 bg-white border border-gray-300 rounded-lg hover:bg-gray-50 hover:border-gray-400 transition-colors duration-200 shadow-sm cursor-pointer">
                <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                    <path d="M2.062 12.348a1 1 0 0 1 0-.696 10.75 10.75 0 0 1 19.876 0 1 1 0 0 1 0 .696 10.75 10.75 0 0 1-19.876 0"/>
                    <circle cx="12" cy="12" r="3"/>
                </svg>
            </a>
            <a href="editMovie.jsp?movieId=<%=m.getMovie_id()%>" 
               class="inline-flex items-center justify-center w-10 h-10 text-blue-600 bg-white border border-blue-300 rounded-lg hover:bg-blue-50 hover:border-blue-400 transition-colors duration-200 shadow-sm cursor-pointer">
                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-5 h-5">
                    <path stroke-linecap="round" stroke-linejoin="round" d="m16.862 4.487 1.687-1.688a1.875 1.875 0 1 1 2.652 2.652L10.582 16.07a4.5 4.5 0 0 1-1.897 1.13L6 18l.8-2.685a4.5 4.5 0 0 1 1.13-1.897l8.932-8.931Zm0 0L19.5 7.125M18 14v4.75A2.25 2.25 0 0 1 15.75 21H5.25A2.25 2.25 0 0 1 3 18.75V8.25A2.25 2.25 0 0 1 5.25 6H10" />
                </svg>
            </a>
            <button onclick="deleteMovie(<%= m.getMovie_id() %>)"
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
            <!-- Breadcrumb -->
				<nav class="text-gray-500 text-sm mb-6" aria-label="Breadcrumb">
					<ol class="list-none p-0 inline-flex">
						<li><a href="index.jsp" class="hover:text-red-600">Home</a></li>
						<li><span class="mx-2">/</span></li>

						<li class="flex items-center text-gray-900 font-semibold">Movie Management</li>
					</ol>
				</nav>
            <!-- Header Section -->
            <div class="flex justify-between items-center mb-6">
                <div>
                    <h1 class="text-2xl font-bold text-gray-900">Movies Management</h1>
                    <p class="text-gray-600 mt-1">Manage all movies and their details</p>
                </div>
            </div>

            <!-- Search and Filter -->
            <div class="flex justify-between items-center mb-6">
                <div class="flex space-x-4">
                    <input type="text" id="searchInput" placeholder="Search by Title, Director, Genre..." 
                           class="px-4 py-2 border border-gray-300 rounded-lg w-80 focus:outline-none ring-transparent "/>
                </div>
                <a href="addMovies.jsp" class="bg-red-600 text-white px-4 py-2 rounded-lg hover:bg-red-700 transition-colors duration-200 shadow-sm">+ Add Movie</a>
            </div>

            <!-- Movies Table -->
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
                                <th class="px-6 py-4 font-semibold cursor-pointer" onclick="sortTable('title')">
                                    <div class="flex items-center space-x-1">
                                        <span>Title</span>
                                        <svg class="w-4 h-4 text-gray-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 16V4m0 0L3 8m4-4l4 4m6 0v12m0 0l4-4m-4 4l-4-4"/>
                                        </svg>
                                    </div>
                                </th>
                                <th class="px-6 py-4 font-semibold cursor-pointer" onclick="sortTable('director')">
                                    <div class="flex items-center space-x-1">
                                        <span>Director</span>
                                        <svg class="w-4 h-4 text-gray-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 16V4m0 0L3 8m4-4l4 4m6 0v12m0 0l4-4m-4 4l-4-4"/>
                                        </svg>
                                    </div>
                                </th>
                                <th class="px-6 py-4 font-semibold">Genres</th>
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
                        Total <span class="shadow-sm px-3 py-2 rounded border border-gray-200 mx-2" id="totalMovies">
                            <%= allMovies.size() %>
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

function loadMovies(page=1, query="", sortField=currentSortField, sortOrder=currentSortOrder){
    currentPage = page;
    fetch('moviesList.jsp', {
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

function deleteMovie(movieId){
    if(!confirm("Are you sure you want to delete this movie?")) return;
    fetch('moviesList.jsp',{
        method:'POST',
        headers:{'Content-Type':'application/x-www-form-urlencoded'},
        body:'action=deleteMovie&movieId='+movieId
    })
    .then(res=>res.json())
    .then(data=>{
        if(data.success){
            showToast("Movie #"+movieId+" deleted!");
            loadMovies(currentPage, document.getElementById('searchInput').value);
        } else {
            showToast("Failed to delete movie #"+movieId,true);
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

const searchInput = document.getElementById('searchInput');
searchInput.addEventListener('input',debounce(function(){
    loadMovies(1,this.value,currentSortField,currentSortOrder);
},500));

function debounce(func,delay){
    let timer;
    return function(...args){
        clearTimeout(timer);
        timer = setTimeout(()=>func.apply(this,args),delay);
    }
}

function renderPagination(){
    const totalMovies = <%= allMovies.size() %>;
    const totalPages = Math.ceil(totalMovies / pageSize);
    
    // Update page info
    document.getElementById('currentPage').textContent = currentPage;
    document.getElementById('totalPages').textContent = totalPages;
    document.getElementById('totalMovies').textContent = totalMovies;
    
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
            loadMovies(currentPage - 1, searchInput.value);
        }
    };
    
    nextBtn.onclick = () => {
        if(currentPage < totalPages) {
            loadMovies(currentPage + 1, searchInput.value);
        }
    };
}

function handleLimitChange() {
    const select = document.getElementById('recordsPerPage');
    pageSize = parseInt(select.value);
    loadMovies(1, searchInput.value);
}

// --- SORT FUNCTION ---
function sortTable(field){
    if(currentSortField===field){
        currentSortOrder = (currentSortOrder==='asc')?'desc':'asc';
    } else {
        currentSortField = field;
        currentSortOrder = 'asc';
    }
    loadMovies(1, searchInput.value, currentSortField, currentSortOrder);
}

window.onload = function(){ 
    loadMovies(); 
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