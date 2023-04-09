const user_nav_button = document.getElementById("user-nav-button");
const user_nav = document.getElementById("user-nav-dropdown");

if (user_nav_button) {
    user_nav_button.addEventListener("click", function() {
        user_nav.classList.toggle("hidden");
    });
}

const errorModal = document.getElementById("error-modal");

window.addEventListener("load", function() {
    if (errorModal) {
        errorModal.style.display = "block";
    }
});