const form = document.getElementById("signup-form");
form.addEventListener("submit", (event) => {
    event.preventDefault();
    let password = document.getElementById("password-input");
    let passwordConfirm = document.getElementById(
        "password-confirm-input"
    );

    if (password.value != passwordConfirm.value) {
        password.value = "";
        passwordConfirm.value = "";

        // TODO: Add a better error message
        alert("Passwords do not match");
        return;
    }
    let email = document.getElementById("email-input");
    let emailConfirm = document.getElementById("email-confirm-input");

    if (email.value != username.value) {
        email.value = "";
        emailConfirm.value = "";

        // TODO: Add a better error message
        alert("Emails do not match");
        return;
    }

    form.submit();
});
