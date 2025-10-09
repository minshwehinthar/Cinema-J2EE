<%@page import="com.demo.dao.TheaterDAO"%>
<%@page import="com.demo.dao.BookingDao"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="com.demo.model.Booking" %>
<%@ page import="com.demo.model.User" %>
<%@ page import="com.demo.model.Theater" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    // Check if user is admin or theater admin
    User adminUser = (User) session.getAttribute("user");
    if (adminUser == null || (!"admin".equals(adminUser.getRole()) && !"theateradmin".equals(adminUser.getRole()))) {
        response.sendRedirect("login.jsp");
        return;
    }

    // Get theater info for theater admin
    Theater userTheater = null;
    if ("theateradmin".equals(adminUser.getRole())) {
        TheaterDAO theaterDao = new TheaterDAO();
        userTheater = theaterDao.getTheaterByUserId(adminUser.getUserId());
    }

    // Get bookings based on user role
    BookingDao bookingDAO = new BookingDao();
    List<Booking> allBookings = null;
    String errorMessage = null;
    
    // Load all theaters for admin
    TheaterDAO theaterDao = new TheaterDAO();
    ArrayList<Theater> theaters = new ArrayList<>();
    if ("admin".equals(adminUser.getRole())) {
        theaters = (ArrayList<Theater>) theaterDao.getAllTheaters();
    }
    
    try {
        if ("theateradmin".equals(adminUser.getRole()) && userTheater != null) {
            allBookings = bookingDAO.getBookingsByTheaterId(userTheater.getTheaterId());
        } else if ("admin".equals(adminUser.getRole())) {
            allBookings = bookingDAO.getAllBookings();
        } else {
            allBookings = new java.util.ArrayList<>();
        }
    } catch (Exception e) {
        errorMessage = "Error loading bookings: " + e.getMessage();
        allBookings = new java.util.ArrayList<>();
    }
    
    SimpleDateFormat dateFormat = new SimpleDateFormat("MMM dd, yyyy");
    SimpleDateFormat timeFormat = new SimpleDateFormat("HH:mm");
%>

<div class="flex">
    <jsp:include page="layout/sidebar.jsp" />
    <div class="flex-1 sm:ml-64">
        <jsp:include page="layout/AdminHeader.jsp" />
        <div class="p-8 max-w-8xl mx-auto">
            
            <!-- Header Section -->
            <div class="flex justify-between items-center mb-6">
                <div>
                    <h1 class="text-2xl font-bold text-gray-900">Booking Management</h1>
                    <p class="text-gray-600 mt-1">
                        <% if ("theateradmin".equals(adminUser.getRole()) && userTheater != null) { %>
                            Managing bookings for <span class="font-semibold text-red-600"><%= userTheater.getName() %></span>
                        <% } else { %>
                            Manage all customer bookings and seat availability
                        <% } %>
                    </p>
                </div>
                <button onclick="refreshPage()" 
                        class="bg-red-600 text-white px-4 py-2 rounded-lg hover:bg-red-700 transition text-sm font-medium">
                    Refresh
                </button>
            </div>

            <!-- Right Sidebar (Admin Theater Filter) -->
            <% if ("admin".equals(adminUser.getRole())) { %>
            <!-- Sidebar Toggle Button -->
            <button id="sidebar-toggle"
                class="fixed top-[80px] right-0 z-50 bg-red-600 text-white px-3 py-1 rounded-l-lg hover:bg-red-700 transition">
                ☰
            </button>

            <aside id="right-sidebar"
                class="fixed top-[64px] right-0 w-64 h-[calc(100vh-64px)] bg-white border-l border-gray-200 overflow-y-auto p-5 transform translate-x-full transition-transform duration-300 ease-in-out lg:translate-x-0 lg:block">
                <div class="flex justify-between items-center mb-3">
                    <h3 class="text-lg font-semibold text-gray-800">Theater</h3>
                    <button id="sidebar-close"
                        class="lg:hidden text-gray-600 hover:text-red-600 text-xl font-bold">✕</button>
                </div>

                <ul class="space-y-1">
                    <!-- All Button -->
                    <li class="theater-filter px-3 py-2 text-red-700 bg-red-100 rounded-lg cursor-pointer font-semibold"
                        data-theater-id="all">Show All</li>

                    <% for (Theater t : theaters) { %>
                    <li class="theater-filter px-3 py-2 text-gray-700 rounded-lg cursor-pointer hover:bg-red-50 hover:text-red-700 transition"
                        data-theater-id="<%=t.getTheaterId()%>">
                        <span class="block font-medium"><%=t.getName()%></span>
                    </li>
                    <% } %>
                </ul>
            </aside>

            <script>
                const sidebarToggle = document.getElementById('sidebar-toggle');
                const rightSidebar = document.getElementById('right-sidebar');
                const sidebarClose = document.getElementById('sidebar-close');

                sidebarToggle.addEventListener('click', () => {
                    const isOpen = !rightSidebar.classList.contains('translate-x-full');
                    rightSidebar.classList.toggle('translate-x-full');
                    sidebarToggle.textContent = isOpen ? '☰' : '✕';
                });

                sidebarClose.addEventListener('click', () => {
                    rightSidebar.classList.add('translate-x-full');
                    sidebarToggle.textContent = '☰';
                });

                document.addEventListener('click', (e) => {
                    if (!rightSidebar.contains(e.target) && !sidebarToggle.contains(e.target) && !rightSidebar.classList.contains('translate-x-full')) {
                        rightSidebar.classList.add('translate-x-full');
                        sidebarToggle.textContent = '☰';
                    }
                });

                // =============================
                // THEATER FILTER FOR BOOKINGS
                // =============================
                const theaterFilters = document.querySelectorAll('.theater-filter');
                
                theaterFilters.forEach(item => {
                    item.addEventListener('click', () => {
                        const theaterId = item.getAttribute('data-theater-id');

                        // Reset all to inactive
                        theaterFilters.forEach(i => {
                            i.classList.remove('bg-red-100', 'text-red-700', 'font-semibold');
                            i.classList.add('text-gray-700');
                        });

                        // Set active
                        item.classList.remove('text-gray-700');
                        item.classList.add('bg-red-100', 'text-red-700', 'font-semibold');

                        // Show all if "all" selected
                        if (theaterId === "all") {
                            document.querySelectorAll('#tableBody tr').forEach(row => row.style.display = '');
                            return;
                        }

                        // Filter bookings by theater ID
                        document.querySelectorAll('#tableBody tr').forEach(row => {
                            const rowTheaterId = row.getAttribute('data-theater-id');
                            row.style.display = (rowTheaterId === theaterId) ? '' : 'none';
                        });
                    });
                });
            </script>
            <% } %>

            <!-- Theater Admin Info Card -->
            <% if ("theateradmin".equals(adminUser.getRole()) && userTheater != null) { %>
            <div class="bg-gradient-to-r from-red-50 to-white border border-red-200 rounded-lg p-6 mb-6 shadow-sm">
                <div class="flex items-center justify-between">
                    <div class="flex items-center space-x-4">
                        <div class="w-12 h-12 bg-red-100 rounded-lg flex items-center justify-center">
                            <svg class="w-6 h-6 text-red-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4"/>
                            </svg>
                        </div>
                        <div>
                            <h3 class="text-lg font-semibold text-red-800"><%= userTheater.getName() %></h3>
                            <p class="text-red-600 text-sm"><%= userTheater.getLocation() %></p>
                        </div>
                    </div>
                    <span class="inline-flex items-center px-3 py-1 rounded-full text-sm font-medium bg-red-100 text-red-800 border border-red-200">
                        Theater Admin
                    </span>
                </div>
            </div>
            <% } %>

            <!-- Search and Filter -->
            <div class="flex justify-between items-center mb-6">
                <div class="flex space-x-4">
                    <input type="text" id="searchInput" placeholder="Search by ID, User, Showtime..." 
                           class="px-4 py-2 border border-gray-300 rounded-lg w-80 focus:outline-none focus:ring-2 focus:ring-red-500 focus:border-transparent"/>
                    
                    <select id="statusFilter" onchange="filterTable()" 
                            class="px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-red-500 focus:border-transparent">
                        <option value="">All Status</option>
                        <option value="pending">Pending</option>
                        <option value="confirmed">Confirmed</option>
                        <option value="cancelled">Cancelled</option>
                    </select>
                </div>
                
                <div class="text-sm text-gray-600">
                    Total: <span class="font-semibold text-red-600"><%= allBookings.size() %></span> bookings
                </div>
            </div>

            <!-- Bookings Table -->
            <div class="bg-white shadow rounded-lg border border-gray-200 overflow-hidden">
                <div class="overflow-x-auto">
                    <table class="min-w-full text-sm text-left">
                        <thead class="bg-red-50 text-red-700 uppercase text-xs border-b border-red-100">
                            <tr>
                                <th class="px-6 py-4 font-semibold cursor-pointer" onclick="sortTable('id')">
                                    <div class="flex items-center space-x-1">
                                        <span>Booking ID</span>
                                        <svg class="w-4 h-4 text-red-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 16V4m0 0L3 8m4-4l4 4m6 0v12m0 0l4-4m-4 4l-4-4"/>
                                        </svg>
                                    </div>
                                </th>
                                <th class="px-6 py-4 font-semibold">Customer Info</th>
                                <th class="px-6 py-4 font-semibold">Show Details</th>
                                <th class="px-6 py-4 font-semibold cursor-pointer" onclick="sortTable('price')">
                                    <div class="flex items-center space-x-1">
                                        <span>Payment</span>
                                        <svg class="w-4 h-4 text-red-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 16V4m0 0L3 8m4-4l4 4m6 0v12m0 0l4-4m-4 4l-4-4"/>
                                        </svg>
                                    </div>
                                </th>
                                <th class="px-6 py-4 font-semibold">Status</th>
                                <th class="px-6 py-4 font-semibold text-center">Actions</th>
                            </tr>
                        </thead>
                        <tbody id="tableBody" class="divide-y divide-gray-100">
                            <% if (allBookings.isEmpty()) { %>
                                <tr>
                                    <td colspan="6" class="px-6 py-8 text-center">
                                        <div class="w-16 h-16 mx-auto mb-4 text-gray-300">
                                            <svg fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1" d="M16 11V7a4 4 0 00-8 0v4M5 9h14l1 12H4L5 9z"/>
                                            </svg>
                                        </div>
                                        <h3 class="text-lg font-medium text-gray-600 mb-2">No bookings found</h3>
                                        <p class="text-gray-500">
                                            <% if ("theateradmin".equals(adminUser.getRole()) && userTheater != null) { %>
                                                No bookings for <%= userTheater.getName() %> yet.
                                            <% } else { %>
                                                There are no bookings in the system yet.
                                            <% } %>
                                        </p>
                                    </td>
                                </tr>
                            <% } else { 
                                for (Booking booking : allBookings) { 
                                    String statusClass = "";
                                    String statusText = "";
                                    String statusIcon = "";
                                    
                                    // Get theater ID for this booking
                                    int theaterId = 0;
                                    try {
                                        TheaterDAO theaterDaoForBooking = new TheaterDAO();
                                        // You need to implement this method in BookingDao to get theater ID for a booking
                                        theaterId = bookingDAO.getTheaterIdByBookingId(booking.getBookingId());
                                    } catch (Exception e) {
                                        theaterId = 0;
                                    }
                                    
                                    switch(booking.getStatus().toLowerCase()) {
                                    case "pending":
                                        statusClass = "bg-yellow-100 text-yellow-800 border-yellow-200";
                                        statusText = "Pending";
                                        statusIcon = "<i class=\"fa-regular fa-hourglass-half\"></i>";
                                        break;
                                    case "confirmed":
                                        statusClass = "bg-green-100 text-green-800 border-green-200";
                                        statusText = "Confirmed";
                                        statusIcon = "<i class=\"fa-solid fa-circle-check\"></i>";
                                        break;
                                    case "cancelled":
                                        statusClass = "bg-red-100 text-red-800 border-red-200";
                                        statusText = "Cancelled";
                                        statusIcon = "<i class=\"fa-solid fa-xmark\"></i>";
                                        break;
                                    case "completed":
                                        statusClass = "bg-blue-100 text-blue-800 border-blue-200";
                                        statusText = "Completed";
                                        statusIcon = "<i class=\"fa-solid fa-flag-checkered\"></i>";
                                        break;
                                    case "refunded":
                                        statusClass = "bg-purple-100 text-purple-800 border-purple-200";
                                        statusText = "Refunded";
                                        statusIcon = "<i class=\"fa-solid fa-rotate-left\"></i>";
                                        break;
                                    case "expired":
                                        statusClass = "bg-gray-100 text-gray-800 border-gray-200";
                                        statusText = "Expired";
                                        statusIcon = "<i class=\"fa-regular fa-clock\"></i>";
                                        break;
                                    default:
                                        statusClass = "bg-gray-100 text-gray-800 border-gray-200";
                                        statusText = booking.getStatus();
                                        statusIcon = "<i class=\"fa-solid fa-question\"></i>";
                                }
                            %>
                            <tr class="hover:bg-red-50 transition-colors duration-150" 
                                id="bookingRow<%= booking.getBookingId() %>"
                                data-theater-id="<%= theaterId %>">
                                <!-- Booking ID -->
                                <td class="px-6 py-4">
                                    <div class="flex items-center space-x-3">
                                        <div class="w-10 h-10 bg-red-100 rounded-lg flex items-center justify-center">
                                            <span class="text-red-600 font-bold text-sm">#<%= booking.getBookingId() %></span>
                                        </div>
                                        <div class="text-xs text-gray-500">
                                            <%= booking.getBookingTime() != null ? dateFormat.format(booking.getBookingTime()) : "N/A" %>
                                        </div>
                                    </div>
                                </td>
                                
                                <!-- Customer Info -->
                                <td class="px-6 py-4">
                                    <div class="font-medium text-gray-900">User #<%= booking.getUserId() %></div>
                                    <div class="text-sm text-gray-500 capitalize">
                                        <%= booking.getPaymentMethod() != null ? booking.getPaymentMethod() : "Unknown" %>
                                    </div>
                                </td>
                                
                                <!-- Show Details -->
                                <td class="px-6 py-4">
                                    <div class="text-gray-900">
                                        <span class="font-medium">Showtime #<%= booking.getShowtimeId() %></span>
                                    </div>
                                    <div class="text-sm text-gray-500">
                                        <%= booking.getSelectedSeatIds() != null ? booking.getSelectedSeatIds().size() + " seats" : "No seats" %>
                                    </div>
                                </td>
                                
                                <!-- Payment -->
                                <td class="px-6 py-4">
                                    <div class="font-semibold text-red-600">
                                        <%= booking.getTotalPrice() != null ? "MMK " + booking.getTotalPrice() : "N/A" %>
                                    </div>
                                </td>
                                
                                <!-- Status -->
                                <td class="px-6 py-4">
                                    <span class="inline-flex items-center px-3 py-1 rounded-full text-xs font-medium border <%= statusClass %>">
                                        <%= statusIcon %> <%= statusText %>
                                    </span>
                                </td>
                                
                                <!-- Actions -->
                                <td class="px-6 py-4">
                                    <div class="flex flex-col space-y-2 min-w-[120px]">
                                        <!-- Status-based actions -->
                                        <% if ("pending".equals(booking.getStatus())) { %>
                                            <button onclick="approveBooking(<%= booking.getBookingId() %>)" 
                                                    class="w-full px-3 py-2 bg-green-600 text-white rounded hover:bg-green-700 transition text-xs font-medium flex items-center justify-center space-x-1">
                                                <span>✓</span>
                                                <span>Approve</span>
                                            </button>
                                        <% } %>
                                        
                                        <% if ("confirmed".equals(booking.getStatus())) { %>
                                            <button onclick="adminCancelBooking(<%= booking.getBookingId() %>)" 
                                                    class="w-full px-3 py-2 bg-red-600 text-white rounded hover:bg-red-700 transition text-xs font-medium flex items-center justify-center space-x-1">
                                                <span>Cancel</span>
                                            </button>
                                        <% } %>
                                        
                                        <!-- View Details Button -->
                                        <button onclick="viewBookingDetails(<%= booking.getBookingId() %>)" 
                                                class="w-full px-3 py-2 bg-blue-600 text-white rounded hover:bg-blue-700 transition text-xs font-medium flex items-center justify-center space-x-1">
                                            <span>View</span>
                                        </button>
                                        
                                        <!-- Delete for cancelled bookings -->
                                        <% if ("cancelled".equals(booking.getStatus())) { %>
                                            <button onclick="deleteBooking(<%= booking.getBookingId() %>)" 
                                                    class="w-full px-3 py-2 bg-gray-600 text-white rounded hover:bg-gray-700 transition text-xs font-medium flex items-center justify-center space-x-1">
                                                <span>Delete</span>
                                            </button>
                                        <% } %>
                                    </div>
                                </td>
                            </tr>
                            <% } 
                            } %>
                        </tbody>
                    </table>
                </div>
            </div>

            <!-- Pagination -->
            <div class="flex justify-center items-center space-x-2 mt-6" id="pagination">
                <!-- Pagination will be populated by JavaScript -->
            </div>

        </div>
    </div>
</div>

<!-- Hidden forms for actions -->
<form id="approveForm" action="ApproveBookingServlet" method="post" class="hidden">
    <input type="hidden" name="bookingId" id="approveBookingId">
</form>

<form id="adminCancelForm" action="AdminCancelBookingServlet" method="post" class="hidden">
    <input type="hidden" name="bookingId" id="adminCancelBookingId">
</form>

<form id="deleteForm" action="DeleteBookingServlet" method="post" class="hidden">
    <input type="hidden" name="bookingId" id="deleteBookingId">
</form>

<script>
// Action functions
function approveBooking(bookingId) {
    if (confirm('Are you sure you want to approve this booking?')) {
        document.getElementById('approveBookingId').value = bookingId;
        document.getElementById('approveForm').submit();
    }
}

function adminCancelBooking(bookingId) {
    if (confirm('Are you sure you want to cancel this booking? This will release the seats for other users.')) {
        document.getElementById('adminCancelBookingId').value = bookingId;
        document.getElementById('adminCancelForm').submit();
    }
}

function deleteBooking(bookingId) {
    if (confirm('Are you sure you want to permanently delete this cancelled booking? This action cannot be undone.')) {
        document.getElementById('deleteBookingId').value = bookingId;
        document.getElementById('deleteForm').submit();
    }
}

function viewBookingDetails(bookingId) {
    window.location.href = 'BookingDetails.jsp?id=' + bookingId;
}

function refreshPage() {
    window.location.reload();
}

// Search and Filter functionality
const searchInput = document.getElementById('searchInput');
const statusFilter = document.getElementById('statusFilter');

function filterTable() {
    const searchTerm = searchInput.value.toLowerCase();
    const statusValue = statusFilter.value.toLowerCase();
    
    const rows = document.querySelectorAll('#tableBody tr');
    
    rows.forEach(row => {
        if (row.cells.length < 6) return; // Skip empty row
        
        const bookingId = row.cells[0].textContent.toLowerCase();
        const customerInfo = row.cells[1].textContent.toLowerCase();
        const showDetails = row.cells[2].textContent.toLowerCase();
        const statusCell = row.cells[4];
        const status = statusCell.textContent.toLowerCase();
        
        const matchesSearch = bookingId.includes(searchTerm) || 
                             customerInfo.includes(searchTerm) || 
                             showDetails.includes(searchTerm);
        
        const matchesStatus = statusValue === '' || status.includes(statusValue);
        
        row.style.display = (matchesSearch && matchesStatus) ? '' : 'none';
    });
}

searchInput.addEventListener('input', filterTable);
statusFilter.addEventListener('change', filterTable);

// Simple sorting function
let currentSort = { field: '', direction: 'asc' };

function sortTable(field) {
    const tbody = document.getElementById('tableBody');
    const rows = Array.from(tbody.querySelectorAll('tr')).filter(row => row.style.display !== 'none');
    
    rows.sort((a, b) => {
        let aValue, bValue;
        
        switch(field) {
            case 'id':
                aValue = parseInt(a.cells[0].querySelector('span').textContent.replace('#', ''));
                bValue = parseInt(b.cells[0].querySelector('span').textContent.replace('#', ''));
                break;
            case 'price':
                aValue = parseFloat(a.cells[3].textContent.replace('MMK ', '')) || 0;
                bValue = parseFloat(b.cells[3].textContent.replace('MMK ', '')) || 0;
                break;
            default:
                return 0;
        }
        
        if (currentSort.field === field && currentSort.direction === 'asc') {
            return aValue - bValue;
        } else {
            return bValue - aValue;
        }
    });
    
    // Toggle sort direction
    if (currentSort.field === field) {
        currentSort.direction = currentSort.direction === 'asc' ? 'desc' : 'asc';
    } else {
        currentSort.field = field;
        currentSort.direction = 'asc';
    }
    
    // Re-append sorted rows
    rows.forEach(row => tbody.appendChild(row));
}

// Initialize pagination
function initPagination() {
    const rows = document.querySelectorAll('#tableBody tr');
    const itemsPerPage = 10;
    const totalPages = Math.ceil(rows.length / itemsPerPage);
    // You can implement proper pagination later
}

// Initialize on load
document.addEventListener('DOMContentLoaded', function() {
    initPagination();
});
</script>