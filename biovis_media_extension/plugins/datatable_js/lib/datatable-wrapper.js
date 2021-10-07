function DataTableViewer(divId, configs) {
    // configs contains several arguments:
    // tableId, dataUrl, columnsType, enableItemSearch
    $('#' + divId).html('<table cellpadding="0" cellspacing="0" border="0" class="display" id="' + configs.tableId + '" style="width: 100%;"></table>');

    Papa.parse(configs.dataUrl, {
        delimiter: "",
        download: true,
        header: false,
        comments: "#",
        skipEmptyLines: true,
        dynamicTyping: true,
        // when worker is true, Error: Can't load PapaParse with a script loader.
        // see https://github.com/mholt/PapaParse/issues/148 for more details.
        worker: false,
        complete: function(results) {
            var tableData = results.data
            var header = tableData[0]

            // It is Not working currently.
            // TODO
            // if (configs.enableItemSearch) {
            //     $('#' + configs.tableId + ' tfoot th').each( function () {
            //         var title = $('#' + configs.tableId + ' thead th').eq( $(this).index() ).text();
            //         $(this).html( '<input type="text" placeholder="Search ' + title + '" />' );
            //     } );
            // }

            var table = $("#" + configs.tableId).DataTable({
                data: tableData.slice(1),
                processing: true,
                scrollX: true,
                scrollCollapse: true,
                scrollY: 400,
                columns: getColumn(header),
                dom: 'lfBrtip',
                colReorder: true,
                select: true,
                buttons: [
                    {
                        extend: 'collection',
                        text: 'Export',
                        buttons: [ 'copyHtml5', 'excelHtml5', 'csvHtml5']
                    }
                ]
            });

            // if (configs.enableItemSearch) {
            //     // Apply the search
            //     table.columns().eq( 0 ).each( function ( colIdx ) {
            //         $( 'input', table.column( colIdx ).footer() ).on( 'keyup change', function () {
            //             table
            //                 .column( colIdx )
            //                 .search( this.value )
            //                 .draw();
            //         });
            //     });              
            // }
        }
    });

    function linkIcon(cell, formatterParams) {
        return '<i class="fas fa-external-link-alt"></i>';
    };
    
    function getColumn(header) {
        var columns = []
    
        for (var item of header) {
            columns.push({
                "title": item,
                "name": item
            })
        }
        return columns
    }
}