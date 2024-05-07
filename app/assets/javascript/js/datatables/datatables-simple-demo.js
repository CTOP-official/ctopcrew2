window.addEventListener('DOMContentLoaded', event => {
    // Simple-DataTables
    // https://github.com/fiduswriter/Simple-DataTables/wiki

    const datatablesSimple = document.getElementById('datatablesSimple');
    if (datatablesSimple) {
        new simpleDatatables.DataTable({
            element : datatablesSimple,
            perPageSelect : [["Five", 5], ["Ten", 10], ["All", 0]]
        });
    }
});
