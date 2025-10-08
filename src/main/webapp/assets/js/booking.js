// Seat selection logic
const seatButtons = document.querySelectorAll('.seat.available');
const selectedSeatIdsInput = document.getElementById('selected-seat-ids');
const totalPriceInput = document.getElementById('total-price-input');
const seatsDisplay = document.getElementById('selected-seats-display');
const totalDisplay = document.getElementById('total-price-display');
let selectedSeats = [];

seatButtons.forEach(btn => {
    btn.addEventListener('click', () => {
        const seatId = btn.dataset.seatid;
        const price = parseFloat(btn.dataset.price);
        if(selectedSeats.includes(seatId)) {
            selectedSeats = selectedSeats.filter(s => s !== seatId);
            btn.classList.remove('selected');
        } else {
            selectedSeats.push(seatId);
            btn.classList.add('selected');
        }
        selectedSeatIdsInput.value = selectedSeats.join(',');
        const total = selectedSeats.reduce((sum, id) => {
            const b = Array.from(seatButtons).find(b => b.dataset.seatid === id);
            return sum + parseFloat(b.dataset.price);
        }, 0);
        totalPriceInput.value = total;
        seatsDisplay.textContent = selectedSeats.length > 0 ? "Seats: " + selectedSeats.join(", ") : "No seats selected.";
        totalDisplay.textContent = "Total: " + total + " MMK";
    });
});

// Payment selection styling
const paymentOptions = document.querySelectorAll('.payment-option');
paymentOptions.forEach(option => {
    const input = option.querySelector('input');
    option.addEventListener('click', () => {
        paymentOptions.forEach(o => o.classList.remove('selected'));
        option.classList.add('selected');
        input.checked = true;
    });
});