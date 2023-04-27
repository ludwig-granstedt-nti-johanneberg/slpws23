const deleteAccountModal = document.getElementById("delete-account-modal");
const passwordConfirmationModal = document.getElementById(
    "password-confirmation-modal"
);
const deleteAccountConfirmationModal = document.getElementById(
    "delete-account-success-modal"
);

const deleteAccountButton = document.getElementById("delete-account-button");
const cancelDeleteButton = document.getElementById("cancel-delete-button");
const confirmDeleteButton = document.getElementById("confirm-delete-button");
const cancelDeleteButton2 = document.getElementById("cancel-delete-button2");

deleteAccountButton.addEventListener("click", function () {
    deleteAccountModal.style.display = "block";
});

cancelDeleteButton.addEventListener("click", function () {
    deleteAccountModal.style.display = "none";
});

confirmDeleteButton.addEventListener("click", function () {
    deleteAccountModal.style.display = "none";
    passwordConfirmationModal.style.display = "block";
});

cancelDeleteButton2.addEventListener("click", function () {
    passwordConfirmationModal.style.display = "none";
});

const uppdatePasswordForm = document.getElementById("update-password-form");

const password = document.getElementById("password");
const passwordConfirm = document.getElementById("password-confirm");

const passwordConfirmationError = document.getElementById("password-confirmation-error")

uppdatePasswordForm.addEventListener("submit", (event) => {
    event.preventDefault();

    if (password.value == "") {
        return;
    }

    if (password.value != passwordConfirm.value) {
        password.value = "";
        passwordConfirm.value = "";

        passwordConfirmationError.style.display = "block";
    } else {
        uppdatePasswordForm.submit();
    };

    event.target.submit();
});