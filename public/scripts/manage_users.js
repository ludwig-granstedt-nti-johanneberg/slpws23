const gen_image_button = document.getElementById("gen-image-button");

gen_image_button.addEventListener("click", function() {
    const uri = "/admin/generate_default_images";

    fetch(uri, {
        method: "POST",
        credentials: "same-origin",
        headers: {
            "Content-Type": "application/json"
        }
    });
});