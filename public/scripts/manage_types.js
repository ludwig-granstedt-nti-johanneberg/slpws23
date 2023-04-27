const typeSelectorForm = document.getElementById('type-selector-form');
const typeSelector = document.getElementById('type-selector');

typeSelector.addEventListener('change', () => {
    typeSelectorForm.submit();
});
