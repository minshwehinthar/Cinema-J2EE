(function () {
  const init = () => {
    const trailerBtn = document.querySelector(".movie-trailer-btn");
    const trailerPopup = document.querySelector(".trailer-popup");
    const trailerClose = document.querySelector(".trailer-close");
    const ticketBtn = document.querySelector(".movie-ticket-btn");

    if (trailerBtn && trailerPopup) {
      trailerBtn.addEventListener("click", () => {
        trailerPopup.classList.remove("hidden");
        document.body.style.overflow = "hidden";
      });
    }

    if (trailerClose && trailerPopup) {
      trailerClose.addEventListener("click", () => {
        trailerPopup.classList.add("hidden");
        document.body.style.overflow = "auto";
      });
    }

    if (trailerPopup) {
      trailerPopup.addEventListener("click", (e) => {
        if (e.target === trailerPopup) {
          trailerPopup.classList.add("hidden");
          document.body.style.overflow = "auto";
        }
      });
    }

    if (ticketBtn) {
      ticketBtn.addEventListener("click", () => {
        alert("Redirecting to ticket booking...");
      });
    }
  };

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", init);
  } else {
    init();
  }
})();