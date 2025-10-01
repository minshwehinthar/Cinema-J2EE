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
            out.print("<tr><td colspan='7' class='px-6 py-4 text-center text-gray-500'>No movies found.</td></tr>");
        } else {
            for(Movies m : pageMovies){
%>
<tr class="hover:bg-gray-50" id="movieRow_<%=m.getMovie_id()%>">
    <td class="px-6 py-4"><%=m.getMovie_id()%></td>
    <td class="px-6 py-4 font-medium text-gray-900">
        <p><%= m.getTitle() %></p>
        <p class="text-sm text-gray-500"><%= m.getDuration() %></p>
    </td>
    <td class="px-6 py-4"><%= (m.getDirector()!=null?m.getDirector():"") %></td>
    <td class="px-6 py-4"><%= (m.getGenres()!=null?m.getGenres():"") %></td>
    <td class="px-6 py-4">
        <span class="px-2 py-1 rounded text-xs font-semibold <%= "now-showing".equals(m.getStatus())?"bg-green-100 text-green-700":"bg-yellow-100 text-yellow-700" %>">
            <%= m.getStatus() %>
        </span>
    </td>
    <td class="px-6 py-4 text-center flex justify-center space-x-2">
    <a href="MoviesDetails.jsp?movieId=<%=m.getMovie_id()%>" 
       class="bg-gray-500 text-white px-3 py-1 rounded hover:bg-gray-600 text-sm">Detail</a>
    <a href="editMovie.jsp?movieId=<%=m.getMovie_id()%>" 
           class="bg-blue-500 text-white px-3 py-1 rounded hover:bg-blue-600 text-sm">Edit</a>
        <button onclick="deleteMovie(<%= m.getMovie_id() %>)"
                class="bg-red-500 text-white px-3 py-1 rounded hover:bg-red-600 text-sm">
            Delete
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
            <h1 class="text-2xl font-bold mb-6 text-gray-900">Movies List</h1>

            <div id="toastContainer" class="fixed top-5 right-5 z-50"></div>

            <div class="flex justify-between items-center mb-4">
                <input type="text" id="searchInput" placeholder="Search by Title, Director, Genre..."
                       class="px-4 py-2 border rounded-lg w-80 focus:outline-none focus:ring-2 focus:ring-blue-500"/>
                <a href="addMovies.jsp" class="bg-blue-500 text-white px-4 py-2 rounded hover:bg-blue-600">+ Add Movie</a>
            </div>

            <div class="overflow-x-auto bg-white shadow rounded-lg">
                <table class="min-w-full text-sm text-left">
                    <thead class="bg-gray-100 text-gray-700 uppercase text-xs">
                        <tr>
                            <th class="px-6 py-3 cursor-pointer" onclick="sortTable('id')">ID</th>
                            <th class="px-6 py-3 cursor-pointer" onclick="sortTable('title')">Title</th>
                            <th class="px-6 py-3 cursor-pointer" onclick="sortTable('director')">Director</th>
                            <th class="px-6 py-3">Genres</th>
                            <th class="px-6 py-3 cursor-pointer" onclick="sortTable('status')">Status</th>
                            <th class="px-6 py-3 text-center">Actions</th>
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
let currentPage = 1;
const pageSize = 5;
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
    const container = document.getElementById('pagination');
    container.innerHTML = '';

    const prev = document.createElement('a');
    prev.href = "javascript:void(0)";
    prev.innerText = "Prev";
    prev.className = "px-4 py-2 rounded-md border "+(currentPage===1?"bg-gray-200 text-gray-500":"bg-white text-gray-700 hover:bg-blue-100");
    prev.addEventListener('click',()=>{ if(currentPage>1) loadMovies(currentPage-1,searchInput.value); });
    container.appendChild(prev);

    for(let i=1;i<=totalPages;i++){
        const a = document.createElement('a');
        a.href = "javascript:void(0)";
        a.innerText = i;
        a.className = "px-4 py-2 rounded-md border "+(i===currentPage?"bg-blue-600 text-white":"bg-white text-gray-700 hover:bg-blue-100");
        a.addEventListener('click',()=>loadMovies(i,searchInput.value));
        container.appendChild(a);
    }

    const next = document.createElement('a');
    next.href = "javascript:void(0)";
    next.innerText = "Next";
    next.className = "px-4 py-2 rounded-md border "+(currentPage===totalPages?"bg-gray-200 text-gray-500":"bg-white text-gray-700 hover:bg-blue-100");
    next.addEventListener('click',()=>{ if(currentPage<totalPages) loadMovies(currentPage+1,searchInput.value); });
    container.appendChild(next);
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

window.onload = function(){ loadMovies(); }
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
