<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
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
%>

<jsp:include page="layout/JSPHeader.jsp"/>
<div class="flex min-h-screen">
    <jsp:include page="layout/sidebar.jsp"/>
    <div class="flex-1 sm:ml-64">
        <jsp:include page="layout/AdminHeader.jsp"/>

        <div class="max-w-8xl mx-auto mt-10 p-8">
            <h2 class="text-2xl font-bold mb-6 text-center">Add Seats for Theater</h2>

            <!-- Two Column Layout -->
            <div class="grid grid-cols-2 gap-10">
                
                <!-- Left Column: Form -->
                <form action="AddSeatsServlet" method="post" class="space-y-6" onsubmit="saveSeatLayout()">
                    <input type="hidden" name="theater_id" value="<%= theaterId %>"/>
                    <input type="hidden" id="seatLayout" name="seatLayout" />

                    <div class="grid grid-cols-1 gap-6">
                        <div>
                            <label class="block font-semibold">Seats per Row:</label>
                            <input type="number" id="seatsPerRow" name="seatsPerRow" min="1" value="8"
                                   class="w-full border rounded-lg p-2" required />
                        </div>

                        <div>
                            <label class="block font-semibold">Normal Rows:</label>
                            <input type="number" id="normalRows" name="normalRows" min="0" value="2"
                                   class="w-full border rounded-lg p-2" required />
                        </div>

                        <div>
                            <label class="block font-semibold">VIP Rows:</label>
                            <input type="number" id="vipRows" name="vipRows" min="0" value="2"
                                   class="w-full border rounded-lg p-2" required />
                        </div>

                        <div>
                            <label class="block font-semibold">Couple Rows:</label>
                            <input type="number" id="coupleRows" name="coupleRows" min="0" value="1"
                                   class="w-full border rounded-lg p-2" required />
                        </div>

                        <div>
                            <label class="block font-semibold">Seats in Couple Row (1 seat = 2 columns):</label>
                            <input type="number" id="coupleSeats" name="coupleSeats" min="1" value="4"
                                   class="w-full border rounded-lg p-2" required />
                        </div>
                    </div>

                    <button type="submit"
                            class="w-full bg-blue-500 text-white py-3 rounded-lg hover:bg-blue-600 mt-6">
                        Add Seats
                    </button>
                </form>

                <!-- Right Column: Preview -->
                <div>
                    <h3 class="text-xl font-bold mb-4 text-center">Seat Preview</h3>
                    <div id="seatPreview" class="space-y-2"></div>
                </div>
            </div>
        </div>
    </div>
</div>
<jsp:include page="layout/JSPFooter.jsp"/>

<script>
    const seatsPerRowInput = document.getElementById("seatsPerRow");
    const normalRowsInput = document.getElementById("normalRows");
    const vipRowsInput = document.getElementById("vipRows");
    const coupleRowsInput = document.getElementById("coupleRows");
    const coupleSeatsInput = document.getElementById("coupleSeats");
    const seatPreview = document.getElementById("seatPreview");
    const seatLayoutInput = document.getElementById("seatLayout");

    let layout = [];

    // Function to convert 0 => A, 1 => B, 25 => Z, 26 => AA, etc.
    function getRowLabel(index) {
        let label = '';
        index += 1;
        while (index > 0) {
            let mod = (index - 1) % 26;
            label = String.fromCharCode(65 + mod) + label;
            index = Math.floor((index - mod - 1) / 26);
        }
        return label;
    }

    function renderSeats() {
        const seatsPerRow = parseInt(seatsPerRowInput.value) || 0;
        const normalRows = parseInt(normalRowsInput.value) || 0;
        const vipRows = parseInt(vipRowsInput.value) || 0;
        const coupleRows = parseInt(coupleRowsInput.value) || 0;
        const coupleSeats = parseInt(coupleSeatsInput.value) || 0;

        layout = [];
        seatPreview.innerHTML = "";

        function createRow(type, count, cols) {
            for (let r = 0; r < count; r++) {
                const rowIndex = layout.length;
                const rowLabel = getRowLabel(rowIndex);

                const row = [];
                const rowDiv = document.createElement("div");
                rowDiv.className = "flex justify-center gap-2";

                for (let c = 0; c < cols; c++) {
                    const seat = document.createElement("div");
                    seat.className =
                        type === "normal" ? "w-10 h-10 bg-gray-400 rounded-md flex items-center justify-center text-sm font-semibold" :
                        type === "vip" ? "w-10 h-10 bg-yellow-400 rounded-md flex items-center justify-center text-sm font-semibold" :
                        "w-16 h-10 bg-pink-400 rounded-md flex items-center justify-center text-sm font-semibold";

                    const seatNumber = rowLabel + (c + 1);
                    seat.innerText = seatNumber;

                    seat.dataset.row = rowIndex;
                    seat.dataset.col = c;
                    seat.dataset.type = type;
                    seat.dataset.active = "1";

                    row.push({ type, active: 1, seatNumber });
                    rowDiv.appendChild(seat);
                }
                layout.push(row);
                seatPreview.appendChild(rowDiv);
            }
        }

        createRow("normal", normalRows, seatsPerRow);
        createRow("vip", vipRows, seatsPerRow);
        createRow("couple", coupleRows, coupleSeats);

        saveSeatLayout();
    }

    function saveSeatLayout() {
        const result = [];
        seatPreview.querySelectorAll("div > div").forEach((seat) => {
            const row = parseInt(seat.dataset.row);
            const col = parseInt(seat.dataset.col);
            const type = seat.dataset.type;
            const seatNumber = seat.innerText;

            if (!result[row]) result[row] = [];
            result[row].push({ type, col, seatNumber });
        });
        seatLayoutInput.value = JSON.stringify(result);
    }

    [seatsPerRowInput, normalRowsInput, vipRowsInput, coupleRowsInput, coupleSeatsInput]
        .forEach(input => input.addEventListener("input", renderSeats));

    renderSeats();
</script>
