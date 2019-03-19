function PivotTableViewer(divId, configs) {
    var pivotInstance = document.querySelector('#wdr-pivot-view')

    if (pivotInstance) {
        $('#' + divId).html("<div class='alert alert-warning' role='alert' style='width: 100%;min-height: 300px; display: flex; justify-content: center; align-items: center;'><pre class='highlight'><code>Only one pivot-table-js plugin can be added into a choppy report.<br>If you have any questions, Please contact the plugin developer.</pre></code></div>");
        return
    }

    var pivot = new WebDataRocks({
        container: "#" + divId,
        beforetoolbarcreated: customizeToolbar,
        toolbar: true,
        report: {
            dataSource: {
                filename: configs.dataUrl
            },
            localization: "http://kancloud.nordata.cn/2019-03-18-custom-en.json"
        },
        reportcomplete: function() {
            var storage = window.sessionStorage;
            chartType = storage.getItem("pivot-current-chart");
            if (chartType == 'none') {
                $('#' + configs.tableId).append("<div class='alert alert-info' role='alert' style='width: 100%; display: flex; margin-bottom: 0px; justify-content: center; align-items: center;'><pre class='highlight'><code>No Chart, you can choose a chart from Chart Options.</pre></code></div>");
            } else if (chartType == 'barchart') {
                createBarChart();
            } else if (chartType == 'areaspline') {
                createChart('areaspline');
            } else if (chartType == 'arearange') {
                createChart('arearange');
            } else if (chartType == 'areasplinerange') {
                createChart('areasplinerange')
            } else if (chartType == 'area') {
                createChart('area')
            } else if (chartType == 'column') {
                createChart('column')
            } else if (chartType == 'bubble') {
                createChart('bubble')
            } else if (chartType == 'columnrange') {
                createChart('columnrange')
            } else if (chartType == 'errorbar') {
                createChart('errorbar')
            } else if (chartType == 'line') {
                createChart('line')
            } else if (chartType == 'funnel') {
                createChart('funnel')
            } else if (chartType == 'pie') {
                createChart('pie')
            } else if (chartType == 'polygon') {
                createChart('polygon')
            } else if (chartType == 'pyramid') {
                createChart('pyramid')
            } else if (chartType == 'scatter') {
                createChart('scatter')
            } else if (chartType == 'spline') {
                createChart('spline')
            } else if (chartType == 'waterfall') {
                createChart('waterfall')
            }

            $('#' + configs.tableId).append('<div id="pivot-chart-btn" class="suspend-btn"><span class="fa" aria-hidden="true"></span></div>');
            $('#' + configs.tableId).addClass('pivot-chart-origin');
            $('#pivot-chart-btn span').addClass('fa-caret-right');
    
            $('#' + configs.tableId).on('click', '#pivot-chart-btn', function(e){
                $('#' + configs.tableId).toggleClass('pivot-chart-suspend');
                $('#pivot-chart-btn span').toggleClass('fa-close fa-caret-right');
                var width = $('#' + configs.tableId).width();
                var height = $('#' + configs.tableId).height();
                console.log('height', height, 'width', width)
                var charts = $('#' + configs.tableId).highcharts()
                if (charts) {
                    charts.setSize(width, height, doAnimation = true);
                }
            });
        }
    });

    const { session, subscribe } = brownies;
    subscribe(session, 'pivot-current-chart', function(chartType) {
        console.log("Change chart type to " + chartType)
        if (chartType == 'none') {
            $('#' + configs.tableId).append("<div class='alert alert-info' role='alert' style='width: 100%; display: flex; margin-bottom: 0px; justify-content: center; align-items: center;'><pre class='highlight'><code>No Chart, you can choose a chart from Chart Options.</pre></code></div>");
        } else if (chartType == 'barchart') {
            createBarChart();
        } else if (chartType == 'areaspline') {
            createChart('areaspline');
        } else if (chartType == 'arearange') {
            createChart('arearange');
        } else if (chartType == 'areasplinerange') {
            createChart('areasplinerange')
        } else if (chartType == 'area') {
            createChart('area')
        } else if (chartType == 'column') {
            createChart('column')
        } else if (chartType == 'bubble') {
            createChart('bubble')
        } else if (chartType == 'columnrange') {
            createChart('columnrange')
        } else if (chartType == 'errorbar') {
            createChart('errorbar')
        } else if (chartType == 'line') {
            createChart('line')
        } else if (chartType == 'funnel') {
            createChart('funnel')
        } else if (chartType == 'pie') {
            createChart('pie')
        } else if (chartType == 'polygon') {
            createChart('polygon')
        } else if (chartType == 'pyramid') {
            createChart('pyramid')
        } else if (chartType == 'scatter') {
            createChart('scatter')
        } else if (chartType == 'spline') {
            createChart('spline')
        } else if (chartType == 'waterfall') {
            createChart('waterfall')
        }
    });

    function createChart(chartType) {
        pivot.highcharts.getData({
            // 'areaspline', 'arearange', 'areasplinerange', 'area',
            // 'column', 'bubble', 'columnrange', 'errorbar', 'line',
            // 'pie', 'funnel', 'polygon', 'pyramid', 'scatter', 'spline'
            // 'waterfall'
            type: chartType
        }, function(data) {
            Highcharts.chart(configs.tableId, data);
        }, function(data) {
            Highcharts.chart(configs.tableId, data);
        });
    }

    function createBarChart() {
        pivot.highcharts.getData({
            type: "bar"
        }, createAndUpdateBarChart, createAndUpdateBarChart);
    }

    function createAndUpdateBarChart(data, rawData) {
        if (data.yAxis == undefined) data.yAxis = {};
        // apply the number formatting from the pivot table to the tooltip
        data.tooltip = {
            pointFormat: pivot.highcharts.getPointYFormat(rawData.meta.formats[0])
        }
        Highcharts.chart(configs.tableId, data);
    }

    function customizeToolbar(toolbar) {
        var tabs = toolbar.getTabs(); // get all tabs from the toolbar
        if(configs.enableLocal) {
            toolbar.getTabs = function() {
                return tabs;
            }
        } else {
            toolbar.getTabs = function() {
                delete tabs[0]; // delete the first tab
                return tabs;
            }
        }
    };

    function customizeCellFunction(cellBuilder, cellData) {
        cellBuilder.style = {
            "font-size": "16px"
        }
    }
}
