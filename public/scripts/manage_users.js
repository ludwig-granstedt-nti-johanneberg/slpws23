const gen_image_button = document.getElementById("gen-image-button");

gen_image_button.addEventListener("click", function() {
    const uri = "/admin/generate_default_images";
    const cookies = getCookies();

    fetch(uri, {
        method: "POST",
        credentials: "same-origin",
        headers: {
            "Content-Type": "application/json"
        }
    });
});

function getCookies() {
    let cookies = {};
    let all = document.cookie;
    if (all === "")
      return cookies;
    let list = all.split("; ");
    for (let i = 0; i < list.length; i++) {
      let cookie = list[i];
      let p = cookie.indexOf("=");
      let name = cookie.substring(0, p);
      let value = cookie.substring(p + 1);
      value = decodeURIComponent(value);
      cookies[name] = value;
    }
    return cookies;
  }