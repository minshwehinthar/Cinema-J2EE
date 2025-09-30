(function() {
  const init = () => {
    const navButtons = document.querySelectorAll('.nav-btn');
    const movieCards = document.querySelectorAll('.movie-card');

    navButtons.forEach(button => {
      button.addEventListener('click', function() {
        const filter = this.getAttribute('data-filter');

        // Update active button styling
        navButtons.forEach(btn => {
          btn.classList.remove('bg-indigo-600', 'text-white');
          btn.classList.add('hover:bg-indigo-100');
        });
        this.classList.add('bg-indigo-600', 'text-white');
        this.classList.remove('hover:bg-indigo-100');

        // Filter movies
        movieCards.forEach(card => {
          const status = card.getAttribute('data-status');

          if (filter === 'all') {
            card.style.display = 'block';
          } else if (status === filter) {
            card.style.display = 'block';
          } else {
            card.style.display = 'none';
          }
        });
      });
    });
  };

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", init);
  } else {
    init();
  }
})();
