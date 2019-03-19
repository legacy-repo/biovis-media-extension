function TabulatorViewer(divId, configs) {
    Papa.parse(configs.dataUrl, {
        download: true,
        header: true,
        dynamicTyping: true,
        complete: function(results) {
            var tableData = results.data
            var header = Object.keys(tableData[0])
            var table = new Tabulator("#" + divId, {
                height: '500px',
                data: tableData,        //load row data from array
                layout: "fitData",      //fit columns to width of table
                tooltips: true,            //show tool tips on cells
                reactiveData: true,
                pagination: "local",       //paginate the data
                paginationSize: 15,         //allow 7 rows per page of data
                movableColumns: true,      //allow column order to be changed
                resizableRows: false,       //allow row order to be changed
                columns: makeColumns(header),
                // autoColumns: true,
                pagination:"local",
                colVertAlign: "middle",
                showLoader: true,
                sortable: true,
                clipboard:true,
                placeholder:"No Data Available", //display message to user on empty table
                paginationSizeSelector:[20, 30, 40, 50, 100],
                persistentLayout: true,
                persistentSort: true,
                persistenceID: divId,
            });

            function makeColumns(header) {
                var columns = [
                    {formatter:"rownum", align:"center"},
                ]
                for (var index in header) {
                    if (configs.columnsType != undefined && configs.columnsType != null) {
                        var type = configs.columnsType[header[index]]
                        var column = getColumn(header[index], type)
                    } else {
                        var column = getColumn(header[index], null)
                    }
                    columns.push(column)
                }
                return columns
            }

            //trigger download of data.csv file
            $("#download-csv").click(function(){
                table.download("csv", "data.csv");
            });

            //trigger download of data.json file
            $("#download-json").click(function(){
                table.download("json", "data.json");
            });
        }
    });

    function linkIcon(cell, formatterParams) {
        return '<i class="fas fa-external-link-alt"></i>';
    };
    
    function getColumn(item, type) {
        var column = {
            title: item,
            field: item,
            align: 'center'
        }
    
        if (type === 'text') {
            column['formatter'] = "textarea"
        } else if (type === 'bool') {
            column['formatter'] = "tickCross"
        } else if (type === 'link') {
            column['formatter'] = function(cell, formatterParams) {return '<i class="fa fa-external-link fa-2x" aria-hidden="true"></i>';};
            column['cellClick'] = function(e, cell){ window.open(cell.getRow().getData()[item], '_blank') }
        } else if (type === 'star') {
            column['formatter'] = "star"
        } else if (type === 'progress') {
            column['formatter'] = "progress"
            column['formatterParams'] = {color: ["#00dd00", "orange", "rgb(255,0,0)"]}
        }
        return column
    }
}