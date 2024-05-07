window.addEventListener('DOMContentLoaded', event => {
    // Simple-DataTables
    // https://github.com/fiduswriter/Simple-DataTables/wiki

    const datatablesSimple = document.getElementById('datatablesSimple');
    if (datatablesSimple) {
        new simpleDatatables.DataTable({
            element : datatablesSimple,
            "lengthMenu" : [[10, 25, 50, -1], [10, 25, 50, "All"]]
        });
    }
});
