<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.demo.model.Seat" %>
<%@ page import="com.demo.dao.SeatsDao" %>

<%
    // Admin session check
    com.demo.model.User user = (com.demo.model.User) session.getAttribute("user");
    if (user == null || !"admin".equals(user.getRole())) {
        response.sendRedirect("login.jsp?msg=unauthorized");
        return;
    }

    Integer theaterId = (Integer) session.getAttribute("theater_id");
    if (theaterId == null) {
        response.sendRedirect("create-theater-admin.jsp?msg=noTheater");
        return;
    }

    SeatsDao seatDao = new SeatsDao();
    List<Seat> seatsList = seatDao.getSeatsByTheater(theaterId);
%>

<jsp:include page="layout/JSPHeader.jsp"/>
<div class="flex min-h-screen">
    <jsp:include page="layout/sidebar.jsp"/>
    <div class="flex-1 sm:ml-64">
        <jsp:include page="layout/AdminHeader.jsp"/>
        <div class="max-w-8xl mx-auto mt-10 p-8">
            <h2 class="text-2xl font-bold mb-6 text-center">Edit Seat Layout</h2>

            <!-- Form -->
            <form action="UpdateSeatsServlet" method="post">
                <input type="hidden" name="theater_id" value="<%= theaterId %>"/>
                <input type="hidden" id="seatLayout" name="seatLayout" />

                <div class="mb-6 text-center">
                    <button type="submit" class="px-6 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700">
                        Save Seat Layout
                    </button>
                </div>

                <!-- Seat Preview -->
                <div id="seatPreview" class="space-y-3 max-w-5xl mx-auto">
                </div>
            </form>
        </div>
    </div>
</div>
<jsp:include page="layout/JSPFooter.jsp"/>

<script>
    const seatPreview = document.getElementById("seatPreview");
    const seatLayoutInput = document.getElementById("seatLayout");

    // Convert existing seats from JSP into JS array
    const existingSeats = [
        <% for (Seat s : seatsList) { %>
            { seatNumber: '<%= s.getSeatNumber() %>', seatType: '<%= s.getSeatType() %>', status: '<%= s.getStatus() %>' },
        <% } %>
    ];

    const layout = [];

    function renderSeats() {
        seatPreview.innerHTML = "";
        let lastRow = '';
        let rowDiv;
        existingSeats.forEach((seat, index) => {
            const rowLetter = seat.seatNumber.charAt(0);
            const seatNumber = seat.seatNumber.substring(1);

            if (rowLetter !== lastRow) {
                if (rowDiv) seatPreview.appendChild(rowDiv);
                rowDiv = document.createElement("div");
                rowDiv.className = "flex justify-center gap-2 mb-2 items-center";
                
                // Row Label
                const rowLabel = document.createElement("div");
                rowLabel.className = "w-6 text-sm font-medium text-gray-600";
                rowLabel.innerText = rowLetter;
                rowDiv.appendChild(rowLabel);

                layout.push([]);
                lastRow = rowLetter;
            }

            const seatDiv = document.createElement("div");
            let baseClass = "rounded-lg font-medium flex items-center justify-center cursor-pointer ";
            if (seat.status.toLowerCase() === "booked") {
                baseClass += "bg-gray-300 text-gray-500 cursor-not-allowed ";
            } else {
                if (seat.seatType.toUpperCase() === "VIP") baseClass += "bg-amber-500 text-white hover:bg-amber-600 ";
                else if (seat.seatType.toUpperCase() === "COUPLE") baseClass += "bg-purple-500 text-white hover:bg-purple-600 ";
                else baseClass += "bg-blue-500 text-white hover:bg-blue-600 ";
            }

            if (seat.seatType.toUpperCase() === "COUPLE") baseClass += "w-14 h-10 text-xs";
            else baseClass += "w-10 h-10 text-sm";

            seatDiv.className = baseClass;
            seatDiv.title = `Seat: ${seat.seatNumber} | Type: ${seat.seatType} | Status: ${seat.status}`;
            seatDiv.dataset.row = layout.length - 1;
            seatDiv.dataset.col = layout[layout.length - 1].length;
            seatDiv.dataset.active = seat.status.toLowerCase() === "booked" ? 0 : 1;

            if (seat.status.toLowerCase() !== "booked") {
                seatDiv.addEventListener("click", () => {
                    seatDiv.classList.toggle("invisible");
                    seatDiv.dataset.active = seatDiv.classList.contains("invisible") ? 0 : 1;
                    saveSeatLayout();
                });
            }

            seatDiv.innerText = seatNumber;
            rowDiv.appendChild(seatDiv);
            layout[layout.length - 1].push({ seatType: seat.seatType, active: seatDiv.dataset.active });
        });

        if (rowDiv) seatPreview.appendChild(rowDiv);

        saveSeatLayout();
    }

    function saveSeatLayout() {
        const result = layout.map(row => row.map(seat => ({ type: seat.seatType, active: seat.active })));
        seatLayoutInput.value = JSON.stringify(result);
    }

    renderSeats();
</script>
