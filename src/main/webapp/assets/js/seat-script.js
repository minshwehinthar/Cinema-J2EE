document.addEventListener('DOMContentLoaded', function () {
    const dates = document.querySelectorAll('.date-btn');
    const timeslots = document.querySelectorAll('.slot-btn');
    const timeslotsContainer = document.getElementById('timeslots-container');
    const seatsContainer = document.getElementById('seat-rows'); 
    const selectedDateInput = document.getElementById('selected-date');
    const selectedSlotInput = document.getElementById('selected-slot-id');
    const selectedSeatsInput = document.getElementById('selected-seats');
    const confirmBtn = document.getElementById('confirm-btn');

    const summaryBox = document.getElementById('booking-summary');
    const seatNumbersElem = document.getElementById('selected-seat-numbers');
    const totalPriceElem = document.getElementById('total-price');

    if(dates.length > 0){
        dates.forEach(dateBtn => {
            dateBtn.addEventListener('click', () => {
                const date = dateBtn.dataset.date;
                selectedDateInput.value = date;

                dates.forEach(d => { 
                    d.classList.remove('bg-indigo-600','text-white'); 
                    d.classList.add('bg-white','text-black'); 
                });
                dateBtn.classList.add('bg-indigo-600','text-white'); 
                dateBtn.classList.remove('bg-white','text-black');

                timeslotsContainer.classList.remove('hidden');
                document.getElementById('seats-container').classList.add('hidden');
                timeslots.forEach(slot => slot.classList.toggle('hidden', slot.dataset.date !== date));

                selectedSlotInput.value = '';
                selectedSeatsInput.value = '';
                confirmBtn.disabled = true;
                summaryBox.style.display = 'none';
            });
        });
    }

    timeslots.forEach(slotBtn => {
        slotBtn.addEventListener('click', () => {
            timeslots.forEach(s => s.classList.remove('bg-indigo-800'));
            slotBtn.classList.add('bg-indigo-800');
            selectedSlotInput.value = slotBtn.dataset.slotId;

            document.getElementById('seats-container').classList.remove('hidden');
            document.querySelectorAll('#seat-rows .seat').forEach(seat => seat.classList.remove('selected'));
            selectedSeatsInput.value = '';
            confirmBtn.disabled = true;
            summaryBox.style.display = 'none';
        });
    });

    seatsContainer.addEventListener('click', function(e) {
        const seat = e.target;
        if (!seat.classList.contains('seat') || seat.disabled || seat.classList.contains('booked')) return;

        seat.classList.toggle('selected');

        const selectedSeats = Array.from(seatsContainer.querySelectorAll('.seat.selected'));
        const seatNumbers = selectedSeats.map(s => s.dataset.seat);
        const totalPrice = selectedSeats.reduce((sum, s) => sum + parseFloat(s.dataset.price), 0);

        selectedSeatsInput.value = seatNumbers.join(',');

        if (seatNumbers.length > 0) {
            summaryBox.style.display = 'block';
            seatNumbersElem.textContent = 'Seats: ' + seatNumbers.join(', ');
            totalPriceElem.textContent = 'Total Price: ' + totalPrice.toLocaleString() + ' MMK';
        } else {
            summaryBox.style.display = 'none';
        }

        confirmBtn.disabled = selectedSeats.length === 0;
    });
});