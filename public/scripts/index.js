const user_nav_button = document.getElementById("user-nav-button");
const user_nav = document.getElementById("user-nav-dropdown");

user_nav_button.addEventListener("click", function() {
    user_nav.classList.toggle("hidden");
});