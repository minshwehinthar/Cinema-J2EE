(function () {
  const init = () => {
    const navButtons = document.querySelectorAll(".nav-btn");
    const movieCards = document.querySelectorAll(".movie-card");

    navButtons.forEach((button) => {
      button.addEventListener("click", () => {
        const filter = button.getAttribute("data-filter");

        // Active button styling
        navButtons.forEach((btn) => {
          btn.classList.remove("bg-indigo-600", "text-white");
          btn.classList.add("text-gray-700");
        });

        button.classList.add("bg-indigo-600", "text-white");
        button.classList.remove("text-gray-700");

        // Filter movie cards
        movieCards.forEach((card) => {
          const status = card.getAttribute("data-status");
          if (filter === "all" || status === filter) {
            card.style.display = "block";
          } else {
            card.style.display = "none";
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
