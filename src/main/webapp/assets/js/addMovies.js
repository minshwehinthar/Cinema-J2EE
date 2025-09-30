(function () {
  const init = () => {
    const movieForm = document.querySelector(".movie-form");
    if (movieForm) {
      movieForm.addEventListener("submit", function (e) {
        e.preventDefault();

        const formData = new FormData(this);
        const movieData = {};

        for (let [key, value] of formData.entries()) {
          movieData[key] = value;
        }

        console.log("Movie data:", movieData);
        alert("Movie added successfully!");
        this.reset();
      });
    }

    const deleteButtons = document.querySelectorAll(
      'button[data-config-id*="txt-116ca4-"]'
    );
    deleteButtons.forEach((button) => {
      if (button.textContent.trim() === "Delete") {
        button.addEventListener("click", function () {
          if (
            confirm("Are you sure you want to delete this movie?")
          ) {
            const movieCard = this.closest(".bg-gray-50");
            if (movieCard) {
              movieCard.remove();
              alert("Movie deleted successfully!");
            }
          }
        });
      }
    });
  };

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", init);
  } else {
    init();
  }
})();